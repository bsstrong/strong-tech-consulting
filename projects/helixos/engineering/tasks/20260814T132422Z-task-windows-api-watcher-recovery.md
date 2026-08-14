# HelixOS Task — Windows API Watcher Startup Recovery

## Identity

- Status: in-progress
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

## Task statistics

| Statistic | Value | Evidence |
| --- | --- | --- |
| Total elapsed | 32 minutes 44 seconds wall-clock; 19 minutes 15 seconds across the two task intervals | `2026-08-14T13:24:22Z` through `2026-08-14T13:57:06Z`, including a 13 minute 29 second completed-state gap before the discussion checkout resumed |
| Commits | 1 | `5e3d83a9 fix(dev): recover stalled Windows API watcher` |
| Change size | 484 insertions, 3 deletions across 6 files | `git show --numstat` and commit summary |
| Validation | 8 focused watcher tests passed; 96 full script tests passed and 2 Unix-only tests skipped on Windows; API build passed; 4 live HTTP assertions passed across replacement/restoration checks | Local command output and Windows process/HTTP inspection |
| Review | 1 local architecture self-review, 0 actionable findings | Complete diff and surrounding launcher/test/runbook inspection |
| CI | 2 exact-head jobs skipped because PR #1150 is Draft | GitHub `statusCheckRollup` for head `5e3d83a952195f2972b27b9914553e7aa93e8c92` |
| Benchmarks | Existing failure exceeded 80 seconds without binding; healthy supervised launches bound within the 45-second smoke windows | Prior process observation plus two consecutive live launcher runs |

## Work and decisions

- Prior observed failure evidence: during a clean `npm run dev:windows` launch, the API `cross-env`/`tsx watch` process tree remained alive for more than 80 seconds without listening on port 4000 or logging an error. Web, portal, workflow, and Rule Engine startup continued. Stopping only the API subtree and relaunching the same API workspace command bound port 4000 within seconds.
- Repository history showed that the prior July fix addressed restart storms from Node's native watcher by moving to `tsx watch`; it did not supervise initial readiness or clean stale Windows watcher trees.
- The selected boundary is a Windows-only local API runner. It owns process discovery/cleanup, initial `/api/health` readiness, one bounded restart, signal forwarding, and exact watcher-tree termination. `tsx watch` continues to own normal source-change restarts.
- The preflight excludes the new launch's own ancestry, targets only recognized Helix API workspace/runner/legacy watcher commands, and refuses to terminate an unrecognized owner of the configured API port.
- A watcher that exits explicitly is not retried. Only a watcher that remains alive but unready for 30 seconds is stopped and retried once; a second timeout exits clearly.

## Validation, review, and CI

- `node --check src/scripts/local-api-windows-runner.mjs` passed.
- `node --test src/scripts/api-dev-command.test.mjs` passed 8 of 8 tests, including process-root selection, current-launch ancestry exclusion, explicit-exit handling, bounded retry exhaustion, readiness/exit/timeout classification, and the real `tsx watch` burst-coalescing regression.
- `npm run test:scripts` passed 96 tests; 2 Unix-only `free-port.mjs` tests were skipped on Windows as designed.
- `npm run build -w @helixos/api` passed.
- Live Windows verification launched the new command twice on port 4000. The first removed the prior PR #1117 API watcher and became healthy; the second removed the first supervised watcher tree and also returned HTTP 200 from `/api/health`.
- The PR #1117 API watcher was restored afterward. `/api/health` and tenant-scoped `/api/me` both returned HTTP 200, and the existing web/portal processes remained running.
- Draft PR #1150 was created at exact head `5e3d83a952195f2972b27b9914553e7aa93e8c92`. It has no reviewer requests. External review activity was not started.

## Outcome, risk, and follow-up

- Outcome: completed in Draft PR #1150.
- Resumed outcome: the active `C:\dev\HelixOS` workspace is now on `codex/windows-api-watcher-recovery` at exact PR head `5e3d83a952195f2972b27b9914553e7aa93e8c92`, clean and tracking its origin branch. The earlier implementation outcome remains unchanged.
- Platform-isolation review outcome: pending.
- Residual risk: a watcher whose child application fails while the `tsx` parent remains alive is observationally the same as a silent startup stall and can consume the single retry before failing. The retry is bounded, output remains inherited, and deterministic explicit watcher exits are preserved.
- Draft CI is intentionally skipped by repository policy. The Windows-hosted regression will run when the owner later authorizes promotion from Draft.
- Draft PR #1117 remains unchanged remotely with review paused. Its local dependency-injection fix commit `70ea332c073441a9567113bf30955b182c064ec1` remains unpushed.

## Evidence provenance

- Starting Git state was read directly from `origin/main` after `git fetch origin`.
- The prior failure observation comes from the immediately preceding PR #1117 local-stack startup in this same Codex task and is also recorded in `projects/helixos/engineering/tasks/20260813T033418Z-pr-1117-assigned-client-roles-phase2.md`.
- Commit, change-size, and branch evidence came from the dedicated worktree at `C:\dev\HelixOS-worktrees\windows-api-watcher-recovery`.
- Pull-request state, exact head, review requests, and check conclusions came from canonical GitHub PR #1150 data after creation.
- The resumed checkout was verified from canonical GitHub PR data, `origin/codex/windows-api-watcher-recovery`, and the active workspace's `git status` and `git rev-parse HEAD` output.
