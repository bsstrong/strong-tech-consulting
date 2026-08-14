# HelixOS next web-test runtime optimization

## Outcome

- Status: in-progress
- Objective: Select, implement, benchmark, and deliver the next evidence-backed HelixOS web-test runtime optimization through Draft pull request, private self-review, production feedback, exact-head CI, three hosted timing samples, and final GitHub approval; do not merge.
- Work started: 2026-08-14T06:27:20.275Z
- Completed: pending
- Repository: https://github.com/helixosio/helixos
- Starting workspace branch: `main` (no implementation work will occur on `main`)
- Starting local head: `e81c2706ca31c91c1e19a3adbede9d08c8d56e9f`
- Starting base: `588b156ddeea6cf5926c266f41fbab72ee3de258` (`origin/main` after fetch)
- Implementation branch: `codex/optimize-next-web-test-20260814`, created from `origin/main`
- Pull request: https://github.com/helixosio/helixos/pull/1148 (`Draft`)
- Target: `src/web/src/features/client-directory/ClientCreateDialog.test.tsx`
- Codex task/thread ID: unavailable in the current tool context

## Scope and exclusions

- Optimize one cohesive untreated web-test hotspot without reducing behavioral coverage.
- Preserve behavior-sensitive hover, keyboard, typing/clearing, masking, autocomplete, validation, navigation, mutation, authorization, and request-boundary seams that apply to the selected suite.
- Exclude production behavior changes, test deletion/skipping, weaker assertions, timeout increases, unrealistic fixtures, and files or principal production dependencies overlapped by active pull requests.
- Carry the PR to the exact-current-head ready-to-merge gate, including `jfollas` approval, but do not merge.
- Active pull requests recorded at start: #1145, #1139, #1135, #1117, #1112, #1057, and #689.

## Evidence

- Initial HelixOS worktree was clean. Local `main` was behind `origin/main`; the implementation will begin from fetched `origin/main` on a `codex/` feature branch.
- Hosted baseline: successful main run `31772393863`, attempt 1, `web-unit` job `94680825469`, artifact `9208798305`, exact base/head `588b156ddeea6cf5926c266f41fbab72ee3de258`. `ClientCreateDialog.test.tsx` measured 25.118s total and 22.719s tests/hooks with 13 passed, 0 failed, and 0 skipped. The web command took 503.102s and Vitest runner wall time was 492s.
- Target selection: the nominally slower Plan Detail, Client Editor, Payroll Provider Management, Operations Dashboard, and Payroll Batches suites already have completed optimization records. Desktop Workspace overlaps active PR #1112. Admin Console exercises Tenant Administration and the shared API-client surface changed by active PR #1117. `ClientCreateDialog.test.tsx` is the next untreated hotspot; none of the active PRs changes the test, `ClientCreateDialog.tsx`, its client-create model, address field, validation, placement autocomplete, or editor-form layout dependencies. Active PR #1117 changes the shared API client, but not the mocked `/api/payroll-providers` request contract used by this suite.
- Interaction inventory: the suite contains click-only switches, selects, autocomplete clear, and submit actions; one explicit masking test depends on realistic typing for EIN, phone, city filtering, and postal-code formatting. Setup-only save payload fields are typed character by character but do not assert keyboard or focus sequencing. No scenario asserts implicit hover behavior. Country selection, parent clearing, masking, validation, async payroll-provider loading, parent rerender preservation, address provenance, payload normalization, and save boundaries must remain covered.
- Matched local baseline under `TZ=UTC` with `npm run test -w @helixos/web -- ClientCreateDialog.test.tsx`: sample 1 wall 27.590s, Vitest total 25.59s, tests/hooks 20.84s; sample 2 wall 30.471s, Vitest total 28.35s, tests/hooks 23.69s. Median wall 29.031s, total 26.970s, and tests/hooks 22.265s. Both samples passed 13/13 with zero failures or skips.
- Implementation: commit `14e4f2b2469386aafb29556ddd514bee5025195c` centralizes click-oriented user-event setup with implicit hover disabled and changes only setup-only save fields to direct controlled-input changes. Realistic `userEvent.type` coverage remains for EIN, phone, city, and postal-code masking. Production code is unchanged.
- Matched local post-change samples: wall 20.798s and 21.750s (median 21.274s, -26.7%); Vitest total 19.33s and 19.91s (median 19.620s, -27.2%); tests/hooks 15.10s and 15.41s (median 15.255s, -31.5%). Both samples passed 13/13 with zero failures or skips.
- Final local validation: focused suite passed 13/13; complete 129-file `@helixos/web` unit suite passed in 207.7s; web lint passed in 19.126s; production build passed in 71.437s; theme check passed in 0.679s; `git diff --check` passed. The complete suite and build emitted only pre-existing MSW/React-test and Rollup/chunk-size warnings.
- Architecture self-review: no production, state, effect, authorization, tenant, transport, mutation, cache, persistence, or presentation responsibility changed. The rendered React Query/MUI/request seams remain, realistic masking input remains, and no test, assertion, fixture, behavior variant, or timeout was removed or loosened.
- Draft PR created at 2026-08-14T06:41:26Z from base `588b156ddeea6cf5926c266f41fbab72ee3de258`; implementation/local-validation checkpoint was 13m 13s from 2026-08-14T06:27:20.275Z through 2026-08-14T06:40:32.822Z.
- Private exact-head self-review requested in `#self-reviews` at 2026-08-14T06:45:30.803Z using parent timestamp `1786689930.802859`. One follow-up heartbeat (`pr-1148-self-review-check`) was scheduled for the required seven-minute initial window.
- Private exact-head self-review completed clean at 2026-08-14T06:47:49.189Z on `14e4f2b2469386aafb29556ddd514bee5025195c`: zero blockers, zero non-blockers, and no inline findings. Review turnaround from request was 2m 18s. The one-shot monitoring heartbeat was deleted after confirmation.
- Draft production feedback, exact-head CI, hosted artifacts, Ready transition, and final approval are pending.

## Risk and follow-up

- Risk and rollback will be recorded after target selection and implementation.
- Next candidate or follow-up: pending hotspot inventory.
