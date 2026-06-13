# R2 Bucket / Object Layout

Status: Green for AMB-668 / PLOS-040 layout specification scope; Yellow for live Cloudflare/R2 account proof, bucket provisioning, CORS/header setup, network validation, production writes, app runtime fetch, privacy/legal approval, release readiness, device proof, accessibility proof, and performance proof.
Updated: 2026-06-12 America/New_York
Owning issue: AMB-668 / PLOS-040
Parent issue: AMB-612 / PLOS-M04

## Boundary

This layout is for public, non-user-specific Source Atlas pathing data and control metadata only. It must never store, receive, derive, or infer private user data.

Allowed material:

- public source packs
- public seed packs
- starter, elasticity, replacement, jurisdiction, and compatibility packs
- signed manifests and object indexes
- freshness manifests
- revocation manifests
- rollback manifests
- validation reports
- release receipts
- public source metadata and non-user-specific goal/Step pathing data

Forbidden material:

- user goals, captures, schedules, proof, receipts, replay, local learning, private profile/context, private imports, files, photos, OCR output, reminders, health/location data, diagnostics, support bundles, exports, or any raw private text
- user-specific pack IDs, user identifiers, analytics IDs, device identifiers, private source-needed requests, or behavioral history
- write tokens, secrets, Cloudflare account IDs, credential receipts, or broad operational logs

## Release Ring Strategy

The layout supports three physical buckets or equivalent prefix-separated release rings:

| Ring | Purpose | Write authority | Runtime read eligibility |
|---|---|---|---|
| `dev` | Local/developer layout tests and non-production validation candidates. | Developer/tooling only; no secrets in repo or artifacts. | Not eligible. |
| `staging` | Public non-user-specific release candidates after local validation. | Least-privilege staging writer only. | Not eligible until promoted. |
| `prod` | Production public reference/pathing objects after release receipt, signature/hash proof, revocation path, rollback path, and compatibility proof. | Least-privilege production promote role only. | Eligible only after future M04/M05/M06 gates prove read compatibility and Source Atlas authority. |

Equivalent single-bucket deployments must include the ring as the first immutable prefix segment:

```text
dev/
staging/
prod/
```

## Object Key Grammar

All production objects use immutable content-addressed keys. Current pointers live only in signed manifests or indexes.

```text
<ring>/<family>/<domain>/<schema>/<artifact-id>/<version>/<sha256>/<filename>
```

Rules:

- `ring` is `dev`, `staging`, or `prod`.
- `family` is one of the allowlisted families below.
- `domain` is a public Source Atlas domain slug, or `global` for cross-domain control metadata.
- `schema` uses `schema-v<major>`.
- `artifact-id` is stable, public, and non-user-specific.
- `version` is semantic or date-versioned, for example `v1.2.0` or `2026-06-12`.
- `sha256` is the lowercase hex digest of the object payload or canonical manifest body.
- `filename` includes the artifact id, version, and extension.

No key may include user text, user identifiers, private locations, private goals, account ids, or secret material.

## Families

