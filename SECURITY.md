# Repository security

This public repository must not retain credentials, API keys, private keys, or secret-bearing connection strings—even when those values originate in publicly accessible source HTML.

## Research artifacts

Download text-based research evidence through the repository guard:

```powershell
pwsh -File scripts/Protect-ResearchArtifacts.ps1 `
  -Uri "https://example.gov/source" `
  -OutputPath "personal/example-source.html"
```

Existing text artifacts can be sanitized before staging:

```powershell
pwsh -File scripts/Protect-ResearchArtifacts.ps1 -SanitizePath personal
```

The guard redacts supported secret-shaped values without printing them. Raw binary evidence such as PDFs is not rewritten by this tool and must be inspected separately when warranted.

## Commit protection

Configure the checked-in pre-commit hook once per clone:

```powershell
git config core.hooksPath .githooks
```

The hook rejects supported secret patterns and files larger than 90 MiB before a commit is created. GitHub secret scanning and push protection remain the remote backstop.
