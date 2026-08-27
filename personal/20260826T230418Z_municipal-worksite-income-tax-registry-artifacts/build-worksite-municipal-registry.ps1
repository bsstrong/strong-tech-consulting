$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$sourcePath = Join-Path $root 'normalized-municipal-tax-inventory.jsonl'
$alabamaLeaguePath = Join-Path $root 'agent-extracts\alabama-league-occupational-tax-survey.csv'
$alabamaPrimaryVerificationPath = Join-Path $root 'agent-extracts\alabama-primary-verification.csv'
$kentuckyKlcPath = Join-Path $root 'agent-extracts\kentucky-klc-fy2023-city-rates.csv'
$jsonlPath = Join-Path $root 'worksite-municipal-income-tax-registry.jsonl'
$csvPath = Join-Path $root 'worksite-municipal-income-tax-registry.csv'
$summaryPath = Join-Path $root 'worksite-municipal-income-tax-registry-validation.json'

$sourceRecords = @(
    Get-Content -LiteralPath $sourcePath |
        ForEach-Object { $_ | ConvertFrom-Json } |
        Where-Object { $_.category -eq 'MUNICIPAL_EARNED_INCOME_WORKSITE' }
)

# The narrower worksite definition removes one Alabama row whose current
# official material does not establish worksite incidence and one resident-only
# Ohio municipality. Directly verified Kentucky additions are added below.
$sourceRecords = @(
    $sourceRecords | Where-Object {
        $_.record_id -notin @(
            'al-bessemer-occupational-tax',
            'oh-municipal-income-76582'
        )
    }
)

