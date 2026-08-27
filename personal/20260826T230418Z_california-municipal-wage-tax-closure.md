# California municipal worksite wage-tax closure

Research date: August 26, 2026

Disposition: `PARTIAL`

Registry rows added: 0

Active research time: approximately 44 minutes, within the one-hour state cap.

## Scope

This iteration applied the national registry's narrow definition: a city or city-equivalent percentage tax calculated from an employee's wages, earnings, compensation, or payroll because the employee works there, including nonresident commuters, with employer-withholding relevance.

It excludes resident-only taxes, employer-only payroll expense taxes, flat occupational or head taxes, county or special-district taxes, business profit and gross-receipts taxes, and sales or property taxes.

## Conclusion

California law preserves municipal authority for an employee occupational or license tax measured by worksite compensation, so California cannot be classified as a categorical no-authority state. The only identified California example, Oakland's former employee license fee, is repealed. Current statewide financial reporting, current municipal-code searches, and current tax pages found no active in-scope adopter. California therefore moves from `UNDETERMINED` to `PARTIAL`, with zero registry rows.

`PARTIAL` is deliberate. No official statewide register owns the employee-license-tax adopter universe, and this iteration did not individually audit every current charter and ordinance for all 482 cities represented in the Controller's FY2024 dataset. An unmatched California municipality is not product-safe `CLEAR`.

## Authority path

Revenue and Taxation Code section 17041.5 generally prohibits a city, county, or other political subdivision from imposing a tax on income or any part of income. Its final paragraph preserves an otherwise-authorized license tax on a business measured by gross receipts.

Government Code section 50026 expressly regulates an otherwise-authorized local tax on an employee's privilege of earning a livelihood or any other tax measured by employee earnings. It permits application to nonresident employees only when the same tax, rate, credits, and deductions apply to residents employed in the jurisdiction. It does not independently authorize a tax prohibited by section 17041.5.

Government Code section 37100.5 permits any city's legislative body to levy a tax that a charter city may levy, subject to voter approval and other limits. Section 37101 separately provides general business-license authority.

In *Weekes v. City of Oakland*, 21 Cal.3d 386 (1978), the California Supreme Court upheld Oakland's one-percent employee license fee measured by compensation for services performed in Oakland. The court classified it as an occupation tax rather than an income tax and held that section 17041.5 did not bar it. The tax applied to the worksite and included employer withholding, making it an in-scope historical example and confirming that the authority path is real.

## Current-adopter audit

- Oakland's current Municode prior-code table records former section 5-1.65(e) through (s), the provisions underlying the employee license fee, as repealed by Ordinance 9700. The current Oakland code is codified through Ordinance 13870, passed December 16, 2025.
- The California State Controller's city-revenues dataset covers fiscal years 2002-03 through 2023-24 and contains 482 distinct FY2024 city entities. Exact scans found no rows labeled wage tax, earnings tax, income tax, employee license, occupational tax, occupation tax, gross payroll, or employee tax.
- The dataset's only standardized payroll-tax field is `GENREV_EMP_PAYROLL_TAX`, labeled Employers Payroll Tax. It contains 6,670 city-year rows. Only San Francisco reports nonzero values: 22 nonzero rows from FY2003 through FY2024, including a negative FY2022 adjustment; 21 are positive.
- San Francisco's current Treasurer page says Proposition F, generally applying in 2021, fully repealed the Payroll Expense Tax. Its current Administrative Office Tax is calculated from the business's payroll expense and is imposed on businesses, so it is an excluded employer tax rather than an employee wage tax. Later Controller receipts do not establish a current employee tax.
- Broad current searches of official California municipal sites and code publishers for employee license fees, wage taxes, earnings taxes, and occupational taxes found no active California employee-wage adopter beyond the repealed Oakland example.

## Product treatment

- California coverage: `PARTIAL`
- Registry rows: zero
- An unmatched California municipality remains unresolved and must not return `CLEAR` merely because it is absent from the registry.
- A municipality may be promoted only after current local primary law proves either an active in-scope tax or a closed local zero.
- Refresh after a change to sections 17041.5, 50026, 37100.5, or 37101; a controlling case; a ballot measure; or discovery of a current municipal employee-license tax.

## Primary sources

- [California Revenue and Taxation Code section 17041.5](https://leginfo.legislature.ca.gov/faces/codes_displaySection.xhtml?lawCode=RTC&sectionNum=17041.5)
- [California Government Code section 50026](https://leginfo.legislature.ca.gov/faces/codes_displaySection.xhtml?lawCode=GOV&sectionNum=50026)
- [California Government Code section 37100.5](https://leginfo.legislature.ca.gov/faces/codes_displaySection.xhtml?lawCode=GOV&sectionNum=37100.5)
- [California Government Code section 37101](https://leginfo.legislature.ca.gov/faces/codes_displaySection.xhtml?lawCode=GOV&sectionNum=37101)
- [*Weekes v. City of Oakland*, 21 Cal.3d 386](https://law.justia.com/cases/california/supreme-court/3d/21/386.html)
- [Oakland prior-code disposition table](https://library.municode.com/ca/Oakland/codes/code_of_ordinances?nodeId=PRCOTAOACA)
- [California State Controller city-revenues dataset](https://bythenumbers.sco.ca.gov/Government/City-Revenues/rrtv-rsj9/about_data)
- [San Francisco Gross Receipts Tax history](https://sftreasurer.org/business/taxes-fees/gross-receipts-tax-gr-0)
- [San Francisco Administrative Office Tax](https://sftreasurer.org/business/taxes-fees/administrative-office-tax-aot-0)
- [Preserved evidence and audit details](./20260826T230418Z_california-municipal-wage-tax-closure-artifacts/README.md)

## Limitations

The Controller dataset is a strong statewide screening source, not an authoritative catalog of every legal tax label or ordinance. Revenue labels can omit or aggregate a levy, and receipts after repeal can reflect prior-period collections or adjustments. Search-engine and code-publisher coverage is also incomplete. Those gaps prevent `COMPLETE`, but the evidence is sufficient to replace `UNDETERMINED` with a documented `PARTIAL` current-zero finding.
