# PR 1 Runbook: View Assigned Clients MVP

## Goal

Deliver a complete, safe assigned-Client capability without introducing
Broker. At the end of this PR:

- `clients.view` is displayed as **View All Clients**.
- `clients.assigned.view` exists and restricts reads to exact person-to-Client
  assignments in the active Carrier.
- authorized administrators can manage those assignments through audited APIs.
- existing production roles behave exactly as they did before.
- no built-in production role receives `clients.assigned.view` yet.

This PR is the security prerequisite for Broker. Do not reduce it to catalog
rows plus frontend filtering.

## What Is In This PR

- forward database migration and Prisma schema
- permission catalog, seed, draft, and active-snapshot changes
- tenant-scoped assignment storage and RLS
- ALL/ASSIGNED/NONE Client visibility policy
- filtering for Client directory, detail, hierarchy, metrics, and capabilities
- assignment list/replace APIs for Platform Admin and Carrier administration
- assigned-only directory/detail presentation
- explicit denial of Broker-style assigned access to adjacent Client tabs and
  APIs that are outside the basic Client directory/detail contract
- focused database, API, web, and security regression tests
- updated OpenAPI artifact

## What Is Not In This PR

- Broker role definition or role template
- generic role creation
- parent/subtree assignment semantics
- production Client-assignment operations UI
- drag/drop or bulk reassignment
- termination/offboarding handoff workflows
- capacity, ownership, and pipeline views
- automatic assignment based on CRM ownership
- Client Portal assignment changes
- redesign of every Client-detail tab
- optimistic assignment-set revision; the MVP serializes replacement writes in
  a transaction and may add a richer revision contract post-MVP

## Read Before Editing

Repository instructions:

- `instructions/authorization/permissions.md`
- `instructions/database/general-db-instructions.md`
- `instructions/database/postgresql-standards.md`
- `instructions/node/nestjs.md`
- `instructions/node/node-testing.md`
- `instructions/react/noeffect.md`
- `DESIGN.md`

Primary reference code:

- `src/packages/db/prisma/schema.prisma`
- `src/packages/db/prisma/seed.ts`
- `src/packages/db/prisma/permissions-foundation-schema.test.ts`
- `src/api/src/common/authorization/permission-resolver.service.ts`
- `src/api/src/modules/clients/clients.controller.ts`
- `src/api/src/modules/clients/clients.service.ts`
- `src/api/src/modules/clients/clients.repository.ts`
- `src/api/src/modules/admin-permissions/*permissions-people*`
- `src/web/src/features/client-directory/ClientDirectoryPage.tsx`
- `src/web/src/features/client-detail/ClientDetailPage.tsx`
- `src/web/src/features/permissions-people/PermissionsPeoplePanel.tsx`
- `src/web/src/features/workspace/pages/DesktopWorkspacePage.tsx`

Useful examples:

- permission migration pattern:
  `src/packages/db/prisma/migrations/20260809040000_add_enrollment_change_review_permission/migration.sql`
- tenant table, composite foreign key, audit, and RLS pattern:
  `src/packages/db/prisma/migrations/20260809045000_add_eligibility_exception_review/migration.sql`

## Step 0: Establish A Clean Baseline

1. Create a non-main branch from current `origin/main`.
2. Confirm the worktree is clean.
3. Run the focused existing tests before changing code:

```powershell
npx tsx --test src/packages/db/prisma/permissions-foundation-schema.test.ts
npx tsx --test src/api/src/modules/clients/clients.controller.test.ts
npx tsx --test src/api/src/modules/clients/clients.repository.test.ts
npx tsx --test src/api/src/modules/clients/clients.service.test.ts
npm exec --workspace @helixos/web -- vitest run src/features/client-directory/ClientDirectoryPage.test.tsx src/features/client-detail/ClientDetailPage.test.tsx src/features/permissions-people/PermissionsPeoplePanel.test.tsx
```

If a baseline test fails, record it before proceeding. Do not silently weaken a
test to accommodate the feature.

## Step 1: Add The Permission Catalog Changes

### 1.1 Keep `clients.view` Stable

In `src/packages/db/prisma/seed.ts`, update metadata only:

```text
code        clients.view
label       View All Clients
description View every client directory and client detail record in the active Carrier.
scope       TENANT
risk        LOW
```

Do not rename the code. Existing API guards, drafts, snapshots, and overrides
must continue referencing `clients.view`.

