# HelixOS Work - Payroll Provider Activation Sequencing

## Identity

- Status: Merged
- Repository: `helixosio/helixos`
- Completed: 2026-08-27T17:54:16Z
- Task/thread ID: `01a04093-a32e-74d1-abc9-bae9c283a56b`
- Branch: `codex/payroll-provider-activation-sequencing`
- Final head SHA: `4143f4cbf785bf3f4a22aed182ec408c8f68487f`
- Issue: N/A
- PR: [#1383](https://github.com/helixosio/helixos/pull/1383)

## Objective and outcome

Fix the circular Payroll Provider workflow that required disabling an enabled provider before publishing its first file-generation configuration. Save now persists the draft while deferring capability activation, and Publish activates the configuration before enabling file generation.

## Delivered changes and decisions

- Sequenced draft save, configuration publication, and provider activation so the API invariant remains intact.
- Preserved the pending provider draft until publication completes and allowed Publish only when file-generation activation is the sole remaining provider change.
- Saved unrelated provider edits safely before publication, then retained only the deferred activation transition.
- Added regression coverage proving the request order is save provider, save config, publish config, then activate the provider capability.
- Updated the Payroll Provider authoring documentation.
- Commits: `42dca45e5` (`fix(web): publish config before enabling payroll generation`) and `4143f4cbf` (`fix(web): save unrelated provider edits before publish`).

## Validation, review, and CI

- Targeted web tests: 35 passed across two suites.
- Targeted ESLint: passed for all changed TypeScript files.
- In-app-browser UAT reproduced the reported Exponent HR flow from a clean database and confirmed Save then Publish succeeds without disabling the provider.
- Mandatory architecture self-review found no actionable issues; tracked worktree was clean at the exact-tree checkpoint.
- The exact-head review finding about unrelated unsaved edits was addressed, its thread was resolved, and the reviewer approved head `4143f4cbf` with no remaining findings.
- CI run `33101983601` passed `backend-and-infra`, `web-unit`, and `web-e2e` on the exact final head.
- PR #1383 merged on the reviewed, green head.

## Risk and follow-up

If provider activation fails after publication, the valid config remains published while the provider stays in its prior safe state; invalidation refreshes the editor for retry. No follow-up is currently required.
