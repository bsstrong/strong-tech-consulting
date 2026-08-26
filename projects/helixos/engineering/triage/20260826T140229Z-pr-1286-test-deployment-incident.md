# HelixOS TEST Deployment Incident — Issue #842 / PR #1286

## TL;DR

[PR #1286](https://github.com/helixosio/helixos/pull/1286) introduced the Daily Summary and Audit Report across 154 files. The feature depended on PostgreSQL `track_commit_timestamp=on`, an infrastructure change that had to be applied through the repository's manual protected infrastructure workflow and followed by a PostgreSQL restart before the application migration could run.

The repository already documented that infrastructure must be applied before dependent application deployment. The implementation plan failed to incorporate that requirement and allowed application code, database migrations, and the infrastructure prerequisite to merge together. That left `main` temporarily undeployable until the infrastructure operation was completed.

Recovery then exposed three additional defects:

1. The Bicep template submitted two PostgreSQL configuration changes concurrently. Azure rejected alternating writes with `ServerIsBusy`, leaving the authoritative ARM deployment record in `Failed`.
2. Once infrastructure succeeded, the hosted runner exhausted its disk while building five application images.
3. Once image builds succeeded, the Daily Payroll migration failed because its privileged backfill recognized local usernames but not the hosted database owner, `helixosadmin`.

Because application deployments intentionally fail closed when the infrastructure deployment record is failed or stale, unrelated merges could not deploy to TEST during recovery. The safety controls prevented un-migrated code from serving traffic, preserved the previous API image, and prevented partial Daily Payroll schema changes.

The incident lasted approximately **7 hours 43 minutes**, from PR #1286 merging at **2026-08-25 23:30 UTC** until the corrected TEST deployment completed at **2026-08-26 07:13 UTC**.

TEST is now deployed successfully. No Beta or Production environment was changed. No data loss, tenant-data exposure, runaway logging, or meaningful Azure Storage growth was found. Repeated builds added approximately **2.74 GB** of container registry artifacts.

## Incident summary

| Field | Value |
| --- | --- |
| Incident start | 2026-08-25 23:30 UTC |
| Incident end | 2026-08-26 07:13 UTC |
| Duration | Approximately 7h 43m |
| Environment affected | TEST |
| Beta affected | No |
| Production affected | No live Production environment was accessed |
| Primary feature | Daily Summary and Audit Report, Issue #842 |
| Originating change | [PR #1286](https://github.com/helixosio/helixos/pull/1286), merge `98d6bdf8` |
| Recovery PRs | [#1326](https://github.com/helixosio/helixos/pull/1326), [#1341](https://github.com/helixosio/helixos/pull/1341), [#1343](https://github.com/helixosio/helixos/pull/1343) |
| Final successful infrastructure run | [32938313237](https://github.com/helixosio/helixos/actions/runs/32938313237) |
| Final successful application run | [32937893060](https://github.com/helixosio/helixos/actions/runs/32937893060), attempt 3 |

## Background: PR #1286

PR #1286 implemented a persisted Daily Payroll report with:

- Immutable JSON snapshots and generated workbooks.
- API, Dashboard, report-detail, and download surfaces reading the same persisted snapshot.
- Transactional outbox processing and Azure Functions handlers.
- Historical source reconstruction at the business-date cutoff.
- Named permissions, Carrier isolation, row-level security, audit records, and authenticated downloads.
- Proactive finalization of PostgreSQL commit timestamps so vacuum could not erase the ordering evidence needed for historical reconstruction.

That last responsibility required enabling PostgreSQL's static `track_commit_timestamp` server parameter. PR #1286 therefore added:

- `track_commit_timestamp=on` to local PostgreSQL.
- A Bicep PostgreSQL configuration resource for Azure.
- A runbook instruction requiring the setting to be applied and PostgreSQL restarted before the Daily Payroll schema migration.

PR #1286 passed its pre-merge CI and review gates, but those gates did not reproduce the complete hosted rollout sequence:

- They did not apply the actual TEST infrastructure.
- They did not restart TEST PostgreSQL.
- They did not run all migrations as the hosted `helixosadmin` database owner.
- They did not exercise the TEST hosted-runner disk constraints.
- They did not prove the protected infrastructure workflow and subsequent automatic application deployment as one end-to-end release path.

## Deployment ownership and documentation

The repository documentation before PR #1286 clearly established these technical requirements:

- The **Deploy Infrastructure** workflow was manual-only.
- Infrastructure had to be applied before the application deploy script.
- Preview and apply were separate workflow modes.
- The application workflow independently checked the exact `infrastructureRevision` and failed closed when it was stale or missing.

The repository did **not** document that Jeff, the system engineer, was the expected human operator for infrastructure deployments. That operator expectation was tribal knowledge.

This distinction matters:

- The plan should have discovered and incorporated the documented technical sequence without relying on tribal knowledge.
- The plan could not reliably infer that Jeff personally owned the operation because that ownership was not recorded in the repository.
- The missing Jeff handoff explains an operational coordination gap, but it does not excuse merging dependent application code before the documented infrastructure prerequisite was applied and verified.

## Impact

### Team impact

The TEST deployment pipeline was blocked for all code, not only Daily Payroll.

After the infrastructure apply failed, the named ARM deployment `helixos-test` remained in `Failed`. Azure does not expose usable outputs from that failed deployment record. The application deployment script correctly refused to continue with empty resource names.

This caused subsequent automatic TEST deployments, including the deployment following PR #1325, to fail before application mutation. The guard protected TEST, but the failed infrastructure record became a team-wide deployment blocker until a successful infrastructure apply replaced it.

### Application availability

There is no evidence that new Daily Payroll application code served against an incompatible database schema.

The deployment process:

- Stopped on stale or failed infrastructure.
- Stopped when image construction failed.
- Stopped when migrations failed.
- Restored the previously compatible API image after migration failure.
- Preserved the existing database rather than reseeding it.

TEST PostgreSQL was intentionally restarted at 03:13 UTC to activate `track_commit_timestamp`, causing the expected brief TEST interruption.

### Database impact

The failed Daily Payroll migration recorded:

- `applied_steps_count = 0`.
- No successfully completed migration timestamp.
- No rollback timestamp until controlled recovery.
- No partial Daily Payroll tables, types, functions, triggers, policies, or constraints.

The failure therefore left a Prisma migration-ledger record but did not leave a partially installed Daily Payroll schema.

After PR #1343 corrected the migration, exactly that zero-step failed ledger entry was transactionally marked rolled back with strict guards. No application data was rewritten.

### Cost and telemetry impact

No logging storm or Azure Storage anomaly was found.

- TEST Azure Storage transactions and bandwidth were equal to or lower than the preceding comparable window.
- Storage capacity changes were effectively zero.
- TEST Log Analytics volume increased approximately 5 MB, or 7.3%, primarily from short API startup bursts during revision changes.
- The observed Log Analytics records reported zero billable bytes.
- Function logging remained near its existing baseline and did not show a sustained spike.
- Repeated builds added approximately 2.74 GB to Azure Container Registry. These were image and build-cache artifacts, not logs, and represented roughly 1% of the registry's existing footprint.

## Detailed timeline

All times are UTC.

### 2026-08-25

#### 23:30 — PR #1286 merged

PR #1286 merged to `main` as `98d6bdf8`. The automatic TEST deployment began immediately.

#### 23:33 — Automatic TEST deployment stopped safely

[Run 32911052996](https://github.com/helixosio/helixos/actions/runs/32911052996) failed before application mutation:

> Successful Bicep deployment helixos-test does not match the current infrastructure revision.

This was expected fail-closed behavior. PR #1286 changed Bicep, but the matching infrastructure revision had not been applied.

#### 23:45–23:47 — Infrastructure preview succeeded

[Run 32912162677](https://github.com/helixosio/helixos/actions/runs/32912162677) ran with preview mode enabled. It performed a non-mutating Bicep what-if and uploaded a sanitized preview artifact.

The workflow was green, but it had not applied infrastructure.

### 2026-08-26

#### 01:15 — First infrastructure apply failed

[Run 32918287334](https://github.com/helixosio/helixos/actions/runs/32918287334), attempt 1, reached Azure Resource Manager.

Bicep submitted `azure.extensions` and `track_commit_timestamp` updates concurrently. Azure PostgreSQL accepted one operation and rejected the other:

> `ServerIsBusy`: Cannot complete operation while server is busy processing another operation.

Attempt 1 failed on `azure.extensions`.

#### 01:23 — Infrastructure rerun failed again

Attempt 2 failed on `track_commit_timestamp` for the same reason. The alternating failure demonstrated that the problem was concurrent configuration writes, not either configuration value individually.

The named `helixos-test` ARM deployment was now in `Failed`, so application deployments could no longer read its outputs.

The first failed infrastructure attempt also risked repointing the Functions runtime to an image tag that had not yet been published. TEST Functions was restored to its prior available image and verified running.

#### 02:46 — PR #1325 deployment was blocked

[Run 32923969550](https://github.com/helixosio/helixos/actions/runs/32923969550) followed an unrelated payroll-cycle PR. It failed because the `helixos-test` ARM deployment remained failed and exposed no outputs.

The PR #1325 application change was not the cause.

#### 02:47 — PR #1326 merged

[PR #1326](https://github.com/helixosio/helixos/pull/1326) made four focused corrections:

- Serialized the PostgreSQL configuration resources.
- Preserved the currently serving Functions image when the matching new image did not yet exist.
- Added regression coverage for these deployment contracts.
- Documented the infrastructure-first delivery requirement.

Its immediate automatic application deployment also stopped because the corrected infrastructure had not yet been applied.

#### 03:07–03:12 — Corrected infrastructure applied successfully

[Run 32925271321](https://github.com/helixosio/helixos/actions/runs/32925271321) successfully applied the serialized infrastructure changes and restored a valid ARM deployment record.

#### 03:13–03:14 — PostgreSQL restarted

Azure activity logs confirm a successful TEST PostgreSQL restart. This activated the static `track_commit_timestamp=on` setting.

#### 03:14–03:35 — Application deployment reached image builds but exhausted disk

[Run 32925706984](https://github.com/helixosio/helixos/actions/runs/32925706984) passed the infrastructure gate but failed while building the five deployment images:

> `failed to copy files: no space left on device`

The API image build failed. Application activation did not proceed.

#### 04:19 — PR #1341 merged

[PR #1341](https://github.com/helixosio/helixos/pull/1341) added:

- A shared hosted-runner cleanup action.
- TEST and Beta workflow integration for that cleanup.
- Capacity and Buildx setup validation.
- A five-image success barrier.
- Ordering that completes image publication before database-password alignment or other target-environment mutation.

#### 04:35–04:37 — Image builds succeeded; migration failed

[Run 32929761743](https://github.com/helixosio/helixos/actions/runs/32929761743) passed infrastructure validation and image construction.

The Daily Payroll migration then failed with Prisma `P3018` and PostgreSQL `P0001`:

> Daily payroll report source mutation requires prepared tenant ordering.

The migration's privileged backfill bypass recognized hard-coded users `helixos` and `helixos_system`. The hosted migration ran as `helixosadmin`, the actual database owner. The bypass did not recognize that owner, so an existing source-write trigger rejected the migration's backfill.

The deployment restored the previously serving API image, explicitly reporting that the running build still matched the schema.

#### 04:37–06:05 — Root-cause and blast-radius analysis

The investigation confirmed:

- The failed migration applied zero steps.
- No partial Daily Payroll schema objects existed.
- The hard-coded username check was the immediate cause.
- Local fresh-migration testing had used a different database identity and therefore concealed the defect.
- The hosted validation path had not tested all migrations as `helixosadmin` with active commit timestamps.
- Additional deployment and download-audit gaps from the original PR required bounded correction.

#### 06:05 — PR #1343 opened

[PR #1343](https://github.com/helixosio/helixos/pull/1343) corrected the original migration and deployment contracts:

- Replaced hard-coded migration usernames with database-owner capability checks.
- Tested all 207 migrations as `helixosadmin`.
- Required hosted migration validation with active `track_commit_timestamp`.
- Kept Bicep and the protected infrastructure workflow as the sole PostgreSQL control-plane owner.
- Made all five image builds fatal before target mutation.
- Verified the two new Daily Payroll Functions were registered from the exact image.
- Removed an obsolete direct PostgreSQL Contributor assignment after successful infrastructure apply.
- Persisted download intent before releasing workbook bytes.
- Preserved READY report-version visibility outside the bounded attempt list.

#### 06:22 — PR #1343 merged

The automatic deployment's first attempt stopped because PR #1343 changed the infrastructure revision. This was again safe, intended behavior.

#### 06:28–06:34 — Exact PR #1343 infrastructure applied

[Run 32938313237](https://github.com/helixosio/helixos/actions/runs/32938313237) completed successfully and recorded the matching infrastructure revision.

#### 06:35–06:51 — Application deployment reached Prisma's failed-ledger guard

[Run 32937893060](https://github.com/helixosio/helixos/actions/runs/32937893060), attempt 2, built the images and reached migrations. Prisma returned `P3009` because the prior zero-step failure from 04:36 remained in `_prisma_migrations`.

The API was again restored to its prior compatible image.

#### 07:01 — Controlled TEST migration-ledger recovery

After verifying zero applied steps and zero partial objects, exactly the failed `20260822195000_add_daily_payroll_report_v1` row was transactionally marked rolled back. No other migration row or application data was changed.

#### 07:02–07:13 — Final deployment succeeded

Attempt 3 completed:

- Bicep-first revision proof verified.
- All images available.
- Migrations completed at 07:07.
- PlatformAdmin bootstrap completed at 07:08.
- API activated.
- Workflow Function image and host reload verified.
- Required Function registrations verified.
- Client Portal and web deployed.
- Application Gateway smoke test passed.
- Run completed successfully at 07:13.

## Root-cause analysis

### Primary root cause: release planning omitted a documented infrastructure prerequisite

The repository already said:

- The infrastructure workflow is manual-only.
- Infrastructure must be deployed before the application.
- Preview and apply are separate workflow modes.
- Application deployment verifies the exact infrastructure revision and fails closed when it does not match.

The implementation plan should have identified `track_commit_timestamp` as a backward-compatible prerequisite and arranged for it to be:

1. Delivered independently.
2. Applied through the protected infrastructure workflow.
3. Followed by the required PostgreSQL restart.
4. Verified active.
5. Only then followed by the dependent application migration.

That did not happen. This was an agent-owned planning and delivery failure, not an undocumented requirement the owner was expected to discover during deployment.

The expectation that Jeff personally performs infrastructure deployments was not captured in the repository. That tribal knowledge should be converted into explicit ownership and handoff documentation, but the missing name did not remove the documented infrastructure-first requirement.

### Technical root cause 1: concurrent Azure PostgreSQL configuration writes

PR #1286 added `track_commit_timestamp` beside the existing `azure.extensions` PostgreSQL configuration resource without an explicit dependency.

ARM treated the sibling resources as parallel operations. Azure PostgreSQL Flexible Server permits only one control-plane operation at a time and rejected the second write with `ServerIsBusy`.

### Technical root cause 2: migration authorization depended on usernames

The Daily Payroll migration used hard-coded session usernames to authorize its one-time backfill. Local migrations ran under a recognized username; TEST used `helixosadmin`.

Authorization should have been based on database-owner capability, not an environment-specific principal name.

### Technical root cause 3: hosted runner capacity was not validated consistently

The Beta workflow already had runner cleanup evidence, but TEST did not use the same shared capacity preparation. The five-image build exhausted the runner before deployment could reach migrations.

This was a pre-existing pipeline defect exposed by the incident rather than a Daily Payroll business-code defect.

## Contributing factors

- PR #1286 was large: 154 files and more than 18,000 additions across database, workflow, Functions, API, UI, infrastructure, and documentation.
- The application and its independently deployable prerequisite were merged together.
- A green infrastructure preview could be mistaken for an apply unless the preview/apply distinction was explicitly called out.
- Pre-merge CI proved code quality but not the complete hosted deployment lifecycle.
- Fresh migration tests did not use the same database owner as TEST.
- The single named ARM deployment record intentionally exposes no outputs while failed, expanding a failed infrastructure apply into a team-wide deployment block.
- Recovery initially surfaced defects sequentially because each earlier guard prevented the pipeline from reaching the next layer.
- Human infrastructure ownership depended partly on tribal knowledge about Jeff rather than checked-in operational documentation.

## What worked correctly

Several safeguards materially limited the damage:

- The infrastructure revision guard prevented deployment against stale infrastructure.
- The failed-ARM-output guard prevented commands from using empty resource names.
- PostgreSQL and Prisma stopped the invalid migration.
- The migration was transactional and left zero partial schema objects.
- The API rollback mechanism restored the build matching the existing schema.
- TEST data was preserved; no reseed occurred.
- The application never served the new Daily Payroll runtime against an un-migrated schema.
- No Beta or Production environment was touched.
- Azure Storage and logging remained stable.
- The final correction added environment-faithful hosted migration and Function-registration verification.

## Corrective actions completed

| Action | Status |
| --- | --- |
| Serialize PostgreSQL configuration writes | Completed in PR #1326 |
| Preserve existing Functions image during infrastructure-first rollout | Completed in PR #1326 |
| Document infrastructure-first delivery ordering | Completed in PR #1326 |
| Reclaim hosted-runner disk before TEST/Beta builds | Completed in PR #1341 |
| Require all five images to build successfully | Completed in PR #1341/#1343 |
| Move target-environment mutation after image publication | Completed in PR #1341 |
| Replace migration username allow-list with owner capability | Completed in PR #1343 |
| Run all migrations as `helixosadmin` with commit timestamps active | Completed in PR #1343 validation |
| Verify required Daily Payroll Functions from the exact image | Completed in PR #1343 |
| Restore Bicep/protected workflow as sole PostgreSQL control-plane owner | Completed in PR #1343 |
| Repair exactly one zero-step failed Prisma ledger row | Completed in TEST |
| Apply exact corrected infrastructure revision | Completed |
| Complete TEST application deployment and gateway smoke test | Completed |

## Recommended follow-up actions

1. **Require an explicit deployment-impact section for every infrastructure-affecting PR.** It must identify whether the change is backward-compatible, whether it can be applied independently, whether a restart is required, the responsible operator, and the exact rollout and rollback order.

2. **Record Jeff's infrastructure ownership and handoff expectations.** Document what Jeff owns, who can act as backup, how to request an apply, and what evidence closes the handoff. Avoid person-only ownership without a named backup path.

3. **Land independently deployable infrastructure before dependent application code.** This exception should override the normal preference for one integrated cross-layer PR when the prerequisite can safely exist before the application uses it.

4. **Add an automated PR gate for infrastructure prerequisites.** A PR that changes Bicep plus dependent migrations should require an explicit infrastructure-first checkpoint rather than relying on reviewers to infer it.

5. **Preserve hosted-environment identity fidelity in migration tests.** Fresh migration CI should continue running as `helixosadmin`, with static server settings matching the destination environment.

6. **Exercise the deployment workflow before merging high-risk migration changes.** A disposable or isolated hosted rehearsal should prove infrastructure revision, image builds, migrations, activation, Function registration, and rollback.

7. **Evaluate reducing the blast radius of a failed named ARM deployment.** The fail-closed behavior is correct, but the team currently cannot deploy any application change while the authoritative deployment record is failed. A versioned last-successful output record could preserve safety without making every unrelated deployment depend on immediate infrastructure recovery.

8. **Audit ACR retention.** The registry already stores approximately 263.6 GB. The incident added about 2.74 GB. A retention policy should remove obsolete untagged manifests and build-cache artifacts without deleting rollback images.

9. **Perform feature-level TEST UAT.** The deployment and gateway smoke test passed. A final user-facing TEST walkthrough of Daily Payroll generation, saved JSON projection, downloads, and version history should still be recorded before Beta rollout.

10. **Use the corrected infrastructure-first sequence for Beta.** Apply and validate the exact Beta infrastructure revision, restart PostgreSQL only if the static parameter is not already active, verify `track_commit_timestamp=on`, and then deploy the application.

## Current status

- TEST infrastructure: healthy and revision-aligned.
- TEST PostgreSQL: running with the required configuration.
- Daily Payroll migration: applied successfully.
- TEST application deployment: successful.
- API, Functions, Client Portal, and web: deployed.
- Gateway smoke test: passed.
- Previous compatible API image: preserved as a rollback reference.
- Team deployment block: cleared.
- Beta: unchanged.
- Production: unchanged and not accessed.
- Data corruption: none found.
- Partial migration objects: none found.
- Logging or storage storm: none found.
- Remaining required validation: feature-level TEST UAT and controlled Beta planning.
