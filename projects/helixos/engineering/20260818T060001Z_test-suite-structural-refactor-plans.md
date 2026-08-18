# HelixOS test-suite structural refactor plans

- Status: Draft for implementation planning
- Type: Refactor and test-performance remediation
- Intended implementer: Associate engineer with senior review
- Planning timestamp: 2026-08-18T06:00:01Z
- Inspected HelixOS revision: `843e80d1cad4b001de2cad4d8a387a54566f2480`

## Objective

Replace test-only interaction micro-optimizations with bounded structural refactors that give deterministic rules, async workflow state, and test fixtures a clear owner. Preserve all user-visible behavior, tenant boundaries, API contracts, and representative UI seams. Do not start an optimization PR until the revised hosted-baseline gate is satisfied.

## Evidence and selection

The only current hosted observation is `web-unit-timing` from Actions run `32100564304`, downloaded at `C:\Users\bsstr\AppData\Local\Temp\helixos-pr-1200-32100564304\attempt-1`. It is useful for ranking but **not** a valid optimization baseline: the new workflow requires three successful unchanged-tree samples with each target-total and tests/hooks range within 10% of its median.

| Priority | Target | Hosted total / tests-hooks | Structural evidence | Current disposition |
| --- | --- | --- | --- | --- |
| 1 | `src/web/src/features/client-detail/tabs/EmployeesTab.tsx` | 15.99s / 14.33s | 1,884 lines, 24 local-state declarations, 15 query/mutation calls; 479-line component test with 21 cases | Plan first; recheck adjacent Client Detail work before starting. |
| 2 | `src/web/src/features/client-detail/tabs/PayrollBatchesTab.tsx` | 21.69s / 19.91s | 825 lines, 10 local-state declarations, 13 query/mutation calls; 1,098-line component test with 50 cases | Plan second; high workflow and tenant-scope risk. |
| 3 | `src/web/src/features/utilities/payroll-providers/PayrollProviderManagementPage.test.tsx` | 24.95s / 22.86s | 178-line page already delegates to focused modules, but its 905-line test runs 23 full-page/MSW scenarios | Refactor the test boundary only after proving duplicated coverage. |

Excluded for now: `PlanDetailTab` overlaps PR #1057; `ClientEditorDialog` overlaps PR #1185 and PR #689; `OperationsDashboard` overlaps PR #1199; and `ZorkaStudioRulesetPage` overlaps PR #1193. Recheck open PRs and imported production seams immediately before any implementation.

## Shared rules and acceptance bar

1. Do not treat file size alone as a defect. Each extraction must have one cohesive owner and a public, directly testable contract.
2. Do not introduce `useEffect`, a catch-all `utils` module, a god hook, or a reducer that merely relocates all existing component responsibilities.
3. Keep remote data in React Query. Mutation variables must capture the exact company, tenant, employee/batch/run target, and payload snapshot; cache invalidation must use those captured values.
4. Preserve backend authorization and tenant scoping. UI affordances remain non-authoritative.
5. Before a performance PR, collect three successful hosted samples from a byte-identical target test, principal production seam, test infrastructure, and lockfile. Require target-total and tests/hooks ranges within 10% of their medians.
6. Retain a performance PR only if three exact-head hosted samples preserve behavior and improve both medians by at least 15%, remain within the 10% range limit, and do not materially regress the `web-unit` job. Local timing is diagnostic only.

## Requirements traceability

| Requirement | Source | Planned work | Validation |
| --- | --- | --- | --- |
| Replace god-component responsibilities with cohesive owners | `C:\dev\HelixOS\AGENTS.md`; `instructions/general/solid-principles.md` | Employees and Payroll Batches plans | Responsibility map, direct module tests, review checklist |
| Do not synchronize derived state through effects | `C:\dev\HelixOS\instructions\react\noeffect.md` | All three plans | Lint plus source review; derived values remain render-time selectors |
| Test deterministic behavior at its owner while keeping integration seams | `C:\dev\HelixOS\instructions\node\node-testing.md` | All three plans | Direct tests plus retained MSW/component boundary cases |
| Make performance claims only from stable hosted evidence | `C:\Users\bsstr\.codex\skills\run-helixos-test-optimization\SKILL.md` | Shared measurement phase | Three baseline and three exact-head artifacts, median/range table |

---

## Priority 1 — Employees Tab decomposition

### Current-state findings

