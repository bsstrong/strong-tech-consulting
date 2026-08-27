[CmdletBinding(DefaultParameterSetName = "CheckStaged")]
param(
  [Parameter(Mandatory, ParameterSetName = "CheckStaged")]
  [switch] $CheckStaged,

  [Parameter(Mandatory, ParameterSetName = "SanitizePath")]
  [string] $SanitizePath,

  [Parameter(Mandatory, ParameterSetName = "Download")]
  [uri] $Uri,

  [Parameter(Mandatory, ParameterSetName = "Download")]
  [string] $OutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$secretPatterns = @(
  [pscustomobject]@{ Name = "Google API key"; Pattern = [regex]::new("AIza[0-9A-Za-z_-]{35}"); Replacement = "[REDACTED_GOOGLE_API_KEY]" },
  [pscustomobject]@{ Name = "GitHub token"; Pattern = [regex]::new("(?:gh[pousr]_[A-Za-z0-9]{36,255}|github_pat_[A-Za-z0-9_]{20,255})"); Replacement = "[REDACTED_GITHUB_TOKEN]" },
  [pscustomobject]@{ Name = "AWS access key"; Pattern = [regex]::new("(?:AKIA|ASIA)[A-Z0-9]{16}"); Replacement = "[REDACTED_AWS_ACCESS_KEY]" },
  [pscustomobject]@{ Name = "Slack token"; Pattern = [regex]::new("xox(?:a|b|p|r|s)-[A-Za-z0-9-]{10,}"); Replacement = "[REDACTED_SLACK_TOKEN]" },
  [pscustomobject]@{ Name = "OpenAI API key"; Pattern = [regex]::new("sk-(?:proj-|svcacct-)?[A-Za-z0-9_-]{20,}"); Replacement = "[REDACTED_OPENAI_API_KEY]" },
  [pscustomobject]@{ Name = "private key"; Pattern = [regex]::new("-----BEGIN (?:RSA |EC |OPENSSH |DSA )?PRIVATE KEY-----"); Replacement = "[REDACTED_PRIVATE_KEY]" },
  [pscustomobject]@{ Name = "storage account key"; Pattern = [regex]::new("AccountKey=[A-Za-z0-9+/=]{20,}"); Replacement = "AccountKey=[REDACTED_STORAGE_ACCOUNT_KEY]" }
)

$textExtensions = [Collections.Generic.HashSet[string]]::new(
  [string[]]@(".csv", ".htm", ".html", ".json", ".jsonl", ".md", ".ps1", ".tsv", ".txt", ".xml"),
  [StringComparer]::OrdinalIgnoreCase
)

function ConvertTo-SanitizedFile {
  param(
    [Parameter(Mandatory)] [string] $Source,
    [Parameter(Mandatory)] [string] $Destination
  )

  $resolvedSource = [IO.Path]::GetFullPath($Source)
  $resolvedDestination = [IO.Path]::GetFullPath($Destination)
  $isInPlaceSanitization = $resolvedSource -eq $resolvedDestination
  $destinationDirectory = [IO.Path]::GetDirectoryName($resolvedDestination)
  if (-not [string]::IsNullOrWhiteSpace($destinationDirectory)) {
    [IO.Directory]::CreateDirectory($destinationDirectory) | Out-Null
  }

  $temporaryDestination = if ($isInPlaceSanitization) {
    "$resolvedDestination.sanitizing-$([guid]::NewGuid().ToString('N'))"
  } else {
    $resolvedDestination
  }

  $redactionCount = 0
  try {
    $reader = [IO.StreamReader]::new($resolvedSource, $true)
    $writer = [IO.StreamWriter]::new($temporaryDestination, $false, [Text.UTF8Encoding]::new($false))
    try {
      while (($line = $reader.ReadLine()) -ne $null) {
        foreach ($secretPattern in $secretPatterns) {
          $redactionCount += $secretPattern.Pattern.Matches($line).Count
          $line = $secretPattern.Pattern.Replace($line, $secretPattern.Replacement)
        }
        $writer.WriteLine($line)
      }
    } finally {
      $writer.Dispose()
      $reader.Dispose()
    }

    if ($isInPlaceSanitization -and $redactionCount -eq 0) {
      [IO.File]::Delete($temporaryDestination)
    } elseif ($temporaryDestination -ne $resolvedDestination) {
      [IO.File]::Move($temporaryDestination, $resolvedDestination, $true)
    }
  } finally {
    if ($temporaryDestination -ne $resolvedDestination -and [IO.File]::Exists($temporaryDestination)) {
      [IO.File]::Delete($temporaryDestination)
    }
  }

  return $redactionCount
}

function Test-StagedContent {
  $repositoryRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot ".."))
  $gitRoot = (& git -C $repositoryRoot rev-parse --show-toplevel).Trim()
  if ($LASTEXITCODE -ne 0 -or [IO.Path]::GetFullPath($gitRoot) -ne $repositoryRoot) {
    throw "Unable to resolve the Git repository root."
  }

  $violations = [Collections.Generic.List[object]]::new()
  $stagedFiles = @(& git -C $repositoryRoot diff --cached --name-only --diff-filter=ACMR --)
  foreach ($relativePath in $stagedFiles) {
    if ([string]::IsNullOrWhiteSpace($relativePath)) {
      continue
    }

    $stagedSize = [int64](& git -C $repositoryRoot cat-file -s ":$relativePath")
    if ($LASTEXITCODE -ne 0) {
      throw "Unable to inspect staged file: $relativePath"
    }
    if ($stagedSize -gt 90MB) {
      $violations.Add([pscustomobject]@{ Name = "file exceeds 90 MiB"; Path = $relativePath })
      continue
    }

    $addedText = (@(& git -C $repositoryRoot diff --cached --no-ext-diff --unified=0 -- $relativePath) |
      Where-Object { $_.StartsWith("+") -and -not $_.StartsWith("+++") }) -join "`n"

    foreach ($secretPattern in $secretPatterns) {
      if ($secretPattern.Pattern.IsMatch($addedText)) {
        $violations.Add([pscustomobject]@{ Name = $secretPattern.Name; Path = $relativePath })
      }
    }
  }

  if ($violations.Count -gt 0) {
    foreach ($violation in $violations) {
      Write-Error "Commit blocked: $($violation.Name) detected in staged file '$($violation.Path)'." -ErrorAction Continue
    }
    exit 1
  }

  Write-Host "Staged secret scan passed."
}

