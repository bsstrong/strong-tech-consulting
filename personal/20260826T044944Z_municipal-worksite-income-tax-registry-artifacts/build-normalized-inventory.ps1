param(
    [Parameter(Mandatory = $false)]
    [string]$ArtifactRoot = 'C:\Users\bsstr\.codex\visualizations\2026\08\25\01a03b43-8288-7012-b881-a39ce7f381d5'
)

$ErrorActionPreference = 'Stop'
$extractRoot = Join-Path $ArtifactRoot 'agent-extracts'
$primaryPath = Join-Path $ArtifactRoot 'normalized-municipal-tax-inventory.jsonl'
$reviewPath = Join-Path $ArtifactRoot 'review-only-and-nonmunicipal-inventory.jsonl'
$summaryPath = Join-Path $ArtifactRoot 'inventory-validation-summary.json'

$coverageByState = @{}
Get-Content -LiteralPath (Join-Path $ArtifactRoot 'coverage-matrix.jsonl') | ForEach-Object {
    $row = $_ | ConvertFrom-Json
    $coverageByState[$row.state_code] = $row.coverage
}

$primary = [System.Collections.Generic.List[object]]::new()
$review = [System.Collections.Generic.List[object]]::new()

function New-NormalizedRecord {
    param(
        [string]$RecordId,
        [string]$StateCode,
        [string]$JurisdictionName,
        [string]$JurisdictionType,
        [object]$OfficialJurisdictionId,
        [string]$Category,
        [string]$TaxName,
        [string]$LegalIncidence,
        [string]$GeographicScope,
        [object]$EmployerWithholding,
        [object]$Rate,
        [object]$EffectiveAt,
        [object]$Administrator,
        [string]$EvidenceStatus,
        [string]$CoverageStatus,
        [string]$ProductDisposition,
        [object[]]$PrimarySourceUrls,
        [object]$SourceDate,
        [object[]]$Limitations,
        [object]$RelatedComponents = $null
    )

    [ordered]@{
        record_id = $RecordId
        state_code = $StateCode
        jurisdiction_name = $JurisdictionName
        jurisdiction_type = $JurisdictionType
        official_jurisdiction_id = $OfficialJurisdictionId
        category = $Category
        tax_name = $TaxName
        legal_incidence = $LegalIncidence
        geographic_scope = $GeographicScope
        employer_withholding = $EmployerWithholding
        rate = $Rate
        effective_at = $EffectiveAt
        administrator = $Administrator
        evidence_status = $EvidenceStatus
        coverage_status = $CoverageStatus
        product_disposition = $ProductDisposition
        primary_source_urls = @($PrimarySourceUrls | Where-Object { $_ } | Select-Object -Unique)
        source_date = $SourceDate
        limitations = @($Limitations | Where-Object { $_ })
        related_components = $RelatedComponents
    }
}

