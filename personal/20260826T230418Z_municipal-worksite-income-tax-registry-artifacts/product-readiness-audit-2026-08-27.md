# Municipal Worksite Income-Tax Registry Product-Readiness Audit

**Audit date:** August 27, 2026
**Audited published checkpoint:** `590a83534dd60d8a88560f2d0e2a91adeda1c922`

## Decision

The research package is **ready to support a governed screening workflow**, but it is **not ready to be loaded as an autonomous approved-city list or a payroll-calculation table**.

It can safely support these outcomes when the stated prerequisites are enforced:

- `BUFFER_REVIEW_REQUIRED`: a `CONFIRMED_PRIMARY` row matches an authoritative legal worksite jurisdiction and is effective for the evaluation date.
- `CLEAR`: the worksite resolves authoritatively and uniquely, the state is `COMPLETE` or `NO_AUTHORITY_CONFIRMED`, and no current qualifying row matches.
- `UNDETERMINED`: every other case, including a mailing-city-only input, a `PARTIAL` state without a match, an association/secondary-supported row, ambiguous or failed resolution, missing evidence, or an evaluation error.

The current Issue #1280 company city/state input is a screening proxy, not an authoritative municipal-boundary identifier. Under the strict evidence contract, that input alone cannot support `CLEAR`. It can at most produce a conservative review signal when a direct-positive name match is intentionally accepted as a proxy; otherwise it must return `UNDETERMINED`.

## Validated package state

| Check | Result |
|---|---:|
| Current registry rows | 2,817 |
| Unique record IDs | 2,817 |
| States with positive/current candidate rows | 9 |
| `CONFIRMED_PRIMARY` | 2,743 |
| `SUPPORTED_AUTHORITATIVE_ASSOCIATION` | 72 |
| `SUPPORTED_CURRENT_SECONDARY` | 2 |
| Rows without a source URL | 0 |
| Duplicate record IDs | 0 |
| Coverage-matrix rows / unique state-or-DC codes | 51 / 51 |
| Coverage: `COMPLETE` | 17 |
| Coverage: `NO_AUTHORITY_CONFIRMED` | 23 |
| Coverage: `PARTIAL` | 11 |
| Coverage: `UNDETERMINED` | 0 |

Validation hashes at the audited checkpoint:

- CSV: `ed497cd4b6265e2f2275e42a3fabc0187cd07ad16bd605b25ed5bc5dcea48efe`
- JSONL: `10a992e63e076e9d498e0c7ac25f7fc6f44f858720a4390704b75366aeb65c1a`

## What is ready

### Scope and evidence contract

The agreed definition is narrow and implementable: a municipality-imposed tax calculated from employee compensation for work performed in the jurisdiction, including nonresident work, with employer-withholding relevance. Resident-only income taxes, employer-only payroll taxes, flat employee fees, and nonmunicipal taxes are separately preserved rather than silently mixed into the current registry.

This is why New York City and Baltimore City are not worksite-positive rows: their relevant individual taxes depend on residence. Yonkers remains included for its nonresident earnings tax. The broader review inventory retains the excluded classes for future workflows.

### Three-result screening semantics

The evidence and coverage fields are sufficient to implement the Issue #1280 result contract without turning absence into `CLEAR`. `coverage_status`, `evidence_status`, `product_disposition`, effective/source fields, and limitations make the intended fallback explicit.

### Nationwide source topology

All 50 states and DC have a current coverage disposition. Statewide closed positive/zero universes are separated from partial states. The research does not treat an administrator or association list as complete unless the source topology actually closes the state.

### Auditability

The snapshot includes reproducible builders, source extracts, validation JSON, a full file manifest, direct source URLs, state closure reports, and explicit unresolved queues. Alabama and Kentucky association rows were individually assessed rather than accepted wholesale.

## Production blockers

### 1. Authoritative boundary resolution is not implemented

Postal city, mailing city, and company-entered city are not legal municipal boundaries. Ohio requires address-to-FIPS resolution; Pennsylvania requires PSD resolution; many Alabama, Kentucky, Michigan, Missouri, Oregon, and other rows still lack a durable official jurisdiction identifier. A canonical exact string match is not enough to prove the worksite lies inside the taxing boundary.

Before production use, the resolver needs normalized work-address inputs and an authoritative boundary result containing at least state, jurisdiction type, stable jurisdiction ID, legal name, and source/version. City/state may remain a discovery key, but it must not be the authoritative `CLEAR` key.

### 2. Seventy-four rows are not approved positives

