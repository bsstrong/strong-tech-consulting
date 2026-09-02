# Sea Sharp engineer workstation kit

This directory contains the maintainers' source for the distributable Sea Sharp engineer workstation onboarding kit. The contents of `package/` are the only files included in the generated archive. Maintainer files and build output are intentionally excluded.

## Build prerequisites

- Windows PowerShell 5.1 or PowerShell 7+
- .NET Framework/.NET runtime supplied with PowerShell

The build does not install software, access the network, or require credentials.

## Validate and build

From this directory:

```powershell
.\Build-Package.ps1 -ValidateOnly
.\Build-Package.ps1
```

Successful builds create these files under `dist/`:

- `SeaSharp-Engineer-Workstation-Kit-<version>.zip`
- `SeaSharp-Engineer-Workstation-Kit-<version>.sha256`
- `SeaSharp-Engineer-Workstation-Kit-<version>.manifest.json`

The ZIP contains one versioned top-level folder, so extracting it does not scatter files into the destination directory. Files are added in ordinal path order with normalized archive timestamps to make repeated builds from identical inputs reproducible on the same PowerShell/.NET implementation.

## What validation covers

The build fails before creating an archive when:

- required scripts, configuration, or documentation are missing;
- JSON configuration or package metadata cannot be parsed;
- the package version is not a three-part semantic version;
- any PowerShell script or module has a parser error;
- a distributable file contains a recognizable credential, private key, personal machine path, or private-owner development locator;
- a generated `dist` directory is accidentally placed inside `package/`.

The leakage scan is a guardrail, not a substitute for review. Before sharing a ZIP, review the manifest and package contents, then compare the published checksum with a fresh local hash:

```powershell
Get-FileHash .\dist\SeaSharp-Engineer-Workstation-Kit-1.0.0.zip -Algorithm SHA256
```

## Updating the kit

1. Change files under `package/`.
2. Update `package/package-metadata.json` when making a versioned release.
3. Run validation and build.
4. Inspect the generated manifest and extracted archive.
5. Share the ZIP and checksum through an approved internal channel.

Do not add credentials, personal workstation configuration, private-owner repositories, or environment-specific secrets to this kit.
