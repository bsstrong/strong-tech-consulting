# PR 2 Runbook: Broker Role And Client Assignment Operations

## Goal

Add Broker as an assignable built-in Carrier role whose initial published
template contains exactly one permission: `clients.assigned.view`.

A Broker must be able to enter the Carrier workspace without inheriting the
legacy CarrierMember permission template. The role must appear through the
existing database-backed role catalog in Roles & Permissions, Add Team Member,
and People & Access.

Carrier administrators must also receive a dedicated **Client Assignments** tab
inside Manage Carrier Account. It is the operational workspace for keeping
Client coverage and the sales pipeline moving; assignment is not a secondary
action hidden inside one person's permission details.

## Hard Precondition

PR 1 must already be merged and deployed. Before coding, verify:

- `clients.assigned.view` exists
- assignment storage and RLS exist
- assigned-only directory/detail filtering is active
- assignment list/replace APIs and deterministic enforcement validation are
  available
- direct unassigned Client access is denied
- no existing role receives `clients.assigned.view`

If any item is missing, stop. Do not make Broker assignable and do not grant
Broker `clients.view` as a temporary workaround.

## What Is In This PR

- Broker role definition in migration and seed
- complete Broker draft and active-snapshot matrix rows
- Broker initial allowlist of exactly `clients.assigned.view`
- nullable primary permission-role pointer on Carrier workspace access
- resolver support for that pointer with NULL preserving legacy behavior
- dynamic, assignment-ready Carrier role catalog service/query
- Add Team Member support for Broker as a primary role
- primary-role replacement for an existing Carrier person
- clear separation between a primary role and additive secondary roles
- dynamic Roles & Permissions and People & Access presentation
- dedicated Client Assignments tab in Manage Carrier Account
- people-centric, Client-centric, unassigned, and offboarding assignment views
- drag/drop transfer plus accessible non-drag alternatives
- multi-select bulk assign, transfer, and unassign operations
- attributable assignment history and conflict-safe refresh
- termination/offboarding handoff for remaining Client assignments
- Broker capability, denial, migration, UI, and regression tests

## What Is Not In This PR

- generic role creation
- Client Portal or Platform role assignment changes
- additional Broker permissions
- role-name authorization checks
- automatic Client assignment
- automatic CRM synchronization or CRM write-back
- forecasting, commission, quota, or territory-management systems
- parent/subtree Client assignment
- deletion of role, assignment, invitation, or audit history

## Read Before Editing

In addition to repository instructions, review:

- the merged PR 1 implementation and tests
- `src/packages/db/prisma/schema.prisma`
- `src/packages/db/prisma/seed.ts`
- `src/api/src/common/authorization/permission-resolver.service.ts`
- `src/api/src/common/tenant-access.service.ts`
- `src/api/src/modules/admin-permissions/admin-permissions-people-management.service.ts`
- `src/api/src/modules/admin-permissions/admin-permissions-people.service.ts`
- `src/api/src/modules/tenant-workspace/tenant-workspace.service.ts`
- `src/api/src/modules/tenant-workspace/tenant-workspace.controller.ts`
- `src/web/src/features/tenant-workspace/pages/TenantWorkspaceMembersPage.tsx`
- `src/web/src/features/permissions-people/PermissionsPeoplePanel.tsx`
- `src/web/src/features/admin-console/AdminConsolePage.tsx`
- `scripts/verify/carrier-role-codes.mjs`

The important current behavior is:

```text
tenant_workspace_access.role_code = ADMIN  -> CarrierAdmin template
tenant_workspace_access.role_code = MEMBER -> CarrierMember template
```

Add Team Member already sends a public `carrierRoleId` for non-ADMIN/MEMBER
roles, but it also writes MEMBER workspace access. Without this PR's pointer,
Broker would inherit CarrierMember and violate least privilege.

## Step 0: Establish Baseline And PR 1 Contract

1. Branch from the merged PR 1 head.
2. Confirm the worktree is clean.
3. Exercise an assigned-only PR 1 test fixture and save the result.
4. Run these existing suites before editing:

