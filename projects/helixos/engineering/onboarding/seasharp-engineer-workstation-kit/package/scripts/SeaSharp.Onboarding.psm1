Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

function Get-SeaSharpKitRoot {
    Split-Path -Parent $PSScriptRoot
}

function Write-SeaSharpStatus {
    param(
        [Parameter(Mandatory = $true)][ValidateSet('INFO', 'PASS', 'SKIP', 'INSTALL', 'WARN', 'FAIL')][string]$Status,
        [Parameter(Mandatory = $true)][string]$Message
    )

    $color = switch ($Status) {
        'PASS' { 'Green' }
        'SKIP' { 'DarkGray' }
        'INSTALL' { 'Cyan' }
        'WARN' { 'Yellow' }
        'FAIL' { 'Red' }
        default { 'Gray' }
    }
    Write-Host "[$Status] $Message" -ForegroundColor $color
}

function Get-SeaSharpConfig {
    $configPath = Join-Path (Get-SeaSharpKitRoot) 'config\workstation.json'
    if (-not (Test-Path -LiteralPath $configPath -PathType Leaf)) {
        throw "Workstation configuration was not found at $configPath."
    }

    Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
}

function Resolve-SeaSharpWorkspaceRoot {
    param([string]$WorkspaceRoot)

    if ([string]::IsNullOrWhiteSpace($WorkspaceRoot)) {
        $WorkspaceRoot = (Get-SeaSharpConfig).defaultWorkspaceRoot
    }

    [System.IO.Path]::GetFullPath([Environment]::ExpandEnvironmentVariables($WorkspaceRoot))
}

function Get-SeaSharpProfileNames {
    param([string[]]$Profile = @('AppDev'))

    $config = Get-SeaSharpConfig
    $resolved = New-Object 'System.Collections.Generic.List[string]'

    function Add-Profile([string]$Name) {
        $property = $config.profiles.PSObject.Properties[$Name]
        if ($null -eq $property) {
            throw "Unknown profile '$Name'. Valid profiles: $($config.profiles.PSObject.Properties.Name -join ', ')."
        }
        $includesProperty = $property.Value.PSObject.Properties['includes']
        $includedProfiles = if ($null -eq $includesProperty) { @() } else { @($includesProperty.Value) }
        foreach ($included in $includedProfiles) {
            if ($included) { Add-Profile ([string]$included) }
        }
        if (-not $resolved.Contains($Name)) { $resolved.Add($Name) }
    }

    foreach ($name in $Profile) { Add-Profile $name }
    $resolved.ToArray()
}

function Get-SeaSharpProfilePackages {
    param(
        [string[]]$Profile = @('AppDev'),
        [switch]$IncludeRecommended
    )

    $config = Get-SeaSharpConfig
    $byId = @{}
    foreach ($name in (Get-SeaSharpProfileNames -Profile $Profile)) {
        $profileConfig = $config.profiles.PSObject.Properties[$name].Value
        $classification = [string]$profileConfig.classification
        if ($classification -notin @('required', 'optional')) {
            throw "Profile '$name' must have a required or optional classification."
        }
        foreach ($package in @($config.profiles.$name.wingetPackages)) {
            $byId[[string]$package.id] = [pscustomobject]@{
                id = [string]$package.id
                command = [string]$package.command
                required = [bool]$package.required
                sourceProfile = $name
                profileClassification = $classification
            }
        }
    }
    if ($IncludeRecommended) {
        foreach ($package in @($config.recommendedWingetPackages)) {
            $byId[[string]$package.id] = [pscustomobject]@{
                id = [string]$package.id
                command = [string]$package.command
                required = $false
                sourceProfile = 'Recommended'
                profileClassification = 'optional'
            }
        }
    }
    @($byId.Values | Sort-Object id)
}

