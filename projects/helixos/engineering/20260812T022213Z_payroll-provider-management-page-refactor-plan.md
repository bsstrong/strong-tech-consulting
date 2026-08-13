# Payroll Provider Management Page Refactor Plan

## 1. Plan metadata

- **Status:** Ready for implementation
- **Plan type:** Refactor; secondary remediation and test-performance work
- **Intended implementer:** Junior/associate engineer, with the explicit senior checkpoints identified below
- **Source repository:** `C:\dev\HelixOS`
- **Planning document:** `C:\dev\strong-tech-consulting\projects\helixos\engineering\20260812T022213Z_payroll-provider-management-page-refactor-plan.md`
- **Whole-feature local review runbook:** `C:\dev\strong-tech-consulting\projects\helixos\engineering\payroll-provider-management-stacked-pr-local-review.md`
- **Inspected HelixOS revision:** `525132ecc460f5b5122188fac45ac0ec59d9e946` (`origin/main`, inspected 2026-08-13)
- **Primary production file:** `C:\dev\HelixOS\src\web\src\features\utilities\payroll-providers\PayrollProviderManagementPage.tsx`
- **Primary component test:** `C:\dev\HelixOS\src\web\src\features\utilities\payroll-providers\PayrollProviderManagementPage.test.tsx`
- **Maintainer documentation:** `C:\dev\HelixOS\docs\payroll-provider-management.md`
- **Performance evidence:** `C:\dev\HelixOS\docs\operations\ci-timing-instrumentation.md`, [HelixOS PR #1116](https://github.com/helixosio/helixos/pull/1116), and its [exact-head CI run](https://github.com/helixosio/helixos/actions/runs/31705733658)
- **Governing repository guidance:** `C:\dev\HelixOS\AGENTS.md`, every mandatory instruction file named there, and `C:\dev\HelixOS\DESIGN.md`

The implementer must re-read the governing repository guidance from the execution branch before starting each pull request. Live owner-authored repository policy overrides lifecycle wording in this plan if it changes after the inspected revision.

## 2. Objective and observable outcome

Refactor Payroll Provider Management into cohesive, directly testable modules without changing its API contracts, persistence, authorization boundary, configuration semantics, visual design, or normal user workflow.

Completion is observable when:

- the page owns only the provider-list query, effective selected provider public key, and page-level create-provider workflow;
- editable state is created only from authoritative provider detail data, never list-summary data;
- changing provider keys mounts a fresh keyed editor instead of hydrating local state through effects;
- one reducer owns the coordinated provider/config editor draft and its persisted baselines;
- no `useEffect` or dependency-driven `useMountEffect` remains in this feature;
- refs are used only for imperative DOM access, not hydration, identity, mutation targeting, or state synchronization;
- every save, validation, preview, and publish request receives an immutable target-and-payload snapshot;
- a save completion advances saved baselines without overwriting edits made after submission;
- deterministic rules continue to live in dependency-light modules and tests;
- component tests prove representative React, accessibility, and network seams without re-testing pure permutations through the full MUI/Query/MSW harness;
- current exact-head hosted performance meets the final gate in this plan; and
- `docs/payroll-provider-management.md` explains the resulting ownership and extension rules.

This is an architectural refactor, not a file-count exercise. Moving the existing component wholesale into a large hook, service, controller, reducer, or generic helper file does not satisfy the outcome.

## 3. Scope

### In scope

- cohesive UI component extraction within the payroll-provider feature;
- a focused API/query-key module for the existing endpoints;
- a keyed provider-detail/editor lifecycle;
- a pure reducer and selectors for coordinated editable state;
- target-safe create, save, validation, preview, and publish inputs;
- cache writes and invalidation keyed from mutation variables/results;
- explicit reconciliation of saved baselines with edits made while save is pending;
- component-test redistribution and representative new race/seam coverage;
- exact-head local and hosted timing evidence;
- a Draft stacked-branch integration tip that passes the complete automated suite and visual UAT before any remaining PR is promoted to Ready;
- incremental maintainer-documentation updates.

### Explicit non-goals

- database schema, seed, or migration changes;
- API route, request, response, or OpenAPI contract changes;
- API payroll-provider service refactoring;
- authorization, role, permission, or identity-population changes;
- payroll export renderer or file-extractor behavior changes;
- provider catalog or configuration-field additions;
- schema-version compatibility changes;
- save, validation, preview, or publish business-semantics changes;
- visual redesign, new navigation, raw theme literals, or theme-token changes;
- replacement of MUI, TanStack Query, Vitest, Testing Library, MSW, or ExcelJS;
- removal of Advanced JSON;
- broad changes to the shared `useMountEffect` helper or unrelated callers.

If implementation appears to require any non-goal, stop that pull request and obtain owner/senior approval before expanding scope. Do not hide a product or API behavior change inside an extraction commit.

### Preserved safeguards

- PlatformAdmin/API authorization remains authoritative; UI gating is not a security boundary.
- The UI never initializes an editable configuration from a list summary.
- Provider selection is locked during save or publish.
- All provider-changing entry points, including autocomplete, drawer selection, and New Provider, are disabled while selected-editor save or publish is pending.
- Form fields remain editable while save is pending. Edits made after submission must survive the response and remain dirty against the new saved baseline.
- Extractor-only providers never create an import configuration.
- Existing required labels, tab order, accessible names, confirmation dialogs, error messages, and success feedback remain recognizable and equivalent.
- List and detail MSW fixtures remain structurally different.
- No client-owned plan or product branding is introduced.
- Helix-owned UI does not display the prohibited vendor name; the approved `Payroll Router` terminology remains unchanged.

## 4. Completed prerequisite: PR #1116

The original first phase is complete and must not be repeated.

- **PR:** `helixosio/helixos#1116`, “Extract payroll provider models to accelerate web tests”
- **Merged commit:** `22fe3db8e4c6915ab24eebcad579350dc933a063`
- **Exact reviewed head:** `2b50693f8b8938fb4e01c325fb6672c304bb6408`
- **Result:** five focused production modules and four direct test files were added; the page was reduced from approximately 2,746 to 2,130 lines; 24 dependency-light tests were added; all 26 component tests remained.
- **Current-main verification:** no payroll-provider feature files changed between the merged PR and inspected revision `525132ecc460f5b5122188fac45ac0ec59d9e946`.

Existing authoritative modules are:

| Existing module | Current authoritative responsibility |
| --- | --- |
| `payroll-provider-types.ts` | Web API record types and config aliases derived from `@helixos/shared`. |
| `payroll-provider-model.ts` | Provider draft conversion, code normalization, capability validation, payload construction, and saved-config list replacement. |
| `payroll-provider-config-model.ts` | Config defaults, stable fingerprints, ordinal normalization, source construction, client-input transformations, and save validation. |
| `payroll-provider-config-json.ts` | Advanced JSON parse, deep shape validation, normalization, schema upgrade, diagnostics, and formatting. |
| `payroll-provider-example-file.ts` | CSV/XLSX example parsing and inferred column/config construction. |

Extend these owners where the responsibility already fits. Do not recreate their rules in the reducer or presentation components.

## 5. Exact current-state evidence

Evidence below is measured from inspected `origin/main`.

| Evidence | Current value |
| --- | ---: |
| `PayrollProviderManagementPage.tsx` | 2,130 lines |
| Root `PayrollProviderManagementPage` function | lines 192-1537; 1,346 lines |
| `useState` calls | 19 |
| `useRef` calls | 5 |
| dependency-driven `useMountEffect` calls | 4 |
| Component test file | 1,118 lines; 26 tests |
| Direct model/parser tests | 24 tests across four files |
| Feature files | 11 |

PR #1116 performance evidence:

| Measurement | Result |
| --- | ---: |
| Focused local baseline before PR #1116 | 75.90 s wall; 70.97 s tests |
| Focused local result after PR #1116 | 44.39 s wall; 39.53 s tests; 50 total tests |
| Exact-head hosted component file | 49.4 s total; 46.5 s tests/hooks; 26 passed |
| Exact-head hosted web runner | 9m 53s |
| Exact-head hosted web-unit command | 10m 06s |

Local timing is directional. Hosted timing is the performance authority.

### Current runtime flow

1. `PayrollProviderManagementPage` queries provider summaries.
2. It selects the first summary through a dependency-driven `useMountEffect`.
3. It queries detail for the selected summary but temporarily falls back to the summary as `provider`.
4. Additional effects copy provider/config data into local state and use identity/fingerprint refs to decide whether hydration should run.
5. The same root function renders the toolbar, all tabs, dialogs, drawer, and mutation feedback.
6. Save and publish callbacks close over current render state and consult `selectedProviderIdRef` when responses complete.
7. Preview owns its own query but constructs its request directly inside the presentation file.

### Root-cause analysis

| Symptom and evidence | Root cause | Ownership failure | Planned correction |
| --- | --- | --- | --- |
| Four dependency-driven `useMountEffect` calls hydrate selection, drafts, config, and validation. | Remote records and local drafts have no explicit lifecycle boundary. | Query state and editor state both behave as authoritative state. | Derive effective selection during render and mount a keyed editor only from authoritative detail. |
| Five refs coordinate file input, hydration identities, validation, and selected provider. | Async target identity and hydration are inferred from current state after work starts. | Mutation and editor lifecycle are not captured in immutable inputs. | Retain only the file-input DOM ref; use mutation snapshots and reducer actions for all other coordination. |
| Save completion can use current selection/current closures. | Mutation inputs do not contain the complete target and payload. | Transport orchestration depends on presentation state. | Add typed request functions and `SaveProviderSetupInput`/`PublishProviderConfigInput`. |
| A 1,346-line component owns presentation, I/O, state transitions, and dialogs. | Workflow boundaries were never made explicit. | The route component has many unrelated reasons to change. | Extract named workflow components and leave orchestration in the editor. |
| 26 component tests still take 49.4 hosted seconds after pure extraction. | UI/network seams and long interactions still share one broad harness/file. | Some tests remain broader than the behavior owner. | Split focused component files after boundaries exist, keeping representative full-page coverage. |
| List-summary fallback can render before detail is authoritative. | Loading and editable lifecycles are conflated. | The detail boundary does not own editor initialization. | `PayrollProviderDetailLoader` renders loading/error until matching detail exists. |

## 6. Confirmed decisions and assumptions

### Confirmed decisions

These are implementation requirements, not choices for the implementer:

1. **Editing remains enabled during save.** Save captures a snapshot. Later edits remain visible and dirty after success.
2. **Provider identity cannot change during save/publish.** Disable autocomplete, drawer selection, and New Provider while either mutation is pending.
3. **Selection is derived without effects.** Use selected key when still present, otherwise the first list item, otherwise `null`.
4. **Provider removal fallback is explicit.** If a refetch no longer contains the selected key, render from the derived first key; do not run a synchronization effect.
5. **Detail is authoritative.** Never initialize or reinitialize the editor from list-summary fields.
6. **The editor is keyed by provider public key.** Query refetches for the same provider do not remount or overwrite local drafts.
7. **Advanced JSON is a view buffer.** Canonical config state is authoritative. Raw JSON changes affect canonical config only after successful Apply. Reducer actions update canonical config and formatted JSON atomically when form edits or Apply change config.
8. **No automatic selection-time validation effect.** Existing persisted validation/readiness displays from authoritative detail. Explicit Save or explicit Preview/Publish operations perform their existing server work using captured inputs.
9. **No new context or controller hook.** Components receive focused domain-shaped props and callbacks.
10. **No new generic `utils`, `helpers`, or `components` module.** Add only modules named for one cohesive responsibility.
11. **Partial save failure remains retryable.** Preserve local drafts, show the existing error category, invalidate only the captured target queries, and allow retry. Do not attempt a client-side rollback across the existing separate PATCH/POST endpoints.
12. **Current API calls remain sequential.** Save provider metadata first when needed, then save import config when needed, then apply the returned validation/baseline information. Do not introduce concurrency between dependent writes.
13. **Cross-component mutation locking uses TanStack Query mutation state.** Give save and publish stable mutation keys and let the page derive the New Provider disabled state with `useIsMutating`. Do not synchronize a child pending flag into page state through an effect or callback.
14. **The remaining pull requests are a true Draft stack.** PR A branches from `main`; PR B branches from PR A; PR C branches from PR B. The PR C branch is the whole-feature integration tip.
15. **Whole-feature signoff precedes Ready promotion.** Complete automated validation and visual UAT must pass against the exact PR C integration head before any PR in the remaining stack is promoted to Ready. This additional engineering gate does not replace any repository lifecycle gate.
16. **Stack updates propagate upward without rewriting reviewed history.** A PR A change is merged forward into PR B and then PR C; a PR B change is merged forward into PR C. Any new integration head invalidates the previous whole-feature signoff.

### Repository-supported assumptions

- Public provider/config `id` fields are the existing opaque API keys and remain the browser-facing identifiers.
- TanStack Query continues to own server records and cache lifecycle.
- The server remains authoritative for production validation and authorization.
- Local draft validation remains a user-feedback safeguard, not the production enforcement boundary.
- No migration, deployment configuration, secret, environment variable, infrastructure, or OpenAPI work is required.

### Pre-implementation decisions

None. If repository drift contradicts a confirmed decision, stop and request senior review rather than inventing a new design.

## 7. Requirements traceability

| Requirement | Source | Planned work | Validation |
| --- | --- | --- | --- |
| Preserve product behavior, API, persistence, authorization, branding, and visual design. | Objective, non-goals, repository guidance | PR A-C | Behavior inventory, full web validation, UAT, diff review. |
| Thin page and cohesive presentation owners. | Objective and root-cause analysis | PR A; B3 | Responsibility audit, component tests, source-size evidence. |
| Detail-only editor initialization and keyed provider lifecycle. | Confirmed decisions 3-6 | B3 | Delayed-detail, detail-error, keyed-remount, and same-provider-refetch tests. |
| One authoritative coordinated editor draft. | Objective and state model | B2-B5 | Pure reducer tests and feature-wide state/effect/ref inventory. |
| Immutable exact-target mutations and cache operations. | Confirmed decisions 1-2, 11-13 | B1, B4 | Deferred request/cache tests and query-key audit. |
| Preserve edits made after Save submission. | Confirmed decision 1 and reconciliation algorithm | B2, B4 | Mandatory A-submit/B-edit race tests. |
| No synchronization effects or coordination refs. | Objective and React repository guidance | B3-B5 | Static search plus lifecycle tests. |
| Narrow test ownership without coverage loss. | Testing standards and behavior inventory | PR A-C | Updated traceability table, zero skips, representative seam tests. |
| Hosted performance improvement without cost shifting. | PR #1116 evidence and performance objective | A5, C1-C3 | `web-unit-timing` artifact and full-command comparison. |
| Review the complete visual feature before individual signoff. | Owner direction and confirmed decisions 14-16 | C5 and stacked-PR runbook | Exact integration head/tree, full automated validation, screenshots, and complete UAT. |
| Maintainer-ready ownership documentation. | Repository documentation requirement | A5, B5, C4 | Reviewed `docs/payroll-provider-management.md`. |
| Follow current owner-authored delivery lifecycle. | HelixOS `AGENTS.md` | Every PR | PR evidence and exact-head gate records. |

## 8. Target design

### Dependency direction

```text
PayrollProviderManagementPage
  -> payroll-provider-api (list/create requests and query keys)
  -> PayrollProviderDetailLoader
       -> payroll-provider-api (detail and editor metadata queries)
       -> PayrollProviderEditor key={provider.id}
            -> payroll-provider-editor-state reducer/selectors
            -> payroll-provider-api typed mutations
            -> toolbar, tabs, dialogs, drawer
                 -> existing pure provider/config/JSON/example-file modules
                 -> @helixos/shared canonical config contract
```

Presentation may call editor callbacks. The reducer may call pure model functions. Pure models must not import React, MUI, TanStack Query, API clients, or presentation modules.

### Target module responsibility and contract map

Paths below are relative to `src/web/src/features/utilities/payroll-providers/`. Existing modules are marked **existing**; all others are **proposed**.

| Module | Owns | Public contract | Must not own | Direct evidence |
| --- | --- | --- | --- | --- |
| `payroll-provider-types.ts` (**existing**) | Browser API types and shared config aliases. | Exported types only. | Runtime logic or React state. | Typecheck/build. |
| `payroll-provider-model.ts` (**existing**) | Provider mapping, code rules, capability UX validation, provider fingerprints/payloads. | Add and use `providerDraftFingerprint` for reducer reconciliation. | I/O or UI. | Existing plus added direct tests. |
| `payroll-provider-config-model.ts` (**existing**) | Config normalization, fingerprints, immutable transformations, local save validation, readiness selectors that are purely derivable. | Focused named functions. | Network validation or UI feedback. | Existing plus added direct tests. |
| `payroll-provider-config-json.ts` (**existing**) | Parse/validate/normalize/format Advanced JSON. | Parse result/throwing API already in use. | React text-field lifecycle. | Existing tests. |
| `payroll-provider-example-file.ts` (**existing**) | CSV/XLSX inference. | `buildConfigFromExampleFile` and direct helpers. | React or persistence. | Existing tests. |
| `payroll-provider-api.ts` (**proposed**) | Query keys, endpoint construction, request functions, immutable transport input types. | `payrollProviderKeys`, list/detail/metadata/create/update/save/validate/publish/preview functions. | Business decisions, React state, cache writes, or feedback messages. | Request-function tests only if URL/body mapping is non-trivial; otherwise component MSW seam tests. |
| `payroll-provider-editor-state.ts` (**proposed**) | Initial editor state, reducer, dirty/readiness selectors, saved-baseline reconciliation. | `createPayrollProviderEditorState`, `payrollProviderEditorReducer`, selectors, action/input/result types. | Network calls, QueryClient, MUI, or timestamps. | `payroll-provider-editor-state.test.ts`. |
| `PayrollProviderManagementPage.tsx` (**existing, reduced**) | Provider list, effective selected key, page load/error, New Provider orchestration. | Default exported page component remains unchanged for callers. | Provider draft/config/editor state or tab markup. | Full-page loading, selection, creation tests. |
| `PayrollProviderDetailLoader.tsx` (**proposed**) | Matching detail and metadata queries; loading/error boundary; keyed editor mount. | `{ providerId, providerSummaries, onSelectProvider }`. | Editable state, payload construction, or child-to-parent pending-state synchronization. | Delayed detail/error/keyed-remount tests. |
| `PayrollProviderEditor.tsx` (**proposed**) | One provider reducer instance, mutation hooks, workflow callbacks, tab/dialog composition. | `initialProvider`, metadata, summaries, selection callback, lock callback. | Large tab markup or pure config rules. | Representative save/publish/race tests. |
| `PayrollProviderToolbar.tsx` (**proposed**) | Provider selector, readiness/status display, Save/Publish/browse actions. | Cohesive `selection`, `status`, and `actions` prop groups. | Query/mutation creation or draft mutation. | Focused accessibility/lock tests. |
| `PayrollProviderDrawer.tsx` (**proposed**) | All-provider status table and selection. | Items, selected ID, disabled, close/select callbacks. | Query state or editor draft. | Drawer selection/disabled tests. |
| `ProviderOverviewTab.tsx` (**proposed**) | Provider identity and capability fields. | Provider draft and `onDraftChange`. | Provider payload construction or server validation. | Required fields/capability wiring. |
| `ImportFormatTab.tsx` (**proposed**) | File-format fields and example-file trigger. | Config file section, sample name, focused change/file callbacks. | CSV/XLSX parsing. | XLSX/CSV visibility and upload wiring. |
| `ColumnsEditor.tsx` (**proposed**) | Column list, selection, reorder, delete confirmation, detail composition. | Columns, selected index, source metadata, focused callbacks. | Canonical normalization or API calls. | Edit/reorder/delete/accessibility tests. |
| `RowRulesEditor.tsx` (**proposed**) | Row mode and line-item rule controls. | Row config and `onRowsChange`. | Preview query or whole-config ownership. | Representative row-rule test. |
| `ClientInputsEditor.tsx` (**proposed**) | Client-input selection and editing. | Inputs, selected index, focused callbacks. | Config-wide validation or source-path queries. | Add/edit/type/options/remove tests. |
| `PayrollProviderPreview.tsx` (**proposed**) | Preview request lifecycle and result table. | Provider ID, immutable config snapshot, enabled. | Editor state mutation. | Request/error/truncated/empty tests. |
| `AdvancedConfigJsonEditor.tsx` (**proposed**) | Raw JSON buffer controls and local parse-error presentation. | Text/error and change/reset/apply callbacks. | Parsing or canonical config mutation. | Apply/Reset wiring test; parser permutations remain direct. |
| `NewPayrollProviderDialog.tsx` (**proposed**) | New-provider draft lifecycle and accessible form. | Open/disabled/submitting/error and async submit/close callbacks. | Query cache writes. | Focus/tab order/normalization/submit test. |

Create `PayrollProviderFields.tsx` for the existing `HelpLabel`, source selectors, labeled select, and extractor autocomplete primitives because they all own reusable payroll-provider form-field presentation. Do not put status panels, workflows, state, or API logic in that file.

### State model

Use this state shape. Type aliases may reuse existing exported record types, but the listed responsibilities may not be combined, omitted, or moved into refs.

```ts
interface PayrollProviderEditorState {
  providerDraft: ProviderDraft;
  configDraft: PayrollProviderImportConfigBody;
  sampleSourceName: string;
  baseline: {
    providerDraft: ProviderDraft;
    configRecord: PayrollProviderImportConfigRecord | null;
  };
  validation: {
    summary: { errors?: string[]; warnings?: string[] } | null;
    validatedFingerprint: string | null;
  };
  json: {
    text: string;
    error: string | null;
  };
  activeTab: number;
  selectedColumnIndex: number;
  selectedClientInputIndex: number;
  saveDraftValidationErrors: string[];
  exampleFileError: string | null;
  actionSuccessMessage: string | null;
  hideProviderReadiness: boolean;
}
```

Keep these transient concerns outside the reducer unless implementation proves they participate in coordinated transitions:

- file-input DOM ref;
- drawer/dialog open state;
- dragged column index;
- delete-column target;
- pending replacement file.

They belong in the narrowest component that owns their lifecycle. Do not use them as shadow copies of provider/config state.

### Required reducer actions

Use domain-event actions, not generic `setField` actions:

- `providerDraftChanged`
- `payrollFileGenerationChanged`
- `configChanged`
- `exampleConfigApplied`
- `sampleSourceNameChanged`
- `jsonTextChanged`
- `jsonApplySucceeded`
- `jsonApplyFailed`
- `jsonReset`
- `activeTabChanged`
- `selectedColumnChanged`
- `selectedClientInputChanged`
- `localSaveValidationFailed`
- `saveStarted` only if pending snapshot belongs in reducer; otherwise mutation state remains in TanStack Query
- `saveSucceeded`
- `saveFailed`
- `publishSucceeded`
- `feedbackCleared`

Config-changing actions must normalize ordinals, clamp selected indexes, clear stale validation/readiness, and regenerate formatted JSON in the same reducer transition. JSON text typing changes only the JSON buffer. `jsonApplySucceeded` replaces canonical config and formatted JSON atomically.

### Immutable mutation contracts

Define transport-neutral inputs in `payroll-provider-api.ts` and editor snapshot types in `payroll-provider-editor-state.ts` or `PayrollProviderEditor.tsx`:

```ts
interface SaveProviderSetupInput {
  providerId: string;
  providerDraft: ProviderDraft;
  providerPayload: ProviderMutationPayload | null;
  configDraft: PayrollProviderImportConfigBody;
  sampleSourceName: string | null;
  configPayload: SavePayrollImportConfigPayload | null;
  submittedProviderFingerprint: string;
  submittedConfigFingerprint: string;
}

interface PublishProviderConfigInput {
  providerId: string;
  configId: string;
}
```

The mutation function must use only its input. It must not close over selected provider, current drafts, current sample name, current tab, or refs.

### Save reconciliation algorithm

Implement and test this exact algorithm:

1. The Save handler validates the current local snapshot.
2. If local validation fails, dispatch `localSaveValidationFailed`; make no request.
3. Build one immutable `SaveProviderSetupInput` containing target ID, exact drafts/payloads, and fingerprints.
4. Execute required provider PATCH, then required config POST, using only that input.
5. When config POST runs, use its returned validation summary. When provider metadata changes but config POST is unnecessary and file generation remains enabled, call the existing validation endpoint with the exact saved-provider values plus the submitted config/sample snapshot. Do not validate from current render state.
6. Build a result containing the original input plus returned provider/config/validation records.
7. Cache only the target provider identified by the input/result. Never consult current selection.
8. On reducer `saveSucceeded`, always advance the persisted provider baseline to the returned saved provider.
9. If the current provider draft fingerprint still equals the submitted provider fingerprint, replace it with the returned saved provider draft. Otherwise preserve the later provider edit; it remains dirty against the new baseline.
10. When config was saved, always advance the config baseline to the returned saved config.
11. If the current config fingerprint still equals the submitted config fingerprint, replace canonical config/sample/JSON with the returned saved config. Otherwise preserve later config/sample/JSON edits; they remain dirty against the new baseline.
12. Apply returned validation only to the saved baseline fingerprint. Do not describe later unsaved edits as validated.
13. Show success feedback only if the keyed editor that submitted the mutation still exists. Correctness must not depend on provider-selection locking.

Required race test:

1. Edit config A.
2. Submit snapshot A.
3. While the request is pending, edit config B.
4. Resolve success for A.
5. Baseline becomes saved A, config B remains visible, and the editor remains dirty.

### Query and cache ownership

Use one query-key factory and one mutation-key factory:

```ts
const payrollProviderKeys = {
  list: ["admin-payroll-providers"] as const,
  detail: (providerId: string) => ["admin-payroll-provider", providerId] as const,
  clientSettingPaths: ["admin-payroll-provider-client-setting-paths"] as const,
  sourcePaths: ["admin-payroll-provider-source-paths"] as const,
  preview: (providerId: string, fingerprint: string) => ["admin-payroll-provider-preview", providerId, fingerprint] as const
};

const payrollProviderMutationKeys = {
  create: ["admin-payroll-providers", "mutation", "create"] as const,
  save: ["admin-payroll-providers", "mutation", "save"] as const,
  publish: ["admin-payroll-providers", "mutation", "publish"] as const
};
```

The query-key factory deliberately preserves every existing key shape. In particular, invalidating `payrollProviderKeys.list` must continue to invalidate the client-create/client-editor provider-option queries that use the same prefix. Use the factories consistently inside this feature; do not leave parallel literal keys. The page uses `useIsMutating` with the save and publish keys to disable New Provider without an effect. Cache updates/invalidation must use `variables.providerId`, returned provider ID after equality verification, or created provider ID. A current-selection ref is prohibited.

## 9. Behavior-preservation and test traceability

The table below is the required starting inventory. The implementer updates its “target evidence” entries in each PR description; the junior engineer is not expected to invent the inventory.

| Existing behavior/test | Current owner/evidence | Target owner | Target evidence |
| --- | --- | --- | --- |
| Approved payroll-routing branding; prohibited vendor name absent | Component test: “names the routing function...” | Page/toolbar/status components | Retain one page assertion; no vendor string in production files. |
| Required provider/config indicators | “renders required indicators...” | Overview and Import Format tabs | Split focused component assertions; retain representative page assertion. |
| Extractor-only provider creates no config | “supports an extractor-only provider...” | Reducer selectors + Editor | Direct selector test and one MSW POST-absence component test. |
| Switch import-enabled/extractor-only modes | “switches between...” | Reducer + Overview/Editor | Reducer transition test plus one rendered workflow. |
| Search and select providers | “shows all providers...” | Toolbar/Page | Toolbar interaction plus page keyed-selection assertion. |
| Delayed detail never hydrates from summary | “hydrates the editor...” | DetailLoader | Retain and strengthen: Save absent/disabled until matching detail arrives. |
| XLSX required sheet; CSV-only fields hidden | “shows XLSX sheet...” | ImportFormatTab + config model | Focused tab test and direct validation cases. |
| Save provider snapshot and validate | “sends provider draft...” | Editor/API/reducer | MSW request-body and validation-fingerprint assertion. |
| Unified provider/config Save | “saves provider settings...” | Editor/API | Representative end-to-end component save. |
| Provider-only result preserves config edits | “preserves unsaved...” | Reducer reconciliation | Direct reducer test plus one component seam. |
| Invalid config blocks request | “shows a clear Save validation...” | Config model + Editor | Direct validation tests and one no-request component assertion. |
| Router writeback blocked without file generation | “blocks Payroll Router...” | Provider model + Overview | Existing direct capability test plus focused UI assertion. |
| Save validation feedback visible | “shows validation feedback...” | Reducer/Editor | Reducer result test and rendered message assertion. |
| Readiness remains visible during pending work | “preserves readiness...” | Selectors/Toolbar/Editor | Selector test and pending-mutation component assertion. |
| Browse drawer status and selection | “shows expanded...” | PayrollProviderDrawer | Focused table/selection/disabled test. |
| Column edits without JSON | “edits columns...” | Config model + ColumnsEditor | Direct transform tests and focused field wiring. |
| Client employee source filtering | “shows and filters...” | ColumnsEditor | Focused metadata filtering test. |
| Supported source paths | “suggests supported...” | DetailLoader metadata + ColumnsEditor | Focused options/wiring test. |
| Expression source editing | “edits expression...” | ColumnsEditor | Focused component test; semantic validation stays shared/direct. |
| Client inputs and client-input sources | “defines provider client inputs...” | ClientInputsEditor + config model/reducer | Direct transitions plus representative rendered workflow. |
| Row rules and preview | “edits row rules...” | RowRulesEditor + Preview | Separate row-rule wiring and preview request/result tests. |
| JSON Apply, Reset, and errors | “applies, resets...” | JSON module + reducer + Advanced editor | Parser tests, reducer atomicity tests, one rendered Apply/Reset test. |
| Legacy JSON upgrade becomes dirty | “marks a legacy config...” | JSON/config model + reducer | Direct reducer initialization/apply test; retain one UI readiness assertion only if still necessary. |
| Publish correct draft | “publishes the latest...” | Editor/API | Assert exact provider ID and config ID in request; no closure state. |
| Create provider and normalize code | “creates a provider...” | New dialog + provider model + Page | Direct normalization tests plus dialog submit/focus-order assertion. |
| List and mutation errors | “shows load and mutation...” | Page/DetailLoader/Editor | Separate list error, detail error, save error, publish error assertions. |
| Example-file inference and replace confirmation | Pure example-file tests; UI currently lacks representative coverage | ImportFormatTab/Editor + existing inference module | Add upload-to-confirmation wiring test using a tiny `File`; no large binary fixture. |
| Delete/reorder column accessibility | Existing UI, limited direct evidence | ColumnsEditor | Add one delete confirmation and one reorder/selection test. |
| Provider selection locked during save/publish | Existing UI implementation, incomplete test | Toolbar/Drawer/Page | Pending deferred request test covering autocomplete, drawer, and New Provider disabled. |
| Response cannot update wrong provider | Existing ref-based implementation, no sufficient proof | API inputs + reducer/Editor | Deferred-response test with exact target cache assertions; no selected-provider ref. |
| Edits after submit survive response | Not currently proven | Reducer/Editor | Mandatory reducer race test and a deferred-response component seam. |

## 10. Ordered implementation work

Implementation work is sequential, but merge is deferred until the complete stack has been reviewed as one feature. Use this exact topology:

```text
origin/main
└── codex/payroll-provider-refactor-ui          (PR A -> main)
    └── codex/payroll-provider-refactor-state   (PR B -> PR A branch)
        └── codex/payroll-provider-refactor-final (PR C -> PR B branch)
```

Create all three pull requests as Draft. PR A must reach its implementation and senior-checkpoint gate before branching PR B. PR B must reach its implementation and senior-checkpoint gate before branching PR C. Do not merge PR A or PR B merely to begin the next unit. The top PR C branch contains the complete feature and is the required local/visual integration-review build.

If a lower branch changes, merge it forward through every branch above it, revalidate each affected unit, and rerun the whole-feature review on the new PR C head. Do not force-push or rebase reviewed shared branches unless current owner-authored policy explicitly authorizes that strategy.

### PR A: Extract cohesive presentation boundaries

#### Work item A1: Establish the exact execution baseline

- **Objective:** Record current starting evidence before moving JSX.
- **Dependencies:** Current `origin/main`; PR #1116 already merged; create `codex/payroll-provider-refactor-ui` in a clean dedicated worktree.
- **Affected code:** No production change yet; PR description or checked-in maintainer-doc update.
- **Changes:** Record start time, exact base SHA, source/test line counts, state/ref/effect counts, focused local command result, and the PR #1116 hosted baseline above. Copy the traceability table into the PR description and mark rows touched by PR A.
- **Preserved invariants:** No test skips, timeout increases, or assertion weakening.
- **Failure/recovery:** A pre-existing functional failure stops extraction until recorded and triaged. A local timeout alone is not a failure; rerun without the local limit.
- **Tests:** Existing focused suite before edits.
- **Acceptance criteria:** Baseline evidence and exact commands are recorded; Draft PR A targets `main`; its exact base/head are available for the later integration checkpoint.

#### Work item A2: Extract status, toolbar, drawer, and reusable fields

- **Objective:** Separate stable page chrome and provider selection/status presentation.
- **Dependencies:** A1.
- **Affected code:** Existing page; proposed `PayrollProviderToolbar.tsx`, `PayrollProviderDrawer.tsx`, and `PayrollProviderFields.tsx`.
- **Changes:**
  1. Move `StatusIcon`, routing/file/extractor/export status components, readiness presentation, selector UI, and drawer markup.
  2. Pass typed view data and callbacks; do not pass the whole page state or QueryClient.
  3. Preserve widths, labels, tooltips, table headings, selected-row semantics, and theme-token usage.
  4. Keep mutation creation and selection state in the existing page during this PR.
- **Preserved invariants:** Same selection/search behavior, same drawer status display, same lock behavior, no new raw colors.
- **Failure/recovery:** Revert only the current extraction commit if a component cannot be given a cohesive contract; do not add context or a giant hook.
- **Tests:** Move/add focused toolbar/drawer tests; keep a page-level selection seam.
- **Acceptance criteria:** Components render without API/query imports and their prop contracts have one workflow purpose.

#### Work item A3: Extract tabs one at a time

- **Objective:** Move presentation responsibilities out of the root while leaving current state behavior unchanged.
- **Dependencies:** A2.
- **Affected code:** Proposed Overview, Import Format, Columns, Row Rules, Client Inputs, Preview, and Advanced JSON components listed in the target map.
- **Changes:** Extract in this order: Import Format, Row Rules, Client Inputs, Columns, Preview, Advanced JSON, Overview. After each extraction:
  1. accept domain-shaped values and callbacks;
  2. keep normalization/validation in existing pure modules;
  3. keep the existing Preview request code inside `PayrollProviderPreview.tsx` for PR A; PR B1 moves it to `payroll-provider-api.ts`, so PR A does not mix transport/state changes into JSX extraction;
  4. run relevant focused cases;
  5. make a coherent commit before the next large tab.
- **Preserved invariants:** Tab order, conditional visibility, accessible names, required markers, input behavior, preview layout, and Advanced JSON workflow.
- **Failure/recovery:** If a prop contract becomes an unrelated bag, stop and define a smaller domain callback rather than adding setters or context.
- **Tests:** Focused component wiring; pure permutations remain in existing direct tests.
- **Acceptance criteria:** Root page reads as orchestration; no tab owns domain validation, payload mapping, cache behavior, or editor hydration.

#### Work item A4: Extract dialogs and add missing seam evidence

- **Objective:** Give create, replace-example, and delete confirmation lifecycles focused owners.
- **Dependencies:** A3.
- **Affected code:** Proposed `NewPayrollProviderDialog.tsx`; dialog ownership in ImportFormat/Columns/Editor as described above.
- **Changes:** Move dialog UI with explicit result callbacks. Add representative example upload/replace, delete, and reorder tests using tiny in-memory data.
- **Preserved invariants:** Focus order, confirmation wording, Cancel behavior, and provider-code normalization.
- **Failure/recovery:** Dialog close cancels only its local draft; it must not clear unrelated editor drafts.
- **Tests:** Focused dialog and accessibility tests.
- **Acceptance criteria:** No dialog reads QueryClient or unrelated editor state.

#### Work item A5: Document and validate PR A

- **Objective:** Leave a documented, behavior-preserving component architecture.
- **Dependencies:** A1-A4 complete and focused tests green.
- **Affected code:** `docs/payroll-provider-management.md` plus extracted code/tests.
- **Changes:** Add the current component responsibility map and extension guidance. Record exact validation and timing.
- **Preserved invariants:** Documentation describes only implemented ownership; API, state lifecycle, and product behavior remain unchanged in PR A.
- **Failure/recovery:** If complete validation exposes a behavior regression, fix or revert the responsible extraction commit before requesting review; do not defer it to PR B.
- **Tests:** Focused suite, web lint, theme check, full web unit, web build.
- **Acceptance criteria:** All tests pass; zero skips; component file hosted timing is no worse than 55 seconds; full web-unit timing has no unexplained material regression; no state/effect/ref architecture change is hidden in this PR.
- **Suggested commits:**
  1. `refactor(payroll): extract provider status and selection surfaces`
  2. `refactor(payroll): extract import configuration tabs`
  3. `refactor(payroll): extract provider management dialogs`
  4. `test(payroll): cover extracted provider UI seams`
  5. `docs(payroll): map provider management components`

**Senior checkpoint after PR A:** Review component cohesion and prop contracts before branching PR B from the exact PR A head. Stop if a giant hook/context, broad setter bag, or duplicated validation/payload logic has appeared. PR A remains Draft and unmerged.

### PR B: Replace hydration choreography with keyed reducer state and target-safe I/O

#### Work item B1: Add the API/query-key boundary

- **Objective:** Centralize existing transport contracts without changing endpoints or payloads.
- **Dependencies:** PR A Draft implementation and senior checkpoint complete; create `codex/payroll-provider-refactor-state` from the exact PR A head and target PR B to `codex/payroll-provider-refactor-ui`.
- **Affected code:** Proposed `payroll-provider-api.ts`, page/editor/preview callers.
- **Changes:** Add query and mutation key factories plus typed list/detail/metadata/create/update/save-config/validate/publish/preview functions. Replace all literal keys and direct `apiRequestWithoutTenantContext` calls in the feature. Assign the stable create/save/publish keys to their mutations. The page derives its cross-component save/publish lock with `useIsMutating`; do not mirror pending state.
- **Preserved invariants:** Exact URLs, methods, headers, payloads, response types, and request order.
- **Failure/recovery:** Transport errors continue to flow to TanStack Query/UI handling; do not normalize server messages into a new contract.
- **Tests:** Existing MSW request assertions; direct tests only for mapping not already proven at the network seam.
- **Acceptance criteria:** API client import exists only in `payroll-provider-api.ts`; no business decision exists there.

#### Work item B2: Implement and prove the pure reducer

- **Objective:** Establish one authoritative coordinated editor state before wiring React.
- **Dependencies:** B1 and existing pure models.
- **Affected code:** Proposed `payroll-provider-editor-state.ts` and `.test.ts`; existing model modules only for focused extensions.
- **Changes:** Implement initialization, domain actions, dirty/readiness selectors, selection clamping, atomic JSON/config transitions, validation fingerprinting, and exact save reconciliation.
- **Preserved invariants:** Draft config preferred over active config; extractor-only behavior; legacy schema normalization; unsaved config preserved during provider changes.
- **Failure/recovery:** Reducer is pure and deterministic; invalid JSON never enters canonical config.
- **Tests:** At minimum:
  - initialization from draft, active, and no config;
  - draft precedence;
  - every coordinated transition;
  - provider/config dirty and clean selectors;
  - validation invalidation on edits;
  - schema upgrade becomes dirty;
  - selection clamping after deletion;
  - save success with no later edits;
  - mandatory A-submit/B-edit race;
  - provider-only save preserving config edits;
  - publish result state;
  - extractor-only no-config-save selector.
- **Acceptance criteria:** Tests import no React, MUI, QueryClient, MSW, or browser render harness.

#### Work item B3: Introduce page/detail/keyed-editor boundaries

- **Objective:** Initialize editor state only from authoritative detail and reset through key changes.
- **Dependencies:** B2.
- **Affected code:** Reduced page; proposed DetailLoader and Editor.
- **Changes:**
  1. Page owns provider list and nullable user-selected key.
  2. Derive effective key from current list without effects.
  3. DetailLoader queries exact detail and metadata.
  4. Render controlled loading/error/empty states.
  5. Mount `<PayrollProviderEditor key={detail.id} initialProvider={detail} ... />` only when detail ID equals requested key.
  6. Initialize `useReducer` exactly once from `initialProvider`.
  7. Delete provider/config hydration effects and identity refs.
- **Preserved invariants:** Delayed detail cannot enable stale Save; provider change resets local draft; same-provider refetch cannot wipe local edits.
- **Failure/recovery:** Detail failure leaves selection available for another provider and shows a retryable error; it never falls back to editable summary data.
- **Tests:** Delayed detail, detail error, missing selected provider fallback, keyed remount, same-provider refetch preservation.
- **Acceptance criteria:** Zero hydration effects/refs; page owns no editor draft.

#### Work item B4: Wire snapshot-safe save, validation, publish, and cache behavior

- **Objective:** Make async completion correct independently of current selection.
- **Dependencies:** B3.
- **Affected code:** Editor, reducer, API module, relevant component tests.
- **Changes:** Implement immutable inputs and the exact reconciliation algorithm. Cache only captured targets. Lock all provider-changing controls during pending save/publish while leaving fields editable. Remove `selectedProviderIdRef`, validation identity refs, and current-render mutation closure dependencies.
- **Preserved invariants:** Same request ordering and normal success/error messages; no config POST for extractor-only providers.
- **Failure/recovery:** On failure preserve drafts, invalidate captured target keys, show error, and permit retry. Do not client-roll back a successful first request when a later request fails.
- **Tests:**
  - exact target provider/config IDs in requests;
  - wrong-provider cache cannot be updated;
  - selection/New Provider disabled during deferred save/publish;
  - field edit B survives save A;
  - provider-only save preserves config changes;
  - partial failure retains drafts and permits retry;
  - publish uses captured provider/config IDs;
  - error/success feedback belongs only to the submitting keyed editor.
- **Acceptance criteria:** Mutation functions use only variables; cache writes use variables/results; no identity coordination ref exists.

#### Work item B5: Remove legacy orchestration and document ownership

- **Objective:** Finish the state boundary rather than retaining compatibility paths.
- **Dependencies:** B4.
- **Affected code:** Whole feature and maintainer documentation.
- **Changes:** Delete dead setters, hydration fingerprints/keys, automatic selection/validation effects, duplicate derived state, and stale cache-merging paths. Update docs with server state versus draft state, reducer actions, mutation snapshots, and keyed lifecycle.
- **Preserved invariants:** All behavior rows remain covered; only obsolete coordination code is removed.
- **Failure/recovery:** If a deleted path still owns observable behavior, restore it only long enough to add the missing narrow test and move that behavior to its target owner; do not retain parallel implementations.
- **Tests:** Complete validation matrix below.
- **Acceptance criteria:** Zero `useEffect`/`useMountEffect` in the feature; only imperative DOM refs remain; no unused compatibility code.
- **Suggested commits:**
  1. `refactor(payroll): centralize provider API requests`
  2. `refactor(payroll): add provider editor state model`
  3. `refactor(payroll): key editor state to provider detail`
  4. `refactor(payroll): make provider mutations target safe`
  5. `test(payroll): cover editor state and mutation races`
  6. `docs(payroll): document editor state ownership`

**Mandatory senior checkpoint before branching PR C:** Review the complete reducer contract, save reconciliation, mutation inputs, cache targeting, partial-failure behavior, and feature-wide effect/ref inventory. Do not branch PR C until this checkpoint finds no missing instance of the same state-ownership pattern. PR B remains Draft and unmerged.

### PR C: Finalize test placement, performance, and maintainer handoff

#### Work item C1: Complete behavior traceability and right-size tests

- **Objective:** Ensure every behavior has a narrow owner and representative seam without duplicate expensive workflows.
- **Dependencies:** PR B Draft implementation and mandatory senior checkpoint complete; create `codex/payroll-provider-refactor-final` from the exact PR B head and target PR C to `codex/payroll-provider-refactor-state`.
- **Affected code:** All feature tests; production only for testability defects discovered here.
- **Changes:** Update every traceability row. Split component test files by owner where collection/setup evidence supports it. Use typed fixture factories and keep list/detail shapes distinct. Remove a broad assertion only after its narrow replacement exists and at least one critical page/network seam remains.
- **Preserved invariants:** Behavioral coverage, realistic request/response distinctions, zero skips, no loosened assertions.
- **Failure/recovery:** Restore the broad test if the proposed narrow test cannot prove the same owner/seam.
- **Tests:** All traceability evidence.
- **Acceptance criteria:** Reviewers can map every preserved behavior to a specific test without relying on test count alone.

#### Work item C2: Audit final responsibility, size, effects, refs, and dependencies

- **Objective:** Confirm the refactor did not move the god component into another artifact.
- **Dependencies:** C1.
- **Affected code:** Entire payroll-provider feature and its imports; production edits are limited to cohesive corrections found by the audit.
- **Changes:** Record file/function sizes and dependencies. Treat these as review signals, not automatic failures: Editor around 300-350 lines, individual tab components around 250-300 lines, ordinary pure functions around 50 lines. Document any cohesive exception. Search for `useEffect`, `useMountEffect`, coordination refs, direct API calls outside the API module, literal query keys, and duplicated payload field lists.
- **Preserved invariants:** Audit-driven corrections do not expand product scope or change API behavior.
- **Failure/recovery:** If the audit finds a cross-cutting design defect rather than a local correction, stop and obtain senior direction instead of adding another abstraction during final cleanup.
- **Tests:** Rerun the focused suite after each audit-driven correction and include static-search results in the PR evidence.
- **Acceptance criteria:** No new god hook/service/reducer, generic dumping ground, circular dependency, or duplicated authoritative rule.

#### Work item C3: Measure exact-head performance

- **Objective:** Demonstrate CI benefit without shifting cost.
- **Dependencies:** C2.
- **Affected code:** Tests and fixtures only when evidence identifies redundant broad-harness work; production code changes require a demonstrated ownership defect.
- **Changes:** Record focused local timing, push the exact head through hosted CI, download `web-unit-timing`, and compare component-file total, tests/hooks, full runner, full command, failures/skips, and expensive imports.
- **Preserved invariants:** Test behavior, assertions, realistic fixtures, and production behavior remain unchanged while reducing repeated setup/work.
- **Performance gates:**
  - Final hosted payroll-provider component total is **45 seconds or less**.
  - If runner variance prevents 45 seconds, it must still be no slower than the PR #1116 49.4-second exact-head baseline and must show a concrete reduction in tests/hooks or broad-harness work; owner approval is required to waive the 45-second target.
  - Full web-unit command must not regress more than 5% against the PR base's comparable successful hosted run without a documented unrelated cause.
  - No test is skipped, deleted without mapped replacement, weakened, or given a larger timeout to meet the gate.
- **Failure/recovery:** Inspect setup, collection, processed imports, repeated render/MSW setup, and duplicated interactions. Do not add concurrency to CPU-saturated work or move cost to another file.
- **Tests:** Focused suite before/after with the same command and environment, full web suite, and exact-head hosted CI artifact.
- **Acceptance criteria:** Exact artifact evidence is linked in the PR description.

#### Work item C4: Finish maintainer and local-review documentation

- **Objective:** Make the final architecture safe for future junior maintenance.
- **Dependencies:** C1-C3 complete and performance evidence available.
- **Affected code:** `docs/payroll-provider-management.md`.
- **Changes:** Finalize responsibility map, dependency direction, reducer/state ownership, mutation snapshot rules, query keys, where to add each rule, where each test belongs, and explicit prohibitions on hydration effects/current-selection mutation targets. Add a maintainer-facing “Review the complete stacked feature locally” section that links to or faithfully incorporates the commands and evidence contract in `payroll-provider-management-stacked-pr-local-review.md`.
- **Preserved invariants:** Documentation matches the exact implemented head and does not claim unperformed UAT or lifecycle gates.
- **Failure/recovery:** If the implemented branch names or local startup commands differ from this plan, update both the checked-in HelixOS documentation and the stack review evidence before whole-feature review; do not leave a knowingly stale runbook.
- **Tests:** Execute every documented command through the non-destructive smoke-check stage and verify paths, route, persona, and script names.
- **Acceptance criteria:** A new engineer can identify the owner of presentation, state, transport, validation, parsing, and inference without reading the former monolith.

#### Work item C5: Validate and visually approve the complete Draft stack

- **Objective:** Give developers and product reviewers one exact local build containing PR A, PR B, and PR C before any PR is promoted to Ready.
- **Dependencies:** C1-C4 complete; PR A, PR B, and PR C are current Drafts with the exact parent-child topology defined above.
- **Affected code:** No new production code is expected. Review evidence belongs in the top PR description or its designated whole-feature review comment.
- **Changes:**
  1. Follow `payroll-provider-management-stacked-pr-local-review.md` from a clean detached worktree at `origin/codex/payroll-provider-refactor-final`.
  2. Verify PR A is an ancestor of PR B and PR B is an ancestor of PR C.
  3. Record stack base, all three heads, integration head, and integration tree SHAs.
  4. Inspect the complete `$StackBaseSha...HEAD` diff and current-main drift.
  5. Run the full automated validation matrix without a local timeout.
  6. Start the self-contained local stack and execute every Manual UAT step below.
  7. Capture the required screenshots/visual evidence and obtain named whole-feature reviewer signoff on the exact integration head.
- **Preserved invariants:** The integration tip contains the unchanged commits of all lower PRs; aggregate review does not replace narrow PR review or authorize Ready, merge, or release.
- **Failure/recovery:** Any lower-branch or integration-head change invalidates the checkpoint. Merge the changed lower branch forward through the stack, re-record SHAs, and rerun complete automated validation and UAT. Any UAT failure reopens its owning work item and adds regression coverage before another checkpoint.
- **Tests:** Full validation matrix, exact-head hosted evidence already required for the top PR, all Manual UAT steps, complete visual review, and ancestry/base-drift checks from the runbook.
- **Acceptance criteria:** The top Draft contains the complete current stack; all validation and UAT pass; evidence identifies one exact integration head/tree; reviewers explicitly approve the feature as a whole; no remaining PR is Ready yet.
- **Suggested commits:**
  1. `test(payroll): right-size provider component coverage`
  2. `docs(payroll): finalize provider editor architecture`

## 11. Validation strategy

Run focused tests after every coherent commit. Before each pull-request feedback request, run the complete applicable matrix without a local timeout. Before any remaining PR is promoted to Ready, rerun the entire matrix from the exact PR C integration tip by following the standalone stacked-PR runbook.

| Layer | Scenario | Command/evidence |
| --- | --- | --- |
| Shared build prerequisite | Workspace packages available to web tests | `npm run build:packages` |
| Focused feature | All payroll-provider direct and component tests | `npm exec --workspace @helixos/web -- vitest run src/features/utilities/payroll-providers` |
| Reducer/model | Pure transitions and race reconciliation | Same focused command; tests must not import render harness |
| Web lint | Type/style/effect restrictions | `npm run lint -w @helixos/web` |
| Theme | No raw feature literals | `npm run theme:check -w @helixos/web` |
| Full web unit | Cross-feature regression | `npm run test -w @helixos/web` |
| Web build | TypeScript and Vite integration | `npm run build -w @helixos/web` |
| Hosted CI | Required exact-head jobs | Current repository-required CI plus `web-unit-timing` artifact |
| Manual | PlatformAdmin workflow | UAT script below |
| Whole stack | PR A + PR B + PR C composed feature | `payroll-provider-management-stacked-pr-local-review.md`; exact head/tree, ancestry checks, complete matrix, screenshots, and reviewer signoff |

If `@helixos/shared` changes despite the stated non-goal, stop and obtain scope approval, then also run:

```powershell
npm run test -w @helixos/shared
npm run build -w @helixos/shared
```

If an API contract appears to require change, stop. After explicit approval, apply NestJS/OpenAPI requirements and add API validation; do not infer that expansion from this plan.

## 12. Manual UAT

Prerequisites:

- full local stack running according to repository documentation;
- PlatformAdmin persona with access to Admin Console;
- one import-enabled provider with active config, one with a draft config, and one extractor-only provider;
- tiny CSV and XLSX example files containing non-sensitive synthetic data;
- browser network panel available for request-target verification.

Execute on the exact `codex/payroll-provider-refactor-final` integration head created from the complete Draft stack. Use `payroll-provider-management-stacked-pr-local-review.md` to create the isolated worktree, start the application, and record evidence.

1. Open Admin Console -> Payroll Provider Management. Confirm approved branding and no prohibited vendor name.
2. Confirm list loading, detail loading, and a usable detail-error/retry surface.
3. Select an import-enabled provider with an active config. Confirm detail fields/config match the detail response, not summary data.
4. Edit provider notes and one config field; Save; confirm both persist after refresh.
5. Edit config, save provider metadata, and confirm the config edit remains.
6. Start Save with edit A, make edit B while pending, then let Save complete. Confirm B remains visible and Save remains enabled/dirty.
7. During pending Save and Publish, confirm provider autocomplete, drawer rows, and New Provider are disabled while ordinary fields remain editable.
8. Switch providers after completion. Confirm no prior provider draft/config appears. Switch back and confirm authoritative saved state.
9. Configure CSV comma, real tab, and pipe delimiters.
10. Configure XLSX and confirm sheet-name requirement.
11. Add, edit, reorder, and delete columns; exercise Cancel and Confirm on deletion.
12. Verify client/employee source-path filtering, expressions, conditional guidance, and client-setting suggestions.
13. Add/edit/remove client inputs, including select options, and use one as a column source.
14. Edit row rules; open Preview; verify loading, successful output, and a simulated error.
15. Upload small CSV/XLSX examples. Exercise replace Cancel and Replace and confirm inferred columns.
16. Apply valid, invalid, and legacy-version Advanced JSON; exercise Reset and confirm only Apply changes canonical config.
17. Attempt invalid Save; confirm no request and useful errors.
18. Publish a valid saved draft; confirm exact provider/config IDs and refreshed readiness.
19. Select an extractor-only provider; confirm config tabs and config POST are absent.
20. Create a disabled provider; confirm field order, code normalization, and new-provider selection after creation.
21. Simulate save and publish failures; confirm drafts remain and retry works.
22. Refresh and confirm persisted provider/config state is authoritative.

Attach screenshots only for changed component boundaries or unexpected visual risk; attach request logs/test assertions for target-ID and no-config-POST evidence.

## 13. Data, migration, security, and rollout

### Data and migration

Not applicable. No schema, seed, migration, persisted data conversion, or backup operation is planned. Existing API contracts and database behavior are preserved.

### Security and privacy

- Authorization remains API-enforced and unchanged.
- No new PII, secret, token, raw JSON diagnostic surface, or protected download is introduced.
- Do not expose internal database identifiers; continue using existing public API keys.
- Do not log provider config contents or payroll sample data.

### Accessibility and visual compatibility

- Preserve labels, required markers, keyboard focus order, dialog names, tab semantics, disabled states, and confirmation behavior.
- Reuse existing theme tokens and shared MUI behavior; no raw color literals or redesign.
- Layout remains responsive to the existing windowed application context.

### Rollout and recovery

- No feature flag or deployment ordering is required.
- Each PR is behavior-preserving and independently releasable.
- Recovery is ordinary revert of the affected PR; no data rollback is needed.
- Never revert PR #1116 as part of this initiative.

## 14. Risks and mitigations

| Risk | Likelihood / impact | Mitigation and evidence |
| --- | --- | --- |
| Mechanical extraction creates prop drilling or a god hook. | Medium / High | PR A senior checkpoint; focused contracts; no context/controller hook; responsibility audit. |
| Reducer duplicates existing model rules. | Medium / High | Reducer imports existing pure owners; direct duplicate-rule search in PR B self-review. |
| Same-provider refetch overwrites unsaved edits. | Medium / High | Key only by provider ID; initialize reducer once; explicit refetch-preservation test. |
| Save response overwrites post-submit edits. | High / High | Exact fingerprint reconciliation algorithm and mandatory A/B race test. |
| Mutation/cache targets wrong provider. | Medium / High | Immutable variables, query-key factory, deferred-response/cache tests, zero selection refs. |
| Separate provider/config writes partially succeed. | Medium / Medium | Preserve drafts, invalidate captured target, retry; no false client rollback. |
| Component-test speed worsens after file extraction. | Medium / Medium | Per-PR 55-second ceiling; final 45-second target; hosted artifact comparison and no cost shifting. |
| Behavior coverage is lost while tests move. | Medium / High | Prewritten traceability matrix; narrow replacement before removal; representative seam retained. |
| Reviewers approve narrow diffs but miss a composed visual/workflow regression. | Medium / High | True Draft stack, isolated top-branch worktree, complete UAT, screenshots, and exact-head whole-feature signoff before Ready. |
| Lower-stack changes leave PR C stale. | Medium / High | Ancestry checks, merge-forward propagation, explicit checkpoint invalidation, and full revalidation on the new integration head. |
| Lifecycle policy becomes stale. | Low / High | Re-read current `AGENTS.md` before every PR; owner-authored policy controls. |

## 15. Pull-request lifecycle and evidence

At execution time, follow the current HelixOS owner-authored lifecycle policy in `C:\dev\HelixOS\AGENTS.md`. As of the inspected revision, this includes a dedicated branch/worktree, incremental validated commits, Draft pull request, clean exact-head private self-review, Draft feedback/re-review, Ready promotion only after the defined clean-feedback gate, exact-head required CI, prescribed reviewer request, and final Slack trigger. Do not copy Slack credentials or automate lifecycle steps from this document; use the repository-prescribed workflow/skill.

The remaining PRs are developed and reviewed as a Draft stack before bottom-up promotion:

1. Complete PR A as a green Draft and pass its senior checkpoint.
2. Branch PR B from PR A; complete it as a green Draft and pass its mandatory senior checkpoint.
3. Branch PR C from PR B; complete it as a green Draft.
4. Use PR C as the integration tip and pass Work item C5 against its exact head.
5. Only after whole-feature signoff may the individual PRs proceed bottom-up through their current owner-authored Ready, CI, reviewer, feedback, and merge gates.

The whole-feature checkpoint is an additional engineering gate. It does not authorize promotion, reviewer requests, Slack writes, merge, release, or publication. Each PR must still satisfy the canonical lifecycle on its exact current head. When a lower PR merges or changes, refresh the branches above it with the repository-approved strategy and re-establish every invalidated exact-head gate.

Every PR description must contain:

- exact base and head SHAs;
- scope and explicit non-goals;
- changed responsibility map;
- affected traceability rows and their evidence;
- state/dependency flow before and after that PR;
- validation commands and results;
- local timing labeled directional;
- exact-head hosted timing when performance is claimed;
- line/state/effect/ref counts where relevant;
- partial-failure and rollback notes;
- any intentional size/cohesion exception;
- confirmation that API, authorization, persistence, branding, and visual behavior remain unchanged.

The top PR description must additionally contain:

- PR A, PR B, and PR C URLs and head SHAs;
- recorded stack base and integration tree SHA;
- the full `main...codex/payroll-provider-refactor-final` comparison URL;
- ancestry-check results;
- whole-stack automated validation and hosted timing;
- complete UAT and visual-review evidence;
- named whole-feature reviewers and their exact-head signoff;
- explicit invalidation/revalidation history after any lower-stack change.

## 16. Mandatory self-review checklist

Before declaring any PR implementation-complete, inspect its complete diff and surrounding feature for:

- a component, hook, reducer, service, or module with unrelated reasons to change;
- a monolith moved wholesale into a hook or generic helper;
- query/detail state copied into local state after initialization;
- `useEffect`, dependency-driven `useMountEffect`, fingerprints, or refs coordinating hydration;
- mutation functions closing over current provider/config/selection;
- cache updates keyed from current selection rather than variables/results;
- more than one authoritative provider/config draft;
- JSON text treated as canonical before Apply;
- duplicated provider payload fields, config validation, normalization, or readiness rules;
- list fixtures containing detail-only `configs`;
- UI-only authorization or server-rule enforcement;
- exhaustive deterministic cases still requiring full rendered setup;
- test speed achieved through skips, weaker assertions, larger timeouts, unrealistic fixtures, or shifted cost;
- raw theme literals, prohibited branding, or layout changes hidden in extraction;
- behavior changes mixed into move-only commits.

If two review rounds reveal omissions from the same state/mutation boundary, invoke the repository circuit breaker: stop automated reruns, inventory the whole category, make one cohesive correction, run complete validation, and obtain owner approval before resuming the review loop.

## 17. Definition of done

The initiative is complete only when all boxes are true:

- [ ] PR #1116 remains the accepted completed prerequisite and its pure owners are reused.
- [ ] Page owns list/effective selection/create workflow only.
- [ ] Matching authoritative detail loads before editor mount or Save availability.
- [ ] Provider changes reset through keyed remount; same-provider refetch does not overwrite drafts.
- [ ] One reducer owns coordinated editor draft/baselines/validation/JSON transitions.
- [ ] Zero `useEffect`/`useMountEffect` exists in the feature.
- [ ] Only imperative DOM refs remain.
- [ ] Save/validation/preview/publish use immutable exact-target snapshots.
- [ ] Post-submit edits survive completion and remain correctly dirty.
- [ ] Provider-changing actions are locked, but fields remain editable, during save/publish.
- [ ] Cache updates/invalidation use captured query keys.
- [ ] Extractor-only providers never post config.
- [ ] Existing pure rules are not duplicated.
- [ ] Every traceability row has passing narrow and/or representative seam evidence.
- [ ] No tests are skipped or weakened.
- [ ] Final hosted feature timing satisfies the stated performance gate without full-suite cost shifting.
- [ ] Full lint, theme, unit, build, manual UAT, and required exact-head CI evidence is green.
- [ ] Maintainer documentation describes final ownership, extension rules, and how to review the complete stack locally.
- [ ] PR A is an ancestor of PR B and PR B is an ancestor of PR C at the recorded whole-feature checkpoint.
- [ ] The exact PR C integration head/tree passes complete automated validation and visual UAT before any remaining PR is promoted to Ready.
- [ ] Whole-feature evidence includes all branch SHAs, full comparison, screenshots, named reviewers, and invalidation history.
- [ ] Architecture self-review reports no actionable state, dependency, test-placement, security, branding, or maintainability finding.
- [ ] Repository lifecycle policy has been followed through the authorized stopping point; this plan does not authorize merge or release.

## 18. Junior-engineer handoff checklist

Before coding:

1. Read `C:\dev\HelixOS\AGENTS.md` and every mandatory file it lists, especially `instructions/about.md`, `instructions/general/refactoring.md`, `instructions/node/node-app.md`, `instructions/node/node-testing.md`, `instructions/react/noeffect.md`, `instructions/ui/web-theme.md`, and `DESIGN.md`.
2. Read this plan completely.
3. Read `payroll-provider-management-stacked-pr-local-review.md`, `docs/payroll-provider-management.md`, and the five existing payroll-provider pure modules/tests.
4. Confirm which ordered PR is assigned and use its prescribed branch parent: PR A from `main`, PR B from PR A, or PR C from PR B.
5. Start in a clean dedicated worktree on the exact prescribed non-main branch; do not merge the lower PR merely to start the next branch.
6. Record start time, exact base/parent SHA, baseline counts, and focused test timing.

While coding:

- make one cohesive change at a time and commit after its validation passes;
- preserve unrelated work;
- use existing pure owners instead of copying rules;
- do not introduce effects, selection refs, generic setters, context, or a controller hook;
- keep list/detail fixtures different;
- run focused tests after each extraction or reducer slice;
- merge lower-branch corrections forward through every branch above them and treat prior aggregate signoff as stale;
- update `docs/payroll-provider-management.md` in the same PR as each meaningful architecture change;
- do not promote any remaining PR to Ready before Work item C5 passes on the exact integration head.

Stop and escalate immediately if:

- an API/schema/authorization/persistence/branding/visual behavior change appears necessary;
- a confirmed decision in this plan conflicts with current repository code or policy;
- a proposed component needs an unrelated prop bag or new cross-feature abstraction;
- save reconciliation cannot follow the specified fingerprint algorithm;
- two review cycles find omissions from the same ownership boundary;
- a functional baseline test fails for reasons unrelated to the assigned change.

Final handoff evidence:

- exact base/head SHAs and elapsed work time;
- logical commit list;
- updated traceability rows;
- focused and complete validation output;
- local and hosted timing evidence;
- UAT evidence for the assigned phase;
- for PR C, exact stack base/A/B/C head/tree SHAs, ancestry checks, complete local-review runbook results, screenshots, and named whole-feature reviewer signoff;
- before/after ownership/state flow;
- remaining risks or explicitly approved exceptions;
- confirmation that no unresolved implementation or product decision remains.
