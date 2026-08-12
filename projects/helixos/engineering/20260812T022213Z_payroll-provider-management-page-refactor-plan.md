# Payroll Provider Management Page Refactor Plan

Status: ready for implementation planning and assignment

Source repository: `C:\dev\HelixOS`

Primary production file:
`src/web/src/features/utilities/payroll-providers/PayrollProviderManagementPage.tsx`

Primary existing test file:
`src/web/src/features/utilities/payroll-providers/PayrollProviderManagementPage.test.tsx`

## Purpose

Refactor Payroll Provider Management into cohesive, testable modules without
changing its API contract, database behavior, authorization boundary, user
workflow, visual design, or payroll-provider configuration semantics.

The existing page works, but it combines too many responsibilities in one
React module. That makes state ownership difficult to reason about, has already
produced hydration and provider-switching bugs, forces deterministic logic
through an expensive component harness, and makes small changes costly to
review.

This plan is intentionally an architectural refactor, not a mechanical file
split. Moving the current page wholesale into a large hook or distributing JSX
among arbitrary files does not satisfy the plan.

## Current Baseline

At the time this plan was written:

- `PayrollProviderManagementPage.tsx` is approximately 2,746 lines.
- The root `PayrollProviderManagementPage` function spans approximately 1,377
  lines.
- The page owns approximately 21 independent `useState` values.
- It uses four dependency-driven `useMountEffect` calls even though the
  repository instruction defines `useMountEffect` as mount-only.
- It uses refs and identity/fingerprint guards to coordinate query hydration,
  selected-provider state, validation, and mutation completion.
- It contains React presentation, TanStack Query calls, cache mutation, request
  payload construction, readiness calculation, validation, JSON parsing,
  column editing, client-input editing, CSV parsing, and XLSX parsing.
- Its component test file is approximately 1,140 lines and has recently taken
  roughly 73-74 seconds on a GitHub-hosted runner.
- The feature directory contains only the page and its component test.

Re-measure the baseline at the implementation branch's starting commit. The
numbers above describe the design problem but are not substitutes for an
exact-head baseline.

## Required Outcome

The completed refactor must produce this dependency direction:

```text
PayrollProviderManagementPage
  -> provider list query and selected public provider key
  -> keyed provider-detail loader
      -> PayrollProviderEditor
          -> focused query/mutation adapter
          -> one cohesive editor state model/reducer
          -> focused tab and dialog components
              -> pure model, validation, import, and payload modules
                  -> shared payroll-provider config contract
```

The page should become a thin orchestration boundary. Deterministic operations
must be testable without rendering React, loading MUI, starting TanStack Query,
or initializing MSW.

The final implementation must have:

- one authoritative persisted provider record from TanStack Query;
- one authoritative local editor state for the selected provider;
- a keyed editor boundary for provider changes;
- no dependency-driven `useMountEffect` in this feature;
- no refs used to repair stale mutation closures or hydration ordering;
- mutations that receive an immutable snapshot containing the exact target
  provider public key and payload;
- pure, dependency-light tests for transformations, validation helpers,
  readiness derivation, payload construction, JSON application, and file
  inference;
- component tests reserved for representative UI wiring and interactions;
- unchanged server-side validation and authorization as the authoritative
  production boundary;
- materially improved hosted component-test time without reducing behavioral
  coverage.

## Non-Goals

Do not include any of the following unless a newly discovered correctness bug
requires a separately approved scope change:

- database schema or migration changes;
- API route or response-contract changes;
- payroll export renderer changes;
- provider seed-catalog changes;
- new provider capabilities or configuration fields;
- visual redesign, theme changes, or new navigation;
- replacement of MUI, TanStack Query, Vitest, Testing Library, or MSW;
- changes to who may access the PlatformAdmin utility;
- broad refactoring of the API payroll-provider service;
- broad repair of the shared `useMountEffect` helper or unrelated callers;
- removal of Advanced JSON;
- changes to schema-version compatibility;
- changes to save, validation, preview, or publish semantics.

If the refactor exposes an existing product defect, first add a regression test
that demonstrates the current failure. Fix it in a small, explicitly described
commit or separate PR rather than hiding the behavior change inside a move.

## Behavior That Must Be Preserved

Build a traceability checklist from the existing component tests before moving
code. At minimum, preserve:

