# Web test-boundary maintenance refactor plan

## Plan metadata

- **Status:** Draft for renewed architecture and test-boundary review
- **Plan type:** Refactor and security remediation; performance investigation is a separate track
- **Repository:** `helixosio/helixos`
- **Inspected revision:** PR #1201 head `f1fdcda2d2e778cc0efc418fa820eccfc702f02b`; target files were confirmed unchanged on `origin/main` at `0a0001fe0`
- **Intended implementer:** Associate engineer working under the repository's current pull-request policy
- **Primary evidence:** PR #1200 hosted timing; GitHub Actions run `32100564304`; `docs/operations/ci-timing-instrumentation.md`; PR #1201 private and production reviews; current source and tests

## Objective and outcome

Treat three verified responsibility and test-placement hotspots as maintainability work, not as test-speed optimizations:

1. correct tenant/cache and asynchronous-mutation targeting defects before moving code;
2. decompose `EmployeesTab` along existing roster, grid, and eligibility-lifecycle boundaries;
3. consolidate Payroll Batches feed-session ownership around the existing lifecycle model;
4. redistribute Payroll Provider Management coverage only after missing focused test owners exist.

Completion means each responsibility has one authoritative owner, tenant and mutation targets are immutable and tested, deterministic behavior is tested without importing the page component, and representative rendered/MSW seams remain. No runtime improvement is promised by these maintenance refactors.

## Why the performance framing was removed

PR #1200 improved matched local Admin Console samples but regressed in three hosted samples: target-total median was 30.8 seconds versus a 24.3-second stored baseline (+26.7%), while all 19 cases still passed. It was closed.

The first production review of this plan then demonstrated that its replacement gate was also unsound:

- the gate measured only the original test file even though the proposed work moves cases into new files;
- every isolated jsdom/fork test file carries roughly 0.5-1.2 seconds of hosted fixed cost in the inspected samples, so target-file improvement can hide a suite regression;
- CI uses two workers on a two-vCPU runner, and Vitest 3.2.4 cold-cache ordering is size-dependent, so shrinking a file changes its contention neighbor;
- the three targets represented about 1% of accumulated file time and 2% of command wall time in the matching hosted samples, below a defensible suite-level optimization claim;
- a 5% full-job guard allowed roughly 46 seconds of regression against candidate effects measured in only a few seconds.

Accordingly, the former 15% target-file gate, duplicate target-total/tests-hooks legs, 10% range rule, and 5% full-job guard do not apply to the maintenance work below. Timing remains a diagnostic and a no-obvious-regression check. Any performance claim must use the separate measurement track at the end of this plan.

Several earlier recorded web-test optimizations were retained on local evidence with hosted confirmation still outstanding. PR #1200 was the first in this cadence to receive the prescribed hosted check, and it failed. Those entries are not evidence that test redistribution improves hosted runtime.

## Current evidence baseline

Counts below were measured from the inspected revision; remeasure immediately before implementation.

| Priority | Production target | Test target | Verified current evidence | Disposition |
| --- | --- | --- | --- | --- |
| 1 | `EmployeesTab.tsx` | `EmployeesTab.test.tsx` | 1,965 / 561 lines; 21 cases; component owns 20 state values, 6 queries, and 7 mutations | Maintenance refactor after security prerequisite |
| 2 | `PayrollBatchesTab.tsx` | `PayrollBatchesTab.test.tsx` | 875 / 1,274 lines; 50 cases; 9 pure lifecycle cases live in the component suite | Maintenance refactor after security prerequisite |
| 3 | `PayrollProviderManagementPage.tsx` | `PayrollProviderManagementPage.test.tsx` | 187 / 1,014 lines; 23 cases; page is already thin, but three critical production owners lack direct tests | Test-boundary maintenance only |

The hosted target totals from run `32100564304` remain useful for ranking, not acceptance: Employees 15.99 seconds, Payroll Batches 21.69 seconds, and Provider Management 24.95 seconds.

## Shared constraints

