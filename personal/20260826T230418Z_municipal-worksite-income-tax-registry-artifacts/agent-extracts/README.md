# Ohio and Pennsylvania Local Earned-Income Tax Extracts

Snapshot date: **2026-08-25**. Retrieval timestamp: **2026-08-26T00:02:05Z**.

These files are research artifacts for HelixOS Issue #1280. They do not map postal city names to legal tax jurisdictions, do not alter HelixOS, and do not update the issue.

## Deliverables

- `ohio_finder_manifest_snapshot.json`: Ohio Finder municipality/download manifest with retrieval metadata.
- `ohio_current_positive_municipal_rates.csv`: 667 current positive municipal-income-tax rates, one row per official municipal FIPS code.
- `ohio_current_jedd_jedz_rates.csv`: 153 current positive JEDD/JEDZ rates, kept separate from municipal corporations.
- `pennsylvania_official_register_normalized.jsonl`: June 15, 2026 Official Register normalized to 2,619 unique PSD codes.
- `pennsylvania_realtime_register_normalized.jsonl`: nightly Real-Time Register snapshot normalized to 2,619 unique PSD codes.
- `pennsylvania_current_in_scope_positive_municipal_eit.csv`: 2,536 directly in-scope municipal EIT rows: 1,978 work-location/nonresident positives and 558 resident-only positives.
- `pennsylvania_official_to_realtime_changes.csv`: five changed fields across two PSD codes between the June 15 official and August 25 real-time snapshots.
- `pennsylvania_philadelphia_overlay.json`: direct City of Philadelphia corroboration. The city rates match the real-time register; the overlay must not create a second tax row.
- `validation_summary.json`: counts, reconciliation checks, URLs, byte sizes, and SHA-256 hashes.
- `sources/`: exact downloaded source files plus UTF-8 CSV conversions of the two DCED XLS registers.

## Normalization and scope rules

### Ohio

- Current means `effective_start <= 2026-08-25 <= effective_end` and rate greater than zero.
- Rates use explicit `rate_percent` and `rate_fraction` fields. The source municipal table stores fractions; the JEDD/JEDZ table stores percentage points.
- The current positive municipal table joins one-to-one to the official municipal FIPS table. Validation found zero duplicate current FIPS keys and zero unmatched current rate rows.
- The official FIPS table contains 1,057 entities; 390 have no current positive municipal-income-tax rate and are not positive rows.
- JEDD/JEDZ records are separate non-municipal employment-zone records. `zone_type_from_official_name` uses only the literal official name; values without either suffix are marked `JEDD_JEDZ_UNSPECIFIED`.

### Pennsylvania

- Official source rows: 2,627. Unique PSD codes: 2,619. Eight PSD codes appear twice because the legal municipality crosses county/reporting rows; duplicate rows are collapsed by PSD while preserving all counties and municipality IDs.
- `municipality_type_from_official_suffix` is parsed only from the literal `TWP`, `TOWNSHIP`, `BORO`, `BOROUGH`, `CITY`, or `TOWN` suffix in the official register. It is not a postal-city inference.
- `MUNICIPAL_EIT_WORK_LOCATION` requires positive Municipal Nonresident EIT. `MUNICIPAL_EIT_RESIDENT_ONLY` requires positive Municipal Resident EIT with zero Municipal Nonresident EIT.
- Eight `SCHOOL_DISTRICT_EIT_ONLY` PSD rows and 75 `NO_EIT_POSITIVE` PSD rows remain in the normalized registers but are excluded from the in-scope municipal-positive CSV.
- Municipal EIT, school-district EIT, school-district PIT, and total resident income tax are preserved separately. Validation reconciled `municipal resident EIT + school district EIT + school district PIT = total resident income tax` for all 2,619 PSD rows; the total is never treated as an additional municipal tax.
- Municipal and school-district LST amounts and collectors are preserved as separate flat-tax categories. They do not create municipal EIT positives.
- The Real-Time Register changes from the June 15 Official Register are: PSD `360999` Municipal LST and Total LST from $47 to $52; PSD `510101` Philadelphia resident, nonresident, and total rates from 3.74/3.43/3.74 to 3.735/3.425/3.735 percent.

