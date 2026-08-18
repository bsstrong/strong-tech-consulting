# HelixOS Task — Payroll Operational Exception Contract

## Identity

- Status: in progress (production-review findings addressed; exact-head CI pending)
- Repository: `helixosio/helixos`
- Task started: 2026-08-17T04:58:35Z
- Task/thread ID: Unavailable (Codex task ID is not exposed in the current tool context)
- Starting branch: `main`
- Starting base SHA: `f76377cb8fa7c26ca2803799ec2f96fcf9ea0c80`
- Starting head SHA: `e81c2706ca31c91c1e19a3adbede9d08c8d56e9f`
- Issue: #842 (related implementation-plan record; exact implementation linkage pending repository inspection)
- PR: https://github.com/helixosio/helixos/pull/1190 (Ready)

## Objective and scope

Implement the Payroll Operational Exception Contract plan exactly as written while preserving existing workflow behavior and limiting the change to the prerequisite contract.

Exclusions and owner decisions:

- Do not implement report schema, API, or UI work.
- Stop if implementation materially exceeds the plan's file inventory.
- Preserve existing workflow behavior.
- Owner clarification at 2026-08-17T13:01:24Z: architecture-standard violations in code touched by this work must be corrected; the planned inventory is not a reason to leave those violations unresolved.

## Lifecycle

