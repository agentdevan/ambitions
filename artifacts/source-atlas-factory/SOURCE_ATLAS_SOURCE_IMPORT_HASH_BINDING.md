# Source Atlas Source Import / Hash Binding

Status: Green for AMB-679 / PLOS-053 source import and immutable hash-binding documentation scope; Yellow for importer implementation, schema migration, hash tooling implementation, release tooling, pack publication, runtime eligibility proof, live R2 promotion, privacy/legal approval, release readiness, device proof, accessibility proof, and measured performance proof.
Updated: 2026-06-12 America/New_York
Owning issue: AMB-679 / PLOS-053
Parent issue: AMB-613 / PLOS-M05

## Boundary

This artifact defines how Source Atlas public/source-backed material must be imported, normalized, bound to immutable hashes, and carried through provenance before it can be eligible for later pack validation or release lanes.

It does not implement an importer, change Swift schemas, migrate existing packs, publish packs, provision Cloudflare/R2, create credentials, perform live R2 writes, change runtime eligibility, or implement runtime pack consumption.

Source import is a control-plane contract. It is not proof that any current pack is production published, legally approved, runtime-eligible, privacy-approved, or release-ready.

## Import Contract

Every imported source-backed item must create a source import record before extraction or pack assembly. The record must contain:

- stable import id and owning pack or foundry job id
- source kind, title, canonical locator, and retrieval locator
- source authority class and source owner or publisher where known
- retrieved-at timestamp and effective-at or published-at timestamp when available
- license, redistribution, and public-reference posture
- source snapshot reference or external immutable reference
- raw source content hash
- normalized source content hash
- canonicalization version and importer contract version
- source record ids and claim ids produced from the import
- validation artifact ids, reviewer ids, and review state
- freshness, risk, jurisdiction, contradiction, and revocation states
- private-data scan result and no-private-user-data assertion
- release receipt, rollback, supersession, and revocation pointers when the import later participates in release

Imports that cannot satisfy the source locator, hash, license/redistribution, private-data, or provenance fields remain `source_needed`, `review_needed`, or `quarantined`. They cannot advance to staged or released states.

## Hash Binding

Hash binding is immutable and multi-layered:

| Hash | Required input | Purpose |
|---|---|---|
| `raw_source_hash` | exact captured source bytes or exact externally-addressed source snapshot | proves the imported material has not silently changed |
| `normalized_source_hash` | canonicalized text/table/media-derived payload after deterministic normalization | proves extraction used the reviewed normalized payload |
| `extraction_hash` | extracted claims, requirements, proof-map references, and source ids | proves pack content came from the reviewed source payload |
| `pack_payload_hash` | serialized pack payload bytes | proves staged/released pack bytes are immutable |
| `manifest_hash` | signed manifest or release metadata bytes | proves release metadata points at the intended payloads |

Rules:

- A hash mismatch routes the import or pack to quarantine.
- A missing hash keeps the item source-needed or review-needed.
- A canonicalization change creates a new lineage entry; it must not overwrite prior hashes.
- Rehashing is allowed only as a new reviewed import version with recorded reason and prior hash pointer.
- Pack payload hashes cannot be treated as source hashes; they prove different evidence.
- User-provided local mini-pack material can remain local/private but cannot be promoted to public Source Atlas authority or R2 source truth.

## Provenance Requirements

Every claim, requirement, proof-map entry, and release receipt that depends on an imported source must be able to trace back to:

- source import id
- `SourceAtlasSourceRecord.id`
- source kind and authority class
- canonical source locator
- raw and normalized source hashes
- retrieval and review timestamps
- license/redistribution posture
- extraction and canonicalization versions
- validation artifact paths
- reviewer decision and review state
- freshness, contradiction, risk, jurisdiction, and revocation state
- release receipt and rollback pointer if released

The existing Swift model anchors are:

- `SourceAtlasSourceRecord` has source kind, locator, retrieved-at, content hash, and official-claim approval fields.
- `SourceAtlasClaim` carries `sourceIDs`, confidence/freshness state, review requirement, and provenance eligibility.
- `SourceAtlasProofMapEntry` carries source record ids and source claim ids for proof binding.
- `SourceAtlasPack` carries sources, claims, requirements, proof map, runtime boundary, composition, freshness, and risk policy.
- `SourceAtlasStore` verifies declared SHA-256 against payload bytes and quarantines hash mismatches, corrupt JSON, unsupported schema, invalid packs, revoked packs, and contradicted packs.
- `SourceAtlasFreshnessManifest` carries pack SHA, signature, rollback pointers, and changed claim buckets.
- `SourceAtlasUserMiniPackBuilder` keeps user-provided mini-pack source records local/private and non-official.

These anchors are source/control-plane evidence only. AMB-679 does not claim the current models are the final schema or that an importer implementation exists.

## Import States

| State | Meaning | Runtime/release posture |
|---|---|---|
| `intake_requested` | source candidate identified but not captured | not eligible |
| `source_captured` | exact source bytes or immutable external snapshot captured | not eligible |
| `hash_bound` | raw and normalized source hashes recorded | not eligible |
| `normalized` | deterministic canonicalization completed | not eligible |
| `extracted` | claims, requirements, and proof references extracted with source ids | not eligible |
| `review_needed` | source, rights, risk, jurisdiction, freshness, contradiction, or privacy requires review | blocked |
| `validated` | source binding and validation pass for the current import version | may proceed to pack staging only |
| `quarantined` | hash, source, rights, privacy, contradiction, revocation, or validation failure | blocked |

## Failure Handling

The import is blocked when any of these occur:

- missing source locator or unverifiable source authority
- missing raw or normalized source hash
- hash mismatch between source snapshot, normalized payload, extracted records, pack payload, or manifest
- unsupported license, unclear redistribution posture, or unknown public-reference boundary
- private user data, local goals, captures, schedules, proof, profile data, files, health/location, diagnostics, identifiers, or inferred private context enters a public/source-backed lane
- stale, contradicted, revoked, disputed, unsupported, or unknown source state
- high-risk, jurisdiction-sensitive, legal, financial, medical, certification, education, crisis, or minor-related content lacks strict review
- extracted claim lacks source record binding
- release receipt or rollback pointer is missing for a released artifact

Blocked imports must route to review-needed, source-needed, quarantine, revocation, or supersession. They must not be silently accepted or used as current runtime source authority.

## R2 Boundary

R2 artifacts may contain public source-pack payloads, manifests, hashes, receipts, rollback pointers, and source/provenance references only after a future active issue owns the release/promotion scope.

R2 artifacts must not contain private user data or local mini-pack content. A released R2 pack must trace back to source material, validation outputs, review decisions, and immutable hash evidence.

AMB-679 performs no live R2 writes and creates no credentials, buckets, objects, or network proof. Live Linear shows AMB-973 as a future Backlog child for R2 staging infrastructure; that future issue is not active AMB-679 scope.

## Scaling Hotspots

Future implementation should bound:

- large source snapshot storage and retention
- canonicalization cost for long documents and tables
- duplicate source import detection
- hash lineage fan-out across pack families
- review queue growth for high-risk and jurisdiction-sensitive content
- source freshness and revocation revalidation cadence
- provenance graph lookup cost during release and rollback

No measured storage, network, CPU, battery, or performance proof is claimed by AMB-679.

## Non-Claims

This artifact does not implement importer tooling, schema migration, hash canonicalization tooling, validators, scanners, release tooling, pack publication, Cloudflare/R2 setup, credential creation, live R2 writes, runtime fetch/cache/quarantine, runtime eligibility, runtime pack consumption, privacy/legal approval, release readiness, device proof, accessibility proof, security certification, or measured performance proof.
