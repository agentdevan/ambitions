# R2 Release Rings And Rollback Manifest Spec

Status: Green for AMB-672 / PLOS-044 release ring and rollback manifest specification scope; Yellow for automated deployment tooling, rollback drill execution, live R2 account proof, bucket provisioning, network validation, release tooling, privacy/legal approval, release readiness, device proof, accessibility proof, and performance proof.
Updated: 2026-06-12 America/New_York
Owning issue: AMB-672 / PLOS-044
Parent issue: AMB-612 / PLOS-M04

## Boundary

This artifact defines public Source Atlas release rings, promotion boundaries, rollback manifest fields, safe retreat behavior, and provenance requirements.

It does not implement deployment tooling, publish packs, configure Cloudflare/R2, create credentials, perform live R2 writes, execute rollback drills, or mark any pack runtime-eligible.

Release ring and rollback metadata is public-reference-only. It must not contain private user data, user identifiers, device identifiers, raw private goal text, private source-needed requests, diagnostics, support bundles, secrets, account ids, or write-token material.

## Release Rings

Rings describe release confidence and runtime eligibility. They may be implemented as physical buckets or as equivalent first-prefix partitions.

| Ring | Purpose | Runtime eligibility | Promotion authority |
|---|---|---|---|
| `dev` | Local/developer candidate artifacts and schema experiments. | Not eligible. | Developer/tooling only; no production credentials. |
| `staging` | Public non-user-specific release candidates after local validation. | Not eligible for production runtime. | Staging writer after validation artifacts exist. |
| `prod` | Production public reference/pathing artifacts after release receipt, signing/integrity, compatibility, freshness, revocation, rollback, and source authority gates. | Eligible only after all runtime gates pass. | Production promote role only; no app/runtime write authority. |

Promotion is a pointer/control-manifest decision, not a mutable object overwrite. Pack bytes remain immutable at content-addressed paths.

## Promotion Requirements

A pack or manifest can move toward production only when promotion evidence names:

- source artifact id, version, sha256, immutable path, and source ring
- target artifact id, version, sha256, immutable path, and target ring
- release receipt id
- signer/trust state
- compatibility manifest id
- freshness manifest id
- revocation manifest id
- rollback manifest id
- validation report ids and validator versions
- promotion operator/owner id for public release stewardship
- promotion timestamp
- non-private operation receipt

Production promotion is Red without a tested rollback path or explicitly recorded rollback drill owner. This artifact does not claim that drill has been executed.

## Rollback Manifest

Rollback manifests make safe retreat deterministic while preserving provenance. They never erase the bad artifact; they block or supersede runtime eligibility and point to a verified retreat target.

Required fields:

- rollback manifest id and schema version
- generated timestamp and effective timestamp
- bad artifact id, version, sha256, immutable path, source domain, family, and ring
- bad current manifest id or index entry id
- reason class: `source_changed`, `freshness_expired`, `security_revoked`, `signer_revoked`, `hash_mismatch`, `schema_replaced`, `policy_updated`, `private_data_leak`, `jurisdiction_changed`, `data_error`, or `operator_error`
- severity: `block`, `quarantine`, or `degraded`
- rollback target artifact id, version, sha256, immutable path, source domain, family, and ring
- target release receipt id
- target compatibility manifest id
- target freshness manifest id
- target revocation manifest id
- current manifest id that should select the target
- revocation manifest id that blocks the bad artifact when applicable
- drill evidence id or drill-required owner when drill evidence is not yet available
- signer/trust state and manifest sha256

Rollback target use is allowed only if the target verifies, is compatible, is not stale beyond allowed behavior, is not revoked, and preserves source authority.

## Provenance Preservation

Rollback must preserve:

- bad artifact addressability for audit unless a future safety policy blocks local inspection
- release receipt linkage for both bad and target artifacts
- signer/trust state for both bad and target artifacts
- current/freshness/revocation/compatibility/rollback manifest ids involved in the retreat
- reason, severity, effective date, and owner-visible operation receipt

Rollback must not:

- overwrite immutable pack bytes
- delete or hide release receipts to make a failed release disappear
- relabel an older pack as new without a new manifest and receipt
- promote an unverified target
- allow revoked or private-data-containing artifacts to remain runtime-eligible

## Current Manifest Interaction

Rollback becomes active through control manifests:

1. Revocation manifest blocks the bad artifact, signer, source, claim, path, or hash when needed.
2. Rollback manifest names the verified target.
3. Current manifest points to the target only after compatibility, freshness, revocation, signing, and release receipt gates pass.
4. Cached eligibility for the bad artifact is invalidated.
5. Degraded/offline mode can use the target only within its freshness and revocation allowances.

The app must not infer rollback from bucket listing order, modified times, filename sorting, or alias keys.

## Ring-Induced Fetch Complexity

Ring-aware reads increase control-manifest checks:

- current manifest selects ring and exact path
- compatibility manifest proves app/runtime/schema support
- freshness manifest proves source currency
- revocation manifest blocks bad artifacts and signers
- rollback manifest names verified retreat targets
- release receipt proves promotion lineage

These documents should stay compact. No measured network, battery, memory, or latency proof is claimed by this spec.

## Drill Evidence

Future rollback/revocation drill evidence must capture:

- target environment/ring
- bad artifact id/version/hash/path
- target artifact id/version/hash/path
- manifest ids before and after
- revocation/rollback/current manifest publication evidence
- validation commands and results
- owner-visible action/result receipt
- confirmation that private user data and secrets were absent from operation artifacts

No rollback drill evidence is claimed by this artifact.

## Non-Claims

This artifact does not implement automated deployment tooling, promotion tooling, rollback tooling, rollback drills, runtime ring selection, runtime rollback evaluation, release tooling, pack publication, Cloudflare/R2 setup, credential creation, live R2 writes, network validation, production-readiness proof, privacy/legal approval, release readiness, device proof, accessibility proof, or performance proof.