$additions = @(
    [pscustomobject]@{
        record_id = 'ky-lebanon-occupational-license-tax'
        state_code = 'KY'
        jurisdiction_name = 'Lebanon'
        jurisdiction_type = 'incorporated city'
        official_jurisdiction_id = $null
        category = 'MUNICIPAL_EARNED_INCOME_WORKSITE'
        tax_name = 'Occupational License Tax / Wage Withholding'
        legal_incidence = 'employee wages and other compensation'
        geographic_scope = 'work or services performed within Lebanon'
        employer_withholding = $true
        rate = '1%'
        effective_at = 'Current official city tax page retrieved 2026-08-25'
        administrator = 'City of Lebanon'
        evidence_status = 'CONFIRMED_PRIMARY'
        coverage_status = 'PARTIAL'
        product_disposition = 'BUFFER_REVIEW_REQUIRED after authoritative jurisdiction-boundary resolution; otherwise UNDETERMINED'
        primary_source_urls = @('https://lebanon.ky.gov/depart/taxes/')
        source_date = 'Retrieved 2026-08-25'
        limitations = @('Kentucky has no complete current authoritative statewide city occupational-tax adopter register.')
        related_components = $null
    },
    [pscustomobject]@{
        record_id = 'ky-henderson-occupational-license-tax'
        state_code = 'KY'
        jurisdiction_name = 'Henderson'
        jurisdiction_type = 'incorporated city'
        official_jurisdiction_id = $null
        category = 'MUNICIPAL_EARNED_INCOME_WORKSITE'
        tax_name = 'Occupational License Tax / Wage Withholding'
        legal_incidence = 'employee wages and other compensation'
        geographic_scope = 'work or services performed within Henderson by resident and nonresident employees'
        employer_withholding = $true
        rate = '1.65%'
        effective_at = 'Current city code retrieved 2026-08-25'
        administrator = 'City of Henderson'
        evidence_status = 'CONFIRMED_PRIMARY'
        coverage_status = 'PARTIAL'
        product_disposition = 'BUFFER_REVIEW_REQUIRED after authoritative jurisdiction-boundary resolution; otherwise UNDETERMINED'
        primary_source_urls = @('https://library.municode.com/ky/henderson/codes/code_of_ordinances?nodeId=COOR_CH21TA_ARTIINGE')
        source_date = 'Retrieved 2026-08-25'
        limitations = @('Kentucky has no complete current authoritative statewide city occupational-tax adopter register.')
        related_components = $null
    },
    [pscustomobject]@{
        record_id = 'ky-west-buechel-occupational-license-tax'
        state_code = 'KY'
        jurisdiction_name = 'West Buechel'
        jurisdiction_type = 'incorporated city'
        official_jurisdiction_id = $null
        category = 'MUNICIPAL_EARNED_INCOME_WORKSITE'
        tax_name = 'Occupational License Tax / Wage Withholding'
        legal_incidence = 'employee wages and compensation'
        geographic_scope = 'work or services performed within West Buechel'
        employer_withholding = $true
        rate = '1.5%'
        effective_at = 'Ordinance 315-2025; current city forms page retrieved 2026-08-25'
        administrator = 'City of West Buechel'
        evidence_status = 'CONFIRMED_PRIMARY'
        coverage_status = 'PARTIAL'
        product_disposition = 'BUFFER_REVIEW_REQUIRED after authoritative jurisdiction-boundary resolution; otherwise UNDETERMINED'
        primary_source_urls = @(
            'https://codelibrary.amlegal.com/codes/westbuechel/latest/westbuechel_ky/0-0-0-2938',
            'https://westbuechel.ky.gov/payment-and-forms/Pages/Forms.aspx',
            'https://westbuechel.ky.gov/payment-and-forms/PublishingImages/Pages/Forms/Occupational%20Withholding%20Form.pdf'
        )
        source_date = '2025 ordinance; retrieved 2026-08-25'
        limitations = @('Kentucky has no complete current authoritative statewide city occupational-tax adopter register.')
        related_components = $null
    },
    [pscustomobject]@{
        record_id = 'ky-walton-occupational-license-tax'
        state_code = 'KY'
        jurisdiction_name = 'Walton'
        jurisdiction_type = 'incorporated city'
        official_jurisdiction_id = $null
        category = 'MUNICIPAL_EARNED_INCOME_WORKSITE'
        tax_name = 'Occupational Tax / Payroll Tax'
        legal_incidence = 'employee wages and other compensation'
        geographic_scope = 'work or services performed within Walton by resident and nonresident employees'
        employer_withholding = $true
        rate = '2%'
        effective_at = 'Effective after January 1, 2025 upon collection arrangements and employer notification; current code and 2025 amendment retrieved 2026-08-25'
        administrator = 'City of Walton or its designee'
        evidence_status = 'CONFIRMED_PRIMARY'
        coverage_status = 'PARTIAL'
        product_disposition = 'BUFFER_REVIEW_REQUIRED after authoritative jurisdiction-boundary resolution; otherwise UNDETERMINED'
        primary_source_urls = @(
            'https://cityofwalton.org/wp-content/uploads/2025/09/Walton-Ordinance-2025-15-Revised-Occupational-License-Fee-Ordinance-2024-17-final-29aug25.pdf',
            'https://codelibrary.amlegal.com/codes/walton/latest/walton_ky/0-0-0-17965',
            'https://codelibrary.amlegal.com/codes/walton/latest/walton_ky/0-0-0-17976',
            'https://codelibrary.amlegal.com/codes/walton/latest/walton_ky/0-0-0-17988'
        )
        source_date = 'Ordinance 2024-17 as amended by Ordinance 2025-15; retrieved 2026-08-25'
        limitations = @('Kentucky has no complete current authoritative statewide city occupational-tax adopter register.')
        related_components = $null
    }
)
$sourceRecords += $additions

