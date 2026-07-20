+++
spec_id = "SYSTEM-SOURCE-ATLAS"
title = "Source Atlas"
kind = "system"
status = "normative"
owner_domain = "system-source-atlas"
canon_revision = 1
profile = "system-v1"
owns_concepts = ["system.source-atlas.public-reference", "system.source-atlas.egress-firewall"]
inherits = ["LAW-R2-PUBLIC-ONLY-001", "LAW-LOCAL-AUTHORITY-001", "LAW-OFFLINE-NO-ACCOUNT-001", "CONST-PROOF-EVIDENCE-001"]
depends_on = ["CONSTITUTION", "OBJECT-SOURCE-REFERENCE", "SYSTEM-PRIVACY-DATA-CLASSIFICATION", "SYSTEM-PRIVATE-LIFE-RUNTIME"]
source_owners = ["Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/", "Native/Ambitions/Core/LocalRuntimeOS/Boundary/", "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/", "Native/Ambitions/Core/LocalRuntimeOS/Planning/", "Native/Ambitions/Core/LocalRuntimeOS/Inspection/", "Native/Ambitions/Quality/"]
+++

# Source Atlas

This target constrains Source Atlas and R2 to public/reference/freshness infrastructure.

## SYSTEM-SOURCE-ATLAS-PUBLIC-001 — Source Atlas supplies verified public context only

- **Concept:** `system.source-atlas.public-reference`
- **Modality:** `MUST`
- **Scope:** Source packs, provenance, verification, freshness, cache, R2 delivery, and local planning composition
- **Status:** `normative`
- **Verification:** `SCENARIO-SYSTEM-SOURCE-ATLAS-PUBLIC-001`
- **Supersedes:** none

Source Atlas MAY retrieve, verify, cache, and project approved public/reference/provenance/freshness data. Local Planning may deterministically match that public corpus to private intent entirely on device while preserving source, freshness, uncertainty, correction, rejection, and unavailable fallback. Source Atlas is not a marketplace, private intelligence store, canonical life graph, or mutation authority.

Source Atlas and R2 MAY store or deliver approved public or reference packs, manifests, freshness, provenance, non-sensitive schemas, and non-sensitive connector or account state; Source Atlas and R2 MUST remain public, reference, and freshness infrastructure only and MUST NOT become a planner, private backend, hidden recommendation engine, or private-graph store.

## SYSTEM-SOURCE-ATLAS-FIREWALL-001 — Requests and R2 artifacts contain no private graph signal

- **Concept:** `system.source-atlas.egress-firewall`
- **Modality:** `MUST NOT`
- **Scope:** Query, URL/path, headers, account/access state, cache keys, telemetry, pack feedback, diagnostics, R2 object naming, and every Source Atlas network payload
- **Status:** `normative`
- **Verification:** `PRIVACY-SOURCE-ATLAS-NO-PRIVATE-GRAPH-EGRESS-001`
- **Supersedes:** none

Source Atlas/R2 MUST NOT receive, store, infer from, personalize from, or transmit Goals, Life Areas, Captures, notes, attachments, calendar facts, schedules, availability, Protected time, Proof, Receipts, closure/history, corrections, behavior patterns, inferred priorities, recommendation context, stable private identifiers, private search terms, private-derived cache keys, or the private life graph. Requests are selected only from a finite allowlisted public artifact namespace; unrecognized or private-influenced request shapes fail closed. No user feedback or diagnostics path may smuggle private context upstream.

## Completeness contract

<!-- canon-section: responsibility-non-responsibility -->
Source Atlas governs verified public artifact delivery and local public cache behavior.
Owns public artifact manifest/provenance/integrity/freshness, allowlisted requests, verified local cache, public projections, and unavailable fallback. It does not own private matching inputs, user personalization, canonical mutation, hosted planning, account profile, telemetry, or private data.

<!-- canon-section: inputs-outputs -->
The contract consumes allowlisted public artifact IDs, pack/freshness/integrity metadata, non-sensitive entitlement/access state, and local cache state. It emits verified public packs/projections, provenance/freshness status, cache result, and local-only planning input; private intent never becomes a request input.

<!-- canon-section: authority-boundary -->
`SourceAtlas/` and R2 own public/reference delivery only. `Boundary/` and `PrivacySecurity/` enforce finite request schemas; `Planning/` performs private matching locally; `Inspection/` exposes sources. No adapter or pack can issue canonical Commands or write private state directly.

<!-- canon-section: data-classification -->
Network/cache artifacts are public reference plus non-sensitive access state. Local private matches, rejections, usage, recommendation effects, searches, and corrections are private graph data and excluded from all Source Atlas/R2 payloads, keys, logs, and feedback.

<!-- canon-section: state-model -->
The state model binds each public artifact and request to verification and cache facts.
Artifacts distinguish bundled, cached-verified, fresh, stale-usable, invalid, quarantined, unavailable, and superseded with manifest/version/hash/provenance. Requests distinguish allowlisted, denied, fetched, verified, failed, and reconciled.

<!-- canon-section: failure-recovery -->
Failure handling keeps the public firewall closed and selects a verified local fallback.
Offline, stale, invalid signature/hash/schema, unknown artifact, server error, entitlement loss, or cache corruption yields bundled/last-verified fallback or quiet unavailability. Invalid content is quarantined; failure never blocks core or relaxes the firewall.

<!-- canon-section: local-network-boundary -->
No-account/offline core and bundled/local public packs remain usable. Network fetch is optional freshness only, contains no private-derived signal, and cannot be triggered by free-form private intent. Hosted AI and server-side profiling are excluded.

<!-- canon-section: determinism -->
Stable verified public pack, local private inputs, policy, clock, and seed produce equivalent on-device composition and explanation. Network timing affects freshness state only, not accepted private mutation semantics.

<!-- canon-section: observability -->
Local redacted traces record allowlisted artifact/request ID, manifest/hash/provenance/freshness/cache/verification result, firewall decision, and local composition policy without private query, object, match, or behavior values.

<!-- canon-section: source-ownership -->
Canonical ownership is divided among SourceAtlas, Boundary, PrivacySecurity, local Planning, Inspection, and Quality.
Exact target owners are `Core/LocalRuntimeOS/SourceAtlas/`, `Boundary/`, `PrivacySecurity/`, local `Planning/`, and `Inspection/`; `Quality/` owns firewall and pack proof. The remediation freeze bars Source Atlas production growth without ADR allowlist and Green changed-scope boundary audit.

<!-- canon-section: tests-proof -->
Test finite request allowlist, every prohibited private category in URL/path/header/body/key/log/feedback, mixed payload, identifier joining, free-form private queries, malicious pack/manifest, signature/hash/schema, cache quarantine, offline/stale/bundled fallback, no-account access, entitlement loss, deterministic local composition, correction/rejection privacy, and the exact no-private-graph egress audit.

<!-- canon-section: performance-resource-constraints -->
Fetch, verification, decode, cache, and local composition are bounded, cancellable, size/decompression limited, off-main where material, and lifecycle-safe. Article 31 calibration must define representative pack/cache/candidate scale, device/OS/build/network/tool, percentile/maximum, memory/energy/storage, and regression threshold; no invented numeric budget or production proof appears here.