## Official sources and source hashes

| Source file | Official URL | SHA-256 |
|---|---|---|
| `ohio_finder_manifest.json` | https://thefinder.tax.ohio.gov/api/file-downloads?type=municipality | `0ced83f225f950d20dd6c818ee75a86abea7f986139c99eb2de665d8792fba11` |
| `ohio_municipal_rate_table.csv` | https://api.thefinder.tax.ohio.gov/finder/api/v1/tax-rates/downloads/Muni/OHMuniRateTable.csv | `7d88442ea6c503ccd45a375fa17fc902d0181d510df3ed2b501dc8bf26f4b17d` |
| `ohio_municipal_fips.csv` | https://api.thefinder.tax.ohio.gov/finder/api/v1/tax-rates/downloads/OHMuniFIPSCodes.txt | `e7c6f83d7eaff12a6ec238565d303984b8fb3a6cfe083dcfaf8896e73af83d94` |
| `ohio_jedd_jedz_rates.csv` | https://api.thefinder.tax.ohio.gov/finder/api/v1/tax-rates/downloads/JEDTaxRates.csv | `c8bb486ace2e7f0c16804d31f4ad40ed28bd7c104948507816928a4f02f89184` |
| `pennsylvania_official_register_2026.xls` | https://apps.dced.pa.gov/munstats-public/ReportToPdf.aspx?report=EitWithCollector_Dyn_Excel&paramList=O;2026 | `797f1298522a95da0591fdc308e193f426bb965670cd843f192904892788fa75` |
| `pennsylvania_realtime_register_2026.xls` | https://apps.dced.pa.gov/munstats-public/ReportToPdf.aspx?report=EitWithCollector_Dyn_Excel&paramList=R;2026 | `adb95d68cc3e783ca82f0109c92f46e377d01b2f36aba1feacca11d422bc227e` |

DCED source pages:

- Official Register, rates as of June 15, 2026: https://apps.dced.pa.gov/munstats-public/ReportInformation2.aspx?report=EitWithCollector_Dyn_Excel&type=O
- Real-Time Register, refreshed nightly and up to 24 hours old: https://apps.dced.pa.gov/munstats-public/ReportInformation2.aspx?report=EitWithCollector_Dyn_Excel&type=R
- Philadelphia Wage Tax, rates effective July 1, 2026: https://www.phila.gov/services/business-self-employment/business-taxes/wage-tax-employers/

## Output hashes

| Output | SHA-256 |
|---|---|
| `ohio_finder_manifest_snapshot.json` | `9f5da3f2c6e1b73a3e8215cddd46a2720e932da09e98cb1c4dd8580237ccd049` |
| `ohio_current_positive_municipal_rates.csv` | `59512f1bfb48b8950c8ba251c9698ece57fb18c77f2139426e349aa7d92c2e49` |
| `ohio_current_jedd_jedz_rates.csv` | `e378318e5de859b404e76a40bca5cbad08313458a9578633aa1ef04d7c153679` |
| `pennsylvania_official_register_normalized.jsonl` | `b6112e73e6507c655f2bab8de38284b7015aaa957f7f6afb2b563e481a193d83` |
| `pennsylvania_realtime_register_normalized.jsonl` | `f99fee055355bd5e0cbbf984eb9ded7b655956f5a8c5b84d4e82f15294e2a979` |
| `pennsylvania_current_in_scope_positive_municipal_eit.csv` | `4e2d3cf6ec1a74d9a5f78627b6dfea22b2925392c0c96ca52a1e8df2da1d931c` |
| `pennsylvania_official_to_realtime_changes.csv` | `862384ca4c949a4f1ee3ab22b33c3545ef72919a09000bc1167b9b34327e1645` |
| `pennsylvania_philadelphia_overlay.json` | `5bd1bfb41dd367310349a42e8fb1c87d2f4e3865c2342eeafe1e03eb92e30812` |

West Virginia is not extracted because Phase 1 did not locate a current complete official adopter/non-adopter registry for the conditional pension-relief municipal occupational tax.
