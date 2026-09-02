# Browser and E2E testing

Install this capability only when the engineer's assignments include browser tests.

## Install Playwright browser payloads

Run from the applicable repository after dependencies are installed:

```powershell
npx playwright install chromium
```

For Zorka, use its pinned package manager:

```powershell
pnpm exec playwright install chromium
```

The initializers provide idempotent equivalents that record the relevant lockfile fingerprint:

```powershell
.\scripts\Initialize-HelixWorkspace.ps1 -InstallPlaywright -SkipStart
.\scripts\Initialize-ZorkaWorkspace.ps1 -InstallPlaywright -SkipStart
```

The current repository lockfile and Playwright package version are authoritative.

## HelixOS

Helix's full browser suite is launched through repository scripts. Git Bash is required for scripts that invoke Bash:

```powershell
npm run test:web:e2e
```

For headed mode on Windows:

```powershell
npm run test:web:e2e:headed:windows
```

Start required services or use the repository's documented bootstrap before running suites that expect a live stack.

## Zorka

Start the local app, API, runtime, and database stack first:

```powershell
pnpm dev
```

In a second terminal:

```powershell
pnpm test:e2e:app
```

Use `pnpm demo` for the embedded-consumer flow when assigned.

## Browser safety

- Use a dedicated approved test browser/context; do not automate a personal browser profile.
- Never store company passwords, access tokens, or production session cookies in test fixtures, screenshots, traces, or videos.
- Use only local, test, or Beta test data authorized for the work.
- Do not point local automation at production services without explicit authorization.
- Review generated traces and screenshots before sharing because they may contain customer or internal data.
