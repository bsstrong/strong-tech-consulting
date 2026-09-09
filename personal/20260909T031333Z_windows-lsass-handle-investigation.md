# Windows LSASS handle investigation

## Context

After roughly two weeks of uptime, the PC became resource constrained. Diagnostics showed approximately 338,000 total process handles, including about 69,000 owned by LSASS. After restarting Windows, the baseline fell to approximately 117,000 total handles and 1,700 LSASS handles, with substantially lower memory and commit usage.

Recent UAT work repeatedly retrieved stored Windows Generic Credentials. The agent used several access paths, primarily short-lived PowerShell processes invoking `CredReadW`, marshaling the credential, and calling `CredFree` in a `finally` block. Some attempts also used PowerShell credential helpers, `cmdkey`, clipboard writes, and simulated paste operations.

## Current assessment

Repeated credential access is a plausible trigger but has not been demonstrated as the cause. The native path appears to release its allocated credential buffer correctly, so a straightforward missing-`CredFree` leak is less likely. Possible alternatives include a Windows component, PowerShell credential helper, authentication provider, or security product accumulating handles over the extended uptime.

No reproduction was run because the machine has been restarted and is currently healthy. Revisit only if handle growth or resource starvation returns.

## Reproduction plan

1. Record uptime, memory/commit usage, total process handles, and LSASS handle count.
2. Repeatedly read the same test credential through `CredReadW`/`CredFree` without printing the secret or accessing a hosted environment.
3. Sample handles during the loop and after the reader process exits.
4. Repeat with separate short-lived PowerShell processes to match the original usage pattern.
5. If that remains clean, isolate PowerShell credential-helper and `cmdkey` access, then clipboard operations.
6. Compare each test with a no-credential control loop and clear the clipboard afterward.

Expected time: 20–30 minutes for the initial native and short-lived-process tests; 45–60 minutes if all variants require isolation.
