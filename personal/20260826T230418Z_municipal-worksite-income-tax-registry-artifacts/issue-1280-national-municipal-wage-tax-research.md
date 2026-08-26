# Issue #1280 nationwide municipal earned-income and wage-tax research

Research retrieval date: 2026-08-25

Status: Historical research notebook plus August 25 West Virginia and August 26 Idaho closure addenda; not compliance-approved and not Rule Engine data.

## August 26, 2026 Idaho closure addendum

Idaho moved from `UNDETERMINED` to `NO_AUTHORITY_CONFIRMED` with zero registry rows. Idaho Constitution article VII, section 6 and controlling case law require specific legislative authorization for a municipal tax; article III, section 19 prohibits local or special laws for tax assessment and collection. A complete audit of all 74 current Idaho Code title indexes and 1,471 linked chapter PDFs found no authorization for a municipal percentage tax measured by employee wages, earnings, compensation, or payroll. The one dead chapter-PDF link was recovered through its live chapter and four section pages.

The resort-city local-option grant in Idaho Code sections 50-1044 through 50-1049 enumerates only short-term lodging occupancy, drink, and sales taxes. The current registry therefore remains 2,815 municipalities across nine states. Coverage is now 16 `COMPLETE`, 17 `NO_AUTHORITY_CONFIRMED`, 10 `PARTIAL`, and 8 `UNDETERMINED`. See the [Idaho closure report](../20260826T230418Z_idaho-municipal-wage-tax-closure.md), [evidence directory](../20260826T230418Z_idaho-municipal-wage-tax-closure-artifacts/README.md), and updated [coverage matrix](coverage-matrix.jsonl).

## August 25, 2026 West Virginia closure addendum

The later timed closure audit resolves the West Virginia gap recorded in this working notebook. West Virginia is now `COMPLETE` with zero current registry rows under the agreed worksite-wage-tax definition. The result rests on the combined legal and adopter topology rather than on a keyword-only absence:

