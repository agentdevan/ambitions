# R2 Immutable Pack Path Strategy

Status: Green for AMB-669 / PLOS-041 immutable pack path strategy scope; Yellow for release tooling implementation, live Cloudflare/R2 account proof, bucket provisioning, network validation, runtime fetch/cache/quarantine implementation, privacy/legal approval, release readiness, device proof, accessibility proof, and performance proof.
Updated: 2026-06-12 America/New_York
Owning issue: AMB-669 / PLOS-041
Parent issue: AMB-612 / PLOS-M04

## Boundary

This strategy narrows the AMB-668 bucket/object layout into released-pack path, version, and supersession rules. It applies only to public, non-user-specific Source Atlas artifacts.

It does not publish packs, create credentials, provision buckets, implement release tooling, implement runtime fetch, mark packs runtime-eligible, or perform live R2 writes.

## Immutable Path Contract

Every released pack artifact is addressed by a content-bound path. Once a released object exists at a path, its body and integrity metadata are never mutated in place.

Canonical path shape:

```text
<ring>/<family>/<domain>/<schema>/<artifact-id>/<version>/<sha256>/<filename>
```

Pack-specific filename shape:

```text
<artifact-id>.<version>.<kind>.json
```

Rules:

- `ring` is the release ring: `dev`, `staging`, or `prod`.
- `family` is one of the AMB-668 allowlisted pack families, such as `packs/source`, `packs/seeds`, `packs/starter`, `packs/elasticity`, `packs/replacement`, or `packs/jurisdiction`.
- `domain` is a public Source Atlas domain slug, or `global` when the artifact is cross-domain.
- `schema` is `schema-v<major>` and changes only when the artifact contract has a breaking schema change.
- `artifact-id` is stable, public, non-user-specific, and independent of version.
- `version` is semantic or date-versioned.
- `sha256` is the lowercase digest of the canonical object payload.
- `filename` repeats artifact id and version so downloaded files remain intelligible outside path context.

No segment may contain user text, user identifiers, private goals, private locations, device identifiers, account ids, token material, or raw source-needed text.

## Version Addressing

Versions identify release intent. Hashes identify exact bytes. Runtime and tooling must require both.

| Version class | Example | Allowed use |
|---|---|---|
| Semantic | `v1.2.0` | Pack contracts with intentional compatibility and patch/minor/major meaning. |
| Date version | `2026-06-12` | Public rule, jurisdiction, freshness, and policy packs tied to effective dates. |
| Revision suffix | `v1.2.0-r2` | Repair release when the release receipt records the prior bad version and rollback/supersession reason. |

Version-only lookup is never enough for runtime eligibility. A current manifest must point to the exact path, expected hash, signature/checksum state, schema, freshness, revocation state, compatibility envelope, release receipt, and rollback target.

## Supersession

Supersession is represented by a new manifest or index entry. It never mutates the old pack.

Required supersession fields:

- superseded artifact id
- superseded version
- superseded sha256
- replacement artifact id
- replacement version
- replacement sha256
- supersession reason class: `source_changed`, `freshness_expired`, `security_revoked`, `schema_replaced`, `policy_updated`, `data_error`, or `rollback`
- effective date
- release receipt id
- rollback target when applicable

Old paths remain addressable for audit, rollback, and receipt verification unless a future revocation manifest blocks them. Addressable does not mean runtime-eligible.

## Current Pointers

Current state is always a signed manifest/index decision, not a bucket-listing decision.

Runtime and tooling must not:

- infer current versions from lexical sort
- infer current versions from latest modified time
- overwrite a pack at an existing immutable path
- use an alias key like `latest.json` as a pack body
- treat a hash-addressed object as current without a manifest

Allowed pointer artifacts:

- `manifests/current`
- `manifests/index`
- `freshness`
- `revocations`
- `compatibility`
- `rollback-manifests`

Pointer artifacts are themselves hash-addressed and replaced by publishing new pointer objects. They may name a current pack, but they do not change pack bytes.

## Cache Friendliness

Immutable pack objects are long-cache candidates because their path includes version and hash. Manifest, freshness, revocation, compatibility, and rollback objects are short-cache candidates because they encode current selection and safety state.

Cache policy expectations:

- Hash-addressed pack paths can use long TTLs after future compatibility proof.
- Current manifests, revocation lists, freshness manifests, compatibility tables, and rollback manifests use short TTLs.
- Runtime reads manifest first, then exact pack path.
- A changed current manifest points to a new path, not a mutated pack.
- Quarantined or revoked paths are retained only for local audit/receipt behavior when safe and must not drive current recommendations.

## Provenance Preservation

Path immutability protects provenance by making the following violations Red:

- released pack body changes without path change
- version changes without release receipt
- hash mismatch between path, metadata, manifest, and payload
- supersession without reason, effective date, replacement target, and release receipt
- runtime eligibility from a pack that lacks source binding, freshness, revocation, release receipt, rollback, and compatibility proof
- private user data in any path, object body, metadata, manifest, validation report, release receipt, request, log, screenshot, or support artifact

## Rollback / Failure

If a released pack is bad, the repair path is:

1. Publish a revocation or rollback manifest that names the bad artifact id, version, and sha256.
2. Publish a new replacement pack at a new immutable path if replacement is available.
3. Publish a new current manifest that points to the replacement or last-known-good path.
4. Preserve the bad path for audit unless safety policy requires blocking local use.
5. Record the release receipt and rollback reason.

The bad pack path is never overwritten.

## Non-Claims

This artifact does not implement release tooling, publish packs, configure Cloudflare/R2, create buckets, create credentials, perform live R2 writes, validate live R2 operations, implement runtime fetch/cache/quarantine behavior, mark packs runtime-eligible, approve privacy/legal posture, prove release readiness, prove accessibility, prove device behavior, or prove performance.
