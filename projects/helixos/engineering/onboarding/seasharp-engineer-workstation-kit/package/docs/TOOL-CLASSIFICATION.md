# Required and optional tools

The kit separates the workstation baseline from tools needed only for a specific assignment. An optional profile is optional for the engineer population; after that profile is selected for an assignment, its listed tools are required for that work.

## Required baseline

Every Helix application engineer needs:

| Tool | Purpose | Installation owner |
|---|---|---|
| Windows Package Manager (`winget`) | Installs approved workstation packages | Windows/App Installer prerequisite |
| Git for Windows | Repository access and Git Bash | `AppDev` profile |
| `fnm` | Installs repository-compatible Node versions | `AppDev` profile |
| Node.js 24.19.0 | Current Helix runtime | `AppDev` profile through `fnm` |
| Docker Desktop with Compose v2 | PostgreSQL and the self-contained Rule Engine | `AppDev` profile |

Windows PowerShell 5.1 can execute the kit. PowerShell 7 is recommended but not required.

## Optional by assignment

| Profile or option | Installed tools | Use when |
|---|---|---|
| `SourceZorka` | .NET 10 SDK, Node.js 22, Corepack 0.34.5, repository-pinned pnpm | Changing or validating Zorka source |
| `WebE2E` | Repository-pinned Playwright Chromium | Running browser/E2E suites locally |
| `CloudOps` | Azure CLI, Bicep, GitHub CLI, Python 3, `jq`, and OpenSSL | Following approved Azure or deployment runbooks |
| `-IncludeRecommended` | PowerShell 7 and Visual Studio Code | Engineer prefers the recommended shell/editor |

The Tax Service is an optional product workflow, not a separate global tool profile. Netlify, production access, private owner-development tooling, AI-agent configuration, and personal editor or shell customization are not installed.

## Script behavior

`Install-SeaSharpDev.ps1` prints the required baseline tools, any selected optional-profile tools, and optional tools that were not selected. Missing optional baseline tools are skipped unless `-IncludeRecommended` is supplied. All selected tools are checked before installation and skipped when already available.
