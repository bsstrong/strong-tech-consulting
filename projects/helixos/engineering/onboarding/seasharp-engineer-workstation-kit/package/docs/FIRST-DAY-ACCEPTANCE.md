# First-day acceptance checklist

Complete only the sections required by the engineer's role.

## Identity and access

- [ ] Company identity and MFA work.
- [ ] GitHub organization and assigned product repositories are accessible.
- [ ] GitHub Packages read succeeds for required private packages.
- [ ] GHCR pull succeeds for the repository-selected Rule Engine image, if required.
- [ ] Slack workspace and assigned channels are accessible.
- [ ] No unneeded production, release, Netlify, Azure, or integration access was requested.

## Workstation

- [ ] `Test-SeaSharpDevEnvironment.ps1 -Profile AppDev` reports required tools ready.
- [ ] Git identity uses the company-approved name/email.
- [ ] Docker Desktop and Compose v2 work.
- [ ] The chosen workspace root is writable and not a synchronized/network folder.
- [ ] No private owner repositories, personal tooling, or Codex/Claude configuration was installed.

## HelixOS application development

- [ ] Checkout uses its declared Node version.
- [ ] `npm ci` succeeds without a token in the repository `.npmrc`.
- [ ] `npm run setup` completes.
- [ ] `npm run dev:windows` starts Rule Engine, API, web, Client Portal, and workflow runner.
- [ ] Helix web opens at `http://localhost:5173`.
- [ ] Client Portal opens at `http://localhost:5174`.
- [ ] Rule Engine readiness and Helix `/api/me` return `200`.
- [ ] When assigned, the disposable local database is backed up or accepted as disposable before running `npm run test:integration`, and the smoke test passes.
- [ ] No unintended Helix repository `.env` exists.

## Zorka source development, when assigned

- [ ] .NET 10 SDK is active.
- [ ] Repository-pinned pnpm is active.
- [ ] `pnpm install` and `pnpm local:setup` complete.
- [ ] `pnpm dev` starts database, runtime, API, and Studio.
- [ ] Runtime and API health checks return `200`.
- [ ] Studio opens and a seeded local account can sign in.
- [ ] Relevant .NET and package validation commands pass.

## Browser/E2E, when assigned

- [ ] Playwright Chromium is installed from the repository's dependency version.
- [ ] Relevant Helix or Zorka browser smoke suite runs.
- [ ] Test traces/screenshots contain no credentials or sensitive data before sharing.

## CloudOps or Tax Service, when assigned

- [ ] Only role-required optional tools and access are configured.
- [ ] Azure tenant/subscription are explicitly verified before any operation.
- [ ] Tax Service fake mode runs without provider credentials.
- [ ] Real-provider credentials are configured only when explicitly authorized.

## Handoff

- [ ] Record tool/bootstrap failures requiring IT or administrator action.
- [ ] Do not paste secrets or private configuration into the handoff.
- [ ] Manager or onboarding owner confirms the role-specific checklist is complete.
