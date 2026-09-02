[CmdletBinding()]
param(
    [Parameter()]
    [string] $PackageRoot,

    [Parameter()]
    [string] $OutputDirectory,

    [Parameter()]
    [switch] $ValidateOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($PackageRoot)) {
    $PackageRoot = Join-Path $PSScriptRoot 'package'
}
if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
    $OutputDirectory = Join-Path $PSScriptRoot 'dist'
}

function Get-NormalizedRelativePath {
    param(
        [Parameter(Mandatory)]
        [string] $BasePath,

        [Parameter(Mandatory)]
        [string] $Path
    )

    $baseUri = [Uri]::new(([IO.Path]::GetFullPath($BasePath).TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar))
    $pathUri = [Uri]::new([IO.Path]::GetFullPath($Path))
    return [Uri]::UnescapeDataString($baseUri.MakeRelativeUri($pathUri).ToString()).Replace('\', '/')
}

function Get-Sha256Hex {
    param(
        [Parameter(Mandatory)]
        [string] $Path
    )

    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Assert-JsonFile {
    param(
        [Parameter(Mandatory)]
        [string] $Path
    )

    try {
        return Get-Content -LiteralPath $Path -Raw -Encoding UTF8 | ConvertFrom-Json
    }
    catch {
        throw "Invalid JSON in '$Path': $($_.Exception.Message)"
    }
}

function Assert-PowerShellSyntax {
    param(
        [Parameter(Mandatory)]
        [IO.FileInfo[]] $Files
    )

    foreach ($file in $Files) {
        $tokens = $null
        $parseErrors = $null
        [void][System.Management.Automation.Language.Parser]::ParseFile(
            $file.FullName,
            [ref] $tokens,
            [ref] $parseErrors
        )

        if ($parseErrors.Count -gt 0) {
            $details = ($parseErrors | ForEach-Object {
                "line $($_.Extent.StartLineNumber), column $($_.Extent.StartColumnNumber): $($_.Message)"
            }) -join [Environment]::NewLine
            throw "PowerShell parser errors in '$($file.FullName)':$([Environment]::NewLine)$details"
        }
    }
}

function Assert-NoSensitiveContent {
    param(
        [Parameter(Mandatory)]
        [IO.FileInfo[]] $Files,

        [Parameter(Mandatory)]
        [string] $BasePath
    )

    $textExtensions = @(
        '.cmd', '.json', '.md', '.ps1', '.psd1', '.psm1', '.txt', '.yaml', '.yml'
    )

    $patterns = [ordered]@{
        'private key material' = '-----BEGIN (?:RSA |EC |OPENSSH |DSA )?PRIVATE KEY-----'
        'GitHub access token' = '\bgh(?:p|o|u|s|r)_[A-Za-z0-9]{30,}\b'
        'Slack access token' = '\bxox(?:a|b|p|r|s)-[A-Za-z0-9-]{20,}\b'
        'OpenAI-style access token' = '\bsk-[A-Za-z0-9_-]{20,}\b'
        'AWS access key' = '\b(?:AKIA|ASIA)[A-Z0-9]{16}\b'
        'personal Windows user path' = '(?i)\b[A-Z]:\\Users\\[^\\\s"''`]+'
        'personal macOS user path' = '(?i)(?<![A-Za-z0-9_])/Users/[^/\s"''`]+'
        'personal Linux user path' = '(?i)(?<![A-Za-z0-9_])/home/[^/\s"''`]+'
        'private-owner repository locator' = '(?i)\b(?:bsstrong|strong-tech-consulting|solipsys-agent-council|slack-pr-review)\b'
        'personal agent configuration' = '(?i)(?:\.agent-instructions|\.codex(?:\\|/)|\.claude(?:\\|/))'
        'owner-only Slack credential locator' = '(?i)Slack[/\\]UserOAuthToken'
    }

    $findings = [Collections.Generic.List[string]]::new()
    foreach ($file in $Files) {
        if ($textExtensions -notcontains $file.Extension.ToLowerInvariant()) {
            continue
        }

        $content = [IO.File]::ReadAllText($file.FullName)
        foreach ($entry in $patterns.GetEnumerator()) {
            if ([Text.RegularExpressions.Regex]::IsMatch($content, $entry.Value)) {
                $relativePath = Get-NormalizedRelativePath -BasePath $BasePath -Path $file.FullName
                $findings.Add("${relativePath}: $($entry.Key)")
            }
        }
    }

    if ($findings.Count -gt 0) {
        throw "Sensitive or private-owner content found:$([Environment]::NewLine)$($findings -join [Environment]::NewLine)"
    }
}

function New-DeterministicArchive {
    param(
        [Parameter(Mandatory)]
        [IO.FileInfo[]] $Files,

        [Parameter(Mandatory)]
        [string] $BasePath,

        [Parameter(Mandatory)]
        [string] $ArchiveRootName,

        [Parameter(Mandatory)]
        [string] $DestinationPath
    )

    Add-Type -AssemblyName System.IO.Compression
    Add-Type -AssemblyName System.IO.Compression.FileSystem

    $temporaryPath = "$DestinationPath.partial"
    if (Test-Path -LiteralPath $temporaryPath) {
        Remove-Item -LiteralPath $temporaryPath -Force
    }

    $stream = $null
    $archive = $null
    try {
        $stream = [IO.File]::Open($temporaryPath, [IO.FileMode]::CreateNew, [IO.FileAccess]::ReadWrite, [IO.FileShare]::None)
        $archive = [IO.Compression.ZipArchive]::new($stream, [IO.Compression.ZipArchiveMode]::Create, $false)
        $normalizedTimestamp = [DateTimeOffset]::new(1980, 1, 1, 0, 0, 0, [TimeSpan]::Zero)

        foreach ($file in $Files) {
            $relativePath = Get-NormalizedRelativePath -BasePath $BasePath -Path $file.FullName
            $entryName = "$ArchiveRootName/$relativePath"
            $entry = $archive.CreateEntry($entryName, [IO.Compression.CompressionLevel]::Optimal)
            $entry.LastWriteTime = $normalizedTimestamp

            $inputStream = $null
            $entryStream = $null
            try {
                $inputStream = [IO.File]::OpenRead($file.FullName)
                $entryStream = $entry.Open()
                $inputStream.CopyTo($entryStream)
            }
            finally {
                if ($null -ne $entryStream) { $entryStream.Dispose() }
                if ($null -ne $inputStream) { $inputStream.Dispose() }
            }
        }
    }
    finally {
        if ($null -ne $archive) { $archive.Dispose() }
        if ($null -ne $stream) { $stream.Dispose() }
    }

    if (Test-Path -LiteralPath $DestinationPath) {
        Remove-Item -LiteralPath $DestinationPath -Force
    }
    Move-Item -LiteralPath $temporaryPath -Destination $DestinationPath
}

$packagePath = [IO.Path]::GetFullPath($PackageRoot)
$outputPath = [IO.Path]::GetFullPath($OutputDirectory)

if (-not (Test-Path -LiteralPath $packagePath -PathType Container)) {
    throw "Package root does not exist: $packagePath"
}

$packagePrefix = $packagePath.TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar
if ($outputPath.Equals($packagePath, [StringComparison]::OrdinalIgnoreCase) -or
    $outputPath.StartsWith($packagePrefix, [StringComparison]::OrdinalIgnoreCase)) {
    throw 'OutputDirectory must be outside PackageRoot so build output cannot be archived recursively.'
}

$requiredFiles = @(
    'START-HERE.md',
    'NOTICE.md',
    'package-metadata.json',
    'config/workstation.json',
    'scripts/SeaSharp.Onboarding.psm1',
    'scripts/Install-SeaSharpDev.ps1',
    'scripts/Test-SeaSharpDevEnvironment.ps1',
    'scripts/Set-SeaSharpPackageAuthentication.ps1',
    'scripts/Initialize-HelixWorkspace.ps1',
    'scripts/Initialize-ZorkaWorkspace.ps1',
    'scripts/Test-SeaSharpLocalStack.ps1',
    'docs/ACCESS-AND-PREREQUISITES.md',
    'docs/TOOL-CLASSIFICATION.md',
    'docs/INSTALLATION-WALKTHROUGH.md',
    'docs/AUTHENTICATION.md',
    'docs/HELIXOS-SETUP.md',
    'docs/ZORKA-SOURCE-SETUP.md',
    'docs/BROWSER-AND-E2E.md',
    'docs/TAX-SERVICE.md',
    'docs/CLOUDOPS-AZURE.md',
    'docs/SECURITY-BOUNDARIES.md',
    'docs/TROUBLESHOOTING.md',
    'docs/FIRST-DAY-ACCEPTANCE.md'
)

$missingFiles = @($requiredFiles | Where-Object {
    -not (Test-Path -LiteralPath (Join-Path $packagePath $_) -PathType Leaf)
})
if ($missingFiles.Count -gt 0) {
    throw "Required package files are missing:$([Environment]::NewLine)$($missingFiles -join [Environment]::NewLine)"
}

if (Test-Path -LiteralPath (Join-Path $packagePath 'dist')) {
    throw "Generated output directory must not exist inside PackageRoot: $(Join-Path $packagePath 'dist')"
}

$metadataPath = Join-Path $packagePath 'package-metadata.json'
$metadata = Assert-JsonFile -Path $metadataPath
[void](Assert-JsonFile -Path (Join-Path $packagePath 'config/workstation.json'))

if ([string]::IsNullOrWhiteSpace([string] $metadata.packageName)) {
    throw "packageName is required in '$metadataPath'."
}
if ([string] $metadata.version -notmatch '^\d+\.\d+\.\d+$') {
    throw "version in '$metadataPath' must use three-part semantic versioning (for example, 1.0.0)."
}

$packageFiles = @(Get-ChildItem -LiteralPath $packagePath -Recurse -File | Sort-Object {
    (Get-NormalizedRelativePath -BasePath $packagePath -Path $_.FullName).ToLowerInvariant()
}, {
    Get-NormalizedRelativePath -BasePath $packagePath -Path $_.FullName
})

if ($packageFiles.Count -eq 0) {
    throw "Package contains no files: $packagePath"
}

$powerShellFiles = @($packageFiles | Where-Object { $_.Extension -in @('.ps1', '.psd1', '.psm1') })
Assert-PowerShellSyntax -Files $powerShellFiles
Assert-NoSensitiveContent -Files $packageFiles -BasePath $packagePath

Write-Host "Validation passed for $($packageFiles.Count) files, including $($powerShellFiles.Count) PowerShell files."
if ($ValidateOnly) {
    return
}

if (-not (Test-Path -LiteralPath $outputPath -PathType Container)) {
    [void](New-Item -ItemType Directory -Path $outputPath)
}

$archiveRootName = "SeaSharp-Engineer-Workstation-Kit-$($metadata.version)"
$archivePath = Join-Path $outputPath "$archiveRootName.zip"
$checksumPath = Join-Path $outputPath "$archiveRootName.sha256"
$manifestPath = Join-Path $outputPath "$archiveRootName.manifest.json"

New-DeterministicArchive `
    -Files $packageFiles `
    -BasePath $packagePath `
    -ArchiveRootName $archiveRootName `
    -DestinationPath $archivePath

$archiveHash = Get-Sha256Hex -Path $archivePath
$sourceEntries = @($packageFiles | ForEach-Object {
    [ordered]@{
        path = Get-NormalizedRelativePath -BasePath $packagePath -Path $_.FullName
        bytes = $_.Length
        sha256 = Get-Sha256Hex -Path $_.FullName
    }
})

$manifest = [ordered]@{
    schemaVersion = 1
    packageName = [string] $metadata.packageName
    packageVersion = [string] $metadata.version
    archive = [IO.Path]::GetFileName($archivePath)
    archiveSha256 = $archiveHash
    fileCount = $packageFiles.Count
    files = $sourceEntries
}

$utf8WithoutBom = [Text.UTF8Encoding]::new($false)
[IO.File]::WriteAllText($manifestPath, (($manifest | ConvertTo-Json -Depth 6) + [Environment]::NewLine), $utf8WithoutBom)
[IO.File]::WriteAllText($checksumPath, "$archiveHash  $([IO.Path]::GetFileName($archivePath))$([Environment]::NewLine)", $utf8WithoutBom)

Write-Host "Created: $archivePath"
Write-Host "SHA256:  $archiveHash"
Write-Host "Manifest: $manifestPath"
