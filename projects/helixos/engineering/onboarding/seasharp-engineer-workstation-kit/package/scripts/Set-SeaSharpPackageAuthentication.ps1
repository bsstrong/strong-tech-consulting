#requires -Version 5.1
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$GitHubUser,
    [switch]$ConfigureNpm,
    [switch]$ConfigureGhcr,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'SeaSharp.Onboarding.psm1') -Force

function Test-NpmPackageReadAccess {
    $nodeVersion = [string](Get-SeaSharpConfig).products.Helix.nodeVersion
    if (Test-SeaSharpCommand 'fnm') {
        $installedNodes = @(& fnm list 2>$null | ForEach-Object { [string]$_ })
        if (Test-SeaSharpNodeVersion -InstalledVersionLines $installedNodes -RequestedVersion $nodeVersion) {
            & fnm exec --using $nodeVersion npm view '@zorkacom/api-client' version --registry=https://npm.pkg.github.com *> $null
            return $LASTEXITCODE -eq 0
        }
    }
    if (Test-SeaSharpCommand 'npm') {
        & npm view '@zorkacom/api-client' version --registry=https://npm.pkg.github.com *> $null
        return $LASTEXITCODE -eq 0
    }
    $null
}

if (-not $ConfigureNpm -and -not $ConfigureGhcr) {
    $ConfigureNpm = $true
    $ConfigureGhcr = $true
}

if ($ConfigureNpm -and -not $Force) {
    $existingNpmrc = Join-Path $env:USERPROFILE '.npmrc'
    $npmReady = $false
    if (Test-Path -LiteralPath $existingNpmrc -PathType Leaf) {
        $existingNpmContent = Get-Content -LiteralPath $existingNpmrc -Raw
        $npmReady = $existingNpmContent -match '(?m)^@zorkacom:registry=https://npm\.pkg\.github\.com/?\s*$' -and
            $existingNpmContent -match '(?m)^//npm\.pkg\.github\.com/:_authToken=\S+' -and
            $existingNpmContent -match '(?m)^always-auth=true\s*$'
    }
    if ($npmReady) {
        $packageAccess = Test-NpmPackageReadAccess
        if ($packageAccess -eq $false) {
            Write-SeaSharpStatus WARN 'Existing npm authentication is present, but private-package access could not be verified. Confirm network, SSO, and package permissions; use -Force only when replacement is required.'
        }
        elseif ($null -eq $packageAccess) {
            Write-SeaSharpStatus WARN 'Existing npm authentication is present, but package access could not be verified because npm is unavailable.'
        }
    }
    if ($npmReady) {
        Write-SeaSharpStatus SKIP 'GitHub Packages npm authentication is already configured. Use -Force to replace it.'
        $ConfigureNpm = $false
    }
}

if ($ConfigureGhcr -and -not $Force) {
    $dockerConfigPath = Join-Path $env:USERPROFILE '.docker\config.json'
    $ghcrReady = $false
    if (Test-Path -LiteralPath $dockerConfigPath -PathType Leaf) {
        try {
            $dockerConfig = Get-Content -LiteralPath $dockerConfigPath -Raw | ConvertFrom-Json
            $ghcrReady = $null -ne $dockerConfig.auths.'ghcr.io'
        }
        catch { }
    }
    if ($ghcrReady) {
        Write-SeaSharpStatus SKIP 'Docker authentication for ghcr.io is already configured. Use -Force to replace it.'
        $ConfigureGhcr = $false
    }
}

if (-not $ConfigureNpm -and -not $ConfigureGhcr) {
    Write-SeaSharpStatus PASS 'Requested package and registry authentication is already configured.'
    return
}

if ($WhatIfPreference) {
    if ($ConfigureNpm) { Write-SeaSharpStatus INFO 'Would securely prompt for a GitHub token, validate it, and configure user-scoped npm authentication.' }
    if ($ConfigureGhcr) { Write-SeaSharpStatus INFO 'Would securely prompt for a GitHub token, validate it, and configure Docker authentication for ghcr.io.' }
    Write-SeaSharpStatus SKIP 'No credentials were requested or changed because -WhatIf was supplied.'
    return
}

if ($ConfigureGhcr -and -not (Test-SeaSharpCommand 'docker')) {
    Write-SeaSharpStatus FAIL 'Docker is unavailable.'
    throw 'Docker is required to configure GHCR authentication.'
}
if ([string]::IsNullOrWhiteSpace($GitHubUser)) {
    $GitHubUser = Read-Host 'GitHub username'
}
if ([string]::IsNullOrWhiteSpace($GitHubUser)) { throw 'A GitHub username is required.' }

