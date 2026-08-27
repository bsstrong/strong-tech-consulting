# U.S. Municipalities With a Worksite-Based Local Income Tax

**Current as of August 27, 2026.**

**Status:** Best-available nationwide research registry. It distinguishes directly confirmed current rows from municipalities found only in authoritative municipal-association surveys. It is not compliance approval and must not be treated as an unqualified “all other cities are clear” list.

For this report, a local or municipal income tax is a tax that a city or similar local government charges on wages earned by people working there, including commuters who live elsewhere. It must be based on employee pay and may require the employer to withhold it. The name does not control: income, earnings, wage, payroll, and occupational taxes can all qualify when they operate this way.

This report does not include taxes based only on where an employee lives, taxes paid only by employers, flat per-worker fees, or taxes imposed by counties, school districts, transit authorities, or other regional bodies. It also excludes taxes on business profits or self-employment and unrelated taxes such as sales, property, and general business-license taxes. Consolidated city governments and other municipal equivalents are included; ordinary county taxes are not.

A municipality is not assumed to be tax-free because it is missing. An unmatched location in a `PARTIAL` or `UNDETERMINED` state remains unresolved.

## Evidence tiers

- `CONFIRMED_PRIMARY` means current municipal or state primary material establishes a qualifying employee-wage tax, a nonresident/worksite rule, and employer-withholding relevance. These are confirmed-positive screening rows, subject to authoritative boundary resolution.
- `SUPPORTED_AUTHORITATIVE_ASSOCIATION` means a statewide municipal association identifies the municipality and a percentage occupational/payroll rate, but the current local ordinance and rate have not been directly verified. These rows make the discovery list more complete, but their product disposition is `UNDETERMINED` until local verification.
- `SUPPORTED_CURRENT_SECONDARY` means current evidence identifies a likely new adopter and rate, but the enacted municipal payroll ordinance or official withholding form has not been retained. These rows remain `UNDETERMINED` and are not product-approved.

## Result

The best-available registry contains **2,817 municipality rows in nine states**. Of those:

- **2,743** are directly confirmed from current primary sources.
- **72** are association-supported discovery rows: 11 in Alabama and 61 in Kentucky.
- **2** are current secondary-supported Kentucky additions pending enacted local payroll instruments.
- **2,619** directly confirmed rows come from states with a closed statewide source or statutory universe.
- **124** directly confirmed rows are in partial-coverage states: Alabama 14, Kentucky 109, and Oregon 1.

The 2,817 number is therefore a best-available screening inventory, not a claim that all 2,817 have individually verified current ordinances and rates.

| State | Best-available rows | Direct primary | Association-supported | Statewide coverage |
|---|---:|---:|---:|---|
| Alabama | 25 | 14 | 11 | `PARTIAL` |
| Delaware | 1 | 1 | 0 | `COMPLETE` |
| Kentucky | 172 | 109 | 61 association + 2 secondary | `PARTIAL` |
| Michigan | 24 | 24 | 0 | `COMPLETE` |
| Missouri | 2 | 2 | 0 | `COMPLETE` |
| New York | 1 | 1 | 0 | `COMPLETE` |
| Ohio | 666 | 666 | 0 | `COMPLETE` |
| Oregon | 1 | 1 | 0 | `PARTIAL` |
| Pennsylvania | 1,925 | 1,925 | 0 | `COMPLETE` |
| **Total** | **2,817** | **2,743** | **72 association + 2 secondary** |  |

The complete row-level list is provided as [CSV](worksite-municipal-income-tax-registry.csv) and [JSONL](worksite-municipal-income-tax-registry.jsonl). Each row carries its evidence status, rate, scope, withholding field, source URLs, source date, limitation, and product disposition. [Validation results](worksite-municipal-income-tax-registry-validation.json) contain the reconciliation, uniqueness checks, evidence-tier counts, and hashes.

The [product-readiness audit](product-readiness-audit-2026-08-27.md) concludes that this package can support a governed three-result screening workflow, but is not an autonomous approved-city list or payroll-calculation table. Authoritative worksite-boundary resolution, an approved direct-primary data view, and release/approval metadata remain prerequisites.

## Included jurisdictions by state

### Alabama — 25 best-available rows; coverage partial

Direct current primary confirmation exists for:

- Auburn
- Birmingham
- Gadsden
- Glencoe
- Opelika
- Bessemer
- Fairfield
- Guin
- Haleyville
- Hamilton
- Leeds
- Midfield
- Rainbow City
- Tuskegee

