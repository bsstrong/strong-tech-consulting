# Access and prerequisites

## Required for product engineers

- Supported Windows workstation with virtualization enabled.
- Sea Sharp company identity and MFA.
- GitHub organization and product-repository access.
- Read access to required private GitHub Packages.
- Read access to required GHCR container images.
- Slack workspace and relevant engineering/review channels.
- Docker Desktop entitlement under the company's licensing policy.
- Permission to install approved development software.

Core local tools:

- Git for Windows, including Git Bash.
- PowerShell 7 (recommended); the bootstrap scripts also support Windows PowerShell 5.1.
- Node version manager (`fnm` in this kit).
- Node.js versions required by the checked-out repositories. HelixOS currently requires Node `24.19.0`/Node 24; the initializer reads the checkout's `.node-version`, which remains authoritative.
- Docker Desktop with Docker Compose v2.
- A developer-selected editor or IDE.

## Role-specific additions

Zorka source developers need:

- .NET 10 SDK.
- Corepack and the repository-pinned pnpm version (currently `10.33.0`).

Browser/E2E developers need:

- The repository's Playwright dependencies and Chromium browser payload.
- Git Bash for Helix scripts that use Bash.

CloudOps engineers may need:

- Azure CLI and Bicep.
- GitHub CLI.
- Python 3, `jq`, `curl`, and OpenSSL.
- Appropriate Azure tenant/subscription roles.

## Access that remains manual

The scripts do not and must not:

- create company, GitHub, Slack, Azure, Netlify, or integration accounts;
- approve MFA, SSO, organization membership, or licenses;
- create or distribute production/Beta secrets;
- grant repository, package, container-registry, Entra, Azure, or Key Vault permissions;
- enroll a device in company management; or
- accept legal or license terms on the engineer's behalf.

Do not assume access to Netlify or any production service. Obtain access only when the assigned role requires it.

## Out of scope

This package does not set up private owner development, owner-only repositories, personal automation, private consulting material, Codex/Claude instructions, AI-agent configuration, personal browser profiles, dotfiles, aliases, editor themes, SSH keys, or signing keys.