# Promote Alabama League candidates only when current municipal primary
# material establishes employee compensation, worksite incidence, rate, and
# employer withholding. Rows with only collector/rate evidence remain in the
# association-supported discovery tier below.
if (-not (Test-Path -LiteralPath $alabamaPrimaryVerificationPath)) {
    throw "Alabama primary-verification extract not found: $alabamaPrimaryVerificationPath"
}
$alabamaPrimaryRows = @(Import-Csv -LiteralPath $alabamaPrimaryVerificationPath)
if ($alabamaPrimaryRows.Count -ne 9) {
    throw "Expected 9 directly verified Alabama additions; found $($alabamaPrimaryRows.Count)."
}
$alabamaPrimaryAdditions = @(
    foreach ($row in $alabamaPrimaryRows) {
        [pscustomobject]@{
            record_id = $row.record_id
            state_code = 'AL'
            jurisdiction_name = $row.municipality
            jurisdiction_type = 'incorporated city or town'
            official_jurisdiction_id = $null
            category = 'MUNICIPAL_EARNED_INCOME_WORKSITE'
            tax_name = $row.tax_name
            legal_incidence = $row.legal_incidence
            geographic_scope = $row.geographic_scope
            employer_withholding = $true
            rate = $row.rate
            effective_at = $row.effective_at
            administrator = $row.administrator
            evidence_status = 'CONFIRMED_PRIMARY'
            coverage_status = 'PARTIAL'
            product_disposition = 'BUFFER_REVIEW_REQUIRED after authoritative jurisdiction-boundary resolution; otherwise UNDETERMINED'
            primary_source_urls = @($row.primary_source_urls -split '\|' | Where-Object { $_ })
            source_date = $row.source_date
            limitations = @($row.limitations)
            related_components = $null
        }
    }
)
$sourceRecords += $alabamaPrimaryAdditions

# Strengthen the directly verified partial-state rows with the current official
# sources used in the narrowed-scope revalidation.
$overrides = @{
    'al-auburn-occupational-license-fee' = @(
        'https://static.auburnalabama.org/media/apps/www/revenue/Business-License-%26-Tax-Info-Brochure.pdf',
        'https://static.auburnalabama.org/media/apps/www/finance/business-and-licensing-forms/Reconciliation-of-Occupational-License-Fee-Form-2025.pdf'
    )
    'al-birmingham-occupational-tax' = @(
        'https://library.municode.com/al/birmingham/codes/code_of_ordinances?nodeId=PT1THCOGEOR_TIT3ARETA_CH2OCTA'
    )
    'al-gadsden-occupation-tax' = @(
        'https://library.municode.com/al/gadsden/codes/code_of_ordinances?nodeId=COOR_CH74LITA_ARTIVOCLIFE',
        'https://www.cityofgadsden.com/DocumentCenter/View/5067/Form-G-3-OLF-Reconciliation'
    )
    'al-glencoe-occupational-license-fee' = @(
        'https://cityofglencoe.org/revenue/',
        'https://cityofglencoe.org/wp-content/uploads/2021/09/Glencoe-Occupational-Tax-Form.pdf'
    )
    'al-opelika-occupation-license-fee' = @(
        'https://www.opelika-al.gov/338/Occupation-License',
        'https://www.opelika-al.gov/m/NewsFlash/Home/Detail/1092'
    )
    'ky-bowling-green-occupational-license-tax' = @(
        'https://www.bgky.org/finance/occupational-taxes-increase'
    )
    'ky-covington-occupational-license-fee' = @(
        'https://www.covingtonky.gov/government/departments/finance',
        'https://www.covingtonky.gov/Portals/covingtonky/ACFR%202025%20-%20Final%20-%20City%20of%20Covington%202182026.pdf'
    )
    'ky-lexington-fayette-occupational-license-fee' = @(
        'https://www.lexingtonky.gov/working/business-licensing-taxes/occupational-license-fee-minimum-license-filing-requirements'
    )
    'ky-louisville-jefferson-occupational-license-tax' = @(
        'https://louisvilleky.gov/revenue-commission/forms/form-w-1ree-employee-refund-occupational-taxes-withheld',
        'https://louisvilleky.gov/government/revenue-commission/w-1ree-tax-form-instructions'
    )
    'ky-nicholasville-occupational-license-fee' = @(
        'https://nicholasville.org/tax-office/'
    )
    'ky-paducah-occupational-license-fee' = @(
        'https://paducahky.gov/node/2810'
    )
}
foreach ($record in $sourceRecords) {
    if ($overrides.ContainsKey($record.record_id)) {
        $record.primary_source_urls = $overrides[$record.record_id]
    }
    if ($record.record_id -eq 'OR-EUGENE-EMPLOYEE-PAYROLL') {
        $record.rate = 'Employee 0%, 0.30%, or 0.44% of subject wages, depending on wage level'
        $record.geographic_scope = 'Employee wage tax tied primarily to the employer physical business location in Eugene; current instructions include nonresident employees for Eugene-location hours.'
        $record.primary_source_urls = @(
            'https://www.eugene-or.gov/DocumentCenter/View/81429/2026-EUG-PY-2---Instructions-to-Employee-Return',
            'https://www.eugene-or.gov/DocumentCenter/View/68719/Non-Resident-withholding-chart',
            'https://www.eugene-or.gov/4281/Community-Safety-Payroll-Tax',
            'https://www.eugene-or.gov/DocumentCenter/View/64582/Business-location-overview'
        )
        $record.source_date = '2026 employee instructions; retrieved 2026-08-25'
    }
    if ($record.record_id -eq 'ny-yonkers-income-taxes') {
        $record.tax_name = 'Yonkers Nonresident Earnings Tax'
        $record.legal_incidence = 'nonresident wages for services performed in Yonkers'
        $record.geographic_scope = 'Nonresidents earning wages for services performed in Yonkers; the separate resident surcharge is excluded from this registry.'
        $record.rate = '0.5% nonresident earnings tax'
        $record.limitations = @('The separate Yonkers resident income-tax surcharge is outside this worksite-only registry.')
    }
}