`EmployeesTab` currently owns unrelated concerns: roster loading; batch selection; eligibility-result loading; tag and availability mutations; delete/restore actions; downloads; import dialog state; grid filtering and grid-column construction; realtime invalidation; and display formatting. It exports several deterministic functions in the same file, including `isSkipPayCycleTag`, `employeeHasSkipPayCycle`, `eligibilityFilterBucket`, `employeeFilterFlags`, `buildEmployeeGridColumnDefs`, `buildEmployeeUpdateInput`, and `nextAvailabilityElection`.

The component starts at `EmployeesTab` line 887. Its query/mutation graph begins at line 941 and includes payroll batches, files, employees, latest run status/detail, employee tags, update, tag, skip-pay-cycle, bulk availability, delete, and restore operations. The existing `EmployeesTab.test.tsx` exercises export, grid actions, and filters through MSW and the rendered grid, but no focused test file currently owns the deterministic helper contracts.

| Symptom | Root cause | Ownership failure | Planned correction |
| --- | --- | --- | --- |
| 1,884-line UI module with 24 local state declarations | Grid policy, employee payload construction, filters, and orchestration accumulated in the tab | Presentation owns deterministic policy and too many independent workflows | Extract policy modules first; then group server orchestration by roster workflow without moving presentation policy into a generic hook |
| Component tests arrange MSW/React/grid state to prove simple rule outcomes | Pure helpers are private to the UI module | Tests sit above the narrowest owner | Give each extracted policy module direct tests; retain only representative UI and request seams |
| Tenant-scoped requests and cache invalidation are interleaved with event handlers | The tab is both data boundary and UI coordinator | Mutation target/cached-resource ownership is difficult to audit | Require immutable mutation inputs and query-key inventory before moving any mutation |

### Target responsibilities and dependencies

Proposed names are intentionally scoped; create only modules whose extraction is supported by the initial characterization work.

| Proposed owner | Responsibility | May depend on | Must not own |
| --- | --- | --- | --- |
| `employee-roster-policy.ts` | Skip-pay-cycle classification, eligibility/filter buckets, flag derivation, and availability-election transitions | `@helixos/shared` types/constants | React, React Query, API calls, grid widgets |
| `employee-update-payload.ts` | The canonical `EmployeeSummary` plus patch to update-request mapping | Shared employee types | Fetching, cache writes, UI state |
| `employee-grid-columns.tsx` | Grid column definitions and narrowly scoped cell-renderer composition | Grid types, existing cell components, policy outputs | Queries, mutations, page selection state |
| `useEmployeeRosterMutations.ts` (only if characterization proves cohesive) | Employee/tag/availability/delete/restore mutation construction and captured-target invalidations | Request function, query client, explicit tenant/company context | Grid rendering, filters, dialogs, download UI |
| `EmployeesTab.tsx` | Compose queries, local transient UI state, child controls, and the focused mutation/query contracts | The above modules and existing child components | Reimplementing policy or payload construction |

Keep query ownership in the tab unless a cohesive query group can be named without combining unrelated network concerns. Do not create a single `useEmployeesTab` hook.

### Behavior-preservation inventory

| Invariant | Current evidence | Target evidence |
| --- | --- | --- |
| Active/terminated filtering, eligibility/enrollment/flag/label filtering, and quick search select the same roster | `EmployeesTab.test.tsx` filter-bar cases | Direct policy-table tests plus one rendered filter-bar case |
| Update payload retains required batch context and only changes requested fields | Rendered mutation tests; `buildEmployeeUpdateInput` in the tab | Direct payload cases for patch combinations plus one MSW PUT assertion |
| Tag, skip-pay-cycle, availability, delete, and restore actions use the selected employee and invalidate the right scope | Existing grid/action tests | Captured-input mutation tests and representative rendered action cases |
| Tenant-specific requests never fall back to an unscoped route | Existing MSW tenant paths | Query-key/request inventory plus negative MSW handlers that fail on unscoped routes |
| Export/import and eligibility dialogs remain accessible and permission-gated | Existing menu/grid tests and parent props | Retained component UAT seam tests |

### Ordered implementation work

