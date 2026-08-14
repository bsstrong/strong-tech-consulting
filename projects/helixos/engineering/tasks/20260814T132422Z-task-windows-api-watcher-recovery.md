# HelixOS Task — Windows API Watcher Startup Recovery

## Identity

- Status: blocked
- Repository: `helixosio/helixos`
- Task started: `2026-08-14T13:24:22Z`
- Task/thread ID: current Codex task; durable ID unavailable
- Starting branch: `codex/windows-api-watcher-recovery` from `origin/main`
- Starting base SHA: `31c57385d9965607e22813b1619b343a37e7c54b`
- Starting head SHA: `31c57385d9965607e22813b1619b343a37e7c54b`
- Issue: N/A
- PR: [helixosio/helixos#1150](https://github.com/helixosio/helixos/pull/1150) (Draft)

## Objective and scope

Diagnose and fix the recurring Windows local-development failure in which the initial Helix API `tsx watch` process remains alive but never binds port 4000, requiring a manual API-watcher restart. Deliver the fix in a separate Draft pull request.

Exclusions and owner decisions:

- Preserve Draft PR #1117, its paused review state, and its unpushed local dependency-injection fix unchanged.
- Keep the currently running PR #1117 development stack available while developing and testing this isolated startup fix where practical.
- Do not broaden this task into unrelated local-development or application behavior changes.
- Owner requires explicit verification that PR #1150 does not change intentional macOS or Linux launcher behavior because those development environments are healthy.
- Owner authorized the complete private `#self-reviews` workflow, including actionable fixes, validation, logical commits, pushes, and up to three rerun requests under the workflow safety limits.
- Two consecutive review rounds found omissions in the same process-identity boundary, activating the churn circuit breaker. The cohesive correction is pushed, but another automated rerun now requires explicit owner approval.

## Lifecycle

| Milestone | Timestamp | Duration or evidence |
| --- | --- | --- |
| Task started | `2026-08-14T13:24:22Z` | — |
| Implementation/handoff | `2026-08-14T13:41:43Z` | Commit `5e3d83a952195f2972b27b9914553e7aa93e8c92` pushed on the dedicated branch |
| PR created | `2026-08-14T13:42:09Z` | 17 minutes 47 seconds from task start; Draft PR #1150 |
| Review | `2026-08-14T13:41:43Z` | Mandatory local architecture self-review completed with zero actionable findings; external review remains paused |
| CI | `2026-08-14T13:42:13Z` | Exact-head HelixOS CI and Windows Watcher CI jobs reported `SKIPPED`, as required for Draft pull requests |
| Completed | `2026-08-14T13:42:33Z` | 18 minutes 11 seconds total elapsed |
| Resumed for PR discussion | `2026-08-14T13:56:02Z` | Owner requested switching the active HelixOS workspace to PR #1150's branch; no review or code change requested |
| Discussion checkout complete | `2026-08-14T13:57:06Z` | Active workspace switched to the exact PR head in 1 minute 4 seconds |
| Resumed for platform-isolation review | `2026-08-14T13:58:21Z` | Inspect every changed entry point and validate that macOS/Linux behavior remains unchanged |
| Platform-isolation review complete | `2026-08-14T14:01:18Z` | 2 minutes 58 seconds; exact-base diff, launcher contract check, and 8 focused tests found zero actionable issues |
| Private self-review resumed | `2026-08-14T20:45:28Z` | Exact head `5e3d83a952195f2972b27b9914553e7aa93e8c92`; fetched `origin/main` advanced to `889edf5d323f067f657a786df3b02c95d2c2b054` and requires freshness inspection before Slack write |
| Branch synchronized with current base | `2026-08-14T20:48:11Z` | Owner-authored merge commit `bde29aac93398907480fe5ad710e0618c0357c67`; no PR/base path overlap and the PR diff remains the same six files |
| Private self-review requested | `2026-08-14T20:49:35Z` | New `#self-reviews` parent `1786740575.153389` contains only the canonical PR URL; exact head `bde29aac93398907480fe5ad710e0618c0357c67`, base `889edf5d323f067f657a786df3b02c95d2c2b054` |
| Private self-review round 1 completed | `2026-08-14T20:53:23Z` | 3 minutes 48 seconds; 1 blocker, 0 non-blockers; pending monitor deleted when the owner reported completion |
| Round 1 remediation pushed | `2026-08-14T21:01:38Z` | Commit `d48487af637ee662dc601bd887167d2650946d15` fixes neutral-worktree ownership and updates focused coverage and documentation |
| Rerun checkpoint | `2026-08-14T21:03:02Z` | Exact head `d48487af637ee662dc601bd887167d2650946d15`, fetched base and merge base `889edf5d323f067f657a786df3b02c95d2c2b054`; clean worktree and fresh base |
| Private self-review rerun requested | `2026-08-14T21:04:16Z` | Posted exactly `rerun` in parent thread `1786740575.153389`; Slack acknowledged that re-review resumed for exact head `d48487af637ee662dc601bd887167d2650946d15` against base `889edf5d323f067f657a786df3b02c95d2c2b054` |
| Private self-review round 2 completed | `2026-08-14T21:09:24Z` | 5 minutes 8 seconds; 1 blocker, 0 non-blockers; relative or root-relative runner/`tsx` paths could be resolved against the current launcher and misclassify an unrelated process |
| Churn circuit breaker activated | `2026-08-14T21:09:24Z` | Two rounds identified omissions in the same process-identity boundary; monitoring automation deleted and no further rerun was posted |
| Round 2 remediation pushed | `2026-08-14T21:14:42Z` | Commit `e687e35238871904b6e9d76b7701d0c0339a838b` accepts only fully qualified watcher paths and covers relative and root-relative runner and `tsx` forms |
| Workflow blocked for owner approval | `2026-08-14T21:15:49Z` | Exact head `e687e35238871904b6e9d76b7701d0c0339a838b`, base and merge base `889edf5d323f067f657a786df3b02c95d2c2b054`; clean Draft PR with no reviewer requests; another private rerun requires explicit approval |
| Circuit-breaker review corrected | `2026-08-14T22:05:22Z` | The owner asked whether the required review had actually been completed. The prior pass had not explicitly repeated the complete-diff architecture review. The completed review found one materially similar process-identity blocker: a standalone lookalike npm workspace command was trusted without a verified watcher descendant. Commit `170988b327be663b4a4778832b8423c3dcddf6a6` fixes and documents the shared boundary. |
| Circuit-breaker checkpoint complete | `2026-08-14T22:05:46Z` | Exact head `170988b327be663b4a4778832b8423c3dcddf6a6`, base and merge base `889edf5d323f067f657a786df3b02c95d2c2b054`; full-diff architecture review and complete relevant validation are clean; workflow remains blocked only on explicit owner approval for another rerun |

## Task statistics

| Statistic | Value | Evidence |
| --- | --- | --- |
| Total elapsed | 8 hours 41 minutes 24 seconds wall-clock; active-work duration unavailable because the task resumed across completed-state gaps | `2026-08-14T13:24:22Z` through `2026-08-14T22:05:46Z` |
| Commits | 4 in-scope commits plus 1 owner-authored base merge | `5e3d83a9 fix(dev): recover stalled Windows API watcher`; `d48487af6 fix(dev): recognize neutral Helix worktrees`; `e687e3523 fix(dev): reject ambiguous watcher paths`; `170988b32 fix(dev): anchor watcher workspace ancestry`; `bde29aac9` merge-forward |
| Change size | 583 insertions, 3 deletions across 6 files | Exact current base-to-head `git diff --shortstat` |
| Validation | Platform contract check passed; 8 focused watcher tests passed in 6.108 seconds; prior 96 full script tests passed with 2 Unix-only tests skipped on Windows; API build passed; 4 live HTTP assertions passed | Exact-base comparison, local command output, and Windows process/HTTP inspection |
| Review | 2 initial local reviews with 0 actionable findings; 2 private rounds returned 1 blocker and 0 non-blockers each; the corrected circuit-breaker full-diff architecture review returned and fixed 1 blocker; 1 rerun requested | `#self-reviews` thread `1786740575.153389` plus exact-base complete-diff inspection; all three blockers were reproduced before correction and share the process-identity boundary |
| CI | 5 exact-head jobs skipped because PR #1150 is Draft | GitHub `statusCheckRollup` for head `e687e35238871904b6e9d76b7701d0c0339a838b` |
| Benchmarks | Existing failure exceeded 80 seconds without binding; healthy supervised launches bound within the 45-second smoke windows | Prior process observation plus two consecutive live launcher runs |

## Work and decisions

- Prior observed failure evidence: during a clean `npm run dev:windows` launch, the API `cross-env`/`tsx watch` process tree remained alive for more than 80 seconds without listening on port 4000 or logging an error. Web, portal, workflow, and Rule Engine startup continued. Stopping only the API subtree and relaunching the same API workspace command bound port 4000 within seconds.
- Repository history showed that the prior July fix addressed restart storms from Node's native watcher by moving to `tsx watch`; it did not supervise initial readiness or clean stale Windows watcher trees.
- The selected boundary is a Windows-only local API runner. It owns process discovery/cleanup, initial `/api/health` readiness, one bounded restart, signal forwarding, and exact watcher-tree termination. `tsx watch` continues to own normal source-change restarts.
- The preflight excludes the new launch's own ancestry, targets only recognized Helix API workspace/runner/legacy watcher commands, and refuses to terminate an unrecognized owner of the configured API port.
- A watcher that exits explicitly is not retried. Only a watcher that remains alive but unready for 30 seconds is stopped and retried once; a second timeout exits clearly.
- Platform-isolation review confirmed the root `package.json` is unchanged, the API workspace's Unix `dev` command is byte-for-byte unchanged, and `dev:windows` is the only package script modified. The new runner is reachable from the documented launcher graph only through Windows-labeled commands.
- The only workflow change adds the new runner to path filters in `windows-watcher-ci.yml`, whose sole job runs on `windows-latest`. The documentation changes are explicitly Windows-scoped.
- The shared script-test file imports the Windows runner without executing it: direct execution is guarded, and PowerShell/process cleanup occurs only inside invoked Windows-runner functions. Its pure supervision tests remain platform-neutral.
- Before the private review request, `origin/main` advanced through seven commits without touching any of the PR's six paths. The branch was then merge-forwarded by the owner to current base; the active checkout fast-forwarded to that exact remote head without local changes.
- Private round 1 found that `isHelixApiWatcher` relied on the worktree path containing `helixos`, so an orphan runner or `tsx` watcher from a neutral-named worktree was not owned by the recovery workflow. The failing regression initially returned only PID `10` instead of `[10, 50, 60]`.
- The cohesive correction parses the stable resolved runner or `tsx` CLI path, derives its workspace root, and verifies both root `helixos` and API `@helixos/api` package identities. Blast-radius inventory covers workspace npm parents, supervised runners, orphan legacy watchers, unrelated application watchers, and current-launch ancestry; non-Windows launch paths and authorization boundaries are unaffected.
- Rerun checkpoint disposition: the sole blocker is fixed and documented; no non-blockers or additional inline findings existed. The complete affected-instance inventory is covered by the focused process table, the prior `includes("helixos")` detector was removed, all callers were inspected, and no materially similar path-branding instance remains unreviewed. The pull-request description now records the corrected identity boundary and evidence.
- Round 2 exposed the shared root cause: process command lines do not provide another process's working directory, so a relative or root-relative script path cannot be safely mapped to a workspace. The complete affected category includes relative and root-relative supervised-runner paths, relative and root-relative `tsx watch src/main.ts` paths, fully qualified neutral-worktree paths, workspace npm parents, unrelated watchers, and current-launch ancestry.
- The cohesive correction accepts only normalized, fully qualified drive or UNC paths before package-backed workspace verification. Ambiguous paths remain unclassified; a recognized npm workspace ancestor or a fully qualified `tsx` child still provides a safe cleanup root. The pull-request description and operator update now state this boundary.
- The corrected full-diff architecture review identified that the npm workspace-command classifier was still an independent authority. It now contributes only ancestry: a matching command is promoted to a cleanup root only when one of its descendants has already passed fully qualified path and package identity verification. A standalone lookalike workspace command remains unclassified.
- Architecture disposition after the corrected review: the runner has one cohesive Windows API watcher-lifecycle responsibility; deterministic selection and retry policy remain directly tested; process and filesystem I/O stay at the runner boundary; authorization and persisted state are not involved; no React state/effect concerns apply; the change adds bounded Windows-only inspection work and leaves macOS/Linux commands byte-for-byte unchanged. No additional actionable architecture, correctness, security, test-placement, or performance findings remain locally.

## Validation, review, and CI

- `node --check src/scripts/local-api-windows-runner.mjs` passed.
- `node --test src/scripts/api-dev-command.test.mjs` passed 8 of 8 tests, including process-root selection, current-launch ancestry exclusion, explicit-exit handling, bounded retry exhaustion, readiness/exit/timeout classification, and the real `tsx watch` burst-coalescing regression.
- `npm run test:scripts` passed 96 tests; 2 Unix-only `free-port.mjs` tests were skipped on Windows as designed.
- `npm run build -w @helixos/api` passed.
- A platform contract comparison against exact base `31c57385d9965607e22813b1619b343a37e7c54b` passed: root launch scripts were unchanged and every API workspace script except `dev:windows` matched the base exactly.
- Re-running `node --test src/scripts/api-dev-command.test.mjs` passed 8 of 8 tests in 6.108 seconds. `git diff --check origin/main...HEAD` also passed.
- Round 1 remediation: the neutral-worktree test first failed with the expected missing PIDs, then passed after the correction. `node --check` passed; focused watcher tests passed 8 of 8 in 3.690 seconds; `npm run test:scripts` passed 96 tests with 2 Unix-only skips in 5.220 seconds; working-diff validation passed.
- Round 2 remediation: the relative-runner regression first failed with unexpected PID `70`, then passed after fully qualified path enforcement. Coverage inventories relative and root-relative runner and `tsx` commands; focused watcher tests passed 8 of 8 in 3.625 seconds; the complete `npm run test:scripts` suite passed 96 tests with 2 Unix-only skips in 4.603 seconds; `node --check` and `git diff --check` passed.
- Corrected circuit-breaker review: the standalone npm-workspace regression first failed with unexpected PID `80`, then passed after workspace commands became verified-descendant ancestry only. Focused watcher tests passed 8 of 8 in 3.172 seconds; the complete `npm run test:scripts` suite passed 96 tests with 2 Unix-only skips in 4.332 seconds of reported test duration; `node --check`, `git diff --check`, exact-base root-package comparison, and the API script comparison passed. The API comparison showed only `dev:windows` changed; every macOS/Linux-relevant script remained identical.
- Live Windows verification launched the new command twice on port 4000. The first removed the prior PR #1117 API watcher and became healthy; the second removed the first supervised watcher tree and also returned HTTP 200 from `/api/health`.
- The PR #1117 API watcher was restored afterward. `/api/health` and tenant-scoped `/api/me` both returned HTTP 200, and the existing web/portal processes remained running.
- Draft PR #1150 was created at exact head `5e3d83a952195f2972b27b9914553e7aa93e8c92`. It has no reviewer requests. External review activity was not started.

## Outcome, risk, and follow-up

- Outcome: completed in Draft PR #1150.
- Resumed outcome: the active `C:\dev\HelixOS` workspace is now on `codex/windows-api-watcher-recovery` at exact PR head `5e3d83a952195f2972b27b9914553e7aa93e8c92`, clean and tracking its origin branch. The earlier implementation outcome remains unchanged.
- Platform-isolation review outcome: verified. PR #1150 does not modify the intentional macOS/Linux runtime launcher path; no PR correction is required.
- Private self-review outcome: blocked by the churn circuit breaker after two rounds found omissions in the same process-identity boundary. Every returned finding plus the corrected complete-diff architecture-review finding is fixed, validated, committed, and pushed at `170988b327be663b4a4778832b8423c3dcddf6a6`; explicit owner approval is required before another rerun.
- Residual risk: a watcher whose child application fails while the `tsx` parent remains alive is observationally the same as a silent startup stall and can consume the single retry before failing. The retry is bounded, output remains inherited, and deterministic explicit watcher exits are preserved.
- Draft CI is intentionally skipped by repository policy. The Windows-hosted regression will run when the owner later authorizes promotion from Draft.
- Hosted macOS/Linux execution was not run for this Draft PR. The isolation conclusion is based on exact-source comparison: the commands those platforms execute are unchanged, while the one changed runtime entry point is the explicitly Windows-only `dev:windows` command.
- Draft PR #1117 remains unchanged remotely with review paused. Its local dependency-injection fix commit `70ea332c073441a9567113bf30955b182c064ec1` remains unpushed.

## Evidence provenance

- Starting Git state was read directly from `origin/main` after `git fetch origin`.
- The prior failure observation comes from the immediately preceding PR #1117 local-stack startup in this same Codex task and is also recorded in `projects/helixos/engineering/tasks/20260813T033418Z-pr-1117-assigned-client-roles-phase2.md`.
- Commit, change-size, and branch evidence came from the dedicated worktree at `C:\dev\HelixOS-worktrees\windows-api-watcher-recovery`.
- Pull-request state, exact head, review requests, and check conclusions came from canonical GitHub PR #1150 data after creation.
- The resumed checkout was verified from canonical GitHub PR data, `origin/codex/windows-api-watcher-recovery`, and the active workspace's `git status` and `git rev-parse HEAD` output.
- The platform-isolation review used the exact merge base and current `origin/main` SHA `31c57385d9965607e22813b1619b343a37e7c54b`, exact PR head `5e3d83a952195f2972b27b9914553e7aa93e8c92`, the complete six-file diff, root/API package-script comparisons, workflow inspection, and focused test output.
