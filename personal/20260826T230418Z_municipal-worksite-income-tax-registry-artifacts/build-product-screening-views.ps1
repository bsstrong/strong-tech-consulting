$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$registryPath = Join-Path $root 'worksite-municipal-income-tax-registry.jsonl'
$coveragePath = Join-Path $root 'coverage-matrix.jsonl'
$directJsonlPath = Join-Path $root 'direct-primary-screening-candidates.jsonl'
$directCsvPath = Join-Path $root 'direct-primary-screening-candidates.csv'
$queueJsonlPath = Join-Path $root 'worksite-tax-evidence-queue.jsonl'
$queueCsvPath = Join-Path $root 'worksite-tax-evidence-queue.csv'
$coveragePolicyJsonlPath = Join-Path $root 'worksite-tax-coverage-policy.jsonl'
$coveragePolicyCsvPath = Join-Path $root 'worksite-tax-coverage-policy.csv'
$releasePath = Join-Path $root 'worksite-tax-screening-data-release.json'

function Write-JsonLines([object[]]$Rows, [string]$Path) {
    $lines = @($Rows | ForEach-Object { $_ | ConvertTo-Json -Depth 20 -Compress })
    [IO.File]::WriteAllLines($Path, $lines, [Text.UTF8Encoding]::new($false))
}

function Convert-ToCell($Value) {
    if ($null -eq $Value -or $Value -is [string] -or $Value -is [bool] -or $Value -is [int] -or $Value -is [long] -or $Value -is [double] -or $Value -is [decimal]) {
        return $Value
    }
    $Value | ConvertTo-Json -Depth 20 -Compress
}

function Write-RegistryCsv([object[]]$Rows, [string]$Path) {
    $csvRows = @(
        $Rows | ForEach-Object {
            [pscustomobject]@{
                record_id = $_.record_id
                state_code = $_.state_code
                jurisdiction_name = $_.jurisdiction_name
                jurisdiction_type = $_.jurisdiction_type
                official_jurisdiction_id = Convert-ToCell $_.official_jurisdiction_id
                tax_name = $_.tax_name
                legal_incidence = Convert-ToCell $_.legal_incidence
                geographic_scope = Convert-ToCell $_.geographic_scope
                employer_withholding = $_.employer_withholding
                rate = Convert-ToCell $_.rate
                effective_at = Convert-ToCell $_.effective_at
                administrator = Convert-ToCell $_.administrator
                evidence_status = $_.evidence_status
                coverage_status = $_.coverage_status
                product_disposition = $_.product_disposition
                source_date = Convert-ToCell $_.source_date
                primary_source_urls = @($_.primary_source_urls) -join ' | '
                limitations = @($_.limitations) -join ' | '
            }
        }
    )
    $csvRows | ConvertTo-Csv -NoTypeInformation | Set-Content -LiteralPath $Path -Encoding utf8NoBOM
}

$registry = @(
    Get-Content -LiteralPath $registryPath |
        ForEach-Object { $_ | ConvertFrom-Json } |
        Sort-Object state_code, jurisdiction_name, record_id
)
$coverage = @(
    Get-Content -LiteralPath $coveragePath |
        ForEach-Object { $_ | ConvertFrom-Json } |
        Sort-Object state_code
)

$duplicateRegistryIds = @($registry | Group-Object record_id | Where-Object Count -gt 1)
if ($duplicateRegistryIds.Count -gt 0) { throw 'The source registry contains duplicate record IDs.' }
if ($coverage.Count -ne 51 -or @($coverage.state_code | Sort-Object -Unique).Count -ne 51) {
    throw 'Coverage policy must contain exactly 51 unique state/DC rows.'
}

$direct = @($registry | Where-Object evidence_status -eq 'CONFIRMED_PRIMARY')
$queue = @($registry | Where-Object evidence_status -ne 'CONFIRMED_PRIMARY')
if ($direct.Count + $queue.Count -ne $registry.Count) { throw 'Direct/queue partition does not reconcile to the source registry.' }
if (@($queue | Where-Object evidence_status -eq 'CONFIRMED_PRIMARY').Count -ne 0) { throw 'Evidence queue contains a direct-primary row.' }

Write-JsonLines $direct $directJsonlPath
Write-RegistryCsv $direct $directCsvPath
Write-JsonLines $queue $queueJsonlPath
Write-RegistryCsv $queue $queueCsvPath

