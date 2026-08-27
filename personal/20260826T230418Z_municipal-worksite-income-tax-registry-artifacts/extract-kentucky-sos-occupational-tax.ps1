[CmdletBinding()]
param(
    [string]$OutputCsv = (Join-Path $PSScriptRoot 'agent-extracts\kentucky-sos-occupational-tax-districts-2026-08-27.csv'),
    [string]$SummaryJson = (Join-Path $PSScriptRoot 'agent-extracts\kentucky-sos-occupational-tax-districts-2026-08-27-validation.json')
)

$ErrorActionPreference = 'Stop'
$sourceUrl = 'https://web.sos.ky.gov/occupationaltax/'
$session = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
$initial = Invoke-WebRequest -UseBasicParsing -WebSession $session -Uri $sourceUrl

function Get-HiddenValue([string]$Name) {
    $pattern = 'name="' + [regex]::Escape($Name) + '"[^>]*value="([^"]*)"'
    $match = [regex]::Match($initial.Content, $pattern)
    if (-not $match.Success) { throw "Missing ASP.NET hidden field: $Name" }
    [Net.WebUtility]::HtmlDecode($match.Groups[1].Value)
}

function Get-SpanValue([string]$Html, [string]$Id) {
    $pattern = '<span[^>]+id="' + [regex]::Escape($Id) + '"[^>]*>(.*?)</span>'
    $match = [regex]::Match($Html, $pattern, [Text.RegularExpressions.RegexOptions]::Singleline)
    if (-not $match.Success) { return '' }
    [Net.WebUtility]::HtmlDecode(($match.Groups[1].Value -replace '<[^>]+>', '' -replace '\s+', ' ').Trim())
}

