# Payroll Provider Management Stacked-PR Local Review

## Purpose

Use this runbook during PR C's final review cycle to test and visually review the complete Payroll Provider Management refactor. The top branch contains every preceding branch and is the full-feature integration build. This is not an intermediate implementation or stack-handoff procedure.

This runbook supplements the [implementation plan](./20260812T022213Z_payroll-provider-management-page-refactor-plan.md). Current HelixOS `AGENTS.md` and local-development documentation remain authoritative.

## Stack contract

The planned branches are:

```text
main
└── codex/payroll-provider-refactor-ui       (PR A -> main)
    └── codex/payroll-provider-refactor-state (PR B -> PR A branch)
        └── codex/payroll-provider-refactor-final (PR C -> PR B branch)
```

`codex/payroll-provider-refactor-final` is the integration tip. Do not create a fourth aggregate pull request. Use the integration-tip branch, its exact commit SHA, and a `main...integration-tip` comparison for whole-feature review.

All three pull requests remain Draft until the owner audits the work and explicitly authorizes promotion. That owner-audit hold is independent of automated review and CI gates. A successful intermediate build allows work to continue up the stack but does not authorize a Draft/Ready state change.

## Intermediate handoff policy

Before branching the next PR or handing an updated stack branch to another agent, run only the affected workspace build. For this web-only stack:

```powershell
npm run build -w @helixos/web
```

Do not run the focused suite, full suite, lint, theme check, complete UAT, or this runbook solely before or after an intermediate handoff or merge-forward propagation. Targeted checks may be used to diagnose an implementation issue. Run the complete applicable validation matrix on each PR's exact current head when that PR enters its final review cycle. Use the remainder of this runbook for the PR C whole-feature final review.

## Prerequisites

- Windows PowerShell.
- Git, Node.js, npm, Docker Desktop, and other versions required by the current HelixOS repository.
- A current local HelixOS checkout at `C:\dev\HelixOS`.
- Read access to all three remote stack branches.
- No other Helix worktree using local ports `5173`, `5174`, `4000`, or `5433`.
- Current repository guidance read from:
  - `C:\dev\HelixOS\AGENTS.md`
  - `C:\dev\HelixOS\docs\local-dev-with-zorka.md`
  - the Manual UAT section of the implementation plan linked above.

The published self-contained Rule Engine image is sufficient because this refactor changes only Helix web code. Source Rule Engine mode is unnecessary unless another change in the composed stack explicitly requires it.

## 1. Fetch and verify the stack

Set review-specific variables. Replace `<PR-A-BASE-SHA>` with the exact base recorded when PR A was created.

```powershell
$HelixCheckout = "C:\dev\HelixOS"
$IntegrationWorktree = "C:\dev\HelixOS-payroll-provider-full-review"
$PrARef = "origin/codex/payroll-provider-refactor-ui"
$PrBRef = "origin/codex/payroll-provider-refactor-state"
$PrCRef = "origin/codex/payroll-provider-refactor-final"
$StackBaseSha = "<PR-A-BASE-SHA>"

git -C $HelixCheckout fetch origin --prune
```

Verify that each later branch contains its parent:

```powershell
git -C $HelixCheckout merge-base --is-ancestor $PrARef $PrBRef
if ($LASTEXITCODE -ne 0) {
  throw "PR B does not contain the current PR A head. Refresh the stack before review."
}

git -C $HelixCheckout merge-base --is-ancestor $PrBRef $PrCRef
if ($LASTEXITCODE -ne 0) {
  throw "PR C does not contain the current PR B head. Refresh the stack before review."
}
```

Do not continue when either ancestry check fails. Testing an out-of-date top branch does not validate the full current stack.

## 2. Create an isolated integration worktree

Do not reuse an implementation worktree or switch another developer's active branch.

