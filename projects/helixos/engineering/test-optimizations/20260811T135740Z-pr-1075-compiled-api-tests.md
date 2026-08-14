# HelixOS PR #1075 — Run API tests from compiled build output

- PR: https://github.com/helixosio/helixos/pull/1075
- Merged: 2026-08-11T13:57:40Z
- Head: `1f8f6522a82b7a60c99e60c09e2e67c196ed82b3`
- Merge: `bf93be465242aa0a94f7265af978ab9076837145`
- Hosted run: `31493731257` on implementation head `bd33c24a71f785e8e71b8129da43634fb9327833`

## Result

| Measurement | PR #1074 baseline | Current | Change |
| --- | ---: | ---: | ---: |
| API wall time | 489,251ms / 8m 09s | 318,805ms / 5m 19s | -34.8% |
| CPU utilization | 188% | 175% | -13 points |
| Peak RSS | 729,864 KiB | 566,108 KiB | -22.4% |
| Coverage | 235 files / 2,566 tests | 235 compiled files / 2,566 tests | preserved |

All tests passed with zero failures or skips. Reporter output remained complete, all paths came from `src/api/dist`, and source/fixture contract suites remained present. Sibling phases moved only -3.2% to +3.9%, isolating the API improvement from runner-wide variation.

Provenance: PR description and checked-in timing record. This optimization predates the three-sample cadence.
