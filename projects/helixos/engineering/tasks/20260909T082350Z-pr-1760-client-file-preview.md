# Client file preview

## Status

Completed. PR #1760 merged on 2026-09-09, issue #1723 closed, its project item moved to Done, and the dedicated branch/worktree were cleaned up.

## Objective and outcome

Add an accessible preview action to Client Files while preserving the existing tenant, Client, and file authorization boundary. Supported images, PDFs, plain text, and CSV now render inline; unsupported or failed previews present safe retry/download guidance.

## Delivered changes and decisions

- Added the server-authorized Preview row action and accessible preview dialog.
- Kept the API-projected `PREVIEW` action and protected tenant/Client preview endpoint authoritative.
- Restricted inline rendering to an explicit safe content-type allowlist; SVG, HTML, and other unsupported formats are not embedded.
- Added authenticated raw-blob transport so object URLs are created only inside the mounted preview surface and revoked on cleanup.
- Added focused coverage for scoped requests, tenant headers, denied access, unsupported formats, action omission, normal URL cleanup, and close-during-load behavior.
- Documented supported formats and the security/lifecycle boundary; refreshed the generated UI surface catalog.
- Delivered in commits `733e4bd739c86c1b80c901a33eb5c23ccf42494b`, `e94dc918b40a35b828fe4213ad5d3aeac1485edb`, and `6a1309194b7e95810c7b00d59a65400b048421e6`; synchronized head `ceaf059386868a3c393c900e978cf113ad461d39` merged as `a3718d99db60f440ed7d5a9a7d2840fdd50546a4`.

## Validation, review, and CI

- Complete web unit suite: 283 files and 2,498 tests passed on the pre-PR candidate.
- Post-correction focused web/API-client run: 2 files and 76 tests passed.
- Existing API authorization seam: 20 controller tests passed.
- Package build, web production build, web lint, theme checks, and the 2,200-surface Axis catalog check passed after synchronization with main.
- The first production review found one object-URL lifecycle blocker. The mounted-owner correction and regression were reviewed on the final head; re-review approved with no findings or open threads.
- All required current-head CI jobs passed, including static checks, package suites, API/workflow/web unit suites, backend integration, web checks, and web end-to-end.

## Risk and follow-up

Browser preview remains intentionally limited to the documented allowlist; other formats require Download permission. Hosted/shared application checks were not run because repository implementation did not authorize live-environment access. No owner follow-up is required.
