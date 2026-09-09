# HelixOS Work - Atomic TEST deployment activation after bootstrap transport failure

## Identity

- Status: Completed and merged
- Repository: `helixosio/helixos`
- Completed: 2026-09-09T07:29:54Z
- Task/thread ID: Unavailable
- Branch: `codex/issue-1733-atomic-test-deploy`
- Final head SHA: `5d9061bf324377656901bc77942a38fc39cf8461`
- Issue: [#1733](https://github.com/helixosio/helixos/issues/1733)
- PR: [#1759](https://github.com/helixosio/helixos/pull/1759)

## Objective and outcome

Prevent a transient Azure PlatformAdmin bootstrap transport failure from advancing only part of a TEST release and leaving mixed application revisions. PR #1759 merged after approval, clean current-head CI, and an authorized controlled Azure TEST failure/recovery exercise. Issue #1733 closed and its project item moved to Done.

## Delivered changes and decisions

- Added bounded retries for replay-safe container-exec transport failures, including the observed WebSocket protocol exception, and for known transient declarative Azure control-plane writes.
- Made post-migration bootstrap failure an immediate activation gate that leaves the API parked and blocks Functions, portal, web, and smoke-test progression.
- Added final exact-image/readiness verification for API, Functions, portal, and web before smoke testing.
- Added focused shell and Node deployment-contract coverage plus operator and recovery documentation.
- Ran a disposable TEST-only fault build immediately before bootstrap, with database reseeding disabled, then recovered by rerunning the exact PR head.
- Kept logs and telemetry enabled. Temporarily disabled the 15 TEST resource-group alert rules after capturing their state, then restored and verified all 15 enabled after recovery. No Beta or Production operation occurred.
- Corrected the merged PR description so its implementation, validation, file-breakdown table, and live TEST evidence render correctly.
- Merge commit: `ab85667d7bf9cc344f8481a188b263703920ee9d`.

## Validation, review, and CI

- Local build passed.
- Deployment contract tests passed 50/50; focused retry and migration-runtime shell suites passed.
- Hermetic API passed 4,408/4,408; payroll 323/323; browser-auth 47/47; web unit 2,493/2,493; payroll-cycle UI 373/373; quote UI 77/77; client portal 226/226; web theme/script checks 21/21.
- Required current-head CI passed: [run 34319284611](https://github.com/helixosio/helixos/actions/runs/34319284611).
- Exact-head GitHub review approved with no findings, review comments, or unresolved threads.
- Controlled failure [run 34320033881](https://github.com/helixosio/helixos/actions/runs/34320033881) exited at the intended gate: the API remained parked and no downstream activation or smoke step ran.
- Recovery [run 34321390726](https://github.com/helixosio/helixos/actions/runs/34321390726) succeeded: bootstrap completed, one healthy active Functions revision used the selected image, API/web/portal used the PR image, final exact-image verification passed, and the public TEST health probe returned HTTP 200.
- Final Azure read-back confirmed all 15 TEST alert rules restored enabled.

## Risk and follow-up

Azure resources remain non-transactional. A persistent provider failure still requires an operator rerun, and the environment is not exact-release evidence until final image verification and smoke testing succeed. The live exercise proved the deterministic post-migration stop and recovery boundaries; the intermittent WebSocket exception itself remains nondeterministic in Azure and is covered by deterministic retry tests.

The merged PR worktree and local branch were removed, and GitHub had already removed the remote head. An empty local directory shell remains because the filesystem safety guard rejected deleting it. The unmerged disposable TEST fault branch and worktree are intentionally retained because deleting unmerged evidence requires separate authority.