```powershell
if (Test-Path -LiteralPath $IntegrationWorktree) {
  throw "The integration-review path already exists. Use a different explicit path or remove the old clean worktree with git worktree remove."
}

git -C $HelixCheckout worktree add --detach $IntegrationWorktree $PrCRef
Set-Location $IntegrationWorktree
```

Record the exact content being reviewed:

```powershell
$IntegrationHeadSha = (git rev-parse HEAD).Trim()
$IntegrationTreeSha = (git rev-parse "HEAD^{tree}").Trim()

Write-Output "Integration head: $IntegrationHeadSha"
Write-Output "Integration tree: $IntegrationTreeSha"
git status --short --branch
```

The worktree must be clean. Record both SHAs in the review evidence. Whole-feature approval is valid only for this exact integration head.

## 3. Inspect the complete feature diff

Review the complete stack from its recorded base:

```powershell
git log --graph --decorate --oneline $StackBaseSha..HEAD
git diff --stat $StackBaseSha...HEAD
git diff --check $StackBaseSha...HEAD
git diff $StackBaseSha...HEAD
```

Also inspect base drift against current `origin/main`:

```powershell
git diff --stat origin/main...HEAD
git diff --name-only $StackBaseSha..origin/main
```

If `origin/main` advanced in overlapping payroll-provider code, tests, shared contracts, theme files, or API contracts, stop. Integrate the current base into PR A, propagate it through PR B and PR C, and restart this runbook from the new top head.

For browser review, the full comparison is:

```text
https://github.com/helixosio/helixos/compare/main...codex/payroll-provider-refactor-final
```

GitHub's normal PR C diff shows only PR C relative to PR B. Use the comparison above or the local `$StackBaseSha...HEAD` diff for the whole initiative.

## 4. Run final-review automated validation

Install exactly from the committed lock file:

```powershell
npm ci
```

During PR C's final review cycle, run the complete composed validation without a local timeout:

```powershell
npm run build:packages

npm exec --workspace @helixos/web -- vitest run src/features/utilities/payroll-providers

npm run lint -w @helixos/web
npm run theme:check -w @helixos/web
npm run test -w @helixos/web
npm run build -w @helixos/web
```

Requirements:

- zero failures and zero skipped payroll-provider tests;
- no lint, type, theme, or build failure;
- all behavior-traceability rows in the implementation plan have evidence;
- no test timeout increase or weakened assertion used to obtain a pass;
- the focused local elapsed time is recorded as directional evidence only.

Do not treat a local runner timeout by itself as a functional failure. Rerun without the local time limit when a result is required.

## 5. Start the complete application locally

The commands below use the self-contained Rule Engine mode documented by HelixOS. Run them from the integration worktree.

```powershell
npm run infra:dev:up
npm run build:packages
npm run db:migrate
npm run db:seed

$env:AUTH_MODE = "demo"
$env:ZORKA_API_BASE_URL = "http://127.0.0.1:3001"

npm run dev:windows
```

The launcher starts the local Helix services and the published self-contained Rule Engine image. Wait for the API and web application to finish starting.

Smoke checks:

```powershell
Invoke-WebRequest http://127.0.0.1:4000/api/me -Headers @{ Authorization = "Bearer keith-demo" }
Invoke-WebRequest http://127.0.0.1:3001/api/health/ready
```

Then:

1. Open `http://localhost:5173`.
2. Select `Keith Elder (PlatformAdmin)` / `keith-demo`.
3. Navigate to **Admin Console -> Payroll Provider Management**, or open `http://localhost:5173/admin/console/payroll-provider-management`.
4. Confirm the page heading is **Payroll Provider Management** before beginning UAT.

If another checkout owns port `5433` or a foreground Helix process owns an application port, stop that checkout through its documented shutdown path. Do not delete Docker volumes merely to resolve a port collision.

## 6. Run whole-feature visual and functional UAT

Execute all steps in the implementation plan's Manual UAT section, not only the rows changed in PR C.

At minimum, reviewers must visually inspect:

