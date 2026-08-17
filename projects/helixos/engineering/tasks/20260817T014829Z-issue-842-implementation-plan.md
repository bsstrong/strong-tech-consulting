# HelixOS Task — Review Issue 842 and Prepare Implementation Plan

## Identity

- Status: in-progress
- Repository: `helixosio/helixos`
- Task started: 2026-08-17T01:48:29Z
- Task/thread ID: Unavailable from the current Codex task context
- Starting branch: `main`
- Starting base SHA: `e81c2706ca31c91c1e19a3adbede9d08c8d56e9f`
- Starting head SHA: `e81c2706ca31c91c1e19a3adbede9d08c8d56e9f`
- Issue: https://github.com/helixosio/helixos/issues/842
- PR: N/A — planning-only task

## Objective and scope

Review HelixOS issue #842, including every link in its comments, inspect the relevant current repository implementation and tests, and write a detailed implementation plan suitable for an associate-level engineer.

Exclusions and owner decisions:

- Do not implement product changes.
- Do not create or update a pull request.
- Treat linked issue discussion and current repository evidence as planning inputs; surface unresolved product or architecture decisions rather than inventing them.

## Lifecycle

| Milestone | Timestamp | Duration or evidence |
| --- | --- | --- |
| Task started | 2026-08-17T01:48:29Z | — |
| Current remote synchronized for planning | 2026-08-17T01:50Z | Inspected detached worktree at `origin/main` `f76377cb8fa7c26ca2803799ec2f96fcf9ea0c80` |
| Issue and linked artifacts reviewed | 2026-08-17T01:58Z | Issue body, all five comments, linked five-sheet workbook, and linked V0 prototype |
| Implementation/handoff | 2026-08-17T02:07:05Z | Detailed plan written and self-reviewed |
| PR created | N/A | Planning-only task |
| Review | 2026-08-17T02:06Z | Requirements, architecture, authorization, test placement, and target-file review complete |
| CI | N/A | No implementation changes planned |
| Completed | 2026-08-17T02:07:05Z | 18 minutes 36 seconds elapsed |
| Resumed for PM decision brief | 2026-08-17T02:18:49Z | Owner requested plain-language decision statements, recommendations, and impacts |
| PM decision brief completed | 2026-08-17T02:19:19Z | Six copy-ready decision statements with recommended choices and consequences |
| Decision-neutral implementation authorized | 2026-08-17T02:28:42Z | Owner requested plan update and implementation start while product decisions remain pending |
| Foundation implementation committed | 2026-08-17T02:49:29Z | Commit `3f0b965efe49882a0daa5a670480923c0cc79968`; 20 minutes 47 seconds from resumed authorization |
| Application-audit scope clarified | 2026-08-17T04:15:23Z | Owner clarified that the report explains what HelixOS did and must not independently analyze imported-provider data; plan and source matrix corrected in commit `7bd56fa4773b4e1be2d42f22e1ad446d0172b618` |
| Eastern cutoff confirmed | 2026-08-17T04:17:59Z | Owner confirmed Sandy's comment is controlling: Eastern time, 5:00 PM daily cutoff, and all Carrier Clients; removed this from the open-decision gate in commit `c329b3980453d70c25d91d8d3d16ba2120368380` |
| Operational exception contract confirmed | 2026-08-17T04:20:40Z | Owner confirmed the report's exception fields are clear; repository review showed heterogeneous persistence rather than a missing business decision, so normalization became Slice 1 engineering work in commit `5e9958aeb6c5fa2672fdc9316bf30aa9ebc3c950` |
| Exception delivery boundary separated | 2026-08-17T04:24:11Z | Plan now requires operational-exception persistence as an independently deployable prerequisite PR with no report schema/API/UI; commit `a234f5cef563c3b1230024993b15bf355ecf3392` |

## Task statistics

