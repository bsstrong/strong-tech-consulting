#requires -Version 5.1
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [ValidateSet('AppDev', 'SourceZorka', 'WebE2E', 'CloudOps')]
    [string[]]$Profile = @('AppDev'),
    [string]$WorkspaceRoot = 'C:\dev',
    [switch]$CheckOnly,
    [switch]$IncludeRecommended
)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'SeaSharp.Onboarding.psm1') -Force

$resolvedRoot = Resolve-SeaSharpWorkspaceRoot $WorkspaceRoot
$resolvedProfiles = Get-SeaSharpProfileNames -Profile $Profile
$packages = Get-SeaSharpProfilePackages -Profile $Profile -IncludeRecommended:$IncludeRecommended
$missing = New-Object 'System.Collections.Generic.List[string]'

Write-SeaSharpStatus INFO "Profiles: $($resolvedProfiles -join ', ')"
Write-SeaSharpStatus INFO "Workspace root: $resolvedRoot"

if (-not (Test-SeaSharpCommand 'winget')) {
    Write-SeaSharpStatus FAIL 'Windows Package Manager (winget) is unavailable.'
    throw 'Windows Package Manager (winget) is required. Install App Installer from Microsoft Store, then rerun this script.'
}

foreach ($package in $packages) {
    $commandPresent = Test-SeaSharpCommand ([string]$package.command)
    $installedByWinget = $false
    if (-not $commandPresent) {
        & winget list --id ([string]$package.id) --exact --accept-source-agreements --disable-interactivity *> $null
        $installedByWinget = $LASTEXITCODE -eq 0
    }

    if ($commandPresent) {
        Write-SeaSharpStatus SKIP "$($package.id) is already available."
        continue
    }
    if ($installedByWinget) {
        Write-SeaSharpStatus WARN "$($package.id) is installed but '$($package.command)' is not on this process PATH. Open a new terminal after setup."
        continue
    }

    $missing.Add([string]$package.id)
    if ($CheckOnly) {
        Write-SeaSharpStatus WARN "$($package.id) is missing."
        continue
    }

    if ($PSCmdlet.ShouldProcess([string]$package.id, 'Install with winget')) {
        Write-SeaSharpStatus INSTALL "Installing $($package.id) with winget."
        & winget install --id ([string]$package.id) --exact --silent --accept-package-agreements --accept-source-agreements --disable-interactivity
        if ($LASTEXITCODE -ne 0) { throw "winget could not install $($package.id)." }
        Write-SeaSharpStatus PASS "$($package.id) installed."
        Update-SeaSharpProcessPath
    }
}

if ($CheckOnly) {
    if ($missing.Count -eq 0) { Write-SeaSharpStatus PASS 'All selected winget prerequisites are installed.' }
    else { Write-SeaSharpStatus WARN "$($missing.Count) selected winget prerequisite(s) are missing." }
    Update-SeaSharpProcessPath
    if (Test-SeaSharpCommand 'fnm') {
        $installedVersions = @(& fnm list 2>$null | ForEach-Object { [string]$_ })
        foreach ($version in (Get-SeaSharpNodeVersions -Profile $Profile)) {
            if (Test-SeaSharpNodeVersion -InstalledVersionLines $installedVersions -RequestedVersion $version) {
                Write-SeaSharpStatus SKIP "Node.js $version is already installed."
            }
            else {
                Write-SeaSharpStatus WARN "Node.js $version is missing."
            }
        }
        if ($resolvedProfiles -contains 'SourceZorka') {
            $requiredCorepack = [string](Get-SeaSharpConfig).corepackVersion
            foreach ($version in (Get-SeaSharpNodeVersions -Profile $Profile)) {
                $corepackFound = (& fnm exec --using $version corepack --version 2>$null | Select-Object -First 1)
                if ($LASTEXITCODE -eq 0 -and ([string]$corepackFound).Trim() -eq $requiredCorepack) {
                    Write-SeaSharpStatus SKIP "Corepack $requiredCorepack is already available under Node.js $version."
                }
                else {
                    Write-SeaSharpStatus WARN "Corepack $requiredCorepack is missing under Node.js $version."
                }
            }
        }
    }
    if ($resolvedProfiles -contains 'WebE2E') {
        $helixPath = Get-SeaSharpProductPath -Product Helix -WorkspaceRoot $resolvedRoot
        $lockPath = Join-Path $helixPath 'package-lock.json'
        $playwrightStamp = Join-Path $helixPath 'node_modules\.seasharp-playwright-package-lock.sha256'
        $playwrightCurrent = (Test-Path -LiteralPath $lockPath -PathType Leaf) -and
            (Test-Path -LiteralPath $playwrightStamp -PathType Leaf) -and
            ((Get-Content -LiteralPath $playwrightStamp -Raw).Trim() -eq (Get-FileHash -LiteralPath $lockPath -Algorithm SHA256).Hash)
        if ($playwrightCurrent) { Write-SeaSharpStatus SKIP 'Helix Playwright Chromium matches package-lock.json.' }
        else { Write-SeaSharpStatus WARN 'Helix Playwright Chromium is not verified for the current lockfile (install during Helix initialization).' }
    }
    if ($resolvedProfiles -contains 'CloudOps' -and (Test-SeaSharpCommand 'az')) {
        if (Test-SeaSharpBicepInstalled) { Write-SeaSharpStatus SKIP 'Azure Bicep CLI is already installed.' }
        else { Write-SeaSharpStatus WARN 'Azure Bicep CLI is missing.' }
    }
    return
}

Update-SeaSharpProcessPath
if (-not (Test-SeaSharpCommand 'fnm')) {
    Write-SeaSharpStatus WARN 'fnm is not available in this terminal yet. Open a new PowerShell terminal and rerun this script to install Node runtimes.'
    return
}