# The Alabama League of Municipalities publishes a 25-jurisdiction percentage
# occupational-tax survey, while warning that the values were supplied by
# survey and must be verified locally. Retain its non-primary candidates as a
# separate association tier; direct current city records supersede matches.
if (-not (Test-Path -LiteralPath $alabamaLeaguePath)) {
    throw "Alabama League extract not found: $alabamaLeaguePath"
}
$alabamaLeagueRows = @(Import-Csv -LiteralPath $alabamaLeaguePath)
if ($alabamaLeagueRows.Count -ne 25) {
    throw "Expected 25 Alabama League occupational-tax rows; found $($alabamaLeagueRows.Count)."
}
$directAlabamaNames = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
@($sourceRecords | Where-Object state_code -eq 'AL') | ForEach-Object {
    [void]$directAlabamaNames.Add($_.jurisdiction_name)
}
$alabamaLeagueAdditions = @(
    foreach ($row in $alabamaLeagueRows) {
        if ($directAlabamaNames.Contains($row.municipality)) { continue }
        $slug = ($row.municipality.ToLowerInvariant() -replace '[^a-z0-9]+', '-').Trim('-')
        [pscustomobject]@{
            record_id = "al-league-occupational-tax-$slug"
            state_code = 'AL'
            jurisdiction_name = $row.municipality
            jurisdiction_type = 'incorporated city or town'
            official_jurisdiction_id = $null
            category = 'MUNICIPAL_EARNED_INCOME_WORKSITE'
            tax_name = 'Occupational Tax'
            legal_incidence = 'percentage occupational tax reported by the Alabama League of Municipalities; employee-wage incidence requires current local verification'
            geographic_scope = 'municipal occupational-tax candidate; current worksite/nonresident rule requires local verification'
            employer_withholding = $null
            rate = $row.league_reported_rate
            effective_at = 'Current Alabama League survey page retrieved 2026-08-25; rate currency is not guaranteed'
            administrator = "$($row.municipality) local occupational-tax administrator"
            evidence_status = 'SUPPORTED_AUTHORITATIVE_ASSOCIATION'
            coverage_status = 'PARTIAL'
            product_disposition = 'UNDETERMINED until the current local ordinance, employee-wage incidence, withholding rule, rate, and authoritative jurisdiction boundary are verified'
            primary_source_urls = @(
                'https://almonline.org/VirtualPageTemplate.aspx?PageID=3f384f8c-dd06-4beb-8cd2-1353aaad9414',
                'https://alison.legislature.state.al.us/files/pdf/SearchableInstruments/2020RS/PrintFiles/204606-1.pdf'
            )
            source_date = 'League survey page retrieved 2026-08-25'
            limitations = @(
                'The Alabama League says the rates were supplied by survey, disclaims their accuracy, and requires verification with the locality.',
                'The League list does not itself prove current employee incidence, commuter/worksite allocation, or employer withholding.',
                'A current local ordinance, withholding material, and boundary match are required before a product BUFFER decision.'
            )
            related_components = [ordered]@{
                source_tier = 'authoritative-association statewide survey'
            }
        }
    }
)
$sourceRecords += $alabamaLeagueAdditions

