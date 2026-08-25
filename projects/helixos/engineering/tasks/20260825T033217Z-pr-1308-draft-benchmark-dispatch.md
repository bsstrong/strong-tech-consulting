# HelixOS Work - Draft benchmark dispatch

## Identity

- Status: Delivered as Draft PR
- Repository: `helixosio/helixos`
- Completed: `2026-08-25T03:32:17Z`
- Task/thread ID: not recorded in available evidence
- Branch: `codex/ci-benchmark-dispatch`
- Final head SHA: `c21bd043abb2b3c261aebb93e7d3b993c2b136a1`
- Issue: N/A
- PR: https://github.com/helixosio/helixos/pull/1308

## Objective and outcome

Add a focused manual GitHub Actions path so Draft pull requests can collect
hosted benchmark samples without launching the full CI workflow. Draft PR #1308
was created from current `main` with independent web-unit and workflow/Functions
benchmark scopes; normal PR checks and branch protection remain unchanged.

## Delivered changes and decisions

- Added `web-unit-benchmark` and `workflow-functions-benchmark` dispatch scopes.
- Reused the normal `web-unit` job and added a manual-only workflow/Functions
  unit job with structured timing output and artifact upload.
- Kept the workflow PostgreSQL suite in `backend-and-infra` with its database
  setup and prevented benchmark dispatches from launching unrelated browser,
  backend, or E2E jobs.
- Made two payroll-feed configuration-absent tests hermetic by injecting the
  integration-config resolver rather than reaching the system Prisma client.
- Documented exact Draft benchmark commands, targeted reruns, and the boundary
  between timing evidence and required PR checks.
- Delivered commit `c21bd043abb2b3c261aebb93e7d3b993c2b136a1`.

## Validation, review, and CI

- Actionlint passed for `.github/workflows/helixos-ci.yml`.
- CI metrics tests passed 5/5.
- `npm run build:packages` passed.
- Workflow unit suite passed 1,006 tests with no failures or skips.
- Functions unit suite passed 115 tests with no failures or skips.
- `git diff --check origin/main...HEAD` passed.
- The Draft PR event correctly skipped normal CI jobs. No reviewer was requested.

## Risk and follow-up

The manual hosted dispatch itself has not yet been run, so GitHub-hosted timing
artifact generation remains unverified. Keep PR #1308 Draft until the owner
chooses the repository review path; after merge, future optimization PRs can
collect three exact-head samples before moving from Draft to Ready.
