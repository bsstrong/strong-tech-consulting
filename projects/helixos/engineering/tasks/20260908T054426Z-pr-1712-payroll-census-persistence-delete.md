# HelixOS Work - Guard payroll census persistence and deletion

## Identity

- Status: Merged and cleaned up
- Repository: `helixosio/helixos`
- Completed: 2026-09-08T05:44:26Z
- Task/thread ID: Unavailable
- Branch: `codex/issue-1708-payroll-persist-delete` (deleted locally and remotely)
- Final head SHA: `ba71040156011a6f4e7c9f238e5629ffef306391`
- Issue: [#1708](https://github.com/helixosio/helixos/issues/1708)
- PR: [#1712](https://github.com/helixosio/helixos/pull/1712)

## Objective and outcome

Prevent invalid payroll persistence and deletion actions, including zero-writable-row persistence, portal-owned run deletion, post-delete detail races, and first-persistence polling races. PR #1712 merged successfully; issue #1708 is closed and its project item is Done.

## Delivered changes and decisions

- Added one shared pure policy for identifying writable census rows and enforced it at the transactional repository boundary.
- Added authoritative API persistence and deletion eligibility fields and retained backend ownership guards.
- Reconciled delete and persistence mutations by immutable run ID, including concurrent first-persist attempts and exact re-persist behavior.
- Added regression coverage for quarantined runs, rollback/no-outbox behavior, portal ownership, deletion races, polling, and re-persistence.
- Posted the production-review request, moved the issue through review, and removed its stale review label after merge.
- Removed the dedicated worktree and local branch; the remote branch had already been deleted.

## Validation, review, and CI

- Local hermetic suites passed: API 4,374 tests; workflow 1,764; payroll 307; web 2,472 across 282 suites.
- API, web, package, payroll, and workflow builds passed; web lint/theme and OpenAPI checks passed.
- Local isolated database coverage was partially unavailable because another worktree occupied its dedicated port; hosted environment checks were not run by policy.
- Exact-head GitHub review approved `ba71040156011a6f4e7c9f238e5629ffef306391` with no unresolved findings.
- Exact-head required CI passed, including static checks, API and workflow unit tests, package suites, all web shards/checks, backend integration, and web end-to-end.
- TEST UAT revisited original run `09427b99-a196-480f-9ab0-f33fc9c008d3`: all 54 rows remained quarantined, the persistence action was absent with the actionable no-writable-rows message, and delete was disabled because the run belongs to payroll-cycle history.
- TEST UAT created fresh run `a0222e2c-724b-4482-bd96-050ddb748948` from the same displayed payroll source. It completed with 54 matched rows, persisted successfully for pay date 2026-09-11, disabled deletion while persistence was pending, and remained non-deletable after persistence. The browser recorded no console errors during the scenario.

## Risk and follow-up

No known outstanding blocker. Normal production risk remains around asynchronous persistence timing; the implementation bounds polling to first-persistence attempts and exact-head CI plus TEST UAT covered the integration and end-to-end seams. The fresh TEST payroll batch was retained as UAT evidence; no owner follow-up is required.
