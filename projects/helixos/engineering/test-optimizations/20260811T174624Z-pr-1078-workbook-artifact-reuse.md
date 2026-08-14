# HelixOS PR #1078 — Reuse generated workbook artifacts in API tests

- PR: https://github.com/helixosio/helixos/pull/1078
- Merged: 2026-08-11T17:46:24Z
- Head: `dbe9fe0fc0e77f4da8c5b56c6656b8543f2d6755`
- Merge: `b5033dfd0077ed8fd12bed698c7fe551eaa3e855`
- Hosted run: `31501854692`

## Retained result

| Measurement | Compiled baseline | Artifact reuse | Change |
| --- | ---: | ---: | ---: |
| API command | 318,805ms | 246,791ms | -22.6% |
| Workbook file | ~183s | 128,280ms | -29.9% |
| CPU utilization | 175% | 185% | +10 points |
| Peak RSS | 566,108 KiB | 566,464 KiB | +0.1% |
| Coverage | 235 files / 2,566 tests | 235 files / 2,566 tests | preserved |

All four jobs passed; all 23 workbook tests and contract reporters remained present. The cache was test-local, returned copied buffers, and preserved fresh workbook objects and custom-input generation.

## Rejected experiment

Splitting the workbook suite reduced the longest file but raised API wall time from 318,805ms to 334,661ms (+5.0%) and produced 4m 13s of combined workbook work. The split was reverted before retaining artifact reuse.

Provenance: PR description and checked-in timing record. This optimization predates the three-sample cadence.
