# Municipal Worksite Income Tax Research Snapshot — Nine-State Closure Run

This directory is the active replacement snapshot for the August 26, 2026 nine-state closure run. It began from the fully validated post-West Virginia snapshot in `../20260826T044944Z_municipal-worksite-income-tax-registry-artifacts/` and is updated, validated, committed, and pushed after each state iteration.

The registry remains **2,815 municipality rows across nine states**. Idaho adds no row and moves from `UNDETERMINED` to `NO_AUTHORITY_CONFIRMED`. Nationwide coverage is now 16 `COMPLETE`, 17 `NO_AUTHORITY_CONFIRMED`, 10 `PARTIAL`, and 8 `UNDETERMINED`.

## Contents

- `U.S. Municipalities With a Worksite-Based Local Income Tax.md` - final readable report, definition, caveats, state dispositions, sources, and conclusions.
- `issue-1280-national-municipal-wage-tax-research.md` - detailed research notes, state-by-state evidence, and the West Virginia closure addendum.
- `worksite-municipal-income-tax-registry.csv` - product-oriented municipality registry in CSV form.
- `worksite-municipal-income-tax-registry.jsonl` - the same municipality registry with richer structured evidence.
- `worksite-municipal-income-tax-registry-validation.json` - validation of the final worksite registry.
- `worksite-municipal-income-tax-review-queue.md` - candidates and evidence tiers requiring manual review.
- `coverage-matrix.jsonl` - disposition and evidence coverage for all 50 states plus the District of Columbia.
- `normalized-municipal-tax-inventory.jsonl` - normalized screening inventory assembled before applying the final product definition.
- `review-only-and-nonmunicipal-inventory.jsonl` - excluded, nonmunicipal, or review-only records preserved for traceability.
- `inventory-validation-summary.json` - validation summary for the normalized inventory.
- `agent-extracts/` - the complete state extracts, Phase 2 audit reports, official-source snapshots, reconciliation datasets, source PDFs/workbooks, and extraction validation used by the reports.
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
