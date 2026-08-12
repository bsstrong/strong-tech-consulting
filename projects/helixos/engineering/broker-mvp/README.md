# Broker MVP Engineering Guide

Status: planning complete enough to implement; not a HelixOS repository artifact

Source repository: `C:\dev\HelixOS`

This guide turns the three repository-level implementation plans into an
associate-engineer execution path. The detailed runbooks cover the two MVP pull
requests. Generic role creation is intentionally post-MVP and appears here only
for sequencing and blast-radius awareness.

## Required Outcome

The MVP introduces two authorization concepts:

```text
Carrier
├── existing all-Client roles
│   └── clients.view (displayed as View All Clients)
└── Broker
    └── clients.assigned.view (displayed as View Assigned Clients)
        └── only Clients explicitly assigned to that person in that Carrier
```

The existing Carrier-to-Client relationship remains unchanged. A Client is a
`Company` with a `tenantId`. The MVP adds a separate relationship between the
Carrier person (`Resource`) and an exact Client (`Company`) within that same
Carrier.

## Pull Request Order

### PR 1: View Assigned Clients MVP

Follow [01-view-assigned-clients-pr.md](./01-view-assigned-clients-pr.md).

This PR adds the permission catalog entries, assignment storage, assignment
management, and server-side Client visibility enforcement. It must not create
or grant the Broker role.

After PR 1, production behavior for every existing role is unchanged. The new
`clients.assigned.view` permission is present but has no built-in role grant.

### PR 2: Broker Role MVP

Follow [02-broker-role-pr.md](./02-broker-role-pr.md).

This PR adds the Broker role, grants only `clients.assigned.view`, separates
workspace entry from the legacy CarrierMember permission bridge, and exposes
Broker through the existing role and team-member workflows.

PR 2 must be based on the merged PR 1 head. It must not duplicate or bypass PR
1's visibility policy.

### Post-MVP: Fully Generic Role Creation And Assignment

The later phase adds role lifecycle and assignment across Carrier, Client
Portal, and Platform families. Do not pull generic create/publish/deactivate
work into either MVP PR.

## Merge Gate

The dependency is a security boundary:

```text
PR 1 merged and deployed
  ├── assignment table and RLS exist
  ├── assigned-only directory/detail filtering is active
  ├── direct unassigned Client access is denied
  └── assignment management is usable
          ↓
PR 2 may make Broker assignable
```

Do not merge PR 2 first. Do not temporarily give Broker `clients.view`. Do not
make Broker assignable behind a frontend-only filter.

## MVP Product Decisions

- Keep the stable code `clients.view`; change only its label to **View All
  Clients**.
- Add `clients.assigned.view`, labeled **View Assigned Clients**.
- Add `clients.assignments.manage` for administering the relationship.
- Carrier Admin, Carrier Member, Carrier View, Account Manager, and Market
  Coordinator retain `clients.view` and their current behavior.
- Broker receives only `clients.assigned.view`.
- If both visibility permissions are effective, ALL wins.
- Assign exact Clients only. A parent assignment does not automatically expose
  descendants.
- An assigned child whose parent is not assigned appears as a root. Do not send
  an unassigned ancestor shell or name.
- A Broker with zero assignments sees a safe assigned-specific empty state.
- The MVP assignment workflow is allowed to be two-step: create/assign Broker,
  then manage Assigned Clients. Zero assignments is safe. A partially enforced
  assignment is not.
- Client create, edit, labels, import, payroll, employee, file, note, audit,
  export, and PII access remain controlled by their own permissions. Broker
  receives none of them.

## Blast Radius Summary

### View Assigned Clients: medium-high

The schema change is additive, but Client reads become identity-dependent.
Affected surfaces include the permission catalog, draft and active templates,
RLS, Client directory/detail/capabilities, desktop Client summaries, hierarchy
shaping, metrics, and People & Access. The largest failure mode is a data leak
through a direct Client URL, an unfiltered metric, or an unassigned parent.

Containment:

- Filter in the database before returning Client records.
- Centralize ALL/ASSIGNED/NONE resolution.
- Add direct negative API tests for unassigned and cross-Carrier IDs.
- Preserve `clients.view` and every existing default grant.
- Audit adjacent Client APIs; deny Broker unless the endpoint explicitly adopts
  assigned-client semantics.

### Broker: medium-high

The catalog row is small, but assignment touches workspace access, invitation,
runtime permission resolution, `/api/me`, role options, People & Access, and
the add-team-member workflow. The largest failure mode is a Broker inheriting
the legacy MEMBER -> CarrierMember permission template.

Containment:

- Add a nullable primary permission-role pointer to workspace access.
- Preserve the legacy bridge only when the pointer is NULL.
- Give Broker a complete permission matrix row with one allowed cell.
- Use dynamic role metadata and public role IDs; never authorize by the Broker
  role name.
- Prove existing NULL workspace rows resolve exactly as before.

### Fully Generic Role Creation: high

This changes the authorization control plane across all role families: catalog
lifecycle, template completeness, publish activation, delegation, Carrier
assignment, Client Portal grants, Platform assignments, audit, and recovery.
It can affect nearly every path that produces effective permissions even when
business endpoints themselves remain unchanged.

Containment:

- Deliver catalog lifecycle first, then assignment one family at a time.
- Keep family-specific assignment adapters.
- Protect system roles and root Platform permissions in the API and database.
- Use optimistic catalog revision and atomic publish activation.
- Preserve legacy bridges until equivalence is proven.
- Never ship the generic phase as one cross-family PR.

## Shared Engineering Rules

- Read all repository instruction files before implementing.
- Work on a non-main branch.
- Use forward migrations; never edit an applied migration.
- Keep migration and `seed.ts` behavior identical.
- Use public UUID keys in APIs and bigint IDs only inside repositories/services.
- Enforce tenant and resource authorization in the API and database. UI gating
  is an affordance, not a security boundary.
- Use capability codes, not role-name checks.
- Add Swagger DTOs/decorators and regenerate `src/api/openapi.json` for API
  changes.
- Make logical commits, run the focused tests after each slice, then run the
  complete validation listed in each runbook.

## Cross-PR Handoff Checklist

PR 1 is ready for PR 2 only when all of the following are true:

- `clients.view` displays as View All Clients without changing its code.
- `clients.assigned.view` exists in migration, seed, draft cells, and active
  snapshot cells.
- assignment rows cannot cross Carrier boundaries.
- RLS is enabled and forced.
- an assigned-only test identity sees exactly its assigned Clients.
- unassigned detail requests return tenant-safe not-found behavior.
- assigned-only directory counts and hierarchy contain no unassigned data.
- Client capability lookup checks visibility before returning capabilities.
- Carrier Admin can manage assignments through the intended People & Access
  surface.
- existing roles pass all-Client regression tests.
- no production role receives `clients.assigned.view` yet.

PR 2 is complete only when:

- Broker appears dynamically in Carrier and All Roles.
- Broker has exactly one allowed template permission.
- Broker workspace access does not resolve CarrierMember.
- add-team-member and primary-role replacement use the public Broker role ID.
- a Broker with assigned Clients can read only those Clients.
- a Broker cannot invoke Client writes or adjacent sensitive reads.
- existing workspace users retain their previous effective permissions.