function Get-SeaSharpNodeVersions {
    param([string[]]$Profile = @('AppDev'))

    $config = Get-SeaSharpConfig
    $versions = New-Object 'System.Collections.Generic.List[string]'
    foreach ($name in (Get-SeaSharpProfileNames -Profile $Profile)) {
        $profileConfig = $config.profiles.PSObject.Properties[$name].Value
        $nodeProperty = $profileConfig.PSObject.Properties['nodeVersions']
        $profileNodeVersions = if ($null -eq $nodeProperty) { @() } else { @($nodeProperty.Value) }
        foreach ($version in $profileNodeVersions) {
            if ($version -and -not $versions.Contains([string]$version)) {
                $versions.Add([string]$version)
            }
        }
    }
    $versions.ToArray()
}

function Test-SeaSharpCommand {
    param([Parameter(Mandatory = $true)][string]$Name)
    $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

function Test-SeaSharpNodeVersion {
    param(
        [Parameter(Mandatory = $true)][string[]]$InstalledVersionLines,
        [Parameter(Mandatory = $true)][string]$RequestedVersion
    )

    $escaped = [regex]::Escape($RequestedVersion)
    $suffix = if ($RequestedVersion -match '^\d+(\.\d+)?$') { '(\.|\s|$)' } else { '(\s|$)' }
    @($InstalledVersionLines | Where-Object { $_ -match "(^|\s|v)$escaped$suffix" }).Count -gt 0
}

function Invoke-SeaSharpCommand {
    param(
        [Parameter(Mandatory = $true)][string]$FilePath,
        [string[]]$ArgumentList = @(),
        [string]$WorkingDirectory
    )

    $oldLocation = Get-Location
    try {
        if ($WorkingDirectory) { Set-Location -LiteralPath $WorkingDirectory }
        & $FilePath @ArgumentList
        if ($LASTEXITCODE -ne 0) {
            throw "$FilePath failed with exit code $LASTEXITCODE."
        }
    }
    finally {
        if ($WorkingDirectory) { Set-Location -LiteralPath $oldLocation }
    }
}

function Get-SeaSharpContentFingerprint {
    param([Parameter(Mandatory = $true)][string[]]$Path)

    $entries = New-Object 'System.Collections.Generic.List[string]'
    foreach ($candidate in $Path) {
        if (-not (Test-Path -LiteralPath $candidate)) { continue }
        $item = Get-Item -LiteralPath $candidate
        $files = if ($item.PSIsContainer) {
            @(Get-ChildItem -LiteralPath $item.FullName -File -Recurse | Sort-Object FullName)
        }
        else { @($item) }

        foreach ($file in $files) {
            $entries.Add("$($file.FullName.ToLowerInvariant())|$((Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash)")
        }
    }

    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes(($entries -join "`n"))
        ([BitConverter]::ToString($sha256.ComputeHash($bytes))).Replace('-', '')
    }
    finally { $sha256.Dispose() }
}

function Test-SeaSharpComposeServiceRunning {
    param(
        [Parameter(Mandatory = $true)][string]$WorkingDirectory,
        [Parameter(Mandatory = $true)][string]$Service
    )

    $oldLocation = Get-Location
    try {
        Set-Location -LiteralPath $WorkingDirectory
        $services = @(& docker compose ps --status running --services 2>$null | ForEach-Object { ([string]$_).Trim() })
        $LASTEXITCODE -eq 0 -and $services -contains $Service
    }
    catch { $false }
    finally { Set-Location -LiteralPath $oldLocation }
}

function Test-SeaSharpGitRemoteMatches {
    param(
        [Parameter(Mandatory = $true)][string]$Actual,
        [Parameter(Mandatory = $true)][string]$Expected
    )

    function Normalize-GitHubRemote([string]$Remote) {
        $value = $Remote.Trim().TrimEnd('/')
        $value = $value -replace '^git@github\.com:', 'https://github.com/'
        $value = $value -replace '^ssh://git@github\.com/', 'https://github.com/'
        ($value -replace '\.git$', '').ToLowerInvariant()
    }

    (Normalize-GitHubRemote $Actual) -eq (Normalize-GitHubRemote $Expected)
}

