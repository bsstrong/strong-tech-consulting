# HelixOS Work - PostgreSQL Configuration Deployment Correction

## Identity

- Status: Completed
- Repository: `helixosio/helixos`
- Completed: 2026-08-26T02:47:02Z
- Task/thread ID: Not available
- Branch: `codex/issue-842-postgres-config-serialization`
- Final head SHA: `21c4677bc6765f76178478f2d6f8a1b7db180079`
- Issue: #842
- PR: [#1326](https://github.com/helixosio/helixos/pull/1326)

## Objective and outcome

Correct the TEST infrastructure deployment path that had alternated between Azure PostgreSQL `ServerIsBusy` failures and an unsafe Function App image update. PR #1326 merged as commit `2b89a4f2384fe7555ba6bfc47ca00f8a090317d5`, providing a fail-closed, independently deployable infrastructure correction before the dependent application deployment resumes.

## Delivered changes and decisions

- Serialized the PostgreSQL `track_commit_timestamp` configuration behind the extension configuration to prevent concurrent server configuration writes.
- Made the infrastructure-first deployment resolve its effective resource group, application name, and environment from Bicep parameters.
- Replaced inferred Azure resource names with exact tagged ACR and Function App discovery, failing on lookup errors or ambiguous matches.
- Preserved the live Functions container image when the requested tag is not published; retained the placeholder only for a true first deployment.
- Added a mocked Azure execution matrix covering the deployment branches and retained Bash 3 portability.
- Documented the infrastructure-precursor workflow so independently deployable infrastructure is applied and validated before dependent application code merges.
- Restored TEST Function App `func-helixos-test-shared-eus2` to `acrhelixostesteus2.azurecr.io/helixos-functions:637323cdee77234c6cd88992621fd0e9853822b2` after the failed deployment had repointed it.

## Validation, review, and CI

- `node --test src/scripts/deploy-runtime-contract.test.mjs`: 19 of 19 passed.
- Git Bash `bash -n scripts/infra/deploy.sh`: passed.
- `az bicep build --file infra/bicep/modules/stack/main.bicep --stdout`: passed with pre-existing warnings.
- `git diff --check`: passed.
- Read-only TEST Azure checks confirmed exact discovery of the tagged registry, Function App, and required repository.
- The complete four-file PR diff received the mandatory architecture review; portability, resource-discovery, and fail-closed findings were corrected and their review threads resolved before merge.
- PR #1326 was merged at 2026-08-26T02:47:02Z with final head `21c4677bc6765f76178478f2d6f8a1b7db180079`.

## Risk and follow-up

The correction is merged but the operational rollout is not recorded as complete. Apply the corrected infrastructure from current `main` to TEST, verify it succeeds, restart TEST PostgreSQL so `track_commit_timestamp` takes effect, and only then deploy the application. No Production environment operation is required or authorized.
