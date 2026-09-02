# Sea Sharp Engineer Workstation Kit

This package prepares a Windows PC for Sea Sharp product development. It standardizes product prerequisites and validates the result without copying another engineer's personal workstation.

It intentionally excludes private owner development, owner-only repositories, personal tools and dotfiles, Codex or Claude configuration, and production credentials.

## Before you begin

1. Read [Access and prerequisites](docs/ACCESS-AND-PREREQUISITES.md).
2. Ask your manager or repository administrator to grant the required access. The scripts cannot grant accounts, licenses, repository membership, package permissions, cloud roles, or secrets.
3. Extract this package to a normal local folder. Do not run it from inside the ZIP archive.
4. Open PowerShell 7 as your normal Windows user. Administrator elevation is needed only when an installer explicitly requests it.

## Recommended path

From the extracted package directory:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\scripts\Test-SeaSharpDevEnvironment.ps1 -Profile AppDev -WorkspaceRoot C:\dev
.\scripts\Install-SeaSharpDev.ps1 -Profile AppDev -WorkspaceRoot C:\dev
.\scripts\Set-SeaSharpPackageAuthentication.ps1 -ConfigureNpm -ConfigureGhcr
.\scripts\Initialize-HelixWorkspace.ps1 -WorkspaceRoot C:\dev -SkipStart
Set-Location C:\dev\HelixOS
fnm exec --using 24.19.0 npm run dev:windows
```

After the stack is ready, run this from a second package terminal:

```powershell
.\scripts\Test-SeaSharpLocalStack.ps1 -Product Helix -WorkspaceRoot C:\dev
```

Use `-WhatIf` on an install or initialization command to preview supported changes. Run `Get-Help <script-path> -Full` for the exact parameters included in this package.

The workspace root is configurable. `C:\dev` is only the recommended default; the scripts do not require a personal folder layout, IDE, shell theme, or terminal profile. Existing repositories are detected and reused when safe.

Engineers who will change Zorka source should also run:

```powershell
.\scripts\Install-SeaSharpDev.ps1 -Profile SourceZorka -WorkspaceRoot C:\dev
.\scripts\Initialize-ZorkaWorkspace.ps1 -WorkspaceRoot C:\dev -SkipStart
Set-Location C:\dev\Zorka
fnm exec --using 22 pnpm dev
```

After the stack is ready, run this from a second package terminal:

```powershell
.\scripts\Test-SeaSharpLocalStack.ps1 -Product Zorka -WorkspaceRoot C:\dev
```

Install browser-test tooling only when the role needs it. Cloud/Azure tooling and the Tax Service are separate optional paths.

## Documentation map

- [Installation walkthrough](docs/INSTALLATION-WALKTHROUGH.md)
- [Authentication](docs/AUTHENTICATION.md)
- [HelixOS setup](docs/HELIXOS-SETUP.md)
- [Zorka source setup](docs/ZORKA-SOURCE-SETUP.md)
- [Browser and E2E testing](docs/BROWSER-AND-E2E.md)
- [Optional Tax Service](docs/TAX-SERVICE.md)
- [Optional CloudOps and Azure](docs/CLOUDOPS-AZURE.md)
- [Security boundaries](docs/SECURITY-BOUNDARIES.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [First-day acceptance checklist](docs/FIRST-DAY-ACCEPTANCE.md)

## Safe reruns

The helpers are intended to be rerunnable. They log each planned action and result to the terminal, including whether an item was installed, configured, already satisfied and skipped, warned, or failed. Review the final summary before closing the terminal.

They check existing state before installing or initializing and skip tools or configuration that already meet requirements. They do not reset databases, overwrite repositories, replace user configuration wholesale, print tokens, or silently remove existing software. A skip is expected when the current installation or configuration is valid; it is not an error.
