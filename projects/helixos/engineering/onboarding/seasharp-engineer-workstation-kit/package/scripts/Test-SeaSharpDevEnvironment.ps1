#requires -Version 5.1
[CmdletBinding()]
param(
    [ValidateSet('AppDev', 'SourceZorka', 'WebE2E', 'CloudOps')]
    [string[]]$Profile = @('AppDev'),
    [string]$WorkspaceRoot = 'C:\dev',
    [switch]$Json
)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'SeaSharp.Onboarding.psm1') -Force

$results = New-Object 'System.Collections.Generic.List[object]'
function Add-Result([string]$Area, [string]$Name, [string]$Status, [string]$Detail) {
    $results.Add([pscustomobject]@{ Area = $Area; Name = $Name; Status = $Status; Detail = $Detail })
}

function Get-VersionText([string]$Command, [string[]]$Arguments) {
    try {
        $text = (& $Command @Arguments 2>$null | Select-Object -First 1)
        if (-not $text) { return $null }
        ([string]$text).Trim()
    }
    catch { $null }
}

$resolvedRoot = Resolve-SeaSharpWorkspaceRoot $WorkspaceRoot
$resolvedProfiles = Get-SeaSharpProfileNames -Profile $Profile
$config = Get-SeaSharpConfig

if ([Environment]::OSVersion.Platform -eq [PlatformID]::Win32NT) {
    Add-Result 'System' 'Windows' 'PASS' ([Environment]::OSVersion.VersionString)
}
else {
    Add-Result 'System' 'Windows' 'FAIL' 'This kit supports Windows workstations.'
}

if (Test-Path -LiteralPath $resolvedRoot -PathType Container) {
    Add-Result 'Workspace' 'Workspace root' 'PASS' $resolvedRoot
    try {
        $driveName = (Get-Item -LiteralPath $resolvedRoot).PSDrive.Name
        $drive = Get-PSDrive -Name $driveName
        $freeGb = [math]::Round($drive.Free / 1GB, 1)
        $diskStatus = if ($freeGb -ge 20) { 'PASS' } else { 'WARN' }
        Add-Result 'System' 'Free disk space' $diskStatus "$freeGb GB available"
    }
    catch { Add-Result 'System' 'Free disk space' 'WARN' 'Could not determine available disk space.' }
}
else {
    Add-Result 'Workspace' 'Workspace root' 'WARN' "$resolvedRoot does not exist yet."
}

foreach ($package in (Get-SeaSharpProfilePackages -Profile $Profile)) {
    $command = [string]$package.command
    $toolArea = if ($package.profileClassification -eq 'required' -and $package.required) {
        'Required tool'
    }
    elseif ($package.required) { 'Selected role tool' }
    else { 'Optional tool' }
    if (Test-SeaSharpCommand $command) {
        $versionArguments = switch ($command) {
            'git' { @('--version') }
            'pwsh' { @('-NoProfile', '-Command', '$PSVersionTable.PSVersion.ToString()') }
            'docker' { @('--version') }
            'fnm' { @('--version') }
            'dotnet' { @('--version') }
            'az' { @('version', '--output', 'tsv', '--query', '"azure-cli"') }
            'gh' { @('--version') }
            'python' { @('--version') }
            'jq' { @('--version') }
            'openssl' { @('version') }
            default { @('--version') }
        }
        $version = Get-VersionText $command $versionArguments
        Add-Result $toolArea $command 'PASS' $(if ($version) { $version } else { 'Installed' })
    }
    else {
        $status = if ([bool]$package.required) { 'FAIL' } else { 'WARN' }
        Add-Result $toolArea $command $status "Install package $($package.id)."
    }
}

if (Test-SeaSharpCommand 'docker') {
    & docker info *> $null
    if ($LASTEXITCODE -eq 0) { Add-Result 'Tool' 'Docker engine' 'PASS' 'Running' }
    else { Add-Result 'Tool' 'Docker engine' 'WARN' 'Docker is installed but the engine is not running.' }

    & docker compose version *> $null
    if ($LASTEXITCODE -eq 0) { Add-Result 'Tool' 'Docker Compose v2' 'PASS' 'Available' }
    else { Add-Result 'Tool' 'Docker Compose v2' 'FAIL' 'docker compose is unavailable.' }
}

