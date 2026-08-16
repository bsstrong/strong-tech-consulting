# HelixOS — Select the next web-unit optimization

## Outcome

- Status: in-progress
- Repository: https://github.com/helixosio/helixos
- Objective: Review at least the latest 20 hosted web-unit timing runs and identify the next untreated, non-overlapping test-runtime optimization target.
- Started: 2026-08-16T04:32:24Z
- Analysis handoff: 2026-08-16T04:37:31Z
- Elapsed: 5m 07s
- Resumed: 2026-08-16T04:42:45Z
- Resumed objective: implement and validate the selected optimization, then create its Draft pull request.
- Implementation branch: `codex/optimize-desktop-workspace-tests`
- Pull request: https://github.com/helixosio/helixos/pull/1180 (Draft)
- PR created: 2026-08-16T05:00:28Z
- Base SHA: `75827ccac1e8f003ddd3518597674e9f56ba836e`
- Head SHA: `ed434432a97eb7e7800d2de4e8004cf13d1a9d52`
- Implementation commit: `ed434432a97eb7e7800d2de4e8004cf13d1a9d52`
- Local head at start: `e81c2706ca31c91c1e19a3adbede9d08c8d56e9f`
- Fetched `origin/main` at start: `75827ccac1e8f003ddd3518597674e9f56ba836e`
- Task/thread ID: unavailable in current execution context

The next target is `src/web/src/features/workspace/pages/DesktopWorkspacePage.test.tsx`: keep its workspace behavior coverage intact while removing duplicate child-page import work at the existing `PageResolver` seam and using hover-free user-event setup only for interactions whose contract does not involve hover.

## Evidence scope

- Hosted runs reviewed: 30 latest successful `HelixOS CI` runs, from run `31894516097` through `31925207424`; every artifact contained the complete `web-unit-files.json` timing report.
- Desktop Workspace over the latest 20 runs: 40.07s median total (26.13-43.46s), 32.25s median tests/hooks (21.40-35.11s), with 87/87 passing and no failures or skips in every sample.
- Desktop Workspace over all 30 reviewed runs: 40.66s median total (25.87-43.94s) and 32.87s median tests/hooks (20.26-35.39s). The latest sample was 40.2s total / 32.3s tests-hooks; the latest merged-main sample, run `31919269767`, was 32.24s / 25.73s with the same 87 tests.
- Current artifact import evidence: `PageResolver.tsx` costs 5.9s accumulated across two test files; `DesktopWorkspacePage.tsx` costs 5.2s in its suite; the Desktop Workspace file spends 6.8s in collection. The dedicated `PageResolver.test.tsx` already owns 20 passing child-page dispatch tests and measured 3.83s total / 1.28s tests-hooks.
- Suite shape on current `origin/main`: 87 hosted tests; 81 declared `it(...)` sites, 18 full workspace renders, 19 `userEvent.setup()` calls, 22 waits, and extensive direct deterministic workspace/layout policy coverage. The production page is a 2,741-line orchestration hotspot, so the optimization must keep the boundary narrow and avoid a mechanical broad refactor.
- Active pull-request overlap inventory: #1179, #1178, #1173, #1139, #1117, #1057, and #689. None changes `DesktopWorkspacePage.test.tsx`, `DesktopWorkspacePage.tsx`, or `PageResolver.tsx`. PR #1112, which previously blocked this target, merged at `4c1b17e1dc6f6bac4d3e8b13c060293df05f285c`.
- Higher nominal targets were excluded: `PlanDetailTab.test.tsx` and `ClientEditorDialog.test.tsx` were already optimized and are currently overlapped by open PRs #1057 and #689; `PayrollProviderManagementPage.test.tsx`, `OperationsDashboard.test.tsx`, and `PayrollBatchesTab.test.tsx` were already optimized, with Operations also overlapped by PR #1173.
- Prior optimization records reviewed: PRs #1092, #1114, #1116, #1131, #1141, #1144, #1147, and #1148, plus the full specialized-record inventory.

## Decision and follow-up