### 1.2 Add `clients.assigned.view`

Add this canonical permission near the existing Client permissions:

```text
code        clients.assigned.view
label       View Assigned Clients
description View only client directory and client detail records explicitly assigned to the current person in the active Carrier.
appSection  Carrier Workspace
featureArea Clients
scope       TENANT
risk        LOW
sortOrder   205
```

Do not add it to `AllowedTemplatePairs` in PR 1. Every current role gets a
complete draft/snapshot cell with `isAllowed = false`.

### 1.3 Add `clients.assignments.manage`

Add a separate management permission:

```text
code        clients.assignments.manage
label       Manage assigned Client access
description Assign or revoke a Carrier person's access to exact Clients.
appSection  Carrier Workspace
featureArea Clients
scope       TENANT
risk        HIGH
sortOrder   240
```

Add only `CarrierAdmin:clients.assignments.manage` to
`AllowedTemplatePairs`. Carrier Member, Carrier View, Account Manager, Market
Coordinator, and all Client Portal roles default to denied.

The Platform Admin controller uses its existing Platform permission-management
authorization. Do not add a Carrier-family permission to PlatformAdmin.

### 1.4 Forward Migration

Create one forward migration. Do not edit the June permissions-foundation
migration.

The migration must:

1. update the `clients.view` label and description in place
2. upsert `clients.assigned.view`
3. upsert `clients.assignments.manage`
4. cross join both permissions to every active role definition to create all
   missing draft cells
5. set `clients.assignments.manage` allowed only for CarrierAdmin
6. set `clients.assigned.view` denied for every current role
7. create matching cells in the single ACTIVE snapshot version
8. fail closed or fail the migration if active-version assumptions are invalid

Use idempotent `ON CONFLICT` behavior where the repository's migration pattern
does so. Do not overwrite unrelated customized draft cells.

### 1.5 Catalog Tests

Update `permissions-foundation-schema.test.ts` or add a focused schema test.
Assert:

- the `clients.view` code is unchanged and label is View All Clients
- both new permission definitions match seed metadata
- every template role has draft and active-snapshot cells for the new codes
- only CarrierAdmin defaults to `clients.assignments.manage`
- no current role defaults to `clients.assigned.view`
- migration and seed allowlists agree

Commit this catalog slice after its tests pass.

## Step 2: Add Assignment Storage

### 2.1 Prisma Model

Add a `ResourceClientAssignmentStatus` enum with `ACTIVE` and `REVOKED`, then
add `ResourceClientAssignment` mapped to
`helixos.resource_client_assignment`.

Required fields:

```text
resourceClientAssignmentId   bigint identity primary key
resourceClientAssignmentKey  UUID public key, unique
tenantId                     bigint
resourceId                   bigint target person
clientId                     bigint assigned Company
status                       ACTIVE or REVOKED
assignedAt                   timestamptz
revokedAt                    nullable timestamptz
revokedBy                    nullable bigint Resource actor
reason                       nonblank text
createdBy                    bigint Resource actor
updatedBy                    bigint Resource actor
createdAt                    timestamptz
updatedAt                    timestamptz
```

Add named relations to the target, created-by, updated-by, and revoked-by
Resources. Add the reverse collections to `Resource` and `Company` when Prisma
requires them.

Use the existing Company composite uniqueness on `(tenantId, id)` for the
tenant-safe Client foreign key. The database relationship must prevent a row
whose `tenant_id` names Carrier A from pointing at a Client in Carrier B.

### 2.2 Migration DDL

The migration must include:

- bigint identity/sequence primary key
- UUID public key and unique index
- composite foreign key `(tenant_id, client_id)` to
  `client(tenant_id, client_id)`
- target and actor Resource foreign keys
- one ACTIVE row per `(tenant_id, resource_id, client_id)` using a partial
  unique index
- lookup index `(tenant_id, resource_id, status, client_id)`
- reverse-management index `(tenant_id, client_id, status, resource_id)`
- status/timestamp consistency check:
  - ACTIVE -> `revoked_at` and `revoked_by` are NULL
  - REVOKED -> both are present
- nonblank `reason` check
- table and important-column comments
- `ENABLE ROW LEVEL SECURITY`
- `FORCE ROW LEVEL SECURITY`
- `tenant_isolation` USING and WITH CHECK policy based on
  `helixos.current_tenant_id`
