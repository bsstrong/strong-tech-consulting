# HelixOS Work - PR Review Cycle Policy

## Identity

- Status: Complete
- Repository: Global agent instructions
- Completed: 2026-08-31T03:25:45Z
- Task/thread ID: Unavailable in current session
- Branch: N/A
- Final head SHA: `N/A`
- Issue: N/A
- PR: N/A

## Objective and outcome

Replace the HelixOS and Zorka owner-authored pull-request lifecycle with the owner's Ready-first Slack `#pr-reviews` cycle. The canonical global instructions now require concurrent review and CI work, repeated review monitoring and correction cycles, and terminal approval only when the exact current head has both review approval and clean required CI.

## Delivered changes and decisions

- New pull requests open directly in Ready state after implementation, local validation, architecture self-review, and the exact-tree checkpoint are complete.
- Initial review requests use `Review <PR URL>` in `#pr-reviews`; re-reviews use the standalone `rerun` reply in the existing thread.
- Review feedback is checked after three minutes and every 30 seconds thereafter until terminal feedback returns.
- CI runs concurrently and never delays an initial request, rerun, monitoring, analysis, or bounded fixes. Final approval requires clean required CI and review approval on the same head.
- Requested changes enter finding disposition and circuit-breaker assessment, followed by fixes, validation, comment responses, thread resolution, rerun, and repeated monitoring until approval.
- The circuit breaker is explicitly a complete scope and root-cause audit, not an owner-approval gate. Standing review-resolution authority includes necessary in-scope authorization, security, tenant-isolation, and cross-bounded-context fixes.
- Approval stops the cycle pending owner merge; agents remain unauthorized to merge.
- The `run-pr-review-loop` skill and its UI metadata were rewritten to match the Ready-first Slack cycle and remove the obsolete Draft, `jfollas`, one-minute-monitoring, rerun-limit, and risky-change approval behavior.

## Validation, review, and CI

- Searched the complete canonical global instruction file for superseded Draft, optional Slack, GitHub reviewer, and older formal-review references; no conflicting HelixOS/Zorka lifecycle text remains.
- Verified the canonical instruction file and the Codex and Claude global entrypoints remain hard links with identical SHA-256 content.
- Verified the revised skill frontmatter, name, description, TODO state, UI metadata, and removal of stale lifecycle terms. The bundled validator could not run because PyYAML is absent from both available Python runtimes; equivalent checks passed manually.
- Repository CI and PR review are not applicable to this external instruction update.

## Risk and follow-up

No known residual policy conflict remains in the canonical global instructions or PR-loop skill. Owner follow-up is to provide the next pull request or implementation objective to run under the revised cycle.
