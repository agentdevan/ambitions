# Source Atlas Claim Extraction / Duplicate Detection

Status: Green for AMB-680 / PLOS-054 claim extraction and duplicate-detection documentation scope; Yellow for extraction engine implementation, duplicate scanner implementation, schema migration, release tooling, pack publication, runtime eligibility proof, live R2 promotion, privacy/legal approval, release readiness, device proof, accessibility proof, and measured performance proof.
Updated: 2026-06-12 America/New_York
Owning issue: AMB-680 / PLOS-054
Parent issue: AMB-613 / PLOS-M05

## Boundary

This artifact defines how Source Atlas source-backed material becomes candidate claims and requirements, and how duplicate/conflict detection must preserve provenance before a pack can advance to later validation or release lanes.

It does not implement an extraction engine, duplicate scanner, merge tool, schema migration, pack publication, Cloudflare/R2 setup, credential creation, live R2 writes, runtime eligibility, or runtime pack consumption.

Claim extraction is a source/provenance contract. It is not proof that production extraction tooling exists.

## Extraction Contract

Every extracted claim must retain enough evidence to be reviewed, rejected, merged, superseded, or traced back to source import evidence.

Required extracted-claim fields:

- stable claim id
- source import id and `SourceAtlasSourceRecord.id`
- source locator and source hash lineage
- extractor contract version and extraction timestamp
- source text range, table row, media segment, or external source reference
- normalized claim text
- claim subject, predicate/action, object/value, qualifiers, and applicability envelope
- effective date, published date, stale-after date, and jurisdiction/scope when known
- source kind, authority level, freshness state, risk class, and review state
- confidence state and uncertainty flags
- produced requirement ids
- proof-map entry ids that depend on the claim
- duplicate group id or distinct-claim reason when evaluated
- contradiction group id when content conflicts rather than duplicates
- reviewer decision id for high-risk, ambiguous, merged, or rejected claims

Claims without source record binding remain `source_needed` or `review_needed`. Claims extracted from local/private user material remain local/private and cannot become public Source Atlas authority or R2 source truth.

## Requirement Projection

Requirements derived from claims must preserve the claim id and source state. A requirement cannot be more authoritative than its backing claim.

Projection rules:

- one claim may produce multiple requirements when the source sentence encodes separate eligibility, deadline, cost, proof, safety, or jurisdiction conditions
- one requirement may reference one canonical claim id plus source/proof aliases, but it must not hide contradictory claims
- requirement source, freshness, risk, and review states inherit the strictest relevant claim/source state
- requirements that drive current recommendations need source-backed claims, non-stale freshness, non-blocked review, and proof binding
- high-risk or jurisdiction-sensitive requirements route to review before any current recommendation use

## Duplicate Detection

Duplicate detection must separate true duplicates from near-overlaps and contradictions.

| Detection class | Meaning | Required handling |
|---|---|---|
| `exact_claim_id_duplicate` | same claim id appears more than once | reject or quarantine until ownership is repaired |
| `same_source_duplicate` | same source, same normalized claim, same applicability | merge only with identical source state and review state |
| `cross_source_equivalent` | different sources assert the same claim with compatible authority/freshness | keep canonical claim plus source aliases after review |
| `near_duplicate` | claims overlap but differ by date, jurisdiction, qualifier, actor, risk, or source state | route to merge review |
| `contradictory_claim` | claims conflict in value, permission, deadline, eligibility, safety, or source state | do not merge; route to contradiction review |
| `superseded_claim` | newer source replaces older source without contradiction | preserve old claim as superseded with rollback lineage |
| `private_public_collision` | local/private user material resembles public source claim | keep separate; never promote private material to public source authority |

## Merge Rules

Merging is allowed only when all of these are true:

- normalized claim meaning is equivalent
- source states are compatible
- freshness states do not conflict
- risk and jurisdiction envelopes match or are explicitly reviewed
- no source is revoked, contradicted, disputed, unsupported, or stale-critical
- no private/local user material is being merged into public Source Atlas authority
- reviewer decision exists for high-risk, jurisdiction-sensitive, near-duplicate, or cross-source equivalent claims
- all source ids, hashes, extraction versions, and review decisions remain traceable

Merging must preserve aliases, source ids, original claim ids, extraction hashes, review decisions, and rollback/supersession pointers. It must not overwrite old claim bytes, delete contradictory evidence, or make a stale/community source look official/current.

## Resolution States

| State | Meaning | Pack/release posture |
|---|---|---|
| `unique` | no duplicate or contradiction found | may proceed if other gates pass |
| `possible_duplicate` | similarity detected but not proven equivalent | review-needed |
| `duplicate_confirmed` | reviewer or deterministic rule confirms equivalent claim | merge allowed only with provenance preservation |
| `merge_review_needed` | merge would change source/freshness/risk/jurisdiction meaning | blocked |
| `distinct_conflict` | similar claims are conflicting, not duplicates | contradiction review |
| `superseded` | old claim replaced by newer reviewed claim | preserve rollback lineage |
| `quarantined` | duplicate/merge state is unsafe or malformed | blocked |

## Existing Source Anchors

AMB-680 inspected these anchors:

- `SourceAtlasClaim` carries claim id, text, state, freshness, risk, source ids, review requirement, and current-recommendation eligibility.
- `SourceAtlasRequirement` binds requirements to claim ids and carries source/freshness/risk/review state.
- `SourceAtlasProofMapEntry` binds proof to requirement ids, source record ids, and source claim ids.
- `SourceAtlasPackValidator` rejects invalid official claims without approved sources, high-risk review bypass, invalid requirement overlays, and proof that cannot support current requirements.
- `SourceAtlasPackFactoryLite` rejects duplicate YAML mapping keys during lightweight pack parsing.
- `AmbitionsOSLivingDreamSourceClaimGraphIssue.duplicateClaimID` exists as an adjacent source-claim duplicate issue type.
- `KnowledgeClaimSet` models conflicting unresolved provider claims and uncertainty flags.
- Prior M05 artifacts define source import/hash binding, pack state/review gates, source-bound draft, duplicate/contradiction pass, validation gauntlet, and quarantine behavior.

These anchors are source/control-plane evidence only. AMB-680 does not claim the final extraction schema or implementation exists.

## Failure Handling

Route to review-needed, contradiction review, quarantine, source-needed, or supersession when:

- claim has no source ids or source hash lineage
- duplicate id appears in a pack/import batch
- near-duplicate differs by date, jurisdiction, qualifier, actor, risk, or source state
- source states conflict or freshness is stale/unknown/revoked
- one source is official/current and another is community/stale/unsupported
- high-risk or jurisdiction-sensitive claim lacks review
- private user material collides with public source material
- merge would remove contradiction evidence or rollback lineage
- requirement would become more authoritative than its backing claim

Prefer unresolved review over unsafe merge.

## Scaling Hotspots

Future implementation should bound:

- normalized claim comparison over large source batches
- cross-pack duplicate group recalculation
- contradiction scans across source/freshness/jurisdiction variants
- merge-review queue growth
- alias/provenance graph lookup cost
- rollback/supersession lineage growth
- high-risk duplicate review latency

No measured performance, storage, network, CPU, or battery proof is claimed by AMB-680.

## Non-Claims

This artifact does not implement extraction tooling, duplicate scanners, merge tooling, schema migration, validators, release tooling, pack publication, Cloudflare/R2 setup, credential creation, live R2 writes, runtime fetch/cache/quarantine, runtime eligibility, runtime pack consumption, privacy/legal approval, release readiness, device proof, accessibility proof, security certification, or measured performance proof.
