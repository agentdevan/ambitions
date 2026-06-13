# Source Atlas Release Receipt Requirements

Status: Green for AMB-684 / PLOS-058 release receipt requirements scope; Yellow for receipt storage implementation, release tooling, signing tooling, pack publication, live Cloudflare/R2 account proof, bucket provisioning, network validation, canary objects, runtime fetch/cache/quarantine implementation, computed runtime eligibility, runtime consumption, privacy/legal approval, release readiness, device proof, accessibility proof, security certification, and measured performance proof.
Updated: 2026-06-13 America/New_York
Owning issue: AMB-684 / PLOS-058
Parent issue: AMB-613 / PLOS-M05

## Boundary

This artifact defines the required release receipt contents for any Source Atlas pack, reusable seed set, manifest, validation report, release ring promotion, revocation, rollback, supersession, or R2-bound public-reference object.

It does not implement receipt storage, receipt generation tooling, signing, release promotion, pack publication, Cloudflare/R2 provisioning, credentials, live R2 writes, canary objects, network validation, runtime fetch/cache/quarantine behavior, runtime pack consumption, runtime eligibility changes, or production certification.

Release receipts are public Source Atlas provenance records. They must never contain private user goals, captures, schedules, proof, receipts, profile data, files, OCR output, health/location data, private imports, diagnostics, support bundles, user identifiers, secrets, account ids, write tokens, raw private text, inferred private life context, or private source-needed requests.

## Receipt Requirement

No Source Atlas artifact can move to `staged`, `released`, `prod`, R2 promotion beyond staging, current-manifest selection, runtime-eligible candidate, rollback target, or supersession target without a release receipt that names the exact artifacts, hashes, validation evidence, rollback/revocation paths, privacy boundary, and owner/reviewer state.

Missing, unverifiable, incomplete, mutable, private-data-containing, secret-containing, hash-mismatched, unsigned-when-required, signer-unknown, stale, revoked, contradicted, risk-unreviewed, jurisdiction-needed, rollback-missing, or validation-failed receipts fail closed to `review_needed`, `quarantined`, `blocked`, or `source_needed`.

## Required Receipt Fields

