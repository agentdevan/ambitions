# R2 Staging Activation Report

Status: Green for AMB-973 / PLOS-M05-R2 staging activation because current R2 settings, staging canary upload/list/HEAD/GET, ETag, size, and SHA-256 body-hash verification passed for the selected public staging `r2.dev` read model.
Date: 2026-06-13 America/New_York
Linear issue: AMB-973
Parent issue: AMB-613
Scope: Live Cloudflare R2 staging activation for Source Atlas Foundry only.
Proof run: `amb-973-r2-green-repair-20260613T183742Z`

## Boundary

This report activates staging infrastructure only. It does not claim app runtime consumption, runtime eligibility, production certification, privacy/legal approval, release readiness, App Store readiness, device proof, accessibility proof, security certification, or measured performance proof.

No private user data, realistic private goals, account ids, API tokens, access keys, secret keys, presigned URLs, write credentials, private documents, diagnostics, support bundles, user identifiers, device identifiers, or source-needed private text were written to R2, repo artifacts, logs, or Linear by AMB-973.

## Existing-First Inspection

AMB-973 inspected and preserved:

- `artifacts/personal-life-os/reports/AMB-612-plos-m04-parent-acceptance-report.md`
- `artifacts/personal-life-os/reports/PLOS-011-source-atlas-factory-runtime-map.md`
- `artifacts/source-atlas-factory/SAF_HARDENING_PLAN.md`
- `tools/source-atlas/lakehouse-workbench/README.md`
- `tools/source-atlas/lakehouse-workbench/.env.example`
- `tools/source-atlas/lakehouse-workbench/publisher.py`
- `artifacts/source-atlas-factory/r2/R2_BUCKET_LAYOUT.md`
- `artifacts/source-atlas-factory/r2/R2_IMMUTABLE_PACK_PATH_STRATEGY.md`
- `artifacts/source-atlas-factory/r2/R2_MANIFEST_COMPATIBILITY_SPEC.md`
- `artifacts/source-atlas-factory/r2/R2_FRESHNESS_REVOCATION_MANIFESTS.md`
- `artifacts/source-atlas-factory/r2/R2_RELEASE_RINGS_ROLLBACK_MANIFESTS.md`
- `artifacts/source-atlas-factory/r2/R2_APP_FETCH_VERIFY_CACHE_QUARANTINE_PLAN.md`
- `scripts/codex/source-atlas-readiness-validate.py`

Cloudflare R2 docs and OpenAPI spec were refreshed through the Cloudflare connector before live operations. The connector exposed R2 bucket list/create/get, CORS, managed-domain, custom-domain, lifecycle, object list, object upload, object GET, object delete, and temporary credential endpoints. AMB-973 did not create or print temporary credentials.

## Current Bucket State

Cloudflare R2 buckets verified:

| Bucket | Role | Live state |
|---|---|---|
| `ambitions-source-atlas-dev` | dev ring | Existing bucket; managed `r2.dev` enabled; no custom domains; no CORS config; default multipart abort lifecycle |
| `ambitions-source-atlas-staging` | staging ring | Existing bucket used by AMB-973; managed `r2.dev` enabled; no custom domains; one GET CORS rule for local development; default multipart abort lifecycle |
| `ambitions-source-atlas-prod` | production ring | Existing bucket; not modified by AMB-973; managed `r2.dev` disabled; no custom domains; no CORS config; default multipart abort lifecycle |

Staging local uploads setting is disabled. Production local uploads setting is disabled. The dev local uploads setting is enabled but was not modified by AMB-973.

## Staging Prefix Strategy

AMB-973 uses the existing physical staging bucket plus the `staging/` ring prefix:

```text
staging/<family>/global/schema-v1/source-atlas-staging-canary/2026-06-13/<sha256>/<filename>
```

This keeps AMB-973 inside staging and preserves the M04 immutable object grammar. `prod/` was not written.

## Live Operations

| Action | Result |
|---|---|
| List R2 buckets | Success; dev, staging, and prod buckets exist |
| Get staging bucket | Success |
| Get staging CORS | Success; one GET rule for local development |
| Get staging managed `r2.dev` domain posture | Success; enabled |
| List staging custom domains | Success; none |
| Get staging lifecycle | Success; default multipart abort rule exists |
| Upload refreshed canaries | Success; 10 non-private staging objects uploaded |
| List `staging/` canaries | Success; 20 total staging canaries listed, including the 10 refreshed canaries |
| Public staging `r2.dev` HEAD | Success for all 10 refreshed canaries |
| Public staging `r2.dev` GET body read | Success for all 10 refreshed canaries |
| SHA-256 body hash compare | Success for all 10 refreshed canaries |

## Read Model

Selected read model: public staging `r2.dev` read for non-private Source Atlas staging canaries only.

This model was selected because it proves object body readability without storing or printing secrets, creating temporary credentials, persisting presigned URLs, adding app runtime write credentials, or creating a Worker-mediated/custom-domain path. It is staging-only evidence and does not imply app runtime consumption.

The old raw connector-body limitation (`Cloudflare API error: 200`) is now recorded only as historical context. It is not acceptable Green evidence for AMB-973 after this repair because the selected read model proves HEAD, GET, body size, ETag, and SHA-256 body hash.

## Cache / Header Posture

- Public HEAD responses returned `Content-Type: application/json`.
- Public HEAD responses returned `Content-Length` matching the downloaded body size.
- Public HEAD ETags matched the Cloudflare connector object-list ETags.
- No custom `Cache-Control` header was set by AMB-973; cache policy remains future-owned for runtime consumption and production certification.

## Red Checks

Red checks passed for AMB-973 staging scope:

- No app source changed.
- No runtime feature implemented.
- No production bucket write performed.
- No private user data was staged.
- No secret material was staged.
- No write credentials were stored in app runtime, repo, artifacts, logs, or Linear.
- No R2 runtime-on claim was made.
- No production-readiness claim was made.

## Non-Claims

AMB-973 does not claim R2 runtime consumption, app runtime fetch, app cache/quarantine implementation, runtime eligibility, pack publication beyond staging canaries, production promotion, production certification, privacy/legal approval, release readiness, TestFlight readiness, App Store readiness, accessibility proof, device proof, performance proof, or AMB-613 parent Green.