if (Test-SeaSharpCommand 'fnm') {
    $installedNodes = @(& fnm list 2>$null | ForEach-Object { [string]$_ })
    foreach ($version in (Get-SeaSharpNodeVersions -Profile $Profile)) {
        $found = Test-SeaSharpNodeVersion -InstalledVersionLines $installedNodes -RequestedVersion $version
        Add-Result 'Runtime' "Node.js $version" $(if ($found) { 'PASS' } else { 'FAIL' }) $(if ($found) { 'Installed by fnm' } else { 'Run Install-SeaSharpDev.ps1.' })
    }
}

if ($resolvedProfiles -contains 'SourceZorka') {
    $dotnetSdks = if (Test-SeaSharpCommand 'dotnet') { @(& dotnet --list-sdks 2>$null) } else { @() }
    $hasDotNet10 = @($dotnetSdks | Where-Object { $_ -match '^10\.' }).Count -gt 0
    Add-Result 'Runtime' '.NET 10 SDK' $(if ($hasDotNet10) { 'PASS' } else { 'FAIL' }) $(if ($hasDotNet10) { ($dotnetSdks -join ', ') } else { 'A .NET 10 SDK was not found.' })
}

if ($resolvedProfiles -contains 'CloudOps') {
    if (Test-SeaSharpCommand 'bash') {
        $bashVersion = Get-VersionText 'bash' @('--version')
        Add-Result 'Tool' 'Git Bash' 'PASS' $(if ($bashVersion) { $bashVersion } else { 'Available' })
    }
    else { Add-Result 'Tool' 'Git Bash' 'FAIL' 'Git Bash was not found on PATH.' }

    if (Test-SeaSharpCommand 'curl.exe') {
        $curlVersion = Get-VersionText 'curl.exe' @('--version')
        Add-Result 'Tool' 'curl' 'PASS' $(if ($curlVersion) { $curlVersion } else { 'Available' })
    }
    else { Add-Result 'Tool' 'curl' 'WARN' 'curl.exe was not found on PATH.' }

    if (Test-SeaSharpCommand 'az') {
        $hasBicep = Test-SeaSharpBicepInstalled
        Add-Result 'Tool' 'Azure Bicep CLI' $(if ($hasBicep) { 'PASS' } else { 'FAIL' }) $(if ($hasBicep) { 'Installed' } else { 'Run az bicep install.' })
    }
    if (Test-SeaSharpCommand 'docker') {
        & docker buildx version *> $null
        Add-Result 'Tool' 'Docker buildx' $(if ($LASTEXITCODE -eq 0) { 'PASS' } else { 'FAIL' }) $(if ($LASTEXITCODE -eq 0) { 'Available' } else { 'Docker buildx is unavailable.' })
    }
    if (-not (Test-SeaSharpCommand 'uuidgen')) {
        Add-Result 'Tool' 'uuidgen' 'WARN' 'Some task-specific Bash setup scripts require uuidgen; install it only when the assigned runbook requires it.'
    }
}

$gitName = if (Test-SeaSharpCommand 'git') { (& git config --global user.name 2>$null) } else { $null }
$gitEmail = if (Test-SeaSharpCommand 'git') { (& git config --global user.email 2>$null) } else { $null }
Add-Result 'Access' 'Git identity' $(if ($gitName -and $gitEmail) { 'PASS' } else { 'WARN' }) $(if ($gitName -and $gitEmail) { 'Global name and email are configured.' } else { 'Configure git user.name and git user.email.' })

$npmrc = Join-Path $env:USERPROFILE '.npmrc'
$npmConfigured = $false
if (Test-Path -LiteralPath $npmrc -PathType Leaf) {
    $npmContent = Get-Content -LiteralPath $npmrc -Raw
    $npmConfigured = $npmContent -match '(?m)^@zorkacom:registry=https://npm\.pkg\.github\.com/?\s*$' -and
        $npmContent -match '(?m)^//npm\.pkg\.github\.com/:_authToken=\S+' -and
        $npmContent -match '(?m)^always-auth=true\s*$'
}
Add-Result 'Access' 'GitHub Packages npm authentication' $(if ($npmConfigured) { 'PASS' } else { 'WARN' }) $(if ($npmConfigured) { 'User npm configuration contains the required registry and credential entry.' } else { 'Run Set-SeaSharpPackageAuthentication.ps1 -ConfigureNpm.' })

