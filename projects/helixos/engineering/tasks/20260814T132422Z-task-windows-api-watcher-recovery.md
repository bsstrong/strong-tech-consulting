# HelixOS Task — Windows API Watcher Startup Recovery

## Identity

- Status: in-progress
- Repository: `helixosio/helixos`
- Task started: `2026-08-14T13:24:22Z`
- Task/thread ID: current Codex task; durable ID unavailable
- Starting branch: `origin/main` (new dedicated branch pending)
- Starting base SHA: `31c57385d9965607e22813b1619b343a37e7c54b`
- Starting head SHA: `31c57385d9965607e22813b1619b343a37e7c54b`
- Issue: N/A
- PR: pending

## Objective and scope

Diagnose and fix the recurring Windows local-development failure in which the initial Helix API `tsx watch` process remains alive but never binds port 4000, requiring a manual API-watcher restart. Deliver the fix in a separate Draft pull request.

Exclusions and owner decisions:

- Preserve Draft PR #1117, its paused review state, and its unpushed local dependency-injection fix unchanged.
- Keep the currently running PR #1117 development stack available while developing and testing this isolated startup fix where practical.
- Do not broaden this task into unrelated local-development or application behavior changes.

## Lifecycle

| Milestone | Timestamp | Duration or evidence |
| --- | --- | --- |
| Task started | `2026-08-14T13:24:22Z` | — |
| Implementation/handoff | pending | pending |
| PR created | pending | pending |
| Review | pending | pending |
| CI | pending | pending |
| Completed | pending | pending |

## Task statistics

| Statistic | Value | Evidence |
| --- | --- | --- |
| Total elapsed | pending | UTC lifecycle timestamps |
| Commits | pending | Git history on the dedicated branch |
| Change size | pending | merge-base diff statistics |
| Validation | pending | command output captured during implementation |
| Review | pending | local architecture self-review and any authorized Draft review evidence |
| CI | pending | exact-head GitHub checks after Draft PR creation |
| Benchmarks | N/A unless diagnosis requires timing comparison | startup-readiness observations |

## Work and decisions

- Prior observed failure evidence: during a clean `npm run dev:windows` launch, the API `cross-env`/`tsx watch` process tree remained alive for more than 80 seconds without listening on port 4000 or logging an error. Web, portal, workflow, and Rule Engine startup continued. Stopping only the API subtree and relaunching the same API workspace command bound port 4000 within seconds.
- Root cause, implementation boundary, and recovery policy are pending repository inspection and focused reproduction.

## Validation, review, and CI

- Pending.

## Outcome, risk, and follow-up

- Outcome: in progress.
- Primary risk: a supervisor that masks real compile/startup failures or leaves orphaned Windows processes. The design must distinguish a live-but-unready stall from an explicit child-process failure and must terminate only the exact managed process tree.
- Follow-up: pending.

## Evidence provenance

- Starting Git state was read directly from `origin/main` after `git fetch origin`.
- The prior failure observation comes from the immediately preceding PR #1117 local-stack startup in this same Codex task and is also recorded in `projects/helixos/engineering/tasks/20260813T033418Z-pr-1117-assigned-client-roles-phase2.md`.