- Never call `useEffect` directly. Use React Query lifecycle, event/mutation callbacks, render-derived values, keyed remounting, or `useMountEffect` only for one-time external setup/cleanup.
- Keep React Query as the owner of remote state. Do not mirror query data into local state.
- Every tenant-scoped query key must include the same tenant identity used by its request URL, and must remain disabled until tenant context is available.
- Every mutation must receive an immutable input containing tenant, company, batch/run/employee target, and payload snapshot as applicable. Transport, completion handling, and invalidation must use those variables.
- Preserve server authorization, PlatformAdmin-only diagnostics, tenant-scoped routes, PII allowlists, accessibility, and representative UI seams.
- Use local camelCase filenames. Do not add generic test kits, `utils` modules, broad controller hooks, or one-file-per-function ceremony.
- A direct policy test must import no page/component module. Moving cases within the original component test does not create a lower-cost or clearer test boundary.
- Preserve behavior coverage, not test-file counts. Retain at least one integration assertion for every important UI/request/cache seam.

## Requirements traceability

| Requirement | Source | Planned work | Validation |
| --- | --- | --- | --- |
| Reclassify the three candidates as maintenance work | PR #1201 final review and hosted arithmetic | All three maintenance review units; separate performance track | PR descriptions make no target-file speed claim |
| Fix tenant-incomplete cache keys before extraction | PR #1201 security review and current query inventory | Review unit 0.1 | Two-tenant shared-cache and negative unscoped-request tests |
| Remove current-selection mutation targeting | PR #1201 security/architecture review | Review unit 0.2 | Deferred/out-of-order mutation tests using captured variables |
| Reuse existing grid and feed-state owners | PR #1201 architecture review | Employees and Payroll Batches target maps | Direct owner tests and complete-diff architecture review |
| Give Provider Detail Loader, persistence, and editor behavior direct owners | PR #1201 test-strategy review | Provider review unit | Checked 23-case traceability matrix and focused tests |
| Make any future performance evidence include relocated work | PR #1201 measurement review | Separate CI performance investigation | Affected-set manifest, command wall time, five hosted pairs, confidence interval |

## Decisions and assumptions

### Confirmed decisions

- The three structural candidates are maintenance/testability refactors, not CI optimizations.
- Tenant/cache and mutation-target defects are a prerequisite security/correctness review unit.
- Provider test redistribution cannot begin by deleting page coverage; missing direct owners are created first.
- Performance experiments use separate scope, acceptance criteria, and review evidence.

### Implementation assumptions to revalidate

- The named target files remain unchanged when each review unit starts.
- The PlatformAdmin timeline endpoint remains intentionally tenant-free and independently authorized.
- Existing API request/response contracts and server authorization remain unchanged.
- Active overlapping pull requests do not modify the same production seams.

If any assumption is false, stop before extraction, update the responsibility/behavior inventory, and obtain senior review of the revised boundary. No unresolved product, schema, or authorization-policy decision is delegated to the implementer.

## Delivery sequence

These are separate review units. Land the security/correctness prerequisite first. Each later unit starts from the integrated result and must recheck overlapping active pull requests.

1. Tenant/cache and mutation-target remediation.
2. Employees maintenance refactor.
3. Payroll Batches feed-session maintenance refactor.
4. Payroll Provider Management test-boundary maintenance refactor.
5. Optional CI measurement experiments, separately justified and reviewed.

Do not combine the three maintenance refactors into one implementation PR.

## Review unit 0: tenant/cache and mutation-target remediation

### Root cause

The original plan described tenant isolation and immutable mutation targeting as preserved invariants, but the current source violates them. Moving the current query/mutation definitions into new hooks would launder those defects into new owners and make a "behavior-preserving" claim false.

In `EmployeesTab`, five tenant-scoped queries omit tenant identity from their keys. `employee-tags` includes tenant but can run before tenant resolution. `eligibility-run-detail` can also run without `hasTenantCode`. The manual eligibility poller currently masks a mismatch between the latest-status key and realtime invalidations.

In `PayrollBatchesTab`, batches, eligibility runs, categorized results, and roster keys omit tenant identity. The recent-run and watched-run queries can run before tenant resolution. The admin timeline is intentionally tenant-free because it uses the separately authorized PlatformAdmin endpoint.