function Add-AgentRecord {
    param([object]$Row, [bool]$IsGroupB)

    $state = if ($Row.state) { $Row.state } else { $Row.state_code }
    $name = if ($Row.canonical_municipality) { $Row.canonical_municipality } else { $Row.jurisdiction_name }
    if ([string]::IsNullOrWhiteSpace($name)) { $name = 'Not municipality-specific' }
    $type = if ($Row.municipality_type) { $Row.municipality_type } else { $Row.jurisdiction_type }
    $sources = if ($Row.authoritative_urls) { @($Row.authoritative_urls) } else { @($Row.sources | ForEach-Object { $_.url }) }
    $limitation = if ($Row.evidence_limitation) { @($Row.evidence_limitation) } else { @($Row.limitations) }
    $category = $Row.category
    $normalizedCategory = switch ($category) {
        'in_scope_percentage_employee_tax' {
            if ($Row.record_id -in @('md-baltimore-city-local-income-tax', 'ny-new-york-city-resident-income-tax')) {
                'MUNICIPAL_RESIDENT_ONLY_INCOME'
            } else {
                'MUNICIPAL_EARNED_INCOME_WORKSITE'
            }
        }
        'review_only_employer_only_tax' { 'MUNICIPAL_EMPLOYER_PAYROLL' }
        'review_only_flat_occupational_tax' { 'MUNICIPAL_FLAT_OCCUPATIONAL' }
        'ambiguous_nonmunicipal' { 'AMBIGUOUS_COMPENSATION_TAX' }
        'review_only_ambiguous_nonmunicipal' { 'AMBIGUOUS_COMPENSATION_TAX' }
        'MUNICIPAL_EMPLOYEE_COMPENSATION' { 'MUNICIPAL_EARNED_INCOME_WORKSITE' }
        'MUNICIPAL_RESIDENT_ONLY_INCOME' { 'MUNICIPAL_RESIDENT_ONLY_INCOME' }
        'MUNICIPAL_EMPLOYER_PAYROLL' { 'MUNICIPAL_EMPLOYER_PAYROLL' }
        default { $category }
    }

    $productDisposition = switch ($normalizedCategory) {
        'MUNICIPAL_EARNED_INCOME_WORKSITE' { 'BUFFER_REVIEW_REQUIRED after authoritative jurisdiction-boundary resolution; otherwise UNDETERMINED' }
        'MUNICIPAL_RESIDENT_ONLY_INCOME' { 'UNDETERMINED under company-situs-only screening; employee residence is required' }
        'MUNICIPAL_EMPLOYER_PAYROLL' { 'REVIEW_ONLY; employer liability is not an employee deduction-variance trigger' }
        'MUNICIPAL_FLAT_OCCUPATIONAL' { 'REVIEW_ONLY; flat fee is not a compensation-percentage tax' }
        'AMBIGUOUS_COMPENSATION_TAX' { 'UNDETERMINED; incidence, current effect, or municipal mapping is unresolved' }
        default { 'UNDETERMINED' }
    }

    $incidence = if ($Row.incidence) { $Row.incidence } else { $Row.legal_incidence }
    $scope = if ($Row.scope) { $Row.scope } else { $Row.geographic_scope }
    $effective = if ($Row.effective_date) { $Row.effective_date } else { $Row.effective_from }
    $record = New-NormalizedRecord `
        -RecordId $Row.record_id `
        -StateCode $state `
        -JurisdictionName $name `
        -JurisdictionType $type `
        -OfficialJurisdictionId $(if ($Row.official_id) { $Row.official_id } else { $null }) `
        -Category $normalizedCategory `
        -TaxName $(if ($Row.tax_label) { $Row.tax_label } else { $Row.tax_name }) `
        -LegalIncidence $incidence `
        -GeographicScope $scope `
        -EmployerWithholding $Row.employer_withholding `
        -Rate $Row.rate `
        -EffectiveAt $effective `
        -Administrator $Row.administrator `
        -EvidenceStatus $(if ($normalizedCategory -eq 'AMBIGUOUS_COMPENSATION_TAX') { 'AMBIGUOUS_PRIMARY' } else { 'CONFIRMED_PRIMARY' }) `
        -CoverageStatus $coverageByState[$state] `
        -ProductDisposition $productDisposition `
        -PrimarySourceUrls $sources `
        -SourceDate $Row.source_date `
        -Limitations $limitation

    if ($normalizedCategory -in @('MUNICIPAL_EARNED_INCOME_WORKSITE', 'MUNICIPAL_RESIDENT_ONLY_INCOME')) {
        $primary.Add($record)
    } else {
        $review.Add($record)
    }
}

Get-Content -LiteralPath (Join-Path $extractRoot 'phase2-group-a.jsonl') | ForEach-Object {
    Add-AgentRecord -Row ($_ | ConvertFrom-Json) -IsGroupB $false
}

Get-Content -LiteralPath (Join-Path $extractRoot 'phase2-group-b.jsonl') | ForEach-Object {
    Add-AgentRecord -Row ($_ | ConvertFrom-Json) -IsGroupB $true
}

Get-Content -LiteralPath (Join-Path $extractRoot 'root-or-wa-dc.jsonl') | ForEach-Object {
    $row = $_ | ConvertFrom-Json
    if ($row.state_code -eq 'DC') {
        $sources = @($row.sources | ForEach-Object { $_.url })
        $review.Add((New-NormalizedRecord `
            -RecordId $row.record_id -StateCode 'DC' -JurisdictionName $row.jurisdiction_name `
            -JurisdictionType $row.jurisdiction_type -OfficialJurisdictionId $null `
            -Category 'DISTRICT_EQUIVALENT_RESIDENT_INCOME' -TaxName $row.tax_name `
            -LegalIncidence $row.legal_incidence -GeographicScope $row.residence_scope `
            -EmployerWithholding $row.employer_withholding -Rate $row.rate -EffectiveAt $null `
            -Administrator $row.administrator -EvidenceStatus $row.evidence_status `
            -CoverageStatus $row.coverage_context `
            -ProductDisposition 'UNDETERMINED under company-situs-only screening; employee residence is required' `
            -PrimarySourceUrls $sources -SourceDate 'retrieved 2026-08-25' -Limitations $row.limitations))
    } else {
        Add-AgentRecord -Row $row -IsGroupB $false
    }
}

