# Optional CloudOps and Azure tooling

This profile is not required for ordinary application development. Install it only for infrastructure, deployment, or operational assignments.

## Tools

- Azure CLI and Bicep.
- GitHub CLI.
- Docker buildx.
- Git Bash or approved WSL2 distribution.
- Python 3.
- `jq`, `curl`, and OpenSSL.

Use the install helper's CloudOps profile when available:

```powershell
.\scripts\Install-SeaSharpDev.ps1 -Profile CloudOps -WorkspaceRoot C:\dev
```

The helper installs Bicep through Azure CLI when it is missing and skips it when already available. The environment doctor also checks Git Bash, `curl`, Docker buildx, and warns when a task-specific runbook needs `uuidgen`.

Confirm versions and authentication:

```powershell
az version
az bicep version
gh --version
docker buildx version
python --version
```

## Access remains manual

An Azure administrator must grant the correct tenant, subscription, resource-group, Entra, and Key Vault roles. A successful `az login` does not prove authorization for a particular operation.

```powershell
az login
az account show
az account list --output table
```

Before running any command that changes Azure resources, explicitly confirm the selected tenant and subscription. Do not set a production subscription as an implicit onboarding default.

Netlify, package publication, container publication, release operations, and production deployment are separate role permissions. This kit neither grants nor tests them by default.

## Boundaries

- Local and Beta are the normal Helix development/validation targets until an owner-authorized production operation is assigned.
- Never download production secrets into repository files.
- Do not create service principals, role assignments, resources, deployments, releases, or publications as part of workstation bootstrap.
- Treat IaC plans and generated deployment output as sensitive until reviewed.
