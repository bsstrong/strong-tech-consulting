# Kentucky Local Occupational-Tax Verification — August 27, 2026

## Outcome

Every one of the 159 Kentucky KLC association-supported rows was assessed against current municipal, municipal-code, delegated-collector, or Kentucky Secretary of State material.

- 98 former KLC-only rows were promoted to `CONFIRMED_PRIMARY`.
- 61 KLC rows remain `SUPPORTED_AUTHORITATIVE_ASSOCIATION`.
- Falmouth and Hurstbourne Acres were added as `SUPPORTED_CURRENT_SECONDARY`; both remain `UNDETERMINED` for product use pending the enacted payroll ordinance or an official withholding form.
- Salem is not current. Ordinance 2026-05 creates a 1% employee-compensation tax but is expressly effective October 1, 2026.
- Kentucky now has 172 best-available current rows: 109 direct primary, 61 association-supported, and 2 current-secondary-supported.
- Kentucky remains `PARTIAL`; no single current official source is both complete and error-free for the municipal adopter/rate universe.

## Direct-primary promotions

Adairville, Alexandria, Ashland, Auburn, Augusta, Bardstown, Beattyville, Bellevue, Berea, Bromley, Brownsville, Calvert City, Camargo, Campbellsville, Catlettsburg, Clarkson, Clinton, Coal Run Village, Cold Spring, Corbin, Crescent Springs, Crestview Hills, Cynthiana, Danville, Dayton, Edgewood, Elizabethtown, Elsmere, Erlanger, Florence, Fort Mitchell, Fort Thomas, Fort Wright, Frankfort, Gamaliel, Georgetown, Glasgow, Grayson, Hartford, Hazard, Hillview, Hodgenville, Hopkinsville, Horse Cave, Independence, Jeffersontown, Jeffersonville, LaGrange, Lakeside Park, Lebanon Junction, Leitchfield, Lewisburg, Ludlow, Madisonville, Mayfield, Maysville, McKee, Middlesboro, Midway, Millersburg, Morehead, Morgantown, Mount Olivet, Mount Vernon, Murray, Newport, Oak Grove, Owensboro, Owenton, Paris, Park Hills, Pineville, Pioneer Village, Prestonsburg, Princeton, Richmond, Russell, Russell Springs, Ryland Heights, Saint Matthews, Scottsville, Shelbyville, Shepherdsville, Simpsonville, Smiths Grove, Somerset, Southgate, Stanton, Taylor Mill, Taylorsville, Vanceburg, Versailles, Villa Hills, Vine Grove, Warsaw, West Liberty, West Point, and Wilder.

The row-level source URLs, rates, effective dates, and limitations are in `kentucky-primary-verification.csv` and the final CSV/JSONL registry. Fifteen promotions use a conservative exact-match rule: the current Secretary of State repository displays the same percentage as the KLC payroll column and retains a local ordinance or form; conflicting, blank, net-profit, business-schedule, or future-dated displays were not promoted by that rule.

## Remaining association-supported rows

Barbourville, Bardwell, Benton, Brodhead, Brooksville, Burkesville, Cadiz, Carlisle, Cave City, Clay City, Columbia, Crab Orchard, Dawson Springs, Dry Ridge, Earlington, Eddyville, Edmonton, Elkhorn City, Elkton, Eminence, Flemingsburg, Fordsville, Fountain Run, Franklin, Fulton, Greensburg, Greenup, Guthrie, Harrodsburg, Hebron Estates, Hickman, Highland Heights, Jackson, Jamestown, Jenkins, Junction City, Lancaster, Marion, Mount Washington, Muldraugh, Munfordville, Nortonville, Paintsville, Park City, Perryville, Pikeville, Prestonville, Raceland, Radcliff, Russellville, Salyersville, Shively, Silver Grove, Springfield, Stanford, Tompkinsville, Union, Williamsburg, Wilmore, Winchester, and Wurtland.

