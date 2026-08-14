# HelixOS PR #1131 — Speed up Operations Dashboard web tests

- PR: https://github.com/helixosio/helixos/pull/1131
- Merged: 2026-08-13T21:47:01Z
- Head: `a080664e6dd8536b6a98a6f41ab6a047d51e4113`
- Merge: `8242afb4d7d1922483e12e2fa97f505e5b36f0e5`
- Baseline run: `31700323078`
- Hosted samples: run `31716001704` on head `7eec6858d2b065042cb889cd0563fa5f55781b88`

## Local result

| Measurement | Baseline | Current median | Change |
| --- | ---: | ---: | ---: |
| Focused wall | 44.43s | 35.20s | -20.8% |
| Tests/hooks | 37.42s | 27.96s | -25.3% |
| Tests | 45 | 45 | preserved |

## Hosted samples

| Attempt | Job | Command | Report | Target total | Tests/hooks |
| --- | ---: | ---: | ---: | ---: | ---: |
| 1 | 14m18s | 10m48.79s | 10m34.59s | 40.40s | 37.27s |
| 2 | 13m44s | 10m14.84s | 10m01.25s | 38.59s | 35.70s |
| 3 | 13m21s | 9m59.10s | 9m46.45s | 38.31s | 35.46s |
| **Median** | **13m44s** | **10m14.84s** | **10m01.25s** | **38.59s** | **35.70s** |

Against the hosted baseline of 48.3s total / 45.6s tests-hooks, medians improved 20.1% and 21.7%. Every sample preserved all 45 target tests and passed 126 suites / 1,349 tests with zero failures, skips, retries, or flakes.

Provenance: PR description with three hosted samples.
