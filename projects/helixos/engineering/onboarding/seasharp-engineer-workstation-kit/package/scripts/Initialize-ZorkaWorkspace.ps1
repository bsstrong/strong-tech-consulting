#requires -Version 5.1
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$WorkspaceRoot = 'C:\dev',
    [switch]$InstallPlaywright,
    [switch]$SkipStart
)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'SeaSharp.Onboarding.psm1') -Force
$config = Get-SeaSharpConfig
$root = Resolve-SeaSharpWorkspaceRoot $WorkspaceRoot
$repoPath = Get-SeaSharpProductPath -Product Zorka -WorkspaceRoot $root
$repoUrl = [string]$config.products.Zorka.repository
$nodeVersion = [string](@($config.profiles.SourceZorka.nodeVersions)[0])

foreach ($command in @('git', 'fnm', 'dotnet', 'docker')) {
    if (-not (Test-SeaSharpCommand $command)) {
        Write-SeaSharpStatus FAIL "$command is unavailable."
        throw "'$command' is required. Run Install-SeaSharpDev.ps1 -Profile SourceZorka first."
    }
    Write-SeaSharpStatus PASS "$command is available."
}
$dotnetSdks = @(& dotnet --list-sdks 2>$null)
if (@($dotnetSdks | Where-Object { $_ -match '^10\.' }).Count -eq 0) { throw '.NET 10 SDK is required.' }
& docker info *> $null
if ($LASTEXITCODE -ne 0) {
    Write-SeaSharpStatus FAIL 'Docker Desktop is installed but its engine is not running.'
    throw 'Start Docker Desktop, wait for the engine to become ready, and rerun this script.'
}
Write-SeaSharpStatus PASS 'Docker engine is running.'

if (-not (Test-Path -LiteralPath $root -PathType Container)) {
    if ($PSCmdlet.ShouldProcess($root, 'Create workspace directory')) {
        Write-SeaSharpStatus INSTALL "Creating workspace directory $root."
        $null = New-Item -ItemType Directory -Path $root -Force
        Write-SeaSharpStatus PASS 'Workspace directory created.'
    }
}
else { Write-SeaSharpStatus SKIP "Workspace directory already exists at $root." }
if (-not (Test-Path -LiteralPath $repoPath)) {
    if ($PSCmdlet.ShouldProcess($repoPath, "Clone $repoUrl")) {
        Write-SeaSharpStatus INSTALL "Cloning Zorka into $repoPath."
        Invoke-SeaSharpCommand -FilePath 'git' -ArgumentList @('clone', $repoUrl, $repoPath)
        Write-SeaSharpStatus PASS 'Zorka repository cloned.'
    }
    elseif ($WhatIfPreference) { return }
}
elseif (-not (Test-Path -LiteralPath (Join-Path $repoPath '.git'))) {
    throw "$repoPath already exists and is not a Git checkout. Choose another WorkspaceRoot or move the existing directory."
}
else { Write-SeaSharpStatus SKIP "Zorka checkout already exists at $repoPath." }

$origin = (& git -C $repoPath remote get-url origin 2>$null)
if ($LASTEXITCODE -ne 0 -or -not (Test-SeaSharpGitRemoteMatches -Actual ([string]$origin) -Expected $repoUrl)) {
    throw "$repoPath is not a checkout of $repoUrl."
}
Write-SeaSharpStatus PASS 'Zorka repository origin is valid.'

$packageJsonPath = Join-Path $repoPath 'package.json'
if (-not (Test-Path -LiteralPath $packageJsonPath -PathType Leaf)) { throw 'Zorka package.json was not found.' }
$packageJson = Get-Content -LiteralPath $packageJsonPath -Raw | ConvertFrom-Json
$packageManager = [string]$packageJson.packageManager
if ($packageManager -notmatch '^pnpm@(.+)$') { throw "Zorka package.json must declare an exact pnpm packageManager version; found '$packageManager'." }
$pnpmVersion = $Matches[1]

$nodeVersionFile = Join-Path $repoPath '.node-version'
if (Test-Path -LiteralPath $nodeVersionFile -PathType Leaf) {
    $declaredNode = (Get-Content -LiteralPath $nodeVersionFile -Raw).Trim()
    if ($declaredNode) { $nodeVersion = $declaredNode }
}
$installedNodes = @(& fnm list 2>$null | ForEach-Object { [string]$_ })
if (-not (Test-SeaSharpNodeVersion -InstalledVersionLines $installedNodes -RequestedVersion $nodeVersion)) {
    throw "Node.js $nodeVersion is not installed by fnm. Run Install-SeaSharpDev.ps1 -Profile SourceZorka."
}
Write-SeaSharpStatus PASS "Node.js $nodeVersion and repository-declared pnpm $pnpmVersion requirements are resolved."

