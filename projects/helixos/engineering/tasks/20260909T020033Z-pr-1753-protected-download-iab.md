# HelixOS Work - Restore in-app-browser Proforma downloads

## Identity

- Status: Merged and cleaned up
- Repository: `helixosio/helixos`
- Completed: 2026-09-09T02:00:33Z
- Branch: `codex/issue-1716-proforma-download`
- Final PR head SHA: `b1332726a03127bb651116e6e3e5e6dfae9a51c8`
- Merge commit: `aace8de65dfc016926e3c10105dc44e038cab183`
- Issue: [#1716](https://github.com/helixosio/helixos/issues/1716)
- PR: [#1753](https://github.com/helixosio/helixos/pull/1753)

## Objective and outcome

Restore completed Quote Proforma delivery in the Codex in-app browser without changing Proforma generation, storage, authorization, immutable artifact identity, or workbook content. PR #1753 merged, issue #1716 closed, and the dedicated worktree and local/remote branch state were cleaned up.

## Delivered changes and decisions

- Replaced the canceled data-URL compatibility path with the browser-native save picker and writable-file API when object URLs are unavailable.
- Opens the picker before authentication/fetch awaits so Chromium retains transient user activation, then writes the exact authenticated response Blob.
- Preserved the standard object-URL path and centralized both direct and upload-generated protected downloads under the shared API-client owner.
- Added transport, Quote workflow, and affected-consumer regression coverage plus a browser-compatibility contract document.
- Published three implementation commits, synchronized current `main`, opened the Ready PR, and requested production review through the required Slack channel.

## Validation, review, and CI

- Local production builds passed, including a post-sync web build.
- Payroll, browser-auth, payroll-cycle UI (373), Quote UI (77), client portal (239), and full web unit (2,491) tests passed; 92 affected web tests passed again after base synchronization.
- Linux repository guardrails and Azure CLI infrastructure guardrails passed; isolated PostgreSQL 16 integration smoke passed.
- Axis catalog and canonical diff checks passed. A secure local Codex in-app-browser probe confirmed native save-picker availability.
- Production review approved the exact PR head with no findings or review threads.
- Every required current-head CI check passed, including backend integration, all web unit shards, web checks, and web end-to-end.

## Risk and follow-up

Hosted TEST UAT was not run because the implementation assignment did not authorize a hosted application operation. The remaining delivery risk is the deployed in-app-browser host boundary; after deployment, repeat the original Quote and Client Files download/checksum and spreadsheet-open acceptance flow. Browsers exposing neither supported delivery API now receive a visible compatibility error before any authenticated request starts.