switch ($PSCmdlet.ParameterSetName) {
  "CheckStaged" {
    Test-StagedContent
  }
  "SanitizePath" {
    $resolvedPath = (Resolve-Path -LiteralPath $SanitizePath).Path
    [array] $files = if ([IO.Directory]::Exists($resolvedPath)) {
      @(Get-ChildItem -LiteralPath $resolvedPath -Recurse -File | Where-Object { $textExtensions.Contains($_.Extension) })
    } else {
      @([IO.FileInfo]::new($resolvedPath))
    }

    $redactionCount = 0
    foreach ($file in $files) {
      if (-not $textExtensions.Contains($file.Extension)) {
        throw "Unsupported text-artifact extension: $($file.Extension)"
      }
      $redactionCount += ConvertTo-SanitizedFile -Source $file.FullName -Destination $file.FullName
    }
    Write-Host "Sanitized $($files.Count) artifact(s); redacted $redactionCount secret-shaped value(s)."
  }
  "Download" {
    if (-not $textExtensions.Contains([IO.Path]::GetExtension($OutputPath))) {
      throw "OutputPath must use a supported text-artifact extension."
    }

    $temporaryDownload = [IO.Path]::GetTempFileName()
    try {
      Invoke-WebRequest -Uri $Uri -OutFile $temporaryDownload
      $redactionCount = ConvertTo-SanitizedFile -Source $temporaryDownload -Destination $OutputPath
      Write-Host "Saved sanitized research artifact; redacted $redactionCount secret-shaped value(s)."
    } finally {
      if ([IO.File]::Exists($temporaryDownload)) {
        [IO.File]::Delete($temporaryDownload)
      }
    }
  }
}
