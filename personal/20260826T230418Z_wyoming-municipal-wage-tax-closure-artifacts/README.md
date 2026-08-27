# Wyoming municipal wage-tax closure evidence

This directory supports the August 26, 2026 conclusion that Wyoming has zero municipalities with authority to impose an in-scope worksite employee wage tax. The state is `NO_AUTHORITY_CONFIRMED`.

## Preserved sources

- `Wyoming-current-statutes-index.html` — current official statutes landing page.
- `Wyoming-current-code-titles.zip` — official current statutory Titles 1 through 42 and Constitution Title 97, plus extracted text for each.
- `current-code-download-audit.csv` — source URL, status, byte count, and SHA-256 for all 43 official PDFs.
- `current-code-file-manifest.csv` — source URL, page count, byte count, and SHA-256 for every PDF and extracted text file before compression.
- `current-code-search-audit.json` — complete phrase counts, contexts, per-file metadata, and corpus totals.
- `manual-hit-dispositions.md` — manual disposition of every nonzero or proximity search hit.
- `source-extracts.md` — controlling statutory and constitutional excerpts and interpretation boundaries.
- `extract-and-audit-current-code.py` — extraction and search script.
- `artifact-manifest.csv` — byte count and SHA-256 for the final evidence package.

## Method

The audit retrieved `title01.pdf` through `title42.pdf` and Constitution `title97.pdf` from the official Wyoming Legislature download path. All 43 responses were verified as PDFs. The corpus contains 12,429 pages, 35,769,599 PDF bytes, and 25,245,201 extracted characters.

Exact searches covered income, earnings, wage, payroll, compensation, employee, and occupational-tax terminology, plus a municipal/employee/compensation proximity screen. Every nonzero hit was manually reviewed. The audit confirmed the express statewide preemption in section 39-12-101 and found no qualifying exception or adopter.
