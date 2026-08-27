# HelixOS Work - Restore TEST deployment revision contract

## Identity

- Status: Completed
- Repository: `helixosio/helixos`
- Completed: 2026-08-27T07:58:43Z
- Task/thread ID: Unavailable
- Branch: `codex/test-deploy-revision-contract`
- Final branch head SHA: `aa8cf86dc11c77a0c761aae5ef22d0114c15002c`
- Merge SHA: `f79cc608eba5d3a087139606905f57cbd817559d`
- Issue: N/A
- PR: [#1377](https://github.com/helixosio/helixos/pull/1377)

## Objective and outcome

Correct the repository contract that caused automatic TEST deployments to reject a stale infrastructure proof after independently deployed hub changes. PR #1377 merged, the corrected TEST infrastructure proof was applied, and exact-merge TEST and BETA deployments both succeeded.

## Delivered changes and decisions

- Limited environment revision hashing to the selected environment root and its exact locally deployed Bicep module set.
- Aligned TEST workflow path filters with that source set.
- Added an early read-only infrastructure proof check before expensive runner setup while retaining the existing pre-mutation check.
- Added focused source-set and workflow-order contract coverage and updated operator documentation.
- Final PR head: `aa8cf86dc`.
- Merge commit: `f79cc608`.

## Validation, review, and CI

- Mandatory complete-diff architecture self-review found no actionable issue or added responsibility boundary.
- Infrastructure revision contract tests: 5 passed.
- Deployment runtime contract tests: 26 passed.
- TEST, BETA, and Production Bicep parameter compilation passed with existing warnings only.
- `git diff --check` passed.
- PR #1377 exact-head CI succeeded after one targeted rerun of the unrelated flaky `api-dev-command.test.mjs` job.
- TEST preview [33046636466](https://github.com/helixosio/helixos/actions/runs/33046636466) and apply [33046830686](https://github.com/helixosio/helixos/actions/runs/33046830686) succeeded from exact PR head.
- Automatic TEST deployment [33048776091](https://github.com/helixosio/helixos/actions/runs/33048776091) succeeded from exact merge `f79cc608`.
- Exact-merge BETA preview [33048868414](https://github.com/helixosio/helixos/actions/runs/33048868414) reported 2 expected creates, 0 deletes, and 0 modifications.
- BETA infrastructure apply [33049084422](https://github.com/helixosio/helixos/actions/runs/33049084422) succeeded and stamped the expected infrastructure revision.
- Only BETA PostgreSQL was restarted; `track_commit_timestamp=on` is active with no pending restart.
- BETA application deployment [33049834525](https://github.com/helixosio/helixos/actions/runs/33049834525) succeeded from the exact merge after build, migration validation, integration smoke, Bicep validation, runtime deployment, and cleanup passed.

## Risk and follow-up

The incident recovery is complete. Preventive follow-up remains: keep environment fingerprints aligned with infrastructure ownership, retain the minimal diagnostic ladder, and document the infrastructure operator/backup handoff. Production was not accessed or changed.