- SELECT, INSERT, and UPDATE grants to `helixos_app`
- sequence usage/select grants to `helixos_app`

Do not delete a row when access is removed. Update it to REVOKED and retain the
actor, reason, and timestamp. A later reassignment creates a new ACTIVE row.

### 2.3 Reset Order

Update the seed/reset deletion order so assignments are removed before their
Resource, Company, or Tenant parents. Update
`src/packages/db/prisma/seed-reset-order.test.ts` if its contract requires it.

### 2.4 Database Tests

Add `src/packages/db/prisma/assigned-client-visibility-schema.test.ts` and
assert the DDL contract. Add an integration-style RLS test if an existing DB
test harness supports it.

Minimum cases:

- cross-Carrier Client relationship rejected
- duplicate ACTIVE relationship rejected
- revoked history retained
- reassignment after revocation accepted
- invalid status/timestamp combination rejected
- tenant A cannot read or write tenant B rows through the app role

Run `npm run db:generate` after the schema change and commit generated schema
consumers only when they are source-controlled by the repository.

## Step 3: Introduce One Client Visibility Policy

Create `src/api/src/modules/clients/client-visibility.service.ts` and its test.

Use this domain contract:

```ts
export type ClientVisibility =
  | { mode: "ALL" }
  | { mode: "ASSIGNED"; resourceId: bigint };
```

The public method should accept the authenticated request and route
`tenantCode`. It must:

1. validate route/header Carrier consistency
2. require an attributable `resourceId`
3. resolve the active tenant permission codes once
4. return ALL when `clients.view` is effective
5. otherwise return ASSIGNED when `clients.assigned.view` is effective
6. otherwise throw `ForbiddenException`

Add a public tenant-capability resolution method to
`PermissionResolverService` if needed; do not access its private context
builders through casts. Preserve override rules: DENY wins, and ALL wins only
when `clients.view` remains effective after overrides.

Do not implement this by catching a failed `clients.view` guard. Do not inspect
role codes. Unit-test ALL, ASSIGNED, neither, both, missing resource, header
mismatch, and DENY outcomes.

Register the new service in `ClientsModule` and inject it normally.

## Step 4: Enforce Visibility In The Core Clients Module

### 4.1 Controller

Replace `requireClientsView` for these three routes:

- `GET /api/tenants/:tenantCode/clients`
- `GET /api/tenants/:tenantCode/clients/:companyId`
- `GET /api/tenants/:tenantCode/clients/:companyId/capabilities`

Resolve visibility once per request and pass it into the service/repository.
For capability lookup, prove the Client is visible before returning any
capability metadata.

### 4.2 Repository

Extend these methods with `ClientVisibility`:

- `listAccessibleCompanies`
- `findCompanyOrThrow`

For ASSIGNED, add an EXISTS/relation predicate requiring an ACTIVE
`resource_client_assignment` matching:

- the active `tenantId`
- current `resourceId`
- candidate Client ID

The assignment predicate belongs in the database query. Never load all Carrier
Clients and filter by assignment in Node or React.

For an unassigned or cross-Carrier detail key, return the existing tenant-safe
`Company not found` behavior. Do not reveal whether the Company exists.

### 4.3 Hierarchy And Parent-Name Safety

The current repository includes `parentCompany`, and the service uses parent
names during search and tree shaping. That can leak an unassigned parent.

For ASSIGNED mode:

- do not expose an unassigned `parentCompany` relation
- do not search an unassigned parent's name
- normalize `parentCompanyId` to NULL when the parent is not also in the
  assigned result set
- render that assigned Client as a tree root
- include normal parent/child nesting only when both records are assigned

Add a test where only a child is assigned. Its directory row must appear, but
the parent's key and legal name must not appear anywhere in the response.

### 4.4 Detail Metrics

`ClientsService.getCompanyDetail` currently computes descendant IDs and then
loads employee/payroll/census metrics. In ASSIGNED mode, descendants must come
only from the assigned Company set. Do not count an unassigned descendant.

Keep exact-assignment semantics. Assigning a parent is not permission to its
children.

### 4.5 Response Contract

Add this to the shared directory and capability response contracts:

```ts
visibility: {
  mode: "ALL" | "ASSIGNED";
}
```

Update:

- `src/packages/shared/src/company-domain.ts`
- `src/api/src/modules/clients/clients.response.dto.ts`
- controller/service tests
- desktop empty response fixtures
- web MSW fixtures