Write-SeaSharpStatus INFO 'Enter a GitHub token authorized for the Sea Sharp organizations with read:packages access.'
$secureToken = Read-Host 'GitHub token' -AsSecureString
$tokenPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureToken)
$plainToken = $null
try {
    $plainToken = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($tokenPointer)
    if ([string]::IsNullOrWhiteSpace($plainToken)) { throw 'The token cannot be empty.' }

    try {
        $headers = @{
            Authorization = "Bearer $plainToken"
            Accept = 'application/vnd.github+json'
            'User-Agent' = 'SeaSharp-Engineer-Workstation-Kit'
            'X-GitHub-Api-Version' = '2022-11-28'
        }
        $identity = Invoke-RestMethod -Uri 'https://api.github.com/user' -Headers $headers -Method Get -UseBasicParsing
        if (-not $identity.login) { throw 'GitHub did not return an authenticated identity.' }
        if ([string]$identity.login -ne $GitHubUser) {
            throw "The supplied credential authenticates as '$($identity.login)', not '$GitHubUser'."
        }
        Write-SeaSharpStatus PASS "Authenticated GitHub identity: $($identity.login)"
    }
    catch {
        throw "GitHub credential validation failed: $($_.Exception.Message)"
    }

    if ($ConfigureNpm) {
        $npmrcPath = Join-Path $env:USERPROFILE '.npmrc'
        if ($PSCmdlet.ShouldProcess($npmrcPath, 'Configure private @zorkacom package authentication')) {
            Write-SeaSharpStatus INSTALL 'Configuring GitHub Packages npm authentication.'
            $npmrcExisted = Test-Path -LiteralPath $npmrcPath -PathType Leaf
            $previousNpmrc = if ($npmrcExisted) { Get-Content -LiteralPath $npmrcPath -Raw } else { $null }
            $existing = @()
            if ($npmrcExisted) {
                $existing = @(Get-Content -LiteralPath $npmrcPath | Where-Object {
                    $_ -notmatch '^\s*@zorkacom:registry\s*=' -and
                    $_ -notmatch '^\s*//npm\.pkg\.github\.com/:_authToken\s*=' -and
                    $_ -notmatch '^\s*always-auth\s*='
                })
            }
            $updated = @($existing) + @(
                '@zorkacom:registry=https://npm.pkg.github.com',
                "//npm.pkg.github.com/:_authToken=$plainToken",
                'always-auth=true'
            )
            [System.IO.File]::WriteAllLines($npmrcPath, [string[]]$updated, (New-Object System.Text.UTF8Encoding($false)))
            $packageAccess = Test-NpmPackageReadAccess
            if ($packageAccess -eq $false) {
                if ($npmrcExisted) {
                    [System.IO.File]::WriteAllText($npmrcPath, $previousNpmrc, (New-Object System.Text.UTF8Encoding($false)))
                }
                else {
                    Remove-Item -LiteralPath $npmrcPath -Force
                }
                Write-SeaSharpStatus FAIL 'The credential cannot read the required private package; npm configuration changes were rolled back.'
                throw 'The previous npm configuration was restored. Confirm read:packages permission, repository/package access, and organization SSO authorization, then rerun with -Force.'
            }
            elseif ($null -eq $packageAccess) {
                Write-SeaSharpStatus WARN 'GitHub Packages authentication was saved, but package access could not be verified because npm is unavailable.'
            }
            else {
                Write-SeaSharpStatus PASS "Configured and verified GitHub Packages authentication in $npmrcPath."
            }
        }
    }

    if ($ConfigureGhcr) {
        if ($PSCmdlet.ShouldProcess('ghcr.io', 'Configure Docker registry authentication')) {
            Write-SeaSharpStatus INSTALL 'Configuring Docker authentication for ghcr.io.'
            $startInfo = New-Object System.Diagnostics.ProcessStartInfo
            $startInfo.FileName = 'docker'
            $startInfo.Arguments = "login ghcr.io --username `"$GitHubUser`" --password-stdin"
            $startInfo.UseShellExecute = $false
            $startInfo.RedirectStandardInput = $true
            $startInfo.RedirectStandardOutput = $true
            $startInfo.RedirectStandardError = $true
            $startInfo.CreateNoWindow = $true
            $process = New-Object System.Diagnostics.Process
            $process.StartInfo = $startInfo
            $null = $process.Start()
            $process.StandardInput.WriteLine($plainToken)
            $process.StandardInput.Close()
            $standardOutput = $process.StandardOutput.ReadToEnd()
            $standardError = $process.StandardError.ReadToEnd()
            $process.WaitForExit()
            if ($process.ExitCode -ne 0) {
                throw "Docker registry login failed: $($standardError.Trim())"
            }
            Write-SeaSharpStatus PASS 'Configured Docker authentication for ghcr.io.'
        }
    }
}
finally {
    $plainToken = $null
    if ($tokenPointer -ne [IntPtr]::Zero) {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($tokenPointer)
    }
}
