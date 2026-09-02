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
$repoPath = Get-SeaSharpProductPath -Product Helix -WorkspaceRoot $root
$repoUrl = [string]$config.products.Helix.repository
$nodeVersion = [string]$config.products.Helix.nodeVersion

foreach ($command in @('git', 'fnm', 'docker')) {
    if (-not (Test-SeaSharpCommand $command)) {
        Write-SeaSharpStatus FAIL "$command is unavailable."
        throw "'$command' is required. Run Install-SeaSharpDev.ps1 first."
    }
    Write-SeaSharpStatus PASS "$command is available."
}
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
        Write-SeaSharpStatus INSTALL "Cloning Helix into $repoPath."
        Invoke-SeaSharpCommand -FilePath 'git' -ArgumentList @('clone', $repoUrl, $repoPath)
        Write-SeaSharpStatus PASS 'Helix repository cloned.'
    }
    elseif ($WhatIfPreference) { return }
}
elseif (-not (Test-Path -LiteralPath (Join-Path $repoPath '.git'))) {
    throw "$repoPath already exists and is not a Git checkout. Choose another WorkspaceRoot or move the existing directory."
}
else { Write-SeaSharpStatus SKIP "Helix checkout already exists at $repoPath." }

$origin = (& git -C $repoPath remote get-url origin 2>$null)
if ($LASTEXITCODE -ne 0 -or -not (Test-SeaSharpGitRemoteMatches -Actual ([string]$origin) -Expected $repoUrl)) {
    throw "$repoPath is not a checkout of $repoUrl."
}
$nodeVersionFile = Join-Path $repoPath '.node-version'
if (Test-Path -LiteralPath $nodeVersionFile -PathType Leaf) {
    $declaredNode = (Get-Content -LiteralPath $nodeVersionFile -Raw).Trim()
    if ($declaredNode) { $nodeVersion = $declaredNode }
}
if (Test-Path -LiteralPath (Join-Path $repoPath '.env') -PathType Leaf) {
    throw 'Helix has a repository-root .env file. Normal local demo mode expects no .env; review and remove or relocate it manually before bootstrap.'
}
Write-SeaSharpStatus PASS 'Helix repository origin and root environment-file state are valid.'

$zorkaImage = Get-SeaSharpHelixZorkaImage -RepositoryPath $repoPath
Write-SeaSharpStatus PASS "Repository-selected Rule Engine image: $zorkaImage"
& docker image inspect $zorkaImage *> $null
if ($LASTEXITCODE -eq 0) {
    Write-SeaSharpStatus SKIP 'Repository-selected Rule Engine image is already installed.'
}
elseif ($PSCmdlet.ShouldProcess($zorkaImage, 'Pull repository-selected Rule Engine image')) {
    Write-SeaSharpStatus INSTALL "Pulling repository-selected Rule Engine image $zorkaImage."
    Invoke-SeaSharpCommand -FilePath 'docker' -ArgumentList @('pull', $zorkaImage)
    Write-SeaSharpStatus PASS 'Repository-selected Rule Engine image installed.'
}

$installedNodes = @(& fnm list 2>$null | ForEach-Object { [string]$_ })
if (-not (Test-SeaSharpNodeVersion -InstalledVersionLines $installedNodes -RequestedVersion $nodeVersion)) {
    throw "Node.js $nodeVersion is not installed by fnm. Run Install-SeaSharpDev.ps1."
}
Write-SeaSharpStatus PASS "Node.js $nodeVersion is installed."

