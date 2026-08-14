# HelixOS Task — Windows API Watcher Startup Recovery

## Identity

- Status: complete
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

## Task statistics

| Statistic | Value | Evidence |
| --- | --- | --- |
| Total elapsed | 36 minutes 57 seconds wall-clock; 22 minutes 13 seconds across three task intervals | `2026-08-14T13:24:22Z` through `2026-08-14T14:01:18Z`, including 14 minutes 44 seconds across two completed-state gaps |
| Commits | 1 | `5e3d83a9 fix(dev): recover stalled Windows API watcher` |
| Change size | 484 insertions, 3 deletions across 6 files | `git show --numstat` and commit summary |
| Validation | Platform contract check passed; 8 focused watcher tests passed in 6.108 seconds; prior 96 full script tests passed with 2 Unix-only tests skipped on Windows; API build passed; 4 live HTTP assertions passed | Exact-base comparison, local command output, and Windows process/HTTP inspection |
| Review | 2 local reviews, 0 actionable findings | Complete architecture review plus exact-base macOS/Linux platform-isolation review |
| CI | 2 exact-head jobs skipped because PR #1150 is Draft | GitHub `statusCheckRollup` for head `5e3d83a952195f2972b27b9914553e7aa93e8c92` |
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

## Validation, review, and CI

- `node --check src/scripts/local-api-windows-runner.mjs` passed.
- `node --test src/scripts/api-dev-command.test.mjs` passed 8 of 8 tests, including process-root selection, current-launch ancestry exclusion, explicit-exit handling, bounded retry exhaustion, readiness/exit/timeout classification, and the real `tsx watch` burst-coalescing regression.
- `npm run test:scripts` passed 96 tests; 2 Unix-only `free-port.mjs` tests were skipped on Windows as designed.
- `npm run build -w @helixos/api` passed.
- A platform contract comparison against exact base `31c57385d9965607e22813b1619b343a37e7c54b` passed: root launch scripts were unchanged and every API workspace script except `dev:windows` matched the base exactly.
- Re-running `node --test src/scripts/api-dev-command.test.mjs` passed 8 of 8 tests in 6.108 seconds. `git diff --check origin/main...HEAD` also passed.
- Live Windows verification launched the new command twice on port 4000. The first removed the prior PR #1117 API watcher and became healthy; the second removed the first supervised watcher tree and also returned HTTP 200 from `/api/health`.
- The PR #1117 API watcher was restored afterward. `/api/health` and tenant-scoped `/api/me` both returned HTTP 200, and the existing web/portal processes remained running.
- Draft PR #1150 was created at exact head `5e3d83a952195f2972b27b9914553e7aa93e8c92`. It has no reviewer requests. External review activity was not started.

## Outcome, risk, and follow-up

- Outcome: completed in Draft PR #1150.
- Resumed outcome: the active `C:\dev\HelixOS` workspace is now on `codex/windows-api-watcher-recovery` at exact PR head `5e3d83a952195f2972b27b9914553e7aa93e8c92`, clean and tracking its origin branch. The earlier implementation outcome remains unchanged.
- Platform-isolation review outcome: verified. PR #1150 does not modify the intentional macOS/Linux runtime launcher path; no PR correction is required.
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
