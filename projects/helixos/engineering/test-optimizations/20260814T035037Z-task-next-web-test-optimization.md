# HelixOS next web-test runtime optimization

## Outcome

- Status: in-progress
- Objective: Select, implement, benchmark, and deliver the next evidence-backed HelixOS web-test runtime optimization as a Draft pull request, then complete the prescribed review, exact-head CI, and hosted timing workflow.
- Work started: 2026-08-14T03:50:37Z
- Repository: https://github.com/helixosio/helixos
- Implementation branch: `codex/optimize-next-web-test`, created from `origin/main`
- Starting local head: `e81c2706ca31c91c1e19a3adbede9d08c8d56e9f`
- Starting base: `526bd35fc34f4074585aaf773ec43ddcea9b93eb` (`origin/main` after fetch)
- Pull request: https://github.com/helixosio/helixos/pull/1147 (`Ready`; owner-promoted while exact-head CI was starting)
- Target: `src/web/src/app/AppAuthGate.test.tsx`
- Codex task/thread ID: unavailable in the current tool context

## Scope and exclusions

- Optimize one cohesive untreated web-test hotspot without reducing behavioral coverage.
- Preserve behavior-sensitive hover, keyboard, typing/clearing, masking, autocomplete, validation, navigation, mutation, authorization, and request-boundary seams that apply to the selected suite.
- Exclude production behavior changes, test deletion/skipping, weaker assertions, timeout increases, unrealistic fixtures, and files or principal production dependencies overlapped by active pull requests.
- Active pull requests recorded at start: #1145, #1139, #1135, #1117, #1112, #1057, and #689.

## Evidence pending

- Hosted baseline: successful HelixOS CI run `31764043322`, job `94656158900`, head `924890b52eb8002a1f57e59b22c39b22c56218de`; `AppAuthGate.test.tsx` measured 25.1s total and 22.3s tests/hooks with 10 passed, 0 failed, and 0 skipped.
- Target selection: higher untreated `DesktopWorkspacePage.test.tsx` is excluded because active PR #1112 changes its test and production component. `AdminConsolePage.test.tsx` is excluded because it directly exercises `TenantAdminPage`, which active PR #1117 changes. Active PR changes to the shared API-client endpoint catalog do not change the `endpoints.me()` or mocked request seam used by `AppAuthGate.test.tsx`.
- Matched local baseline under `TZ=UTC` with `npm run test -w @helixos/web -- AppAuthGate.test.tsx`: wall 28.356s and 27.753s (median 28.055s); Vitest total 26.57s and 26.15s (median 26.36s); tests/hooks 21.96s and 22.12s (median 22.04s); both samples passed 10/10 with zero failures or skips.
- Interaction inventory: six click-only auth actions; no hover, typing, clearing, mask, autocomplete, keyboard-sequence, upload, or focus contract. Three general-auth-failure cases currently spend the production 1s/2s/4s automatic retry delays before asserting the terminal screen; request retry, forced token refresh, interactive restart, redirect suppression, sign-in, sign-out, invite-route bypass, and provisioning-denial seams must remain covered.
- Implementation: commit `12c487584eb4b19f33e5d4abcd748ce03c7c0ea4` advances the exact production retry delays with Vitest fake time, asserts four request attempts, restores real timers before recovery actions, and uses `skipHover` for click-only auth interactions. Production code is unchanged.
- Matched local post-change samples: wall 7.048s and 7.032s (median 7.040s, -74.9%); Vitest total 5.16s and 5.18s (median 5.17s, -80.4%); tests/hooks 0.801s and 0.822s (median 0.812s, -96.3%); both samples passed 10/10 with zero failures or skips.
- Validation: focused samples passed; the complete 129-file `@helixos/web` suite passed in 175.3s; web lint passed in 14.725s; production build passed in 51.058s; theme check passed in 0.887s; `git diff --check` passed. Build emitted only the repository's existing Rollup annotation and chunk-size warnings.
- Architecture self-review: no production, state, effect, authorization, tenant, transport, mutation, cache, or persistence responsibility changed; the rendered React Query integration seam is retained and strengthened by the explicit retry-count assertion; no behavior, assertion, fixture, or test was removed.
- Draft PR created at 2026-08-14T04:05:48Z from base `526bd35fc34f4074585aaf773ec43ddcea9b93eb`; implementation/local-validation checkpoint recorded as 13m 56s from 2026-08-14T03:50:37Z through 2026-08-14T04:04:33Z.
- Private self-review requested at 2026-08-14T04:09:15Z and completed clean on exact head `12c487584eb4b19f33e5d4abcd748ce03c7c0ea4` at 2026-08-14T04:11:42Z with zero blockers and zero non-blockers.
- The owner promoted the pull request to Ready; workflow run `31769190823` started on the exact head at 2026-08-14T04:13:21Z. The owner-selected Ready state is authoritative and was not reverted.
- Public production feedback requested at 2026-08-14T04:14:51Z. Exact-head review completed at 2026-08-14T04:15:31Z with zero findings, no unresolved review threads, and GitHub approval from `walkeryan` recorded at 2026-08-14T04:15:30Z.
- Exact-head CI is in progress: `web-e2e` passed; `backend-and-infra` and `web-unit` remain in progress; `web-cross-browser` is intentionally skipped for this change.
- Hosted samples, final `jfollas` review, completion timestamp, and terminal outcome: pending.
- Completion timestamp, final PR identity, duration, and terminal outcome: pending.
