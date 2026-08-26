# Utah municipal wage-tax closure evidence

This directory supports the August 26, 2026 conclusion that Utah municipalities have no current authority to impose an in-scope worksite employee wage tax. The state is `NO_AUTHORITY_CONFIRMED` with zero registry rows.

## Preserved sources

- `Utah-Code-current-index.html` — official index used to select one current version for each Utah Code title.
- `Utah-Constitution-current.pdf` and `Utah-Constitution-Article-XI-current.pdf` — official current constitutional text.
- `Utah-Publication-14-April-2026.pdf` and `.txt` — current official withholding guide and extracted text.
- `Utah-Tax-Commission-Withholding-current.html` and `Utah-Publication-14-current.html` — current Tax Commission pages.
- `Utah-current-code-titles.zip` — the 96 official current title PDFs and their 96 extracted text files.
- `current-code-download-audit.csv` — title, selected current-version URL, status, and byte count for every title.
- `current-code-file-manifest.csv` — source URL, page count, byte count, and SHA-256 for every PDF and extracted text file before compression.
- `current-code-search-audit.json` — complete phrase counts, contexts, per-file metadata, and corpus totals.
- `manual-hit-dispositions.md` — manual disposition of every nonzero or proximity search hit.
- `source-extracts.md` — controlling legal excerpts and interpretation boundaries.
- `extract-and-audit-current-code.py` — extraction and search script.
- `artifact-manifest.csv` — byte count and SHA-256 for the final evidence package.

## Method

The official current-code index was parsed to identify one current version of every title. Future-effective duplicate versions were not selected. All 96 selected title PDFs returned status 200 and were extracted with `pypdf`.

The corpus contains 19,339 pages, 37,553,810 PDF bytes, and 56,391,062 extracted characters. Exact phrase searches covered `wage tax`, `earnings tax`, `payroll tax`, `compensation tax`, `municipal income tax`, `city income tax`, `local income tax`, and `political subdivision income tax`, plus a municipal/employee/compensation proximity screen. Every nonzero hit was manually reviewed.

The statutory result was reconciled to article XI, section 5, the Utah Supreme Court's municipal-tax rule in *Moss*, current section 10-1-203, current section 59-10-402, and the April 2026 Utah Withholding Tax Guide. No qualifying delegation, tax, or adopter was found.
