# Zorka source setup

Install this profile only for engineers assigned to change or validate Zorka source. Helix-only development normally uses the self-contained Rule Engine image.

## Requirements

- Git repository access.
- Node supported by the current checkout.
- Corepack and repository-pinned pnpm (`packageManager` currently specifies `pnpm@10.33.0`).
- .NET 10 SDK.
- Docker Desktop with Docker Compose v2.

## Automated bootstrap

```powershell
.\scripts\Install-SeaSharpDev.ps1 -Profile SourceZorka -WorkspaceRoot C:\dev
.\scripts\Initialize-ZorkaWorkspace.ps1 -WorkspaceRoot C:\dev -SkipStart
```

The initializer prefers versions declared by the checkout and uses the repository-owned bootstrap rather than reproducing its migration and seed logic. It fingerprints successful dependency and setup inputs so unchanged reruns skip completed work.

Run without `-SkipStart` when you want the initializer to keep the stack attached to the current terminal. Otherwise, start `fnm exec --using 22 pnpm dev` from the Zorka checkout after initialization, unless the checkout declares a different Node version.

## Manual equivalent

From the Zorka repository root:

```powershell
corepack enable
pnpm install
pnpm local:setup
pnpm dev
```

`pnpm local:setup` creates a repository-root `.env` from `.env.example` only when missing, starts PostgreSQL, migrates, seeds, and builds packages. Unlike HelixOS, Zorka source development expects the root `.env` created by this workflow.

Assistant features require separately issued Azure OpenAI or OpenAI configuration. They are optional for basic local stack operation and must not be populated with production secrets.

## Default local surfaces

| Surface | URL |
|---|---|
| Zorka PostgreSQL | `localhost:54329` |
| Runtime host | `http://localhost:5082` |
| Public API | `http://localhost:3000/api` |
| API Swagger | `http://localhost:3000/swagger` |
| Studio | `http://localhost:4173` |
| Marketing site | `http://localhost:4174` |
| Embedded consumer | `http://localhost:6173` |

Seeded local sign-in accounts include `owner@demo.zorka.test`, `admin@demo.zorka.test`, `editor@demo.zorka.test`, and `viewer@demo.zorka.test`. These are local demo identities only.

## Verification

```powershell
Invoke-WebRequest http://127.0.0.1:3000/api/health/ready
Invoke-WebRequest http://127.0.0.1:5082/health/live
dotnet test src/engine/Zorka.Cli.Tests/Zorka.Cli.Tests.csproj
dotnet test src/engine/Zorka.Runtime.Host.Tests/Zorka.Runtime.Host.Tests.csproj
pnpm build:packages
pnpm lint:packages
pnpm test:packages
```

Use the narrower repository suites appropriate to a change. Cross-service workflow changes require the relevant E2E suite.

## Running Helix with source Zorka

Source Zorka uses API port `3000`; the self-contained image uses `3001`. Do not run both modes accidentally. Follow HelixOS `docs/local-dev-with-zorka.md` for current integration variables and tenant-isolation workflows. Keep Rule Engine configuration identical for the Helix API and workflow runner.

## Cleanup and reset safety

Stop the stack normally with `Ctrl+C` and `pnpm db:down`. `pnpm db:reset` destroys and recreates the local demo database; run it only after confirming the target and accepting local data loss. Bootstrap helpers must never run it automatically.
