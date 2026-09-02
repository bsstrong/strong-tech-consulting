# Optional Tax Service

Use this setup only for engineers working on Helix Tax Service functionality.

## Integrated local stack

From the HelixOS repository root:

```powershell
npm run dev:windows:tax
```

This starts the normal Helix stack plus the Tax Service and uses fake mode by default. Fake mode is offline and does not require Symmetry or Azure credentials.

Open `http://localhost:5173`, select the local `keith-demo` persona, and navigate to **Admin Utilities → Tax Service Admin**.

## Standalone Tax Service

```powershell
npm run infra:dev:up
npm run tax-service:dev
```

Open `http://localhost:8081/admin`. Health endpoints are `http://localhost:8081/healthz` and `http://localhost:8081/readyz`.

The local runner creates a separate `tax_service` database in the same local PostgreSQL container.

## Real provider access

Real or automatic Symmetry lookup requires separately issued credentials and an approved base URL. Do not request or store these for an engineer whose assignment uses fake mode. When real-provider testing is authorized, use the Tax Service admin workflow or the company's approved secret mechanism. Never commit credentials or copy Beta/production values into local configuration.
