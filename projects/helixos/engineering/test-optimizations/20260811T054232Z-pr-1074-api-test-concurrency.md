# HelixOS PR #1074 — Use both hosted runner CPUs for API tests

- PR: https://github.com/helixosio/helixos/pull/1074
- PR created: 2026-08-11T04:20:44Z
- Merged: 2026-08-11T05:42:32Z
- PR open-to-merge: 1h 21m 48s
- Recorded implementation/handoff: not recorded in available evidence
- Work-start-to-merge: not recorded in available evidence
- Head: `baae313661ca2f0152a5f19d00f5e2ee8ede319f`
- Merge: `5bb767a84b9ae3b8cd9d6d4e9d36b5f2860ffa6e`
- Hosted run: `31458185462` on implementation head `b9f20b03f3bb259a62a494b96e18e3c7df38f37b`

## Result

| Measurement | Baseline | Current | Change |
| --- | ---: | ---: | ---: |
| API wall time | 9m 19s | 8m 09s | -1m 10s / -12.5% |
| CPU utilization | 138% | 188% | second CPU utilized |
| Peak RSS | 744 MiB | 713 MiB | -31 MiB |
| `backend-and-infra` job | 18m 40s | 17m 04s | -1m 36s |
| Coverage | 235 files / 2,566 tests | 235 files / 2,566 tests | preserved |

All 2,566 tests passed with zero failures or skips. Concurrency two was retained; higher concurrency was not indicated because the dominant workbook test slowed under CPU contention.

Provenance: PR description and the checked-in CI timing record. This optimization predates the three-sample cadence.