- administrative branding and no user-facing vendor leakage;
- required-field indicators;
- extractor-only provider behavior;
- switching between import-enabled and extractor-only modes;
- provider selection through search and the provider drawer;
- delayed authoritative detail hydration;
- CSV and XLSX field behavior, including real tab delimiters;
- provider and import-config save behavior;
- preservation of unsaved config edits during provider-only changes;
- client/employee source-path filtering;
- expressions, conditional sources, client inputs, and row rules;
- preview requests and preview error handling;
- Advanced JSON apply, reset, validation, and schema upgrade;
- draft publishing;
- provider creation and provider-code normalization;
- load, validation, mutation, and success feedback;
- prevention of provider switching while save or publish is pending;
- mutation completion affecting only the provider targeted at request time;
- no import configuration being created for extractor-only providers.

Existing test names do not have to remain in the same file. Every behavior must
remain covered at the narrowest layer that owns it, with at least one component
test retained for each important UI or network seam.

## Target Module Responsibilities

Use these names unless an adjacent repository convention provides a clearer
equivalent. Do not collapse the responsibilities back into one large module.

| Module | Single responsibility |
| --- | --- |
| `payroll-provider-types.ts` | Web-facing API records, response types, provider draft types, and shared type aliases derived from `@helixos/shared`. |
| `payroll-provider-api.ts` | Query keys, endpoint construction, and typed API request functions. It contains no React state and no business decisions. |
| `payroll-provider-model.ts` | Provider draft conversion, provider-code normalization, dirty comparison, capability UX validation, and create/update payload construction. |
| `payroll-provider-config-model.ts` | Default config creation, immutable column/client-input operations, ordinal normalization, fingerprints, readiness/display selectors, and save validation composition. |
| `payroll-provider-config-json.ts` | Parse, shape validation, error description, normalization, and formatting for Advanced JSON. |
| `payroll-provider-example-file.ts` | Browser-side CSV/XLSX sample inspection and inferred config construction. It imports no React or UI libraries. |
| `payroll-provider-editor-state.ts` | Pure reducer/state transitions and selectors for one selected provider editor. It performs no I/O. |
| `PayrollProviderManagementPage.tsx` | Load provider summaries, own the selected public provider key, and render loading/error/detail boundaries. |
| `PayrollProviderDetailLoader.tsx` | Load authoritative detail for one provider key and mount a keyed editor only after authoritative detail is available. |
| `PayrollProviderEditor.tsx` | Coordinate the reducer, focused mutations, toolbar, tabs, and dialogs for one provider. Do not put tab markup or pure domain logic here. |
| `PayrollProviderToolbar.tsx` | Provider selection, readiness label, Save, Publish, and browse-provider affordances. |
| `ProviderOverviewTab.tsx` | Provider identity and capability fields only. |
| `ImportFormatTab.tsx` | File-format fields only. |
| `ColumnsEditor.tsx` | Column list, selection, reorder, delete confirmation trigger, and column-detail composition. |
| `RowRulesEditor.tsx` | Row-mode and line-item rule controls only. |
| `ClientInputsEditor.tsx` | Client-input list, selection, editing, and removal controls only. |
| `PayrollProviderPreview.tsx` | Preview query and preview rendering only. |
| `AdvancedConfigJsonEditor.tsx` | Raw JSON text editing, Reset, Apply, and local parse-error presentation only. |
| `NewPayrollProviderDialog.tsx` | New-provider draft lifecycle and create submission UI only. |
| `PayrollProviderDrawer.tsx` | All-provider status table and provider selection only. |

Small field primitives such as source-path selectors can remain shared inside
the feature, but each file must have a coherent reason to change. Do not create
one file per trivial component.

## State Ownership Contract

### Page state

`PayrollProviderManagementPage` may own only:

- the selected provider public key;
- provider-list query state.

Do not use an effect to select the first provider. Derive the effective key:

```ts
const effectiveProviderId = selectedProviderId
  ?? providersQuery.data?.items[0]?.id
  ?? null;
```

If a selected key is no longer present after a refetch, derive a safe existing
selection during render or handle it at the explicit selection/query boundary.
Do not build a dependency effect to synchronize it.

### Provider editor state

Mount the editor only from authoritative detail data:

```tsx
<PayrollProviderEditor
  key={provider.id}
  initialProvider={provider}
  providerSummaries={providers}
  onSelectProvider={setSelectedProviderId}
/>
```

Changing the provider key creates a fresh editor. The editor must not reset
itself by watching `provider.id`, `updatedAt`, config IDs, or query results.

Use one pure reducer for coordinated editable state. Its initial state should
contain, at minimum:

- provider draft;
- import config draft;
- persisted baseline/fingerprint;
- sample source name;
- Advanced JSON draft text;
- active tab;
- selected column and client-input indexes;
- validation summary and action feedback that truly belong to the editor;
- pending replacement-file and deletion-dialog context if they participate in
  coordinated transitions.

Reducer actions must update related representations atomically. For example,
applying a config change must update the canonical config, normalized ordinals,
JSON representation, dirty/readiness state, and valid selection indexes in one
transition. Do not use an effect to make a second state variable catch up.

Keep transient state inside the narrowest component when it is not part of the
coordinated editor model. Examples include whether the provider drawer is open
or the current raw text in a self-contained dialog, provided closing that
component intentionally ends that draft lifecycle.

### Server state

TanStack Query owns server records. Local editor state is a deliberate draft,
not a second cache.

After a successful mutation:

1. use the mutation variables/result's target provider key;
2. update or invalidate only that provider's query and the provider summary
   list;
3. dispatch one explicit reducer action with the saved result when the keyed
   editor still exists;
4. never read the currently selected provider to discover which cache record
   to update;
5. never use a ref to determine the mutation's original target.

Provider selection remains disabled while save or publish is pending. This is
a UX constraint, not the correctness mechanism; target-captured mutation input
must still make completion safe.

## Testing Strategy

### Pure module tests

Add adjacent tests for each extracted owner. These tests must not call
`renderWithProviders`, create a QueryClient, initialize MSW, or import MUI.

Minimum cases:

#### `payroll-provider-model.test.ts`

- provider record to draft conversion;
- provider-code normalization while typing and final trimming;
- create and update payload construction;
- dirty and clean provider comparisons;
- capability validation, including extractor-only and Router push without
  file generation.

#### `payroll-provider-config-model.test.ts`

- default config;
- stable fingerprinting independent of object-key order;
- schema-version normalization;
- contiguous ordinal normalization;
- add, edit, remove, and move column transitions;
- unique generated column and client-input keys;
- selected-index clamping after removal;
- client-input type transition and option parsing;
- dirty, saved, validation-current, publishable, and readiness selectors;
- validation error de-duplication;
- no config-save requirement for extractor-only providers.

Do not duplicate the shared contract's exhaustive validation suite. Test only
the web authoring composition and messages owned by this feature; rely on
`@helixos/shared` tests for canonical source, expression, schema, and runtime
rules.

#### `payroll-provider-config-json.test.ts`

- valid version 1 and current-version JSON;
- malformed JSON;
- missing file, rows, or columns;
- malformed client inputs and option entries;
- normalization after apply;
- useful path-specific error messages;
- reset/format behavior.

#### `payroll-provider-example-file.test.ts`

- comma, tab, and pipe detection;
- quoted delimiters and escaped quotes;
- empty files;
- header and non-header inference;
- duplicate/blank header key generation;
- CSV inferred config;
- XLSX first-sheet name and header inference;
- workbook with no worksheet.

Use tiny in-memory fixtures. Do not check in large workbook binaries. Avoid
serializing/reparsing the same workbook separately for every assertion.

#### `payroll-provider-editor-state.test.ts`

- initialization from active config, draft config, and no config;
- draft preferred over active config;
- all coordinated state changes happen in one reducer transition;
- unsaved config edits survive provider-metadata edits;
- config changes clear stale validation/readiness appropriately;
- a saved result advances the persisted baseline without losing later edits;
- publish completion updates published state;
- selection indexes stay valid;
- provider switching is represented by remount/initialization, not a reducer
  hydration action.

### Component tests

Retain component tests only where React or a network seam is the behavior under
test:

- list loading and error states;
- delayed provider detail prevents editing/saving stale summary data;
- selecting a provider mounts a fresh keyed editor;
- Save submits the correct provider and config payloads;
- Publish submits the saved draft key for the correct provider;
- provider selection is disabled during pending mutations;
- save/publish failures and success feedback are visible;
- extractor-only mode hides configuration tabs and does not post config;
- representative editing in each tab wires controls to the reducer;
- Preview sends current config and renders server output;
- Advanced JSON Apply and Reset wire to the state model;
- example-file replace confirmation wires to the import module;
- direct accessible labels, delete confirmation, drag/drop wiring, and provider
  drawer selection remain intact.

Move exhaustive permutations and long interaction sequences to pure tests.
Keep at least one representative full save workflow through the rendered page.

MSW list and detail fixtures must remain distinct. The list response must not
accidentally contain detail-only `configs`, because that previously masked a
real hydration defect.

### Performance measurement

Capture:

- focused local wall time before the first change;
- focused local wall time after each PR;
- exact-head hosted file time from the `web-unit-timing` artifact;
- full web-unit job time so cost is not merely shifted to another file.

The target is:

- all behavioral cases retained with zero skips;
- the hosted Payroll Provider component suite at or below 45 seconds, or at
  least 30% faster than the remeasured baseline;
- no material regression in full web-unit wall time or peak memory.

If the target is missed, inspect setup, collection, imports, and test/hook time
before changing timeouts or concurrency. Do not claim improvement from local
timing alone.

## Pull Request Order

Implement the refactor as four small, ordered pull requests. Each PR must be
independently green and behavior-preserving. A later PR starts from the merged
head of the preceding PR.

### PR 1: Extract Contracts, Pure Models, And File Inference

Goal: move deterministic logic out of the TSX file and establish fast direct
tests without changing component or state behavior.

#### Step 1: Establish baseline and traceability

1. Create a clean worktree and non-main branch from current `origin/main`.
2. Record start time as required by repository instructions.
3. Confirm no unrelated worktree changes.
4. Run the focused existing component suite and record elapsed time.
5. Create a behavior-to-test traceability table in the PR description or a
   temporary working note.
6. Record the current count of dependent `useMountEffect`, state variables,
   refs, and production/test lines for later comparison.

Suggested focused command:

```powershell
npm run build:packages
npm exec --workspace @helixos/web -- vitest run src/features/utilities/payroll-providers/PayrollProviderManagementPage.test.tsx
```

Do not weaken or delete a failing baseline test. Record any pre-existing
failure before proceeding.

#### Step 2: Use the shared config type

Replace the page's hand-maintained duplicate import-config interfaces with
type aliases derived from `PayrollProviderImportConfig` exported by
`@helixos/shared`.

Examples:

```ts
type PayrollProviderImportConfigBody = PayrollProviderImportConfig;
type PayrollProviderColumn = PayrollProviderImportConfig["columns"][number];
type PayrollProviderColumnSource = PayrollProviderColumn["source"];
type PayrollProviderClientInput = NonNullable<PayrollProviderImportConfig["clientInputs"]>[number];
```

Keep web/API record types in `payroll-provider-types.ts`. Do not move HTTP
response records into the shared package unless another application already
needs them.

#### Step 3: Extract provider and config models

Move the deterministic functions listed in the target architecture into
focused modules. Export explicit functions with explicit return types.

Do not import React, MUI, TanStack Query, `apiRequestWithoutTenantContext`, or
browser globals into these model modules.

Build payload objects in pure functions. Create and update should share one
mapping function for common fields rather than repeat the field list.

#### Step 4: Extract Advanced JSON behavior

Create a parse result contract such as:

```ts
type ParseConfigJsonResult =
  | { ok: true; config: PayrollProviderImportConfig }
  | { ok: false; message: string };
```

Use the shared schema/authoring validator where possible. Retain web-owned
friendly errors only where they improve the editor experience.

#### Step 5: Extract example-file inference

Move CSV/XLSX inspection into `payroll-provider-example-file.ts`.

The module may depend on `File` and dynamically import `exceljs`, but it must
not depend on React. Keep parsing in the browser for this refactor because it
only infers an editable configuration; it does not process or persist the
payroll file as authoritative server work.

#### Step 6: Add direct tests and narrow component cases

Add the pure tests. Move only assertions whose behavior is now completely
owned by a pure module. Retain a representative component assertion for the UI
boundary.

Do not rewrite the component architecture in PR 1.

#### PR 1 completion gate

