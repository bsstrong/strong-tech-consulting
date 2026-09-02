# Authentication

Use a company-managed identity and least-privilege credentials. Complete GitHub organization SSO authorization when required.

## GitHub repositories

Configure Git identity:

```powershell
git config --global user.name "Your Name"
git config --global user.email "your.company.email@example.com"
```

Authenticate using an approved Git credential method. Git Credential Manager over HTTPS is the default recommendation. If the company requires SSH or commit signing, follow that policy rather than generating unmanaged credentials from this kit.

Verify repository access with the clone URL supplied by your administrator:

```powershell
git ls-remote <approved-helixos-clone-url> HEAD
```

Do not paste private repository URLs into tickets, public documents, or logs.

## GitHub Packages (`@zorkacom/*`)

HelixOS consumes private packages from `npm.pkg.github.com`. Two `.npmrc` scopes are involved:

- The repository `.npmrc` contains only the committed `@zorkacom` registry mapping and must remain token-free.
- The user-level npm configuration contains the real read token.

Use the authentication helper so the token is requested securely and written only to the user-scoped npm configuration:

```powershell
.\scripts\Set-SeaSharpPackageAuthentication.ps1 -ConfigureNpm
```

Equivalent user-level entries are:

```ini
//npm.pkg.github.com/:_authToken=REDACTED
always-auth=true
```

The credential must have read access to the required private package namespace and any required organization SSO authorization. Never commit it, place it in a repository `.env`, send it in chat, or print it in a diagnostic transcript.

Verify from a product repository without echoing the token:

```powershell
npm whoami --registry=https://npm.pkg.github.com
```

## GHCR

HelixOS may pull a private self-contained Rule Engine image from `ghcr.io`. Use a credential with only the required package-read permission:

```powershell
$token = Read-Host "GHCR read token" -AsSecureString
# Prefer the included authentication helper to avoid exposing the token.
```

Configure GHCR through the secure helper:

```powershell
.\scripts\Set-SeaSharpPackageAuthentication.ps1 -ConfigureGhcr
```

The Helix launcher supports `GHCR_USERNAME` and `GHCR_TOKEN` when registry authentication is required. Set them only in the current process or through an approved local secret mechanism; do not put them in source control. The helper and doctor must never print the token.

After authentication, verify that Docker can pull the exact image/tag referenced by the current repository configuration. Do not copy an image tag from this document; repository configuration is authoritative.

## GitHub CLI

GitHub CLI is optional for normal application work and useful for CloudOps/repository workflows:

```powershell
gh auth login
gh auth status
```

Choose the company-approved protocol and authorize organization SSO if prompted.

## Authentication failures

- `401` from GitHub Packages usually means the user-level token is absent, expired, malformed, or not selected by npm.
- `403` usually means the identity/token lacks package access or organization SSO authorization.
- `denied` from GHCR usually means the token lacks container-package read access or the account cannot access the package.
- A successful GitHub website login does not prove Git, GitHub Packages, or GHCR access; verify each separately.