| Milestone | Timestamp | Duration or evidence |
| --- | --- | --- |
| Task started | 2026-08-17T04:58:35Z | — |
| Shared contract and persistence seam committed | 2026-08-17T05:21:07Z | 22m 32s from task start |
| API, workflow, and source-matrix implementation committed | 2026-08-17T05:59:29Z | Head `7f075e24b`; 1h 00m 54s from task start |
| Architecture audit and local validation complete | 2026-08-17T06:26:55Z | Head `dc185fbe7`; stale follow-up delivery guards and actor-scope validation corrected within planned files |
| Implementation/handoff | Blocked | Private review requires source-owner corrections outside the authorized file inventory |
| Draft PR created | 2026-08-17T06:28:29Z | PR #1190 at exact head `dc185fbe7`; 1h 29m 54s from task start |
| Private self-review requested | 2026-08-17T06:30:33Z | `#self-reviews` parent `1786948233.619459`; first follow-up scheduled after seven minutes |
| Private self-review completed | 2026-08-17T06:38:21Z | Exact head `dc185fbe7`; 3 blockers, 0 non-blockers |
| Scope stop gate applied | 2026-08-17T06:40:12Z | Authoritative intake correction requires payroll-feed worker files and tests outside the plan inventory; no review fixes or rerun requested |
| CI | Not started | Draft private gate did not clear |
| Completed | Blocked | Owner decision required to expand the plan inventory or revise the contract |
| Owner clarified architecture scope; work resumed | 2026-08-17T13:01:24Z | Resume the private self-review loop and correct all three exact-head blockers |
| Base synchronized | 2026-08-17T13:06:39Z | Merged `origin/main` at `4e776a5d5`; resolved the additive Prisma schema overlap by retaining both independent relations |
| Private-review corrections validated and pushed | 2026-08-17T13:31:17Z | Head `4b5837363`; all three blockers corrected, focused lifecycle policies extracted from touched architecture hotspots |
| Private self-review rerun requested | 2026-08-17T13:32:40Z | Exact `rerun` reply `1786973560.156779` confirmed in parent `1786948233.619459`; rerun cycle 1 of 3 |
| Second private review completed | 2026-08-17T13:41:08Z | Exact head `4b5837363`; 2 blockers and 3 non-blockers |
| Second-round corrections pushed | 2026-08-17T13:56:53Z | Head `f809f7da3`; every finding addressed and validated |
| Churn circuit breaker stop | 2026-08-17T13:56:53Z | Two rounds found omissions in the same lifecycle-identity boundary; monitoring paused and another rerun requires explicit owner approval |
| Owner approved fresh private loop | 2026-08-17T23:26:48Z | Circuit breaker cleared by explicit owner instruction; fresh invocation rerun count reset to 0 of 3 |
| Fresh private rerun requested | 2026-08-17T23:28:13Z | Exact `rerun` reply `1787009293.616639` posted by verified user `U0B9R7NJTQA`; bot acknowledgement `1787009297.045949`; fresh cycle 1 of 3 at head `f809f7da3` |
| Fresh cycle-1 review completed | 2026-08-17T23:32:08Z | Exact head `f809f7da3`; 1 blocker, 0 non-blockers; heartbeat paused while the finding is processed |
| Fresh cycle-1 correction validated and pushed | 2026-08-17T23:42:36Z | Head `e56a6f50d`; resolved-history BBA claims are a locked no-op and no longer roll back the queue claim |
| Fresh cycle-2 rerun requested | 2026-08-17T23:43:50Z | Exact `rerun` reply `1787010230.812489` posted by verified user `U0B9R7NJTQA`; bot acknowledgement `1787010233.421509`; fresh cycle 2 of 3 at head `e56a6f50d` |
| Fresh cycle-2 review completed | 2026-08-17T23:46:40Z | Exact head `e56a6f50d`; 1 blocker, 0 non-blockers; second fresh round on the conditional lifecycle boundary activated the churn circuit breaker and paused monitoring |
| Fresh cycle-2 correction validated and pushed | 2026-08-17T23:55:45Z | Head `0c3c9c615`; locked no-op classification now precedes authorization while active mutations remain authorized |
| Fresh circuit-breaker checkpoint complete | 2026-08-17T23:55:45Z | Full affected-category audit and validation complete; another rerun requires explicit owner approval |
| Owner approved second fresh private loop | 2026-08-18T00:42:42Z | Circuit breaker cleared by explicit owner instruction; the invocation-only churn ledger and rerun count reset to 0 of 3 |
| Second fresh invocation rerun requested | 2026-08-18T00:43:54Z | Exact `rerun` reply `1787013834.177109` posted by verified user `U0B9R7NJTQA`; bot acknowledgement `1787013837.087269`; cycle 1 of 3 at head `0c3c9c615` |
| Second fresh invocation review completed cleanly | 2026-08-18T00:47:51Z | Exact head `0c3c9c615`; 0 blockers, 0 non-blockers, 0 inline findings; result `1787014071.205399` |
| Task completed | 2026-08-18T00:51:28Z | Private loop stopped and heartbeat paused; PR #1190 remains Draft with no public/final review actions taken |
| Task resumed for PR documentation | 2026-08-18T01:10:45Z | Owner requested additional insight in the Draft PR about what the model stores and why |
| Draft PR model rationale updated | 2026-08-18T01:11:58Z | Added current-state/event-history storage details and design rationale; refreshed clean-review and base-freshness evidence without changing code, head, or Draft state |
| Resumed documentation interval completed | 2026-08-18T01:12:14Z | 1m 29s from resume; canonical PR verification passed |
| Production review feedback received | 2026-08-18T01:46:36Z | Four actionable lifecycle findings from walkeryan, one valid regression gap from Keith/Jarvis, and one non-blocking enum-design finding from `jfollas`; other Keith/Jarvis claims were verified as already satisfied or unsupported by the cited code |
| Production-review corrections validated and pushed | 2026-08-18T02:17:04Z | Head `63e95479c`; all six inline threads answered and resolved; PR description updated with dispositions and evidence |
| Exact-head hosted CI started | 2026-08-18T02:18:00Z | HelixOS CI run `32091258542` on `63e95479c` is in progress; one follow-up scheduled after 62 minutes from the latest-50-run duration evidence |
| Owner clarified review lifecycle | 2026-08-18T02:20:00Z | Once the PR is in the production cycle, private self-review is not revisited unless explicitly requested; the prior private rerun trigger is ignored and its heartbeat was replaced with the single CI follow-up |

## Task statistics

