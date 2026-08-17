# HelixOS — Create the next web-test optimization PR

## Outcome

- Status: in-progress
- Repository: https://github.com/helixosio/helixos
- Objective: Select, implement, benchmark, validate, and deliver the next untreated, non-overlapping HelixOS web-test runtime optimization as a Draft pull request, then complete the prescribed review, exact-head CI, and hosted timing workflow.
- Started: 2026-08-17T04:37:11Z
- Initial fetched base SHA: `f76377cb8fa7c26ca2803799ec2f96fcf9ea0c80`
- Initial local branch: `main`
- Initial local head: `e81c2706ca31c91c1e19a3adbede9d08c8d56e9f`
- Initial worktree state: clean; local `main` was 733 commits behind `origin/main`, so implementation will use a dedicated branch/worktree from the fetched base.
- Pull request: pending
- Task/thread ID: unavailable in the current execution context

## Scope and evidence

- In scope: one cohesive web-test hotspot, matched local baseline/post-change samples, unchanged behavioral coverage, full required local validation, Draft PR creation, private self-review, repository-prescribed feedback/final review, exact-head CI, and three hosted timing samples.
- Explicit exclusions: reducing or skipping tests, loosening assertions, increasing timeouts, changing production behavior, overlapping active pull-request work, merging, releasing, or publishing.
- Selection evidence, active-PR overlap inventory, hosted baseline, responsibility boundary, measurements, validation, review findings, CI attempts, and hosted samples: pending.

## Target selection

- Hosted evidence reviewed: the 30 latest successful merged-main `HelixOS CI` timing artifacts were downloaded; target ranking used the latest 20 complete `web-unit-files.json` reports.
- Selected target: `src/web/src/features/client-portal-access/ClientPortalAccessPanel.test.tsx`.
- Latest-20 target median: 24.292s total (15.375-27.184s) and 21.531s tests/hooks (13.695-24.185s), with 19 passed, 0 failed, and 0 skipped in the latest sample.
- Hosted baseline: main run `31985160819`, attempt 1, `web-unit` job `95258775914`, artifact `9273751045`, head `f76377cb8fa7c26ca2803799ec2f96fcf9ea0c80`. Target time was 24.501s total, 21.807s tests/hooks, and 1.651s collection; 19/0/0. The web command took 679.231s and the Vitest runner took 665.209s.
- Higher untreated `AdminConsolePage.test.tsx` was excluded because active PR #1186 changes its directly imported `admin-workflow-model.ts` authorization dependency. Higher-ranked Plan Detail, Client Editor, Payroll Provider Management, Desktop Workspace, Operations Dashboard, Payroll Batches, Tenant Administration, and Zorka Studio suites already have optimization records; active PRs #1185, #1057, and #689 also overlap the two client-editor targets.
- Open-PR inventory: #1186, #1185, #1139, #1057, and #689. None changes the selected test, `ClientPortalAccessPanel.tsx`, `AddPortalUserDialog.tsx`, `ManageClientAccessDialog.tsx`, or their direct client-portal-access model boundaries. Prior optimization PR #1180 is merged and is no longer active.
- Preliminary interaction inventory: 19 tests, 18 `userEvent` setup instances, 53 clicks, 12 typed-input interactions, 16 waits, and no explicit hover or keyboard interaction. Behavior-sensitive seams include client-side filtering, status query parameters, email/identity/client autocomplete input, invitation/link/grant mutations, dialog confirmations, pagination, readiness states, and exact refusal copy.

## Risk and follow-up

- Initial risk: target selection must account for active PR #1180 and any newer active changes before editing.
- Rollback and next candidate: pending implementation evidence.