`EligibilityRunsDialog`, shared by both target tabs, repeats the incomplete `payroll-batches` and `eligibility-runs` keys. Its delete mutation also uses the initial `payrollBatchKey` after the in-dialog batch selector can change. The remediation must cover this shared child and every equivalent consumer or invalidator of those key families, not only the two tabs.

Several mutations derive transport or invalidation targets from closed-over selection state. The clearest defect is `deleteEmployeeMutation.onSuccess`, which reads `employeePendingDelete` instead of its mutation variable.

### Work item 0.1: make tenant identity authoritative in cache keys

- **Affected code:** `EmployeesTab.tsx`, `PayrollBatchesTab.tsx`, shared `EligibilityRunsDialog.tsx`, `useClientEligibilityRealtime.ts`, every other web consumer or invalidator of the `payroll-batches` and `eligibility-runs` key families (currently `EmployeeDetailPage.tsx`, `EmployeeEligibilityTab.tsx`, `EligibilityRunHistoryTab.tsx`, `ClientAuditTab.tsx`, and `CensusBuilderTab.tsx`), their focused tests, and any shared query-key module introduced by the implementation.
- **Changes:** inventory every query URL, key, enabled predicate, invalidation, and realtime invalidation across the complete affected key families; include resolved tenant identity in every tenant-scoped key; require tenant resolution before every tenant-scoped request; canonicalize payroll-batch and eligibility run-list/detail key families so kickoff, delete, component, and realtime invalidations target the same tenant-complete keys. Explicitly classify independently authorized or non-tenant-scoped cases.
- **Preserved invariants:** the PlatformAdmin timeline remains tenant-free and separately authorized; no client-side change weakens server enforcement.
- **Tests:** mount two client windows under one shared `QueryClient` with different tenants, including the shared dialog and equivalent consumers; prove batches, employees/roster, eligibility, and feed runs never cross caches; install negative bare-`/api` handlers and prove no request occurs before tenant resolution.
- **Acceptance:** no tenant-scoped URL has a tenant-free key or an enabled path without tenant context.

### Work item 0.2: capture every mutation target

- **Affected code:** employee update/tag/skip/availability/delete/restore mutations; payroll pull/retry/force-retry/approve/delete mutations; the `EligibilityRunsDialog` delete mutation; focused tests.
- **Changes:** define immutable mutation variables containing the exact tenant, company, batch/run/employee, and payload snapshot; use variables for request construction, completion handling, and invalidations; remove closed-over current-selection targeting.
- **Tests:** switch employee, batch, company, and tenant selections while deferred mutations are pending; in `EligibilityRunsDialog`, select another batch before delete and switch again before the deferred DELETE resolves; resolve out of order; prove each request, response, and invalidation uses only its captured tenant/company/batch/run/employee target.
- **Acceptance:** no mutation request or cache write depends on whichever entity is selected when the request finishes.

### Security validation

The PR description must include a query-key/URL/enabled/invalidation matrix for both components, `EligibilityRunsDialog`, realtime invalidations, and every equivalent `payroll-batches`/`eligibility-runs` consumer or invalidator. It must explicitly identify PII-bearing roster/employee caches, classify intentional exclusions, and show two-tenant negative-space plus selector-switch/deferred-delete tests. This remediation is a correctness/security change, not a performance change.

## Review unit 1: Employees maintenance refactor

### Current responsibility map

`EmployeesTab` composes payroll batches, files, employees, eligibility status/detail, and tags; seven mutation workflows; filters/search/grid selection; import/export; dialogs/snackbars; realtime eligibility; deterministic projection/update rules; and a hand-written eligibility poller.

`runEligibilityForEmployee` is a 59-line POST-plus-poll workflow with up to twenty two-second waits, result projection, UI messages, and invalidation. No current `EmployeesTab` test executes that loop, so extracting it improves ownership and direct testability but does not explain the measured 14.3-second component-test time.

The current PUT test forces a 409 and does not inspect the update body. `buildEmployeeUpdateInput` therefore needs characterization before it moves.

### Target responsibility map