- [W. Va. Code §8-13C-2](https://code.wvlegislature.gov/8-13C-2/) limits the pension-relief municipal occupational tax to a municipality whose weighted police/fire pension funded percentage is 3% or less, and [§8-13C-11](https://code.wvlegislature.gov/8-13C-11/) additionally requires a Joint Committee plan and any necessary enabling legislation.
- The [2026 Guidebook to West Virginia Taxes](https://www.wvscpa.org/resources/public-resources/guidebook-to-wv-taxes) states that no West Virginia municipality imposed the tax as of January 1, 2026.
- The Municipal Pensions Oversight Board's complete [53-plan universe](https://mpob.wv.gov/about/Pages/53-Pension-Plans.aspx) has an official GASB 2025 report for every plan through June 30, 2025. No plan is at or below 3%; the lowest fiduciary-net-position percentage is 12.40%. The consolidated July 1, 2024 valuation independently reaches the same above-threshold result.
- Current Article 13C bill history and the January 1, 2026 [Home Rule annual report](https://www.wvlegislature.gov/legisdocs/reports/agency/M23_CY_2025_26930.pdf) disclose no later enabling act, adopter, or alternate home-rule employee wage tax.

That iteration produced 16 `COMPLETE`, 16 `NO_AUTHORITY_CONFIRMED`, 10 `PARTIAL`, and 9 `UNDETERMINED`. The row-level registry remained 2,815 municipalities in nine states because West Virginia added no positive. See the [full closure report](../20260826T044944Z_west-virginia-municipal-wage-tax-closure.md), the updated [coverage matrix](coverage-matrix.jsonl), and the [national report](U.S.%20Municipalities%20With%20a%20Worksite-Based%20Local%20Income%20Tax.md).

Some state-by-state rows below retain Phase 1 research detail. Where a historical row conflicts with the final report or machine-readable matrix, the final report and matrix are the current disposition.

## Executive boundary

This research inventories current local taxes imposed by municipalities on an individual's earned income, wages, earnings, or employee compensation, plus compensation-based occupational taxes that may create employer withholding duties. It is a screening-data study for HelixOS Issue #1280. It is not a calculation of employee liability, does not establish that a company address alone creates tax nexus or withholding liability, and cannot activate the existing rounded-variance option.

The current Issue #1280 uses company situs city and state from Client Demographics as an interim screening proxy. A confirmed match may support `BUFFER_REVIEW_REQUIRED`; `CLEAR` is allowed only where an approved authoritative source demonstrably closes the relevant jurisdiction universe and the input maps unambiguously to that universe. All other negative results are `UNDETERMINED`.

The approximately 700-city estimate in the Slack huddle is a hypothesis. It is not a count target and is not compliance evidence.

## Working tax definition

### Primary inclusion candidate

A current tax imposed by an incorporated municipality on an individual's earned income, wages, earnings, salary, commissions, or employee compensation, including a compensation-based occupational, license, or payroll tax whose legal incidence reaches the employee or for which an employer must withhold from employee pay.

### Separate product/compliance-review classes

- `NON_MUNICIPAL_LOCAL_INCOME`: county, school-district, transit, regional, or other non-municipal income or wage tax.
- `MUNICIPAL_RESIDENT_ONLY_INCOME`: municipal income tax whose applicability depends on employee residence rather than the employer's company city.
- `MUNICIPAL_EMPLOYER_PAYROLL`: employer-only payroll-expense tax that may be measured by employee compensation but is not deducted from employee pay.
- `MUNICIPAL_FLAT_OCCUPATIONAL`: flat occupational privilege, head, license, or service fee not calculated as a percentage or graduated amount of employee compensation.
- `AMBIGUOUS_COMPENSATION_TAX`: official evidence does not resolve incidence, base, current effect, or withholding relevance.

### Excluded

Sales/use, property, general business-license, corporate income/franchise, and gross-receipts taxes unrelated to employee compensation; lists of municipalities that do not themselves establish a relevant tax.

## Evidence and confidence model

- `CONFIRMED_PRIMARY`: current statute, municipal code, official state registry, official tax department, or official administrator directly establishes the jurisdiction and tax.
- `CONFIRMED_WITH_LIMITATION`: authoritative evidence establishes the tax but leaves a material product question such as residence-only incidence, boundary ambiguity, or incomplete statewide coverage.
- `AMBIGUOUS_PRIMARY`: an official source exists but does not resolve current applicability, tax base, incidence, or administrator coverage.
- `DISCOVERY_ONLY`: secondary/commercial material; never sufficient for a positive record or `CLEAR`.

Every positive record requires a direct authoritative citation. Administrator membership lists are partial unless the state or statute establishes that the administrator covers the entire taxing universe.

## Coverage statuses

- `COMPLETE`: an authoritative current statewide source or closed statutory/official registry demonstrably covers every relevant municipality and tax adopter.
- `PARTIAL`: official positives exist, but the source universe is limited or additional municipalities may administer independently.
- `NO_AUTHORITY_CONFIRMED`: current primary authority expressly prevents municipalities from imposing the included tax.
- `UNDETERMINED`: authority, adoption, completeness, or current evidence remains unresolved.

`CLEAR` is safe only for `COMPLETE` or `NO_AUTHORITY_CONFIRMED` coverage, after successful canonical municipality/alias resolution. A missing match in `PARTIAL` or `UNDETERMINED` coverage returns `UNDETERMINED`.

## Source-context notes

- [Current GitHub Issue #1280](https://github.com/helixosio/helixos/issues/1280) defines the screening workflow and three-result contract.
- [Slack huddle transcript](https://seasharpllc.slack.com/docs/T0ACD4ENM6H/F0BSPTZ1W0J) confirms that the intended research target is local income/earnings taxes, that company city/state is only an interim proxy, and that the approximate count is not backed by a supplied client registry. The transcript is product context, not tax-law evidence.

## Nationwide coverage matrix

Machine-readable detail: [`coverage-matrix.jsonl`](coverage-matrix.jsonl). After the Idaho closure, the matrix has 51 unique rows: 16 `COMPLETE`, 17 `NO_AUTHORITY_CONFIRMED`, 10 `PARTIAL`, and 8 `UNDETERMINED`.

| State | Coverage | Phase 1 finding |
|---|---|---|
| [Alabama](https://www.revenue.alabama.gov/wp-content/uploads/2021/01/2020-General-Summary.pdf) | `PARTIAL` | Birmingham is a confirmed employee-earnings occupational-tax positive; no complete current statewide adopter registry was found. |
| [Alaska](https://www.commerce.alaska.gov/dcra/admin/Taxable/ViewFile/2de31798-e2aa-42c9-8a50-43e1c7c6ddb8) | `COMPLETE` | The current all-municipality/all-tax-type report has no in-scope tax; this is current-practice closure, not permanent preemption. |
| [Arizona](https://www.azleg.gov/ars/43/00201.htm) | `NO_AUTHORITY_CONFIRMED` | Current statute preempts local income taxation while the urban revenue-sharing fund is maintained. |
| [Arkansas](https://arkleg.state.ar.us/Bills/Detail?ddBienniumSession=2023%2F2023R&id=HB1026) | `NO_AUTHORITY_CONFIRMED` | Act 96 of 2023 prohibits local-government income taxes and repealed prior local authority. |
| [California](https://www.leginfo.legislature.ca.gov/faces/codes_displayText.xhtml?article=2.&chapter=1.&division=1.&lawCode=GOV&part=1.&title=5.) | `UNDETERMINED` | Current charter/general-law authority and adopter universe were not closed. |
| [Colorado](https://www.denvergov.org/files/assets/public/v/1/finance/documents/treasury/tax-guides/tax-update-2025/treasurytaxrule004_rulesrelatingtothefrequencyof.taxreturns.pdf) | `UNDETERMINED` | Denver's current employee occupational privilege tax is flat, not compensation-calculated; statewide coverage remains open. |
| [Connecticut](https://www.cga.ct.gov/current/pub/chap_204.htm) | `UNDETERMINED` | A dated official interpretation says no granted municipal income-tax authority; current closure was not found. |
| [Delaware](https://delcode.delaware.gov/title22/c009/index.html) | `COMPLETE` | Statutory population threshold plus current official population data close the current universe to Wilmington. |
| [Florida](https://www.flsenate.gov/Laws/Constitution/Article7) | `NO_AUTHORITY_CONFIRMED` | The state constitution bars natural-person income taxation by the state or under its authority beyond unavailable federal credits. |
| [Georgia](https://www.legis.ga.gov/api/document/docs/default-source/general-statutes/2010sumdoc.pdf) | `UNDETERMINED` | Official enactment history records a local-income-tax prohibition, but current official statutory text and occupational-tax scope were not closed. |
| [Hawaii](https://data.capitol.hawaii.gov/hrscurrent/Vol02_Ch0046-0115/HRS0046/HRS_0046-0001_0005.htm) | `UNDETERMINED` | No explicit current no-authority determination or complete county/local tax inventory was found. |
| [Idaho](https://sos.idaho.gov/elections/publications/Idaho_Constitution.pdf) | `NO_AUTHORITY_CONFIRMED` | Specific legislative authorization is required; the special-law path is constitutionally closed; and the complete current-code audit found no qualifying municipal employee wage-tax grant. |
| [Illinois](https://www.ilga.gov/commission/lru/TaxHandbook2026.pdf) | `NO_AUTHORITY_CONFIRMED` | The May 2026 legislative tax handbook states that no local personal-income tax is authorized. |
| [Indiana](https://www.in.gov/dor/files/tax-chapter.pdf) | `NO_AUTHORITY_CONFIRMED` through FY2027 | Current local income tax is county-based; municipal authority begins in FY2028 and requires refresh before then. |
| [Iowa](https://www.legis.iowa.gov/docs/code/364.2.pdf) | `UNDETERMINED` | No municipal adopter or explicit prohibition was established; school-district surtax is separate. |
| [Kansas](https://ksrevisor.gov/statutes/chapters/ch12/012_001_0040.html) | `UNDETERMINED` | Income-tax prohibition is explicit, but official annotations leave compensation-based occupational-tax scope unresolved. |
| [Kentucky](https://apps.legislature.ky.gov/CommitteeDocuments/26/35644/Sep%2023%202025%20Centralized%20Occupational%20License%20Tax%20Info.pdf) | `PARTIAL` | Local occupational license taxes on wages are confirmed; no complete current municipal adopter registry was found. |
| [Louisiana](https://www.legis.la.gov/legis/Law.aspx?d=763297) | `UNDETERMINED` | Nonresident local income taxation is barred, but resident-only/special-act authority and adopters were not closed. |
| [Maine](https://www.mainelegislature.org/legis/statutes/30-a/title30-A.pdf) | `UNDETERMINED` | No explicit current local preemption or complete local-tax inventory was established. |
| [Maryland](https://services.marylandcomptroller.gov/taxes/en/maryland-income-tax-rates-and-brackets?id=kb_article_view&sysparm_article=KB0010014) | `COMPLETE` | State-administered closed county-equivalent universe; Baltimore City is the only municipal-equivalent record. |
| [Massachusetts](https://malegislature.gov/Laws/Constitution) | `UNDETERMINED` | Constitutional limits were found, but statutory/special-act authority was not fully closed. |
| [Michigan](https://www.michigan.gov/taxes/citytax/what-cities-impose-an-income-tax) | `COMPLETE` | Treasury publishes the current closed list of 24 city income-tax adopters. |
| [Minnesota](https://www.revisor.mn.gov/statutes/cite/477A.016) | `NO_AUTHORITY_CONFIRMED` | Current statute prevents the in-scope municipal tax. |
| [Mississippi](https://www.dor.ms.gov/sites/default/files/Forms/indiv_80100138.pdf) | `UNDETERMINED` | A wage-deducted project assessment is nonmunicipal; active legacy-project status remains unresolved. |
| [Missouri](https://revisor.mo.gov/main/OneSection.aspx?section=92.111) | `COMPLETE` | The closed statutory class and current city sources identify Kansas City and St. Louis. |
| [Montana](https://mca.legmt.gov/bills/mca/title_0070/chapter_0010/part_0010/section_0120/0070-0010-0010-0120.html) | `UNDETERMINED` | Self-government cannot create an income tax without delegation; special delegations were not exhaustively closed. |
| [Nebraska](https://nebraskalegislature.gov/laws/statutes.php?statute=14-109) | `UNDETERMINED` | Broad occupation/license power exists; current municipal ordinances were not exhaustively closed. |
| [Nevada](https://www.leg.state.nv.us/Const/NVConst.html) | `NO_AUTHORITY_CONFIRMED` | The state constitution prohibits state and local individual income taxes. |
| [New Hampshire](https://www.revenue.nh.gov/taxes-glance/interest-dividends-tax) | `UNDETERMINED` | No complete municipal compensation-tax authority/adopter inventory was found. |
| [New Jersey](https://pub.njleg.state.nj.us/Bills/2024/AL25/314_.PDF) | `PARTIAL` | Newark and Jersey City have current employer-only remuneration-based payroll taxes; employee-incidence coverage remains open. |
| [New Mexico](https://www.tax.newmexico.gov/governments/municipal-county-governments/local-option-taxes/) | `UNDETERMINED` | Municipal income taxation is barred unless otherwise provided by law; the exception universe was not closed. |
| [New York](https://www.tax.ny.gov/bus/wt/whtax_require.htm) | `COMPLETE` | Current state withholding sources close the municipal universe to New York City and Yonkers. |
| [North Carolina](https://www.ncleg.gov/EnactedLegislation/Statutes/HTML/BySection/Chapter_105/GS_105-247.html) | `NO_AUTHORITY_CONFIRMED` | Current statute prevents the in-scope local income tax. |
| [North Dakota](https://ndlegis.gov/cencode/t40c05-1.pdf) | `NO_AUTHORITY_CONFIRMED` | Current municipal home-rule authority does not permit the in-scope tax. |
| [Ohio](https://thefinder.tax.ohio.gov/) | `COMPLETE` | Taxation's Finder closes the current statewide municipal positive-rate universe; JEDD/JEDZ and school districts are separate. |
| [Oklahoma](https://www.oklegislature.gov/OK_Statutes/CompleteTitles/os68.pdf) | `UNDETERMINED` | Broad local tax authority exists, but earnings/payroll/income taxes on nonresidents are barred; resident-only adopters were not closed. |
| [Oregon](https://www.eugene-or.gov/DocumentCenter/View/64574/Employee-Payroll-Tax-FAQ) | `PARTIAL` | Eugene employee payroll tax and Portland resident-only Arts income tax are confirmed; statewide municipal coverage remains open. |
| [Pennsylvania](https://dced.pa.gov/local-government/local-income-tax-information/psd-codes-and-eit-rates/) | `COMPLETE` | DCED's official and nightly Real-Time Registers close every municipality/PSD; Philadelphia is a direct overlay outside Act 32. |
| [Rhode Island](https://tax.ri.gov/tax-sections/personal-income-tax) | `UNDETERMINED` | No explicit municipal preemption or complete local inventory was established. |
| [South Carolina](https://dor.sc.gov/withholding) | `UNDETERMINED` | No explicit municipal preemption or complete local inventory was established. |
| [South Dakota](https://dor.sd.gov/businesses/taxes/municipal-tax/) | `UNDETERMINED` | The official page covers selected local tax types but does not establish an exhaustive all-tax universe. |
| [Tennessee](https://www.tn.gov/revenue/taxes/local-taxes.html) | `UNDETERMINED` | No explicit municipal compensation-tax preemption or complete current inventory was established. |
| [Texas](https://comptroller.texas.gov/transparency/local/cities.php) | `UNDETERMINED` | Official city-tax material is not an exhaustive all-tax registry and does not explicitly close compensation-tax authority. |
| [Utah](https://tax.utah.gov/forms/pubs/pub-14.pdf) | `UNDETERMINED` | No explicit municipal preemption or complete current inventory was established. |
| [Vermont](https://tax.vermont.gov/sites/tax/files/documents/MRT%20Regs%20final%20effective%206%201%2022.pdf) | `UNDETERMINED` | Local-option sources do not close charter/special-act compensation-tax authority. |
| [Virginia](https://law.lis.virginia.gov/vacodefull/title58.1/subtitleIII/) | `NO_AUTHORITY_CONFIRMED` | Current code bars local income, payroll, and occupation taxes. |
| [Washington](https://app.leg.wa.gov/RCW/default.aspx?cite=1.90&full=true) | `NO_AUTHORITY_CONFIRMED` | Current law bars local individual personal-income taxes; Seattle payroll-expense tax is employer-only. |
| [West Virginia](https://code.wvlegislature.gov/8-13C-3/) | `COMPLETE` | Current closed zero: conditional authority exists, but the 2026 statewide tax guide reports no adopter and all 53 official GASB 2025 plan reports remain above the 3% qualification ceiling. |
| [Wisconsin](https://www.revenue.wi.gov/Pages/FAQS/pcs-with.aspx) | `UNDETERMINED` | No explicit municipal preemption or complete local inventory was established. |
| [Wyoming](https://revenue.wyo.gov/excise-tax-division) | `UNDETERMINED` | Official local-tax material found was not an exhaustive all-tax registry. |
| [District of Columbia](https://otr.cfo.dc.gov/page/dc-individual-and-fiduciary-income-tax-rates) | `COMPLETE` | The District is one closed district-equivalent resident income-tax system, but it cannot be inferred from company situs. |

## Normalized positive-jurisdiction inventory

The directly supported municipal inventory is [`normalized-municipal-tax-inventory.jsonl`](normalized-municipal-tax-inventory.jsonl). It contains one valid JSON object per positive jurisdiction, with a direct primary-source URL on every row. [`review-only-and-nonmunicipal-inventory.jsonl`](review-only-and-nonmunicipal-inventory.jsonl) keeps employer-only payroll taxes, flat occupational/LST taxes, Ohio JEDD/JEDZ records, the DC district-equivalent resident tax, and one ambiguous Mississippi assessment outside the municipal-positive count. [`inventory-validation-summary.json`](inventory-validation-summary.json) records counts, unique-key checks, and file hashes.

Normalized fields are:

- stable record ID, state code, canonical jurisdiction name/type, and authoritative jurisdiction ID;
- tax category/name, legal incidence, geographic scope, employer-withholding flag, rate, and effective period;
- administrator, evidence status, state coverage status, product disposition, and limitations;
- direct primary-source URLs and source date;
- separately retained school-district and flat-tax components where the official source combines them.

The two statewide source extracts with the largest populations are independently auditable:

- [Ohio Taxation's Finder](https://thefinder.tax.ohio.gov/) produced 667 current positive municipal FIPS/rate rows with no unmatched or duplicate current key. Its 153 JEDD/JEDZ rows are separate non-municipal records.
- [Pennsylvania DCED's Real-Time Register](https://apps.dced.pa.gov/munstats-public/ReportInformation2.aspx?report=EitWithCollector_Dyn_Excel&type=R) produced 2,627 source rows, normalized to 2,619 unique PSD codes after collapsing eight cross-county duplicates. There are 2,536 municipal EIT positives: 1,978 work-location/nonresident positives and 558 resident-only positives. Municipal EIT, school EIT/PIT, and municipal/school LST remain separate. The full source-normalized workbook extracts and hashes are documented in [`agent-extracts/README.md`](agent-extracts/README.md).

## Counts and reconciliation

### Directly supported municipal positives

| State | Positive rows | Coverage effect on count |
|---|---:|---|
| Alabama | 6 | Minimum only; `PARTIAL`. |
| Delaware | 1 | Closed current set: Wilmington. |
| Kentucky | 7 | Minimum only; `PARTIAL`. |
| Maryland | 1 | Baltimore City resident-only municipal-equivalent. |
| Michigan | 24 | Closed current Treasury set. |
| Missouri | 2 | Closed current set: Kansas City and St. Louis. |
| New York | 2 | Closed current set: New York City resident-only and Yonkers. |
| Ohio | 667 | Closed current positive-rate set from Finder. |
| Oregon | 2 | Eugene employee payroll plus Portland resident-only income tax; `PARTIAL`. |
| Pennsylvania | 2,536 | Closed unique-PSD set; 1,978 work-location and 558 resident-only. |
| **Total** | **3,248** | Documented directly supported rows, not a closed nationwide total. |

Category reconciliation:

- 2,687 municipal earned-income/worksite-relevant rows;
- 561 resident-only municipal income rows;
- 1,831 separately normalized review/nonmunicipal rows: 1,669 flat municipal occupational/LST rows, 7 employer-only municipal payroll rows, 153 Ohio JEDD/JEDZ rows, 1 DC district-equivalent resident tax, and 1 ambiguous Mississippi assessment;
- 1 separately recorded repealed Colorado tax (Aurora), excluded from current totals.

Pennsylvania's June 15 Official Register and the August 25 nightly register have the same 2,619 unique PSDs and 2,536 municipal positives. Five fields changed across two PSDs: Lancaster City municipal/total LST changed from $47 to $52; Philadelphia resident/nonresident/total rates changed from 3.74/3.43/3.74 to 3.735/3.425/3.735 percent. The current Philadelphia values match the [city's direct Wage Tax source](https://www.phila.gov/services/business-self-employment/business-taxes/wage-tax-employers/) and are one record, not an overlay duplicate.

The approximately 700 estimate is not supportable as a national count. Ohio alone has 667 official current positive municipal rates; Ohio plus Pennsylvania already has 3,203 directly supported municipal positives before the other eight positive states. The research therefore treats 700 as an unsourced conversational estimate, not a reconciliation target.

## Gap report

This is an exhaustive nationwide source-topology and gap assessment, but not an individually ordinance-verified national adopter list. Nineteen jurisdictions cannot support a nationwide `CLEAR` decision from current evidence:

- `PARTIAL`: Alabama, Iowa, Kentucky, Maine, Massachusetts, New Hampshire, Oregon, Rhode Island, South Carolina, and Tennessee.
- `UNDETERMINED`: California, Colorado, Mississippi, Montana, South Dakota, Texas, Utah, and Wyoming.

The remaining material gaps are:

1. **Adopter closure:** Alabama and Kentucky have directly confirmed positives but no complete official current municipal adopter/rate registry. Oregon has confirmed Eugene and Portland taxes but no closed statewide registry. New Jersey's directly confirmed Newark/Jersey City taxes are employer-only; the employee-incidence universe is open.
2. **Legal exception closure:** the 8 `UNDETERMINED` states require a current explicit preemption determination, a complete special-act/charter authorization inventory, or a complete all-municipality tax source. Absence from a state page covering only common local taxes is not negative evidence.
3. **Boundary resolution:** a postal or mailing city is not a legal municipal boundary. Ohio Finder explicitly resolves addresses; Pennsylvania uses PSD codes; Eugene warns that a Eugene mailing address may be outside city limits. City/state alone cannot safely map these records.
4. **Residence-only taxes:** Baltimore City, New York City, Portland, 558 Pennsylvania PSDs, and DC depend on individual residence. Company situs cannot establish applicability, so the current Issue #1280 input contract must return `UNDETERMINED` for these classes.
5. **Rate currency:** Michigan's official registry closes the current 24-city adopter set, but the latest located statewide rate table is tax year 2025 for 23 cities; Detroit has a direct 2026 withholding guide. Several partial-state municipal sources likewise confirm current existence without a fully current rate/exemption codification.
6. **Nonmunicipal components:** Pennsylvania school-district EIT/PIT, Ohio JEDD/JEDZ and school-district income taxes, county/regional income taxes, and project-specific assessments must not be silently reclassified as municipal positives. Pennsylvania source data preserves 466 school-district IDs with positive EIT components; four have municipality-dependent component rates and cannot be flattened to one district rate without loss.
7. **Time-sensitive authority:** Indiana is `NO_AUTHORITY_CONFIRMED` only through FY2027; municipal LIT authority begins in FY2028, requiring a scheduled source refresh before that date.

## Product-data recommendation

Do not implement the research as one unversioned approved city-name list. Use a versioned jurisdiction/evidence registry plus a deterministic resolver.

### Registry shape

Each approved record should store:

- immutable record ID; state; canonical jurisdiction name and type; official FIPS, PSD, or administrator code;
- official aliases as separately sourced/versioned values, never fuzzy aliases invented from mailing cities;
- tax class, legal incidence, resident/nonresident/work-location behavior, employer-withholding relevance, and administrator;
- rate components with `valid_from`/`valid_to`; never overwrite history;
- source title/URL, source effective or register date, retrieval timestamp, content hash, evidence status, coverage status, and limitation text;
- dataset version, approval artifact, approver, approval time, superseded version, and next mandatory refresh date.

### Lookup contract

1. Normalize state and punctuation only; do not fuzzy-match jurisdiction names.
2. Resolve the full company situs address through the applicable authoritative boundary source when one exists: Ohio Finder/FIPS, Pennsylvania PSD, or an official municipal boundary service. City/state text by itself is insufficient where the source says so.
3. Return `BUFFER_REVIEW_REQUIRED` only for an approved worksite-relevant positive whose authoritative jurisdiction key is resolved.
4. Return `CLEAR` only when the state is `COMPLETE` or `NO_AUTHORITY_CONFIRMED`, the input maps unambiguously to the authoritative universe, and no relevant positive exists for the dataset version.
5. Return `UNDETERMINED` for `PARTIAL`/`UNDETERMINED` states, ambiguous boundary matches, residence-only taxes without employee residence, employer-only/flat/nonmunicipal classes, or stale/expired evidence.
6. Persist the exact dataset version, resolved jurisdiction ID, coverage decision, evidence IDs, and decision reason. A later source refresh must not silently rewrite a prior application decision.

The three-result contract in Issue #1280 remains workable as a screening workflow, but the current city/state-only input cannot support national `CLEAR` behavior. Full address-to-jurisdiction resolution and an approved refresh process are required before this research can become Rule Engine data.

## Separate scope question: United States territories

The 50-state-plus-DC mandate does not resolve United States territories. Territories are not silently included or excluded. Their territorial tax systems, municipal authority, and federal mirror-code relationships require a separately approved scope and source plan before they can affect Issue #1280 decisions.