# Kentucky's League of Cities says 170 Kentucky cities levy a tax on gross
# earnings and links its statewide FY2023 city-rate survey. The table contains
# 169 percentage payroll rows plus one flat Caneyville row, which is excluded by
# this report's definition. These rows are retained as a separate authoritative-
# association evidence tier. Direct municipal rows above supersede matching KLC
# rows, and Walton is a current post-FY2023 primary-source addition.
if (-not (Test-Path -LiteralPath $kentuckyKlcPath)) {
    throw "Kentucky KLC extract not found: $kentuckyKlcPath"
}
$kentuckyKlcRows = @(
    Import-Csv -LiteralPath $kentuckyKlcPath |
        Where-Object { $_.fy2023_payroll_rate -match '%' }
)
if ($kentuckyKlcRows.Count -ne 169) {
    throw "Expected 169 percentage-payroll rows in KLC extract; found $($kentuckyKlcRows.Count)."
}
$duplicateKentuckyKlcNames = @(
    $kentuckyKlcRows | Group-Object city_name | Where-Object Count -gt 1 | Select-Object -ExpandProperty Name
)
if ($duplicateKentuckyKlcNames.Count -gt 0) {
    throw "Duplicate KLC percentage-payroll city names: $($duplicateKentuckyKlcNames -join ', ')"
}

$kentuckyKlcAliases = @{
    'Lexington' = 'Lexington-Fayette Urban County Government'
    'Louisville' = 'Louisville/Jefferson County Metro Government'
}
$directKentuckyNames = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
@($sourceRecords | Where-Object state_code -eq 'KY') | ForEach-Object {
    [void]$directKentuckyNames.Add($_.jurisdiction_name)
}

function Get-StableRecordSlug([string]$value) {
    $slug = $value.ToLowerInvariant() -replace '[^a-z0-9]+', '-'
    $slug.Trim('-')
}

