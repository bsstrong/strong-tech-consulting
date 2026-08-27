# California municipal wage-tax closure evidence

This directory supports the August 26, 2026 conclusion that no current California municipality was proven to impose an in-scope employee worksite wage tax. California is `PARTIAL`, not a categorical no-authority or complete-zero state, because current law preserves an employee occupational-license-tax path and no official statewide adopter register closes every local ordinance.

## Preserved sources

- `California-RTC-17041.5-current.html` — current official income-tax prohibition and business-license exception.
- `California-GOV-50026-current.html` — current official nonresident parity rule for otherwise-authorized employee earnings taxes.
- `California-GOV-37100.5-current.html` and `California-GOV-37101-current.html` — current official city taxing and business-license provisions.
- `source-extracts.md` records the controlling *Weekes* holding and public case URLs. A third-party full-page HTML shell was intentionally not retained because it included unrelated client-side service configuration.
- `Oakland-prior-code-table-current.html` — current Municode shell; the searchable current page records former section 5-1.65(e) through (s) as repealed by Ordinance 9700.
- `San-Francisco-Gross-Receipts-Tax-current.html` — official statement that Proposition F fully repealed the Payroll Expense Tax, generally applying in 2021.
- `San-Francisco-Administrative-Office-Tax-current.html` — official current employer-side tax description.
- `California-Controller-employer-payroll-tax-rows.csv` — all 6,670 public State Controller rows for `GENREV_EMP_PAYROLL_TAX`.
- `source-extracts.md` — legal holdings, current-adopter checks, dataset audit, source URLs, and limitations.
- `source-file-manifest.csv` — source URL, byte count, and SHA-256 for retained downloaded evidence plus metadata for the deleted oversized raw dataset.
- `artifact-manifest.csv` — byte count and SHA-256 for the final retained evidence package.

## State Controller audit

The complete raw City Revenues download was used locally but intentionally not retained because it was 817,277,453 bytes and exceeds the repository's 90 MiB evidence limit. Its source URL and SHA-256 are recorded in `source-file-manifest.csv` and `source-extracts.md`. The retained Socrata extract contains the complete standardized employer-payroll-tax field.

The raw dataset covers fiscal years 2002-03 through 2023-24 and contains 482 distinct FY2024 city entities. Exact phrase scans returned zero rows for `wage tax`, `earnings tax`, `income tax`, `employee license`, `occupational tax`, `occupation tax`, `gross payroll`, and `employee tax`. The only payroll-tax field was the employer category. Its 6,670 rows contained 22 nonzero values, all for San Francisco; 21 were positive and the FY2022 value was negative. San Francisco's official current page establishes that the underlying Payroll Expense Tax was fully repealed generally starting in 2021.

## Method and classification

Current statutes and *Weekes* prove a real legal authority path, so `NO_AUTHORITY_CONFIRMED` is unavailable. The historical Oakland ordinance is repealed, and current statewide reporting plus broad municipal-code searches found no active adopter. Because neither those searches nor the Controller revenue taxonomy is an exhaustive current ordinance register, the defensible result is `PARTIAL` with zero registry rows.

No California municipality may be treated as product-safe `CLEAR` solely from absence in this registry.
