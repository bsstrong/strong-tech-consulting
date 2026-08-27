# HelixOS Work - Safe Azure Preview Diagnostics

## Identity

- Status: Delivered for review
- Repository: `helixosio/helixos`
- Completed: 2026-08-27T01:11:18Z
- Task/thread ID: unavailable
- Branch: `codex/beta-preview-diagnostics`
- Final head SHA: `e9ffe3954150fee2e56fc5c4ce48b091c10488ff`
- Issue: N/A
- PR: [helixosio/helixos#1369](https://github.com/helixosio/helixos/pull/1369)

## Objective and outcome

Make failed protected Azure infrastructure previews actionable without exposing raw Azure output or secrets. The exact reviewed branch was pushed and PR #1369 was opened Ready for owner-arranged review; no reviewer, BETA preview, infrastructure apply, database restart, application deployment, or Production access was initiated.

## Delivered changes and decisions

- Separated private what-if stdout and stderr captures while preserving the first failure across scopes.
- Made failed previews withhold all raw and partial output and publish only allowlisted command status, Azure error code, correlation ID, and recognized target category.
- Kept raw runner captures restrictive, ephemeral, and excluded from artifacts.
- Added focused shell and Node contract coverage to CI.
- Documented the existing non-mutating validation fallback for the known Function App appsettings what-if limitation.
- Preserved existing Bicep, apply, and deployment behavior.

## Validation, review, and CI

- `scripts/infra/preview-status.test.sh`: passed.
- `scripts/infra/plan.test.sh`: passed.
- `node scripts/infra/sanitize-preview.test.mjs`: passed.
- Node syntax checks and `git diff --check`: passed.
- Mandatory architecture self-review completed against base `376b82e8508241897c336bc65c99c8652bfbee97`; no unresolved actionable findings.
- Hosted CI and external review were not complete when the PR was delivered.

## Risk and follow-up

The safe parser intentionally reports unavailable for unknown Azure error formats instead of exposing raw text. After review and merge, run a non-mutating BETA stack preview from one exact main SHA and inspect the sanitized artifact before any infrastructure apply.
