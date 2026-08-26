# West Virginia Municipal Worksite-Wage-Tax Closure

Research date: August 25, 2026

Disposition: `COMPLETE` — current closed zero

Registry effect: no West Virginia municipality rows added

## Outcome

West Virginia can be removed from the national registry's `UNDETERMINED` queue. No West Virginia municipality currently imposes the narrow type of local tax this project is registering.

West Virginia law does contain dormant conditional authority for a tax that would qualify if activated. The current-zero result is therefore classified as `COMPLETE`, not `NO_AUTHORITY_CONFIRMED`: the present adopter universe is closed, but future activation is legally possible if all statutory conditions are met.

## Definition applied

This audit includes a municipality-imposed percentage tax calculated from an employee's wages or earned compensation for work performed in the municipality, including nonresident commuter work, where the employer may have to withhold the tax.

It does not include:

- flat weekly or annual user, service, occupational, or privilege fees;
- a tax payable only because the employee resides in the municipality;
- employer-incidence payroll-expense taxes that cannot be withheld from employees;
- county, school, transit, regional, or special-district taxes;
- municipal business-and-occupation, gross-receipts, net-profit, business-profit, or self-employment taxes; or
- sales/use taxes dedicated to pension funding.

## Why the dormant Article 13C tax would qualify

[W. Va. Code §8-13C-3](https://code.wvlegislature.gov/8-13C-3/) permits a qualifying municipality to impose a uniform pension-relief municipal occupational tax of up to 1%. The base is employee salaries, wages, commissions, and other earned income included in federal adjusted gross income. Employers must withhold and remit it each pay period.

[Section 8-13C-2](https://code.wvlegislature.gov/8-13C-2/) defines a taxable employee as someone employed by an employer with a place of business in the municipality whose covered earned income exceeds $10,000 per year. That is a worksite/employer-location rule capable of reaching nonresident commuters, so an activated tax would satisfy the registry definition.

## Why no municipality can be added now

Four independent layers close the current universe.

### 1. Current professional statewide tax guide: zero adopters

The [2026 Guidebook to West Virginia Taxes](https://www.wvscpa.org/resources/public-resources/guidebook-to-wv-taxes) says no West Virginia municipality imposed a pension-relief occupation tax as of January 1, 2026. The guidebook page says the 2026 edition incorporates intervening legislative and regulatory changes and was written and updated by experienced West Virginia state and local tax professionals.

The prior 2025 edition separately reported the same zero as of January 1, 2025. The successive statements close the historical/current-adopter gap through the start of 2026 rather than relying only on failure to locate a municipal form.

### 2. Complete pension-plan universe: no currently eligible municipality

The [Municipal Pensions Oversight Board](https://mpob.wv.gov/about/Pages/53-Pension-Plans.aspx) identifies the complete legacy universe as 53 municipal police and fire pension plans: 31 police plans and 22 fire plans.

A qualifying municipality must have a weighted average police/fire funded percentage of **3% or less** on the ordinance-adoption date. MPOB posts an official GASB 2025 report for every plan in the 53-plan universe. The complete extracted set has 31 police and 22 fire reports, each with a June 30, 2025 measurement date. Every plan is above 3%:

- minimum fiduciary-net-position percentage: **12.40%**, St. Albans Fire;
- South Charleston Fire: **13.33%**;
- South Charleston Police: **15.42%**;
- Martinsburg Fire: **19.72%**;
- all other plans: **23.53% or higher**.

Because every component ratio is above 3%, every municipality's positively weighted average is also above 3%, regardless of the weighting method. The complete [2025 extract](./20260826T044944Z_west-virginia-municipal-wage-tax-closure-artifacts/MPOB-2025-individual-plan-funded-ratios.csv) preserves all 53 results, source URLs, local source filenames, per-file hashes, byte counts, and page counts. All 53 official source PDFs and the reproducible extraction script are preserved with it. The minimum St. Albans source page was rendered and visually checked.

The Board's [Consolidated Actuarial Report 2024](https://mpob.wv.gov/actuarialreports/Pages/default.aspx), valued July 1, 2024 and carrying the fiscal-year 2026 contribution schedule, independently gives above-threshold market-value and actuarial-value ratios for all 53 plans. Its complete [extracted table](./20260826T044944Z_west-virginia-municipal-wage-tax-closure-artifacts/MPOB-2024-individual-plan-funded-ratios.csv) and minimum rows were also visually checked against the rendered source pages.

### 3. Additional statutory activation and termination gates

Even a municipality at or below 3% could not activate the tax automatically. [Section 8-13C-11](https://code.wvlegislature.gov/8-13C-11/) says the authority is not effective until the municipality presents the Joint Committee on Government and Finance with a plan to eliminate its police/fire pension liabilities and the necessary West Virginia-law changes are enacted.

[Section 8-13C-9](https://code.wvlegislature.gov/8-13C-9/) restricts proceeds to pension liability or qualifying bonds and terminates taxing authority when its funding, accumulation, or bond-retirement conditions occur.

Current §8-13C-3 and §8-13C-11 bill histories show the 2004 creating act and an unsuccessful 2009 bill, with no later signed amendment activating an occupational-tax adopter. The 2025 and 2026 code-affected-session searches produced no Article 13C change. This is corroborating change-window evidence; the current guidebook and complete plan data carry the current-zero conclusion.

### 4. No alternate Home Rule path

Current Home Rule law prohibits participating municipalities from adopting ordinances contrary to state pension or taxation law, apart from its expressly limited municipal sales-tax path. It also bars an occupation tax, fee, or assessment payable by a nonresident unless otherwise authorized by state law.

The Home Rule Board's [2025 annual report](https://www.wvlegislature.gov/legisdocs/reports/agency/M23_CY_2025_26930.pdf), dated January 1, 2026, records all current participants and their approved/implemented proposals. It contains no employee occupation, wage, or payroll tax. Current Huntington entries concern a municipal sales/service/use tax, not employee wages.

Huntington's proposed 1% occupation tax during the original Home Rule pilot is not a historical adopter. The Legislative Auditor's [November 2012 report](https://www.wvlegislature.gov/Joint/PERD/perdrep/HomeRule_11_2012.pdf) says Huntington agreed not to implement it, was enjoined, and retained its existing weekly service fee instead.

## Flat employee fees remain excluded

The 2026 WVSCPA chapter identifies these current municipal user/service fees on employees:

| Municipality | Flat fee |
| --- | ---: |
| Huntington | $5.00 per week |
| Charleston | $3.00 per week |
| Morgantown | $3.00 per week |
| Parkersburg | $2.50 per week |
| Fairmont | $2.00 per week |
| Weirton | $2.00 per week |
| Wheeling | $2.00 per week |
| Montgomery | $2.00 per week |
| Chester | $2.00 per week |
| Romney | $1.00 per week |

These charges may appear in payroll systems as local employee deductions, but they are not percentage taxes calculated from wages. Adding them would broaden the product definition and is intentionally not part of this registry.

## Registry disposition

- West Virginia coverage: `UNDETERMINED` → `COMPLETE`.
- West Virginia registry rows: 0 → 0.
- National registry rows: unchanged at **2,815** across **nine states**.
- Nationwide coverage: **16 `COMPLETE`**, **16 `NO_AUTHORITY_CONFIRMED`**, **10 `PARTIAL`**, and **9 `UNDETERMINED`**.
- Product screening: after authoritative address/state resolution, an unmatched West Virginia location may be treated as a current closed-zero result for this definition. This does not determine other local fees or taxes.

## Required refresh triggers

Refresh West Virginia immediately if any of the following occurs:

1. Article 13C, the Home Rule taxation restrictions, or related pension law changes.
2. A municipality presents an Article 13C pension-remediation plan or the Legislature enacts municipality-specific enabling law.
3. A new MPOB consolidated valuation shows any municipality's applicable police/fire funded percentage approaching or reaching 3%.
4. A municipality adopts an ordinance, withholding form, budget revenue line, or employer notice invoking §8-13C-3.
5. A later WVSCPA guidebook no longer reports zero adopters.

Absent an event-driven trigger, repeat the guidebook, current-code/bill-history, Home Rule inventory, and MPOB consolidated-report check annually.

## Preserved evidence

The [evidence manifest](./20260826T044944Z_west-virginia-municipal-wage-tax-closure-artifacts/README.md) preserves the 2026 WVSCPA chapter, the complete MPOB actuarial report, the current Home Rule report, the historical Huntington report, the extracted 53-plan table, source URLs, hashes, and extraction notes.
