# R2 Signed Manifest And Compatibility Manifest Spec

Status: Green for AMB-670 / PLOS-042 manifest specification scope; Yellow for runtime parser implementation, live R2 account proof, bucket provisioning, network validation, release tooling, privacy/legal approval, release readiness, device proof, accessibility proof, and performance proof.
Updated: 2026-06-12 America/New_York
Owning issue: AMB-670 / PLOS-042
Parent issue: AMB-612 / PLOS-M04

## Boundary

This spec defines public Source Atlas manifest roles, signing expectations, compatibility metadata, and invalid-manifest handling. It does not implement a parser, publish packs, configure Cloudflare/R2, create credentials, perform live R2 writes, or mark any pack runtime-eligible.

All manifests are public-reference-only. They must not contain private user data, user identifiers, device identifiers, raw private goal text, private source-needed requests, diagnostics, support bundles, secrets, or write-token material.

## Manifest Roles

| Manifest | Purpose | Required contents | Failure behavior |
|---|---|---|---|
| Current manifest | Selects current public pack versions by exact immutable path. | manifest id/version, generated date, ring, pack ids, exact object paths, versions, sha256 values, schema versions, signing state, release receipts, compatibility table id. | Quarantine manifest and use last-known-good or bundled/source-needed fallback. |
| Index manifest | Lists available public artifacts for bounded discovery. | artifact ids, families, domains, versions, sha256 values, risk class, freshness id, revocation id, release receipt id. | Do not infer current state; fall back to current manifest only. |
| Compatibility manifest | Defines app/runtime/schema compatibility for packs and manifests. | min/max app build or schema envelope, supported schema versions, incompatible versions, fallback behavior, deprecation dates. | Quarantine incompatible pack/manifest and use compatible last-known-good or bundled/source-needed fallback. |
| Freshness manifest | Declares source and pack freshness windows. | source timestamps, review dates, stale thresholds, changed claim ids, stale behavior, owner. | Treat stale or missing freshness as source-needed/review-needed, not current. |
| Revocation manifest | Blocks unsafe source, pack, manifest, signer, or claim ids. | revoked ids, versions, sha256, reason class, effective date, replacement/rollback pointer. | Block runtime eligibility and route to rollback/fallback. |
| Rollback manifest | Names deterministic rollback targets. | bad artifact id/version/hash, target artifact id/version/hash, reason, effective date, release receipt. | If rollback target verifies and is not revoked, use as last-known-good candidate. |

## Signing And Integrity

Production-eligible manifests require all of:

- canonical JSON serialization rule
- manifest sha256
- signer id or pinned integrity authority
- signature or explicitly pinned checksum state
- signing key/trust state reference
- release receipt id
- generated timestamp
- expiry or next-review timestamp
- revocation list reference
- rollback reference

Unsigned manifests are allowed only for local drafts and dev validation. They cannot select runtime-eligible production packs.

Hash mismatch, unknown signer, revoked signer, missing release receipt, missing revocation reference, missing rollback reference, missing compatibility reference, or schema mismatch is Red for production runtime eligibility.

## Compatibility Metadata

Compatibility manifests must describe:

- manifest schema version
- pack schema versions supported by the app/runtime
- minimum app build or runtime capability set
- maximum known-compatible schema when needed
- required feature flags or capability ids
- incompatible artifact ids/versions/hashes
- fallback mode: `last_known_good`, `bundled`, `source_needed`, `blocked`, or `manual_review`
- deprecation date and owner

Compatibility is evaluated before pack use. If the app cannot prove compatibility, it must quarantine the artifact and use safe fallback. It must not try best-effort parsing of a production pack while claiming Green.

## Size And Fetch Overhead

Manifest objects should be small pointer/control documents. They should avoid embedding full packs, large validation logs, screenshots, or source bodies.

Expected fetch posture:

- current, compatibility, freshness, revocation, and rollback manifests are short-TTL reads
- immutable pack objects are long-TTL reads after exact path verification
- index manifests are optional bounded discovery, not a current-state oracle
- runtime fetch should prefer one current manifest, one compatibility manifest, one freshness/revocation set, then exact pack reads

No measured network, battery, memory, or latency proof is claimed by this spec.

## Quarantine Rules

A manifest is quarantined when:

- signature or checksum verification fails
- signer trust is unknown or revoked
- manifest schema is unsupported
- compatibility manifest marks it incompatible
- required field is missing
- referenced pack hash/path does not match
- freshness is stale beyond allowed behavior
- revocation includes the manifest, pack, signer, source, or claim
- private user data appears in manifest body, path, metadata, request, log, validation report, release receipt, screenshot, or support artifact

Quarantine must be fail-closed for production eligibility. Safe fallback can use verified last-known-good, bundled public data, source-needed, needs-review, or blocked behavior.

## Non-Claims

This artifact does not implement manifest parsing, signature verification, compatibility evaluation, runtime quarantine, release tooling, pack publication, Cloudflare/R2 setup, credential creation, live R2 writes, network validation, production-readiness proof, privacy/legal approval, release readiness, device proof, accessibility proof, or performance proof.
