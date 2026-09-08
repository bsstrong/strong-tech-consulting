# Browser-compatible Proforma download

## Objective

Restore Quote Proforma downloads in browser runtimes that do not expose object URLs, and carry the correction through the HelixOS production-review lifecycle.

## Outcome

Pull request #1718 was approved on its exact head, passed required CI, merged, and was cleaned up.

## Delivered

- Added a data-URL fallback while preserving object URLs as the preferred download path.
- Awaited download preparation so failures propagate to callers.
- Added quote-scoped pending and safe error handling to the Proforma action.
- Added focused regression coverage for fallback delivery and failure UX.

## Evidence

- Local comprehensive hermetic suite passed, including 2,478 web unit tests and the integration smoke.
- Linux guardrail suites passed; infrastructure suites passed 29/29.
- Production review approved commit `8a20fe271` with no findings.
- Required exact-head CI completed successfully.
- Merged at 2026-09-08T10:06:38Z.
- Dedicated worktree and local/remote feature branches were removed after merge verification.

## Residual risk and follow-up

- The fallback holds an encoded download in browser memory when object URLs are unavailable. Object URLs remain preferred.
- Re-verify the Proforma download in TEST after the merged revision deploys.
