# Colorado municipal wage-tax closure evidence

This directory supports the August 26, 2026 conclusion that Colorado has zero municipalities with authority to impose an in-scope worksite employee wage tax. The state is `NO_AUTHORITY_CONFIRMED`.

## Preserved sources

- `Colorado-2026-CRS-titles-index.html` — official page for the 2026 Colorado Revised Statutes release.
- `Colorado-Constitution-2026.pdf` and `.txt` — current official constitution and page-marked extraction.
- `Colorado-Legislative-Drafting-Manual-current.pdf` and `.txt` — official legislative manual and page-marked extraction.
- `Glendale-OPT-current.html`, `Greenwood-Village-OPT-current.html`, and `Sheridan-OPT-current.html` — current official municipal descriptions of excluded flat employee occupational taxes.
- `source-extracts.md` — constitutional provisions, controlling-case holdings, flat-tax classification, source URLs, and download limitation.
- `extract-pdfs.py` — deterministic page-marked PDF extraction script.
- `source-file-manifest.csv` — source URL, byte count, and SHA-256 for the downloaded official files.
- `artifact-manifest.csv` — byte count and SHA-256 for the final evidence package.

## Method

The audit reviewed the current official constitution, the Office of Legislative Legal Services' current drafting manual, four controlling Colorado Supreme Court decisions, and current municipal examples of employee occupational privilege taxes.

The legal topology closes the state without a municipality-by-municipality charter audit. Article X, section 17, as interpreted by *Sweet* and reaffirmed in *Duffy*, places income-tax power exclusively in the General Assembly. Article X, section 20(8)(a) now expressly prohibits local district income taxes, with district defined to include local government. *Johnson* distinguishes a valid flat occupational fee from a prohibited income tax precisely because the flat fee is not measured by wages or salary. *Rountree* leaves that state-law distinction intact.

Therefore a municipality cannot impose the percentage or graduated wage-based employee tax required by the registry definition. Current flat monthly occupational taxes are excluded rather than omitted positives.

