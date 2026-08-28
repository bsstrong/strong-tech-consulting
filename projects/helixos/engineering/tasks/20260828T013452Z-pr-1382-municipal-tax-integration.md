# HelixOS Work - Complete municipal income-tax integration delivery

## Identity

- Status: Completed; Zorka changes merged and HelixOS delivery approved, with HelixOS merge intentionally deferred
- Repository: `helixosio/helixos` and `zorkacom/zorka`
- Completed: 2026-08-28T04:22:17Z
- Task/thread ID: unavailable
- Branch: `codex/issue-1280-municipal-tax-workflow`, `codex/issue-1280-global-stored-execution`, and `codex/municipal-tax-ruleset`
- Final head SHA: HelixOS `98cfbeb05cf7cdf6f5ca9d85792cb1866f7f794c`; Zorka #166 `b0385a5a2525ccbd9a346bdbd039a6d0f2de81c2`; Zorka #168 `4464f56f8e3a1b84e2bacc0f9c543c11f8f6ff9f`
- Issue: `helixosio/helixos#1280`
- PR: [HelixOS #1382](https://github.com/helixosio/helixos/pull/1382), [Zorka #166](https://github.com/zorkacom/zorka/pull/166), and [Zorka #168](https://github.com/zorkacom/zorka/pull/168)

## Objective and outcome

Complete the cross-repository municipal income-tax screening workflow. Product approved the exact checked-in dataset for Beta validation. The implementation, exact-tree architecture reviews, required CI, combined local acceptance, pull-request descriptions, and review resolution are complete. Zorka #166 and #168 merged. HelixOS #1382 is approved and green, but its merge is intentionally deferred so the automatic Test deployment does not expose the new municipal section before the planned demonstration. No Zorka image release, environment deployment, or ruleset activation occurred.

## Delivered changes and decisions

- HelixOS screens normalized client situs against the platform-owned ruleset, persists a fail-soft result, presents the result in the client workflow, governs application evidence, and audits Option 1 transitions.
- Zorka resolves platform-global stored rulesets through the existing visibility and lifecycle policies, including active-first selection, deprecated fallback, and withdrawn exclusion.
- The governed ruleset contains state-scoped lookup tables, conservative collision handling, closed/partial coverage policy, invalid-input safeguards, deterministic generation, and integrity evidence.
- Review corrections close rejected upload streams, prioritize unresolved municipal guidance, warn when active Option 1 no longer aligns with a clear screening result, avoid loading version history for unselected rulesets, apply lifecycle policy consistently, reject whitespace-only input, and pin governed artifacts to stable LF bytes.
- Each pull-request description now contains an exact-current-head file-change breakdown and open-ended Beta-validation language without a promised duration.
- Zorka #166 and #168 descriptions were re-authored as structured Markdown and updated through a JSON request body that preserves line breaks; the remote bodies were verified byte-for-byte after each write.
- Zorka #166 and #168 merged after their exact-head review and CI gates passed. HelixOS #1382 received approval on its current head and remains unmerged by owner decision rather than an implementation or review blocker.

## Validation, review, and CI

- HelixOS exact-head CI passed its required backend, web-unit, and web-E2E checks. Full API tests passed 3,388/3,388; full web tests passed 1,955/1,955 across 231 suites; focused municipal, client-file, shared-contract, database, build, lint, theme, and OpenAPI checks passed. The final feedback correction additionally passed 21/21 focused web tests, targeted ESLint, and the web production build.
- Zorka #166 exact-head CI passed all eight checks. Full API unit tests passed 527/527 and full API E2E passed 89/89, including authenticated PostgreSQL/API/runtime global-ruleset coverage.
- Zorka #168 exact-head CI passed all eight checks. Tool tests passed 17/17, Runtime tests passed 333/333, and exact-artifact municipal scenarios passed 13/13.
- Combined acceptance proved the global ruleset path, immutable-version propagation, Helix persistence and presentation for matched, clear, incomplete-input, and simulated-outage cases, and fail-soft recovery after service restoration.
- Mandatory architecture self-review and exact-tree checkpoints found no unresolved actionable correctness, security, authorization, architecture, test-placement, or performance issue. GitHub reports HelixOS #1382 approved, mergeable, and green on all required checks.
- GitHub's Markdown renderer confirmed structured output for all three descriptions: HelixOS #1382 has 10 section headings and 3 tables; Zorka #166 has 7 section headings and 2 tables; Zorka #168 has 10 section headings and 1 table. No inline-collapsed heading remains.

## Risk and follow-up

City/state remains a conservative screening proxy rather than authoritative municipal-boundary resolution; incomplete and ambiguous evidence remains fail-safe `UNDETERMINED`. Dataset approval and source merge do not activate or deploy the ruleset. After the demonstration, publish and deploy the approved Zorka application image to Test, import and publish the municipal ruleset, verify slug execution, and then merge HelixOS #1382. Merging HelixOS first would remain fail-soft, but would immediately expose an unresolved municipal status in Test and could add up to the five-second integration deadline on client saves.