This field is presentation metadata. The API query remains the security
boundary.

## Step 5: Close Adjacent Client Read Bypasses

The Broker contract for MVP is the basic Client directory/detail experience,
not every tab hanging off Client detail.

Perform a route inventory before editing:

```powershell
rg -n '@(Get|Post|Put|Patch|Delete)|companyId|clientId|employeeId|fileId|clients\.view|ensureRole|requireApiPolicy' src/api/src/modules
```

Classify every route reachable from Client directory/detail:

| Class | Required behavior |
| --- | --- |
| Core directory/detail/capabilities | Use ALL/ASSIGNED visibility. |
| Adjacent read not included in Broker MVP | Require existing `clients.view` plus tenant/resource ownership, so Broker is denied. |
| Independent action | Keep its explicit action permission and ownership check. Do not let `clients.assigned.view` satisfy it. |

At minimum review and test:

- Client state history
- files list, download, and preview, including routes keyed only by `fileId`
- Client notes
- Client audit
- employees list and employee detail, including routes keyed only by
  `employeeId`
- payroll batches
- payroll-cycle data
- eligibility runs and census runs
- exports and downloads
- desktop widgets and global Client search

Several of these currently rely on a tenant-header check, RLS, or a raw role
array rather than the published permission resolver. Replace those legacy
checks in the affected workflow. Do not add `Broker` to `TenantAccessRoles`.

For an endpoint keyed only by an employee/file/other child public key, resolve
its owning Client first, validate tenant ownership, and then perform the
permission check. Never authorize a child record solely because its tenant
matches.

Add direct tests proving an assigned-only identity cannot call the adjacent
endpoint even for an assigned Client unless a separate required permission is
explicitly granted.

## Step 6: Add Assignment Management APIs

Create a focused `AssignedClientAccessService` in the admin-permissions module.
Do not put this logic in a controller.

Add both controller shapes because `PermissionsPeoplePanel` is shared between
Platform Admin and Carrier administration:

```text
GET /api/admin/permissions-people/:personId/client-assignments?tenantKey=<uuid>
PUT /api/admin/permissions-people/:personId/client-assignments

GET /api/tenant-workspace/permissions-people/:personId/client-assignments
PUT /api/tenant-workspace/permissions-people/:personId/client-assignments
```

Recommended PUT body:

```ts
interface ReplaceClientAssignmentsRequest {
  tenantKey?: string; // required only on Platform Admin route
  clientIds: string[]; // Company public UUID keys
  reason: string;      // trimmed, minimum 10 characters
}
```

Recommended response:

```ts
interface ClientAssignmentsResponse {
  personId: string;
  tenantKey: string;
  assignments: Array<{
    clientId: string;
    clientName: string;
  }>;
}
```

Authorization:

- Platform Admin route: retain the controller's existing
  `admin.permission_overrides.manage` Platform permission gate.
- Carrier route: require `clients.assignments.manage` in the active Carrier.
- both routes: require an attributable actor Resource.

Replacement transaction:

1. resolve active Carrier by public tenant key
2. lock the target person's `tenant_workspace_access` row so two replacement
   writes cannot interleave
3. verify the target is an active PERSON with active workspace access in that
   Carrier
4. reject duplicate Client keys in the request
5. resolve every public Client key inside that Carrier
6. reject the entire request if any key is missing or cross-Carrier
7. load current ACTIVE assignments
8. revoke removed rows with actor/timestamp/reason
9. leave unchanged rows untouched
10. create new ACTIVE rows for additions
11. write one attributable audit event containing public keys and before/after
    counts
12. commit all changes atomically

An empty list intentionally revokes all assignments. A failed validation must
write nothing.

Add Zod request/response DTOs and complete Swagger decorators. Regenerate
`src/api/openapi.json`.

## Step 7: Add The Assigned-Only Client UX

### 7.1 Do Not Ship A Tactical Assignment Dialog

PR 1 intentionally exposes the audited assignment APIs without adding a
per-person **Assigned Clients** action to People & Access. That interaction does
not scale to the operational problem: Carrier teams need to see people and
Client portfolios together, move work between owners, reassign many Clients,
recover unassigned work, and complete safe employment-termination handoffs.

