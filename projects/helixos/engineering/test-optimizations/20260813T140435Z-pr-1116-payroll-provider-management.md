# HelixOS PR #1116 — Extract payroll provider models to accelerate web tests

- PR: https://github.com/helixosio/helixos/pull/1116
- PR created: 2026-08-13T04:42:56Z
- Merged: 2026-08-13T14:04:35Z
- PR open-to-merge: 9h 21m 39s
- Recorded implementation/handoff: not recorded in available evidence
- Work-start-to-merge: not recorded in available evidence
- Head: `2b50693f8b8938fb4e01c325fb6672c304bb6408`
- Merge: `22fe3db8e4c6915ab24eebcad579350dc933a063`
- Hosted run: `31673798073`, attempts 1-3; exact-base run `31671496026`

## Local result

- Baseline: 26 component tests, 75.90s total / 70.97s test execution.
- Current: 26 component tests plus 24 direct tests, 44.39s total / 39.53s execution.
- Change: -41.5% wall and -44.3% execution with added direct coverage.

## Hosted result

| Measurement | Main | PR median | PR range | Change |
| --- | ---: | ---: | ---: | ---: |
| Payroll Provider file | 75.749s | 48.501s | 47.953-51.106s | -36.0% |
| Page assertions | 72.405s | 45.658s | 45.210-48.273s | -36.9% |
| Web command | 608.838s | 609.845s | 596.208-614.149s | +0.2% |
| Vitest report | 596.304s | 596.104s | 583.559-601.271s | -0.03% |
| `web-unit` job | 13m33s | 13m37s | 13m13s-13m38s | +0.5% |

All three samples passed 124 suites / 1,336 tests with zero failures or skips. The target improved materially; whole-job time stayed neutral because four direct-module suites added 24 tests.

Provenance: PR description with three hosted samples.