1. **Characterize contracts and establish a baseline.** Recheck active PR overlap, fetch current main, inventory every query key, request URL, mutation payload, invalidation key, and permission prop. Add direct characterization tests around the existing helpers before moving them. Collect the required hosted baseline; stop if it is unstable.
2. **Extract deterministic employee policy.** Move classification, filter, election, and payload logic into the two focused modules above. Export only public feature contracts. Move exhaustive truth-table cases from component tests into module tests; keep a rendered filter and PUT seam case for each category.
3. **Separate grid composition.** Move column definitions and cell composition to `employee-grid-columns.tsx` only if it can remain free of network state. Pass a narrow, typed grid context. Preserve selection, keyboard access, action labels, and disabled/pending state behavior.
4. **Audit mutations rather than mechanically extracting them.** For each mutation, ensure the variable contains its employee and tenant/company scope; make success invalidation derive from variables. Extract only the mutually cohesive roster mutations if that leaves the tab smaller and clearer. Otherwise retain them in the tab with the new payload owner.
5. **Redistribute tests and measure.** Run direct policy/payload tests, retained component tests, the complete web suite, lint, theme check, build, and hosted post-change samples. Reject the performance claim if the shared optimization bar is not met.

### Risks, recovery, and UAT

The highest risk is a tenant/query-key or stale-mutation regression hidden by a structural move. Treat a discovered missing tenant key as a separate security defect, not an incidental refactor change; stop and obtain the required endpoint-to-policy inventory before changing it. Roll back by reverting the independently reviewable extraction commit; no persistence or API migration is planned.

Manual UAT: as a writer in two carrier workspaces, open Employees; switch status and filters; update a cell; add/remove a tag; toggle skip-pay-cycle; bulk-update availability; delete then restore an employee; run eligibility; exercise each export/import affordance; then switch workspace and confirm no stale roster or action targets appear.

---

## Priority 2 — Payroll Batches feed-workflow decomposition

### Current-state findings

`PayrollBatchesTab` owns batch/employee/eligibility data loading, feed-run selection and polling, post-pull watch-window state, pull/retry/force-retry/approve mutations, delete-dialog and eligibility-dialog state, timeline expansion, roster display formatting, and rendering of the feed status, trace, and categorized results surfaces. The component begins at line 120. Its server-state graph starts at line 178; mutations begin at line 324. Its test has 50 cases, global MSW handlers, and a mix of full-component workflow tests plus direct tests for `feedRunNeedsBatchRefresh` and retryability.

| Symptom | Root cause | Ownership failure | Planned correction |
| --- | --- | --- | --- |
| Feed lifecycle, polling eligibility, and UI dialog state coexist in one tab | No named feed-session boundary between server state and presentation | Lifecycle policy is hard to test without the full component | Introduce a pure feed-session policy module and narrowly scoped query/action adapters |
| Many rendered tests exist solely to establish feed status or request construction | Derived watch/poll decisions are embedded beside rendering | Deterministic workflow policy is not directly owned | Move state-selection and refresh decisions into direct tests; retain MSW cases for actual routes/mutations |
| Tenant path, active run, and post-pull refresh are coordinated across queries/mutations | Cached context and mutation targets are distributed | A refactor could accidentally use current UI selection after an async completion | Capture company, tenant, pay date, and run key in immutable mutation inputs and derive invalidation from them |

### Target responsibilities and dependencies

| Proposed owner | Responsibility | May depend on | Must not own |
| --- | --- | --- | --- |
| `payroll-feed-session-policy.ts` | Choose watched run, decide polling/refresh eligibility, derive pull/retry availability and user-facing phase inputs | Feed-run types and existing `payrollFeedRunState` constants | React, timers, requests, cache writes |
| `payroll-pull-request.ts` | Validate/normalize the pay-date input and build immutable pull/retry command inputs | Shared types and date helpers | UI dialogs, fetching |
| `usePayrollFeedRunQueries.ts` (proposed only after inventory) | Feed-run list/detail query definitions with tenant-complete keys and documented polling | Request function and feed-session policy | Batch deletion, eligibility UI, timeline rendering |
| `usePayrollFeedPullActions.ts` (proposed only after inventory) | Pull/retry/force-retry mutations and captured-target invalidation | Request function, query client, immutable command inputs | Dialog state and rendering |
| `PayrollBatchesTab.tsx` | Batch-level composition and transient dialogs; passes focused data/actions to existing `PayrollPullStatusCard`, `PayrollRunTracePanel`, and results panels | Existing visual components plus the above boundaries | Reimplementing lifecycle policy |

Do not merge the watch-window clock with server-state ownership. The policy module may calculate from an explicit `now` value; the React boundary owns obtaining `Date.now()` and supplying it. Do not add an effect to synchronize it.

### Behavior-preservation inventory