```powershell
npx tsx --test src/api/src/common/authorization/permission-resolver.service.test.ts
npx tsx --test src/api/src/modules/admin-permissions/admin-permissions-people-management.service.test.ts
npx tsx --test src/api/src/modules/tenant-workspace/tenant-workspace.service.test.ts
npm exec --workspace @helixos/web -- vitest run src/features/tenant-workspace/pages/TenantWorkspaceMembersPage.test.tsx src/features/permissions-people/PermissionsPeoplePanel.test.tsx src/features/admin-console/AdminConsolePage.test.tsx
```

## Step 1: Add The Primary Permission-Role Pointer

### 1.1 Prisma Schema

Add a nullable field to `TenantWorkspaceAccess`:

```text
permissionRoleDefinitionId bigint nullable
```

Map it to `permission_role_definition_id` and add a named relation to
`RoleDefinition`. Add the reverse relation to `RoleDefinition`.

The semantics are:

- NULL: preserve the existing role-code bridge exactly
- non-NULL: this role definition is the primary permission template for the
  workspace access row; do not also apply the role-code bridge

Keep `roleCode` because it still controls workspace-entry semantics:

- ADMIN can manage the Carrier workspace
- MEMBER can enter but is not a Carrier workspace administrator

For Broker, store MEMBER plus a pointer to Broker.

### 1.2 Forward Migration

The migration must:

- add the nullable column
- add an index
- add a foreign key to `role_definition` with RESTRICT deletion behavior
- leave every existing row NULL

Do not backfill. NULL is the compatibility contract that prevents this PR from
changing existing effective permissions.

Add a schema test asserting the column, index, foreign key, and nullable
default.

## Step 2: Add Broker To The Catalog

### 2.1 Fixed Metadata

Use exactly:

```text
code               Broker
name               Broker
displayName        Broker
description        Read-only access to explicitly assigned Clients in a Carrier workspace.
roleFamily         CARRIER
assignableScope    TENANT
sortOrder          60
isSystem           true
isTemplateEditable true
isActive           true
```

### 2.2 Seed

Update `src/packages/db/prisma/seed.ts`:

- add Broker to role-definition creation
- add Broker to `TemplateRoleCodes`
- add only `Broker:clients.assigned.view` to `AllowedTemplatePairs`
- allow the existing full Cartesian draft/snapshot generation to create every
  denied cell
- do not clone CarrierView, AccountManager, or CarrierMember defaults

The initial Broker template must have exactly one `isAllowed = true` cell.

### 2.3 Forward Migration

In one transaction:

1. assert the PR 1 permission definition exists
2. assert the active template-version assumption is valid
3. insert/upsert the Broker role metadata
4. cross join Broker with every active permission definition to create a
   complete draft row
5. set only `clients.assigned.view` allowed
6. insert a complete Broker row set into the ACTIVE snapshot version
7. preserve copied role and permission codes

Do not create only the allowed cell. A missing denied cell makes the matrix and
future publish behavior incomplete.

### 2.4 Database Contract Tests

Assert:

- migration and seed metadata are identical
- Broker has every active permission in draft and active snapshot
- exactly one pair is allowed
- high-risk and sensitive permissions are denied
- clean seed and upgraded database produce the same result
- rerunning seed is idempotent

Commit schema/catalog work when these tests pass.

## Step 3: Add A Shared Assignment-Ready Role Catalog

Extract or introduce a `RoleCatalogService` instead of repeating catalog logic
in People & Access and Tenant Workspace.

The read method should require:

```ts
interface ListAssignableRolesInput {
  roleFamily: "CARRIER" | "CLIENT_PORTAL" | "PLATFORM";
  assignableScope: "TENANT" | "CLIENT_SUBTREE" | "PLATFORM";
}
```

For each returned role, require:

- active role definition
- exact requested family and scope
- complete draft cells for every active permission
- complete cells in the single active snapshot version
- public role ID and human-readable metadata

Return no internal bigint IDs to controllers or web clients.

Move `getCarrierRoleOptions` and server-side role validation onto this service.
Delegation authority remains in the Carrier assignment service; the catalog
service only reports readiness.

Add tests for inactive, wrong-family, wrong-scope, incomplete-draft,
incomplete-snapshot, missing-active-version, and multiple-active-version roles.

## Step 4: Update Runtime Permission Resolution

In `PermissionResolverService.resolveCarrierRoleCodes`:

1. continue loading active additive `resource_role_assignment` rows
2. load workspace access with both `roleCode` and the optional primary
   permission-role definition code
