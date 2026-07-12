+++
spec_id = "SYSTEM-PERSISTENCE-REPLAY"
title = "Persistence and Replay"
kind = "system"
status = "normative"
owner_domain = "system-persistence-replay"
canon_revision = 1
profile = "system-v1"
owns_concepts = ["system.persistence.atomicity", "system.persistence.corruption", "system.persistence.replay",
  "system.persistence.compaction",
  "system.persistence.migration",
]
inherits = ["RUNTIME-MUTATION-SEQUENCE-001", "LAW-RUNTIME-DURABLE-SUCCESS-001", "RUNTIME-SOURCE-OWNER-001", "LAW-DATA-LOSS-STOP-SHIP-001"]
depends_on = ["CONSTITUTION", "SYSTEM-PRIVATE-LIFE-RUNTIME", "JOURNEY-BACKUP-RESTORE-RESET"]
source_owners = ["Native/Ambitions/Core/LocalRuntimeOS/Transactions/", "Native/Ambitions/Core/LocalRuntimeOS/EventJournal/", "Native/Ambitions/Core/LocalRuntimeOS/State/", "Native/Ambitions/Core/LocalRuntimeOS/Projections/", "Native/Ambitions/Core/LocalRuntimeOS/Storage/", "Native/Ambitions/Core/LocalRuntimeOS/Repair/", "Native/Ambitions/Quality/"]
+++

# Persistence and Replay

This shadow specification defines intended persistence semantics independently of SwiftData, SQLite, files, or another substrate.

## SYSTEM-PERSISTENCE-ATOMIC-001 — Accepted local intent is atomic and crash-consistent

- **Concept:** `system.persistence.atomicity`
- **Modality:** `MUST`
- **Scope:** Canonical Event, object state, projection invalidation, Receipt metadata, tombstone, attachment reference, migration, and external-effect intent
- **Status:** `normative`
- **Verification:** `SCENARIO-SYSTEM-PERSISTENCE-CRASH-001`
- **Supersedes:** none

A declared local transaction MUST durably commit its complete write set or none. Partial durable stages are permitted only when explicitly modeled with a recovery path and truthful Receipt. The last honest store remains readable across interruption, migration, compaction, backup, restore, projection rebuild, and storage pressure.

Storage failure MUST preserve input or MUST provide a safe export or recovery path.

Relaunch MUST NOT duplicate accepted intent, lose accepted intent, or expose impossible mixed state.

A migration MUST NOT destroy the only readable copy of user data.

## SYSTEM-PERSISTENCE-REPLAY-001 — Canonical history replays equivalently

- **Concept:** `system.persistence.replay`
- **Modality:** `MUST`
- **Scope:** Events, object revisions, tombstones, projections, receipts, migrations, and compaction
- **Status:** `normative`
- **Verification:** `SCENARIO-SYSTEM-PERSISTENCE-REPLAY-001`, `AUDIT-SYSTEM-PERSISTENCE-INVARIANTS-001`
- **Supersedes:** none

Historical Event meaning MUST be immutable and version-decodable. Replaying durable history reproduces logically equivalent canonical state and disposable Projections with validated cursors/checksums; ordinary replay does not repeat external effects. Unsupported stores receive explicit recovery/export handling, never silent reset.

Compaction MUST preserve causal meaning, auditability required by product law, replay equivalence, and deletion semantics.

Migrations MUST preserve object identity, History, recurrence, source, and Receipts.

The owning persistence specification MUST define the minimum supported direct-upgrade version and the behavior for older stores.

Unsupported historical stores MUST require an explicit export/recovery path.

Canonical command, event, and replay identities MUST NOT be silently reset.

Event payloads MUST be versioned and decoded through explicit adapters.

New code MAY reinterpret an old event only through a reviewed migration that preserves auditability and replay equivalence.

External effects MUST NOT be automatically reissued during ordinary replay.

Relaunch MUST reconstruct the same local recommendations, placements, closure, Receipts, and recovery state unless source data changed.

Interrupted commands MUST roll back or resume from an inspectable pending state.

## SYSTEM-PERSISTENCE-COMPACTION-001 — Persistence compaction

- **Concept:** `system.persistence.compaction`
- **Modality:** `MUST`
- **Scope:** Event and projection compaction
- **Status:** `normative`
- **Verification:** `TEST-PERSISTENCE-COMPACTION-001`
- **Supersedes:** none

Compaction MUST preserve canonical outcome, History and Receipt linkage, replay determinism, rollback horizon, crash safety, and privacy deletion obligations.

