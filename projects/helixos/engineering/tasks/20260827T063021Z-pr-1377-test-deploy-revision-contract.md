# HelixOS Work - Restore TEST deployment revision contract

## Identity

- Status: Delivered for review
- Repository: `helixosio/helixos`
- Completed: 2026-08-27T06:30:21Z
- Task/thread ID: Unavailable
- Branch: `codex/test-deploy-revision-contract`
- Final head SHA: `f1c9c8933e3b42526f9063454a2c5c5f41474c77`
- Issue: N/A
- PR: [#1377](https://github.com/helixosio/helixos/pull/1377)

## Objective and outcome

Correct the repository contract that caused automatic TEST deployments to reject a stale infrastructure proof after independently deployed hub changes. PR #1377 is Ready at the exact reviewed head with a focused five-file correction.

## Delivered changes and decisions

- Limited environment revision hashing to the selected environment root and its exact locally deployed Bicep module set.
- Aligned TEST workflow path filters with that source set.
- Added an early read-only infrastructure proof check before expensive runner setup while retaining the existing pre-mutation check.
- Added focused source-set and workflow-order contract coverage and updated operator documentation.
- Commit: `f1c9c8933` (`fix(ci): align test deploy infrastructure proof`).

## Validation, review, and CI

- Mandatory complete-diff architecture self-review found no actionable issue or added responsibility boundary.
- Infrastructure revision contract tests: 5 passed.
- Deployment runtime contract tests: 26 passed.
- TEST, BETA, and Production Bicep parameter compilation passed with existing warnings only.
- `git diff --check` passed.
- PR CI started; final hosted result was not awaited.

## Risk and follow-up

The v2 TEST infrastructure proof must be previewed and applied from exact head `f1c9c8933e3b42526f9063454a2c5c5f41474c77` before merge. Merging first will intentionally fail at the new early proof gate. No Production access or change is required.