function Test-SeaSharpBicepInstalled {
    $azureConfigRoot = if ($env:AZURE_CONFIG_DIR) { $env:AZURE_CONFIG_DIR } else { Join-Path $env:USERPROFILE '.azure' }
    Test-Path -LiteralPath (Join-Path $azureConfigRoot 'bin\bicep.exe') -PathType Leaf
}

function Get-SeaSharpHelixZorkaImage {
    param([Parameter(Mandatory = $true)][string]$RepositoryPath)

    $composePath = Join-Path $RepositoryPath 'docker-compose.yml'
    if (-not (Test-Path -LiteralPath $composePath -PathType Leaf)) {
        throw "Helix Docker Compose configuration was not found at $composePath."
    }

    $oldLocation = Get-Location
    try {
        Set-Location -LiteralPath $RepositoryPath
        $rawConfig = (& docker compose --profile zorka config --format json 2>$null) -join "`n"
        if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($rawConfig)) {
            throw 'Docker Compose could not resolve the Helix zorka service configuration.'
        }
        $composeConfig = $rawConfig | ConvertFrom-Json
        $image = [string]$composeConfig.services.zorka.image
        if ([string]::IsNullOrWhiteSpace($image)) {
            throw 'Docker Compose did not resolve an image for the Helix zorka service.'
        }
        $image.Trim()
    }
    finally { Set-Location -LiteralPath $oldLocation }
}

function Update-SeaSharpProcessPath {
    $machine = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $user = [Environment]::GetEnvironmentVariable('Path', 'User')
    $env:Path = (@($machine, $user) | Where-Object { $_ }) -join ';'
}

function Get-SeaSharpProductPath {
    param(
        [Parameter(Mandatory = $true)][ValidateSet('Helix', 'Zorka')][string]$Product,
        [string]$WorkspaceRoot
    )

    $config = Get-SeaSharpConfig
    Join-Path (Resolve-SeaSharpWorkspaceRoot $WorkspaceRoot) ([string]$config.products.$Product.directory)
}

function Test-SeaSharpTcpPort {
    param([string]$HostName = '127.0.0.1', [int]$Port, [int]$TimeoutMilliseconds = 1500)

    $client = New-Object System.Net.Sockets.TcpClient
    try {
        $async = $client.BeginConnect($HostName, $Port, $null, $null)
        if (-not $async.AsyncWaitHandle.WaitOne($TimeoutMilliseconds, $false)) { return $false }
        $client.EndConnect($async)
        $true
    }
    catch { $false }
    finally { $client.Close() }
}

function Test-SeaSharpHttpEndpoint {
    param([Parameter(Mandatory = $true)][string]$Uri, [int]$TimeoutSeconds = 3)

    try {
        $response = Invoke-WebRequest -Uri $Uri -Method Get -UseBasicParsing -TimeoutSec $TimeoutSeconds
        $response.StatusCode -ge 200 -and $response.StatusCode -lt 500
    }
    catch {
        if ($_.Exception.Response -and [int]$_.Exception.Response.StatusCode -lt 500) { return $true }
        $false
    }
}

Export-ModuleMember -Function Write-SeaSharpStatus, Get-SeaSharpConfig, Resolve-SeaSharpWorkspaceRoot, Get-SeaSharpProfileNames, Get-SeaSharpProfilePackages, Get-SeaSharpNodeVersions, Test-SeaSharpCommand, Test-SeaSharpNodeVersion, Invoke-SeaSharpCommand, Get-SeaSharpContentFingerprint, Test-SeaSharpComposeServiceRunning, Test-SeaSharpGitRemoteMatches, Test-SeaSharpBicepInstalled, Get-SeaSharpHelixZorkaImage, Update-SeaSharpProcessPath, Get-SeaSharpProductPath, Test-SeaSharpTcpPort, Test-SeaSharpHttpEndpoint