| Owner | Cohesive responsibility | Must not own | Direct evidence |
| --- | --- | --- | --- |
| Proposed `employeeRosterProjection.ts` | Eligibility bucket, active roster flags, tag/label projection, and `employeeMatchesRosterFilters` | React, grid, requests, cache, availability transitions | `employeeRosterProjection.test.ts` importing no component |
| Proposed `employeeRosterUpdate.ts` | Availability/review transitions and canonical employee update input | React, requests, cache | `employeeRosterUpdate.test.ts` importing no component |
| Existing `employeeGridCells.tsx` | Roster identity/eligibility/enrollment/flags/action cells and, only if cohesive, `buildEmployeeRosterColumnDefs` | Queries, mutations, dialog ownership | Expanded `employeeGridCells.test.tsx` |
| Proposed `executeEmployeeEligibilityRun.ts` | Abortable POST plus exact-run terminal polling with injected request/delay/clock | React state, snackbars, cache | Deterministic executor tests with no real waits |
| Proposed `useEmployeeEligibilityRun.ts` | One mutation lifecycle that captures exact variables, exposes pending/error/result, invalidates canonical keys, and aborts on unmount | Other roster mutations, filters, grid/dialog state | Focused hook tests |
| Existing `EmployeesTab.tsx` | Server-state composition, transient filters/search/selection/dialogs, import/export, and focused child contracts | Reimplementation of the owners above | Reduced representative component/MSW seams |

Do not create `employeeGridColumns.tsx`. The builder references local row-action cells and would drag roughly 250 lines of context/action plumbing. Keep eligibility builders in `employeeEligibilityGrid.ts`; move cohesive roster presentation into the existing `employeeGridCells.tsx`, or leave the builder in the tab if the move would make that owner incoherent.

Do not split tag identity into another file unless it proves independently useful. Avoid 4-6 one-function policy files whose isolated jsdom/fork tests add fixed suite cost.

### Behavior-preservation inventory

| Behavior | Current proof | Target proof |
| --- | --- | --- |
| Status, eligibility, enrollment, flags, labels, and quick search | Rendered filter cases | Projection truth tables plus one rendered filter seam |
| Update mapping and patch precedence | Missing/indirect; 409 PUT does not inspect body | Direct update cases plus one successful MSW PUT body assertion |
| Availability/review transitions | Broad component interaction | Direct transition table plus one bulk-action seam |
| Tag, skip-pay-cycle, delete, and restore target the exact employee | Rendered action cases, with known closure defect | Captured-variable tests plus representative row actions |
| Eligibility kickoff/poll/result/timeout/cancel | Not directly covered | Executor and hook tests plus one click-to-result component seam |
| Tenant isolation and no unscoped fallback | Incomplete today | Prerequisite two-tenant and negative bare-`/api` tests |
| Import/export and eligibility permissions/accessibility | Rendered menu/grid cases | Retained component seams and manual UAT |

### Ordered work

1. Land review unit 0 and rebaseline current counts against the exact implementation head.
2. Add missing characterization for update mapping and eligibility lifecycle.
3. Extract `employeeRosterProjection.ts` and `employeeRosterUpdate.ts`; move exhaustive deterministic cases to direct tests.
4. Consolidate cohesive roster cells into `employeeGridCells.tsx`; rename `EmployeeUpdateCell` to `EmployeeRowActionsCell`; keep dialog/mutation implementations outside grid presentation.
5. Extract the abortable eligibility executor and its single-concern hook. On kickoff, invalidate/refetch the canonical run-list key so declarative status polling and realtime invalidation remain aligned. Stop on completed, failed, timeout, cancellation, or request error; never project another employee's result.
6. Consider a roster-mutation hook only if one cohesive lifecycle remains. Reject it if it requires many UI setters or combines unrelated tag/delete/availability workflows.
7. Reduce component cases only after every moved assertion has a direct owner; run manual UAT in two tenant workspaces.

### Manual UAT

As a Carrier writer: switch filters; update an employee; add/remove a tag; toggle skip-pay-cycle; bulk-update availability; delete/restore; run eligibility through success and failure; use import/export. Switch to a second Carrier workspace while requests are pending and confirm no stale rows, action targets, cache data, or tenant paths cross windows.