3. for each workspace row:
   - pointer present -> use pointed role code
   - pointer absent -> use `LegacyWorkspaceRoleCodeMap[roleCode]`
4. deduplicate the final code list

Do not apply both the pointer and the legacy bridge for one workspace row.

Expected examples:

```text
MEMBER + NULL pointer        -> CarrierMember
ADMIN  + NULL pointer        -> CarrierAdmin
MEMBER + Broker pointer      -> Broker
MEMBER + Broker pointer
       + AccountManager secondary assignment
                              -> Broker + AccountManager
```

Update `TenantWorkspaceAccessRow` typing and resolver mocks. Tests must prove:

- every legacy NULL case is unchanged
- Broker pointer does not add CarrierMember
- additive roles still combine with the primary role
- inactive/wrong-family pointers fail closed or are rejected at assignment time
- `/api/me` for Broker contains `clients.assigned.view` and none of
  CarrierMember's permissions
- current tokens need not contain `Broker`; authorization comes from the
  database resolver

## Step 5: Make Primary-Role Assignment Explicit

Primary role and additive secondary roles are different operations. Do not use
the existing additive role-assignment endpoint as Broker's primary-role setter.

### 5.1 Add/Change Primary Role API

Add both shared-surface endpoints:

```text
PUT /api/admin/permissions-people/:personId/primary-role
PUT /api/tenant-workspace/permissions-people/:personId/primary-role
```

Recommended body:

```ts
interface ReplacePrimaryCarrierRoleRequest {
  tenantKey?: string; // Platform Admin route only
  roleId: string;     // public role UUID
  reason: string;     // minimum 10 characters
}
```

Use the same Platform and Carrier management authorization boundaries as the
existing role-assignment controllers.

The service transaction must:

1. resolve and lock the active Carrier
2. resolve the active PERSON and workspace access
3. resolve the assignment-ready Carrier role by public ID
4. apply delegation-ceiling validation
5. preserve the final-effective-CarrierAdmin invariant before demotion
6. choose workspace representation:
   - CarrierAdmin -> roleCode ADMIN, pointer NULL
   - CarrierMember -> roleCode MEMBER, pointer NULL
   - any other assignment-ready Carrier role -> roleCode MEMBER, pointer to that
     role definition
7. deactivate an identical additive assignment if one exists, so the same role
   is not displayed as both primary and secondary
8. update workspace access and write an attributable before/after audit event
9. return public primary-role metadata

The CarrierAdmin/CarrierMember checks above are a documented legacy-bridge
adapter. Do not add a Broker branch.

Changing away from Broker must select a replacement primary role or remove
workspace access through the existing explicit removal workflow. Never clear a
Broker pointer and silently fall back to CarrierMember.

### 5.2 Existing Additive Endpoint

Keep `POST .../:personId/role-assignments` for deliberately secondary roles.
Update response/presentation terminology from a generic **Assign role** to
**Add secondary role** where needed.

Do not make Broker primary through an additive row. If the UI permits Broker as
a secondary role, clearly show that permissions are additive; a person with
CarrierMember plus Broker is not a restricted Broker.

For MVP simplicity, it is acceptable to exclude Broker from secondary options
and expose it only in primary-role options, as long as the exclusion is based on
API-provided assignment mode/readiness metadata rather than a frontend role-code
literal.

## Step 6: Update Add Team Member Atomically

The current create request already supports `carrierRoleId`. Extend the
transaction so a selected primary role controls workspace permission
resolution.

For Add Team Member:

- CarrierAdmin selection -> ADMIN + NULL pointer
- CarrierMember selection -> MEMBER + NULL pointer
- Broker or another catalog Carrier primary role -> MEMBER + role-definition
  pointer

The transaction must create or update:

- PERSON Resource
- TenantMembership
- TenantWorkspaceAccess with primary pointer
- invitation state
- audit/outbox/email-delivery rows

Do not also create an additive Broker `resource_role_assignment` for the same
selection. If any validation or outbox write fails, roll back the entire
operation.

Extend `TenantWorkspaceMemberRecord` and its DTO to return:

```ts
primaryRole: {
  roleId: string;
  code: string;
  displayName: string;
}
```