| Statistic | Value | Evidence |
| --- | --- | --- |
| Total elapsed | 19h 52m 53s | 2026-08-17T04:58:35Z through 2026-08-18T00:51:28Z; includes owner-decision and review waiting intervals |
| Commits | 14 | Current branch history above `origin/main`, including production-review fix `63e95479c` |
| Change size | 45 files, 4,998 insertions, 167 deletions | `git diff --shortstat origin/main...HEAD` at `63e95479c` |
| Validation | Shared 217/217; DB 260 passed with 3 existing skips; API 3,057/3,057; workflow 947/947 | Full package suites, focused lifecycle seams, builds, and Prisma validation/generation passed |
| Review | 5 completed private rounds: 7 blockers, 3 non-blockers; every finding fixed; final exact-head review clean | Exact-head clean result `1787014071.205399` in `#self-reviews` parent `1786948233.619459` |
| CI | In progress | HelixOS CI run `32091258542` on exact head `63e95479c`; latest 50 completed PR runs had a 60.48-minute maximum, so the policy follow-up interval is 62 minutes |
| Benchmarks | N/A | Performance benchmarking is not in the requested contract scope |

## Work and decisions

- The requested boundary is a prerequisite operational-exception contract only.
- The exact plan was read from `codex/842-report-foundation:docs/plans/2026-08-17-payroll-operational-exception-contract.md`.
- Implementation branch: `codex/payroll-operational-exception-contract`, based on `origin/main` at `f76377cb8fa7c26ca2803799ec2f96fcf9ea0c80`.
- Added the closed shared vocabulary, policy table, source-key/scope validation, and pure lifecycle projector in commit `1d49f7b61`.
- Added the additive Prisma schema/migration and transaction-participating current/event mutation seam in commit `13d9cfe3e`.
- Added API-owned writers in commit `d1d62cb29`, workflow-owned writers in commit `2252f2aa4`, and the verified source/timestamp matrix in commit `7f075e24b`.
- Hardened repeated resolution and actor tenant scope in `09e0b6dd4`, then guarded eligibility, census-persistence, and export follow-up writes against stale source state in `dc185fbe7`.
- Source integrations cover all eight codes and preserve existing source status/audit writes. Ambiguous census/eligibility cycle linkage falls back to Client scope rather than guessing a cycle.
- The only support file outside the named inventory is `src/packages/db/prisma/seed.ts`, required by the existing every-model reset contract; this is not a material scope expansion.
- No report model, endpoint, controller, permission, UI, scheduler, generation path, or historical backfill was added.
- The exact-head private review found that intake-source failures are written only from request-time API paths while authoritative asynchronous payroll-feed transitions occur in `feed-pull-poller.ts`, `feed-ingestor.ts`, and `feed-pull-kickoff.ts`. Correcting ownership requires those production files, focused tests, and likely a focused transition adapter, materially exceeding the plan inventory.
- The same review found two additional lifecycle-identity blockers within planned source families: export and operations-file retries use per-attempt keys that cannot resolve an earlier failed occurrence, and eligibility review reassignment from source run A to run B reconciles only run B while run A can remain open.
- No partial review fixes were made because the authoritative intake correction triggered the owner's explicit scope stop. The private-review heartbeat was disabled and no rerun, public feedback request, Ready transition, reviewer request, or merge action was performed.
- The owner subsequently clarified that architecture violations in touched code are in scope and must be fixed. The prior stop is retained as lifecycle history; implementation resumed to address all three findings and obtain a clean exact-head private review.
- Merged the overlapping payroll-router push base change at `4e776a5d5` and retained both independent additive Prisma relations. A later base advance to `e8e9a5d89` changed only CI timing documentation and a web test, with no overlap or review-premise change.
- Added a focused DB intake transition adapter shared by API and payroll-feed workers. Poller, kickoff, and ingestor source transitions now update linked intake state and normalized operational exceptions in the same tenant transaction.
- Replaced per-attempt export and Operations file-generation identities with stable logical occurrence keys so successful retries resolve earlier failures.
- Reconciled both prior and replacement eligibility-review identities. Superseded source aggregates resolve with `SOURCE_REPLACED` when their open count reaches zero.
- Extracted intake, eligibility-review, and Operations exception lifecycle policies from the touched large service/processor modules, addressing the architecture ownership finding instead of adding more responsibilities to those hotspots.
- The second private review found that date-wide BBA identity still aliased independent selected-group sets and that a claimed retry did not move the exception to `IN_PROGRESS`. It also requested transaction-level coverage for linked intake workers, eligibility source replacement, and distinct export attempts.
- Corrected the shared root cause cohesively: BBA source identity now hashes the order-independent selected-company/run snapshot, and the authoritative claim transaction updates only the matching open exception to `IN_PROGRESS`. Interleaved selections remain independent; true retries share identity.
- Inventoried every Operations generation status writer: API enqueue (`QUEUED`), worker claim (`PROCESSING`), processor completion/failure (`READY`/`FAILED`), recovery failure, API expiry, and sweeper expiry. Expiry is a completed-artifact retention transition and does not mutate failure lifecycle state.
- Added worker-boundary linked-source coverage for payroll-feed failure, retry, and ingestion; transaction-level prior eligibility aggregate resolution; and failed-export followed by a distinct successful attempt.
- The churn circuit breaker activated because two review rounds found omissions from the same lifecycle-identity boundary and both cycles materially expanded coverage. All findings were fixed before stopping; the private-review heartbeat remains paused and no new rerun was posted.
- At 2026-08-17T23:26:48Z the owner explicitly authorized restarting the private self-review loop at rerun count zero. The prior circuit-breaker evidence remains historical; the current invocation may post up to three new reruns under the skill safety limit.
- Fresh cycle 1 found that the BBA claim transition queries matching exception history without excluding `RESOLVED`. The shared lifecycle owner correctly rejects `RESOLVED` to `IN_PROGRESS`, so a later matching generation can roll back its claim and repeatedly block the oldest queued row. The correction boundary is the locked BBA claim transition plus a resolved-history regression; monitoring is paused during implementation and validation.
- Added `updatePayrollOperationalExceptionIfActive` at the DB mutation boundary. It validates actor and assignee scope, locks the exact tenant/source occurrence, returns a no-op for missing or `RESOLVED` state, and applies the existing lifecycle projector only to active state. The BBA adapter now uses this mutation instead of a pre-lock existence probe.
- Blast-radius inventory confirmed the new conditional mutation has one caller: the authoritative BBA `QUEUED` to `PROCESSING` claim transaction. Open retries still transition to `IN_PROGRESS`; missing occurrences and resolved history do not update or append events; subsequent failures still reopen through the existing detection mutation. Ready resolution, recovery failure, and expiry behavior remain unchanged.
- Fresh cycle 2 found that `updatePayrollOperationalExceptionIfActive` validates actor and assignee scope before acquiring and classifying the occurrence. An inactive historical actor can therefore roll back a claim even when the locked result is missing or already `RESOLVED` and no exception mutation is required. The cohesive correction boundary is lock/load, terminal no-op classification, then validation only for an active mutation, with inactive-actor coverage.
- This is the second fresh review round on the same conditional lifecycle root pattern. The churn circuit breaker is active, the heartbeat is paused, and another automated rerun will not be posted without explicit owner approval after correction, complete affected-category inventory, full validation, and full-diff architecture review.
- Corrected the ordering in `0c3c9c615`: the DB owner now locks and classifies missing or `RESOLVED` state before actor/assignee validation, then preserves strict authorization for active mutations. Added exhaustive focused cases for missing plus inactive actor, resolved plus inactive historical actor, and active plus invalid actor.
- Complete caller inventory remains one BBA claim adapter. Complete state/authorization inventory now covers missing, resolved, active authorized, active unauthorized, active invalid assignee, open retry, repeated in-progress delivery, successful resolution, later failure reopening, and the processor/recovery/expiry writers. No other source family uses the conditional helper.
- At 2026-08-18T00:42:42Z the owner explicitly authorized another fresh private self-review invocation. Per the current skill contract, churn is counted only within this invocation; prior-invocation review rounds remain historical evidence and the new rerun ledger starts at zero.
- At 2026-08-18T01:10:45Z the owner requested a focused PR-description update explaining the current-state and append-only event data model, its stored fields, and its reporting rationale. This is documentation-only and does not alter the clean reviewed head or Draft lifecycle state.
- Updated Draft PR #1190 with a dedicated `Data model and rationale` section describing the logical-occurrence identity, stored current-state fields, append-only event snapshots, source-of-truth boundary, transactional consistency, data-minimization boundary, and future reporting purpose. Also replaced the stale circuit-breaker wording with the clean exact-head private-review result and refreshed the non-overlapping base evidence.
- Production feedback identified three concrete root boundaries: eligibility aggregates omitted two actionable states and counted before locking; asynchronous payroll-feed and BBA workers reused historical requesters who could later be inactive; and two remaining closed database vocabularies were represented as strings with duplicated allowlists.
- Corrected those boundaries at their authoritative owners. One shared eligibility open-status definition now feeds persistence, workflow aggregation, and API filtering; aggregate reconciliation row-locks the occurrence before counting; worker mutations require current dedicated system actors; and PostgreSQL/Prisma enums own affected-count units and resolution codes.
- Added the valid Keith/Jarvis regression for an insert conflict with no winning row. The remaining Keith/Jarvis migration and timestamp claims were checked against the exact diff and required no change because the constraints already existed and timestamp variables were already reused consistently.
- Every production-review inline thread was answered and resolved. The PR description records the findings, blast radius, affected-instance inventory, validation, and the intentional no-change disposition for `jfollas`'s unique-index observation.
- Because Keith/Jarvis submitted its findings as a review body rather than replyable inline threads, posted a top-level PR follow-up comment (`5322680703`) that records the one corrected conflict-reload regression and the exact-code verification behind the migration, timestamp, and coverage dispositions.
- Owner lifecycle clarification supersedes the earlier private-gate habit: after entering production review, do not return to private self-review unless explicitly requested. Final re-review proceeds through exact-head hosted CI and GitHub-only `jfollas` review.