## Review unit 2: Payroll Batches feed-session maintenance refactor

### Current responsibility map

`PayrollBatchesTab` combines batch/employee/eligibility queries, feed-run selection and polling, post-pull watch state, pull/retry/force-retry actions, timeline expansion, dialogs, roster formatting, and results composition.

`payrollFeedRunState.ts` already owns retryability, automatic retry, batch-refresh policy, polling interval, and watch-window constants. Nine pure lifecycle cases currently live inside `PayrollBatchesTab.test.tsx`.

### Target responsibility map

| Owner | Cohesive responsibility | Must not own | Direct evidence |
| --- | --- | --- | --- |
| Existing `payrollFeedRunState.ts` | Lifecycle vocabulary plus the missing watched-run selector | React, requests, cache, UI feedback | New `payrollFeedRunState.test.ts` |
| Proposed `useFeedPullSession.ts` | Active run key, watch deadline, recent/detail queries, pull/retry/force-retry mutations, and session feedback as one lifecycle | Batch delete/approve, eligibility, roster rendering, admin trace | `useFeedPullSession.test.tsx` |
| Existing `PayrollBatchesTab.tsx` | Batch/eligibility/roster composition, transient batch dialogs, PlatformAdmin trace, and results presentation | Duplicated feed-session state/policy | Reduced representative component/MSW seams |

Do not create `payrollFeedSessionPolicy.ts`; it would duplicate the existing state module. Do not split queries from pull actions: each action activates the exact run, opens the watch deadline, and owns feedback, so the cohesive boundary is the feed-pull session. Never call `useEffect` directly; use query polling and event-driven state.

### Behavior-preservation inventory

| Behavior | Current proof | Target proof |
| --- | --- | --- |
| Active session run wins; reload restores latest non-ingested run | Component suite | Direct selector matrix plus reload seam |
| Queued/processing/ingested/failed refresh and retry rules | Nine pure cases inside component test | `payrollFeedRunState.test.ts` with explicit clock |
| Pull/retry/force-retry target exact tenant/company/pay-date/run | MSW cases | Captured-variable hook tests plus representative rendered requests |
| Batch/roster refresh survives ingestion settling | Component/query behavior | Hook/state tests plus one integration seam |
| Admin trace remains PlatformAdmin-only, tenant-free, lazy, and live | Rendered behavior/source guard | Retained permission/lazy-query component tests |
| Roster PII remains allowlisted | Inline security safeguard and rendering | Source-review checklist plus retained roster seam |

### Ordered work

1. Land review unit 0 and create a state table for absent, queued, processing, failed, ingested, and settling runs.
2. Add `payrollFeedRunState.test.ts`; move the nine pure cases and add watched-run selector cases.
3. Extract `useFeedPullSession.ts` with immutable inputs and tenant-complete query keys. Keep session notice/error state inside this lifecycle; expose a narrow result/actions contract.
4. Leave trace, batch deletion/approval, eligibility, and roster presentation in the tab.
5. Reduce the component suite only after direct owners exist; retain pull, reload restoration, retry, force-retry permission, tenant routing, progress/failure, approval/deletion, roster, and categorized-result seams.
6. Run two-workspace/persona UAT and record any timing only as diagnostic evidence.

### Manual UAT

As a Carrier writer: pull a pay period; observe queued, processing, completed, and failed states; refresh mid-run; retry; confirm post-ingestion batch/roster refresh; approve/delete where permitted. As PlatformAdmin, open trace and force retry; as non-admin, confirm those controls and requests do not exist. Repeat in a second Carrier workspace.

## Review unit 3: Payroll Provider Management test-boundary maintenance refactor

### Corrected premise

The 187-line production page is already thin. The 1,014-line page test owns critical behavior because `PayrollProviderDetailLoader.tsx`, `usePayrollProviderPersistence.ts`, and `PayrollProviderEditor.tsx` have no direct tests. Existing dialog/advanced-JSON tests are too thin to receive that coverage.

