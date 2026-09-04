# HelixOS Work - CI Runner Cost Analysis

## Identity

- Status: Completed
- Repository: Governed HelixOS source repository
- Completed: 2026-09-04T06:07:57Z
- Task/thread ID: Unavailable at the cross-repository confidentiality boundary
- Branch: Dedicated documentation branch
- Final head SHA: Withheld at the cross-repository confidentiality boundary; delivery integrity reference `sha256:4da48bb624bbae6a440a9b5dc4773ce7527596f5e1480dbdacb67efefee8897f`
- Issue: N/A
- PR: N/A

## Objective and outcome

Produced and committed a shareable cost analysis comparing the current GitHub-hosted CI baseline, GitHub larger-runner tiers, and Azure self-hosted ephemeral and always-on alternatives. The analysis states today's published-equivalent cost, projected cost and performance for each option, monthly-volume comparisons, break-even points, caveats, and a recommended pilot.

## Delivered changes and decisions

- Added a dated operations document grounded in the latest 50 successful pull-request workflow runs and current official GitHub and Azure retail rates.
- Distinguished wall-clock duration from summed billable runner time and included-minute effects.
- Compared 2-, 4-, 8-, and 16-core GitHub and Azure options, including scale-to-zero, always-on, savings-plan, and Spot scenarios.
- Recommended a zero-to-three-instance ephemeral Azure 8-core pilot instead of one permanent shared runner.
- Created one isolated documentation commit; it was not pushed or published.

## Validation, review, and CI

- Verified the committed diff contains only the new operations document.
- `git diff --check` passed.
- Recalculated the runner-rate, per-workflow, monthly-volume, startup-overhead, and break-even figures against the cited source rates.
- Completed a consistency and confidentiality review; no production code, workflow, infrastructure, or runtime behavior changed.
- CI was not run because the delivered artifact is Markdown-only.

## Risk and follow-up

Projected larger-runner durations remain planning estimates until measured on candidate hardware. Actual GitHub invoice cost depends on organization-wide included-minute consumption, which was unavailable from repository-level access. Before adopting self-hosted capacity, run exact-head samples on the current GitHub runner, GitHub 8-core, Azure 8-core, and Azure 16-core candidates and include boot latency, retries, isolation, operations labor, and shared-network charges in the final decision.