## Validation, review, and CI

- Shared focused tests: 11/11 passed.
- Shared full suite: 217/217 passed; shared build passed.
- Prisma validate and generate passed.
- DB focused mutation/schema tests: 13/13 passed.
- DB seed plus mutation tests: 23/23 passed.
- DB full suite: 255 passed, 0 failed, 3 existing skipped; DB build passed.
- The migration applied successfully to the local PostgreSQL instance; both new tables remained empty (`0` current, `0` event rows), confirming no backfill.
- API focused writer suite: 151/151 passed; API build passed.
- API full suite: 2,999/2,999 passed in 140.960s after the final audit fixes.
- Workflow focused writer suite: 161/161 passed in 4.807s; workflow build passed.
- Workflow full suite: 915/915 passed in 20.980s after the final audit fixes.
- Review-fix focused suites: 224 assertions passed across DB intake transition, workflow worker/identity/reconciliation, and API intake/export seams; DB mutation tests remained green.
- Review-fix full DB suite: 257 passed, 0 failed, 3 existing skipped in 13.013s.
- Review-fix full workflow suite after the architecture extraction: 941/941 passed in 21.559s; workflow build passed.
- Review-fix full API suite: 3,056/3,056 passed in 137.779s; API build passed.
- `git diff --check` passed; shared, DB, workflow, and API builds passed.
- Second-round focused export suite: 36/36 passed in 2.993s.
- Second-round focused BBA identity/lifecycle suite: 3/3 passed after adding the interleaved-selection regression.
- Second-round full workflow suite: 946/946 passed in 21.805s; workflow build passed.
- Second-round full API suite: 3,057/3,057 passed in 119.960s; API build passed.
- Fresh cycle-1 focused DB mutation suite: 14/14 passed, including a `FOR UPDATE` assertion for the resolved-history no-op.
- Fresh cycle-1 focused BBA exception/processor suites: 12/12 passed, including open retry and resolved-history claim paths.
- Fresh cycle-1 full DB suite: 258 passed, 0 failed, 3 existing skipped; DB build and Prisma generation passed.
- Fresh cycle-1 full workflow suite: 947/947 passed in 22.531s; workflow build passed.
- Fresh cycle-2 focused DB mutation suite: 16/16 passed; focused BBA exception/processor suites: 12/12 passed.
- Fresh cycle-2 full DB suite: 260 passed, 0 failed, 3 existing skipped; DB build and Prisma generation passed.
- Fresh cycle-2 full workflow suite: 947/947 passed in 21.833s; workflow build passed.
- Final `git diff --check` and complete diff architecture review passed. No materially similar status writer, retry identity, replacement aggregate, or worker boundary remains unreviewed in the affected source families.
- Production-review focused validation at `63e95479c`: shared, DB, workflow, and API builds passed; DB 21/21, workflow 144/144, and API 25/25 focused tests passed; `git diff --check`, complete affected-instance inventory, and architecture review passed.
- Current exact-head hosted CI: HelixOS CI run `32091258542` started for `63e95479c`; status was `in_progress` at the initial check. Per owner policy, the single follow-up is scheduled after 62 minutes and no polling is performed.

