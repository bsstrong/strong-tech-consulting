# HelixOS Task — Expand lifecycle tracking to every HelixOS and Zorka task

## Identity

- Status: completed
- Repository context: `helixosio/helixos` and `zorkacom/zorka`
- Task started: 2026-08-14T03:42:03Z
- Task/thread ID: Unavailable from the current Codex task context
- Starting workspace: `C:\dev\HelixOS`
- Starting branch: `main`
- Starting base SHA: `526bd35fc34f4074585aaf773ec43ddcea9b93eb` (`origin/main`)
- Starting head SHA: `e81c2706ca31c91c1e19a3adbede9d08c8d56e9f`
- Issue: N/A
- PR: N/A

## Objective and scope

Expand the optimization statistics practice into durable lifecycle tracking for every root task started in a HelixOS or Zorka workspace, including implementation, debugging, review, analysis, planning, CI, PR operations, settings work, and read-only investigations.

Exclusions and owner decisions:

- Track one root objective across messages, corrections, heartbeats, automations, and new-chat continuations; do not create records for individual operations or routine checks.
- Preserve specialized HelixOS optimization records as the richer task record instead of creating duplicates.
- Store records in the project-specific areas of `strong-tech-consulting` and push them directly to `main`.

## Lifecycle

| Milestone | Timestamp | Duration or evidence |
| --- | --- | --- |
| Task started | 2026-08-14T03:42:03Z | Captured during the active request |
| Start record pushed | 2026-08-14T03:45:55Z | 3m52s after task start; commit `2f1d6451a5219c5591c7ddada2a5cb559cdd7a64` |
| Tracking policy implementation | 2026-08-14T03:46:49Z | 4m46s after task start |
| Validation | 2026-08-14T03:46:49Z | Both affected skills passed `quick_validate.py` |
| Completed | 2026-08-14T03:46:59Z | 4m56s total elapsed |

## Task statistics

| Statistic | Value | Evidence |
| --- | --- | --- |
| Total elapsed | 4m56s | 2026-08-14T03:42:03Z through 2026-08-14T03:46:59Z |
| Consulting-repository commits | 2 | Start record plus this final record update |
| Workflow change size | 5 workflow/config files plus 1 lifecycle record | New skill, template, generated skill metadata, optimization-skill integration, canonical global policy, and this note |
| Skill validation | 2 passed, 0 failed | `quick_validate.py` for `track-helixos-zorka-task` and `run-helixos-test-optimization` |
| Review | N/A | No pull request or external review was required for personal workflow configuration |
| CI | N/A | No HelixOS or Zorka source tree changed |
| Benchmarks | N/A | This was a workflow-policy task, not a performance change |

## Work and decisions

- Created a general `track-helixos-zorka-task` personal skill with a reusable record template.
- Updated the canonical vendor-neutral global instructions so tracking applies across agents, not only Codex sessions that happen to select the skill.
- Updated `run-helixos-test-optimization` so its statistics note fulfills the general tracking requirement without generating a duplicate general note.
- Defined material-milestone updates to avoid per-poll, per-heartbeat, and per-tool-call noise.
- Defined evidence-backed statistics for elapsed and phase timing, commits and change size, validation, reviews, CI, artifacts, and performance samples.

## Validation, review, and CI

- `track-helixos-zorka-task`: passed `quick_validate.py`.
- `run-helixos-test-optimization`: passed `quick_validate.py` after integration.
- Generated `agents/openai.yaml` and verified that the new skill contained no scaffold TODOs.
- Repository CI: N/A; this task changes personal workflow instructions and records, not HelixOS or Zorka source.

## Outcome, risk, and follow-up

Every future root task started in a HelixOS or Zorka workspace, or targeting either repository, now requires one durable record created at task start, updated at material milestones, and finalized at the terminal outcome. Records are searchable by sortable UTC filename and PR/issue/task identity. Specialized optimization notes remain authoritative for optimization tasks.

Residual risk: enforcement by non-Codex agents depends on their loading the canonical global instructions. The policy is stored there specifically to make the behavior vendor-neutral.

Follow-up: create the Zorka task directory on the first Zorka task; Git does not retain empty directories.

## Evidence provenance

- Start time was captured from the workstation clock during the active task.
- Workspace branch and SHAs were read from local Git state at task start.
- Task/thread ID is not exposed in the available task context and is recorded as unavailable rather than inferred.
- Completion and validation timestamps came from the workstation UTC clock; Git supplied the start-record commit time and SHA.
- HelixOS source remained unchanged at local `e81c2706ca31c91c1e19a3adbede9d08c8d56e9f`; its tracked `origin/main` at task start was `526bd35fc34f4074585aaf773ec43ddcea9b93eb`.
