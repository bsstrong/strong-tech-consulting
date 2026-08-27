# HelixOS BETA Rollout Incident — Infrastructure Preview and Deployment Contracts

## TL;DR

The authorized HelixOS BETA rollout began from current `main` at **2026-08-27 00:31 UTC**. The first infrastructure preview failed before any BETA resource was applied. The protected workflow skipped every apply step, so the failure did **not** interrupt the existing BETA application, restart PostgreSQL, mutate the database, deploy application images, or access Production.

The rollout exposed three repository defects and one Azure limitation:

1. [PR #1348](https://github.com/helixosio/helixos/pull/1348) changed PostgreSQL private-DNS ownership but did not forward the resolved DNS-zone ID through the TEST, BETA, and Production environment roots into the shared stack. BETA was the first environment to exercise that newer runtime parameter path.
2. Azure Resource Manager What-If returned its known `DeploymentWhatIfResourceInvalidResponse` / unexpected `BadRequest` failure for the Function App `config/appsettings` child resource. This prevented a predictive drift list even when non-mutating validation could establish that the deployment request was valid.
3. The preview sanitizer correctly withheld secret-shaped raw output, but the workflow had no narrow, safe way to distinguish the known Azure limitation from a real deployment defect. The initial artifact therefore contained only a withholding notice and no actionable error.
4. Recovery exposed a separate TEST deployment-contract defect: the infrastructure fingerprint included independently deployed modules that the TEST stack did not own, while the TEST workflow path filters correctly did not run for those modules. Every automatic TEST deployment since [PR #1345](https://github.com/helixosio/helixos/pull/1345) had been failing closed on that stale proof.

The diagnostic response also took too long and became too complex. Multiple temporary branches and preview implementations were tried before the minimal direct Azure call and guarded validation fallback were used. That produced avoidable GitHub Actions runs, review churn, and elapsed time. Two preview-only runs then wrote 142 Azure resource identifiers to the job log while attempting to preserve safe evidence. Those two complete run records were purged. No credential value was observed in the pre-purge scan, and neither run applied infrastructure.

[PR #1375](https://github.com/helixosio/helixos/pull/1375) corrected the DNS contract and hardened preview diagnostics. It merged at **06:37 UTC** after three review rounds found and resolved five blocking safety/correctness findings. [PR #1377](https://github.com/helixosio/helixos/pull/1377) corrected the TEST revision contract, passed exact-head CI after one unrelated flaky-test rerun, and merged at **07:12 UTC** as `f79cc608eba5d3a087139606905f57cbd817559d`.

An exact-merge BETA preview then completed successfully with:

- `Create`: 2 — the expected Daily Payroll Service Bus subscription and filter rule.
- `Delete`: 0.
- `Modify`: 0.
- `Deploy`: 123 existing resources ARM will reconcile.
- `Ignore`: 17 existing resources omitted from change application by What-If.

The exact-merge BETA infrastructure apply succeeded. Azure recorded the expected infrastructure revision, only the HelixOS BETA PostgreSQL server was restarted, and `track_commit_timestamp=on` is active with no pending restart. The exact-SHA BETA application deployment then passed build, migration validation, integration smoke, Bicep validation, runtime deployment, and cleanup. The incident closed at **07:58 UTC**, approximately **7 hours 28 minutes** after the scheduled rollout began. Production remained out of scope and was not accessed.

## Incident summary

| Field | Value |
| --- | --- |
| Incident start | 2026-08-27 00:31 UTC |
| Incident end | 2026-08-27 07:58 UTC |
| Elapsed time | Approximately 7 hours 28 minutes |
| Environment affected | BETA rollout path |
| BETA runtime availability | Existing runtime remained unchanged; no outage caused by failed previews |
| TEST impact | Separate pre-existing revision-contract defect surfaced during recovery and continued blocking automatic TEST deploys until PR #1377 |
| Production impact | None; Production was not accessed |
| Primary originating defect | [PR #1348](https://github.com/helixosio/helixos/pull/1348), merge `07fd157f` |
| External contributor | Azure ARM What-If limitation for Function App `config/appsettings` |
| Closed diagnostic PR | [#1369](https://github.com/helixosio/helixos/pull/1369) |
| Recovery PRs | [#1375](https://github.com/helixosio/helixos/pull/1375), [#1377](https://github.com/helixosio/helixos/pull/1377) |
| Exact recovery merge | `f79cc608eba5d3a087139606905f57cbd817559d` |
| Exact-merge preview | [Run 33048868414](https://github.com/helixosio/helixos/actions/runs/33048868414) |
| BETA database restart | Completed; only `psql-helixos-beta-shared-eus2` restarted |
| BETA application deployment | [Run 33049834525](https://github.com/helixosio/helixos/actions/runs/33049834525), succeeded at exact recovery merge |

## Background

The prior TEST incident established the required BETA rollout order:

1. Pin one exact `main` revision.
2. Preview BETA infrastructure without applying it.
3. Inspect the sanitized preview for destructive or unexpected drift.
4. Apply infrastructure from the same exact revision.
5. Restart only BETA PostgreSQL if the static setting is pending restart.
6. Verify active `track_commit_timestamp=on`.
7. Deploy the BETA application from that same revision.
8. Validate the deployed application.

That ordering was followed. The preview gate is why the repository defects did not become a partial BETA deployment.

An earlier workflow run, [32984543235](https://github.com/helixosio/helixos/actions/runs/32984543235), was created during the August 26 GitHub Actions incident. GitHub later reported that Actions jobs failed to start from 15:02–15:45 UTC, startup delays continued while queues drained, and a subset of runs remained stuck until cancellation. Run 32984543235 never created a job and was eventually canceled. The owner therefore paused the rollout and scheduled the active attempt for 20:30 EDT / 00:30 UTC.

The GitHub outage delayed the rollout but did not cause the later BETA preview failure. The active rollout began after GitHub Actions had recovered.

## Impact

### BETA runtime and database

All failed attempts were preview-only. Their `Deploy stack infrastructure` steps were skipped.

Before the successful recovery apply:

- No BETA Azure resource was created, modified, or deleted by the failed previews.
- BETA PostgreSQL was not restarted.
- `track_commit_timestamp` was not activated by these previews.
- No Prisma migration ran against BETA.
- No container image was built, published, or activated for BETA.
- The existing BETA application continued serving its prior revision.
- No BETA data loss or partial schema state was created.

### Team and delivery impact

The rollout consumed several hours of owner and engineering attention. The response produced multiple temporary diagnostic branches, repeated workflow dispatches, and review cycles before reaching the minimal durable correction.

The recovery also discovered that TEST's automatic deployment path had been failing closed since PR #1345. This was not caused by PR #1375, but PR #1375's merge triggered the same existing proof mismatch and made the team-wide deployment block visible again. PR #1377 was required before another merged application change could deploy normally to TEST.

### Security and evidence handling

The original sanitizer correctly recognized secret-shaped preview content and withheld it rather than risking credential exposure. Its artifact said only:

> Infrastructure preview output was withheld because it contained secret-shaped fields.

During later diagnostics, runs 33040219808 and 33040418980 projected 142 Azure resource identifiers into the GitHub Actions job log. The runs were preview-only and every apply step was skipped. Both complete run records, including logs and artifacts, were deleted after inspection.

No credential value was observed in the pre-purge scan. The exposed values were Azure resource identifiers, which still should not have been written to routine job output. Repository access-log review was not performed, so this report does not claim who viewed the purged logs before deletion.

### Cost

The failed previews made Azure control-plane requests and consumed GitHub-hosted runner minutes. They did not create billable BETA resources or publish application images. No dollar estimate is made because billing data was not queried specifically for this incident.

## Detailed timeline

All times are UTC on 2026-08-27 unless stated otherwise.

### 2026-08-26 15:15 — GitHub Actions run stuck before job creation

[Run 32984543235](https://github.com/helixosio/helixos/actions/runs/32984543235) was dispatched during GitHub's critical Actions incident. It created no jobs and remained stuck until later cancellation. The BETA environment was untouched.

### 00:31 — First scheduled BETA preview failed safely

[Run 33027107232](https://github.com/helixosio/helixos/actions/runs/33027107232) used `main` at `cb6629e4c8f351efc8eaaed0dc3c689bfcb65166`.

- Identity and Bicep static validation passed.
- ARM What-If failed.
- The sanitizer withheld secret-shaped raw content.
- The stack apply step was skipped.

### 00:37 — Immediate confirmation failed the same way

[Run 33027471513](https://github.com/helixosio/helixos/actions/runs/33027471513) repeated the exact revision and preview scope. It produced the same safe failure and no BETA mutation.

### 01:09–01:52 — First diagnostic branch produced five failed previews

The `codex/beta-preview-diagnostics` branch attempted to expose a safe error summary, parse both output streams, bypass template-level noise, classify the known failure, and add guarded diagnostics.

The associated preview runs all failed before apply:

- [33029793719](https://github.com/helixosio/helixos/actions/runs/33029793719)
- [33030019912](https://github.com/helixosio/helixos/actions/runs/33030019912)
- [33030418087](https://github.com/helixosio/helixos/actions/runs/33030418087)
- [33030689945](https://github.com/helixosio/helixos/actions/runs/33030689945)
- [33031389305](https://github.com/helixosio/helixos/actions/runs/33031389305)

[PR #1369](https://github.com/helixosio/helixos/pull/1369) was opened at 01:10 and closed at 02:20 without merge. The branch did not produce a sufficiently simple or reliable correction.

### 02:22 — Current-main preview reconfirmed the blocker

[Run 33033092085](https://github.com/helixosio/helixos/actions/runs/33033092085) used later `main` at `376b82e8508241897c336bc65c99c8652bfbee97`. It failed in the same preview stage, withheld raw output, and skipped apply.

This proved the issue was not limited to the first pinned revision.

### 03:02–03:14 — Direct REST diagnostic iterations failed

Four `codex/beta-rest-whatif-diagnostic` previews attempted subscription-scope REST What-If calls:

- [33035127714](https://github.com/helixosio/helixos/actions/runs/33035127714)
- [33035326567](https://github.com/helixosio/helixos/actions/runs/33035326567)
- [33035476551](https://github.com/helixosio/helixos/actions/runs/33035476551)
- [33035703274](https://github.com/helixosio/helixos/actions/runs/33035703274)

These were diagnostic-only and did not apply resources.

### 03:52 — SDK diagnostic attempt also failed

[Run 33037665270](https://github.com/helixosio/helixos/actions/runs/33037665270) tried an SDK-based What-If request. It did not produce the required actionable result and did not apply resources.

At this point the response had become overengineered. A minimal direct call and the existing Azure validation mode should have been used earlier, before creating several repository-level diagnostic variants.

### 04:09–04:21 — Guarded validation identified both failure classes

The `codex/beta-whatif-validate-fallback` branch narrowed the known ARM error and used non-mutating validation as the fallback.

Early runs remained failed while the classifier and evidence path were developed:

- [33038555379](https://github.com/helixosio/helixos/actions/runs/33038555379)
- [33038716052](https://github.com/helixosio/helixos/actions/runs/33038716052)
- [33038950095](https://github.com/helixosio/helixos/actions/runs/33038950095)

[Run 33039105035](https://github.com/helixosio/helixos/actions/runs/33039105035) then exposed `BCP258`: the BETA `main.bicepparam` did not assign the newly required `postgresDnsZoneId` parameter. This converted the opaque preview failure into a concrete repository defect.

### 04:23 — First successful non-mutating BETA validation

[Run 33039253052](https://github.com/helixosio/helixos/actions/runs/33039253052) retained a compile-safe parameter-file default while the deployment driver supplied the resolved non-empty DNS-zone ID at runtime. The preview workflow completed successfully without applying infrastructure.

Because Azure What-If still hit the known Function App limitation, the artifact remained withheld and did not yet provide a drift list.

### 04:30–04:40 — Fallback ownership and safe projection improved

These preview-only runs succeeded:

- [33039640964](https://github.com/helixosio/helixos/actions/runs/33039640964) moved the fallback to `plan.sh`, the owner of stack preview behavior.
- [33039834177](https://github.com/helixosio/helixos/actions/runs/33039834177) preserved a safe drift projection when available.
- [33039981439](https://github.com/helixosio/helixos/actions/runs/33039981439) requested machine-readable What-If output.

### 04:42–04:48 — Two preview logs exposed resource identifiers and were purged

Runs 33040219808 and 33040418980 were preview-only. Their sanitizer wrote 142 projected Azure resource identifiers to the job log and artifact. Both run records were deleted. No apply step ran and no credential value was observed.

The retained pre-purge projection counts were:

| Change type | Count |
| --- | ---: |
| Create | 2 |
| Deploy | 123 |
| Ignore | 17 |
| Delete | 0 |
| Modify | 0 |
| Unsupported | 0 |

### 04:59 — PR #1375 opened

[PR #1375](https://github.com/helixosio/helixos/pull/1375) combined the DNS-zone contract correction, exact known-error classifier, validation fallback, preview projection, multi-scope result isolation, raw-file cleanup, and documentation.

### 05:17–06:07 — Review found five blocking defects across three rounds

The review sequence was:

- 05:17 — two blocking preview-safety findings.
- 05:47 — two additional blocking correctness findings after the first correction.
- 05:59 — one remaining preview-safety finding.
- 06:07 — exact-head approval with no actionable findings.

The findings were resolved before merge. They also confirm that the recovery patch had grown large enough that additional safety defects were being introduced during correction.

### 06:29 — PR #1377 opened for the TEST revision contract

Investigation of repeated TEST deployment failures found that the revision calculator hashed all Bicep modules, including independently deployed hub/shared modules. The TEST workflow correctly did not trigger for those independent paths, so its proof could become stale without any supported stack apply to refresh it.

[PR #1377](https://github.com/helixosio/helixos/pull/1377) constrained the fingerprint to the selected environment stack's actual source closure, aligned workflow path filters, and moved the first proof check before expensive setup.

### 06:37 — PR #1375 merged; TEST failed on the pre-existing proof mismatch

PR #1375 merged as `a6a166fba17bd1ca09b3e6fb4ebe58c84366bc12`.

[TEST run 33046541808](https://github.com/helixosio/helixos/actions/runs/33046541808) then failed before application mutation because its stored infrastructure proof reflected the old broad revision contract. This failure was expected once the separate PR #1377 diagnosis was known.

### 06:39–06:47 — PR #1377 TEST preview and apply succeeded

- [TEST preview 33046636466](https://github.com/helixosio/helixos/actions/runs/33046636466) reported no deletes, no modifications, and no creates.
- [TEST apply 33046830686](https://github.com/helixosio/helixos/actions/runs/33046830686) stamped the corrected exact-stack revision proof without deploying application images.

### 06:38–07:11 — PR #1377 CI completed after one unrelated flaky rerun

The first `backend-and-infra` attempt failed in the existing `api-dev-command.test.mjs` watcher-coalescing test. No PR #1377 file or focused contract failed. Only that job was rerun. The previously failing watcher test passed on attempt 2, and exact-head CI completed successfully at 07:11.

### 06:56–06:58 — Branch-head BETA preview succeeded

[Run 33047729728](https://github.com/helixosio/helixos/actions/runs/33047729728) previewed BETA at PR #1377 head `aa8cf86dc11c77a0c761aae5ef22d0114c15002c` and produced the expected 2 creates, 123 deploys, 17 ignores, 0 deletes, and 0 modifications.

No apply was started from the unmerged branch.

### 07:12 — PR #1377 merged

PR #1377 merged to `main` as `f79cc608eba5d3a087139606905f57cbd817559d`.

### 07:13–07:16 — Exact-merge BETA preview succeeded

[Run 33048868414](https://github.com/helixosio/helixos/actions/runs/33048868414) used exact merged `main` SHA `f79cc608eba5d3a087139606905f57cbd817559d`.

The sanitized artifact confirmed:

| Change type | Count | Disposition |
| --- | ---: | --- |
| Create | 2 | Expected Daily Payroll Service Bus subscription and filter rule |
| Delete | 0 | No destructive deletion |
| Modify | 0 | No explicit property modification record |
| Deploy | 123 | Existing BETA resources ARM will reconcile |
| Ignore | 17 | Existing resources omitted from application by What-If |

### 07:17–07:21 — Exact-merge BETA infrastructure apply succeeded

[Run 33049084422](https://github.com/helixosio/helixos/actions/runs/33049084422) used the same exact merge commit and completed successfully at 07:21:48. Azure recorded named deployment `helixos-beta` as `Succeeded` and stored infrastructure revision `ba6cd26344dfb06a796e975368102b270e81a6afb42565fca8754e948c6b89b9`.

### After 07:21 — BETA-only PostgreSQL restart completed

Azure reported `track_commit_timestamp=on` with a pending restart. Only `psql-helixos-beta-shared-eus2` in `rg-helixos-beta-eus2` was restarted. The server returned to `Ready`; the parameter remained `on`, `isConfigPendingRestart=false`, `isDynamicConfig=false`, and source `user-override`.

### 07:28 — Exact-merge BETA application deployment started

[Run 33049834525](https://github.com/helixosio/helixos/actions/runs/33049834525) started from exact merge `f79cc608eba5d3a087139606905f57cbd817559d`. Build, local migration validation, and local database seeding passed before the terminal deployment gate.

### 07:40 — Automatic TEST application deployment succeeded

[Run 33048776091](https://github.com/helixosio/helixos/actions/runs/33048776091) completed successfully from exact merge `f79cc608eba5d3a087139606905f57cbd817559d`. The corrected infrastructure-revision contract passed both proof gates and the TEST runtime deployment completed.

### 07:58 — Exact-merge BETA application deployment succeeded

[Run 33049834525](https://github.com/helixosio/helixos/actions/runs/33049834525) completed successfully from exact merge `f79cc608eba5d3a087139606905f57cbd817559d`. Its build, local migration application, seed, integration smoke suite, Bicep validation, Azure login, BETA runtime deployment, and cleanup steps all passed. The hosted integration log explicitly reported `Smoke test passed.`

## Root-cause analysis

### Primary repository root cause: incomplete PostgreSQL DNS ownership refactor

[PR #1348](https://github.com/helixosio/helixos/pull/1348) moved per-environment PostgreSQL private DNS-zone ownership to the shared hub. The shared application stack no longer referenced the zone directly; it accepted `postgresDnsZoneId`, and `deploy.sh` resolved the correct zone.

The refactor did not add the matching parameter declaration and module forwarding to all three environment roots. The deployment driver could resolve the value, but the environment root could not accept and pass it into the stack.

The correction in PR #1375:

- Declares the parameter in TEST, BETA, and Production roots.
- Forwards it to the shared stack.
- Rejects an explicitly empty value.
- Rejects failed or empty discovery.
- Preserves a non-empty explicit override.
- Keeps a compile-only default in committed parameter files while supplying the resolved runtime value through the supported deployment driver.

### Azure contributor: Function App What-If limitation

Azure ARM What-If returned `DeploymentWhatIfResourceInvalidResponse` for the Function App's `config/appsettings` child and an unexpected `BadRequest`. The same deployment could pass non-mutating validation.

The corrected implementation falls back only when one ARM failure detail contains the complete exact known signature. Any incomplete signature, extra failure detail, sibling resource path, non-Function-App site, or failed validation remains fatal.

This is intentionally a preview fallback, not an apply bypass. It never converts a failed validation into permission to deploy.

### Observability root cause: all-or-nothing sanitization

The original sanitizer treated raw Azure output containing secure-parameter-shaped fields as wholly unsafe. That was the correct default for secrets, but it discarded the error structure needed to diagnose a non-secret infrastructure failure.

The corrected path:

- Keeps raw Azure output in a private runner-local file.
- Requests machine-readable `ResourceIdOnly` What-If output.
- Projects only structurally validated change type and resource ID into the private artifact.
- Writes no preview payload to the job log.
- Deletes raw captures.
- Keeps scopes isolated so one withheld result cannot hide another scope's failure.

### Secondary repository root cause: TEST fingerprint exceeded TEST ownership

The old revision calculator included every file under `infra/bicep/modules`. Independently deployed hub, shared-service, and tax-service modules could therefore change the TEST application-stack fingerprint even though the TEST application workflow intentionally did not trigger for those paths.

PR #1344 changed an independently deployed hub module. PR #1345 later changed a shared deployment script and triggered TEST, exposing the stale broad fingerprint. Fifteen subsequent push-triggered TEST deployments failed the same pre-deployment gate before PR #1377.

PR #1377 makes the source set and trigger set describe the same owned deployment unit and preserves a second proof check immediately before runtime mutation.

### Process root cause: the diagnostic path was not kept minimal

The first safe failure proved only that raw output could not be emitted. The fastest next step was a one-off direct Azure REST call or the already supported non-mutating validation mode using the exact resolved template and parameters.

Instead, the response iterated through workflow-output parsing, template-level preview variants, a dedicated REST diagnostic branch, an SDK diagnostic, and several classifier/sanitizer shapes. This increased code churn and review surface before the concrete DNS defect was isolated.

The durable fix needed repository changes, but the investigation should have used the smallest disposable diagnostic first and modified the repository only after the failure mode was known.

## Why TEST did not expose the BETA DNS failure

This was a revision and execution-path difference, not proof that BETA behaves differently from TEST.

- [TEST infrastructure run 32925271321](https://github.com/helixosio/helixos/actions/runs/32925271321) successfully applied the stack before PR #1348's DNS ownership refactor.
- At that revision, the shared stack referenced the existing PostgreSQL DNS zone directly.
- PR #1348 changed the parameter path afterward.
- Later TEST application deployments were failing earlier at the stale infrastructure-revision proof, so they never exercised the newer BETA DNS parameter path.
- The first BETA rollout against later `main` was therefore the first complete hosted exercise of that refactored stack contract.

## What worked correctly

- Preview and apply were separate protected workflow modes.
- Every failed preview skipped all infrastructure apply steps.
- The secret-shaped-output guard prevented raw deployment parameters from reaching logs or artifacts.
- No blind apply was attempted to obtain a better error.
- The exact complete known Azure failure is now required before validation fallback.
- Validation fallback remains non-mutating and fails closed.
- Review caught five additional safety/correctness defects before PR #1375 merged.
- The exact-head TEST infrastructure preview and apply were completed before PR #1377 merged.
- Exact-head CI passed before PR #1377 merged.
- A fresh BETA preview was rerun from the exact merge commit rather than relying on the branch preview.
- Production remained untouched.

## Corrective actions completed

| Action | Status |
| --- | --- |
| Forward PostgreSQL DNS-zone ID through all environment roots | Completed in PR #1375 |
| Fail closed on empty or unresolved PostgreSQL DNS-zone ID | Completed in PR #1375 |
| Add exact known ARM What-If classifier | Completed in PR #1375 |
| Add non-mutating validation fallback for only that exact failure | Completed in PR #1375 |
| Keep raw preview output off stdout and out of uploaded artifacts | Completed in PR #1375 |
| Preserve only safe machine-readable change projections | Completed in PR #1375 |
| Isolate multi-scope preview status and artifacts | Completed in PR #1375 |
| Purge the two preview runs that logged resource identifiers | Completed |
| Constrain TEST revision proof to the environment stack's owned sources | Completed in PR #1377 |
| Align TEST workflow path filters with the same source set | Completed in PR #1377 |
| Move TEST proof before expensive setup | Completed in PR #1377 |
| Preserve second pre-mutation proof | Completed in PR #1377 |
| Apply corrected TEST proof from exact PR #1377 head | Completed |
| Complete exact-head PR #1377 CI | Completed |
| Merge PR #1377 | Completed |
| Run exact-merge BETA preview | Completed; clean |
| Apply exact-merge BETA infrastructure | Completed; succeeded |
| Restart only BETA PostgreSQL | Completed |
| Verify active `track_commit_timestamp=on` | Completed; no restart pending |
| Deploy and validate exact-merge BETA application | Completed; succeeded |
| Complete automatic exact-merge TEST deployment | Completed; succeeded |

## Recovery outcome

The recovery is terminally successful. Exact-merge TEST and BETA application deployments passed, the BETA database configuration is active, and the protected workflow completed its runtime validation. Remaining work is preventive follow-up, not incident recovery.

## Prevention and follow-up recommendations

1. **Test every environment root-to-module contract.** Any new root parameter must be declared, assigned safely for static compilation, forwarded into the owned module, and exercised in TEST, BETA, and Production static compilation. Production compilation is static only; it does not authorize Production access.

2. **Use a minimal diagnostic ladder.** For an opaque protected-workflow failure: inspect the safe artifact, reproduce one exact non-mutating request through REST/CLI, run validation if What-If has a known provider limitation, and only then create repository code. Do not begin with a new SDK or generalized diagnostic framework.

3. **Keep diagnostic output private by construction.** Raw Azure responses belong only in runner-local files. Logs should contain status and counts, not resource identifiers, parameters, deployment payloads, or serialized error objects.

4. **Keep deployment fingerprints aligned with ownership.** A stack fingerprint must include exactly the sources the supported stack apply owns. Independently deployed infrastructure needs its own proof and trigger contract.

5. **Add a hosted environment-root contract rehearsal for infrastructure refactors.** A non-mutating protected preview from an exact branch should be required before merging changes that alter environment-to-module parameter flow.

6. **Keep independently deployable infrastructure ahead of dependent application changes.** Apply backward-compatible prerequisites before merging application code that requires them.

7. **Set a diagnostic circuit breaker.** After two failed diagnostic implementations or two attempts that expand the patch without producing a more specific error, stop repository changes, restate the known evidence, and use one direct disposable diagnostic.

8. **Document the operator handoff.** The repository should state that Jeff is the expected infrastructure operator, name a backup, and list the evidence required before dependent application deployment. The technical workflow must remain executable by authorized backups.

9. **Track temporary diagnostic artifacts.** Any temporary PR, branch, run, or artifact must have an explicit terminal disposition: merge, close, delete, or retain with a reason.

10. **Record exact elapsed time and runner usage after terminal recovery.** The final report should include the completed end time and available GitHub Actions duration evidence without estimating dollar cost.

## Current status

- PR #1375: merged.
- PR #1377: merged at exact SHA `f79cc608eba5d3a087139606905f57cbd817559d`.
- PR #1377 exact-head CI: passed after one targeted rerun of an unrelated flaky job.
- TEST corrected infrastructure proof: applied.
- Automatic TEST deployment from the PR #1377 merge: succeeded in [run 33048776091](https://github.com/helixosio/helixos/actions/runs/33048776091) at the exact merge commit.
- Exact-merge BETA preview: passed with two expected creates and no deletes or modifications.
- Exact-merge BETA infrastructure apply: succeeded.
- BETA PostgreSQL restart: completed for only `psql-helixos-beta-shared-eus2`.
- Active BETA `track_commit_timestamp=on` verification: passed; no restart pending.
- BETA application deployment: succeeded in [run 33049834525](https://github.com/helixosio/helixos/actions/runs/33049834525) at the exact merge commit.
- Incident recovery: complete at 07:58 UTC.
- Closed PR #1369 diagnostic branch/worktree: deleted.
- BETA data mutation from failed previews: none.
- Production access or mutation: none.