### Private rerun evidence checkpoint

- Exact head: `4b58373635903274cf3b9aee6ccade807fdfadbe`.
- Fetched base: `e8e9a5d8982969bc04d54f8a138c25845958950f`. Since the synchronized base `4e776a5d5`, base changed only `docs/operations/ci-timing-instrumentation.md` and `src/web/src/features/client-portal-access/ClientPortalAccessPanel.test.tsx`; neither overlaps the PR or changes its review premise.
- Finding 1 disposition: fixed by one focused intake transition adapter invoked by manual API writes and every payroll-feed status owner (`feed-pull-poller`, `feed-pull-kickoff`, `feed-ingestor`) inside the authoritative tenant transaction.
- Finding 2 disposition: fixed by stable logical occurrence identities for every retry-capable affected source: cycle key for payroll-cycle export and file type plus pay date for Operations generation.
- Finding 3 disposition: fixed by inventorying, deduplicating, and reconciling both prior and replacement eligibility review identities; zero-count prior aggregates resolve as `SOURCE_REPLACED`.
- Shared root cause: normalized exception lifecycle identity and transition ownership were embedded in request/attempt paths instead of the authoritative source occurrence. Blast radius covered all status mutation sites and all retry/replacement identities for the three reported source families.
- Complete affected-instance inventory: intake request validation/replacement/retry plus poller queued/retry/failure, kickoff claim/failure, and ingestor guarded failure/success/all-quarantined outcomes; export failure/success; Operations processor/recovery; eligibility review same-run idempotency, newer-run replacement, old/new type identity, zero-count resolution, update, and initial detection.
- Validation: shared 217/217; DB 257 passed with 3 existing skips; API 3,056/3,056; workflow 941/941; all four builds green; focused review seams green; `git diff --check` green.
- Full-diff architecture audit found no materially similar unreviewed instance. No report schema, API contract, permission, UI, scheduler, report generation, or historical reconstruction was introduced.