Import-Csv -LiteralPath (Join-Path $extractRoot 'ohio_current_positive_municipal_rates.csv') | ForEach-Object {
    $row = $_
    $primary.Add((New-NormalizedRecord `
        -RecordId "oh-municipal-income-$($row.fips_code)" -StateCode 'OH' `
        -JurisdictionName $row.municipality_name -JurisdictionType 'Ohio municipality' `
        -OfficialJurisdictionId ([ordered]@{ fips_code = $row.fips_code }) `
        -Category 'MUNICIPAL_EARNED_INCOME_WORKSITE' -TaxName 'Municipal Income Tax' `
        -LegalIncidence 'individual municipal income tax; employers withhold qualifying wages under ORC 718.03' `
        -GeographicScope 'Official municipal boundary; resident and work-location rules require address-level resolution' `
        -EmployerWithholding $true `
        -Rate ([ordered]@{ percent = [decimal]$row.rate_percent; fraction = [decimal]$row.rate_fraction }) `
        -EffectiveAt ([ordered]@{ from = $row.effective_start_date; through = $row.effective_end_date; snapshot = $row.snapshot_as_of_date }) `
        -Administrator 'Municipality or its authorized administrator; The Finder is the statewide rate source' `
        -EvidenceStatus 'CONFIRMED_PRIMARY' -CoverageStatus 'COMPLETE' `
        -ProductDisposition 'BUFFER_REVIEW_REQUIRED only after authoritative address-to-municipality/FIPS resolution; postal city alone remains UNDETERMINED' `
        -PrimarySourceUrls @($row.source_rate_url, $row.source_fips_url, $row.source_manifest_url, 'https://codes.ohio.gov/ohio-revised-code/section-718.03') `
        -SourceDate $row.retrieved_at `
        -Limitations @('The official rate table does not make a postal city an authoritative municipal-boundary match.', 'JEDD/JEDZ and school-district income taxes are separate records.')))
}

Import-Csv -LiteralPath (Join-Path $extractRoot 'pennsylvania_current_in_scope_positive_municipal_eit.csv') | ForEach-Object {
    $row = $_
    $category = if ($row.scope_category -eq 'MUNICIPAL_EIT_RESIDENT_ONLY') { 'MUNICIPAL_RESIDENT_ONLY_INCOME' } else { 'MUNICIPAL_EARNED_INCOME_WORKSITE' }
    $disposition = if ($category -eq 'MUNICIPAL_RESIDENT_ONLY_INCOME') {
        'UNDETERMINED under company-situs-only screening; employee residence and authoritative PSD resolution are required'
    } else {
        'BUFFER_REVIEW_REQUIRED only after authoritative address-to-PSD resolution; postal city alone remains UNDETERMINED'
    }
    $primary.Add((New-NormalizedRecord `
        -RecordId "pa-municipal-eit-$($row.psd_code)" -StateCode 'PA' `
        -JurisdictionName $row.municipality_name_official -JurisdictionType $row.municipality_type_from_official_suffix `
        -OfficialJurisdictionId ([ordered]@{ psd_code = $row.psd_code; municipality_ids = @($row.municipality_ids -split '\|') }) `
        -Category $category -TaxName 'Municipal Earned Income Tax' `
        -LegalIncidence 'individual municipal earned-income tax; employer withholding follows resident/work-location rules' `
        -GeographicScope $(if ($category -eq 'MUNICIPAL_RESIDENT_ONLY_INCOME') { 'municipal resident EIT component only' } else { 'positive work-location municipal nonresident EIT, with resident component retained separately' }) `
        -EmployerWithholding $true `
        -Rate ([ordered]@{ municipal_nonresident_percent = [decimal]$row.municipal_nonresident_eit_percent; municipal_resident_percent = [decimal]$row.municipal_resident_eit_percent }) `
        -EffectiveAt ([ordered]@{ nonresident = $row.municipal_nonresident_eit_effective_date; resident = $row.municipal_resident_eit_effective_date; register_as_of = $row.register_as_of_date }) `
        -Administrator $row.eit_collector -EvidenceStatus 'CONFIRMED_PRIMARY' -CoverageStatus 'COMPLETE' `
        -ProductDisposition $disposition `
        -PrimarySourceUrls @($row.source_page_url, $row.source_download_url, $row.philadelphia_overlay_url, 'https://dced.pa.gov/local-government/local-income-tax-information/psd-codes-and-eit-rates/', 'https://dced.pa.gov/local-government/local-income-tax-information/local-withholding-tax-faqs/') `
        -SourceDate $row.date_last_updated `
        -Limitations @('PSD code, not postal city, is the authoritative locality key.', 'School-district EIT/PIT and municipal/school LST components are not included in the municipal EIT rate fields.') `
        -RelatedComponents ([ordered]@{ school_district_id = $row.school_district_id; school_district_name = $row.school_district_name; school_district_eit_percent = [decimal]$row.school_district_eit_percent; school_district_pit_percent = [decimal]$row.school_district_pit_percent; municipal_lst_dollars = [decimal]$row.municipal_lst_dollars; school_district_lst_dollars = [decimal]$row.school_district_lst_dollars })))
}