| Statistic | Value | Evidence |
| --- | --- | --- |
| Total elapsed | 18 minutes 36 seconds | 2026-08-17T01:48:29Z through 2026-08-17T02:07:05Z |
| Commits | 5 product commits plus consulting lifecycle commits | Product commits `3f0b965efe49882a0daa5a670480923c0cc79968`, `7bd56fa4773b4e1be2d42f22e1ad446d0172b618`, `c329b3980453d70c25d91d8d3d16ba2120368380`, `5e9958aeb6c5fa2672fdc9316bf30aa9ebc3c950`, `a234f5cef563c3b1230024993b15bf355ecf3392` |
| Change size | 7 files, 1,532 additions, 113 deletions | `git diff --shortstat f76377cb8..a234f5cef` |
| Validation | Planning evidence plus 211 shared tests, 13 Cycle Monitor service tests, 2 PostgreSQL Cycle Monitor tests, package builds, and API build | All final commands passed; detailed evidence below |
| Review | 1 complete plan self-review; 6 pre-implementation decisions identified | No implementation or PR review rounds |
| CI | N/A | Planning-only task |
| Benchmarks | N/A | Performance scope not yet established |

## Work and decisions

- Identified this as a new root objective distinct from completed issue #1130 / PR #1117 work.
- Selected the GitHub issue review, engineering-plan, and HelixOS task-tracking workflows.
- Repository checkout began on local `main` at `e81c2706ca31c91c1e19a3adbede9d08c8d56e9f`, which was 623 commits behind `origin/main`; current remote evidence will be fetched and inspected before planning.
- Fetched current `origin/main` and created a detached planning worktree at `f76377cb8fa7c26ca2803799ec2f96fcf9ea0c80`; the user's stale local `main` was not changed.
- Reviewed the issue's confirmed decisions: Eastern time, 5:00 PM cutoff, all Carrier Clients, V0 content direction, Operations/Carrier Admin audience, Reports & Files placement, one-year retention, and Carrier Admin rerun access.
- Reviewed the workbook's five sheets and the V0 date navigation, funding periods/alignment, cycle research, control, exception, file-audit, and empty-state behavior.
- Current source proves that cycle state, application-produced counts, funding statuses, file-generation totals, and audit pieces exist. Missing items are application outcomes or actions that HelixOS does not yet persist at the report's required grain, plus a complete operational-exception ownership contract. The report must not create an independent financial analysis of imported-provider data. The owner clarified that Sandy's explicit 5:00 PM Eastern/all-Clients comment controls over the artifacts' calendar-day examples.
- The final plan therefore marks six product/data/security decisions as an explicit gate and provides recommended answers rather than inventing contracts.
- Planned a tenant-scoped immutable/versioned snapshot, idempotent Eastern-time scheduler, guarded worker/recovery, reasoned rerun/backfill, delivery record, one-year sweeper, explicit permissions, protected APIs, route-driven Reports & Files subview, narrow tests, UAT, and documentation.
- Preserved current architecture: existing Files archive remains; Operations stays independently permissioned; PlatformAudit is not reused; the Cycle Monitor hotspot is not grown; deterministic rules stay out of React and expensive E2E tests.
- Resumed the same issue-planning objective to translate the six technical decision gates into project-manager language without changing their substance.
- Produced a PM-facing approval brief covering the reporting day, cycle inclusion/aging, HelixOS outcome summaries, standard exception tracking, report format/delivery, and audience/action permissions.
- Updated the implementation plan so Slice 0A can proceed without encoding any unresolved report contract and Slice 0B remains an explicit blocking gate.
- Created branch/worktree `codex/842-report-foundation` at current `origin/main` `f76377cb8fa7c26ca2803799ec2f96fcf9ea0c80`.
- Added a field-to-source/gap, capacity, and reconciliation matrix under `docs/features/`; missing application-action, exception, delivery, and window fields remain explicit gaps.
- Extracted Cycle Monitor status, label, message, current-step, and timeline projection into the dependency-light `@helixos/shared` module. The Operations service retains tenant-scoped I/O, SQL paging/filtering, deadline derivation, and response mapping.
- Preserved the PostgreSQL classifier required for server-side filtering/paging and documented its required parity with the shared projector; existing SQL integration coverage exercises all five outcomes.
- Deferred the contract-sensitive report schema, API, permissions, scheduling, aggregation, exception aging, artifact, retention, and visible UI work.
- Corrected the plan and source matrix so the report projects persisted HelixOS actions and outcomes at their true execution grain. Imported record counts remain processing evidence only; the report will not reparse or recalculate provider data, infer unrecorded confirmation, or misrepresent tenant-level file-generation totals as per-cycle values.
- Moved the Eastern 5:00 PM cutoff and all-Carrier-Clients population from the decision gate into confirmed requirements. The implementation uses a prior-day 5:00 PM through report-day 5:00 PM closed-open window in `America/New_York`; five pre-implementation decisions remain.
- Moved the operational-exception contract from the decision gate into confirmed requirements. Current finalization blockers, intake failures, run failures, eligibility reviews, file-generation failures, and generic audit events use different schemas and lifecycle semantics; Slice 1 must write one structured tenant-scoped exception contract at those owning workflow boundaries. Four pre-implementation decisions remain.
- Split exception normalization into Slice 1A, a separate prerequisite PR. It owns the schema, lifecycle policy, idempotent source mapping, workflow writers, tenant isolation, PII-safe fields, and prospective/backfill rules. Report persistence and projection move to Slice 1B and depend on the merged exception contract.