$kentuckyKlcAdditions = @(
    foreach ($row in $kentuckyKlcRows) {
        $canonicalName = if ($kentuckyKlcAliases.ContainsKey($row.city_name)) {
            $kentuckyKlcAliases[$row.city_name]
        } else {
            $row.city_name
        }
        if ($directKentuckyNames.Contains($canonicalName)) { continue }

        [pscustomobject]@{
            record_id = "ky-klc-payroll-$(Get-StableRecordSlug $row.city_name)"
            state_code = 'KY'
            jurisdiction_name = $row.city_name
            jurisdiction_type = 'incorporated city'
            official_jurisdiction_id = [ordered]@{
                klc_county = $row.county
                klc_fy2023_source_page = [int]$row.source_page
            }
            category = 'MUNICIPAL_EARNED_INCOME_WORKSITE'
            tax_name = 'Occupational License Tax / Payroll Tax'
            legal_incidence = 'employee gross earnings or payroll'
            geographic_scope = 'persons working within the city under Kentucky occupational-license-tax rules; current local boundary and ordinance must be verified before use'
            employer_withholding = $true
            rate = $row.fy2023_payroll_rate
            effective_at = 'FY2023 KLC city survey; KLC still reported 170 gross-earnings cities on 2025-07-11'
            administrator = "$($row.city_name) local occupational-tax administrator"
            evidence_status = 'SUPPORTED_AUTHORITATIVE_ASSOCIATION'
            coverage_status = 'PARTIAL'
            product_disposition = 'UNDETERMINED until the current local ordinance, rate, and authoritative jurisdiction boundary are verified'
            primary_source_urls = @(
                'https://www.klc.org/News/12942/the-occupational-business-license-fee',
                'https://kleague.sharepoint.com/sites/governmentalaffairs/Shared%20Documents/Research/Taxes/Occupational%20Taxes/KY%20City_OccupationalLicenseRates_FY2023.pdf?ga=1',
                'https://www.klc.org/InfoCentral/Detail/31/occupational-license-tax',
                'https://apps.legislature.ky.gov/law/statutes/statute.aspx?id=23793',
                'https://apps.legislature.ky.gov/law/statutes/statute.aspx?id=23796'
            )
            source_date = 'FY2023 surveyed rate; KLC adopter count published 2025-07-11; retrieved 2026-08-25'
            limitations = @(
                'KLC is an authoritative municipal association, but its rate table is a city survey rather than the municipality ordinance.',
                'The table warns that rates may change and uses FY2023 or the most readily available values.',
                'A current local ordinance, withholding material, and boundary match are required before a product BUFFER decision.'
            )
            related_components = [ordered]@{
                source_tier = 'authoritative-association statewide survey'
                klc_fy2023_net_profits_rate = $row.fy2023_net_profits_rate
                klc_fy2023_gross_receipts_rate = $row.fy2023_gross_receipts_rate
            }
        }
    }
)
$sourceRecords += $kentuckyKlcAdditions

function Get-PaMunicipalityIds($record) {
    @(
        @($record.official_jurisdiction_id.municipality_ids) |
            ForEach-Object { "$_" -split ';' } |
            ForEach-Object { $_.Trim() } |
            Where-Object { $_ } |
            Sort-Object -Unique
    )
}

$script:paParent = @{}
function Find-PaRoot([string]$id) {
    if (-not $script:paParent.ContainsKey($id)) {
        $script:paParent[$id] = $id
    }
    if ($script:paParent[$id] -ne $id) {
        $script:paParent[$id] = Find-PaRoot $script:paParent[$id]
    }
    $script:paParent[$id]
}
function Join-PaIds([string]$left, [string]$right) {
    $leftRoot = Find-PaRoot $left
    $rightRoot = Find-PaRoot $right
    if ($leftRoot -ne $rightRoot) {
        if ([string]::CompareOrdinal($leftRoot, $rightRoot) -le 0) {
            $script:paParent[$rightRoot] = $leftRoot
        } else {
            $script:paParent[$leftRoot] = $rightRoot
        }
    }
}

$paSourceRecords = @($sourceRecords | Where-Object state_code -eq 'PA')
foreach ($record in $paSourceRecords) {
    $ids = @(Get-PaMunicipalityIds $record)
    if ($ids.Count -eq 0) { throw "PA record $($record.record_id) has no municipality ID." }
    foreach ($id in $ids) { [void](Find-PaRoot $id) }
    for ($i = 1; $i -lt $ids.Count; $i++) { Join-PaIds $ids[0] $ids[$i] }
}