- page, toolbar, tabs, cards, drawer, dialogs, loading surfaces, and error surfaces;
- responsive behavior inside a resized Helix window;
- keyboard focus order, required markers, disabled states, tab semantics, and confirmation dialogs;
- provider switching with no prior-provider draft leakage;
- editable fields during a pending Save while provider-changing actions remain locked;
- CSV, XLSX, column, client-input, row-rule, Preview, Advanced JSON, create, Save, validation, and Publish workflows;
- extractor-only behavior with no import-config request;
- success, validation, detail-load, save, preview, and publish error feedback;
- approved `Payroll Router` wording and absence of prohibited vendor branding.

Capture screenshots for the main page, each tab, provider drawer, create dialog, representative confirmation/error states, and at least one narrow/resized window. A short screen recording may supplement screenshots but does not replace the written UAT result.

## 7. Record the whole-feature evidence checkpoint

Record this in the top PR description or its designated full-feature review comment:

```text
Full-feature integration review
- Stack base SHA: <sha>
- PR A head SHA: <sha>
- PR B head SHA: <sha>
- PR C/integration head SHA: <sha>
- Integration tree SHA: <sha>
- Full compare: https://github.com/helixosio/helixos/compare/main...codex/payroll-provider-refactor-final
- Focused validation: <command and result>
- Full web validation: <commands and results>
- Manual UAT: <pass/fail and evidence links>
- Visual review: <reviewer and evidence links>
- Residual risks: <none or explicit list>
```

Whole-feature local approval does not replace the owner's audit or any PR's required exact-head self-review, Draft feedback, CI, reviewer request, or final-review gate.

## 8. Refreshing the stack after changes

Any change to PR A must be propagated into PR B and then PR C. Any change to PR B must be propagated into PR C. Use the repository-approved non-force strategy; do not rewrite another developer's reviewed branch history.

Conceptually:

```text
update PR A
-> merge the current PR A branch into PR B
-> build and push PR B
-> merge the current PR B branch into PR C
-> build and push PR C
-> defer complete validation until the affected PR's final review cycle
```

The full-feature checkpoint is stale when:

- any stack head changes;
- a lower branch is not an ancestor of the branch above it;
- current `main` advances in overlapping code or changes a review premise;
- conflict resolution changes the integration tree;
- required tests, UAT data, or local runtime configuration change materially.

If a final-review checkpoint already exists, record a new integration head/tree and rerun automated validation plus the complete UAT during the affected final review cycle. Before final review begins, a new head requires only the intermediate build gate. Do not carry visual signoff from an older top head.

## 9. Promotion and merge order

Keep the entire stack Draft until the owner completes the audit and explicitly authorizes promotion. After that authorization, process the stack bottom-up under the current HelixOS lifecycle:

1. PR A runs its complete applicable validation matrix on the exact head during final review, then completes its remaining authorized lifecycle steps.
2. Refresh PR B's base against the resulting current `main`; run the intermediate web build while propagating the stack.
3. PR B runs its complete applicable validation matrix on the exact head during final review, then completes its remaining authorized lifecycle steps.
4. Refresh PR C's base against current `main`; run the intermediate web build while propagating the stack.
5. PR C runs its complete applicable validation matrix and this whole-feature UAT runbook on the exact head during final review, then completes its remaining authorized lifecycle steps.

Do not promote any PR to Ready solely because the integration worktree passed. Promotion, reviewer requests, Slack writes, merge, and release remain governed by current owner-authored repository policy.

## 10. Shutdown and remove the review worktree

Stop foreground processes with `Ctrl+C`. From the integration worktree, stop its local infrastructure when it is no longer needed:

```powershell
npm run infra:dev:down
git status --short
```

The worktree must be clean before removal. Then return to the primary checkout and remove only the explicit integration-review worktree:

```powershell
Set-Location $HelixCheckout
git -C $HelixCheckout worktree remove $IntegrationWorktree
git -C $HelixCheckout worktree prune
```

Do not use recursive filesystem deletion to remove a Git worktree.