function Get-ImageRecords([string]$Html) {
    $table = [regex]::Match($Html, '(?is)<table[^>]+id="ContentPlaceHolder1_gvImages".*?</table>')
    if (-not $table.Success) { return @() }
    @(
        [regex]::Matches($table.Value, '(?is)<tr[^>]*>\s*<td>(.*?)</td>\s*<td[^>]*>\s*<a[^>]+href="([^"]+)"[^>]*>.*?</a>\s*</td>\s*<td>(.*?)</td>') |
            ForEach-Object {
                $href = [Net.WebUtility]::HtmlDecode($_.Groups[2].Value).Replace('\', '/')
                if ($href -like 'http://web.sos.ky.gov/*') { $href = 'https://' + $href.Substring(7) }
                [pscustomobject]@{
                    type = [Net.WebUtility]::HtmlDecode(($_.Groups[1].Value -replace '<[^>]+>', '').Trim())
                    url = $href
                    pages = [Net.WebUtility]::HtmlDecode(($_.Groups[3].Value -replace '<[^>]+>', '').Trim())
                }
            }
    )
}

$select = [regex]::Match($initial.Content, '(?is)<select[^>]+id="ContentPlaceHolder1_ddlDistricts".*?</select>')
if (-not $select.Success) { throw 'Kentucky SOS tax-district selector was not found.' }
$districts = @(
    [regex]::Matches($select.Value, '<option(?: selected="selected")? value="([^"]+)">(.*?)</option>') |
        ForEach-Object {
            [pscustomobject]@{
                district_id = $_.Groups[1].Value
                selector_name = [Net.WebUtility]::HtmlDecode(($_.Groups[2].Value -replace '<[^>]+>', '').Trim())
            }
        } |
        Where-Object district_id -ne '-10'
)

$baseBody = @{
    '__EVENTTARGET' = 'ctl00$ContentPlaceHolder1$ddlDistricts'
    '__EVENTARGUMENT' = ''
    '__LASTFOCUS' = ''
    '__VIEWSTATE' = Get-HiddenValue '__VIEWSTATE'
    '__VIEWSTATEGENERATOR' = Get-HiddenValue '__VIEWSTATEGENERATOR'
    '__EVENTVALIDATION' = Get-HiddenValue '__EVENTVALIDATION'
}

$rows = [Collections.Generic.List[object]]::new()
for ($index = 0; $index -lt $districts.Count; $index++) {
    $district = $districts[$index]
    Write-Progress -Activity 'Kentucky SOS occupational-tax extraction' -Status "$($index + 1) / $($districts.Count): $($district.selector_name)" -PercentComplete ((($index + 1) / $districts.Count) * 100)
    $body = @{} + $baseBody
    $body['ctl00$ContentPlaceHolder1$ddlDistricts'] = $district.district_id
    $response = $null
    for ($attempt = 1; $attempt -le 3 -and -not $response; $attempt++) {
        try {
            $response = Invoke-WebRequest -UseBasicParsing -WebSession $session -Method Post -Uri $sourceUrl -Body $body
        } catch {
            if ($attempt -eq 3) { throw }
            Start-Sleep -Milliseconds (250 * $attempt)
        }
    }

    $images = @(Get-ImageRecords $response.Content)
    $rows.Add([pscustomobject]@{
        district_id = $district.district_id
        selector_name = $district.selector_name
        tax_district_name = Get-SpanValue $response.Content 'ContentPlaceHolder1_FvDetails_TaxDistrictNameLabel'
        ordinance = Get-SpanValue $response.Content 'ContentPlaceHolder1_FvDetails_OrdinanceLabel'
        city = Get-SpanValue $response.Content 'ContentPlaceHolder1_FvDetails_CityLabel'
        county = Get-SpanValue $response.Content 'ContentPlaceHolder1_FvDetails_CountyLabel'
        net_profits_or_gross_receipts = Get-SpanValue $response.Content 'ContentPlaceHolder1_fvDetail_LblGross'
        tax_rate_text = Get-SpanValue $response.Content 'ContentPlaceHolder1_fvDetail_LblRate'
        minimum_tax = Get-SpanValue $response.Content 'ContentPlaceHolder1_fvDetail_LblMin'
        cap = Get-SpanValue $response.Content 'ContentPlaceHolder1_fvDetail_LblCap'
        public_notes = Get-SpanValue $response.Content 'ContentPlaceHolder1_fvDetail_PublicNotesLabel'
        ordinance_urls = @($images | Where-Object type -eq 'Ordinance' | Select-Object -ExpandProperty url) -join ' | '
        tax_form_urls = @($images | Where-Object type -eq 'Tax Form' | Select-Object -ExpandProperty url) -join ' | '
        other_document_urls = @($images | Where-Object type -notin @('Ordinance', 'Tax Form') | Select-Object -ExpandProperty url) -join ' | '
        source_page_url = $sourceUrl
        retrieved_at = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    })
}
Write-Progress -Activity 'Kentucky SOS occupational-tax extraction' -Completed

$outputDirectory = Split-Path -Parent $OutputCsv
[IO.Directory]::CreateDirectory($outputDirectory) | Out-Null
$rows | ConvertTo-Csv -NoTypeInformation | Set-Content -LiteralPath $OutputCsv -Encoding utf8NoBOM

$initialBytes = [Text.Encoding]::UTF8.GetBytes($initial.Content)
$summary = [ordered]@{
    source_url = $sourceUrl
    retrieved_at = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    source_page_sha256 = [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($initialBytes)).ToLowerInvariant()
    district_count = $rows.Count
    city_labeled_district_count = @($rows | Where-Object city).Count
    payroll_rate_text_count = @($rows | Where-Object tax_rate_text).Count
    ordinance_document_count = @($rows | Where-Object ordinance_urls).Count
    tax_form_document_count = @($rows | Where-Object tax_form_urls).Count
    output_csv_sha256 = (Get-FileHash -LiteralPath $OutputCsv -Algorithm SHA256).Hash.ToLowerInvariant()
}
$summary | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $SummaryJson -Encoding utf8NoBOM
$summary | ConvertTo-Json -Depth 5
