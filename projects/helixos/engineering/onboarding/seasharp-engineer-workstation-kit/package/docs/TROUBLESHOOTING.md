# Troubleshooting

Start with read-only diagnostics:

```powershell
.\scripts\Test-SeaSharpDevEnvironment.ps1 -Profile AppDev -WorkspaceRoot C:\dev
.\scripts\Test-SeaSharpLocalStack.ps1 -Product Helix -WorkspaceRoot C:\dev
```

Do not include tokens or complete environment dumps in a support message.

## An item is reported as skipped

A skipped item normally means the compatible tool, repository, package authentication, or configuration is already present. Read the reason printed beside the skip and the final terminal summary. No action is needed when the requirement is satisfied. If the detected version or path is wrong, rerun the environment test for the applicable profile and include the redacted status lines in the escalation bundle.

The scripts must never print secret values. If terminal output unexpectedly contains a credential, stop sharing the transcript, rotate the credential, and report the exposure.

## Command is not recognized after installation

Close and reopen PowerShell so PATH changes are loaded. If Node is managed by `fnm`, initialize `fnm` for the current shell and select the version declared by the repository. Avoid installing a second unmanaged Node that shadows it.

## PowerShell blocks a script

From the extracted package directory:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

Do not change machine-wide policy unless company IT requires it.

## Docker is unavailable

- Start Docker Desktop and wait for the engine to become ready.
- Confirm virtualization/WSL2 requirements are enabled.
- Run `docker version` and `docker compose version`.
- If corporate licensing or device policy blocks Docker, contact IT; the helper cannot bypass policy.

## Git clone returns 401/403 or repository not found

Confirm the company GitHub identity, organization membership, repository team, SSO authorization, and Git Credential Manager session. A private repository may intentionally appear not found when access is missing.

## `npm ci` returns 401/403 for `@zorkacom/*`

Verify that the repository `.npmrc` contains the scope mapping but no secret, and the user-level npm configuration contains the active token. Check package-read permission and organization SSO. Run:

```powershell
npm whoami --registry=https://npm.pkg.github.com
npm config get userconfig
```

Do not print `npm config list` into a shared log because it may reveal sensitive configuration.

## GHCR pull is denied

Confirm the GitHub identity can read the container package and the credential is authorized for organization SSO. Authenticate using the included helper or approved Docker credential flow. Pull the tag selected by the current repository configuration; do not guess an old tag.

## Helix local login or Rule Engine routing is broken

Remove or rename an unintended Helix repository `.env` after first preserving any legitimate local override. Normal local Helix development uses built-in demo defaults. Use `npm run dev:windows`, not Unix-style `npm run dev`, on Windows.

## Helix changes save but workflows remain pending

The local workflow runner is missing. `npm run dev:windows` starts it. When starting services individually, also run:

```powershell
npm run workflow:dev
```

## Port already in use

Identify the owner before stopping anything:

```powershell
$ports = 3000,3001,4000,4173,5082,5173,5174,5433,54329,8080,8081
Get-NetTCPConnection -State Listen |
  Where-Object { $ports -contains $_.LocalPort } |
  Select-Object LocalAddress,LocalPort,OwningProcess
```

Stop only a process or container belonging to your checkout. Source Zorka uses API port `3000`; the Helix self-contained Rule Engine uses `3001`.

## Helix database migration fails just after startup

Docker may have returned before PostgreSQL became healthy. Wait for the container health check, then rerun the migration/bootstrap command. Do not reset the database merely because startup was slow.

## Zorka returns Prisma schema-readiness `503`

Run:

```powershell
pnpm db:migrate:deploy
```

Use `pnpm db:reset` only if Prisma reports unreconcilable local migration history and you accept losing the local demo database.

## Zorka sign-in cannot find a local account

Confirm `pnpm dev` is running, API port `3000` is reachable, and the database was seeded with `pnpm db:seed`. Verify the repository-root `.env` came from the current `.env.example` and that `VITE_API_BASE_URL` points to the current local API.

## Playwright browser executable is missing

From the applicable repository:

```powershell
npx playwright install chromium
# Zorka:
pnpm exec playwright install chromium
```

## Escalation bundle

Provide the failing command, exit code, relevant redacted action/result/skip lines and final summary, product/branch, tool versions, Docker status, and whether the failure occurs before or after repository bootstrap. Never attach `.env`, user `.npmrc`, credential-store exports, full headers, cookies, access tokens, customer data, or private browser traces.
