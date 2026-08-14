# HelixOS PR #1148 — Speed up client creation dialog web tests

## Outcome

- PR: https://github.com/helixosio/helixos/pull/1148
- State: Merged after the owner completed the merge; exact-head required CI and approval were green before merge
- Target: `src/web/src/features/client-directory/ClientCreateDialog.test.tsx`
- Work started: 2026-08-14T06:27:20.275Z
- PR created: 2026-08-14T06:41:26Z
- Active workflow completed: 2026-08-14T08:12:30Z (`jfollas` exact-head approval made the PR ready to merge)
- PR merge time: 2026-08-14T12:59:46Z (owner action after the active workflow completed)
- Adjusted PR open-to-merge: 1h 31m 04s from PR creation through the ready-to-merge approval gate
- Recorded implementation/handoff: 13m 13s, through 2026-08-14T06:40:32.822Z
- Adjusted work-start-to-merge: 1h 45m 09.725s from task start through the ready-to-merge approval gate
- Excluded owner sleep/merge wait: 4h 47m 16s from approval through owner merge; this interval is not counted in duration statistics
- Baseline run: `31772393863`, attempt 1, `web-unit` job `94680825469`, artifact `9208798305`
- Base SHA: `588b156ddeea6cf5926c266f41fbab72ee3de258`
- Head SHA: `14e4f2b2469386aafb29556ddd514bee5025195c`
- Merge SHA: `31c57385d9965607e22813b1619b343a37e7c54b`
- Branch: `codex/optimize-next-web-test-20260814`
- Change size: 2 files, 44 additions, 13 deletions, 1 implementation commit
- Implementation commit: `14e4f2b2469386aafb29556ddd514bee5025195c`
- Codex task/thread ID: unavailable in the current tool context

Centralized click-oriented user-event setup and replaced only setup-only save-field typing, reducing hosted median target tests/hooks time by 27.7% while preserving all 13 tests and every behavior-sensitive interaction seam.

## Selection and scope

- The nominally slower Plan Detail, Client Editor, Payroll Provider Management, Operations Dashboard, and Payroll Batches suites already had completed optimization slices.
- Desktop Workspace overlapped active PR #1112. Admin Console exercised Tenant Administration and the shared API-client surface changed by active PR #1117.
- No active PR changed this target, `ClientCreateDialog.tsx`, its client-create model, address field, validation, placement autocomplete, editor-form layout, or the mocked `/api/payroll-providers` request contract.
- Scope was limited to test-harness interaction cost and CI timing documentation. Production behavior, state ownership, authorization, transport, persistence, workflows, dependencies, and test infrastructure were unchanged.

## Local measurements

All samples used `TZ=UTC npm run test -w @helixos/web -- ClientCreateDialog.test.tsx` and passed 13/13 with 0 failures and 0 skips.

| Measurement | Baseline samples | Baseline median | Current samples | Current median | Change |
| --- | --- | ---: | --- | ---: | ---: |
| Focused wall time | 27.590s, 30.471s | 29.031s | 20.798s, 21.750s | 21.274s | -26.7% |
| Vitest file total | 25.590s, 28.350s | 26.970s | 19.330s, 19.910s | 19.620s | -27.2% |
| Tests/hooks | 20.840s, 23.690s | 22.265s | 15.100s, 15.410s | 15.255s | -31.5% |

## Hosted measurements

| Sample | Run / attempt / job / artifact | Runner | Job | Web command | Vitest runner | Target total | Tests/hooks | Passed / failed / skipped |
| --- | --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Baseline | 31772393863 / 1 / 94680825469 / 9208798305 | GitHub Actions 1000018353 | 685s | 503.102s | 492.000s | 25.118s | 22.719s | 13 / 0 / 0 |
| Current 1 | 31778352981 / 1 / 94698495859 / 9211009515 | GitHub Actions 1000018365 | 777s | 581.995s | 568.845s | 19.473s | 16.621s | 13 / 0 / 0 |
| Current 2 | 31778352981 / 2 / 94702050174 / 9211438803 | GitHub Actions 1000018367 | 763s | 568.252s | 555.891s | 19.345s | 16.429s | 13 / 0 / 0 |
| Current 3 | 31778352981 / 3 / 94705568209 / 9211879814 | GitHub Actions 1000018368 | 792s | 577.182s | 563.997s | 19.246s | 16.340s | 13 / 0 / 0 |
| Current median | — | — | 777s | 577.182s | 563.997s | 19.345s | 16.429s | 13 / 0 / 0 |
| Current range | — | — | 763–792s | 568.252–581.995s | 555.891–568.845s | 19.246–19.473s | 16.340–16.621s | unchanged |

- Hosted target-total median change: -23.0% from 25.118s to 19.345s.
- Hosted tests/hooks median change: -27.7% from 22.719s to 16.429s.
- Every current sample belongs to final exact head `14e4f2b2469386aafb29556ddd514bee5025195c`; sample 1 was the full required CI run and samples 2 and 3 reran only the completed `web-unit` job.
- Local artifact copies: `C:\Users\bsstr\AppData\Local\Temp\helixos-pr-1148\attempt-1`, `attempt-2`, and `attempt-3`. Durable GitHub artifact IDs are recorded in the table.
- The full web-unit command and job were slower than the single baseline run. The performance claim is therefore scoped to the tightly grouped target-file improvement; the change cannot shift work into another phase because it modifies no workflow, setup, build, production, dependency, or unrelated test code.
- The skill-referenced `scripts/summarize_web_unit_samples.py` was absent from the repository and all fetched refs. Aggregate statistics were calculated directly from the three artifact JSON payloads using the prescribed median, range, and baseline-delta definitions; no repository file was added for this tooling gap.

