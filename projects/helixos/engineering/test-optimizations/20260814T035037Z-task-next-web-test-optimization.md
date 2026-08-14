# HelixOS next web-test runtime optimization

## Outcome

- Status: in-progress
- Objective: Select, implement, benchmark, and deliver the next evidence-backed HelixOS web-test runtime optimization as a Draft pull request, then complete the prescribed review, exact-head CI, and hosted timing workflow.
- Work started: 2026-08-14T03:50:37Z
- Repository: https://github.com/helixosio/helixos
- Implementation branch: `codex/optimize-next-web-test`, created from `origin/main`
- Starting local head: `e81c2706ca31c91c1e19a3adbede9d08c8d56e9f`
- Starting base: `526bd35fc34f4074585aaf773ec43ddcea9b93eb` (`origin/main` after fetch)
- Pull request: not created
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
- Validation, review, CI, and hosted samples: pending implementation.
- Completion timestamp, final PR identity, duration, and terminal outcome: pending.
