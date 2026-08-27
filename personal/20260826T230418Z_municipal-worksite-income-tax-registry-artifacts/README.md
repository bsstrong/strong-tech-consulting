# Municipal Worksite Income Tax Research Snapshot — Nine-State Closure Run

This directory is the active replacement snapshot for the August 26, 2026 nine-state closure run. It began from the fully validated post-West Virginia snapshot in `../20260826T044944Z_municipal-worksite-income-tax-registry-artifacts/` and is updated, validated, committed, and pushed after each state iteration.

The nine-state run is complete. Subsequent Alabama and Kentucky verification passes on August 27 promoted 107 association-supported rows to direct primary, corrected current rates, added Falmouth and Hurstbourne Acres as secondary-supported current candidates, and retained Salem as future-dated effective October 1, 2026. The [final requirement-by-requirement audit](../20260827T140517Z_nine-state-municipal-wage-tax-completion-audit.md) remains the audit for the earlier nine-state run.

The registry now contains **2,817 municipality rows across nine states**: 2,743 direct-primary, 72 association-supported, and 2 current-secondary-supported. Idaho, Mississippi, Montana, Utah, Wyoming, Colorado, and Texas add no rows and move from `UNDETERMINED` to `NO_AUTHORITY_CONFIRMED`; South Dakota adds no rows and moves to a `COMPLETE` current zero; California adds no rows and moves to `PARTIAL`. Nationwide coverage is 17 `COMPLETE`, 23 `NO_AUTHORITY_CONFIRMED`, 11 `PARTIAL`, and 0 `UNDETERMINED`.

## Contents

- `U.S. Municipalities With a Worksite-Based Local Income Tax.md` - final readable report, definition, caveats, state dispositions, sources, and conclusions.
- `issue-1280-national-municipal-wage-tax-research.md` - detailed research notes, state-by-state evidence, and the West Virginia closure addendum.
- `worksite-municipal-income-tax-registry.csv` - product-oriented municipality registry in CSV form.
- `worksite-municipal-income-tax-registry.jsonl` - the same municipality registry with richer structured evidence.
- `worksite-municipal-income-tax-registry-validation.json` - validation of the final worksite registry.
- `worksite-municipal-income-tax-review-queue.md` - candidates and evidence tiers requiring manual review.
- `product-readiness-audit-2026-08-27.md` - final decision on what the registry can safely power, production blockers, required data views, and the deterministic three-result contract.
- `coverage-matrix.jsonl` - disposition and evidence coverage for all 50 states plus the District of Columbia.
- `normalized-municipal-tax-inventory.jsonl` - normalized screening inventory assembled before applying the final product definition.
- `review-only-and-nonmunicipal-inventory.jsonl` - excluded, nonmunicipal, or review-only records preserved for traceability.
- `inventory-validation-summary.json` - validation summary for the normalized inventory.
- `agent-extracts/` - the complete state extracts, Phase 2 audit reports, official-source snapshots, reconciliation datasets, source PDFs/workbooks, and extraction validation used by the reports.
- `agent-extracts/alabama-local-verification-2026-08-27.md` and `agent-extracts/alabama-primary-verification.csv` - the 20-row Alabama verification disposition and the nine direct-primary promotions.
- `agent-extracts/kentucky-local-verification-2026-08-27.md`, `kentucky-primary-verification.csv`, and the Kentucky SOS snapshot/validation - the 159-row Kentucky verification, 98 promotions, two current secondary additions, and future-dated Salem evidence.
- `source-audit-kentucky/` - the preserved Kentucky workbook audit input and inspection script.
- `build-normalized-inventory.ps1`, `build-worksite-municipal-registry.ps1`, and `extract-kentucky-klc-rates.py` - the build/extraction scripts used to produce the normalized and final registries.
- `snapshot-file-manifest.csv` - byte counts and SHA-256 hashes for every other file in this replacement snapshot.

Transient rendered-page PNGs, the linked runtime dependency directory, and the temporary local transcript-extraction binary are not duplicated here. They are working inputs/scratch files rather than research results; all locally accumulated tax-source documents, structured extracts, reports, and reproducibility scripts are preserved.

## West Virginia evidence

- [Closure report](../20260826T044944Z_west-virginia-municipal-wage-tax-closure.md)
- [Source and extraction manifest](../20260826T044944Z_west-virginia-municipal-wage-tax-closure-artifacts/README.md)
- [Latest 53-plan GASB 2025 funded-ratio extract](../20260826T044944Z_west-virginia-municipal-wage-tax-closure-artifacts/MPOB-2025-individual-plan-funded-ratios.csv)
- [Consolidated 2024 cross-check](../20260826T044944Z_west-virginia-municipal-wage-tax-closure-artifacts/MPOB-2024-individual-plan-funded-ratios.csv)

The current-zero conclusion is intentionally represented as `COMPLETE`, not `NO_AUTHORITY_CONFIRMED`, because Article 13C contains dormant conditional authority. Refresh the state whenever the statutory, pension-plan, enabling-act, or ordinance triggers in `coverage-matrix.jsonl` occur.