Do not create `payrollProviderManagementPage.testKit.tsx`. `usePayrollProviderHandlers()` already serves 11 cases; the remaining cases intentionally need counters, deferred gates, mutable server records, or failure toggles. Existing factories already return fresh nested objects and distinguish list summaries from detail records. A parameterized kit would become an over-configurable fixture owner.

### Add missing focused owners first

| Proposed test owner | Required direct coverage |
| --- | --- |
| `PayrollProviderDetailLoader.test.tsx` | Detail-vs-summary identity, delayed hydration, mismatched detail rejection, retry, preserved selection |
| `usePayrollProviderPersistence.test.tsx` | Captured targets, provider/config save order, response identity rejection, partial-save recovery, cache merge/invalidation, exact-snapshot validation, publish success/failure, late edits |
| `PayrollProviderEditor.test.tsx` | Save/publish wiring, validation display, authoritative-conflict reload, selection locking, representative child composition |
| Optional `usePayrollProviderExampleFile.test.tsx` | Confirmation/apply lifecycle only if parser and dialog tests do not already own it |

### Preliminary 23-case traceability

| Disposition | Current cases |
| --- | --- |
| Keep as reduced page seams (9) | route/section navigation; route correction during mutation; empty-state create entry; stale-snapshot reload; dirty-state preservation across list/detail refresh failure; one combined-save seam; one publish/selection-lock seam; create handoff/navigation; list-load retry |
| Relocate after focused owner exists (3) | provider search to `PayrollProviderToolbar.test.tsx`; delayed detail hydration and detail-load retry to `PayrollProviderDetailLoader.test.tsx` |
| Remove or reduce only after direct ownership exists (11) | extractor-only policy; exact-snapshot validation deduplication; mismatched save response; partial-save recovery; invalid-config preflight; cancelled column creation; detailed validation feedback; CSV replacement; JSON schema upgrade; disabled-provider publish policy; publish-error detail |

The retained save/publish page cases prove only cross-component wiring. Payload order, cache reconciliation, late edits, and failures belong to persistence/state tests. The retained create case proves navigation and list/detail handoff; normalization remains in `payroll-provider-model.test.ts`.

### Ordered work

1. Expand the table above into a checked 23-row traceability artifact before changing tests.
2. Add the Detail Loader, persistence hook, and editor test files. Add only the smallest production seam needed for direct testing; do not expose private state or mock internal collaborators indiscriminately.
3. Add the optional example-file hook test only if confirmation/apply behavior remains otherwise unowned.
4. Move the three identified cases, then remove/reduce the eleven cases one at a time only after the target test proves the same public behavior.
5. Keep dynamic handlers local to the test that needs them; extract a small factory only after repeated use exists across focused suites.
6. Run all payroll-provider tests and the complete web suite. Record runtime as a diagnostic, with no optimization claim.

### Manual UAT

Open the route with no providers, a selected provider, and an invalid section. Create a provider; edit/save/publish; force list and detail refresh failures while dirty data exists; confirm selection remains locked during save/publish and that partial failure never discards later edits.

## Separate CI performance investigation

If reducing `web-unit` feedback time remains an objective, open independent measurement/experiment PRs rather than attaching a speed claim to the maintenance work.

### Experiment A: deterministic scheduling

Benchmark a custom Vitest sequencer that orders by stable module ID under CI. This removes size-change ordering bias but does not eliminate all two-worker contention because added files still change pairing. Adopt it only if repeated hosted evidence shows stable diagnostics without worsening command wall time.

### Experiment B: critical-path and topology

Identify the roughly 170 KB critical-path straggler and benchmark it independently. Separately compare the current two-vCPU/two-worker topology with bounded alternatives; do not add workers to a CPU-saturated run without evidence.

### Measurement contract for future performance claims

1. Define an affected-set manifest containing the original test and every new or relocated test file.
2. Measure the affected set serially for attribution and the regular-topology `web-unit` command wall time for user impact. Full job duration is a control because install/build/shared-UI phases are unrelated.
3. Collect at least five hosted baseline and candidate samples with unchanged runner topology, sequencer, lockfile, and test manifest.
4. Report median, range, and a confidence interval for the paired difference; the interval must exclude zero.
5. Require at least 15% affected-set reduction and at least 5% regular-topology command-wall improvement, with no coverage loss, retries, memory spike, or cost shifted to other files/phases.
6. Treat unstable or inconclusive evidence as no performance claim. A maintainability PR may still stand on its own stated acceptance criteria.