## SYSTEM-PERSISTENCE-MIGRATION-001 — Persistence migration

- **Concept:** `system.persistence.migration`
- **Modality:** `MUST`
- **Scope:** Schema and event migration
- **Status:** `normative`
- **Verification:** `TEST-PERSISTENCE-MIGRATION-001`
- **Supersedes:** none

Persistence migration MUST be deterministic, idempotent, crash-safe, directly upgrade from the supported horizon, preserve rollback or repair, and prove exact pre/post replay equivalence.

## Completeness contract

<!-- canon-section: responsibility-non-responsibility -->
Owns atomic storage, schema identity, journal/object state, projection persistence, replay, compaction, backup-store and migration substrate contracts. It does not own command policy, continuity merge policy, import meaning, repair decisions, UI state, or private-data egress.

<!-- canon-section: inputs-outputs -->
Inputs are prepared transaction read/write sets, canonical Events/object revisions, invalidations, Receipt metadata, blobs, schema/policy versions, causal order, and idempotency keys. Outputs are durable commit/rejection, cursors/checksums, replay result, invariant result, backup/migration state, and redacted diagnosis.

<!-- canon-section: authority-boundary -->
Storage persists decisions authorized by `Core/LocalRuntimeOS/`; it never creates semantic mutations. `Core/Persistence/` is compatibility debt and cannot gain authority. CloudKit is optional transport, not local store or command authority.

<!-- canon-section: data-classification -->
Stores contain private graph, attachments, receipts, history, corrections, and external metadata under explicit file protection, encryption/key, backup, export, retention, and deletion classes. Projections and App Group snapshots contain only declared minimized fields.

<!-- canon-section: state-model -->
The state model binds durable identity, causal order, health, and rebuild position.
Records carry stable type/logical IDs, schema revision, causal clock, provenance, tombstone state, checksum, migration compatibility, and deterministic decode status. Stores are healthy, degraded, quarantined, migrating, restoring, or blocked; projections are current, stale, rebuilding, or invalid.

<!-- canon-section: failure-recovery -->
Corruption yields redacted diagnosis, quarantine, safe backup/export opportunity, repair preview, rollback protection, and post-repair invariants. Interruption resumes or cleanly rolls back; no migration destroys the only readable copy.

<!-- canon-section: local-network-boundary -->
Persistence, backup, restore, migration, compaction, and replay operate locally without account/network. Network state cannot gate local reads or commits; continuity uses separately eligible envelopes only after local durability.

<!-- canon-section: determinism -->
Stable causal order, schema adapters, migration plans, compaction rules, projection definitions, and checksums make equivalent history replay-equivalent; timestamps alone never resolve equal-order events.

<!-- canon-section: observability -->
Redacted evidence includes transaction/event/projection cursors, schema IDs, store health, invariant/checksum results, migration/backup/restore phase, retained rollback point, and correlation IDs.

<!-- canon-section: source-ownership -->
Exact target owners are `Core/LocalRuntimeOS/Transactions/`, `EventJournal/`, `State/`, `Projections/`, `Storage/`, and `Repair/`; `Quality/` owns fixtures and replay proof.

<!-- canon-section: tests-proof -->
Test atomic crash points, concurrent conflicts, duplicate commands, schema decoding, every supported upgrade path, unsupported old store, corrupt/tampered records, projection deletion/rebuild equivalence, compaction, tombstones, blob quarantine, low storage, backup/restore interruption, no external reissue, and machine-checkable invariants.

<!-- canon-section: performance-resource-constraints -->
I/O is isolated from the main actor; queues, batches, buffers, retention, compaction, rebuild, migration, and backup work are bounded and cancellable. Article 31 calibration must supply representative event/object/blob scales and device/OS/build/tool/percentile/maximum/energy/memory/storage/regression context; no numeric budget or performance proof is invented here.

## SYSTEM-PERSISTENCE-CORRUPTION-001 — Persistence corruption containment

- **Concept:** `system.persistence.corruption`
- **Modality:** `MUST NOT`
- **Scope:** Persistence corruption containment
- **Status:** `normative`
- **Verification:** `REVIEW-SYSTEM-PERSISTENCE-CORRUPTION-001`
- **Supersedes:** none

Detected persistence corruption MUST produce a redacted diagnosis, quarantine, a safe export or backup opportunity when available, and a repair preview; silent deletion and automatic destructive reset MUST NOT occur.
