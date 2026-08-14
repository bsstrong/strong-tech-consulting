# HelixOS PR #1140 — Speed up Zorka Studio ruleset web tests

- PR: https://github.com/helixosio/helixos/pull/1140
- PR created: 2026-08-13T22:17:56Z
- Merged: 2026-08-13T23:26:37Z
- PR open-to-merge: 1h 08m 41s
- Recorded implementation/handoff: not recorded in available evidence
- Work-start-to-merge: not recorded in available evidence
- Head: `9518fdd644c5317764747cbcbdffa7cc6a48c9ef`
- Merge: `e6e6c7d8aec33dfb66deb3201ec0f7d4629106cb`
- Baseline run: `31747168791`
- Hosted samples: run `31750156414`, attempts 1-3

## Local result

| Measurement | Baseline | Current median | Change |
| --- | ---: | ---: | ---: |
| Focused wall | 37.36s | 19.91s | -46.7% |
| Tests/hooks | 32.30s | 14.32s | -55.7% |
| Tests | 11 | 11 | preserved |

## Hosted result

| Measurement | Median | Range | Baseline change |
| --- | ---: | ---: | ---: |
| Target total | 22.16s | 17.98-24.82s | -50.3% vs 44.6s |
| Tests/hooks | 19.18s | 15.90-21.75s | -53.9% vs 41.6s |
| `web-unit` job | 12m55s | 10m31s-13m10s | contextual |
| Web command | 9m35s | 7m44s-9m47s | contextual |
| Vitest report | 9m23s | 7m34s-9m34s | contextual |

All three samples passed 126 suites / 1,349 tests with zero failures or skips. Every target sample retained 11/11 passing tests with no retry or flake evidence.

Provenance: PR description with three hosted samples.