The UI should use `displayName`. It must not infer Carrier Member from
`roleCode: MEMBER` when a primary pointer exists.

The existing two-step MVP is safe:

1. add Broker
2. open Client Assignments filtered to that person and assign coverage

A newly invited Broker with zero assignments sees the assigned-specific empty
state. After creation, link directly to the dedicated Client Assignments tab
with the new person selected. Do not add a per-person assignment dialog to
People & Access.

## Step 7: Handle Delegation Correctly

The current delegation ceiling compares exact permission codes. CarrierAdmin
has `clients.view`, while Broker has the narrower
`clients.assigned.view`. Without an implication rule, CarrierAdmin may be
unable to assign Broker.

Add one centrally tested delegation implication:

```text
clients.view implies authority to delegate clients.assigned.view
```

This implication is for delegation only. It does not grant
`clients.assigned.view` to CarrierAdmin and does not change runtime visibility;
CarrierAdmin remains ALL through `clients.view`.

Implement the implication in a named authorization policy/helper, not inline in
a controller or UI. Test:

- CarrierAdmin can delegate Broker
- a manager with neither code cannot delegate Broker
- a person with only `clients.assigned.view` cannot delegate a role containing
  `clients.view`
- a DENY that removes durable delegation authority is honored
- Platform Admin's existing authorized management path still works

## Step 8: Update Web Surfaces

### Roles & Permissions

No Broker-specific column or static option is needed. Verify the existing API
payload makes Broker appear in:

- All Roles
- Carrier roles
- selected-role details and matrix

Use backend display metadata. Do not add a hard-coded Broker option.

### Add Team Member

- show assignment-ready Carrier primary roles from the role-options API
- submit the public `roleId`
- explain that Broker access is limited to assigned Clients
- after successful Broker creation, select the person and direct the operator
  to the Client Assignments tab
- do not use the role name as an authorization decision; presentation may show
  the backend-returned name

### People & Access

- display primary role separately from secondary roles
- add **Change primary role** using the new PUT endpoint
- retain **Add secondary role** for additive assignments
- warn that changing primary role replaces the current primary permission
  template

Do not place Client assignment controls in this permission-management view.
Link to the Client Assignments tab when assignment work is required.

### Client Assignments

Add a first-class **Client Assignments** section to the existing Manage Carrier
Account navigation. This surface is authorized by
`clients.assignments.manage`; the API remains the enforcement boundary.

The tab must support these operational views without loading the entire Carrier
into browser memory:

- **By Team Member**: active and former Team Members with assignment count,
  assignment status, role, availability, and expandable or paged Client list
- **By Client**: searchable Client portfolio with all assigned Team Members and
  a clear unassigned state
- **Unassigned**: Clients with no active assignment, prioritized for triage
- **Needs handoff**: active assignments owned by inactive, terminated, or
  workspace-revoked people
- filters for Team Member, Client name, lifecycle stage, role, assignment
  state, and active/inactive employment status

Interaction requirements:

- drag one or more selected Clients from one Team Member to another
- offer the same transfer through an accessible action/menu and keyboard flow;
  drag/drop must never be the only path
- bulk assign Clients to a Team Member
- bulk transfer selected assignments from one Team Member to another
- bulk unassign selected assignments into the unassigned queue
- reassign all of a person's active Clients as a guided offboarding action
- preserve unrelated co-assignees when transferring one person's coverage
- require a meaningful reason for every mutation
- preview the affected Client and Team Member counts before a bulk mutation
- show partial selection clearly and never imply success until the server
  transaction commits
- refresh stale data on conflict and preserve the operator's selection when it
  remains valid
- provide assignment history with actor, reason, timestamp, source person,
  destination person, and affected public Client keys

The current PR 1 replace-set API remains useful for exact single-person
reconciliation, but it is not sufficient as the only operational contract.
Add paged assignment-board queries and an atomic transfer command. The transfer
service must:

1. require `clients.assignments.manage` and an attributable actor
2. resolve all person and Client public keys inside the active Carrier
3. lock every affected workspace-access row in stable ID order
4. validate source assignments and destination eligibility before writing
5. revoke the source rows and create destination rows in one transaction
6. preserve unrelated active co-assignees
7. treat a NULL destination as an explicit move to the unassigned queue
8. write one audit event containing public before/after ownership and counts
9. reject stale or conflicting operations without a partial transfer