| Family | Object contents | Example key | Required controls |
|---|---|---|---|
| `packs/source` | Public source packs. | `prod/packs/source/certification/schema-v1/certification-core/v1.0.0/<sha>/certification-core.v1.0.0.pack.json` | Source binding, hash/signature, freshness, revocation, release receipt, rollback. |
| `packs/seeds` | Public reusable seed packs. | `prod/packs/seeds/recovery/schema-v1/recovery-low-capacity/v1.0.0/<sha>/recovery-low-capacity.v1.0.0.seed.json` | Seed gates, no exact-user Steps, hash/signature, release receipt. |
| `packs/starter` | Starter guidance-only packs. | `prod/packs/starter/global/schema-v1/starter-goal-setup/v1.0.0/<sha>/starter-goal-setup.v1.0.0.pack.json` | Starter-guidance-only state, risk review, no authoritative high-risk planning. |
| `packs/elasticity` | Public Step elasticity templates. | `prod/packs/elasticity/global/schema-v1/elasticity-time-fit/v1.0.0/<sha>/elasticity-time-fit.v1.0.0.seed.json` | Step Elasticity law compatibility and no private capacity data. |
| `packs/replacement` | Public replacement/recovery templates. | `prod/packs/replacement/global/schema-v1/replacement-recovery/v1.0.0/<sha>/replacement-recovery.v1.0.0.seed.json` | Recovery-safe wording, no shame language, no private history. |
| `packs/jurisdiction` | Public jurisdiction/rule packs. | `prod/packs/jurisdiction/us/schema-v1/us-certification-rules/2026-06-12/<sha>/us-certification-rules.2026-06-12.pack.json` | Jurisdiction, review, effective date, expiration, high-risk owner. |
| `manifests/current` | Signed current pointers for allowed public packs. | `prod/manifests/current/global/schema-v1/source-atlas-current/2026-06-12/<sha>/source-atlas-current.2026-06-12.manifest.json` | Signature/hash, release receipt, compatibility table reference. |
| `manifests/index` | Public object indexes. | `prod/manifests/index/global/schema-v1/source-atlas-index/2026-06-12/<sha>/source-atlas-index.2026-06-12.json` | Hash/signature, compact fan-out, no private keys. |
| `freshness` | Freshness windows and changed-claim sets. | `prod/freshness/global/schema-v1/source-atlas-freshness/2026-06-12/<sha>/source-atlas-freshness.2026-06-12.json` | Published date, stale thresholds, changed ids, rollback pointer. |
| `revocations` | Revoked packs/sources/keys/claims. | `prod/revocations/global/schema-v1/source-atlas-revocations/2026-06-12/<sha>/source-atlas-revocations.2026-06-12.json` | Effective date, reason class, affected ids, signed integrity. |
| `compatibility` | App/schema/pack compatibility table. | `prod/compatibility/global/schema-v1/source-atlas-compatibility/2026-06-12/<sha>/source-atlas-compatibility.2026-06-12.json` | Min app/runtime version, schema support, fallback behavior. |
| `validation-reports` | Public pack-scoped validation output. | `prod/validation-reports/certification/schema-v1/certification-core/v1.0.0/<sha>/certification-core.v1.0.0.validation.json` | Command, exit code, validator version, no private logs. |
| `release-receipts` | Public release receipt metadata. | `prod/release-receipts/certification/schema-v1/certification-core/v1.0.0/<sha>/certification-core.v1.0.0.receipt.json` | Releaser, hashes, signer, validators, rollback note. |
| `rollback-manifests` | Deterministic rollback targets. | `prod/rollback-manifests/certification/schema-v1/certification-core/2026-06-12/<sha>/certification-core.rollback.2026-06-12.json` | Bad version, target version/hash, reason, effective date. |

## Current Pointers

Mutable object overwrite is forbidden for packs and receipts. The only way to change what clients should consider current is to publish a new signed current manifest and release receipt.

The app must not infer current state from bucket listing order. It must read a signed manifest/index, verify it, then fetch exact hash-addressed objects.

## Metadata

Future object metadata may include only non-private fields:

- `x-ambitions-artifact-id`
- `x-ambitions-artifact-version`
- `x-ambitions-schema-version`
- `x-ambitions-sha256`
- `x-ambitions-source-domain`
- `x-ambitions-risk-class`
- `x-ambitions-release-ring`
- `x-ambitions-release-receipt-id`

Forbidden metadata:

- user id, device id, analytics id, goal text, capture text, schedule data, profile data, receipt/proof/replay ids, private location, raw source-needed text, account id, token, or secret.

## Cache And Fan-Out

- Manifests, freshness, revocation, compatibility, and rollback objects should be small and cacheable with short TTLs.
- Hash-addressed packs and validation artifacts should be immutable and cacheable with long TTLs.
- Runtime read paths should prefer manifest-first reads, then exact object reads.
- Range reads are allowed only after future compatibility proof shows a concrete need.

## Red Conditions

- Any private user data in an R2 key, object body, metadata, manifest, validation report, release receipt, request, log, screenshot, or support artifact.
- Any runtime or client write authority.
- Production write without staging validation, release receipt, rollback path, revocation path, manifest/hash proof, and owner-visible account/bucket/action/result evidence.
- Any object path that cannot be audited to one of the allowlisted families.
- Any pack marked runtime-eligible without source binding, freshness, revocation, release receipt, rollback, and Source Atlas authority proof.

## Non-Claims

This artifact does not provision Cloudflare/R2 infrastructure, create buckets, configure CORS/cache/headers, validate live R2 operations, publish packs, create credentials, implement runtime fetch/cache/quarantine behavior, approve privacy/legal posture, prove release readiness, prove accessibility, prove device behavior, or prove performance.