$coveragePolicy = @(
    $coverage | ForEach-Object {
        $unmatchedDisposition = if ($_.coverage -in @('COMPLETE', 'NO_AUTHORITY_CONFIRMED')) {
            'CLEAR only after authoritative, unique worksite-jurisdiction resolution and a current release evaluation'
        } else {
            'UNDETERMINED'
        }
        [ordered]@{
            state_code = $_.state_code
            coverage_status = $_.coverage
            unmatched_authoritative_jurisdiction_disposition = $unmatchedDisposition
            evidence_summary = $_.basis
            primary_sources = $_.primary_sources
            limitations = $_.limitations
            source_date = $_.source_date
            valid_through = $_.valid_through
        }
    }
)
Write-JsonLines $coveragePolicy $coveragePolicyJsonlPath
$coveragePolicy | ForEach-Object {
    [pscustomobject]@{
        state_code = $_.state_code
        coverage_status = $_.coverage_status
        unmatched_authoritative_jurisdiction_disposition = $_.unmatched_authoritative_jurisdiction_disposition
        evidence_summary = $_.evidence_summary
        primary_sources = @($_.primary_sources) -join ' | '
        limitations = @($_.limitations) -join ' | '
        source_date = $_.source_date
        valid_through = $_.valid_through
    }
} | ConvertTo-Csv -NoTypeInformation | Set-Content -LiteralPath $coveragePolicyCsvPath -Encoding utf8NoBOM

$release = [ordered]@{
    schema_version = 1
    generated_at = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    governance_status = 'RESEARCH_COMPLETE_AWAITING_PRODUCT_DATA_APPROVAL'
    definition = 'Current municipality-imposed tax calculated from employee wages for work performed in the jurisdiction, including nonresident work, where employer withholding may be required.'
    prohibited_uses = @(
        'Do not calculate tax or withholding from this dataset.',
        'Do not treat a mailing or postal city as an authoritative municipal-boundary match.',
        'Do not treat evidence-queue rows as confirmed positives or negatives.',
        'Do not return CLEAR for a PARTIAL state merely because no row matched.'
    )
    decision_contract = [ordered]@{
        confirmed_primary_match = 'BUFFER_REVIEW_REQUIRED only after authoritative, unique worksite-jurisdiction resolution and effective-date validation'
        evidence_queue_match = 'UNDETERMINED'
        unmatched_complete_or_no_authority_state = 'CLEAR only after authoritative, unique worksite-jurisdiction resolution and current release validation'
        unmatched_partial_state = 'UNDETERMINED'
        incomplete_or_failed_evaluation = 'UNDETERMINED'
    }
    source_registry = [ordered]@{
        path = [IO.Path]::GetFileName($registryPath)
        rows = $registry.Count
        sha256 = (Get-FileHash -LiteralPath $registryPath -Algorithm SHA256).Hash.ToLowerInvariant()
    }
    direct_primary_candidates = [ordered]@{
        rows = $direct.Count
        jsonl_path = [IO.Path]::GetFileName($directJsonlPath)
        jsonl_sha256 = (Get-FileHash -LiteralPath $directJsonlPath -Algorithm SHA256).Hash.ToLowerInvariant()
        csv_path = [IO.Path]::GetFileName($directCsvPath)
        csv_sha256 = (Get-FileHash -LiteralPath $directCsvPath -Algorithm SHA256).Hash.ToLowerInvariant()
    }
    evidence_queue = [ordered]@{
        rows = $queue.Count
        counts_by_evidence_status = [ordered]@{}
        jsonl_path = [IO.Path]::GetFileName($queueJsonlPath)
        jsonl_sha256 = (Get-FileHash -LiteralPath $queueJsonlPath -Algorithm SHA256).Hash.ToLowerInvariant()
        csv_path = [IO.Path]::GetFileName($queueCsvPath)
        csv_sha256 = (Get-FileHash -LiteralPath $queueCsvPath -Algorithm SHA256).Hash.ToLowerInvariant()
    }
    coverage_policy = [ordered]@{
        rows = $coveragePolicy.Count
        jsonl_path = [IO.Path]::GetFileName($coveragePolicyJsonlPath)
        jsonl_sha256 = (Get-FileHash -LiteralPath $coveragePolicyJsonlPath -Algorithm SHA256).Hash.ToLowerInvariant()
        csv_path = [IO.Path]::GetFileName($coveragePolicyCsvPath)
        csv_sha256 = (Get-FileHash -LiteralPath $coveragePolicyCsvPath -Algorithm SHA256).Hash.ToLowerInvariant()
    }
}
$queue | Group-Object evidence_status | Sort-Object Name | ForEach-Object {
    $release.evidence_queue.counts_by_evidence_status[$_.Name] = $_.Count
}
$release | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $releasePath -Encoding utf8NoBOM
$release | ConvertTo-Json -Depth 10
