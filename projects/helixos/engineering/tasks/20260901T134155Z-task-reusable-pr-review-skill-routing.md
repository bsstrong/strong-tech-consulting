# HelixOS Work - Require the reusable PR-review skill

## Identity

- Status: Completed
- Repository: Shared agent instructions
- Completed: 2026-09-01T13:41:55Z
- Task/thread ID: Unavailable
- Branch: N/A
- Final head SHA: N/A
- Issue: N/A
- PR: N/A

## Objective and outcome

Ensure the new reusable HelixOS/Zorka pull-request workflow is selected automatically for applicable work instead of depending on memory or explicit owner invocation. The canonical shared global instructions now require the skill for actionable owner-authored PR lifecycle work while excluding read-only assessments.

## Delivered changes and decisions

- Added a `Reusable workflow skills` section to the canonical shared global instruction file.
- Required Codex to load and use `manage-helixos-zorka-pr-review` when creating, advancing, synchronizing, repairing conflicts in, addressing feedback on, requesting or monitoring review for, or finishing an owner-authored HelixOS or Zorka pull request.
- Preserved global and repository policy as canonical authority and defined direct-policy fallback when a required skill is unavailable.
- Retained the terminal-only trigger for `track-helixos-zorka-task`.

## Validation, review, and CI

- Verified the canonical global file remains hard-linked to the Codex and Claude global entrypoints.
- Verified both agent entrypoints expose the new mandatory skill-routing rule.
- The reusable skill passed its official structure validator; its PowerShell Slack helper passed syntax validation and its live safe dry run correctly rejected a merged pull request.

## Risk and follow-up

Agents without reusable-skill support will continue to execute the canonical PR policy directly. No owner follow-up is required.
