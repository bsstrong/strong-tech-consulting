# Installation walkthrough

## 1. Extract and inspect

Extract the package, open PowerShell 7 in the extracted directory, and review the planned actions:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\scripts\Test-SeaSharpDevEnvironment.ps1 -Profile AppDev -WorkspaceRoot C:\dev
.\scripts\Install-SeaSharpDev.ps1 -Profile AppDev -WorkspaceRoot C:\dev -WhatIf
```

`Set-ExecutionPolicy -Scope Process` affects only the current PowerShell process. Do not weaken machine-wide policy.

## 2. Choose a workspace root

`C:\dev` is the recommended default, not a requirement. Use another local path if company policy or disk layout requires it:

```powershell
$workspaceRoot = "D:\Development"
.\scripts\Install-SeaSharpDev.ps1 -Profile AppDev -WorkspaceRoot $workspaceRoot
```

Avoid OneDrive-synchronized folders, network shares, and paths with unusually restrictive permissions. The scripts create only their required directories and reuse existing valid checkouts.

## 3. Install a profile

For HelixOS application development:

```powershell
.\scripts\Install-SeaSharpDev.ps1 -Profile AppDev -WorkspaceRoot C:\dev
```

For engineers changing Zorka source:

```powershell
.\scripts\Install-SeaSharpDev.ps1 -Profile SourceZorka -WorkspaceRoot C:\dev
```

To include the recommended but non-required PowerShell 7 and Visual Studio Code packages:

```powershell
.\scripts\Install-SeaSharpDev.ps1 -Profile AppDev -WorkspaceRoot C:\dev -IncludeRecommended
```

For browser-test dependencies or CloudOps tooling, use the corresponding supported profile shown by:

```powershell
Get-Help .\scripts\Install-SeaSharpDev.ps1 -Full
```

The script reports required baseline tools, selected optional-profile tools, and optional tools separately. Items that are already installed at a compatible version are reported as satisfied/skipped instead of being reinstalled. Configuration steps likewise skip settings that are already correct. Warnings and failures remain visible in the final result summary; save a redacted transcript when support needs the evidence.

Restart PowerShell after installation if the command reports that PATH or virtualization changes require it. Start Docker Desktop and wait for the engine to report ready.

## 4. Configure authentication

Follow [Authentication](AUTHENTICATION.md), then run the authentication helper. Enter secrets only at its interactive secure prompts:

```powershell
.\scripts\Set-SeaSharpPackageAuthentication.ps1 -ConfigureNpm -ConfigureGhcr
```

Never pass a token on a command line that could be retained in shell history.

## 5. Initialize products

HelixOS:

```powershell
.\scripts\Initialize-HelixWorkspace.ps1 -WorkspaceRoot C:\dev -SkipStart
```

Zorka source, when required:

```powershell
.\scripts\Initialize-ZorkaWorkspace.ps1 -WorkspaceRoot C:\dev -SkipStart
```

These helpers are for non-destructive first-time bootstrap. `-SkipStart` returns control after setup; start the repository's documented development command in a dedicated terminal, then run health checks from another package terminal. Without `-SkipStart`, the initializer starts the development stack in the foreground. Database reset commands remain explicit manual actions because they destroy local development data.

Initialization scripts also inspect current state first. They reuse valid existing checkouts and completed prerequisites, log skipped steps, and stop rather than overwrite a dirty or conflicting checkout.

## 6. Verify

```powershell
.\scripts\Test-SeaSharpDevEnvironment.ps1 -Profile AppDev -WorkspaceRoot C:\dev
.\scripts\Test-SeaSharpLocalStack.ps1 -Product Helix -WorkspaceRoot C:\dev
```

Complete [First-day acceptance](FIRST-DAY-ACCEPTANCE.md) before treating the workstation as ready.

## What is standardized

The scripts standardize supported runtimes, package managers, Docker availability, repository bootstrap, package authentication checks, and product health checks. They emit human-readable terminal status for actions, results, skips, warnings, and failures. They do not standardize personal IDE choice, terminal configuration, directory layout beyond the selected root, themes, aliases, or AI tools.