The full product interaction belongs in PR 2 as a dedicated **Client
Assignments** tab under Manage Carrier Account. PR 1 validates list/replace,
empty assignment, and restoration through the API and deterministic UAT reset
tooling. Do not add temporary web endpoint builders or dialog state here.

### 7.2 Client Directory

For `visibility.mode === "ASSIGNED"`:

- show concise copy such as **Clients assigned to you**
- use an empty state that says no Clients are assigned
- never say the Carrier has no Clients
- hide create, import, reorganize, and other write affordances unless their
  independent capabilities exist
- render the already-filtered hierarchy returned by the API

Do not filter response rows in React.

### 7.3 Client Detail

Use capability response `visibility.mode` to keep an assigned-only user on the
basic read-only Client experience. Hide tabs/actions whose APIs require
`clients.view` or another capability. Direct URLs to hidden tabs must render a
safe unavailable state or redirect to Overview; the API must still deny them.

Do not check for a future Broker role name. This UX belongs to the permission.

### 7.4 Desktop

`DesktopWorkspacePage` loads the Client directory for window labels and desktop
state. Its query must inherit the same filtered endpoint. Update its response
fixtures for `visibility`; do not add a second unfiltered query.

## Step 8: Required Test Matrix

### Database

- schema, constraints, partial uniqueness, and RLS cases from Step 2
- permission metadata and seed/migration parity
- all new draft and active-snapshot cells exist
- seed reset is idempotent

### Visibility Policy

- ALL for effective `clients.view`
- ASSIGNED for effective `clients.assigned.view`
- ALL when both are present
- 403 when neither is present
- missing Resource is denied
- DENY override changes the effective mode correctly
- Carrier and Platform/Client Portal populations do not leak into each other

### Clients API

- existing all-Client identity sees unchanged results
- assigned identity sees exactly its ACTIVE assignments
- revoked assignment disappears on next request
- Client in another Carrier never appears
- unassigned direct detail returns tenant-safe not found
- unassigned capability lookup returns tenant-safe not found
- filters/search/counts/plan metrics/employee totals include assigned data only
- assigned child with unassigned parent is a root and leaks no parent metadata
- exact parent assignment does not expose an unassigned child

### Adjacent API Security

- assigned-only identity is denied from files, notes, audit, employees, payroll,
  eligibility, exports, and other non-MVP reads
- direct child IDs cannot bypass Client visibility
- existing roles with their current permissions still succeed
- write operations still require their own permission

### Assignment Management

- Platform Admin authorization success and failure
- Carrier management-permission success and failure
- target missing workspace access -> not found/denied
- duplicate request keys -> 400
- cross-Carrier key -> entire PUT rejected
- empty list revokes all
- replacement is atomic on injected failure
- audit actor, reason, and public before/after identifiers are correct
- simultaneous replacements serialize on the workspace row

### Web

- assigned copy and empty state
- no frontend row filtering
- no write controls from assigned read permission alone
- unassigned detail not-found handling
- assigned-only detail hides adjacent tabs/actions
- all-Client users retain existing Client page behavior

## Step 9: Validation Commands

Run focused tests while developing. Before requesting review, run without a
local timeout:

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
npm run verify:platform-admin-guards
```

Apply the migration to both a clean database and an upgraded local database.
Run the seed twice and verify no duplicate permissions, snapshots, or
assignments are created.

## Step 10: Suggested Commit Breakdown

1. `feat(db): add assigned client access foundation`
2. `feat(auth): enforce assigned client visibility`
3. `feat(api): add assigned client management`
4. `feat(web): present assigned-only client access`
5. `test(auth): cover assigned client isolation`
6. `docs(api): refresh assigned client contracts` if OpenAPI/docs are not
   naturally included with the prior commits

Each commit should build and have its relevant focused tests passing.

## PR Description Evidence

Attach or describe:

- migration and RLS design
- permission default table before and after
- API route classification inventory
- automated test results
- manual UAT with two Carriers and at least three Clients
- screenshot of assigned-only directory and empty state
- proof that an unassigned direct URL is denied
- explicit statement that no built-in role has `clients.assigned.view` yet

## Definition Of Done

- all required catalog, schema, API, web, and test work is complete
- existing roles retain all-Client visibility
- assigned-only access is enforced server-side and is tenant-safe
- adjacent Client data is not exposed through direct URLs
- assignment management is attributable and atomic
- OpenAPI is current
- PR 1 is merged and deployed before PR 2 becomes assignable