- All extracted functions have direct tests.
- The existing component suite remains green.
- The page no longer declares duplicate shared config types.
- Payload mapping is not duplicated.
- Pure modules have no React/query/UI imports.
- No behavior, API, or visual contract changed.
- Documentation records the new internal module ownership.

Suggested commits:

1. `refactor(payroll): extract provider authoring models`
2. `refactor(payroll): isolate example config inference`
3. `test(payroll): cover provider authoring logic directly`

### PR 2: Extract Cohesive UI Components

Goal: split presentation by workflow responsibility while preserving the
existing state owner temporarily.

#### Step 1: Extract stable primitives and status presentation

Move status icons, readiness panel, field primitives, and provider drawer into
cohesive component files. Avoid a generic `components.tsx` dumping ground.

#### Step 2: Extract one tab at a time

Recommended order:

1. Import Format
2. Row Rules
3. Client Inputs
4. Columns
5. Preview
6. Advanced JSON
7. Overview

After each tab extraction:

- run its focused component cases;
- inspect the prop contract;
- ensure the component receives domain-shaped values and callbacks rather
  than the entire parent state object;
- commit the coherent extraction.

Prefer callbacks such as `onConfigChange(nextConfig)` or a small action
contract over passing every setter. Do not introduce a context solely to avoid
props, and do not hide the existing state orchestration inside a new giant
hook.

#### Step 3: Extract dialogs

Move New Provider, Replace Config, Delete Column, and provider browsing into
focused components. Each dialog should own its purely local open/close draft
state when practical and report an explicit result to the editor.

#### PR 2 completion gate

- Each extracted component has one identifiable workflow responsibility.
- No component receives an unbounded bag of unrelated props.
- No domain validation or request construction is added to presentation files.
- No new effect, ref synchronization, or controller hook is introduced.
- The root function is materially smaller and reads as orchestration rather
  than full-screen markup.
- Layout, labels, tab order, and accessible names are unchanged.
- Focused and full feature tests remain green.

Suggested commits:

1. `refactor(payroll): extract provider status surfaces`
2. `refactor(payroll): extract import configuration tabs`
3. `refactor(payroll): extract provider management dialogs`

### PR 3: Replace Hydration Choreography With A Keyed Editor State Model

Goal: correct state ownership, remove synchronization effects/refs, and make
mutation completion target-safe by construction.

This is the highest-risk PR. Do not combine it with visual changes.

#### Step 1: Add the pure editor reducer first

Implement `createPayrollProviderEditorState`, the reducer, actions, and
selectors. Write reducer tests before wiring React.

Actions should represent user or network events, not setters. Examples:

- `providerDraftChanged`
- `fileGenerationToggled`
- `configReplaced`
- `columnChanged`
- `columnsReordered`
- `clientInputChanged`
- `jsonDraftChanged`
- `jsonApplied`
- `saveSucceeded`
- `validationSucceeded`
- `publishSucceeded`
- `feedbackCleared`

Do not add a generic `{ type: "setField", key, value }` action that discards
domain meaning.

#### Step 2: Introduce the detail-loader/key boundary

The page must not render an editable provider from list-summary data. Load the
authoritative detail, then mount the keyed editor. Show a controlled loading
surface during the detail request.

Delete configuration hydration keys, identity refs, selection-validation
refs, selected-provider refs, and all dependency-driven effects from this
feature once the keyed model is active.

#### Step 3: Extract the typed API adapter

Move endpoints and request functions into `payroll-provider-api.ts`.

Define immutable mutation input types. For example:

```ts
interface SavePayrollProviderInput {
  providerId: string;
  providerPayload: UpdatePayrollProviderPayload | null;
  configPayload: SavePayrollImportConfigPayload | null;
}
```

The mutation function must use only its input. It must not close over the
current provider, config draft, sample name, or selected key.

Publish input must contain both `providerId` and `configId`.

#### Step 4: Reconcile saved results explicitly

On save success:

- update/invalidate cache keys from `variables.providerId` or the returned
  target provider ID;
- dispatch `saveSucceeded` with the returned records;
- advance the persisted baseline only for the state that was actually saved;
- preserve edits made after the mutation snapshot was submitted;
- do not replace the entire editor state with the response if later edits
  exist.

Add a reducer test for this exact race:

