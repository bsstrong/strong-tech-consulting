# HelixOS setup

## Requirements

- Git repository access.
- Node version required by the checkout (`.node-version` currently specifies `24.19.0`).
- npm, supplied with Node.
- Docker Desktop and Docker Compose v2.
- GitHub Packages read access for private `@zorkacom/*` packages.
- GHCR read access if the configured Rule Engine image is private.

A host PostgreSQL installation is not required; Docker provides the local database.

## Automated bootstrap

```powershell
.\scripts\Initialize-HelixWorkspace.ps1 -WorkspaceRoot C:\dev -SkipStart
```

The helper locates or clones the approved repository, selects the repository-required Node version, installs dependencies, and uses the repository bootstrap commands. It fingerprints successful dependency and setup inputs so unchanged reruns skip completed work. It does not overwrite checkout files or reset a database automatically.

Run without `-SkipStart` when you want the initializer to keep the stack attached to the current terminal. Otherwise, start `fnm exec --using 24.19.0 npm run dev:windows` from the Helix checkout after initialization.

## Manual equivalent

From the HelixOS repository root:

```powershell
npm ci
npm run setup
npm run dev:windows
```

`npm run setup` starts local PostgreSQL, builds workspace packages, applies migrations, and seeds demo data. `npm run dev:windows` starts the self-contained Rule Engine, API, web app, Client Portal, and workflow runner.

Do not copy `.env.example` to `.env` for normal local Helix development. The checked-in example documents deployed settings and can break local demo authentication and Rule Engine routing. Create an override only for a documented need.

## Default local surfaces

| Surface | URL |
|---|---|
| Helix web | `http://localhost:5173` |
| Client Portal | `http://localhost:5174` |
| Helix API | `http://localhost:4000` |
| Self-contained Rule Engine Studio | `http://localhost:8080` |
| Self-contained Rule Engine API | `http://127.0.0.1:3001/api` |
| Rule Engine Swagger | `http://localhost:3001/swagger` |
| PostgreSQL | `localhost:5433` |

The current checkout remains authoritative if ports or scripts change.

## Verification

```powershell
Invoke-WebRequest http://127.0.0.1:3001/api/health/ready
Invoke-WebRequest http://127.0.0.1:4000/api/me -Headers @{ Authorization = "Bearer keith-demo" }
```

Then load the web and Client Portal. Confirm the foreground terminal shows all expected processes, especially the workflow runner. If services are started individually, run `npm run workflow:dev`; otherwise outbox-driven operations remain pending.

Run the baseline integration smoke:

```powershell
npm run test:integration
```

## Normal shutdown

Stop foreground processes with `Ctrl+C`, then from the repository root:

```powershell
npm run infra:dev:down
```

This normal shutdown is distinct from database-reset commands that remove volumes or seeded state.
