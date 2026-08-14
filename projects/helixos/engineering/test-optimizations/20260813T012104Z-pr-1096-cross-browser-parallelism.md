# HelixOS PR #1096 — Parallelize cross-browser Playwright CI

- PR: https://github.com/helixosio/helixos/pull/1096
- Merged: 2026-08-13T01:21:04Z
- Head: `5efd63283dc0b2dbfcdbcc5a2a405a3836ec5e5`
- Merge: `6fc42e2570cc82e30a945157c6d72ad980b53a89`
- Performance head: `b89f734469d30845be3939fe9d246bd5e7496a6a`

## Hosted samples

| Run | Firefox job / step / report | WebKit job / step / report |
| --- | ---: | ---: |
| `31630368704` | 6m50s / 5m15s / 153.528s | 10m00s / 8m22s / 339.406s |
| `31631318706` | 4m37s / 3m31s / 99.045s | 9m40s / 8m08s / 327.694s |
| `31636791376` | 6m40s / 5m24s / 168.243s | 10m06s / 8m09s / 336.053s |
| **Median** | **6m40s / 5m15s / 153.528s** | **10m00s / 8m09s / 336.053s** |

Each browser selected 41 tests and reported 37 expected passes, 4 skips, zero failures, zero retries, and zero flakes. One retry-contaminated run was excluded.

Against pre-change run `31566690088`, median WebKit job time fell 24.4%, its Playwright step fell 30.2%, and the cross-browser critical path fell from 17m11s to 10m00s (-41.8%). Median aggregate runner time fell 14.7%, so latency was not traded for higher runner consumption.

Provenance: PR description with three retained hosted samples.