| Invariant | Current evidence | Target evidence |
| --- | --- | --- |
| Pull chooses the intended pay date, sends the tenant-scoped route, and disables/re-enables controls correctly | Existing pull and tenant-scope MSW tests | Direct command/policy tests plus one rendered pull request assertion |
| Reloaded failed/in-flight runs regain retry/progress visibility | Existing feed-run list/state cases | Direct watched-run selector matrix plus retained reload integration case |
| Polling continues only for queued/processing and documented settling states | Existing `feedRunNeedsBatchRefresh` tests | Expanded policy truth table with explicit `now`; one query adapter test |
| Retry/force retry/approve/delete mutate the exact batch or run and refresh the correct cache entries | Existing MSW mutation tests | Captured-variable tests plus representative component cases |
| Trace is PlatformAdmin-only and lazy; batch/roster PII rendering remains allowlisted | Existing component behavior and inline source safeguards | Permission/lazy-query tests and source-review checklist |

### Ordered implementation work

1. **Map workflow states before moving code.** Produce a table for `QUEUED`, `PROCESSING`, `FAILED`, `INGESTED`, absent run, and stale/settling states. For each, record visible controls, polling behavior, cache refreshes, and tenant route. Add missing direct characterization tests first.
2. **Extract pure session and command policy.** Move watched-run selection, refresh predicates, and pay-date command construction to focused modules. Use explicit `now` arguments for time-dependent decisions. Keep the existing `payrollFeedRunState.ts` as the authoritative lower-level lifecycle vocabulary; do not duplicate it.
3. **Create narrow React Query adapters only where cohesive.** Move feed-run queries and feed actions separately, with query keys that exactly match tenant-scoped request context. Each mutation must carry immutable target data; completion invalidations must read variables, not current selected state.
4. **Reduce component tests by layer, not by deleting coverage.** Move state matrices and command validation to direct tests. Retain component/MSW tests for pull, retry, reload restoration, force retry authorization, trace lazy loading, delete/approve, and categorized-results wiring.
5. **Validate lifecycle and measure.** Run focused tests, complete web tests, lint, theme check, build, and manual UAT. Use the hosted baseline/post-change gates; close rather than promote if the performance bar fails.

### Risks, recovery, and UAT

This is the highest-risk item because it combines payroll workflow progress, cross-tenant routing, polling, and privileged diagnostics. No schema or endpoint change is planned. If an extracted policy changes a state outcome, revert the affected vertical slice and retain the characterization test as a regression guard.

Manual UAT: as a Carrier writer, pull a valid pay period, observe queued/processing/terminal transitions, refresh the page mid-run, retry a failure, confirm batch/roster refresh after ingestion, and delete/approve where allowed. As PlatformAdmin, expand the trace and force retry; as a non-admin, verify those controls and requests do not appear. Repeat in a second carrier workspace to verify tenant isolation.

---

## Priority 3 — Payroll Provider Management test-boundary refactor

### Current-state findings

The production page is already appropriately thin: `PayrollProviderManagementPage.tsx` is 178 lines and delegates provider API/query keys, routing, detail loading, toolbar, new-provider dialog, and validation to focused modules. Recent history includes `refactor(payroll): finalize provider management` and merge commit `75827ccac` for PR #1165. A new page/component decomposition is therefore not justified.

The opportunity is the page test boundary. `PayrollProviderManagementPage.test.tsx` is 905 lines and runs 23 full-page/MSW scenarios. It repeatedly installs list/detail/path/validation/import handlers to reach behavior that may already be owned by `NewPayrollProviderDialog`, `PayrollProviderDetailLoader`, `PayrollProviderAdvancedJsonTab`, persistence/state modules, and API tests. The plan must first prove which assertions are duplicated; it must not delete a scenario merely because a child component has its own test.

| Symptom | Root cause | Ownership failure | Planned correction |
| --- | --- | --- |
| Slow 23-case full-page test suite despite a thin page | Page-level tests cover both orchestration and child-editor behavior | Test boundary is broader than the page responsibility | Keep page tests to route, selection lock/correction, list/error states, and create handoff; move only proven child behavior to existing child/module owners |
| Repeated large MSW handler arrangements | No single test-only owner supplies fresh, shape-realistic page fixtures | Setup is duplicated and can hide list/detail distinctions | Add a narrow test kit that creates fresh list summaries, detail records, and endpoint handlers without sharing mutable state |
| Earlier production refactor already moved rules into modules | Repeating the split would create churn | The proposed change would lack a structural cause | Stop after characterization if page coverage is not duplicated; do not force a refactor |

### Target responsibilities and dependencies

