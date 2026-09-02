# Security boundaries

## Credentials

- Use company identities and least-privilege credentials.
- Never commit tokens, passwords, connection strings, certificates, cookies, or private keys.
- Never place the GitHub Packages token in a repository `.npmrc`, `.env`, runtime config, test fixture, or issue.
- Never pass secrets directly on a command line when a secure prompt or credential store is available.
- Redact diagnostic output before sharing it.
- Rotate and report any credential that is exposed.

## Environments and data

- Use local, test, or Beta data appropriate to the assignment.
- Do not access production infrastructure, data, smoke tests, migrations, or deployment workflows unless that exact operation is explicitly authorized.
- Never copy customer or production data into local databases, fixtures, screenshots, traces, logs, or AI tools.
- Treat repository names, URLs, internal hosts, commit identifiers, local paths, and private conversations as confidential outside their intended audience.

## Package behavior

This package may install approved local prerequisites, create a chosen workspace directory, initialize approved product repositories, and run read-only validation. It must not:

- provision external accounts or permissions;
- alter organization settings;
- retrieve production secrets;
- deploy, publish, release, merge, or push code;
- reset databases without an explicit manual command;
- remove unrelated software, directories, repositories, containers, or user configuration;
- reproduce an owner's personal setup; or
- install/configure Codex, Claude, private owner tools, or owner repositories.

Inspect planned actions with `-WhatIf`; use `Install-SeaSharpDev.ps1 -CheckOnly` or the read-only environment and local-stack test scripts for diagnostics. Stop if a path resolves outside the selected workspace root or an existing checkout contains uncommitted changes.

## Local configuration differences

- HelixOS normally needs no repository `.env`; do not create one from `.env.example` during routine local bootstrap.
- Zorka source uses a repository-root `.env` created from `.env.example` when missing.
- User-level package credentials must remain outside both repositories.