| Field | Required Meaning | Red stop |
|---|---|---|
| `receipt_id` | Stable receipt identifier, unique to the exact release/promotion/revocation/rollback event. | Missing or reused id. |
| `schema_version` | Receipt schema version. | Unsupported or omitted version. |
| `created_at` | ISO-8601 creation timestamp. | Missing timestamp. |
| `created_by_role` | Role/class of the actor or tool that created the receipt, without personal secrets. | Secret-bearing or untraceable actor state. |
| `owning_issue` | AMB issue that owns the release/promotion event. | PLOS label only, missing AMB id, or wrong owner. |
| `release_ring` | `dev`, `staging`, or `prod`, matching the R2 release-ring model when R2 is in scope. | Unknown ring or promotion beyond active issue authority. |
| `operation_type` | `stage`, `release`, `promote`, `supersede`, `revoke`, `rollback`, `quarantine`, or `repair`. | Ambiguous operation. |
| `artifact_ids` | Exact pack, seed, manifest, validation report, freshness, revocation, compatibility, rollback, or canary ids involved. | Wildcard or latest-only artifact selection. |
| `artifact_paths` | Immutable local paths or future R2 object keys for exact artifacts. | Mutable alias as source truth. |
| `manifest_ids` | Current/index/compatibility/freshness/revocation/rollback manifest ids involved. | Manifest omitted for release or runtime consideration. |
| `source_binding_ids` | Source import, provenance, and authority ids that bind the artifact to public source material. | Missing source binding. |
| `source_hashes` | Raw and normalized source hashes when applicable. | Hash missing or changed without supersession. |
| `extraction_hashes` | Claim/requirement extraction hash lineage when applicable. | Extraction output cannot be tied to source. |
| `pack_payload_hashes` | Exact payload sha256 or equivalent pinned checksum for each pack/seed artifact. | Hash mismatch or absent payload hash. |
| `manifest_hashes` | Exact manifest sha256 or equivalent pinned checksum. | Current/control manifest lacks integrity evidence. |
| `signature_state` | Signed, pinned-checksum, draft-unsigned, signer id, signer trust state, and signature/checksum verification result. | Unknown signer, revoked signer, failed verification, or production unsigned. |
| `validation_report_ids` | Validation artifact ids and log paths, referenced rather than embedded. | No validation evidence. |
| `validation_status` | Pass/fail/warn outcomes for schema, source binding, duplicate, contradiction, freshness, revocation, risk, jurisdiction, private-data, seed coverage, no-hardcoded-Step, Step Quality preflight, compatibility, rollback, and receipt completeness gates. | Any required Red gate failed or absent. |
| `review_state` | Reviewer owner/state and approval/block reason for risk, jurisdiction, source authority, and release readiness within the issue scope. | High-risk or jurisdiction-needed material lacks review state. |
| `risk_jurisdiction_state` | Risk class, jurisdiction envelope, professional-boundary flags, and review routing. | Unknown risk/jurisdiction treated as eligible. |
| `freshness_state` | Freshness class, source timestamp, stale threshold, expiry, and source-needed behavior. | Stale or missing freshness silently passes. |
| `revocation_state` | Matching revocation manifest ids, signer/source/artifact revocation status, and emergency revocation posture. | Revoked or unverifiable revocation state passes. |
| `rollback_link` | Rollback manifest/path, last-known-good target, and rollback verification status. | No rollback target for release/promotion. |
| `revocation_link` | Revocation manifest/path or emergency block path. | No revocation path for release/promotion. |
| `supersession_link` | Prior artifact id/hash/path and replacement reason when applicable. | Supersession erases prior provenance. |
| `compatibility_state` | Runtime/app/schema compatibility manifest id and compatibility result. | Unsupported schema treated as eligible. |
| `no_private_data_confirmation` | Explicit confirmation that artifacts, paths, metadata, logs, receipt body, and Linear/proof references contain no private user data or secrets. | Private data, secrets, tokens, account ids, or identifiers present. |
| `r2_boundary` | If R2 is in scope, public-reference-only bucket/prefix/ring class and no runtime write credentials. | Private data or runtime write credentials in R2 path. |
| `runtime_eligibility_result` | `not_eligible`, `candidate`, or `eligible`, plus gates passed. AMB-684 receipts default to `not_eligible`. | Eligibility claimed before future owning gates pass. |
| `no_claims` | Explicit non-claims for implementation, runtime consumption, production readiness, privacy/legal approval, release readiness, device/accessibility/performance/security proof, and parent completion when not proven. | Overclaim. |
| `evidence_artifact_paths` | Repo artifact paths for validation, review, and release evidence. | Evidence pasted from unbounded logs or missing. |
| `rollback_failure_behavior` | Required behavior if validation, signature, freshness, revocation, rollback, privacy, or compatibility checks fail after release. | Silent use or silent overwrite. |

## Receipt Contents By Release State

| State | Receipt Requirement |
|---|---|
| `draft` | Receipt may be draft/unsigned but must name source binding, artifact ids, intended validation gates, and no-private-data boundary. |
| `validated` | Receipt references passing validation reports and unresolved Yellow/future-owned gates. |
| `staged` | Receipt includes immutable paths, exact hashes, manifest ids, signer/checksum state, rollback/revocation links, review state, and no-private-data confirmation. |
| `released` | Receipt includes release ring, current-manifest selection, compatibility/freshness/revocation/rollback references, validation status, review state, and explicit no-claim boundaries. |
| `superseded` | Receipt preserves prior and replacement artifact ids, hashes, reasons, manifests, and rollback state. |
| `revoked` | Receipt names revoked ids/hashes/signers/sources, reason, effective date, replacement or block state, and cache/quarantine expectation. |
| `rollback` | Receipt names bad artifact, verified target, control manifests before/after, signer/hash state, reason, owner-visible operation receipt, and follow-up validation. |
| `quarantined` | Receipt names failing gate, affected artifact ids/hashes, evidence path, private-data/secret handling if applicable, and non-eligibility state. |