Import-Csv -LiteralPath (Join-Path $extractRoot 'ohio_current_jedd_jedz_rates.csv') | ForEach-Object {
    $row = $_
    $review.Add((New-NormalizedRecord `
        -RecordId "oh-jedd-jedz-$($row.jedd_jedz_id)" -StateCode 'OH' -JurisdictionName $row.name `
        -JurisdictionType $row.zone_type_from_official_name `
        -OfficialJurisdictionId ([ordered]@{ jedd_jedz_id = $row.jedd_jedz_id }) `
        -Category 'NON_MUNICIPAL_LOCAL_INCOME' -TaxName 'JEDD/JEDZ Income Tax' `
        -LegalIncidence 'special-district income tax; not an incorporated municipality record' `
        -GeographicScope 'joint economic development district or zone boundary' -EmployerWithholding $true `
        -Rate ([ordered]@{ percent = [decimal]$row.rate_percent; fraction = [decimal]$row.rate_fraction }) `
        -EffectiveAt ([ordered]@{ from = $row.effective_start_date; through = $row.effective_end_date; snapshot = $row.snapshot_as_of_date }) `
        -Administrator 'JEDD/JEDZ administrator identified through Ohio Finder source data' `
        -EvidenceStatus 'CONFIRMED_PRIMARY' -CoverageStatus 'COMPLETE' `
        -ProductDisposition 'REVIEW_ONLY; resolve through special-district boundaries and do not treat as a municipal city-name match' `
        -PrimarySourceUrls @($row.source_url, 'https://thefinder.tax.ohio.gov/') -SourceDate $row.retrieved_at `
        -Limitations @('This record is intentionally excluded from the municipal-positive count.')))
}

Get-Content -LiteralPath (Join-Path $extractRoot 'pennsylvania_realtime_register_normalized.jsonl') | ForEach-Object {
    $row = $_ | ConvertFrom-Json
    if ([decimal]$row.municipal_lst_dollars -le 0) { return }
    $review.Add((New-NormalizedRecord `
        -RecordId "pa-municipal-lst-$($row.psd_code)" -StateCode 'PA' `
        -JurisdictionName $row.municipality_name_official -JurisdictionType $row.municipality_type_from_official_suffix `
        -OfficialJurisdictionId ([ordered]@{ psd_code = $row.psd_code; municipality_ids = @($row.municipality_ids) }) `
        -Category 'MUNICIPAL_FLAT_OCCUPATIONAL' -TaxName 'Municipal Local Services Tax component' `
        -LegalIncidence 'flat or prorated local-services tax component, not a percentage of employee compensation' `
        -GeographicScope 'municipal PSD component' -EmployerWithholding $true `
        -Rate ([ordered]@{ annual_dollars = [decimal]$row.municipal_lst_dollars; low_income_exemption_dollars = [decimal]$row.municipal_lst_lie_dollars }) `
        -EffectiveAt ([ordered]@{ effective_date = $row.municipal_lst_effective_date; register_as_of = $row.register_as_of_date }) `
        -Administrator $row.municipal_lst_collector -EvidenceStatus 'CONFIRMED_PRIMARY' -CoverageStatus 'COMPLETE' `
        -ProductDisposition 'REVIEW_ONLY; flat LST is not a compensation-percentage municipal income tax' `
        -PrimarySourceUrls @($row.source_page_url, $row.source_download_url) -SourceDate $row.date_last_updated `
        -Limitations @('School-district LST, if any, is a separate nonmunicipal component.')))
}

$primaryIds = @($primary | ForEach-Object { $_.record_id })
$reviewIds = @($review | ForEach-Object { $_.record_id })
if (($primaryIds | Sort-Object -Unique).Count -ne $primaryIds.Count) { throw 'Duplicate primary record IDs found.' }
if (($reviewIds | Sort-Object -Unique).Count -ne $reviewIds.Count) { throw 'Duplicate review record IDs found.' }
if (@($primaryIds | Where-Object { $_ -in $reviewIds }).Count -ne 0) { throw 'Record ID occurs in both outputs.' }

$primary | ForEach-Object { $_ | ConvertTo-Json -Compress -Depth 20 } | Set-Content -LiteralPath $primaryPath -Encoding utf8NoBOM
$review | ForEach-Object { $_ | ConvertTo-Json -Compress -Depth 20 } | Set-Content -LiteralPath $reviewPath -Encoding utf8NoBOM

$primaryReparse = @(Get-Content -LiteralPath $primaryPath | ForEach-Object { $_ | ConvertFrom-Json })
$reviewReparse = @(Get-Content -LiteralPath $reviewPath | ForEach-Object { $_ | ConvertFrom-Json })

$summary = [ordered]@{
    generated_at = (Get-Date).ToUniversalTime().ToString('o')
    primary = [ordered]@{
        row_count = $primaryReparse.Count
        unique_record_ids = @($primaryReparse.record_id | Sort-Object -Unique).Count
        by_state = [ordered]@{}
        by_category = [ordered]@{}
        sha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $primaryPath).Hash.ToLowerInvariant()
    }
    review = [ordered]@{
        row_count = $reviewReparse.Count
        unique_record_ids = @($reviewReparse.record_id | Sort-Object -Unique).Count
        by_state = [ordered]@{}
        by_category = [ordered]@{}
        sha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $reviewPath).Hash.ToLowerInvariant()
    }
}

$primaryReparse | Group-Object state_code | Sort-Object Name | ForEach-Object { $summary.primary.by_state[$_.Name] = $_.Count }
$primaryReparse | Group-Object category | Sort-Object Name | ForEach-Object { $summary.primary.by_category[$_.Name] = $_.Count }
$reviewReparse | Group-Object state_code | Sort-Object Name | ForEach-Object { $summary.review.by_state[$_.Name] = $_.Count }
$reviewReparse | Group-Object category | Sort-Object Name | ForEach-Object { $summary.review.by_category[$_.Name] = $_.Count }

$summary | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $summaryPath -Encoding utf8NoBOM
$summary | ConvertTo-Json -Depth 20