### Fresh-invocation rerun evidence checkpoint

- Owner gate: explicit approval received to clear the churn circuit breaker and restart the private loop at rerun count 0 of 3.
- Exact head: `f809f7da35d81cacfdc7c2c4cac6688a58e797c5`; local, remote branch, and Draft PR head match, and the HelixOS worktree is clean.
- Fetched base: `e8e9a5d8982969bc04d54f8a138c25845958950f`; merge base remains `4e776a5d573b6d86b9e98d8dec4f66ab946d8355`. Base-only changes are `docs/operations/ci-timing-instrumentation.md` and `src/web/src/features/client-portal-access/ClientPortalAccessPanel.test.tsx`; neither overlaps the contract implementation or changes the review premise.
- Second-review blocker 1: fixed. BBA occurrence identity hashes the deterministic, order-independent selected company/run snapshot, keeping independent selections separate while true retries share identity.
- Second-review blocker 2: fixed. The authoritative BBA `QUEUED` to `PROCESSING` claim transaction moves the matching open exception to `IN_PROGRESS`.
- Second-review non-blocker 1: fixed. Payroll-feed worker tests now exercise a linked intake source and exception through failure, retry, and ingestion transitions.
- Second-review non-blocker 2: fixed. Transaction-level eligibility coverage proves run A resolves when the review moves to run B, while B remains `OPEN` with the correct aggregate count.
- Second-review non-blocker 3: fixed. Export service coverage proves a failed attempt followed by a distinct successful attempt resolves the existing logical-occurrence exception.
- Shared root cause and blast radius: lifecycle identity and current-state transitions must be owned by the authoritative logical occurrence, not an individual attempt or request path. The audit covered BBA identity and every status writer, linked payroll-feed source/exception transitions, eligibility source replacement, and export attempts.
- Complete affected-instance inventory: BBA API enqueue (`QUEUED`), worker claim (`PROCESSING`), processor completion/failure (`READY`/`FAILED`), recovery failure, API expiry, and sweeper expiry; independent and true-retry BBA selections; payroll-feed poller failure/retry, kickoff claim/failure, and ingestor success/failure; eligibility prior/replacement source aggregates; export failed attempts and distinct successful retries. Expiry is completed-artifact retention and intentionally does not change failure lifecycle state.
- Validation: shared 217/217; DB 257 passed with 3 existing skips; workflow 946/946 in 21.805s; API 3,057/3,057 in 119.960s; focused export 36/36; focused BBA lifecycle 3/3; shared, DB, workflow, and API builds green; `git diff --check` green.
- The complete-diff architecture audit found no materially similar unreviewed instance. No report schema/API/UI, controller, DTO, OpenAPI contract, permission, scheduler, report generation, or historical reconstruction was introduced.