## Validation, review, and CI

- `git diff --check`: pass for the plan file.
- Verified every named existing target file in the plan exists at current `origin/main`.
- Reviewed current Operations routing, window restoration, Reports & Files archive, permissions, tenant authorization model, payroll-cycle/funding/census/eligibility/audit schemas, async worker/sweeper patterns, and Payroll Provider Management test-runtime guidance.
- Completed a requirement-to-owner-to-proof traceability table and endpoint-to-policy matrix.
- The original planning phase ran no product tests or CI because it contained no implementation changes.

### Foundation implementation validation

- Baseline Cycle Monitor service test: 13/13 passed; 3,459 ms wall time before extraction.
- Focused shared projector test: 6/6 passed; final Node test duration 511 ms.
- Full `@helixos/shared` suite: 211/211 passed; 5,246 ms wall time.
- Cycle Monitor service seam: 13/13 passed; final Node test duration 2,016 ms.
- Cycle Monitor PostgreSQL coverage: 2/2 passed; 6,341 ms wall time; status precedence, tenant scope, filtering, and paging remained green.
- `npm run build:packages`: passed in 62,622 ms.
- `npm run build -w @helixos/api`: passed in 33,398 ms after required workspace packages were built.
- `git diff --cached --check`: passed before commit.
- Initial direct API build attempt failed only because fresh-worktree package artifacts had not yet been built; `build:packages` established the documented prerequisite and the subsequent API build passed.
- `npm ci` reported 61 dependency audit findings from the existing lockfile (2 low, 33 moderate, 22 high, 4 critical); dependency remediation is outside this issue slice.

## Outcome, risk, and follow-up

- Outcome: updated associate-engineer handoff and first decision-neutral implementation slice committed locally.
- Product repository state: clean branch `codex/842-report-foundation`, one commit ahead of `origin/main`; no push or pull request yet.
- Primary risk: implementation must not begin with report migrations/API DTOs until inclusion/aging, included HelixOS outcome/actions, artifact/delivery channel, and audience-permission mapping are approved. The exception normalization itself is confirmed engineering scope.
- Follow-up: Slice 1A exception normalization may proceed independently. Record the four remaining report answers on issue #842 and update the source matrix before beginning Slice 1B report persistence.

## Resumed implementation interval

- Resumed: 2026-08-17T02:28:42Z
- Owner authorization: update the implementation plan with work that can safely proceed before the six product decisions are finalized, then begin that decision-neutral implementation.
- Initial implementation scope: add a field-to-source/gap matrix and extract the existing deterministic Operations cycle-status projection into a focused directly tested module without changing behavior.
- Explicitly deferred: report persistence migrations, any missing HelixOS action-audit contracts, final report DTOs, permissions, cutoff scheduling, aggregation rules, exception aging, Excel delivery, and visible report UI.

## Evidence provenance

- User request in the current Codex task.
- Local Git status and revision captured at task start.
- Canonical issue body and all comments, including the linked OneDrive workbook and V0 prototype.
- Current `helixosio/helixos` `origin/main` at `f76377cb8fa7c26ca2803799ec2f96fcf9ea0c80`.
- Current repository instructions, `DESIGN.md`, Operations feature/audit/visibility documentation, Prisma schema and seed permissions, Operations API/web code, workflow/Functions patterns, and Payroll Provider Management test-runtime handoff.