## Optimization and retained coverage

The implementation introduced one `setupUser()` owner using `userEvent.setup({ skipHover: true })` for click-oriented scenarios with no hover contract. It changed only terminal setup values in save-payload tests to `fireEvent.change`. The dedicated masking scenario continues to type character by character.

Retained behavior:

- EIN and phone masking, city character filtering, and ZIP+4 formatting still use realistic sequential typing.
- Country selection, the out-of-country switch, parent-placement clearing, and submit actions still use `userEvent`.
- Async payroll-provider loading, validation, parent-rerender preservation, address provenance, payload normalization, and save request boundaries remain rendered React Query/MUI/request tests.
- All 13 tests, assertions, fixtures, variants, and timeouts remain intact; there are no `.skip` or `.only` cases.
- Production code is unchanged.

## Validation and architecture review

- Focused final suite: 13 passed, 0 failed, 0 skipped.
- Complete 129-file `@helixos/web` unit suite: passed in 207.7s; only pre-existing MSW/React-test warnings.
- Web lint: passed in 19.126s.
- Production web build: passed in 71.437s; only existing Rollup annotation and chunk-size warnings.
- Theme check: passed in 0.679s.
- `git diff --check`: passed.
- Full-diff architecture review: no production, state, effect, authorization, tenant, transport, mutation, cache, persistence, or presentation responsibility changed; no duplicated policy, shadow state, effect choreography, UI-only enforcement, or hidden behavior change was introduced.

## Review and lifecycle evidence

| Milestone | Time / duration | Result |
| --- | --- | --- |
| Implementation and local handoff | 2026-08-14T06:40:32.822Z / 13m 13s from start | Cohesive commit pushed; all local gates passed |
| Draft PR created | 2026-08-14T06:41:26Z | PR #1148 opened against exact base |
| Private self-review | Requested 06:45:30.803Z; clean 06:47:49.189Z / 2m 18s | 0 blockers, 0 non-blockers, no inline findings |
| Draft production feedback | Requested 06:56:40.440Z; clean 06:57:07Z / 26.560s | GitHub review 4934728980 on exact head; 0 actionable findings and no threads |
| Ready transition | 2026-08-14T07:01:24Z / 19m 58s after PR creation | Canonical reread confirmed Ready and unchanged head |
| Exact-head full CI | 07:01:26Z–07:15:58Z / 14m 32s | Required checks passed; expected path-gated cross-browser check skipped |
| Hosted samples | 07:01:29Z–07:51:14Z | Three exact-head artifacts collected; attempts 2 and 3 reran only web-unit |
| Final review | Requested 07:57:04Z; approved 08:12:30Z / 15m 26s | `jfollas` approval on exact head; no actionable findings or threads |
| Owner merge | 2026-08-14T12:59:46Z | Merge commit `31c57385d9965607e22813b1619b343a37e7c54b`; post-approval owner wait excluded from duration statistics |

- Review rounds: 1 private self-review, 1 Draft production review, and 1 final GitHub approval; zero corrective review cycles and zero findings.
- Final approval review: GitHub review `4935246571`, `APPROVED`, commit `14e4f2b2469386aafb29556ddd514bee5025195c`.
- No final Slack `Check this one again` message was posted because Draft production feedback completed clean and produced no finding to re-review.
- Final base/head checkpoint: local, pushed, and PR heads matched; fetched base and merge base remained `588b156ddeea6cf5926c266f41fbab72ee3de258`; no base advance; clean worktree; Ready, mergeable, no actionable threads.
- Post-merge verification: GitHub reports PR #1148 closed and merged at 2026-08-14T12:59:46Z with merge commit `31c57385d9965607e22813b1619b343a37e7c54b`.

## Exact-current-head CI

- Run `31778352981`, attempt 1, exact head `14e4f2b2469386aafb29556ddd514bee5025195c`, completed successfully.
- `web-unit` job `94698495859`: passed in 777s.
- `backend-and-infra` job `94698495895`: passed in 866s.
- `web-e2e` job `94698495936`: passed in 376s.
- `web-cross-browser` job `94698496310`: expected path-gated skip; neither changed file is in its trigger scope.
- Attempts 2 and 3 were intentional timing-only reruns of the already successful `web-unit` job and produced jobs `94702050174` and `94705568209`; backend, end-to-end, and cross-browser work was not rerun for benchmark collection.
- The latest-50 completed PR-run cadence calculation used `run_started_at` to `updated_at`: maximum 14m 58s, plus two minutes rounded down to a 16-minute one-shot follow-up.

## Risk and follow-up

Risk is limited to test-harness fidelity. Implicit hover is skipped only where no test asserts hover-revealed behavior, and direct controlled-input changes are limited to terminal setup values whose keyboard sequence is not the contract. The dedicated masking test preserves realistic incremental input. Roll back by reverting commit `14e4f2b2469386aafb29556ddd514bee5025195c`.

Next candidate or follow-up: re-inventory the newest successful main `web-unit-timing` artifact against completed optimization records and active-PR overlap before selecting another hotspot. Restore or document the missing `scripts/summarize_web_unit_samples.py` helper separately; it was not part of this optimization PR.
