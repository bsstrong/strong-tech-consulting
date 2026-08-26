# West Virginia Municipal Wage-Tax Closure Evidence

This directory preserves the source documents and the complete structured pension-plan result used to close West Virginia on August 25, 2026.

## Files

| File | Purpose | Bytes | SHA-256 |
| --- | --- | ---: | --- |
| `2026-WVSCPA-Guidebook-Chapter-10.docx` | Current statewide tax-practitioner guide; reports zero pension-relief occupation-tax adopters as of January 1, 2026 and lists flat municipal user fees. | 93,633 | `A53B1901935088A82742251D21E5140398D2397FB2F40CF7466A9298544522DB` |
| `MPOB-Consolidated-Actuarial-Report-2024.pdf` | Latest posted complete consolidated valuation of the 53 legacy municipal police/fire plans, valued July 1, 2024 with FYE 2026 contributions. | 1,367,123 | `5419210C33F39C6C6507134051E52DF92A8DA76A258D2F22C61B6295387BBEE8` |
| `MPOB-2024-individual-plan-funded-ratios.csv` | Extract of all 53 individual MVA/AVA funded ratios from report pages 13–21 (PDF pages 18–26). | 1,642 | `353F95206F1228C6D972F8E83C61951D98E7E4B8336EDB1A881D0510F33012DC` |
| `MPOB-GASB-2025/` | All 53 official plan-level GASB reports for the June 30, 2025 measurement period. Per-file URLs, sizes, page counts, and hashes are in the 2025 CSV. | 30,225,101 | Per-file hashes in CSV |
| `MPOB-2025-individual-plan-funded-ratios.csv` | Complete 31-police/22-fire current result with funded percentage and source provenance for every plan. | 13,355 | `49B096F9F392E3346F1D3B4BE35E659D8A2C260F8E4359B932E3797A11EEC274` |
| `extract-wv-mpob-gasb-2025.py` | Reproducible downloader, 53-plan completeness check, PDF extraction, and provenance generator. | 4,317 | `01B1389DCFDC2CD52CC36AD3870C4A302BF928C8257FD7E03F336C58AE8FAD61` |
| `west-virginia-closure-validation.json` | Machine-readable closure result, statewide plan counts, minimums, registry effect, and refresh triggers. | 2,059 | `B574AF1C669768EE7F32F0C8B70A7C7AB08F23505FBCBE5A19D8223D75235C64` |
| `evidence-file-manifest.csv` | Relative path, byte count, and SHA-256 hash for every other file in this evidence directory. | Generated last | Excludes itself |
| `WV-Code-Article-8-13C.pdf` | Current official Article 13C text covering qualification, the occupational tax, activation, proceeds, termination, and related pension authority. | 84,140 | `79AA9C4A77A1252D5E727CF859F681749EB3BA4ECEE0BEC815EC134F9149BDB9` |
| `WV-Code-8-1-5a.pdf` | Current official Home Rule statute, including taxation, pension, and nonresident occupation-tax restrictions. | 58,661 | `C196C1FAB72AEE1C173C808FEFCCC58B6C39D3BB6E6C84CE07B428C4B7C08DF7` |
| `WV-Municipal-Home-Rule-2025-Annual-Report.pdf` | January 1, 2026 statewide inventory of Home Rule participants, proposals, and implementation status. | 724,821 | `1A883484411B8286A966D117CCAA6724A2D7B992D8842012EA210FB6759A3943` |
| `WV-Home-Rule-2012-Legislative-Auditor.pdf` | Official historical evidence that Huntington's proposed 1% occupation tax was enjoined and never implemented. | 494,719 | `CFDBC5B48CE828E63417495FA2BE69BB82541EB73B0D60A4A5C58DB9D6E1958A` |

## Source URLs

- WVSCPA 2026 guidebook landing page: <https://www.wvscpa.org/resources/public-resources/guidebook-to-wv-taxes>
- WVSCPA Chapter 10: <https://www.wvscpa.org/storage/assets/2026%20Guidebook%20to%20WV%20Taxes/2026%20-%20GBWVT%20Chapter%2010%20(Miscellaneous%20Taxes)%20(FINAL)%20-%204905-4978-4194.1.docx>
- Current Article 13C: <https://code.wvlegislature.gov/pdf/8-13C/>
- Current Home Rule statute: <https://code.wvlegislature.gov/pdf/8-1-5A/>
- MPOB actuarial reports: <https://mpob.wv.gov/actuarialreports/Pages/default.aspx>
- MPOB source PDF: <https://mpob.wv.gov/actuarialreports/SiteAssets/Pages/default/Consolidated%20Actuarial%20Report%202024.pdf>
- MPOB 53-plan list: <https://mpob.wv.gov/about/Pages/53-Pension-Plans.aspx>
- MPOB municipality results: source page and direct report URL for each plan are preserved in `MPOB-2025-individual-plan-funded-ratios.csv`.
- 2025 Home Rule report: <https://www.wvlegislature.gov/legisdocs/reports/agency/M23_CY_2025_26930.pdf>
- 2012 Legislative Auditor report: <https://www.wvlegislature.gov/Joint/PERD/perdrep/HomeRule_11_2012.pdf>

## Extraction and verification

The 2025 extraction began with the complete 53-plan table, retrieved each plan's official GASB 2025 report from its MPOB municipality-results page, verified exactly 31 unique police and 22 unique fire plans, and extracted the June 30, 2025 fiduciary-net-position percentage. All 53 reports have the same measurement date; the minimum is St. Albans Fire at 12.40%, and no plan is at or below 3%. The minimum report's cover and result page were rendered with Poppler and visually checked.

The consolidated 2024 CSV was independently extracted from PDF pages 18–26 with `pdfplumber`. It contains exactly the same 53 plan rows. Both MVA and AVA funded-ratio series have a 12% minimum. The relevant tables, including the minimum rows on PDF page 24, were rendered and visually inspected. The historical Huntington pages and the current Home Rule Huntington table were also rendered and visually checked.

The 2026 WVSCPA Chapter 10 text was read from the DOCX XML. The adopter conclusion and the flat-fee table were preserved in the closure report without treating the professional guide as a substitute for the controlling statutes.

## Related results

- [West Virginia closure report](../20260826T044944Z_west-virginia-municipal-wage-tax-closure.md)
- [Updated national snapshot](../20260826T044944Z_municipal-worksite-income-tax-registry-artifacts/README.md)
