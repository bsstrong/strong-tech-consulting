# California source extracts and audit results

Research date: August 26, 2026

## Current law

- Revenue and Taxation Code section 17041.5 prohibits local taxes on income or any part of income, while preserving an otherwise-authorized license tax on a business measured by gross receipts.
- Government Code section 50026 regulates an otherwise-authorized local tax on the privilege of earning a livelihood by an employee or another tax measured by employee earnings. A nonresident may be taxed only when residents employed there face exactly the same tax, rate, credits, and deductions. The section does not itself authorize a tax prohibited by section 17041.5.
- Government Code section 37100.5 permits any city's legislative body to levy a tax a charter city may levy, subject to voter approval and other legal limits.
- Government Code section 37101 authorizes business-license taxes in general terms.

Official URLs:

- https://leginfo.legislature.ca.gov/faces/codes_displaySection.xhtml?lawCode=RTC&sectionNum=17041.5
- https://leginfo.legislature.ca.gov/faces/codes_displaySection.xhtml?lawCode=GOV&sectionNum=50026
- https://leginfo.legislature.ca.gov/faces/codes_displaySection.xhtml?lawCode=GOV&sectionNum=37100.5
- https://leginfo.legislature.ca.gov/faces/codes_displaySection.xhtml?lawCode=GOV&sectionNum=37101

## Controlling case and historical adopter

*Weekes v. City of Oakland*, 21 Cal.3d 386, 579 P.2d 449, 146 Cal.Rptr. 558 (1978), upheld Oakland Municipal Code section 5-1.65. The ordinance imposed an employee license fee for the privilege of working in Oakland, measured generally as one percent of Oakland-derived employee compensation, with employer withholding. The California Supreme Court held that it was an occupation tax rather than a prohibited income tax and that section 17041.5 did not bar it.

The current Oakland Municode prior-code table records former section `5-1.65(e)—5-1.65(s)` as `Repealed by 9700`. The current code page states that it is codified through Ordinance 13870, passed December 16, 2025.

Sources:

- https://law.justia.com/cases/california/supreme-court/3d/21/386.html
- https://library.municode.com/ca/Oakland/codes/code_of_ordinances?nodeId=PRCOTAOACA
- https://library.municode.com/ca/oakland/codes/code_of_ordinances

## State Controller dataset audit

Dataset: California State Controller, City Revenues, fiscal years 2002-03 through 2023-24.

- Full CSV download URL: https://bythenumbers.sco.ca.gov/api/views/rrtv-rsj9/rows.csv?accessType=DOWNLOAD
- Local raw bytes: `817277453`
- Local raw SHA-256: `B29682CB6F90C662090B9793877DC27FCFDF52F99DA2E12ED31CF18B43E22D3C`
- Distinct FY2024 entity names: `482`
- Exact raw-row match counts: `wage tax` 0; `earnings tax` 0; `income tax` 0; `employee license` 0; `occupational tax` 0; `occupation tax` 0; `gross payroll` 0; `employee tax` 0.
- Only payroll-related standardized field: `GENREV_EMP_PAYROLL_TAX`, labeled `Employers Payroll Tax_General Revenues`.
- Complete retained extract rows: `6670`.
- Nonzero rows: `22`, all San Francisco, FY2003-FY2024.
- Positive rows: `21`; FY2022 is a negative adjustment of `-5134410`.
- Latest FY2024 reported value: `4127334`.

Retained extract URL:

https://bythenumbers.sco.ca.gov/resource/rrtv-rsj9.csv?$limit=50000&$where=form_table%3D%27GENREV_EMP_PAYROLL_TAX%27&$order=fiscal_year%2Centity_name

The complete raw download was deleted after this audit because it exceeds the repository's 90 MiB evidence limit. Its URL, byte count, and hash preserve reproducibility without committing the oversized file.

## San Francisco classification

San Francisco's current Treasurer page says Proposition F, approved November 2, 2020 and generally applying starting in 2021, completed the transition to the Gross Receipts Tax and fully repealed the Payroll Expense Tax. The current Administrative Office Tax is imposed on persons engaging in business as an administrative office and is calculated as 1.47 percent of the business's San Francisco payroll expense for tax year 2025. Both are employer/business taxes, not employee-incidence worksite wage taxes.

Sources:

- https://sftreasurer.org/business/taxes-fees/gross-receipts-tax-gr-0
- https://sftreasurer.org/business/taxes-fees/administrative-office-tax-aot-0

## Residual gap

The Controller revenue taxonomy and current code searches are statewide screening evidence, not an official adopter registry. California's authority path exists, and the audit did not individually inspect the current charter and every tax ordinance for all 482 cities. The state is therefore `PARTIAL`, not `COMPLETE`, with zero proven current registry rows.
