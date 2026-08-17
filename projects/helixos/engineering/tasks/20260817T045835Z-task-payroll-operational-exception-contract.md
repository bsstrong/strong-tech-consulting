# HelixOS Task — Payroll Operational Exception Contract

## Identity

- Status: in-progress (resumed for architecture corrections)
- Repository: `helixosio/helixos`
- Task started: 2026-08-17T04:58:35Z
- Task/thread ID: Unavailable (Codex task ID is not exposed in the current tool context)
- Starting branch: `main`
- Starting base SHA: `f76377cb8fa7c26ca2803799ec2f96fcf9ea0c80`
- Starting head SHA: `e81c2706ca31c91c1e19a3adbede9d08c8d56e9f`
- Issue: #842 (related implementation-plan record; exact implementation linkage pending repository inspection)
- PR: https://github.com/helixosio/helixos/pull/1190 (Draft)

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

## Task statistics

| Statistic | Value | Evidence |
| --- | --- | --- |
| Total elapsed | 1h 41m 37s to scope stop | 2026-08-17T04:58:35Z through 2026-08-17T06:40:12Z |
| Commits | 9 | Seven implementation commits plus base-sync merge `55206b81e` and review-fix commit `4b5837363` |
| Change size | 42 files, 4,064 insertions, 135 deletions | `git diff --shortstat origin/main...HEAD` at `4b5837363` |
| Validation | Shared 217/217; DB 257 passed with 3 existing skips; API 3,056/3,056; workflow 941/941 | Full package suites, focused seams, builds, and Prisma validation/generation passed |
| Review | 1 private round: 3 blockers, 0 non-blockers | Exact-head result in `#self-reviews` parent `1786948233.619459` |
| CI | Not started | Private Draft gate did not clear |
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

## Outcome, risk, and follow-up

All three first-round private-review blockers are corrected and pushed at exact head `4b58373635903274cf3b9aee6ccade807fdfadbe`. Draft PR #1190 remains Draft. The next lifecycle action is an exact-head private self-review rerun; Ready status, GitHub reviewers, public `#pr-reviews`, CI final gate, and merge remain unauthorized at this stage.

## Evidence provenance

- User objective and exclusions from the Codex task request.
- Repository identity from local Git and `origin/main` at 2026-08-17T04:58:35Z.
- Related issue-plan identity from the existing consulting record `20260817T014829Z-issue-842-implementation-plan.md`.