The 72 association-supported and 2 current-secondary-supported rows remain `UNDETERMINED`. They must be excluded from the product-approved positive view and routed to evidence review. Falmouth and Hurstbourne Acres are deliberately present for completeness but cannot trigger an approved positive until their enacted payroll ordinance or official employer form is retained.

### 3. Eleven states cannot support unmatched `CLEAR`

Alabama, California, Iowa, Kentucky, Maine, Massachusetts, New Hampshire, Oregon, Rhode Island, South Carolina, and Tennessee remain `PARTIAL`. A no-match in any of these states is `UNDETERMINED`, even when the city is absent from all known candidate rows.

### 4. The registry is not calculation-ready

Rates and effective periods are intentionally evidence-oriented and heterogeneous: simple percentage strings, structured component objects, caps, brackets, free-text effective dates, and source-snapshot dates coexist. The dataset does not encode exemptions, reciprocal credits, wage definitions, caps, apportionment, filing frequency, or rate history sufficiently to calculate withholding.

The Rule Engine should use this registry only to select a review workflow. It must not calculate tax or automatically activate the rounded-variance option.

### 5. Evidence approval and lifecycle metadata are incomplete

The snapshot has file hashes and source URLs, but the row model does not yet carry an approval record, approver, approval time, source title, retrieved-content hash, superseded version, or mandatory refresh date for every row. Dynamic pages and delegated-administrator forms can change without preserving history.

Before loading governed Rule Engine data, produce an immutable approved release with dataset version, exact source snapshot/content hash, reviewer approval, valid-from/valid-to, and refresh trigger metadata.

### 6. Known current conflicts require nonmatching behavior

The review queue contains unresolved Alabama fields and Kentucky rate conflicts, including Bardwell, Paintsville, Perryville, Raceland, Shively, Springfield, and Winchester. These rows must remain `UNDETERMINED`; the product must never pick whichever source is newer-looking without a controlling local instrument.

## Required product data views

Use separate governed views rather than one unqualified list:

1. **Approved worksite positives** - only current/effective `CONFIRMED_PRIMARY` rows approved for the release.
2. **Discovery and evidence queue** - association, secondary, ambiguous, conflicting, and incomplete rows; never treated as a confirmed positive or negative.
3. **Coverage policy** - one current row per state/DC defining whether unmatched authoritative jurisdictions may be `CLEAR`.
4. **Excluded/review classes** - resident-only, employer-only, flat, county, school, transit, special-district, and ambiguous taxes.
5. **Future changes** - effective-dated records that cannot enter the approved current view early; Salem's October 1, 2026 tax is the immediate example.

## Deterministic decision contract

```text
if evaluation failed or work address is incomplete:
    UNDETERMINED
else if authoritative jurisdiction resolution failed or is ambiguous:
    UNDETERMINED
else if an effective CONFIRMED_PRIMARY row matches:
    BUFFER_REVIEW_REQUIRED
else if an association, secondary, ambiguous, or conflicting row matches:
    UNDETERMINED
else if state coverage is COMPLETE or NO_AUTHORITY_CONFIRMED:
    CLEAR
else:
    UNDETERMINED
```

The output should include registry version, matched jurisdiction ID, record ID if any, evidence status, coverage status, evaluation date, resolver source/version, and a machine-readable reason code.

## Acceptance checks before implementation is enabled

- The agreed narrow definition and strict decision contract are recorded as governed product-data policy.
- A work-address-to-legal-jurisdiction resolver is selected and versioned.
- Only direct-primary rows enter the approved positive view.
- Secondary/association rows and all `PARTIAL`-state misses demonstrably return `UNDETERMINED`.
- Effective dating excludes Salem before October 1, 2026 and includes it only after revalidation.
- Tests cover duplicate city names, independent/consolidated cities, postal-city mismatch, city/county name collisions, incomplete addresses, resolver failures, source-version failures, and future-dated changes.
- The ruleset produces a review alert only; it does not calculate tax, approve an application, or change the rounded-variance setting.
- The approved dataset release and source artifacts are immutable and reproducible from the recorded hashes.

## Immediate next actions

1. Obtain the Falmouth and Hurstbourne Acres enacted payroll ordinances/forms and resolve the seven named Kentucky rate conflicts.
2. Define and implement authoritative legal-jurisdiction resolution for company work addresses.
3. Create the governed approved/direct view and the separate evidence queue.
4. Add dataset approval/version/effective/refresh metadata.
5. Revalidate Salem on or after October 1, 2026 and Indiana before municipal authority begins in FY2028.

Until those blockers are closed, the correct product status is: **research-complete enough for a conservative governed screening design; not approved for autonomous production matching, `CLEAR` from city/state alone, or tax calculation.**