The [Alabama League of Municipalities occupational-tax survey](https://almonline.org/VirtualPageTemplate.aspx?PageID=3f384f8c-dd06-4beb-8cd2-1353aaad9414) still supplies 11 percentage-tax candidates that could not be fully closed from current municipal primary material:

- Attalla
- Bear Creek
- Brilliant
- Goodwater
- Hackleburg
- Lynn
- Mosses
- Red Bay
- Shorter
- Southside
- Sulligent

The League states that the rates were supplied by survey, disclaims their accuracy, and requires verification with the locality. Attalla, Hackleburg, Mosses, Shorter, Southside, and Sulligent have additional current collector or municipal-form evidence for rate and withholding, but the accessible primary material does not close the worksite/nonresident incidence rule. Bear Creek, Brilliant, Goodwater, Lynn, and Red Bay remain association-only. All 11 retain `SUPPORTED_AUTHORITATIVE_ASSOCIATION` and `UNDETERMINED` product disposition.

The verification corrected two stale League rates: Opelika is **1%** effective April 1, 2025, and Tuskegee is **3%**, not 2%. Alabama remains `PARTIAL` because no authoritative current statewide source closes the adopter universe. The complete August 27 municipality-by-municipality disposition is preserved in [the Alabama verification report](agent-extracts/alabama-local-verification-2026-08-27.md).

### Delaware — 1; coverage complete

- Wilmington

[Delaware law](https://delcode.delaware.gov/title22/c009/index.html) limits municipal earned-income-tax authority to municipalities above the statutory population threshold. Wilmington is the only current municipality in that universe and reaches compensation for services performed in the city by nonresidents as well as residents.

### Kentucky — 172 best-available current rows; coverage partial

Direct current primary confirmation now exists for **109** municipalities. The August 27 pass promoted 98 former KLC-only rows; the complete promoted set is:

- Adairville, Alexandria, Ashland, Auburn, Augusta, Bardstown, Beattyville, Bellevue, Berea, Bromley, Brownsville, Calvert City, Camargo, Campbellsville, Catlettsburg, Clarkson, Clinton, Coal Run Village, Cold Spring, Corbin, Crescent Springs, Crestview Hills, Cynthiana, Danville, Dayton, Edgewood, Elizabethtown, Elsmere, Erlanger, Florence, Fort Mitchell, Fort Thomas, Fort Wright, Frankfort, Gamaliel, Georgetown, Glasgow, Grayson, Hartford, Hazard, Hillview, Hodgenville, Hopkinsville, Horse Cave, Independence, Jeffersontown, Jeffersonville, LaGrange, Lakeside Park, Lebanon Junction, Leitchfield, Lewisburg, Ludlow, Madisonville, Mayfield, Maysville, McKee, Middlesboro, Midway, Millersburg, Morehead, Morgantown, Mount Olivet, Mount Vernon, Murray, Newport, Oak Grove, Owensboro, Owenton, Paris, Park Hills, Pineville, Pioneer Village, Prestonsburg, Princeton, Richmond, Russell, Russell Springs, Ryland Heights, Saint Matthews, Scottsville, Shelbyville, Shepherdsville, Simpsonville, Smiths Grove, Somerset, Southgate, Stanton, Taylor Mill, Taylorsville, Vanceburg, Versailles, Villa Hills, Vine Grove, Warsaw, West Liberty, West Point, and Wilder.

The previously confirmed 11 are Bowling Green, Covington, Henderson, Lebanon, Lexington-Fayette Urban County Government, Louisville/Jefferson County Metro Government, Lyndon, Nicholasville, Paducah, Walton, and West Buechel.

The [Kentucky League of Cities](https://www.klc.org/News/12942/the-occupational-business-license-fee) stated on July 11, 2025 that 170 Kentucky cities levy a tax on gross earnings and linked its statewide city-rate survey. The linked FY2023 table contains **169 percentage payroll rows** and one flat Caneyville charge. Caneyville is excluded because a flat weekly fee does not meet this report's definition.

The registry retains the 169 percentage rows, now superseding 108 with direct primary evidence, and adds Walton from current 2024/2025 city law. It also adds two current candidates missing from the FY2023 table: Falmouth at a reported 1.5% effective July 1, 2026, and Hurstbourne Acres at a reported 1% effective July 1, 2024. Both are `SUPPORTED_CURRENT_SECONDARY`, not direct primary, until their enacted payroll ordinances or official withholding forms are retained. That produces 172 best-available current Kentucky rows: 109 direct-primary, 61 association-supported, and 2 current-secondary-supported.

The 61 remaining KLC rows have not been removed. Some have current official existence evidence but unresolved payroll-rate fields; others have conflicts between the FY2023 survey and current official displays. Bardwell, Paintsville, Perryville, Raceland, Shively, Springfield, and Winchester have specific possible rate changes that require a controlling local instrument before correction. Absence from the Secretary of State repository is not repeal evidence because demonstrably active municipalities are omitted and the repository itself warns of omissions or inaccuracies.

Current rate corrections made in this pass include Ashland 2.375%, Augusta 1.3%, Campbellsville 1.5%, Covington 2.45%, Dayton 2%, Elsmere 1.75% effective July 1, 2026, Hodgenville 1%, and Jeffersonville 2%.

Kentucky's statewide legal framework supports the functional classification: [KRS 67.780](https://apps.legislature.ky.gov/law/statutes/statute.aspx?id=23793) requires employers to withhold a compensation tax imposed by a tax district, and [KRS 67.788](https://apps.legislature.ky.gov/law/statutes/statute.aspx?id=23796) provides refunds for compensation attributable to work outside the district. Those statutes do not prove that every surveyed municipality currently imposes the reported rate.

Salem is excluded from the current registry. The enacted Ordinance 2026-05 imposes a 1% employee compensation tax with employer withholding, but section 14 makes it effective **October 1, 2026**. It belongs in the future-dated queue until that date is reached and current effect is revalidated.

The complete 172-name current Kentucky list is in the registry. The [August 27 verification report](agent-extracts/kentucky-local-verification-2026-08-27.md) gives the full reconciliation. The extracted KLC table is available as [CSV](agent-extracts/kentucky-klc-fy2023-city-rates.csv), the source survey is preserved as [PDF](agent-extracts/sources/kentucky-city-occupational-license-rates-fy2023.pdf), and the current Secretary of State repository snapshot and validation are preserved in `agent-extracts/`.

### Michigan — 24; coverage complete

The [Michigan Department of Treasury](https://www.michigan.gov/taxes/citytax/what-cities-impose-an-income-tax) identifies exactly 24 current city income-tax jurisdictions:

- Albion
- Battle Creek
- Benton Harbor
- Big Rapids
- Detroit
- East Lansing
- Flint
- Grand Rapids
- Grayling
- Hamtramck
- Highland Park
- Hudson
- Ionia
- Jackson
- Lansing
- Lapeer
- Muskegon
- Muskegon Heights
- Pontiac
- Port Huron
- Portland
- Saginaw
- Springfield
- Walker

Michigan city income taxes reach compensation earned by nonresidents working in the city and require employer withholding, subject to state allocation rules.

### Missouri — 2; coverage complete

- Kansas City
- St. Louis

[Missouri law](https://revisor.mo.gov/main/OneSection.aspx?section=92.111) limits municipal earnings taxes to legacy constitutional-charter cities that already imposed the tax and maintain voter approval. [Kansas City](https://www.kcmo.gov/city-hall/departments/finance/earnings-tax) and [St. Louis](https://www.stlouis-mo.gov/government/departments/collector/earnings-tax/payroll-tax-info.cfm) each impose a 1% earnings tax on residents and nonresidents earning compensation for work in the city. St. Louis's separate employer payroll-expense tax is excluded.

### New York — 1; coverage complete

- Yonkers

[New York withholding guidance](https://www.tax.ny.gov/bus/wt/whtax_require.htm) requires Yonkers nonresident earnings-tax withholding for services performed in Yonkers. New York City's personal income tax applies to residents, not to commuters merely because they work in NYC, so NYC is outside this worksite-and-commuter definition.

### Ohio — 666; coverage complete

The [Ohio Department of Taxation Finder](https://thefinder.tax.ohio.gov/) yielded 667 current municipalities with a positive municipal income-tax rate. Indian Hill is excluded because its current ordinance taxes resident individuals rather than nonresident wages earned by working there, leaving **666 qualifying municipalities**. [Ohio Revised Code §718.03](https://codes.ohio.gov/ohio-revised-code/section-718.03) supplies the employer-withholding rule.

The full Ohio list is in the registry. It excludes 153 JEDD/JEDZ records and all school-district income taxes because those are not municipalities.

### Oregon — 1; coverage partial

- Eugene

Eugene's [Community Safety Payroll Tax](https://www.eugene-or.gov/4281/Community-Safety-Payroll-Tax) includes an employee wage-tax component withheld by employers. Current city instructions and the nonresident chart tie the tax to the employer's Eugene physical business/reporting location. Eugene's employer payroll-tax and self-employment components are separate and excluded.

Portland's Arts Tax is excluded because it is a flat resident tax. Portland-administered Metro and Multnomah County income taxes are regional/county taxes, not City of Portland taxes. No exhaustive Oregon city-adopter register was found, so statewide coverage remains `PARTIAL`.

### Pennsylvania — 1,925; coverage complete

The [Pennsylvania DCED Real-Time Register](https://apps.dced.pa.gov/munstats-public/ReportInformation2.aspx?report=EitWithCollector_Dyn_Excel&type=R) yielded 1,978 positive work-location PSD rows. Those rows reconcile to **1,925 unique legal municipalities** after municipality-ID deduplication across school-district and county splits:

| Municipality type | Included |
|---|---:|
| Township | 1,160 |
| Borough | 713 |
| City | 51 |
| Town | 1 |
| **Total** | **1,925** |

The full Pennsylvania list is in the registry. It excludes 558 resident-only PSD rows, school-district EIT/PIT components, flat Local Services Taxes, and duplicate source rows for a legal municipality. The [municipality-to-PSD reconciliation](agent-extracts/pennsylvania_worksite_legal_municipality_psd_mapping.csv) preserves the official municipality IDs and PSD codes.

## Important exclusions

| Jurisdiction or category | Why it is excluded |
|---|---|
| New York City | City personal-income-tax liability is residence-based; merely working in NYC does not impose it on a nonresident. |
| Baltimore City | Maryland local income tax is residence-based. Baltimore's independent-city status does not change the incidence. |
| Portland Arts Tax | Flat resident tax, not a percentage tax on wages earned by working in Portland. |
| Colorado occupational privilege taxes | Current examples are flat monthly employee charges rather than wage percentages; Colorado law prohibits the percentage or graduated local income-tax class. |
| Newark and Jersey City payroll taxes | Employer-incidence taxes. Jersey City expressly prohibits withholding the tax from employees. |
| St. Louis payroll-expense tax | Employer-only; the separate employee earnings tax remains included. |
| Ohio JEDD/JEDZ and school income taxes | Special-district or school taxes, not municipal taxes. |
| Pennsylvania school EIT/PIT and Local Services Tax | School components are nonmunicipal; LST is flat. |
| County, transit, and regional income taxes | Outside the municipal scope even when employers withhold them. |
| Business net-profit, gross-receipts, and self-employment taxes | The requested incidence is employee wages. |

### West Virginia — zero current rows; coverage complete

West Virginia has a statute that would functionally qualify if activated: [W. Va. Code §8-13C-3](https://code.wvlegislature.gov/8-13C-3/) permits a qualifying municipality to impose up to 1% on taxable employees' wages and requires employer withholding. The authority is unusually narrow. A municipality must have a weighted police/fire pension funded percentage of 3% or less under [§8-13C-2](https://code.wvlegislature.gov/8-13C-2/), present a pension-remediation plan to the Joint Committee on Government and Finance, and obtain any necessary enabling legislation under [§8-13C-11](https://code.wvlegislature.gov/8-13C-11/). The tax also terminates under the funding and bond conditions in [§8-13C-9](https://code.wvlegislature.gov/8-13C-9/).

The current-adopter universe is closed at zero. The [2026 Guidebook to West Virginia Taxes](https://www.wvscpa.org/resources/public-resources/guidebook-to-wv-taxes), updated by experienced West Virginia tax professionals, states that no municipality imposed this pension-relief occupation tax as of January 1, 2026. The [Municipal Pensions Oversight Board](https://mpob.wv.gov/about/Pages/53-Pension-Plans.aspx) identifies the complete 53-plan legacy police/fire universe. All 53 official GASB 2025 reports measure those plans through June 30, 2025, and every plan remains above the statutory 3% ceiling; the lowest fiduciary-net-position percentage is St. Albans Fire at 12.40%. The Board's [consolidated actuarial report](https://mpob.wv.gov/actuarialreports/Pages/default.aspx) independently reports every July 1, 2024 market-value and actuarial-value ratio above 3%. Because every component ratio exceeds 3%, no municipality's positive weighted average can be 3% or less. The full per-plan 2025 result, source URL, file hash, and preserved official PDF are in the [West Virginia evidence set](../20260826T044944Z_west-virginia-municipal-wage-tax-closure-artifacts/README.md).

The January 1, 2026 [Municipal Home Rule annual report](https://www.wvlegislature.gov/legisdocs/reports/agency/M23_CY_2025_26930.pdf) discloses the full current proposal/implementation inventory and contains no employee occupational or payroll tax. Current home-rule law also prohibits ordinances contrary to state taxation and pension laws other than its limited sales-tax path. Huntington's proposed 1% occupation tax from the original pilot is historical, not an adopter: the [Legislative Auditor's 2012 report](https://www.wvlegislature.gov/Joint/PERD/perdrep/HomeRule_11_2012.pdf) says it was enjoined and never implemented.

No West Virginia municipality is therefore added to the registry. Flat weekly employee user/service fees charged by Huntington, Charleston, Morgantown, Parkersburg, Fairmont, Weirton, Wheeling, Montgomery, Chester, and Romney remain excluded because they are not percentage taxes calculated from wages. The dormant statute remains a refresh trigger; this is a current closed-zero conclusion, not a claim that future activation is legally impossible. The full closure audit and extracted 53-plan table are preserved in the [West Virginia report](../20260826T044944Z_west-virginia-municipal-wage-tax-closure.md).

### Idaho — zero current rows; no qualifying authority

Idaho requires specific legislative authorization for a municipal tax. [Idaho Constitution article VII, section 6](https://sos.idaho.gov/elections/publications/Idaho_Constitution.pdf) makes municipal taxing power dependent on legislative investment, and *North Idaho Building Contractors Association v. City of Hayden*, 156 Idaho 721, 329 P.3d 466 (2015), holds that Idaho Code section 50-301 is not a general taxing grant. Constitution article III, section 19 also prohibits local or special laws for tax assessment and collection.

The closure audit retrieved all 74 current Idaho Code title indexes and all 1,471 linked chapter PDFs. It searched 1,470 valid chapter PDFs plus the live chapter and four sections behind the one broken PDF link. No current statute authorizes a municipal percentage tax measured by employee wages, earnings, compensation, or payroll. The actual resort-city local-option grant in [sections 50-1044](https://legislature.idaho.gov/statutesrules/idstat/Title50/T50CH10/SECT50-1044/) and [50-1046](https://legislature.idaho.gov/statutesrules/idstat/Title50/T50CH10/SECT50-1046/) enumerates only short-term lodging occupancy, drink, and sales taxes. The [State Tax Commission](https://tax.idaho.gov/taxes/sales-use/sales-tax/local-sales-tax/city-sales-tax/) corroborates that local-option sales-tax topology. No Idaho row is added. The [full Idaho report](../20260826T230418Z_idaho-municipal-wage-tax-closure.md) and [evidence set](../20260826T230418Z_idaho-municipal-wage-tax-closure-artifacts/README.md) preserve the method, source hashes, and refresh triggers.

### Mississippi — zero current rows; no qualifying authority

[Mississippi Code section 21-17-5(2)](https://law.justia.com/codes/mississippi/title-21/chapter-17/section-21-17-5/) requires specific statutory or other state-law authority before a municipality may levy any tax. The current municipal-tax framework, the State Auditor's mandatory [Municipal Audit and Accounting Guide](https://www.osa.ms.gov/sites/default/files/Resources/Local%20Governments/maag22.pdf), and the Department of Revenue's current withholding and special-local-levy systems contain no municipal percentage tax on employee wages, earnings, compensation, or payroll.

The closure audit also retrieved the official “All Measures” report for every regular session from 1997 through 2026. Five bills proposed the exact missing authority—1997 HB 68, 1998 HB 299, 1999 HB 950, 2001 HB 900, and 2003 HB 1467—and every one died in House committee. The proposed measures would have taxed income from employment or business carried on in eligible cities, allocated nonresident work, and used state tax administration; none became law. The wage-deducted Mississippi Business Finance Corporation Job Development Assessment Fee is excluded because it services project bonds and is not imposed by a municipality, even when reported in the W-2 local box. No Mississippi row is added. The [full Mississippi report](../20260826T230418Z_mississippi-municipal-wage-tax-closure.md) and [evidence set](../20260826T230418Z_mississippi-municipal-wage-tax-closure-artifacts/README.md) preserve the 30-session audit, candidate histories, current administrative sources, and refresh triggers.

### Montana — zero current rows; no qualifying authority

Current [MCA section 7-1-112](https://mca.legmt.gov/bills/mca/title_0070/chapter_0010/part_0010/section_0120/0070-0010-0010-0120.html) requires specific legislative delegation before a self-government local government may authorize an income tax. Current [sections 7-6-4401](https://mca.legmt.gov/bills/mca/title_0070/chapter_0060/part_0440/section_0010/0070-0060-0440-0010.html) and [7-6-4421](https://mca.legmt.gov/bills/mca/title_0070/chapter_0060/part_0440/section_0210/0070-0060-0440-0210.html) provide only property-based general municipal taxing power.

Montana DOR's tax-year 2023 Form 2 instructions state that no city in Montana imposes a local income tax, consistent with its 2019-2022 instructions. The Legislature's complete July 2025 [enacted-tax summary](https://archive.legmt.gov/content/Committees/Interim/2025-2026/RIC/Meetings/July_11_2025/3.3.tax-legislation-2025.pdf) contains no local income-tax delegation, and the post-session 2025 MCA still contains the restriction and property-only general grants. Current-code searches found no alternate municipal employee wage, earnings, compensation, or payroll tax delegation. No Montana row is added. The [full Montana report](../20260826T230418Z_montana-municipal-wage-tax-closure.md) and [evidence set](../20260826T230418Z_montana-municipal-wage-tax-closure-artifacts/README.md) preserve the sources, search scope, and refresh triggers.

### South Dakota — zero current rows; coverage complete

South Dakota retains broad home-rule and municipal non-ad-valorem language, so it is not a categorical no-authority state. The current adopter universe is nevertheless closed at zero. [SDCL 10-52-9](https://sdlegislature.gov/api/Statutes/10-52.html?all=true) requires advance notice to the Secretary of Revenue for every new or amended chapter 10-52 municipal tax ordinance. The Department's [July 2026 Municipal Tax Guide](https://dor.sd.gov/media/54mb5a2w/2026-07_municipal-tax-guide.pdf) identifies the current municipal tax system and municipality-by-municipality codes as sales/use and gross-receipts taxes; it contains no employee income, wage, earnings, compensation, or payroll category or adopter.

The closure audit downloaded all 63 official consolidated title files—Constitution title `0N` and codified-law titles 1 through 62—and searched the complete 176,375,083-byte corpus. No qualifying authorization or adopter was found. The sole `payroll tax` occurrence concerns a PEO sales-tax deduction, and the two `local income tax` occurrences are generic partnership recordkeeping provisions. No South Dakota row is added. The [full South Dakota report](../20260826T230418Z_south-dakota-municipal-wage-tax-closure.md) and [evidence set](../20260826T230418Z_south-dakota-municipal-wage-tax-closure-artifacts/README.md) preserve the DOR sources, complete-code archive, phrase dispositions, hashes, and refresh triggers.

### Utah — zero current rows; no qualifying authority

[Utah Constitution article XI, section 5](https://le.utah.gov/xcode/ArticleXI/UC_AXI_1800010118000101.pdf) limits charter-city taxing power to the bounds prescribed by general law. *[Moss v. Board of Commissioners of Salt Lake City](https://law.justia.com/cases/utah/supreme-court/1953/8092-0.html)* holds that a municipality has only tax power expressly conferred or necessarily implied by legislative enactment. Current [section 10-1-203](https://le.utah.gov/xcode/Title10/Chapter1/10-1-S203.html) excludes employees rendering services to employers from its municipal business-tax definition and enumerates other revenue subjects, not employee wages.

The closure audit downloaded and searched all 96 current Utah Code title PDFs—19,339 pages and 56,391,062 extracted characters. It found no qualifying municipal income, wage, earnings, compensation, payroll, or withholding delegation or adopter. State withholding provisions and the April 2026 Tax Commission guide concern Utah state income tax only. No Utah row is added. The [full Utah report](../20260826T230418Z_utah-municipal-wage-tax-closure.md) and [evidence set](../20260826T230418Z_utah-municipal-wage-tax-closure-artifacts/README.md) preserve the complete-code audit, sources, hashes, and refresh triggers.

### Wyoming — zero current rows; no qualifying authority

Current [Wyoming Statutes section 39-12-101](https://wyoleg.gov/statutes/compress/title39.pdf) expressly denies every county, city, town, and other political subdivision authority to impose, levy, or collect an income tax, earnings tax, or any other tax based on wages or other income. That provision directly covers every tax within the registry definition.

The closure audit cross-checked statutory Titles 1 through 42 and Constitution Title 97—43 official files and 12,429 pages—and found no qualifying exception, delegation, or adopter. All phrase and proximity hits were unrelated partnership, FICA, deferred-compensation, economic-development, or pension provisions. No Wyoming row is added. The [full Wyoming report](../20260826T230418Z_wyoming-municipal-wage-tax-closure.md) and [evidence set](../20260826T230418Z_wyoming-municipal-wage-tax-closure-artifacts/README.md) preserve the complete-code audit, dispositions, hashes, and refresh triggers.

### Colorado — zero current rows; no qualifying authority

Current [Colorado Constitution article X](https://olls.info/crs/crs2026-title-00.pdf), section 20(8)(a), expressly prohibits local district income taxes, and section 20(2)(b) defines district to include local government. The Office of Legislative Legal Services' current [drafting manual](https://content.leg.colorado.gov/sites/default/files/colorado-legislative-drafting-manual-accessible.pdf) confirms that the prohibition covers any local-government income tax.

The rule also predates TABOR. *[City & County of Denver v. Sweet](https://law.justia.com/cases/colorado/supreme-court/1958/18802.html)* held that article X, section 17 gives the General Assembly exclusive, nondelegable income-tax power and denies even home-rule cities authority to impose an income tax. *[Duffy](https://law.justia.com/cases/colorado/supreme-court/1969/23940.html)* reaffirmed *Sweet* and invalidated Denver's percentage earnings tax. *[Johnson](https://law.justia.com/cases/colorado/supreme-court/1974/c-491.html)* distinguishes a permissible flat occupational fee because it is not measured by income; *[Rountree](https://law.justia.com/cases/colorado/supreme-court/1979/27990.html)* left that Colorado-law distinction intact. Current Glendale, Greenwood Village, Sheridan, and Denver employee occupational taxes are fixed monthly amounts and remain excluded. No Colorado row is added. The [full Colorado report](../20260826T230418Z_colorado-municipal-wage-tax-closure.md) and [evidence set](../20260826T230418Z_colorado-municipal-wage-tax-closure-artifacts/README.md) preserve the current constitution, official legislative interpretation, cases, municipal examples, source hashes, and refresh triggers.

### California — zero proven current rows; partial coverage

California law preserves a municipal employee occupational-license-tax path. [Revenue and Taxation Code section 17041.5](https://leginfo.legislature.ca.gov/faces/codes_displaySection.xhtml?lawCode=RTC&sectionNum=17041.5) generally bars local income taxes but preserves otherwise-authorized business-license taxes, while [Government Code section 50026](https://leginfo.legislature.ca.gov/faces/codes_displaySection.xhtml?lawCode=GOV&sectionNum=50026) regulates otherwise-authorized employee earnings taxes. *[Weekes v. City of Oakland](https://law.justia.com/cases/california/supreme-court/3d/21/386.html)* upheld Oakland's historical employee license fee measured by worksite compensation. Oakland's operative provisions were later repealed.

The State Controller's FY2003-FY2024 city-revenues dataset covers 482 FY2024 city entities and yielded no employee wage-, earnings-, income-, or occupation-tax label. Its only employer-payroll-tax category had nonzero values solely for San Francisco, whose official current page says that tax was repealed generally starting in 2021. Broad current municipal-code searches found no active employee-wage adopter, but no official source closes every charter and ordinance. California is therefore `PARTIAL`, with zero registry rows; an unmatched city is not product-safe `CLEAR`. The [full California report](../20260826T230418Z_california-municipal-wage-tax-closure.md) and [evidence set](../20260826T230418Z_california-municipal-wage-tax-closure-artifacts/README.md) preserve the audit and limitations.

### Texas — zero current rows; no qualifying authority

[Texas Constitution article VIII, section 1(f)](https://tcss.legis.texas.gov/resources/CN/htm/CN.8.htm) caps every city occupation tax at one-half of the state occupation tax on the same profession or business. *Brown v. City of Galveston* and [Attorney General Opinion JM-1195](https://www.texasattorneygeneral.gov/sites/default/files/opinion-files/opinion/1990/jm1195.pdf) apply that formula as a prohibition where the state levies no occupation tax on the pursuit. *[Conlen Grain](https://law.justia.com/cases/texas/supreme-court/1975/b-4711-0.html)* classifies a revenue exaction by its subject—the privilege of carrying on the occupation—rather than merely by the formula used to calculate it.

An employee percentage tax triggered by performing services in a city is therefore an occupation tax even when measured by wages. Texas imposes no state occupation tax on employment or wage earning, making the municipal ceiling zero. [Article XI, section 5](https://tcss.legis.texas.gov/resources/CN/htm/CN.11.htm) and [Tax Code chapter 302](https://tcss.legis.texas.gov/resources/TX/htm/TX.302.htm) do not let a home-rule charter or general-law ordinance exceed that constitutional ceiling. The Texas Municipal League revenue manual and Comptroller city-tax overview corroborate current practice. No Texas row is added. The [full Texas report](../20260827T134945Z_texas-municipal-wage-tax-closure.md) and [evidence set](../20260827T134945Z_texas-municipal-wage-tax-closure-artifacts/README.md) preserve the sources and refresh triggers.

## Nationwide coverage

All 50 states and the District of Columbia now have an explicit coverage classification:

- `COMPLETE` — **17**: Alaska, Connecticut, Delaware, District of Columbia, Kansas, Maryland, Michigan, Missouri, Nebraska, New Jersey, New York, Ohio, Pennsylvania, South Dakota, Vermont, West Virginia, Wisconsin.
- `NO_AUTHORITY_CONFIRMED` — **23**: Arizona, Arkansas, Colorado, Florida, Georgia, Hawaii, Idaho, Illinois, Indiana through FY2027, Louisiana, Minnesota, Mississippi, Montana, Nevada, New Mexico, North Carolina, North Dakota, Oklahoma under this worksite definition, Texas, Utah, Virginia, Washington, Wyoming.
- `PARTIAL` — **11**: Alabama, California, Iowa, Kentucky, Maine, Massachusetts, New Hampshire, Oregon, Rhode Island, South Carolina, Tennessee.
- `UNDETERMINED` — **0**: none.

`COMPLETE` means a current authoritative source or legal topology closes the municipal universe for this narrow question. `NO_AUTHORITY_CONFIRMED` is a closed zero under the definition. `PARTIAL` means current evidence supports the positive or zero findings shown but leaves an adopter, special-act, charter, legacy, or update gap. `UNDETERMINED` means the legal source set could not safely establish either an adopter or a categorical zero.

The structured [coverage matrix](coverage-matrix.jsonl) contains all 51 state/DC records and source URLs. Detailed audit evidence is preserved for the [South](agent-extracts/phase2-south-audit.md), [Northeast/Midwest](agent-extracts/phase2-northeast-midwest-audit.md), [West](agent-extracts/phase2-west-audit.md), and the individual closure reports linked above.

## Remaining review and scheduled refreshes

The [review queue](worksite-municipal-income-tax-review-queue.md) records the unresolved candidates and future changes. The most important are:

- Hurstbourne Acres, Kentucky: current secondary payroll sources report a 1% tax effective July 1, 2024, but no current municipal ordinance/form was located that proves the complete inclusion test.
- Falmouth, Kentucky: the official city page announces a 2026 occupational ordinance but does not expose enough wage-tax detail to confirm a current row.
- Salem, Kentucky: official Ordinance 2026-05 meets the functional test but is effective **October 1, 2026**, so it is future-dated on this report.
- Indiana: the present no-authority conclusion is time-limited; municipal LIT authority begins in FY2028 and requires a pre-2028 refresh.

## Product-use boundary

This registry supports screening, not a tax-liability calculation. A confirmed company-location match means review may be required; it does not prove a particular employee owes tax.

`BUFFER_REVIEW_REQUIRED` is appropriate only for a `CONFIRMED_PRIMARY` positive after the full address is mapped to the authoritative municipal boundary. Association-supported rows remain `UNDETERMINED` until the current local ordinance and rate are verified. Postal city text alone is not enough in systems such as Ohio, Pennsylvania, or Eugene.

`CLEAR` is appropriate only when the state source is `COMPLETE` or `NO_AUTHORITY_CONFIRMED`, the address maps unambiguously to the authoritative universe, and no relevant positive exists. An unmatched city in a `PARTIAL` or `UNDETERMINED` state is not `CLEAR`.