## R2 Promotion Rule

AMB-684 defines the receipt contract only. Live Cloudflare R2 staging activation belongs to AMB-973 / PLOS-M05-R2, runtime consumption belongs to AMB-617 / PLOS-M10, and production certification belongs to AMB-635 / PLOS-M26.

R2 promotion beyond staging cannot be Green unless the release receipt proves:

- exact immutable object paths and hashes
- signed or pinned checksum manifest state
- validation pass state
- release ring and promotion owner
- rollback and revocation links
- no-private-data confirmation
- no app/runtime write credentials
- compatible current/freshness/revocation/rollback manifests
- source binding, risk, jurisdiction, review, Step Quality, and release receipt gates

AMB-684 performs no live R2 writes and does not make R2 runtime-on.

## Validation Evidence Rules

Receipts reference validation evidence instead of embedding large logs. Required references include:

- schema and version validation
- source binding and hash verification
- duplicate and contradiction scan output
- freshness and stale-threshold result
- revocation and rollback readiness result
- risk and jurisdiction classification result
- private-data and secret scan result
- reusable seed coverage and no-hardcoded-finished-Step result
- Step Quality preflight readiness result when future-owned
- manifest/signature/checksum compatibility result
- release ring or R2 operation evidence only when the active issue owns that action

If evidence is missing, the receipt records `blocked` or `review_needed`, not Green.

## Privacy And Secret Boundary

Release receipts must contain public-source provenance and integrity facts only. They must not include:

- private user goals, captures, schedules, proof, profile data, receipts, local learning, exports, diagnostics, support bundles, raw private text, identifiers, health/location data, or private imports
- Cloudflare account ids, API tokens, write credentials, bucket secrets, presigned write URLs, environment variables, private keys, signing secrets, scanner secrets, or Linear/private support credentials
- screenshots or logs that reveal private data
- mutable aliases or bucket listings as proof of current state

A receipt with private data or secrets is itself a Red artifact and requires quarantine, revocation, and replacement.

## Runtime Eligibility Boundary

Receipt existence is required but not sufficient for runtime eligibility. A future pack can only move toward runtime eligibility when future owning issues prove:

- source binding
- freshness
- revocation
- review/risk/jurisdiction
- release receipt
- rollback
- compatibility
- Step Quality
- computed runtime eligibility
- runtime consumption

Before AMB-617 / PLOS-M10 proves runtime consumption, receipts must not claim R2 is runtime-on. Before AMB-635 / PLOS-M26 passes production gauntlets, receipts must not claim production readiness.

## Failure Handling

Receipt failures route as follows:

- missing receipt: block stage/release/promotion
- hash or signature mismatch: quarantine artifact and manifest
- unknown or revoked signer: block release and route to signer review/revocation
- missing source binding: source-needed and blocked
- stale/contradicted/revoked source: block, revoke, supersede, or rollback
- missing risk/jurisdiction review: review-needed
- private data or secret present: quarantine, revoke affected artifact, and replace receipt
- rollback target missing or unverifiable: block release/promotion
- unsupported schema or compatibility: quarantine and fallback only to verified last-known-good
- live R2 evidence requested outside owning issue: blocked as scope violation

No failure may be repaired by silently overwriting released bytes, deleting receipts, relabeling an older pack, relying on bucket listing order, or claiming runtime eligibility from receipt presence alone.

## Non-Claims

This artifact does not implement receipt storage, receipt generation tooling, signing, release promotion, pack publication, R2 staging activation, Cloudflare/R2 account setup, credentials, live R2 writes, canary objects, network validation, runtime fetch/cache/quarantine behavior, computed runtime eligibility, runtime pack consumption, production readiness, privacy/legal approval, release readiness, accessibility proof, device proof, security certification, or measured performance proof.