## Idaho evidence

- [Closure report](../20260826T230418Z_idaho-municipal-wage-tax-closure.md)
- [Source and complete-code audit manifest](../20260826T230418Z_idaho-municipal-wage-tax-closure-artifacts/README.md)

Idaho is `NO_AUTHORITY_CONFIRMED`: specific legislative authorization is required, the local/special tax-law path is constitutionally closed, and the complete current-code audit found no qualifying municipal employee wage-tax grant.

## Mississippi evidence

- [Closure report](../20260826T230418Z_mississippi-municipal-wage-tax-closure.md)
- [Source, administrative, and 30-session audit manifest](../20260826T230418Z_mississippi-municipal-wage-tax-closure-artifacts/README.md)

Mississippi is `NO_AUTHORITY_CONFIRMED`: specific state-law authorization is required; the current municipal tax framework, State Auditor/DOR systems, and the official 1997-2026 regular-session audit disclose no enacted municipal employee wage-tax grant. Five exact authorization bills died in committee, and the project-specific Job Development Assessment Fee is nonmunicipal.

## Montana evidence

- [Closure report](../20260826T230418Z_montana-municipal-wage-tax-closure.md)
- [Current-law and post-2025-session audit manifest](../20260826T230418Z_montana-municipal-wage-tax-closure-artifacts/README.md)

Montana is `NO_AUTHORITY_CONFIRMED`: specific delegation is required; the general municipal grants are property-only; DOR reports no city local-income-tax adopter; and the current 2025 code plus complete enacted-tax summary reveal no qualifying municipal employee wage-tax delegation.

## South Dakota evidence

- [Closure report](../20260826T230418Z_south-dakota-municipal-wage-tax-closure.md)
- [DOR and complete-current-code audit manifest](../20260826T230418Z_south-dakota-municipal-wage-tax-closure-artifacts/README.md)

South Dakota is a `COMPLETE` current zero: chapter 10-52 provides central advance notice and administration, the July 2026 DOR guide identifies no employee wage-tax category or adopter, and all 63 official consolidated title files contain no qualifying authorization or adopter. Broad non-ad-valorem and home-rule language remains, so the classification is intentionally not `NO_AUTHORITY_CONFIRMED`.

## Utah evidence

- [Closure report](../20260826T230418Z_utah-municipal-wage-tax-closure.md)
- [Constitutional, case-law, withholding, and complete-code audit manifest](../20260826T230418Z_utah-municipal-wage-tax-closure-artifacts/README.md)

Utah is `NO_AUTHORITY_CONFIRMED`: municipal tax power requires a legislative grant; section 10-1-203 excludes employees from its municipal business-tax definition; and the complete 96-title current-code audit found no qualifying employee wage-tax delegation or adopter.

## Wyoming evidence

- [Closure report](../20260826T230418Z_wyoming-municipal-wage-tax-closure.md)
- [Express preemption and complete-code audit manifest](../20260826T230418Z_wyoming-municipal-wage-tax-closure-artifacts/README.md)

Wyoming is `NO_AUTHORITY_CONFIRMED`: section 39-12-101 expressly preempts every local income tax, earnings tax, and other tax based on wages or income, and the complete 43-file current-code audit found no qualifying exception or adopter.

## Colorado evidence

- [Closure report](../20260826T230418Z_colorado-municipal-wage-tax-closure.md)
- [Constitutional, case-law, and flat-tax classification manifest](../20260826T230418Z_colorado-municipal-wage-tax-closure-artifacts/README.md)

Colorado is `NO_AUTHORITY_CONFIRMED`: the current constitution and controlling cases prohibit municipal income taxes, while current flat employee occupational taxes remain excluded because they are not calculated as a percentage or graduated amount of employee compensation.

## California evidence

- [Closure report](../20260826T230418Z_california-municipal-wage-tax-closure.md)
- [Current-law, historical-adopter, and statewide-screening evidence](../20260826T230418Z_california-municipal-wage-tax-closure-artifacts/README.md)

California is `PARTIAL`: current law and *Weekes* preserve an authority path for an employee occupational-license tax measured by worksite compensation, but Oakland's historical tax is repealed and the statewide Controller audit plus current municipal-code searches found no active adopter. No official source closes every current charter and ordinance, so unmatched California municipalities remain unresolved.

## Texas evidence

- [Closure report](../20260827T134945Z_texas-municipal-wage-tax-closure.md)
- [Constitutional, case-law, and current-practice evidence](../20260827T134945Z_texas-municipal-wage-tax-closure-artifacts/README.md)

Texas is `NO_AUTHORITY_CONFIRMED`: article VIII, section 1(f), *Brown*, JM-1195, and *Conlen Grain* make the state occupation-tax rate a constitutional ceiling for a municipal tax on the privilege of working. Texas levies no state occupation tax on employment or wage earning, so the in-scope municipal ceiling is zero; home-rule charters remain subordinate to that rule.