Server queries own pagination, filtering, counts, and inactive-owner detection.
Do not construct the board by fetching People & Access, the Client directory,
and individual assignment lists in an N+1 fan-out. Keep board query mapping,
transfer-set calculation, and readiness rules in focused pure or application
modules with direct tests; the React tab should orchestrate query state,
selection, and focused child views.

Employment termination and workspace revocation must surface a handoff choice
when active assignments remain. A revoked person cannot retain effective Client
access, but their assignment history must remain attributable. The operator may
transfer all assignments to another eligible person or explicitly place them
in the unassigned queue before completing the handoff. Do not silently delete
assignment history or silently choose a replacement owner.

### Broker Client Experience

The web should already respond to PR 1's ASSIGNED mode. Verify:

- only assigned Client rows appear
- unassigned direct routes show safe not-found behavior
- no create, edit, labels, import, reorganize, onboarding, export, file,
  employee, note, audit, payroll, or sensitive action is exposed
- zero assignments shows **No Clients are assigned to you**

Do not write `roles.includes("Broker")`. Drive the experience from
`visibility.mode` and capability codes.

## Step 9: Prevent New Role-Name Authorization

Update `scripts/verify/carrier-role-codes.mjs` for Broker's canonical catalog
metadata where appropriate. Extend it or add a focused verification script so
production authorization code cannot introduce `Broker` literals outside:

- seed and migration data
- tests and fixtures
- audit/presentation metadata
- documented legacy assignment adapters

The verification should flag Broker in controller/service role arrays and UI
authorization gates.

Run both:

```powershell
npm run verify:carrier-role-codes
npm run verify:platform-admin-guards
```

## Step 10: Required Test Matrix

### Database

- pointer column/foreign key/index and NULL compatibility
- Broker metadata parity between migration and seed
- complete Broker draft and active snapshot
- only `Broker:clients.assigned.view` allowed
- clean seed, upgrade migration, and seed rerun

### Resolver And Bootstrap

- legacy ADMIN/MEMBER NULL rows unchanged
- Broker pointer resolves Broker only
- Broker plus secondary role is additive
- missing/multiple active template version fails closed
- inactive Broker is not resolved/assignable
- `/api/me` Broker capabilities are exactly expected
- person-level DENY on `clients.assigned.view` takes effect on next request

### Primary Role API

- Platform Admin and authorized Carrier Admin can set Broker primary
- unauthorized operator gets 403
- wrong-family, wrong-scope, inactive, and incomplete roles are rejected
- changing primary role is atomic and audited
- identical secondary assignment is deactivated
- last effective Carrier Admin cannot be demoted
- clearing Broker without replacement is rejected
- legacy primary choices produce NULL pointer and correct workspace role

### Client Assignment Operations API

- paged board queries return server-filtered people, Clients, counts, unassigned
  work, and Needs handoff results
- unauthorized operators receive 403 and cross-Carrier public keys reveal
  nothing
- transfer locks affected people in stable order and commits atomically
- transfer preserves unrelated co-assignees
- NULL destination explicitly creates unassigned work without deleting history
- duplicate, inactive, ineligible, missing, and stale inputs fail before writes
- concurrent transfers cannot create duplicate active rows or partial ownership
- reassign-all handles every active assignment for the source person
- audit metadata contains actor, reason, public source/destination person keys,
  public Client keys, and before/after counts
- workspace revocation with remaining assignments requires an explicit transfer
  or unassigned handoff decision

### Add Team Member

- Broker selection writes MEMBER plus Broker pointer
- Broker creation does not write an additive Broker assignment
- invitation/outbox failure rolls back membership, access, and pointer
- existing person and new person flows behave consistently
- current CarrierAdmin/CarrierMember creation is unchanged

### Web

- Broker appears dynamically under All and Carrier filters
- selected Broker matrix contains one allowed permission
- Add Team Member submits Broker public role ID
- People & Access distinguishes primary and secondary roles
- changing primary role warns and refreshes effective access
- Broker handoff opens the Client Assignments tab filtered to that person
- assignment board pages and filters by Team Member, Client, lifecycle, and
  assignment state without client-side security filtering
