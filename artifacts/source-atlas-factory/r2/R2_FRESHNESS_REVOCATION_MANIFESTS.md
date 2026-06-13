# R2 Freshness And Revocation Manifest Semantics

Status: Green for AMB-671 / PLOS-043 freshness and revocation manifest semantics scope; Yellow for background fetch implementation, runtime evaluator implementation, live R2 account proof, bucket provisioning, network validation, release tooling, privacy/legal approval, release readiness, device proof, accessibility proof, and performance proof.
Updated: 2026-06-12 America/New_York
Owning issue: AMB-671 / PLOS-043
Parent issue: AMB-612 / PLOS-M04

## Boundary

This artifact defines how public Source Atlas freshness and revocation manifests represent freshness windows, stale thresholds, revocation payloads, cache invalidation semantics, and degraded-mode routing.

It does not implement background fetch, runtime parsing, runtime evaluation, release tooling, pack publication, Cloudflare/R2 provisioning, credential creation, or live R2 writes.

Freshness and revocation manifests are public-reference-only. They must not include private user data, user identifiers, device identifiers, raw private goal text, private source-needed requests, diagnostics, support bundles, secrets, or write-token material.

## Freshness Manifest

Freshness manifests declare whether a public pack/source/claim set is current enough for runtime consideration. Freshness is separate from compatibility and signature validity: a pack can be signed and compatible yet still stale.

Required fields:

- manifest id and schema version
- generated timestamp and next-review timestamp
- freshness window id
- source domain and source authority id
- artifact ids, versions, sha256 values, and immutable object paths
- source observed-at timestamp
- source reviewed-at timestamp
- stale-after timestamp
- hard-expiry timestamp when the source cannot be safely used past a date
- changed claim ids
- claim state buckets: `source_needed`, `stale`, `contradicted`, `revoked`, or `locally_proven`
- fallback behavior: `last_known_good`, `source_needed`, `review_needed`, `degraded`, or `blocked`
- owner/reviewer id for public source stewardship
- release receipt id
- compatibility manifest id
- revocation manifest id
- rollback manifest id
- signing/hash state

Freshness windows must be explicit per source class. Jurisdiction, safety, medical, financial, legal, and high-risk rule packs need shorter stale windows than stable public template packs.

## Revocation Manifest

Revocation manifests declare objects, sources, claims, signers, or manifests that are no longer runtime-eligible.

Required fields:

- manifest id and schema version
- generated timestamp and effective timestamp
- revoked artifact id, source id, claim id, manifest id, signer id, or sha256
- affected immutable object paths and versions
- revocation reason class: `source_withdrawn`, `source_contradicted`, `security_revoked`, `signer_revoked`, `hash_mismatch`, `private_data_leak`, `policy_replaced`, `jurisdiction_changed`, `schema_replaced`, or `data_error`
- severity: `block`, `quarantine`, or `degraded`
- replacement pointer or rollback manifest id when available
- current manifest id that supersedes the revoked object when available
- release receipt id
- signing/hash state
- owner/reviewer id

Revocation is fail-closed. A matching revocation blocks runtime eligibility even if the pack remains immutable, signed, available in R2, present in cache, or compatible by schema.

## Runtime Eligibility Routing

Runtime eligibility requires all of:

- exact immutable path and sha256 match
- valid signature or pinned checksum state
- compatible manifest/schema/runtime envelope
- freshness state is current or explicitly allowed degraded
- no matching revocation for pack, source, claim, signer, manifest, hash, or path
- release receipt, rollback pointer, and source authority reference

Missing or unverifiable freshness/revocation data is Red for production runtime use. It routes to `source_needed`, `review_needed`, `degraded`, or `blocked`; it must not silently pass as current.

| State | Runtime eligibility | Route |
|---|---|---|
| Current and not revoked | Eligible after all other gates pass. | Use exact manifest-selected object. |
| Soft stale | Not current. | Use degraded explanation or source-needed/review-needed route. |
| Hard expired | Not eligible. | Block or last-known-good if the replacement verifies and is not stale/revoked. |
| Source needed | Not eligible as authoritative. | Ask for source review or use local/bundled non-authoritative fallback. |
| Review needed | Not eligible as current. | Route to manual/public source review queue. |
| Contradicted | Not eligible. | Quarantine and require replacement or owner review. |
| Revoked | Not eligible. | Block/quarantine and route to rollback or replacement. |
| Unknown/missing | Not eligible. | Fail closed to source-needed/review-needed. |

## Cache Invalidation And Offline Behavior

Freshness, revocation, current, compatibility, and rollback manifests are short-TTL control objects. Immutable pack objects can use long TTLs only after exact hash verification and only while freshness and revocation state remain valid.

Cache rules:

- A new revocation manifest invalidates cached eligibility for matching packs, claims, sources, signers, manifests, paths, and hashes.
- A new freshness manifest can downgrade current packs to stale/source-needed/review-needed without changing pack bytes.
- Offline use may rely on a verified last-known-good pack only when its freshness window allows offline grace, it is not hard-expired, and no cached revocation blocks it.
- If the app cannot refresh revocation state within the allowed window, high-risk packs route to blocked/review-needed, not silent use.
- Degraded mode must be inspectable and must not imply current source confidence.

## Golden Slice And Source Authority Feed

This spec feeds future Source Authority runtime eligibility and Golden Slice revocation/offline proof. Future implementation must demonstrate:

- stale pack routes away from current recommendations
- revoked pack becomes runtime-ineligible even when cached
- offline grace is bounded and explainable
- missing freshness/revocation manifests fail closed
- replacement or rollback target verifies before use

No Golden Slice runtime proof is claimed by this documentation artifact.

## Performance Notes

Freshness and revocation manifests should be compact control documents. They should avoid embedding full packs, large validation logs, screenshots, source bodies, support artifacts, or private diagnostics.

Refresh cadence should be risk-class based:

- high-risk/public-rule packs: shortest control-manifest TTL and no silent stale use
- active source packs: moderate TTL with explicit source-needed/review-needed fallback
- stable template/seed packs: longer TTL when no revocation and no hard expiry applies

No measured network, battery, memory, or latency proof is claimed by this spec.

## Non-Claims

This artifact does not implement background fetch, manifest parsing, freshness evaluation, revocation evaluation, runtime quarantine, release tooling, pack publication, Cloudflare/R2 setup, credential creation, live R2 writes, network validation, production-readiness proof, privacy/legal approval, release readiness, device proof, accessibility proof, or performance proof.
