+++
spec_id = "SYSTEM-PERSISTENCE-REPLAY"
title = "Persistence and Replay"
kind = "system"
status = "normative"
owner_domain = "system-persistence-replay"
canon_revision = 1
profile = "system-v1"
owns_concepts = ["system.persistence.atomicity", "system.persistence.replay"]
inherits = ["RUNTIME-MUTATION-SEQUENCE-001", "LAW-RUNTIME-DURABLE-SUCCESS-001", "RUNTIME-SOURCE-OWNER-001", "LAW-DATA-LOSS-STOP-SHIP-001"]
depends_on = ["CONSTITUTION", "SYSTEM-PRIVATE-LIFE-RUNTIME", "JOURNEY-BACKUP-RESTORE-RESET"]
source_owners = ["Native/Ambitions/Core/LocalRuntimeOS/Transactions/", "Native/Ambitions/Core/LocalRuntimeOS/EventJournal/", "Native/Ambitions/Core/LocalRuntimeOS/State/", "Native/Ambitions/Core/LocalRuntimeOS/Projections/", "Native/Ambitions/Core/LocalRuntimeOS/Storage/", "Native/Ambitions/Core/LocalRuntimeOS/Repair/", "Native/Ambitions/Quality/"]
+++

# Persistence and Replay

This shadow specification defines intended persistence semantics independently of SwiftData, SQLite, files, or another substrate. It does not claim current migration or data-integrity completeness.

## SYSTEM-PERSISTENCE-ATOMIC-001 — Accepted local intent is atomic and crash-consistent

- **Concept:** `system.persistence.atomicity`
- **Modality:** `MUST`
- **Scope:** Canonical Event, object state, projection invalidation, Receipt metadata, tombstone, attachment reference, migration, and external-effect intent
- **Status:** `normative`
- **Verification:** `SCENARIO-SYSTEM-PERSISTENCE-CRASH-001`
- **Supersedes:** none

A declared local transaction MUST durably commit its complete write set or none. Partial durable stages are permitted only when explicitly modeled with a recovery path and truthful Receipt. The last honest store remains readable across interruption, migration, compaction, backup, restore, projection rebuild, and storage pressure.

## SYSTEM-PERSISTENCE-REPLAY-001 — Canonical history replays equivalently

- **Concept:** `system.persistence.replay`
- **Modality:** `MUST`
- **Scope:** Events, object revisions, tombstones, projections, receipts, migrations, and compaction
- **Status:** `normative`
- **Verification:** `SCENARIO-SYSTEM-PERSISTENCE-REPLAY-001`, `AUDIT-SYSTEM-PERSISTENCE-INVARIANTS-001`
- **Supersedes:** none

Historical Event meaning MUST be immutable and version-decodable. Replaying durable history reproduces logically equivalent canonical state and disposable Projections with validated cursors/checksums; ordinary replay does not repeat external effects. Unsupported stores receive explicit recovery/export handling, never silent reset.

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
Exact target owners are `Core/LocalRuntimeOS/Transactions/`, `EventJournal/`, `State/`, `Projections/`, `Storage/`, and `Repair/`; `Quality/` owns fixtures and replay proof. Existing `Core/Persistence/`, incomplete State consumption, app-wide replay, migration horizon, backup/restore, and direct-write debt remain current implementation concerns, not target aliases.

<!-- canon-section: tests-proof -->
Test atomic crash points, concurrent conflicts, duplicate commands, schema decoding, every supported upgrade path, unsupported old store, corrupt/tampered records, projection deletion/rebuild equivalence, compaction, tombstones, blob quarantine, low storage, backup/restore interruption, no external reissue, and machine-checkable invariants.

<!-- canon-section: performance-resource-constraints -->
I/O is isolated from the main actor; queues, batches, buffers, retention, compaction, rebuild, migration, and backup work are bounded and cancellable. Article 31 calibration must supply representative event/object/blob scales and device/OS/build/tool/percentile/maximum/energy/memory/storage/regression context; no numeric budget or performance proof is invented here.
