# R2 Staging Activation Report

Status: Yellow for AMB-973 / PLOS-M05-R2 because staging bucket and canary writes/listing are live-verified, but raw object body GET/HEAD verification is limited by the Cloudflare connector returning `Cloudflare API error: 200` for successful raw object responses.
Date: 2026-06-13 America/New_York
Linear issue: AMB-973
Parent issue: AMB-613
Scope: Live Cloudflare R2 staging activation for Source Atlas Foundry only.

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

## Bucket State

Cloudflare R2 buckets already existed:

| Bucket | Role | Live state |
|---|---|---|
| `ambitions-source-atlas-dev` | dev ring | Existing bucket |
| `ambitions-source-atlas-staging` | staging ring | Existing bucket used by AMB-973 |
| `ambitions-source-atlas-prod` | production ring | Existing bucket; not modified by AMB-973 |

The staging bucket `ambitions-source-atlas-staging` was verified through the Cloudflare connector:

- Location: `ENAM`
- Storage class: `Standard`
- Jurisdiction: `default`
- Managed `r2.dev` public access: disabled
- Custom domains: none
- CORS policy: not configured; Cloudflare returned `10059: The CORS configuration does not exist`
- Lifecycle: default multipart abort rule enabled

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
| Get staging bucket CORS | Yellow; no CORS config exists |
| Get managed `r2.dev` domain posture | Success; disabled |
| List custom domains | Success; none |
| Get lifecycle | Success; default multipart abort rule exists |
| Upload canaries | Success; 10 non-private staging objects uploaded |
| List `staging/` canaries | Success; 10 canary objects listed with size and ETag |
| Raw object GET | Yellow; connector throws `Cloudflare API error: 200` for successful raw object body responses |

## Read Model

The intended Source Atlas read model remains:

1. Read compact current/control manifests.
2. Verify schema, hash/checksum or signature state, compatibility, freshness, revocation, rollback, release receipt, source authority, risk/jurisdiction, and no-private-data state.
3. Fetch exact immutable public Source Atlas object paths only after control gates pass.
4. Quarantine or route to source-needed/review-needed/blocked on any missing, stale, revoked, private-data-containing, incompatible, or hash-mismatched state.

AMB-973 verifies staging existence, object upload, object listing, ETag presence, and content-addressed path layout. It does not prove app runtime fetch, cache, quarantine, parser, eligibility, or consumption.

## Yellow Limitation

The Cloudflare REST object GET endpoint returns raw object bodies. The Cloudflare connector used in this run expects Cloudflare JSON envelopes and throws `Cloudflare API error: 200` on successful raw object-body responses. Because of that connector limitation, AMB-973 records upload/list/ETag/path verification as live evidence and leaves raw object body GET/hash re-download verification as Yellow.

This Yellow blocks any M06/M10 runtime eligibility or runtime consumption claim from AMB-973 alone.

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
