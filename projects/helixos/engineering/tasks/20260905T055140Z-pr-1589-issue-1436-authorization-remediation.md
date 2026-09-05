# HelixOS Work - Issue 1436 authorization remediation

## Identity

- Status: Merged and cleaned up
- Repository: `helixosio/helixos`
- Completed: 2026-09-05T05:46:06Z
- Branch: `codex/issue-1436-remediation`
- Final head SHA: `40ff65cbecd03fa942c0377c9705730cf27c84e6`
- Issue: #1436
- PR: #1589

## Objective and outcome

Audited all Issue 1436 changes for authorization, tenant isolation, indirect-resource access, lifecycle evidence ownership, and repository-instruction violations. PR #1589 merged the resulting remediation with approval and clean exact-head CI.

## Delivered changes and decisions

- Enforced tenant and client ownership for indirect identifiers, replay identities, search, counts, exports, hierarchy data, background work, and authorization decisions.
- Preserved existing education restrictions through a governed permission-template successor without broadening grants.
- Made lifecycle evidence authoritative for new workflow projections, fenced evidence restoration, bounded untrusted audit data, and corrected audit/persistence ordering and concurrency controls.
- Removed retired-route dependencies while retaining the explicitly approved employee delete, restore, and new-hire compatibility actions until governed replacements are approved.
- Corrected final review findings so ordinary employee updates cannot rewrite canonical hire or termination projections or report false lifecycle audit transitions.
- Removed the dedicated Git worktree and local branch. GitHub had already removed the remote branch.

## Validation, review, and CI

The complete local hermetic validation was run before review across affected packages and workspaces. Review corrections used focused owning-layer validation; the final correction passed API test compilation and all 64 employee service tests. The exact final head received an approving GitHub review with no unresolved threads. Required CI completed successfully for backend and infrastructure, web unit, and web end-to-end jobs; intentionally inapplicable benchmark and cross-browser jobs were skipped.

## Risk and follow-up

The retained legacy employee delete, restore, and new-hire actions still write lifecycle status outside the governed evidence workflow and require a separately approved replacement. Two unmeasured Operations roster performance proposals remain recorded for evidence-based follow-up. Ignored dependency artifacts were retained locally outside the removed Git worktree because automatic filesystem approval rejected deletion; they contain no repository work.