# HelixOS Work - Payroll Provider Activation Sequencing

## Identity

- Status: Delivered; Ready PR with exact-head CI pending
- Repository: `helixosio/helixos`
- Completed: 2026-08-27T17:54:16Z
- Task/thread ID: `01a04093-a32e-74d1-abc9-bae9c283a56b`
- Branch: `codex/payroll-provider-activation-sequencing`
- Final head SHA: `42dca45e5a7d4f466ea98efe9e29bb02c60dfbb6`
- Issue: N/A
- PR: [#1383](https://github.com/helixosio/helixos/pull/1383)

## Objective and outcome

Fix the circular Payroll Provider workflow that required disabling an enabled provider before publishing its first file-generation configuration. Save now persists the draft while deferring capability activation, and Publish activates the configuration before enabling file generation.

## Delivered changes and decisions

- Sequenced draft save, configuration publication, and provider activation so the API invariant remains intact.
- Preserved the pending provider draft until publication completes and allowed Publish only for this exact deferred transition.
- Added regression coverage proving the request order is save config, publish config, then save provider.
- Updated the Payroll Provider authoring documentation.
- Commit: `42dca45e5` (`fix(web): publish config before enabling payroll generation`).

## Validation, review, and CI

- Targeted web tests: 35 passed across two suites.
- Targeted ESLint: passed for all changed TypeScript files.
- In-app-browser UAT reproduced the reported Exponent HR flow from a clean database and confirmed Save then Publish succeeds without disabling the provider.
- Mandatory architecture self-review found no actionable issues; tracked worktree was clean at the exact-tree checkpoint.
- PR #1383 is Ready at the exact head. CI run `33100675097` started and is pending; a single calculated follow-up is scheduled.

## Risk and follow-up

If provider activation fails after publication, the valid config remains published while the provider stays in its prior safe state; invalidation refreshes the editor for retry. After exact-head CI passes, run the required machine-local review and request GitHub review from `jfollas` only if that review is clean. Do not merge without owner authorization.