- drag/drop and the accessible transfer action produce the same command
- bulk transfer, unassign, and reassign-all previews match committed results
- inactive or workspace-revoked owners appear in Needs handoff
- concurrent assignment changes produce a safe conflict refresh, not a partial
  transfer
- no role-name capability gate is introduced

### End-To-End Security

- Broker assigned to Client A sees A in directory/detail
- Broker does not see unassigned Client B
- Broker does not see any Client in Carrier B
- Broker receives safe empty state with no assignments
- Broker cannot invoke Client writes or adjacent reads
- Carrier Admin, Carrier Member, Carrier View, Account Manager, and Market
  Coordinator retain their previous all-Client behavior

## Step 11: Validation Commands

Run focused tests during each slice. Before review, run without a local timeout:

```powershell
npm run db:generate
npm run build:packages
npm run test -w @helixos/db
npm run test -w @helixos/api
npm run openapi:generate -w @helixos/api
npm run openapi:check -w @helixos/api
npm run openapi:check-bodies -w @helixos/api
npm run lint -w @helixos/web
npm run theme:check -w @helixos/web
npm run test -w @helixos/web
npm run build -w @helixos/api
npm run build -w @helixos/web
npm run verify:carrier-role-codes
npm run verify:platform-admin-guards
```

Apply the migration to a clean database and an upgraded PR 1 database. Run the
seed twice.

## Step 12: Suggested Commit Breakdown

1. `feat(db): add Broker role and workspace permission pointer`
2. `feat(auth): resolve primary Carrier permission roles`
3. `feat(api): support primary Carrier role assignment`
4. `feat(api): add atomic Client assignment operations`
5. `feat(web): expose Broker primary role workflows`
6. `feat(web): add Client Assignments operations tab`
7. `test(auth): prove Broker least privilege and assignment handoff`
8. `docs(api): refresh Broker assignment contracts` if needed

Keep PR 1 code reusable. Do not copy its assignment or visibility logic into a
Broker-specific service.

## Manual UAT

1. Start from a database upgraded through PR 1.
2. Sign in as Platform Admin and open Roles & Permissions.
3. Confirm Broker appears under All and Carrier.
4. Confirm its published and draft matrix allows only View Assigned Clients.
5. Add a new team member with Broker as primary role.
6. Confirm the member record displays Broker, not Carrier Member.
7. Open Client Assignments, filter to the Broker, and assign two exact Clients.
8. Sign in as Broker and verify only those two Clients appear.
9. Open an unassigned Client URL and confirm safe not-found behavior.
10. Try create, edit, files, employees, notes, audit, payroll, exports, and
    another Carrier; confirm denial.
11. Drag one assignment to another eligible Team Member and confirm both the
    source and destination portfolios update after commit.
12. Bulk move the remaining assignment to Unassigned, then restore it through
    the accessible transfer action.
13. Mark or use an inactive UAT identity and confirm Needs handoff exposes its
    assignments; complete a reassign-all handoff and verify history.
14. Change Broker primary role to Carrier Member and confirm the pointer clears
    intentionally and CarrierMember capabilities become effective.
15. Recheck an existing pre-migration Carrier Member and Carrier Admin; their
    capabilities must be unchanged.

## PR Description Evidence

Include:

- explicit PR 1 dependency
- before/after workspace-resolution diagram
- Broker permission allowlist
- database migration and compatibility explanation
- automated validation results
- screenshots of matrix, Add Team Member, Client Assignments views and
  transfers, offboarding handoff, People & Access, and Broker directory
- direct API denial evidence
- proof that existing NULL workspace rows are unchanged
- statement that generic role creation remains post-MVP

## Definition Of Done

- Broker exists in fresh and upgraded databases
- Broker has exactly one initial allowed permission
- Broker is available from dynamic catalog-driven UI
- Broker is stored as a primary permission role, not a CarrierMember plus an
  additive label
- runtime resolution never grants CarrierMember through the same workspace row
- assigned Client visibility comes only from PR 1
- primary-role changes and invitations are atomic and audited
- Client Assignments is a full Manage Carrier Account tab with paged operational
  views, bulk/drag transfer, unassigned triage, and offboarding handoff
- assignment transfer is atomic, conflict-safe, attributable, and available
  through an accessible non-drag interaction
- existing workspace behavior is unchanged
- direct least-privilege UAT passes