$activePnpmVersion = (& fnm exec --using $nodeVersion corepack pnpm --version 2>$null | Select-Object -First 1)
if ($LASTEXITCODE -eq 0 -and ([string]$activePnpmVersion).Trim() -eq $pnpmVersion) {
    Write-SeaSharpStatus SKIP "Corepack already resolves pnpm $pnpmVersion under Node.js $nodeVersion."
}
elseif ($PSCmdlet.ShouldProcess("pnpm $pnpmVersion", "Activate repository-declared pnpm with Corepack under Node.js $nodeVersion")) {
    Write-SeaSharpStatus INSTALL "Activating pnpm $pnpmVersion with Corepack."
    Invoke-SeaSharpCommand -FilePath 'fnm' -ArgumentList @('exec', '--using', $nodeVersion, 'corepack', 'enable')
    Invoke-SeaSharpCommand -FilePath 'fnm' -ArgumentList @('exec', '--using', $nodeVersion, 'corepack', 'prepare', "pnpm@$pnpmVersion", '--activate')
    Write-SeaSharpStatus PASS "pnpm $pnpmVersion activated."
}
$lockPath = Join-Path $repoPath 'pnpm-lock.yaml'
$dependencyStamp = Join-Path $repoPath 'node_modules\.seasharp-pnpm-lock.sha256'
$lockHash = (Get-FileHash -LiteralPath $lockPath -Algorithm SHA256).Hash
$dependenciesCurrent = (Test-Path -LiteralPath $dependencyStamp -PathType Leaf) -and ((Get-Content -LiteralPath $dependencyStamp -Raw).Trim() -eq $lockHash)
if ($dependenciesCurrent) {
    Write-SeaSharpStatus SKIP 'pnpm dependencies already match pnpm-lock.yaml.'
}
elseif ($PSCmdlet.ShouldProcess($repoPath, 'Install exact pnpm dependencies')) {
    Write-SeaSharpStatus INSTALL 'Installing exact pnpm dependencies.'
    Invoke-SeaSharpCommand -FilePath 'fnm' -ArgumentList @('exec', '--using', $nodeVersion, 'pnpm', 'install', '--frozen-lockfile') -WorkingDirectory $repoPath
    [System.IO.File]::WriteAllText($dependencyStamp, $lockHash, (New-Object System.Text.UTF8Encoding($false)))
    Write-SeaSharpStatus PASS 'pnpm dependencies installed.'
}
$bootstrapFingerprint = Get-SeaSharpContentFingerprint -Path @(
    (Join-Path $repoPath 'package.json'),
    (Join-Path $repoPath 'pnpm-lock.yaml'),
    (Join-Path $repoPath 'docker-compose.yml'),
    (Join-Path $repoPath '.env.example'),
    (Join-Path $repoPath 'tools\local-setup.mjs'),
    (Join-Path $repoPath 'src\db\prisma')
)
$bootstrapStamp = Join-Path $repoPath 'node_modules\.seasharp-zorka-setup.sha256'
$bootstrapCurrent = (Test-Path -LiteralPath $bootstrapStamp -PathType Leaf) -and
    ((Get-Content -LiteralPath $bootstrapStamp -Raw).Trim() -eq $bootstrapFingerprint) -and
    (Test-Path -LiteralPath (Join-Path $repoPath '.env') -PathType Leaf) -and
    (Test-SeaSharpComposeServiceRunning -WorkingDirectory $repoPath -Service 'postgres')
if ($bootstrapCurrent) {
    Write-SeaSharpStatus SKIP 'Zorka environment, database preparation, seed, and package build already match the current setup inputs.'
}
elseif ($PSCmdlet.ShouldProcess($repoPath, 'Run the repository local setup workflow')) {
    Write-SeaSharpStatus INSTALL 'Running the Zorka local setup workflow.'
    Invoke-SeaSharpCommand -FilePath 'fnm' -ArgumentList @('exec', '--using', $nodeVersion, 'pnpm', 'local:setup') -WorkingDirectory $repoPath
    [System.IO.File]::WriteAllText($bootstrapStamp, $bootstrapFingerprint, (New-Object System.Text.UTF8Encoding($false)))
    Write-SeaSharpStatus PASS 'Zorka local setup completed.'
}

if ($InstallPlaywright) {
    $playwrightStamp = Join-Path $repoPath 'node_modules\.seasharp-playwright-pnpm-lock.sha256'
    $playwrightCurrent = (Test-Path -LiteralPath $playwrightStamp -PathType Leaf) -and
        ((Get-Content -LiteralPath $playwrightStamp -Raw).Trim() -eq $lockHash)
    if ($playwrightCurrent) { Write-SeaSharpStatus SKIP 'Playwright Chromium already matches pnpm-lock.yaml.' }
    elseif ($PSCmdlet.ShouldProcess($repoPath, 'Install Playwright Chromium')) {
        Write-SeaSharpStatus INSTALL 'Installing Playwright Chromium for Zorka.'
        Invoke-SeaSharpCommand -FilePath 'fnm' -ArgumentList @('exec', '--using', $nodeVersion, 'pnpm', 'exec', 'playwright', 'install', 'chromium') -WorkingDirectory $repoPath
        [System.IO.File]::WriteAllText($playwrightStamp, $lockHash, (New-Object System.Text.UTF8Encoding($false)))
        Write-SeaSharpStatus PASS 'Playwright Chromium installed for Zorka.'
    }
}

if ($SkipStart) {
    Write-SeaSharpStatus PASS "Zorka workspace initialized at $repoPath with repository-declared pnpm $pnpmVersion."
    Write-SeaSharpStatus INFO "Start it with: fnm exec --using $nodeVersion pnpm dev"
    return
}

if ($PSCmdlet.ShouldProcess($repoPath, 'Start the Zorka local development stack in this terminal')) {
    Write-SeaSharpStatus INFO 'Starting Zorka. Press Ctrl+C to stop the development processes.'
    Invoke-SeaSharpCommand -FilePath 'fnm' -ArgumentList @('exec', '--using', $nodeVersion, 'pnpm', 'dev') -WorkingDirectory $repoPath
}