### Fresh cycle-2 rerun evidence checkpoint

- Exact head: `e56a6f50d257d121381280689f32c9f4a4f3cb34`; local, remote branch, and Draft PR head match, and the HelixOS worktree is clean.
- Fetched base: `e8e9a5d8982969bc04d54f8a138c25845958950f`; merge base remains `4e776a5d573b6d86b9e98d8dec4f66ab946d8355`. Base-only changes remain the non-overlapping CI timing document and Client Portal access web test, so the review premise is unchanged.
- Fresh cycle-1 blocker: fixed. The pre-lock BBA existence probe was replaced by an authoritative DB mutation that locks the occurrence and treats missing or `RESOLVED` state as a no-op before projecting an active update.
- Shared root cause: an adapter-level existence check classified historical state before the lifecycle owner acquired its lock. The correction moves conditional terminal-state classification to the locked mutation boundary without weakening the shared prohibition on `RESOLVED` to `IN_PROGRESS` transitions.
- Blast radius and complete affected-instance inventory: BBA enqueue (`QUEUED`), claim (`PROCESSING`), open retry (`IN_PROGRESS`), missing exception, resolved historical exception, processor success/failure (`READY`/`FAILED`), recovery failure, later failure reopening, API expiry, and sweeper expiry. The new conditional DB mutation has no other callers; all other source families retain their existing strict update semantics.
- Validation: focused DB 14/14; focused BBA 12/12; full DB 258 passed with 3 existing skips; full workflow 947/947 in 22.531s; DB and workflow builds green; Prisma generation and `git diff --check` green.
- Full-diff architecture review confirms lifecycle locking remains DB-owned, BBA identity remains adapter-owned, workflow behavior outside the resolved-history no-op is unchanged, and no materially similar pre-lock terminal-state classifier remains in the affected BBA category. No report schema/API/UI or other excluded surface was introduced.

### Fresh circuit-breaker evidence checkpoint

- Exact head: `0c3c9c615e895be21630e906827d891d0ed76ab8`; local, remote branch, and Draft PR head match, and the HelixOS worktree is clean.
- Fetched base: `e8e9a5d8982969bc04d54f8a138c25845958950f`; merge base remains `4e776a5d573b6d86b9e98d8dec4f66ab946d8355`. Base-only changes remain the non-overlapping CI timing document and Client Portal access web test; review premise unchanged.
- Fresh cycle-2 blocker: fixed. The conditional DB mutation locks and loads first, returns for missing or `RESOLVED`, and validates actor/assignee only before an active mutation.
- Shared root cause: the new conditional lifecycle operation initially interleaved existence/status classification with mutation authorization. Both decisions now have one ordered owner at the DB boundary: lock, classify no-op, authorize active mutation, project, persist, append event.
- Blast radius and complete affected-instance inventory: missing/inactive actor, resolved/inactive historical actor, active/invalid actor, active/invalid assignee, active authorized OPEN and IN_PROGRESS, BBA enqueue, claim, success/failure, recovery, later detection reopening, API expiry, and sweeper expiry. The helper has one BBA claim caller; strict mutations for all other source families are unchanged.
- Validation: focused DB 16/16; focused BBA 12/12; full DB 260 passed with 3 existing skips; full workflow 947/947 in 21.833s; DB and workflow builds green; Prisma generation and `git diff --check` green.
- Full-diff architecture review confirms DB ownership of locking/classification/authorization, adapter ownership of BBA occurrence mapping, unchanged source workflow behavior, no duplicate conditional policy, and no materially similar unreviewed instance in the affected category. No report schema/API/UI, controller, DTO, OpenAPI contract, permission, scheduler, report generation, or historical reconstruction was introduced.