$paGroups = @(
    $paSourceRecords | Group-Object {
        $ids = @(Get-PaMunicipalityIds $_)
        Find-PaRoot $ids[0]
    }
)
$paRecords = @(
    foreach ($group in $paGroups) {
        $names = @($group.Group.jurisdiction_name | Sort-Object -Unique)
        $types = @($group.Group.jurisdiction_type | Sort-Object -Unique)
        if ($names.Count -ne 1 -or $types.Count -ne 1) {
            throw "PA legal-municipality group $($group.Name) has inconsistent names or types."
        }
        $allIds = @($group.Group | ForEach-Object { Get-PaMunicipalityIds $_ } | Sort-Object -Unique)
        $psdCodes = @($group.Group.official_jurisdiction_id.psd_code | Sort-Object -Unique)
        $nonresidentRates = @($group.Group.rate.municipal_nonresident_percent | Sort-Object -Unique)
        $residentRates = @($group.Group.rate.municipal_resident_percent | Sort-Object -Unique)
        $administrators = @($group.Group.administrator | Sort-Object -Unique)
        $urls = @($group.Group.primary_source_urls | Sort-Object -Unique)
        $dates = @($group.Group.source_date | Sort-Object -Unique)
        [pscustomobject]@{
            record_id = "pa-legal-municipality-eit-$($group.Name)"
            state_code = 'PA'
            jurisdiction_name = $names[0]
            jurisdiction_type = $types[0]
            official_jurisdiction_id = [ordered]@{
                municipality_ids = $allIds
                psd_codes = $psdCodes
            }
            category = 'MUNICIPAL_EARNED_INCOME_WORKSITE'
            tax_name = 'Municipal Earned Income Tax'
            legal_incidence = 'individual municipal earned-income tax; employer withholding follows resident/work-location rules'
            geographic_scope = 'positive work-location municipal nonresident EIT; one legal municipality may span multiple PSD codes'
            employer_withholding = $true
            rate = [ordered]@{
                municipal_nonresident_percent = $nonresidentRates
                municipal_resident_percent = $residentRates
            }
            effective_at = [ordered]@{ register_as_of = '2026-08-25' }
            administrator = $administrators
            evidence_status = 'CONFIRMED_PRIMARY'
            coverage_status = 'COMPLETE'
            product_disposition = 'BUFFER_REVIEW_REQUIRED only after authoritative address-to-PSD resolution; postal city alone remains UNDETERMINED'
            primary_source_urls = $urls
            source_date = $dates
            limitations = @(
                'PSD code, not postal city, is the authoritative locality key.',
                'School-district EIT/PIT and municipal/school LST components are excluded.',
                'Member municipality IDs and PSD codes are preserved when a legal municipality spans more than one source row.'
            )
            related_components = [ordered]@{
                source_psd_record_count = $group.Count
            }
        }
    }
)

$records = @(
    @($sourceRecords | Where-Object state_code -ne 'PA') + $paRecords |
        Sort-Object state_code, jurisdiction_name, record_id
)

$jsonLines = @($records | ForEach-Object { $_ | ConvertTo-Json -Depth 20 -Compress })
[System.IO.File]::WriteAllLines($jsonlPath, $jsonLines, [System.Text.UTF8Encoding]::new($false))

function Convert-ToCell($value) {
    if ($null -eq $value -or $value -is [string] -or $value -is [bool] -or $value -is [int] -or $value -is [long] -or $value -is [double] -or $value -is [decimal]) {
        return $value
    }
    $value | ConvertTo-Json -Depth 20 -Compress
}

