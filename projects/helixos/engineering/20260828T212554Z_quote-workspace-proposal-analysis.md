# Broker Quote Workspace Proposal Analysis

## Context

Analysis of the Broker Quote workspace proposal documented in the internal Slack canvas and decomposed by Keith into HelixOS issues [#1421](https://github.com/helixosio/helixos/issues/1421) through [#1425](https://github.com/helixosio/helixos/issues/1425), under umbrella epic [#1420](https://github.com/helixosio/helixos/issues/1420).

The proposal introduces a dedicated Quote aggregate and a permission-controlled four-step Broker workflow:

1. Employee & Payroll Data
2. Validate & Import
3. Run Eligibility
4. Review & Download

The central architectural constraint is that quoting operates only on quote-owned snapshots. It must not write to live Employee, PayrollBatch, eligibility, client lifecycle, plan configuration, or `quoteRunDate` state.

## Overall assessment

The five-issue decomposition is coherent and directionally strong. Quote is correctly separated from the live payroll aggregate, authorization is server-owned, background processing uses Functions and the transactional outbox, and the UI is sequenced after its backend contracts.

The work is ready to allocate, but several foundation contracts should be resolved before #1421 freezes the schema. Most later risks trace back to state ownership, snapshot identity, authorization scope, and sensitive-data boundaries.

| Issue | Scope assessment | Primary risk |
| --- | --- | --- |
| [#1421](https://github.com/helixosio/helixos/issues/1421) | Correct foundation boundary: persistence, RLS, permissions, public contracts, documentation, focused tests | State machine, immutable revision model, configuration snapshots, sensitive fields |
| [#1422](https://github.com/helixosio/helixos/issues/1422) | Necessary security slice: lifecycle-aware capabilities, exact assignments, adjacent endpoints, endpoint-policy matrix | Largest authorization blast radius; hidden-resource leakage through adjacent routes |
| [#1423](https://github.com/helixosio/helixos/issues/1423) | Cohesive API/workflow slice: revisions, imports, validation, outbox, artifact access | Import concurrency, revision conflicts, transactional consistency, action authorization |
| [#1424](https://github.com/helixosio/helixos/issues/1424) | Correct processing boundary: imports, eligibility, proforma, artifacts, infrastructure, telemetry | Existing live eligibility and proforma orchestration cannot be reused wholesale |
| [#1425](https://github.com/helixosio/helixos/issues/1425) | Appropriately last: navigation, landing/detail workflow, E2E | Package responsibility, host integration, and parent/child requirement mismatches |

No Quote implementation or matching pull request was present in the inspected checkout. The issues are currently specifications rather than descriptions of delivered code.

## Foundation decisions needed before #1421

### 1. Add an explicit post-eligibility state

The proposed aggregate statuses include `READY`, `ELIGIBILITY_QUEUED`, `ELIGIBILITY_PROCESSING`, and `PROFORMA_PROCESSING`, but no state representing completed eligibility while waiting for a separately requested proforma run.

#1423 and #1425 describe the user starting proforma after eligibility, while #1424 mentions a proforma-ready transition. The schema should therefore either:

- make proforma automatic after eligibility; or
- add an explicit `ELIGIBILITY_COMPLETED` or `PROFORMA_READY` state and preferably `PROFORMA_QUEUED`; or
- keep aggregate state intentionally coarse and introduce a dedicated proforma job owner with its own state machine.

Reusing `READY` would conflate “validated and ready for eligibility” with “eligibility completed and ready for proforma.” The selected design must also define which owner records queued/running/succeeded/failed transitions.

### 2. Define immutable revision storage

A quote-level `dataRevision` does not independently prove which row images an eligibility run consumed. Choose one database-level invariant:

- append-only Quote rows keyed by quote, revision, and stable row identity; or
- mutable draft rows copied into an immutable frozen snapshot at dispatch.

If rows remain mutable, database-enforced guards should prevent updates and removals after freezing. Service-only checks are weaker than the proposal's immutability guarantee.

Separate revision concepts are useful:

- Quote revision: invalidates validation and identifies a complete dataset version.
- Row revision: supports optimistic editing and prevents same-row lost updates without causing unnecessary quote-wide AG Grid conflicts.
- Frozen run revision: identifies the exact immutable input used by eligibility and proforma.

Persisting both workflow step and status can also drift. Legal combinations need a single transition map and constraints, or the current step should be derived server-side from authoritative state.

### 3. Make failure-stage ownership explicit

`FAILED` is active and resumable, but the aggregate status alone does not identify whether import, validation, eligibility, or proforma failed. Persist the owning stage, failure classification, attempt identity, timestamps, and retry eligibility on the aggregate or stage record.

Retry behavior must be deterministic and must not accidentally restart a later or different stage.

### 4. Pin complete configuration inputs

Keys and current-version pointers are insufficient when their targets can change. A reproducible Quote needs immutable snapshots or references to genuinely immutable versions, plus hashes where appropriate, for:

- ruleset document/version;
- plan configuration and pay schedule;
- included division scope;
- proforma profile, colors, logo references, and product configuration;
- tax inputs and resolved tax results;
- any other external response that affects eligibility or workbook output.

Public contracts should expose only safe provenance summaries. For tax and other external integrations, persisting only a cache/version key may not reproduce the original result after cache replacement or expiry.

### 5. Add composite consistency constraints

Quote should reference the selected `CompanyPlan`, rather than storing unrelated company and plan identifiers that could drift apart. Child tables should use tenant-qualified composite foreign keys. The selected assignment must be proven to belong to the same Quote tenant and client.

The partial unique index for one active quote per client and plan must exclude only `COMPLETED` and `ABANDONED`. `FAILED` intentionally remains active and must continue to block creation of another active Quote.

### 6. Define immutable-result and deletion policy

“Immutable results and artifacts” needs a concrete enforcement mechanism: restricted update/delete paths, append-only repositories, database triggers, or equivalent constraints. Retention and tenant-offboarding exceptions should be documented separately.

Useful uniqueness constraints include:

- one result per eligibility run and quote row;
- unique logical stage attempt identifiers;
- one completed artifact per quote, eligibility run, and artifact type;
- deterministic artifact storage key and checksum.

### 7. Define stable row identity and provenance

Employee identifiers are only unique within their payroll company. Quote rows need a stable quote-local UUID and a source identity that includes the source company or division.

Manual removal should be modeled as retained exclusion/audit state, not destructive deletion. Per-field provenance should identify the source, import or source event, timestamp, and pin actor—not merely a list of pinned field names.

Later imports also need deterministic per-field precedence rules for manually pinned values and source replacements.

### 8. Resolve permission gaps

The proposed permission catalog does not explicitly identify which permission authorizes validation. Decide whether validation is governed by `quotes.data.edit` or requires `quotes.validate` before the permission catalog is frozen.

The Broker experience promises read-only Eligibility Runs after the Documentation lifecycle milestone, but no narrow new permission is specified. Decide whether this uses existing `eligibility.view` or a new `eligibility.runs.view`. The contract must not expose hidden Payroll Batch information or enable ordinary execute/delete/export behavior.

The intended meaning of a Carrier or tenant override should also be clarified. Existing person-level permission overrides and global role-template configuration are not the same as a tenant-wide role-template override.

### 9. Define the sensitive-data boundary

Quote permissions must not imply access to full SSNs, elections, enrollment, coverage decisions, payroll-batch data, or other sensitive employee fields.

Define an explicit minimal allowlist for:

- Quote data rows;
- API list/detail responses;
- eligibility inputs/results;
- audit metadata;
- generated workbook fields;
- logs and telemetry.

Sensitive values should be encrypted where persistence is required and omitted unless the workflow has an independently approved business need and separate authorization.

### 10. Define plan-scope drift behavior

If included plan divisions change after Quote creation, choose one rule:

- invalidate and require a new Quote;
- require an explicit reseed before any run; or
- continue using the frozen original scope.

At run time, compare the exact required scope, return only generic denial information, and persist the resolved set or hash used by the run.

### 11. Clarify public money contracts

Decimal strings should include currency and basis semantics, such as per-pay-period versus annual. Otherwise consumers may silently assume USD or apply incorrect annualization based on pay schedule.

## Existing-code constraints and reuse boundaries

### Eligibility

The current eligibility handler is live operational orchestration. It loads current assignments, payroll rows, employees, tags, and active ruleset state. Its finalization replaces results and mutates live employee eligibility, participation records, activation state, and tags.

Quote processing must not invoke that orchestration. Extract and reuse only deterministic seams such as input mapping, evaluation, and classification in dependency-light modules. Quote retry must execute its originally pinned ruleset even when a newer version becomes active.

Relevant code: `src/packages/workflow/src/handlers/eligibility-run.ts`.

### Payroll feed ingestion

Current payroll feed runs and ingestion are keyed to live payroll state. Replacement ingestion can delete employees absent from a new snapshot, including manually retained data, and supersede live eligibility runs.

A Quote source pull therefore needs a destination-aware run/event and Quote-owned persistence adapter. Pure parsing and normalization can be reused; the live job model and persistence orchestration cannot.

Relevant code:

- `src/packages/workflow/src/payroll-feed/feed-pull-kickoff.ts`
- `src/packages/workflow/src/payroll-feed/feed-ingestor.ts`

### File extraction

The current extractor job table is not a tenant-owned RLS Quote aggregate and its processor polls and claims that table directly. Reuse pure extraction/normalization behavior, not the current job ownership model.

Relevant code:

- `src/packages/workflow/src/file-extractor/processor.ts`
- `src/packages/db/prisma/schema.prisma`

### Sales Proforma

Current Sales Proforma generation is synchronous in the API, reads current mutable profiles and logos, returns bytes directly, updates live `CompanyPlan.quoteRunDate`, and maps full SSNs into workbook input.

The input-driven workbook builder may be reusable after establishing a safe contract, but orchestration, data loading, mutable configuration lookup, live plan writes, and sensitive-field mapping are not reusable for Quote as written.

Relevant code:

- `src/api/src/modules/payroll-batches/payroll-batches.service.ts`
- `src/api/src/modules/payroll-batches/consolidated-sales-proforma-workbook.ts`

Final Quote workbook acceptance should remain dependent on completing the still-open [#819](https://github.com/helixosio/helixos/issues/819) Sales Proforma E2E/UAT and reference-approval work.

## Authorization analysis for #1422

#1422 is the broadest security slice because the Broker experience touches more than Quote routes. The endpoint-policy matrix should explicitly classify:

| Surface | Required policy behavior |
| --- | --- |
| Client list/detail | All-client access or exact assigned-client access; no hidden-client existence leakage |
| Subsidiaries/divisions | Exact assignment and scope; generic denial for missing required divisions |
| Lifecycle history | Broker should not infer policy from a direct history query; the capability policy evaluates history internally |
| Notes | Notes action permission plus visible client |
| Files | Separate view/upload/download action permissions plus visible client; authorize before file or storage lookup |
| Employees | Exact visible owning client plus action permission; sensitive, enrollment, and payroll operations remain independently denied |
| Eligibility Runs | Narrow read-only client-scoped policy; do not expose Payroll Batches or ordinary execute/delete/export actions |
| Quote routes | Quote action permission plus tenant/client/plan ownership; readiness requires exact included-division scope |
| Platform administration, Portal, Operations | Independently permissioned or denied; do not inherit Broker Quote access |
| Public callbacks and service integrations | Independent machine/service authorization |

The ordinary Employee boundary should enumerate which create/edit/import/remove fields and endpoints are included. It should explicitly exclude payroll-batch operations, full SSNs and sensitive PII, enrollment/elections, labels if not intended, coverage decisions, and skip-pay-cycle behavior.

Server responses should provide visible sections and effective actions. React must not query lifecycle history and recreate authorization logic client-side.

## Concurrency and idempotency requirements

The platform's transactional outbox and workflow-delivery deduplication provide useful transport-level primitives, but they do not protect against two distinct commands targeting the same Quote.

Each stage should therefore use:

- expected Quote revision and frozen revision in the event;
- compare-and-set transitions that include current stage/status and non-abandoned state;
- a unique logical command and attempt key;
- Quote-keyed Service Bus session ordering;
- deterministic artifact storage keys and checksums;
- atomic stage completion and follow-up outbox insertion;
- abandonment precedence over in-flight workers;
- successful no-op handling for stale or out-of-order events.

For large imports, parsing and external I/O should occur outside the database transaction. The short apply transaction should lock or compare-and-set the expected revision, atomically merge all normalized rows, increment the Quote revision once, and reject stale input rather than silently rebasing it.

One active import per Quote is the simplest initial concurrency policy.

## Database and migration expectations

- The partial active-Quote uniqueness index requires raw SQL because Prisma cannot express the predicate.
- All Quote tables require `ENABLE ROW LEVEL SECURITY` and `FORCE ROW LEVEL SECURITY` with tenant-context policies.
- Child relations should be tenant-qualified composite relations.
- Concurrency tests should use competing transactions rather than only inspecting schema text.
- Permission migrations must update definitions, draft cells, and active snapshots without recreating or overwriting unrelated customized templates.
- Quote audit metadata must remain PII-safe. Reuse the existing client audit mechanism where its ownership and semantics fit.

## UI and package ownership

The mandated `@helixos/quote-ui` package should remain presentational. The web host should own:

- React Query and server-state caching;
- tenant-aware authenticated transport;
- permission and effective-action handling;
- protected downloads;
- routing and deep-link integration;
- host-level error and session behavior.

The package should own cohesive Quote screens, deterministic view models, editors, and presentation contracts. It should not become a second application shell or own authorization decisions.

Existing shared UI primitives such as the grid and card surfaces are web-private, so #1425 needs an explicit boundary decision: promote appropriate primitives to a shared package or keep thin web-owned adapters instead of duplicating them.

The current client-detail page is already a large orchestration hotspot. The Quote host should remain thin and should not add Quote state machines or domain mapping directly to that page.

The epic describes a substantially wider Quote landing table than #1425. Treating #1425's narrower seven-column list as authoritative is preferable for viewport usability and request cost, while keeping financial and outcome metrics in Quote detail and Step 4. The parent epic should be updated or the product decision explicitly confirmed to remove ambiguity.

## Recommended sequencing and preparation

1. Resolve the foundation decisions above and implement #1421.
2. While #1421 is underway, prepare #1422's complete endpoint-policy matrix and adjacent-route inventory without coding against unstable contracts.
3. Implement #1422 after permission and shared capability contracts are stable.
4. Start #1423 only after revision, lifecycle action, and authorization contracts are settled.
5. Prepare pure eligibility/workbook extraction designs early, but implement #1424 only against stable schema and event contracts.
6. Implement #1425 after effective-action, API, artifact, and processing contracts stabilize.
7. Keep final workbook business acceptance tied to #819's UAT/reference evidence.

Issues #1422, #1423, and #1424 are each large enough that stacked pull requests may be useful within an issue, provided every intermediate contract remains deployable and the issue boundaries are preserved.

## Readiness conclusion

The proposal is architecturally sound and the five issues cover the intended delivery. The highest-value preparation before assignment is to settle:

1. state and proforma transition ownership;
2. immutable row/snapshot revision strategy;
3. failure and retry ownership;
4. complete configuration snapshots;
5. validation and Eligibility Runs permissions;
6. sensitive-data and workbook field allowlists;
7. exact plan-scope drift behavior.

Once those are explicit in #1421/#1420, the slices can be implemented without avoidable schema churn or cross-layer ambiguity.