### Second fresh-invocation rerun evidence checkpoint

- Owner gate: explicit approval received to clear the circuit breaker and restart both the invocation-only churn ledger and rerun count at 0 of 3.
- Exact head: `0c3c9c615e895be21630e906827d891d0ed76ab8`; local, remote branch, and Draft PR head match, and the HelixOS worktree is clean.
- Fetched base: `e8e9a5d8982969bc04d54f8a138c25845958950f`; merge base remains `4e776a5d573b6d86b9e98d8dec4f66ab946d8355`. Base-only changes remain the non-overlapping CI timing document and Client Portal access web test; review premise unchanged.
- First review findings remain fixed: authoritative payroll-feed intake transitions use the focused transactional adapter; export and BBA retry identities are logical occurrences; eligibility source replacement reconciles prior and replacement aggregates.
- Second review findings remain fixed: BBA selected-group/run identity isolates independent selections; claim moves active retries to `IN_PROGRESS`; linked payroll-feed, eligibility replacement, and distinct export-attempt lifecycle tests exercise the actual transitions.
- First prior fresh-review finding remains fixed: resolved historical BBA matches are locked lifecycle no-ops and do not roll back a matching queue claim.
- Second prior fresh-review finding remains fixed: lock/load and missing/resolved no-op classification precede actor/assignee validation; active mutations remain strictly authorized. Coverage includes missing/inactive actor, resolved/inactive historical actor, and active/invalid actor.
- Shared root cause and blast radius: logical occurrence identity, authoritative transition ownership, and ordered conditional lifecycle mutation must be owned at stable source and DB boundaries rather than request or attempt paths. Inventory covers all eight source families plus every BBA enqueue, claim, processor, recovery, and expiry writer and all missing/resolved/active authorization states.
- Validation: shared 217/217; DB 260 passed with 3 existing skips; API 3,057/3,057; workflow 947/947; focused DB 16/16; focused BBA 12/12; all affected builds green; Prisma generation and `git diff --check` green.
- Complete-diff architecture review found no materially similar unreviewed instance. No report schema/API/UI, controller, DTO, OpenAPI contract, permission, scheduler, report generation, or historical reconstruction was introduced.

### Clean exact-head private-review result

- Review result `1787014071.205399` completed at 2026-08-18T00:47:51Z for exact head `0c3c9c615e895be21630e906827d891d0ed76ab8` with no blockers, non-blockers, or inline findings.
- The fetched base advanced to `0be661696e6ff3376cb0fb1746a53ae3c89d52a0`; merge base remains `4e776a5d573b6d86b9e98d8dec4f66ab946d8355`. The 32 base-only changed files do not intersect the PR's 42 changed files, so the review premise remains valid.
- The private self-review loop is terminally clean. Monitoring is paused. Draft PR #1190 was not marked Ready; no GitHub reviewer, public `#pr-reviews` request, merge, release, or publish action was taken.

## Outcome, risk, and follow-up

The Payroll Operational Exception prerequisite contract and all production-review corrections are implemented and locally validated at exact head `63e95479ce871ce8dcbdbef6df53a6e5883eb541`. The PR remains Ready and limited to the prerequisite contract: no report schema, report API, report UI, scheduler, generation path, or historical reconstruction was added. All inline feedback is resolved. Exact-head hosted CI is pending; only after it is green and the head/thread gates still hold will `jfollas` be re-requested through GitHub. No merge, release, or publish action is authorized.

## Evidence provenance

- User objective and exclusions from the Codex task request.
- Repository identity from local Git and `origin/main` at 2026-08-17T04:58:35Z.
- Related issue-plan identity from the existing consulting record `20260817T014829Z-issue-842-implementation-plan.md`.
