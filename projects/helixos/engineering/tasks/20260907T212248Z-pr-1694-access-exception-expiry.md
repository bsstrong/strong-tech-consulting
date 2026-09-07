# HelixOS Work - Access Exception Expiry Visibility

## Identity

- Status: Completed and merged
- Repository: `helixosio/helixos`
- Completed: 2026-09-07T21:22:48Z
- Task/thread ID: unavailable
- Branch: `codex/issue-1690-access-exception-expiry` (cleaned up)
- Final head SHA: `6bda9e0da8a251ebfa2452a6a265bcb5e2c80b5b`
- Issue: [#1690](https://github.com/helixosio/helixos/issues/1690)
- PR: [#1694](https://github.com/helixosio/helixos/pull/1694)

## Objective and outcome

Expose configured access-exception expiration metadata in People & Access. PR #1694 auto-merged after exact-head approval and clean required CI; the issue is closed and its project item is Done.

## Delivered changes and decisions

- Displayed the creating actor, creation time, and local-time expiry for active access exceptions.
- Explicitly labeled indefinite grants and restrictions as `No expiry`.
- Preserved expiry context in recent elevation/restriction history, including expired and revoked records.
- Added UI regression coverage and UAT documentation.
- Merge commit: `0fb2f427eb93baf6a3b457df05ea920504f148b7`.
- Removed the clean dedicated worktree and local branch; the remote branch had already been deleted.

## Validation, review, and CI

- Bounded fast-path validation passed: 17 targeted People & Access tests, web lint, theme checks, web production build, and `git diff --check`.
- Exact-head review approved with no findings or unresolved threads.
- All required exact-head CI checks passed; conditional benchmark and cross-browser jobs were expected skips.
- Hosted TEST/Beta retest was excluded by release-state policy.

## Risk and follow-up

Residual risk is limited to hosted rendering not exercised locally. Retest the disposable #830 persona after deployment to confirm the entered expiry is displayed in the hosted UI.
