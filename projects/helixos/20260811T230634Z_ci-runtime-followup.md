# HelixOS CI Runtime Follow-up

Follow up on the recent HelixOS CI runtime and runner-minute investigation without creating another issue in the HelixOS repository.

## Investigation context

- A pull-request CI run took 15m 24s elapsed and about 35 runner-minutes. Its critical `web-unit` job took 15m 19s.
- The web unit/component phase took 11m 47s at roughly 193% CPU. The 114 Vitest files accumulated 22m 30s of work across two fully occupied runner CPUs, so the job was already close to the two-core throughput limit.
- The largest web-unit test files were `PlanDetailTab.test.tsx` at 4m 02s, `ClientEditorDialog.test.tsx` at 2m 20s, and `PayrollProviderManagementPage.test.tsx` at 1m 21s.
- A main CI run took 18m 43s elapsed and about 49 runner-minutes. Its critical `web-cross-browser` job took 18m 40s.
- The cross-browser job ran 123 Playwright cases with one worker: the complete 41-test suite across Chromium, Firefox, and WebKit. Actual Playwright execution took 13m 43s. WebKit accounted for about 9m 02s, Firefox 2m 36s, and Chromium 1m 56s.
- Chromium is duplicated on main because the separate `web-e2e` job already runs the Chromium suite against the same SHA.
- A post-merge main control run with no overlapping HelixOS CI run remained slow: web-unit took 14m 49s and cross-browser took 17m 41s.
- Across recent runs, overlap with other HelixOS CI workflows had essentially no correlation with web-unit, Chromium E2E, or cross-browser job duration. GitHub gives each standard hosted job a fresh VM. This strongly rules out our simultaneous workflows as the cause of these particular slow runs, while still allowing general hosted-runner throughput variability.

## Follow-up options

1. Remove Chromium from the main-only cross-browser job because `web-e2e` already supplies that coverage. This should reduce both elapsed time and runner-minutes by roughly two minutes per main run.
2. Define a genuine Firefox/WebKit smoke subset for every main push and retain the complete cross-browser suite for the existing weekly schedule and manual dispatch. Evaluate the coverage tradeoff before changing the gate.
3. Benchmark the cross-browser suite with two Playwright workers. Measure runtime and flake rate because two browser workers would contend with the local API, web server, and PostgreSQL on a two-core runner.
4. Profile and reduce the slowest WebKit interactions, beginning with the approximately 51-second plan-policy test and the tests taking 20-30 seconds.
5. Profile the largest Vitest files and reduce repeated full-tree rendering and long high-level interaction sequences. Prefer smaller model or component tests where they preserve the same evidence.
6. Evaluate two-way Vitest sharding when feedback latency matters. It could reduce elapsed web-unit time to roughly 8-9 minutes but would duplicate setup and likely increase total runner-minutes.
7. Evaluate a four-core hosted runner only as a latency tradeoff. It should improve elapsed time but may increase direct cost and may not consume included standard-runner minutes.
8. Add a short CPU calibration measurement and record runner image, Azure region, and calibration score with the existing timing artifacts. Use it to distinguish test regressions from unusually slow hosted VMs.
9. Continue optimizing the backend critical path. The API unit phase still takes about 4m 48s, with `consolidated-sales-proforma-workbook.test.js` accounting for approximately 2m 26s.

## Suggested order

Start with the changes that can reduce both latency and runner consumption without adding machines: remove duplicate Chromium, define the intended cross-browser smoke coverage, and optimize the slowest WebKit and Vitest tests. Benchmark worker-count changes afterward. Treat sharding and larger runners as explicit latency-versus-cost choices.

Compare medians across several runs rather than relying on one hosted VM. Track elapsed critical-path time, total rounded runner-minutes, test failures/retries, and coverage changes for each experiment.