$nodeVersions = Get-SeaSharpNodeVersions -Profile $Profile
foreach ($version in $nodeVersions) {
    $installedVersions = @(& fnm list 2>$null | ForEach-Object { [string]$_ })
    $isInstalled = Test-SeaSharpNodeVersion -InstalledVersionLines $installedVersions -RequestedVersion $version
    if ($isInstalled) {
        Write-SeaSharpStatus SKIP "Node.js $version is already installed."
    }
    elseif ($PSCmdlet.ShouldProcess("Node.js $version", 'Install with fnm')) {
        Write-SeaSharpStatus INSTALL "Installing Node.js $version with fnm."
        Invoke-SeaSharpCommand -FilePath 'fnm' -ArgumentList @('install', $version)
        Write-SeaSharpStatus PASS "Node.js $version installed."
    }
}

$primaryNodeVersion = if ($nodeVersions -contains '24.19.0') { '24.19.0' } else { $nodeVersions[0] }
if ($primaryNodeVersion) {
    $defaultLines = @(& fnm list 2>$null | Where-Object { [string]$_ -match 'default' } | ForEach-Object { [string]$_ })
    if (Test-SeaSharpNodeVersion -InstalledVersionLines $defaultLines -RequestedVersion $primaryNodeVersion) {
        Write-SeaSharpStatus SKIP "Node.js $primaryNodeVersion is already the fnm default."
    }
    elseif ($PSCmdlet.ShouldProcess("Node.js $primaryNodeVersion", 'Set fnm default')) {
        Write-SeaSharpStatus INSTALL "Setting Node.js $primaryNodeVersion as the fnm default."
        Invoke-SeaSharpCommand -FilePath 'fnm' -ArgumentList @('default', $primaryNodeVersion)
        Write-SeaSharpStatus PASS "Node.js $primaryNodeVersion is the fnm default."
    }
}

if ($resolvedProfiles -contains 'SourceZorka') {
    $corepackVersion = [string](Get-SeaSharpConfig).corepackVersion
    foreach ($nodeVersion in $nodeVersions) {
        $installedCorepack = (& fnm exec --using $nodeVersion corepack --version 2>$null | Select-Object -First 1)
        if ($LASTEXITCODE -eq 0 -and ([string]$installedCorepack).Trim() -eq $corepackVersion) {
            Write-SeaSharpStatus SKIP "Corepack $corepackVersion is already available under Node.js $nodeVersion."
        }
        elseif ($PSCmdlet.ShouldProcess("Node.js $nodeVersion", "Install Corepack $corepackVersion")) {
            Write-SeaSharpStatus INSTALL "Installing Corepack $corepackVersion under Node.js $nodeVersion."
            Invoke-SeaSharpCommand -FilePath 'fnm' -ArgumentList @('exec', '--using', $nodeVersion, 'npm', 'install', '--global', "corepack@$corepackVersion")
            Write-SeaSharpStatus PASS "Corepack $corepackVersion installed under Node.js $nodeVersion."
        }
    }
}

if ($resolvedProfiles -contains 'WebE2E') {
    $helixPath = Get-SeaSharpProductPath -Product Helix -WorkspaceRoot $resolvedRoot
    $lockPath = Join-Path $helixPath 'package-lock.json'
    $playwrightStamp = Join-Path $helixPath 'node_modules\.seasharp-playwright-package-lock.sha256'
    $lockHash = if (Test-Path -LiteralPath $lockPath -PathType Leaf) { (Get-FileHash -LiteralPath $lockPath -Algorithm SHA256).Hash } else { $null }
    $playwrightCurrent = $lockHash -and (Test-Path -LiteralPath $playwrightStamp -PathType Leaf) -and
        ((Get-Content -LiteralPath $playwrightStamp -Raw).Trim() -eq $lockHash)
    if ($playwrightCurrent) {
        Write-SeaSharpStatus SKIP 'Helix Playwright Chromium already matches package-lock.json.'
    }
    elseif ($lockHash -and (Test-Path -LiteralPath (Join-Path $helixPath 'node_modules'))) {
        if ($PSCmdlet.ShouldProcess($helixPath, 'Install Playwright Chromium browser')) {
            Write-SeaSharpStatus INSTALL 'Installing Playwright Chromium.'
            Invoke-SeaSharpCommand -FilePath 'fnm' -ArgumentList @('exec', '--using', '24.19.0', 'npx', 'playwright', 'install', 'chromium') -WorkingDirectory $helixPath
            [System.IO.File]::WriteAllText($playwrightStamp, $lockHash, (New-Object System.Text.UTF8Encoding($false)))
            Write-SeaSharpStatus PASS 'Playwright Chromium installed.'
        }
    }
    else {
        Write-SeaSharpStatus WARN 'Playwright installation is deferred until Helix dependencies exist. Run Initialize-HelixWorkspace.ps1 -InstallPlaywright.'
    }
}

if ($resolvedProfiles -contains 'CloudOps' -and (Test-SeaSharpCommand 'az')) {
    if (Test-SeaSharpBicepInstalled) {
        Write-SeaSharpStatus SKIP 'Azure Bicep CLI is already installed.'
    }
    elseif ($PSCmdlet.ShouldProcess('Azure Bicep CLI', 'Install through Azure CLI')) {
        Write-SeaSharpStatus INSTALL 'Installing Azure Bicep CLI.'
        Invoke-SeaSharpCommand -FilePath 'az' -ArgumentList @('bicep', 'install')
        Write-SeaSharpStatus PASS 'Azure Bicep CLI installed.'
    }
}

Write-SeaSharpStatus PASS 'Prerequisite installation is complete.'
Write-SeaSharpStatus INFO 'Docker Desktop may require first-run license acceptance, sign-in, or a restart.'