These rows stay `UNDETERMINED` until a controlling current local source closes rate, employee-payroll incidence, worksite/nonresident scope, withholding, and effective status. Specific rate conflicts requiring priority follow-up include:

| Municipality | Existing KLC/registry rate | Newer or conflicting indication | Disposition |
|---|---:|---:|---|
| Bardwell | 0.5% | 1% reported effective July 1, 2025 | Retain 0.5% association row; obtain primary local instrument. |
| Paintsville | 1.5% | SOS display 1.25% | Do not choose between conflicting sources without local payroll instrument. |
| Perryville | 1.5% | SOS display 1% | Do not choose between conflicting sources without local payroll instrument. |
| Raceland | 1% | SOS display 1.5% | Do not choose between conflicting sources without local payroll instrument. |
| Shively | 2% | SOS display 1.5%; city material also references 2% | Retain unresolved pending the latest controlling ordinance/form. |
| Springfield | 1% | SOS display 1.5% | Do not choose between conflicting sources without local payroll instrument. |
| Winchester | 2.15% | SOS display 2% | Do not choose between conflicting sources without local payroll instrument. |

## New current candidates

### Falmouth

The [current city page](https://cityoffalmouth.com/occupational-license/) says Falmouth adopted a new occupational ordinance on May 7, 2026, but the public page describes a graduated business-license schedule rather than employee payroll terms. Dated reporting identifies a 1.5% employee payroll tax effective July 1, 2026. The registry adds a `SUPPORTED_CURRENT_SECONDARY` row but does not promote it until the enacted payroll ordinance or official employer return is retained.

### Hurstbourne Acres

Current payroll publications identify a 1% city occupational tax effective July 1, 2024. The [current city treasurer page](https://www.hurstbourneacresky.gov/treasurer) has a document widget, but it did not expose the enacted payroll ordinance during this pass. The registry adds a `SUPPORTED_CURRENT_SECONDARY` row and keeps it `UNDETERMINED` pending the local ordinance or official employer return.

## Salem future-dated change

The Secretary of State repository provides [Ordinance 2026-05](https://web.sos.ky.gov/occupationaltaxes/245-1337.pdf) and tax forms. The ordinance imposes 1% on compensation for work in Salem, covers employer withholding, and states in section 14 that it is effective October 1, 2026. It is excluded from the August 27 current registry and retained in the future-dated review queue.

## Current rate corrections

| Municipality | Previous value | Current value | Current basis |
|---|---:|---:|---|
| Ashland | 2% | 2.375% | City enactment effective January 1, 2026. |
| Augusta | 1.25% | 1.3% | Current municipal code. |
| Campbellsville | 1% | 1.5% | Current delegated administrator, effective January 1, 2026. |
| Covington | 2.5% | 2.45% | Official July-December 2026 Kenton County schedule. |
| Dayton | 2.5% | 2% | Official 2026 Campbell County schedule. |
| Elsmere | 1.25% | 1.75% | Official notice and July-December 2026 schedule, effective July 1, 2026. |
| Hodgenville | 0.75% | 1% | Current municipal code. |
| Jeffersonville | 1% | 2% | Current Montgomery County official guidance; retain city-form follow-up for archival durability. |

## Secretary of State repository audit

The reproducible extractor captured 227 tax-district entries from the current [Kentucky Secretary of State repository](https://web.sos.ky.gov/occupationaltax/): 176 displayed rate text, 214 linked an ordinance document, and 222 linked a tax form. The structured snapshot is `kentucky-sos-occupational-tax-districts-2026-08-27.csv`; validation and the source-page hash are in the adjacent JSON file.

The repository is valuable primary evidence under KRS 67.766, but it is not a stand-alone closed current city-payroll registry. It contains counties, schools, net-profit-only displays, ambiguous business schedules, stale fields, and at least one future-dated ordinance (Salem), while omitting some demonstrably active cities. Its own page warns of omissions or inaccuracies. No row was removed merely because it was absent from the selector.
