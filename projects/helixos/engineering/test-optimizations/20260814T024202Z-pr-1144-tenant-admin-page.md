# HelixOS PR #1144 — Speed up Tenant Administration web tests

## Outcome

- PR: https://github.com/helixosio/helixos/pull/1144
- State: merged
- Target: `src/web/src/features/tenant-admin/pages/TenantAdminPage.test.tsx`
- Completed: 2026-08-14T02:42:02Z
- Hosted baseline: run `31754118142`
- Benchmark head: `14cfc641ea32bfbcd703a5f6b90b5ccab0469e55`
- Final PR head: `c2f61d86a97c6fa5c30a3900c0be5f849cd2ba1a`
- Final base: `015345e51ac0bab75b89137cd846e8f0c54da9a8`
- Merge commit: `526bd35fc34f4074585aaf773ec43ddcea9b93eb`

The optimization reduced the hosted median target-file time by 14.7% and tests/hooks time by 18.7% while preserving all 18 rendered component tests and their behavior-sensitive interaction seams.

## Local measurements

| Measurement | Baseline samples | Baseline median | Current samples | Current median | Change |
| --- | --- | ---: | --- | ---: | ---: |
| Focused wall time | 31.23s, 31.37s | 31.30s | 24.60s, 26.28s | 25.44s | -18.7% |
| Tests/hooks | 24.40s, 24.49s | 24.45s | 17.24s, 19.80s | 18.52s | -24.2% |
| Passed/failed/skipped | 18/0/0, 18/0/0 | 18/0/0 | 18/0/0, 18/0/0 | 18/0/0 | preserved |

All focused samples used the same Vitest target with `TZ=UTC`.

## Hosted measurements

Run `31760707142` supplied all three samples on benchmark head `14cfc641ea32bfbcd703a5f6b90b5ccab0469e55`.

| Measurement | Attempt 1 | Attempt 2 | Attempt 3 | Median | Range | Baseline change |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| `web-unit` job | 10m 25s | 13m 49s | 12m 35s | 12m 35s | 10m 25s-13m 49s | n/a |
| Web command | 7m 37s | 10m 18s | 9m 11s | 9m 11s | 7m 37s-10m 18s | n/a |
| Vitest runner | 7m 27s | 10m 05s | 8m 58s | 8m 58s | 7m 27s-10m 05s | n/a |
| TenantAdminPage total | 19.3s | 26.5s | 22.9s | 22.9s | 19.3s-26.5s | -14.7% vs 26.8s |
| TenantAdminPage tests/hooks | 17.3s | 23.6s | 20.2s | 20.2s | 17.3s-23.6s | -18.7% vs 24.9s |
| Passed/failed/skipped | 18/0/0 | 18/0/0 | 18/0/0 | 18/0/0 | unchanged | preserved |

Attempt 1 used the initial full workflow. Attempt 2 was an unnecessary full-workflow rerun made before the cadence was corrected. Attempt 3 reran only the independent `web-unit` job. Later base-only merges changed none of the target test, its production component, test setup, package metadata, lockfile, or CI workflow, so these are retained as byte-identical predecessor-head statistics. Final-head run `31763811963` passed `backend-and-infra`, `web-unit`, and `web-e2e` on `c2f61d86a97c6fa5c30a3900c0be5f849cd2ba1a`.

## Optimization and retained coverage

The suite centralized user-event setup with `skipHover: true` for interactions that do not depend on implicit hover. Setup-only searches and identity inputs assign terminal controlled values directly instead of simulating every keystroke.

Retained behavior includes:

- explicit filter-rail hover and Escape handling;
- representative search typing and clearing;
- address autocomplete and invalid-email typing;
- phone and postal-code masking;
- navigation, authorization, mutation, invitation, and request-boundary assertions;
- all 18 tests with no skips, focus flags, deleted assertions, or timeout increases.

## Validation and review

- Focused post-change suite: 18 passed, zero failures or skips in both samples.
- Complete `@helixos/web` unit suite: 129 suite files passed.
- Web lint, production build, theme check, and `git diff --check` passed.
- Private exact-head self-review completed clean.
- Public review completed clean with no findings or unresolved threads; `walkeryan` approved.
- Final-head required CI passed. The owner merged the PR before a separate `jfollas` approval was requested.

## Risk and follow-up

Risk was limited to interaction fidelity. Behavior-sensitive hover, keyboard, mask, autocomplete, navigation, mutation, and request seams remain realistic. Reverting the optimization commit restores the prior arrangement.

For the next optimization, select the highest untreated target from the latest successful merged-main timing artifact after excluding files touched by active pull requests. Use three hosted samples, rerunning only `web-unit` after the initial full CI run.