- Selected target: `src/web/src/features/workspace/pages/DesktopWorkspacePage.test.tsx`.
- Optimization seam: mock the already independently tested `PageResolver` child-content boundary in this workspace-orchestration suite so it no longer imports the application page tree a second time. Centralize `userEvent.setup({ skipHover: true })` for click/keyboard cases only where implicit hover is not asserted. Retain the dedicated `PageResolver.test.tsx` as the representative dispatch integration seam.
- Preserved behavior-sensitive interactions: real clicks, Escape handling, focus transfer, launcher selection, navigation, persona switching, tenant and permission readiness, workspace hydration/persistence, reset behavior, request scoping, and all 87 current Desktop Workspace assertions. Do not convert keyboard/focus-sensitive flows to direct events.
- Expected evidence gate: two matched focused baselines and two post-change samples under `TZ=UTC`, unchanged pass/fail/skip counts, one complete web-unit run, lint/build/theme/diff checks, then three hosted samples if implementation proceeds. Retain the change only if the matched median improves meaningfully.
- Risks or evidence gaps: hosted artifacts do not provide per-test timing, so the relative contribution of child imports versus implicit hover must be established by the matched local samples. No source changes were made during this analysis.

## Implementation and validation

- Implementation: replaced the duplicate child-page import tree in the Desktop Workspace orchestration suite with a focused `PageResolver` test double for the Operations content and Control Panel callback seams; centralized `userEvent.setup({ skipHover: true })` for the suite's non-hover interactions. Production code is unchanged.
- Local baseline samples: wall 40.281s and 39.595s (median 39.938s); file total 38.35s and 38.13s (median 38.24s); tests/hooks 28.23s and 27.29s (median 27.76s); collection 8.61s and 9.17s (median 8.89s); 87/0/0 in both.
- Local post-change samples: wall 31.440s and 28.163s (median 29.802s, -25.4%); file total 29.77s and 26.41s (median 28.09s, -26.5%); tests/hooks 23.38s and 19.91s (median 21.645s, -22.0%); collection 4.72s and 4.91s (median 4.815s, -45.8%); 87/0/0 in both.
- Focused seam validation: Desktop Workspace plus the real Page Resolver suite passed 107/107 tests.
- Complete web unit suite: 151 files and 1,487 tests passed in 214.064s wall time.
- Web lint, production build, theme literal check, and `git diff --check` passed. Build emitted only the existing Rollup annotation and chunk-size warnings.
- Mandatory architecture self-review: no production behavior, state ownership, authorization, transport, persistence, or public contract changed. The test double is scoped to workspace orchestration; the dedicated 20-test Page Resolver suite retains the real child-dispatch integration owner.
- Change size: 2 files, 96 additions, 19 deletions; documentation and one test harness only.
- Recorded resumed implementation-to-Draft handoff: approximately 18 minutes.
- Private exact-head self-review: requested at 2026-08-16T05:03:19Z for head `ed434432a97eb7e7800d2de4e8004cf13d1a9d52`; authenticated user `U0B9R7NJTQA` posted the canonical PR URL as the only parent text in verified `#self-reviews` channel `C0BMWSRGYDS`, thread `1786856599.310989`. The review bot acknowledged that GitHub will not be changed and began the inquiry.
- Hosted samples and exact-head CI: pending.

## Private review round 1

- Completed: 2026-08-16T05:07:27Z on head `ed434432a97eb7e7800d2de4e8004cf13d1a9d52`.
- Findings: 0 Blockers; 1 Non-blocker. The lightweight Operations resolver double rendered success content without asserting the tenant, capability, and navigation callbacks supplied by `DesktopWorkspacePage`.
- Disposition: fixed in commit `d7d29a6dc362f03568a71c0d4bb6fc7d90a4caa8`. The test double now captures its resolver props, and the Operations launcher test asserts tenant `nriver`, `operations.view`, the Operations window type, and both navigation callbacks.
- Blast radius: test-only capture and assertion at the Desktop Workspace-to-Page Resolver seam; no production, runtime, authorization, persistence, or child-page implementation changed. The dedicated Page Resolver suite remains the real dispatch owner, and no materially similar unconditional resolver-success boundary remains in this test double.
- Validation: Desktop Workspace plus Page Resolver passed 107/107 tests; web lint and `git diff --check` passed.
- Pull-request description updated with the finding, fix, validation, and exact current head.
- Rerun requested through authenticated-user Slack Web API at thread reply `1786857086.477179`; this is rerun cycle 1 of at most 3. Exact fetched base and merge base remain `75827ccac1e8f003ddd3518597674e9f56ba836e`.
- Timer: active heartbeat `pr-1180-self-review-rerun-check` checks the returned exact-head review after seven minutes and will be deleted when review completes.