$lockPath = Join-Path $repoPath 'package-lock.json'
$dependencyStamp = Join-Path $repoPath 'node_modules\.seasharp-package-lock.sha256'
$lockHash = (Get-FileHash -LiteralPath $lockPath -Algorithm SHA256).Hash
$dependenciesCurrent = (Test-Path -LiteralPath $dependencyStamp -PathType Leaf) -and ((Get-Content -LiteralPath $dependencyStamp -Raw).Trim() -eq $lockHash)
if ($dependenciesCurrent) {
    Write-SeaSharpStatus SKIP 'npm dependencies already match package-lock.json.'
}
elseif ($PSCmdlet.ShouldProcess($repoPath, 'Install exact npm dependencies')) {
    Write-SeaSharpStatus INSTALL 'Installing exact npm dependencies.'
    Invoke-SeaSharpCommand -FilePath 'fnm' -ArgumentList @('exec', '--using', $nodeVersion, 'npm', 'ci') -WorkingDirectory $repoPath
    [System.IO.File]::WriteAllText($dependencyStamp, $lockHash, (New-Object System.Text.UTF8Encoding($false)))
    Write-SeaSharpStatus PASS 'npm dependencies installed.'
}
$bootstrapFingerprint = Get-SeaSharpContentFingerprint -Path @(
    (Join-Path $repoPath 'package.json'),
    (Join-Path $repoPath 'package-lock.json'),
    (Join-Path $repoPath 'docker-compose.yml'),
    (Join-Path $repoPath 'src\packages\db\package.json'),
    (Join-Path $repoPath 'src\packages\db\prisma')
)
$bootstrapStamp = Join-Path $repoPath 'node_modules\.seasharp-helix-setup.sha256'
$bootstrapCurrent = (Test-Path -LiteralPath $bootstrapStamp -PathType Leaf) -and
    ((Get-Content -LiteralPath $bootstrapStamp -Raw).Trim() -eq $bootstrapFingerprint) -and
    (Test-SeaSharpComposeServiceRunning -WorkingDirectory $repoPath -Service 'postgres')
if ($bootstrapCurrent) {
    Write-SeaSharpStatus SKIP 'Helix infrastructure, package build, migrations, and seed already match the current setup inputs.'
}
elseif ($PSCmdlet.ShouldProcess($repoPath, 'Start local infrastructure, build packages, migrate, and seed the local database')) {
    Write-SeaSharpStatus INSTALL 'Bootstrapping Helix local infrastructure and database.'
    Invoke-SeaSharpCommand -FilePath 'fnm' -ArgumentList @('exec', '--using', $nodeVersion, 'npm', 'run', 'setup') -WorkingDirectory $repoPath
    [System.IO.File]::WriteAllText($bootstrapStamp, $bootstrapFingerprint, (New-Object System.Text.UTF8Encoding($false)))
    Write-SeaSharpStatus PASS 'Helix local infrastructure and database bootstrap completed.'
}
if ($InstallPlaywright) {
    $playwrightStamp = Join-Path $repoPath 'node_modules\.seasharp-playwright-package-lock.sha256'
    $playwrightCurrent = (Test-Path -LiteralPath $playwrightStamp -PathType Leaf) -and
        ((Get-Content -LiteralPath $playwrightStamp -Raw).Trim() -eq $lockHash)
    if ($playwrightCurrent) { Write-SeaSharpStatus SKIP 'Playwright Chromium already matches package-lock.json.' }
    elseif ($PSCmdlet.ShouldProcess($repoPath, 'Install Playwright Chromium')) {
        Write-SeaSharpStatus INSTALL 'Installing Playwright Chromium.'
        Invoke-SeaSharpCommand -FilePath 'fnm' -ArgumentList @('exec', '--using', $nodeVersion, 'npx', 'playwright', 'install', 'chromium') -WorkingDirectory $repoPath
        [System.IO.File]::WriteAllText($playwrightStamp, $lockHash, (New-Object System.Text.UTF8Encoding($false)))
        Write-SeaSharpStatus PASS 'Playwright Chromium installed.'
    }
}

if ($SkipStart) {
    Write-SeaSharpStatus PASS "Helix workspace initialized at $repoPath."
    Write-SeaSharpStatus INFO "Start it with: fnm exec --using $nodeVersion npm run dev:windows"
    return
}

if ($PSCmdlet.ShouldProcess($repoPath, 'Start the Helix local development stack in this terminal')) {
    Write-SeaSharpStatus INFO 'Starting Helix. Press Ctrl+C to stop the development processes.'
    Invoke-SeaSharpCommand -FilePath 'fnm' -ArgumentList @('exec', '--using', $nodeVersion, 'npm', 'run', 'dev:windows') -WorkingDirectory $repoPath
}
