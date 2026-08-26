# Idaho municipal wage-tax closure evidence

This evidence set supports the August 26, 2026 Idaho closed-zero determination under the national registry's narrow worksite-based employee wage-tax definition.

## Result

Idaho is `NO_AUTHORITY_CONFIRMED`. Municipal taxing power requires specific legislative authorization, and the complete current Idaho Code corpus contains no qualifying authorization. No Idaho municipality is added to the registry.

## Preserved evidence

- `Idaho_Constitution.pdf` - official Secretary of State constitution; article III, section 19 prohibits local/special tax-assessment and collection laws, and article VII, section 6 requires legislative investment of municipal taxing power.
- `Idaho-Code-Title50-Chapter10.pdf` - official current municipal-finance chapter; sections 50-1044 through 50-1049 contain the resort-city local-option nonproperty-tax grant.
- `idaho-code-corpus-manifest.csv` - 1,471 current chapter links discovered through all 74 official title indexes, with byte counts, SHA-256 hashes, PDF validity, and source URLs.
- `idaho-code-corpus-audit.json` - corpus size, search terms, candidate-context dispositions, one dead-link recovery, and the legal conclusion.
- `Idaho-Code-Title44-Chapter28.html` and `Idaho-Code-Title44-SECT44-2801.html` through `-2804.html` - recovery for the single chapter PDF link that returned a 404 page. All four live sections were searched separately and contain no qualifying authorization.
- `Idaho-Tax-Commission-City-Sales-Taxes.html` - current Tax Commission page identifying resort-city sales taxes as Idaho's city local-option taxes and linking Title 50, chapter 10.

## Retrieval and search method

All 74 title indexes at the [Idaho Legislature's current code site](https://legislature.idaho.gov/statutesrules/idstat/) were retrieved. They exposed 1,471 chapter-PDF links. Of those, 1,470 returned valid PDFs and were extracted into 37,192,145 bytes of whitespace-normalized text. The one broken chapter link was recovered from its live chapter page and four live section pages. Exact and proximity searches covered income, wage, earnings, compensation, payroll, withholding, taxing-power, municipal, city, levy, impose, and assess formulations. Every candidate context that combined a municipal term with an income or compensation-tax term was reviewed.

The 105 MB temporary source corpus and derived working text are not duplicated here. The source URL, byte count, and SHA-256 of every chapter response are preserved in the manifest; the legally relevant chapter and dead-link recovery are retained in full.

## Source notes

- The controlling municipal-tax rule was verified in *North Idaho Building Contractors Association v. City of Hayden*, 156 Idaho 721, 329 P.3d 466 (2015), docket 41316-2013. The Idaho Courts legacy PDF URL was broken after the court-site migration during this audit; the current Idaho Courts opinion search and an exact full-opinion republication were cross-checked.
- The Tax Commission page is corroborative, not treated as an exhaustive negative list. The closed-zero result rests on the constitutional topology, controlling case law, and complete current-code search.

## Refresh triggers

Refresh Idaho if article III or VII of the constitution changes, Idaho Code section 50-301 or Title 50 chapter 10 changes, a new general tax delegation is enacted, or Idaho appellate law changes the specific-authorization rule.