| Proposed owner | Responsibility | May depend on | Must not own |
| --- | --- | --- |
| `payroll-provider-management-page.test-kit.tsx` (test-only proposal) | Produce fresh list/detail fixtures and compose page-level MSW handlers for route/selection/create scenarios | Existing API contracts, MSW, test render helper | Business validation, production API behavior, a mutable shared fixture singleton |
| `PayrollProviderManagementPage.test.tsx` | Verify page composition: list load/error, selected-provider route, selection lock/route correction, empty state, and create handoff | Page test kit and real page public interface | Detailed editor JSON, persistence, import parsing, or publish policy |
| Existing child/module tests | Own editor, parser, validation, persistence, and API-specific behavior | Their current public contracts | Page route orchestration |

### Behavior-preservation inventory

| Invariant | Current evidence | Target evidence |
| --- | --- | --- |
| Provider route selects the requested provider and section | Page test route cases | Retained page route/selection tests |
| Pending save/publish locks selection and corrects the route | Page mutation-state cases | Retained page test with real mutation keys |
| Empty, initial load, and stale refresh error states render accessibly | Page error/empty cases | Retained page tests |
| New-provider draft normalization/validation and create request are correct | Page and `NewPayrollProviderDialog` coverage | Dialog/model direct tests plus one page create-handoff test |
| JSON/import/publish/persistence details remain covered | Page scenarios and focused child/module tests | Traceability matrix proving one authoritative child/module test per behavior |

### Ordered implementation work

1. **Build a page-to-owner traceability matrix.** List every one of the 23 page scenarios, its asserted behavior, current child/module owner, and whether it is a unique page seam. Do not move or remove coverage until each behavior has a target owner and one retained integration seam where needed.
2. **Introduce fresh test fixtures only if repetition is proven.** Add a narrowly typed test kit that distinguishes summaries from detail records and returns fresh objects/handlers per case. Do not create a generic testing utility or reuse mutable provider records across tests.
3. **Narrow the page suite.** Retain unique page orchestration cases. Move duplicated validation, parser, persistence, and import behavior to their existing focused test files only when the traceability matrix identifies missing direct assertions. Keep request-boundary tests at the API/persistence layer.
4. **Measure and decide.** Run the page suite, all payroll-provider focused tests, complete web tests, lint, theme check, build, then hosted samples. If the hosted criteria are not met, retain the clearer test boundary if it is behaviorally valuable but describe it as maintainability work, not a performance optimization.

### Risks, recovery, and UAT

The primary risk is a fixture abstraction that makes list and detail responses unrealistically identical or masks persistence sequencing. Require fresh fixtures and separate response shapes. No production behavior, schema, or API change is planned. Roll back by reverting the test-kit/page-suite change independently.

Manual UAT: open the provider-management route with no providers, a selected provider, and an invalid route section; create a provider; edit and save/publish a provider; trigger a load refresh failure while detail data is present; verify selection remains locked while save/publish is pending.

## Delivery sequence and validation

Treat each priority item as its own branch and review unit. Do not run them concurrently with overlapping Client Detail or payroll-provider PRs. For every unit: read current repository instructions and active PR files; collect the stable hosted baseline; make a small vertical extraction; run direct tests and retained component tests; run `npm run test -w @helixos/web -- <target>`, `npm run test -w @helixos/web`, `npm run lint -w @helixos/web`, `npm run theme:check -w @helixos/web`, `npm run build -w @helixos/web`, and `git diff --check`; then collect exact-head hosted samples.

No migration, deployment, feature flag, or external configuration change is planned for any item. Follow the repository's current PR lifecycle at implementation time; this note does not authorize a Ready transition, reviewer request, merge, or release.

## Reviewer checklist

- Each extracted module has one owner and no new generic helper/god hook.
- Query keys, request URLs, mutation variables, and cache invalidations preserve tenant and exact-target scope.
- No effect-driven prop/query-to-state synchronization, shadow refs, or stale-selection mutations appear.
- Direct tests own deterministic logic; component tests retain user-visible, permission, and request seams.
- Fixtures preserve list/detail shape and mutable-instance distinctions.
- Hosted evidence satisfies the optimization bar; otherwise the change is described only as a maintainability refactor or closed.

## Definition of done

- The selected responsibility boundary is demonstrably smaller and cohesive.
- Every preserved behavior in the relevant inventory has direct or seam coverage.
- No production API, authorization, tenant, or PII safeguard regresses.
- Local and hosted evidence is recorded separately; performance claims meet the current skill gate.
- The worktree is clean, applicable documentation is updated, and the repository lifecycle policy has been followed.
