# South Dakota municipal wage-tax closure evidence

This directory supports the August 26, 2026 conclusion that South Dakota has zero current municipalities imposing an in-scope worksite employee wage tax. The state is `COMPLETE`, not `NO_AUTHORITY_CONFIRMED`, because broad non-ad-valorem and home-rule language remains in current law.

## Preserved sources

- `South-Dakota-Constitution-current.html` — official consolidated Constitution, including article IX, section 2.
- `SDCL-6-12-current.html` — official current home-rule chapter, including the local taxing-power restriction in sections 6-12-14 and 6-12-15.
- `SDCL-10-52-current.html` — official current Uniform Municipal Non-Ad Valorem Tax Law.
- `SDCL-10-43-current.html` — official current financial-institution income-tax chapter.
- `SD-DOR-Municipal-Tax-2026.html` — current DOR municipal-tax page.
- `SD-DOR-Municipal-Tax-Guide-July-2026.pdf` and `.txt` — current DOR guide and extracted text.
- `South-Dakota-current-code-titles.zip` — all 63 official consolidated title files scanned in the iteration.
- `current-code-file-manifest.csv` — source URL, byte count, and SHA-256 for every consolidated title file before compression.
- `current-code-search-audit.json` — exact search counts and disposition of every potentially relevant phrase.
- `source-extracts.md` — controlling excerpts and interpretation boundaries.
- `artifact-manifest.csv` — byte count and SHA-256 for the final evidence package.

## Method

The audit retrieved `https://sdlegislature.gov/api/Statutes/{title}.html?all=true` for Constitution title `0N` and codified-law titles 1 through 62. All 63 requests returned an official consolidated title document. The raw corpus totaled 176,375,083 bytes and is preserved as a ZIP with a per-title hash manifest.

Exact phrase searches covered `wage tax`, `earnings tax`, `payroll tax`, `compensation tax`, `municipal income tax`, `city income tax`, and `local income tax`. The only three nonzero hits were inspected and rejected as unrelated to municipal employee-wage authority.

The statutory audit was then reconciled to the July 2026 DOR municipal-tax guide and the chapter 10-52 advance-notice/administration topology. No qualifying adopter or tax category was found.