## Validation strategy

For each review unit, verify the exact commands against current package scripts, then run the focused direct tests, retained component tests, complete `@helixos/web` tests, web lint, theme check, production build, and `git diff --check`. Hosted CI is required by the repository lifecycle. Record command timing only as diagnostic evidence; an observed regression must be investigated for accidental repeated work or cost shifting, but the maintenance review unit has no speedup threshold.

| Layer | Required evidence |
| --- | --- |
| Dependency-light policy | Direct tests import no component and cover full decision tables |
| Hook/lifecycle | Captured variables, out-of-order completion, cancellation/timeout, exact invalidations |
| Component/MSW | Representative rendering, permission, request, cache, and accessibility seams |
| Tenant/security | Two simultaneously mounted tenants; negative unscoped handlers; PII cache separation |
| Full web | Tests, lint, theme check, build, and exact-head required CI |
| Manual UAT | Two workspaces/personas and pending-request target switches where applicable |

## Risks and recovery

- **Tenant defects hidden by extraction - high/high:** land review unit 0 first and require the complete query/mutation matrix.
- **Mechanical file proliferation - medium/high:** prefer existing owners, camelCase names, and a direct usefulness test before creating a module.
- **Provider coverage loss - medium/high:** add missing focused owners before removing any page assertion; use the 23-row matrix as the gate.
- **God hook replacement - medium/high:** reject hooks that need many unrelated setters or own workflows outside their lifecycle.
- **False performance claim - high/medium:** keep maintenance and performance review units separate and measure all relocated work.

Each review unit is independently revertible. No schema, endpoint, deployment, feature flag, or external configuration change is planned by this document.

## Data, rollout, compatibility, and recovery

No persistence migration, API contract change, deployment ordering, feature flag, or backward-compatibility bridge is planned. Each review unit must leave the application behaviorally complete and can be reverted independently. If review unit 0 reveals a server-side tenant or authorization defect, stop this plan and create a separately scoped cross-cutting remediation with the required endpoint-to-policy matrix.

## Definition of done

- The security prerequisite is integrated before either Client Detail refactor.
- Every query and mutation has one tenant/target ownership contract and direct negative-space evidence.
- Every extracted rule/lifecycle has one authoritative owner and direct tests at the narrowest layer.
- Representative UI, request, permission, PII, and cache seams remain covered.
- No direct `useEffect`, god hook, dumping-ground helper, generic fixture kit, or mechanical file split is introduced.
- The Provider 23-case traceability matrix has no behavior with a missing target owner.
- Timing is described honestly as diagnostic unless the separate performance contract is satisfied.
- Documentation, validation, review evidence, and the repository lifecycle gates are complete; merge remains an owner decision.

## Reviewer checklist

- Challenge every proposed owner for cohesion and dependency direction.
- Verify all tenant-scoped keys, enabled predicates, realtime invalidations, and mutation targets.
- Confirm direct tests import no page component and component tests retain critical seams.
- Reject any test deletion without a named target owner and equivalent public-behavior evidence.
- Reject a new grid module, duplicate feed-session policy, generic provider test kit, or broad page-controller hook.
- Require exact-ref evidence and all relocated files in any future performance measurement.

## Associate-engineer handoff checklist

1. Read repository instructions, this plan, the current target modules/tests, `instructions/react/noeffect.md`, and `docs/operations/ci-timing-instrumentation.md`.
2. Start only the next ordered review unit and confirm its dependency gate is integrated.
3. Recount source/tests and refresh the responsibility and behavior inventories against the exact starting head.
4. Stop and escalate if the work needs a new API, authorization rule, schema, cross-context abstraction, or more than the named responsibility boundary.
5. Attach the exact head/base, query/mutation or case-traceability inventory, validation commands/results, UAT evidence, residual risks, and any diagnostic timing to the PR description.
6. Follow the live owner-authored PR lifecycle; engineering completion alone does not authorize merge.
