# HelixOS PR #1090 — Speed up Sales Proforma workbook contract tests

- PR: https://github.com/helixosio/helixos/pull/1090
- PR created: 2026-08-11T23:44:26Z
- Merged: 2026-08-11T23:59:55Z
- PR open-to-merge: 15m 29s
- Recorded implementation/handoff: not recorded in available evidence
- Work-start-to-merge: not recorded in available evidence
- Head: `4c487a5a77e5773dff76b0e9d0218d7d992c4c53`
- Merge: `3e4f02e45b409b2876deb6ff6b64fb768c302f80`
- Recovered exact-head run: `31547698044`, backend job `93963594632`

## Result

| Measurement | Baseline | Current | Change |
| --- | ---: | ---: | ---: |
| Focused source suite | 142.5s | 56.1s | -60.6% |
| Focused compiled suite | not recorded | 53.4s | contextual |
| Hosted API command | 246.8s prior optimization | 243.8s | effectively neutral |
| Hosted API runner | not recorded | 4m 03s | contextual |
| Hosted workbook file | 128.3s prior optimization | 1m 33s | approximately -27.5% |
| Coverage | 23 tests / 125 assertions | 23 tests / 125 assertions | preserved |

Semantic assertions moved to the populated ExcelJS model while package topology, normalization, repair metadata, formula caches, media, table metadata, long headers, and formula-looking input remained on serialized output. The complete compiled API command passed 235 files and 2,570 tests with zero failures or skips.

Provenance: PR description plus the still-retained `backend-and-infrastructure-timing` artifact downloaded from run `31547698044`. One hosted sample was available.