$dockerConfig = Join-Path $env:USERPROFILE '.docker\config.json'
$ghcrConfigured = $false
if (Test-Path -LiteralPath $dockerConfig -PathType Leaf) {
    try {
        $dockerJson = Get-Content -LiteralPath $dockerConfig -Raw | ConvertFrom-Json
        $ghcrConfigured = $null -ne $dockerJson.auths.'ghcr.io'
    }
    catch { }
}
Add-Result 'Access' 'GHCR authentication' $(if ($ghcrConfigured) { 'PASS' } else { 'WARN' }) $(if ($ghcrConfigured) { 'Docker has a ghcr.io credential entry.' } else { 'Run Set-SeaSharpPackageAuthentication.ps1 -ConfigureGhcr.' })

foreach ($product in @('Helix', 'Zorka')) {
    $path = Get-SeaSharpProductPath -Product $product -WorkspaceRoot $resolvedRoot
    if (Test-Path -LiteralPath (Join-Path $path '.git')) {
        Add-Result 'Workspace' "$product repository" 'PASS' $path
    }
    else {
        Add-Result 'Workspace' "$product repository" 'SKIP' "Not checked out at $path."
    }
}

$helixPath = Get-SeaSharpProductPath -Product Helix -WorkspaceRoot $resolvedRoot
if (Test-Path -LiteralPath (Join-Path $helixPath '.env') -PathType Leaf) {
    Add-Result 'Workspace' 'Helix root .env' 'WARN' 'A root .env exists; normal local demo mode expects no root .env.'
}

if ($resolvedProfiles -contains 'WebE2E') {
    $helixLock = Join-Path $helixPath 'package-lock.json'
    $helixStamp = Join-Path $helixPath 'node_modules\.seasharp-playwright-package-lock.sha256'
    $helixCurrent = (Test-Path -LiteralPath $helixLock -PathType Leaf) -and
        (Test-Path -LiteralPath $helixStamp -PathType Leaf) -and
        ((Get-Content -LiteralPath $helixStamp -Raw).Trim() -eq (Get-FileHash -LiteralPath $helixLock -Algorithm SHA256).Hash)
    Add-Result 'Browser' 'Helix Playwright Chromium' $(if ($helixCurrent) { 'PASS' } else { 'WARN' }) $(if ($helixCurrent) { 'Verified for package-lock.json.' } else { 'Run Initialize-HelixWorkspace.ps1 -InstallPlaywright.' })

    if ($resolvedProfiles -contains 'SourceZorka') {
        $zorkaPath = Get-SeaSharpProductPath -Product Zorka -WorkspaceRoot $resolvedRoot
        $zorkaLock = Join-Path $zorkaPath 'pnpm-lock.yaml'
        $zorkaStamp = Join-Path $zorkaPath 'node_modules\.seasharp-playwright-pnpm-lock.sha256'
        $zorkaCurrent = (Test-Path -LiteralPath $zorkaLock -PathType Leaf) -and
            (Test-Path -LiteralPath $zorkaStamp -PathType Leaf) -and
            ((Get-Content -LiteralPath $zorkaStamp -Raw).Trim() -eq (Get-FileHash -LiteralPath $zorkaLock -Algorithm SHA256).Hash)
        Add-Result 'Browser' 'Zorka Playwright Chromium' $(if ($zorkaCurrent) { 'PASS' } else { 'WARN' }) $(if ($zorkaCurrent) { 'Verified for pnpm-lock.yaml.' } else { 'Run Initialize-ZorkaWorkspace.ps1 -InstallPlaywright.' })
    }
}

$failures = @($results | Where-Object { $_.Status -eq 'FAIL' }).Count
$warnings = @($results | Where-Object { $_.Status -eq 'WARN' }).Count
if ($Json) {
    $results | ConvertTo-Json -Depth 4
}
else {
    $results | Format-Table -AutoSize -Wrap
    if ($failures -eq 0) { Write-SeaSharpStatus PASS "Doctor completed with $warnings warning(s)." }
    else { Write-SeaSharpStatus FAIL "Doctor found $failures failure(s) and $warnings warning(s)." }
}
if ($failures -gt 0) { exit 1 }
