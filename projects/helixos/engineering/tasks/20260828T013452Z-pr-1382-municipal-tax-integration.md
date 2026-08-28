# HelixOS Work - Complete municipal income-tax integration review handoff

## Identity

- Status: Delivered; HelixOS human review approved, Zorka human review pending
- Repository: `helixosio/helixos` and `zorkacom/zorka`
- Completed: 2026-08-28T01:48:45Z
- Task/thread ID: unavailable
- Branch: `codex/issue-1280-municipal-tax-workflow`, `codex/issue-1280-global-stored-execution`, and `codex/municipal-tax-ruleset`
- Final head SHA: HelixOS `faba8ac52cd396e7ade2b18ac5a4136f54198b40`; Zorka #166 `b0385a5a2525ccbd9a346bdbd039a6d0f2de81c2`; Zorka #168 `4464f56f8e3a1b84e2bacc0f9c543c11f8f6ff9f`
- Issue: `helixosio/helixos#1280`
- PR: [HelixOS #1382](https://github.com/helixosio/helixos/pull/1382), [Zorka #166](https://github.com/zorkacom/zorka/pull/166), and [Zorka #168](https://github.com/zorkacom/zorka/pull/168)

## Objective and outcome

Complete the cross-repository municipal income-tax screening workflow and place all three pull requests at the human final-review gate. Product approved the exact checked-in dataset for Beta validation. The implementation, exact-tree architecture reviews, required CI, combined local acceptance, pull-request descriptions, and reviewer requests are complete. A follow-up metadata repair restored structured GitHub Markdown after a multiline update flattened the two Zorka descriptions. No merge, Beta activation, deployment, release, or Production action occurred.

## Delivered changes and decisions

- HelixOS screens normalized client situs against the platform-owned ruleset, persists a fail-soft result, presents the result in the client workflow, governs application evidence, and audits Option 1 transitions.
- Zorka resolves platform-global stored rulesets through the existing visibility and lifecycle policies, including active-first selection, deprecated fallback, and withdrawn exclusion.
- The governed ruleset contains state-scoped lookup tables, conservative collision handling, closed/partial coverage policy, invalid-input safeguards, deterministic generation, and integrity evidence.
- Review corrections close rejected upload streams, prioritize unresolved municipal guidance, avoid loading version history for unselected rulesets, apply lifecycle policy consistently, reject whitespace-only input, and pin governed artifacts to stable LF bytes.
- Each pull-request description now contains an exact-current-head file-change breakdown and open-ended Beta-validation language without a promised duration.
- Zorka #166 and #168 descriptions were re-authored as structured Markdown and updated through a JSON request body that preserves line breaks; the remote bodies were verified byte-for-byte after each write.
- `jfollas` approved HelixOS #1382 on its exact current head and remains requested on both Ready Zorka pull requests. Agent-authored review comments are not used as review evidence under the current lifecycle policy.

## Validation, review, and CI

- HelixOS exact-head CI passed its required backend, web-unit, and web-E2E checks. Full API tests passed 3,388/3,388; full web tests passed 1,955/1,955 across 231 suites; focused municipal, client-file, shared-contract, database, build, lint, theme, and OpenAPI checks passed.
- Zorka #166 exact-head CI passed all eight checks. Full API unit tests passed 527/527 and full API E2E passed 89/89, including authenticated PostgreSQL/API/runtime global-ruleset coverage.
- Zorka #168 exact-head CI passed all eight checks. Tool tests passed 17/17, Runtime tests passed 333/333, and exact-artifact municipal scenarios passed 13/13.
- Combined acceptance proved the global ruleset path, immutable-version propagation, Helix persistence and presentation for matched, clear, incomplete-input, and simulated-outage cases, and fail-soft recovery after service restoration.
- Mandatory architecture self-review and exact-tree checkpoints found no unresolved actionable correctness, security, authorization, architecture, test-placement, or performance issue. GitHub reports zero unresolved review threads on all three current heads.
- GitHub's Markdown renderer confirmed structured output for all three descriptions: HelixOS #1382 has 9 section headings and 3 tables; Zorka #166 has 7 section headings and 2 tables; Zorka #168 has 10 section headings and 1 table. No inline-collapsed heading remains.

## Risk and follow-up

City/state remains a conservative screening proxy rather than authoritative municipal-boundary resolution; incomplete and ambiguous evidence remains fail-safe `UNDETERMINED`. Dataset approval does not activate or deploy the ruleset. Human final review remains pending for the two Zorka pull requests, and no merge is authorized.