1. edit config A;
2. submit save snapshot A;
3. edit config B while save is pending;
4. receive success for snapshot A;
5. config B remains visible and dirty relative to the newly saved A baseline.

The UI currently locks provider selection during mutations, but field-editing
behavior during the request must be explicitly tested and either safely
supported or deliberately disabled with a clear UI contract.

#### Step 5: Make validation event-driven

Do not validate through an effect watching persisted identity.

Run validation as an explicit continuation of Save or an explicit user action,
using the exact saved provider/config snapshot. Apply the result through a
reducer action only if it still corresponds to the relevant persisted
baseline.

#### Step 6: Remove legacy orchestration

Delete:

- the four dependency-driven `useMountEffect` calls;
- hydration key and identity refs;
- selected-provider ref;
- effect-driven provider draft copying;
- parallel setter choreography now owned by reducer transitions;
- cache merging that derives its target from the current render.

Do not leave dead compatibility code “just in case.”

#### PR 3 completion gate

- Zero `useMountEffect` or `useEffect` calls in the payroll-provider feature.
- Zero refs used for hydration or stale mutation selection.
- Provider switching creates a fresh keyed editor.
- List-summary data cannot initialize editable config state.
- All mutation inputs capture target IDs and payload snapshots.
- Save/publish completion cannot update the wrong provider.
- Edits cannot be silently wiped by refetch, focus changes, provider-only
  saves, or mutation completion.
- Reducer and race-condition tests pass.
- Representative full component workflows pass.

Suggested commits:

1. `refactor(payroll): add provider editor state model`
2. `refactor(payroll): key editor state to provider detail`
3. `refactor(payroll): make provider mutations target safe`
4. `test(payroll): cover editor hydration and mutation races`

### PR 4: Finalize Test Placement, Performance, And Maintainer Guidance

Goal: ensure the architecture produces a durable maintenance and CI benefit.

#### Step 1: Audit responsibility and size

Inspect every feature file and public function. File size is a review signal,
not the objective, but the expected steady state is:

- page/loader files small enough to understand without scrolling through
  workflow implementation;
- editor orchestration normally under approximately 300-350 lines;
- tab components normally under approximately 250-300 lines;
- pure functions normally under 50 lines unless one cohesive parser benefits
  from remaining together;
- no replacement god hook or “utils” module.

Document any intentional exception and its single responsibility.

#### Step 2: Complete test redistribution

Use the traceability checklist to confirm every original behavior still has an
owner and test. Remove duplicate expensive component arrangements only after
the narrower test exists and a representative boundary test remains.

Create reusable typed fixture factories instead of large mutable records
duplicated across test files. Keep list and detail fixtures semantically
different.

#### Step 3: Measure hosted improvement

Run the complete web validation and push. Use the exact-head timing artifact to
compare:

- component test/hook time;
- environment/setup/collection time;
- expensive processed-module imports;
- complete web-unit command time;
- failures, skips, and test counts by owner.

Do not increase timeouts, skip tests, reduce realistic boundary coverage, or
claim success from a faster local workstation run.

#### Step 4: Update documentation

Update `docs/payroll-provider-management.md` with a concise maintainer section:

- module responsibility map;
- editor state ownership and keyed remount behavior;
- server state versus local draft state;
- where to add validation and transformations;
- where each kind of test belongs;
- explicit instruction not to reintroduce dependency-driven hydration effects.

If repository-wide agent/reviewer instructions are changed separately, link
the new guidance, but do not make this refactor PR depend on that broader
governance work.

#### PR 4 completion gate

- Test traceability is complete with no skipped coverage.
- Hosted feature timing meets the stated target or has a documented,
  evidence-backed explanation and follow-up.
- Full web-unit timing does not materially regress.
- Documentation describes the new architecture and testing rules.
- Self-review finds no mixed-responsibility hotspot, synchronization effect,
  stale target closure, duplicated policy, or UI-only production rule.
- PR description contains before/after architecture, metrics, test evidence,
  and explicit confirmation of unchanged behavior.

Suggested commits:

1. `test(payroll): right-size provider component coverage`
2. `docs(payroll): document provider editor architecture`

## Validation Commands

Run focused tests after each coherent slice. Before review, run without a local
timeout:

```powershell
npm run build:packages
npm exec --workspace @helixos/web -- vitest run src/features/utilities/payroll-providers
npm run lint -w @helixos/web
npm run theme:check -w @helixos/web
npm run test -w @helixos/web
npm run build -w @helixos/web
```

If a PR changes the shared package despite the non-goal, also run:

```powershell
npm run test -w @helixos/shared
npm run build -w @helixos/shared
```

If a PR changes an API contract despite the non-goal, stop and confirm the
expanded scope first. Then run the API tests, build, OpenAPI generation, and
OpenAPI checks required by repository instructions.

## Manual UAT

Perform this on the final composed branch before the last PR is marked ready:

1. Open Admin Console -> Payroll Provider Management as PlatformAdmin.
2. Select an import-enabled provider with an active config.
3. Edit provider notes and one config field; Save and confirm both persist.
4. Edit config, save provider metadata, and confirm the unsaved config edit is
   not lost.
5. Switch providers and confirm the new provider never displays the previous
   provider's draft or config.
6. Switch back and confirm authoritative saved data is loaded.
7. Configure CSV with comma, tab, and pipe delimiters.
8. Configure XLSX and verify sheet-name validation.
9. Add, edit, reorder, and delete columns.
10. Add and remove client inputs, including select options.
11. Edit row rules and inspect Preview.
12. Upload a small CSV and XLSX example and confirm inferred columns.
13. Replace an existing config from an example and exercise Cancel and
    Replace.
14. Apply valid and invalid Advanced JSON; exercise Reset.
15. Save an invalid draft and verify useful validation feedback.
16. Publish a valid draft and confirm readiness refreshes.
17. While save/publish is pending, confirm provider selection is locked and no
    wrong-provider feedback appears.
18. Select an extractor-only provider and confirm config tabs and config POSTs
    remain absent.
19. Create a disabled provider and confirm provider-code normalization.
20. Refresh the page and confirm the persisted provider/config state is
    authoritative.

## Self-Review Checklist

The implementing engineer and PR reviewer must explicitly inspect for:

- a module with more than one unrelated reason to change;
- a large component replaced by a large hook;
- query or prop data mirrored into local state by an effect;
- `useMountEffect` used with dependencies;
- fingerprints, refs, or guards compensating for unclear state ownership;
- mutations closing over selected records instead of receiving target IDs;
- cache updates targeting the current selection rather than mutation input;
- more than one authoritative representation of provider/config state;
- duplicated provider payload field mapping;
- duplicated shared config validation;
- client-side rules presented as authoritative server enforcement;
- exhaustive deterministic cases exercised through full React rendering;
- list mocks containing detail-only fields;
- arbitrary sleeps, increased timeouts, skipped tests, or reduced assertions;
- new generic `utils`, `helpers`, or controller modules accumulating unrelated
  behavior;
- visual or behavior changes hidden inside extraction commits.

Repeated findings involving hydration, switching records, overwritten edits,
stale data, or mutation timing must be treated as one state-ownership defect.
Do not resolve the class by adding another effect, ref, identity key, or guard.

## PR Description Evidence

Every PR should include:

- scope and explicit non-goals;
- responsibility table for added/moved modules;
- before/after dependency or state-flow diagram;
- behavioral traceability affected by that PR;
- focused and complete validation results;
- local timing as directional evidence;
- exact-head hosted timing when performance is claimed;
- line/state/effect/ref counts where relevant;
- any intentional SOLID or size exception and its tradeoff;
- confirmation that API, authorization, persistence, and UI behavior remain
  unchanged.

## Definition Of Done

This initiative is complete only when:

- the page is a thin provider-list/selection boundary;
- authoritative detail loads before an editor can save;
- provider changes reset state through a keyed editor remount;
- one cohesive reducer owns coordinated draft state;
- no synchronization effect or hydration ref remains in the feature;
- save, validate, preview, and publish use immutable target snapshots;
- deterministic logic is covered by direct dependency-light tests;
- component tests cover UI/network seams without repeating long workflows for
  every calculation;
- all original behavior remains covered and no tests are skipped;
- server validation, authorization, and persistence contracts are unchanged;
- hosted component and full web-unit timing satisfy the performance gate;
- maintainer documentation explains how to extend the feature without
  recreating the original anti-patterns;
- a thorough self-review and external PR review report no actionable
  architecture, correctness, test-placement, or maintainability findings.
