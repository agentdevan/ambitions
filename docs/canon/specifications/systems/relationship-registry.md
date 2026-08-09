+++
spec_id = "SYSTEM-RELATIONSHIP-REGISTRY"
title = "Relationship Registry"
kind = "system"
status = "normative"
owner_domain = "system-relationship-registry"
canon_revision = 1
profile = "system-v1"
owns_concepts = ["system.relationship-registry.release-authority", "system.relationship-registry.purpose-boundary", "system.relationship-registry.lifecycle", "system.relationship-registry.consumer-boundary"]
inherits = ["LAW-LOCAL-AUTHORITY-001", "LAW-OFFLINE-NO-ACCOUNT-001", "LAW-R2-PUBLIC-ONLY-001", "CONST-PROOF-EVIDENCE-001"]
depends_on = ["CONSTITUTION", "SYSTEM-SOURCE-ATLAS", "OBJECT-SOURCE-REFERENCE", "GLOBAL-TRUST-INSPECTION", "SYSTEM-PRIVACY-DATA-CLASSIFICATION"]
source_owners = ["Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/", "Native/Ambitions/Core/LocalRuntimeOS/Inspection/", "Native/Ambitions/Core/LocalRuntimeOS/Boundary/", "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/", "Native/Ambitions/Quality/"]
+++

# Relationship Registry

This specification defines authority for immutable public relationships between
source-native concepts. It does not assert that the registry is implemented.

## SYSTEM-RELATIONSHIP-REGISTRY-RELEASE-001 — Releases preserve exact source meaning

- **Concept:** `system.relationship-registry.release-authority`
- **Modality:** `MUST`
- **Scope:** Mapping-set releases, endpoint concepts, predicates, metadata, and review state
- **Status:** `normative`
- **Verification:** `SCENARIO-RELATIONSHIP-REGISTRY-RELEASE-001`
- **Supersedes:** none

Every mapping set and edge MUST have stable identity and bind an immutable set
release to exact subject and object scheme releases, source-native concept IDs,
source bytes and hashes, schema, publisher or curator, dates, method, evidence,
coverage, QA partition, creator and reviewer, and source-specific rights. A label,
shared code, `latest`, or floating endpoint MUST NOT replace an exact identifier
or silently retarget a changed, split, merged, deprecated, or deleted concept.

Every edge MUST preserve its relationship family, exact source predicate,
direction, source meaning, justification, available confidence and source row.
Ambitions review state MUST remain separate from source predicate and provenance:
review MAY narrow product use, but MUST NOT rewrite source meaning, imply external
acceptance, or treat confidence as authority. Unknown required identity, release,
predicate, direction, schema, metadata, review, or rights state MUST fail closed.

## SYSTEM-RELATIONSHIP-REGISTRY-PURPOSE-001 — Purpose never widens a relationship

- **Concept:** `system.relationship-registry.purpose-boundary`
- **Modality:** `MUST NOT`
- **Scope:** Product-use profiles, directions, forbidden propagation, and relationship queries
- **Status:** `normative`
- **Verification:** `SCENARIO-RELATIONSHIP-REGISTRY-NO-INFERENCE-001`
- **Supersedes:** none

Each consumer request MUST name one fixed purpose and receive only stored edges
whose exact product-use profile permits that purpose and direction, together
with explicit limits and forbidden propagation. Source predicate and product-use
profile remain distinct. Ambitions MUST NOT derive a consumer-eligible edge by
chain, transitivity, symmetry, inverse, confidence, similarity, or majority;
MUST NOT transfer qualification, credit, acceptance, Capability, Proof,
recommendation, or another endpoint claim across an edge; and MUST NOT widen an
edge approved for search, explanation, or version migration into another use.
Multiple source edges MAY be inspected as a path only without a derived
conclusion.

## SYSTEM-RELATIONSHIP-REGISTRY-LIFECYCLE-001 — Rights and release state fail closed independently

- **Concept:** `system.relationship-registry.lifecycle`
- **Modality:** `MUST`
- **Scope:** Rights, freshness, validation, promotion, rollback, correction, offline use, reset, and purge
- **Status:** `normative`
- **Verification:** `SCENARIO-RELATIONSHIP-REGISTRY-LIFECYCLE-001`
- **Supersedes:** none

Packaging, transformation, display, retention, and derivation MUST satisfy the
exact mapping-set and both endpoint-source rights; schema or standard licensing
does not authorize source content. Mapping-set and endpoint releases retain
independent clocks. A changed endpoint or set produces an explicit diff and
makes only affected version-sensitive use stale or ineligible until reviewed;
it never floats to a newer release.

Promotion MUST require verified bytes, schema, signature, size, set and endpoint
releases, predicates, directions, integrity, rights and attribution, metadata,
review, conflicts, purpose profiles, coverage, evaluation, and applicable device
proof. Any unknown or failed required state quarantines the candidate and
preserves last-known-good data. Promotion, rollback, correction, reset, and
withdrawal purge MUST be atomic, idempotent, and replay-safe. Eligible bundled
or last-known-good edges remain inspectable offline with actual age; never
fetched or blocked remains unavailable, not `noMatch`. Reset removes downloaded
public data without changing private objects, and mandatory purge resumes until
prohibited raw, derived, index, rendered, cached, and export bytes are removed.

## SYSTEM-RELATIONSHIP-REGISTRY-CONSUMER-001 — Consumers are exact, typed, and read-only

- **Concept:** `system.relationship-registry.consumer-boundary`
- **Modality:** `MUST`
- **Scope:** Snapshots, dependency invalidation, coverage, inspection projections, and consumer APIs
- **Status:** `normative`
- **Verification:** `SCENARIO-RELATIONSHIP-REGISTRY-CONSUMER-001`
- **Supersedes:** none

Consumers MUST receive immutable purpose-eligible edges, limits, coverage, and
dependency bindings from one exact registry snapshot through typed read-only
interfaces. Each use MUST bind snapshot, mapping set and edge revision, endpoint
concept and release, purpose profile, and direction. Change or withdrawal MUST
invalidate only affected dependencies before reuse and MUST NOT rewrite accepted
history, mutate an owning object, approve a candidate, recommend an outcome, or
perform an external action.

Each release MUST expose exact set, edge, endpoint, predicate, method, QA,
review, purpose, conflict, unmapped, authoritative `noMatch`, stale, and rights
coverage with denominators and exclusions. Aggregate quality MUST NOT waive a
false-equivalence, inference-leakage, rights, privacy, or accessibility failure.
The registry accepts no private state and exposes no arbitrary graph traversal,
inference control, recommendation, current-authority adjudication, canonical
mutation, or Capability, Proof, Goal, Path, Step, or schedule API.
