# HelixOS Work - Safe Azure Preview Diagnostics

## Identity

- Status: Closed without merge
- Repository: `helixosio/helixos`
- Completed: 2026-08-27T02:20:50Z
- Task/thread ID: unavailable
- Branch: `codex/beta-preview-diagnostics`
- Final head SHA: `0379daa19dc087417b9771564ddf1dfccd5c66e3`
- Issue: N/A
- PR: [helixosio/helixos#1369](https://github.com/helixosio/helixos/pull/1369)

## Objective and outcome

Make failed protected Azure infrastructure previews actionable without exposing raw Azure output or secrets. The diagnostic branch produced only fail-closed, sanitized evidence and did not identify an actionable Azure code. At the owner's direction, PR #1369 was closed without merge and its remote branch was deleted. No infrastructure apply, database restart, application deployment, or Production access occurred.

## Delivered changes and decisions

- Separated private what-if stdout and stderr captures while preserving the first failure across scopes.
- Made failed previews withhold all raw and partial output and publish only allowlisted command status, Azure error code, correlation ID, and recognized target category.
- Kept raw runner captures restrictive, ephemeral, and excluded from artifacts.
- Added focused shell and Node contract coverage to CI.
- Added an owner-controlled debug switch restricted to non-mutating stack previews; raw debug output remained private and was never uploaded.
- Documented the existing non-mutating validation fallback for the known Function App appsettings what-if limitation.
- Preserved existing Bicep, apply, and deployment behavior.
- Closed PR #1369 and deleted remote branch `codex/beta-preview-diagnostics`.

## Validation, review, and CI

- `scripts/infra/preview-status.test.sh`: passed.
- `scripts/infra/plan.test.sh`: passed.
- `node scripts/infra/sanitize-preview.test.mjs`: passed.
- Node syntax checks and `git diff --check`: passed.
- Mandatory architecture self-review completed against base `376b82e8508241897c336bc65c99c8652bfbee97`; no unresolved actionable findings at final head.
- Exact-head diagnostic preview run 33031389305 authenticated to Azure and passed Bicep validation, then failed safely in the stack what-if request with exit status 1 and Azure error code `unavailable`.
- The apply step was skipped and BETA remained unchanged.
- Exact-head CI was still running when the owner directed closure; no external review was requested.

## Risk and follow-up

PR #1369 will not be merged. BETA deployment remains paused pending actionable guidance from the Azure engineer. Any future replacement must begin from current `main`, use a non-mutating preview gate, and avoid reusing the closed branch.