$csvRows = @(
    $records | ForEach-Object {
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
$csvText = $csvRows | ConvertTo-Csv -NoTypeInformation
[System.IO.File]::WriteAllLines($csvPath, $csvText, [System.Text.UTF8Encoding]::new($false))

$stateCounts = [ordered]@{}
$records | Group-Object state_code | Sort-Object Name | ForEach-Object { $stateCounts[$_.Name] = $_.Count }
$duplicateRecordIds = @($records | Group-Object record_id | Where-Object Count -gt 1 | Select-Object -ExpandProperty Name)
$missingSources = @($records | Where-Object { @($_.primary_source_urls).Count -eq 0 } | Select-Object -ExpandProperty record_id)
$nonWithholding = @($records | Where-Object { $_.employer_withholding -ne $true } | Select-Object -ExpandProperty record_id)

$summary = [ordered]@{
    generated_at = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    definition = 'Current municipality-imposed tax calculated from employee wages for work performed in the jurisdiction, including nonresident work, where employer withholding may be required.'
    source_inventory = $sourcePath
    source_inputs = [ordered]@{
        normalized_inventory_sha256 = (Get-FileHash -LiteralPath $sourcePath -Algorithm SHA256).Hash.ToLowerInvariant()
        alabama_league_extract_sha256 = (Get-FileHash -LiteralPath $alabamaLeaguePath -Algorithm SHA256).Hash.ToLowerInvariant()
        alabama_primary_verification_sha256 = (Get-FileHash -LiteralPath $alabamaPrimaryVerificationPath -Algorithm SHA256).Hash.ToLowerInvariant()
        kentucky_klc_extract_sha256 = (Get-FileHash -LiteralPath $kentuckyKlcPath -Algorithm SHA256).Hash.ToLowerInvariant()
        kentucky_klc_source_pdf_sha256 = (Get-FileHash -LiteralPath (Join-Path $root 'agent-extracts\sources\kentucky-city-occupational-license-rates-fy2023.pdf') -Algorithm SHA256).Hash.ToLowerInvariant()
    }
    reconciliation = [ordered]@{
        original_worksite_rows = 2687
        excluded_records = @('al-bessemer-occupational-tax', 'oh-municipal-income-76582')
        added_direct_primary_records = @(
            $alabamaPrimaryAdditions.record_id
            'ky-lebanon-occupational-license-tax',
            'ky-henderson-occupational-license-tax',
            'ky-west-buechel-occupational-license-tax',
            'ky-walton-occupational-license-tax'
        )
        alabama_league_occupational_tax_rows = $alabamaLeagueRows.Count
        alabama_new_direct_primary_rows = $alabamaPrimaryAdditions.Count
        alabama_league_rows_superseded_by_direct_primary = $alabamaLeagueRows.Count - $alabamaLeagueAdditions.Count
        alabama_league_association_only_rows_added = $alabamaLeagueAdditions.Count
        kentucky_klc_percentage_payroll_rows = $kentuckyKlcRows.Count
        kentucky_klc_rows_superseded_by_direct_primary = $kentuckyKlcRows.Count - $kentuckyKlcAdditions.Count
        kentucky_klc_association_only_rows_added = $kentuckyKlcAdditions.Count
        pennsylvania_source_psd_rows = $paSourceRecords.Count
        pennsylvania_unique_legal_municipalities = $paRecords.Count
    }
    total_records = $records.Count
    states_with_registry_records = $stateCounts.Count
    counts_by_state = $stateCounts
    duplicate_record_ids = $duplicateRecordIds
    records_without_primary_source = $missingSources
    records_without_confirmed_employer_withholding = $nonWithholding
    counts_by_evidence_status = [ordered]@{}
    jsonl_sha256 = (Get-FileHash -LiteralPath $jsonlPath -Algorithm SHA256).Hash.ToLowerInvariant()
    csv_sha256 = (Get-FileHash -LiteralPath $csvPath -Algorithm SHA256).Hash.ToLowerInvariant()
}
$records | Group-Object evidence_status | Sort-Object Name | ForEach-Object {
    $summary.counts_by_evidence_status[$_.Name] = $_.Count
}
$summaryJson = $summary | ConvertTo-Json -Depth 10
[System.IO.File]::WriteAllText($summaryPath, $summaryJson + [Environment]::NewLine, [System.Text.UTF8Encoding]::new($false))

$summaryJson
