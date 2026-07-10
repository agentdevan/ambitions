# Article 25 — Persistence and data integrity

## PERSIST-001 — Canonical write authority

No View, presentation model, repository adapter, widget, extension, App Intent, notification callback, import callback, sync callback, or external-service callback may mutate canonical Ambitions state directly.

Every meaningful write routes through:

```text
Command
→ validation and authorization
→ transaction preparation
→ durable event append
→ canonical object-state commit
→ projection invalidation/materialization
→ receipt
→ replayable result
```

Adapters may translate and persist. They do not become mutation authority.

## PERSIST-002 — Atomic local commit

A required local mutation is atomic across the transaction’s declared write set. A transaction commits all required canonical changes, event metadata, projection invalidations, receipt metadata, and external-effect intent—or commits none.

Partial local success is forbidden unless the command explicitly defines a durable staged state and recovery path.

## PERSIST-003 — Crash consistency

Every mutation design must specify restart behavior after interruption:

1. before command-journal append,
2. after command append but before validation result,
3. after event append but before object-state commit,
4. during object-state commit,
5. after canonical commit but before projection materialization,
6. after projection materialization but before receipt finalization,
7. after local commit but before external effect,
8. during compaction,
9. during schema migration,
10. during backup or restore.

Relaunch must not duplicate accepted intent, lose accepted intent, or expose impossible mixed state.

## PERSIST-004 — Stable schema identity

Every persisted canonical object, event, receipt, tombstone, projection cursor, attachment record, migration record, and external-effect record requires:

- stable type identifier,
- schema version,
- logical object identifier,
- creation and modification clock policy,
- provenance where applicable,
- migration compatibility metadata,
- deterministic decoding behavior.

Renaming a Swift type is not permission to change persisted identity.

## PERSIST-005 — Migration safety

Every production schema migration requires:

- source and destination schema IDs,
- supported starting versions,
- preflight and dry run,
- affected-record estimate,
- free-storage estimate,
- pre-migration backup or equivalent rollback protection,
- invariant checks before and after,
- interruption behavior,
- resumability or clean rollback,
- corruption quarantine,
- post-migration receipt and diagnostics,
- fixture coverage for every supported upgrade path.

A migration may not destroy the only readable copy of user data.

## PERSIST-006 — Supported upgrade horizon

The owning persistence specification must define the minimum supported direct-upgrade version and the behavior for older stores. Unsupported historical stores require an explicit export/recovery path; they may not be silently reset.

## PERSIST-007 — Event evolution and replay compatibility

Historical events are immutable in meaning. Event payloads are versioned and decoded through explicit adapters. New code may reinterpret an old event only through a reviewed migration that preserves auditability and replay equivalence.

## PERSIST-008 — Projection disposability

Derived projections are disposable and rebuildable from canonical state/history. Every projection defines:

- input owners,
- cursor or version,
- checksum,
- invalidation triggers,
- rebuild path,
- partial-failure behavior,
- privacy filter,
- scale budget.

Projection loss must not equal user-data loss.

## PERSIST-009 — Machine-checkable store invariants

The store invariant registry must include, at minimum:

- no dangling primary Goal/Step references,
- no Placement referencing a missing canonical object,
- one canonical object per imported source lineage,
- every receipt reference resolves or carries an explicit tombstone,
- every recurrence exception belongs to a valid recurrence series,
- tombstones are causally ordered,
- projection cursors never exceed durable event cursors,
- App Group snapshots contain no unrestricted private graph,
- external-effect records reference a committed local transaction,
- attachment references resolve or are explicitly quarantined,
- no canonical object exists only in a derived projection.

## PERSIST-010 — Backup and restore

Backup and restore specifications define:

- included stores and attachments,
- encryption and key ownership,
- package version,
- checksums and tamper detection,
- selective versus full restore,
- CloudKit interaction,
- conflict and duplicate behavior,
- restore into newer schema,
- restore interruption,
- post-restore invariant validation,
- rollback after failed restore.

## PERSIST-011 — Corruption containment

Detected corruption produces a redacted diagnosis, quarantine, export/backup opportunity when safe, and a repair preview. Silent deletion and automatic destructive reset are forbidden.

## PERSIST-012 — Retention and compaction

The owning design documents define retention and compaction for events, receipts, tombstones, projections, search indexes, ignored external lineages, attachments, backups, and diagnostics.

Compaction must preserve causal meaning, auditability required by product law, replay equivalence, and deletion semantics.

## PERSIST-013 — Attachment vault

Attachments require:

- content-derived identity or equivalent deduplication key,
- checksum verification,
- MIME/type validation,
- size and decompression limits,
- file protection,
- encryption where required,
- quarantine,
- thumbnail policy,
- orphan collection,
- export/sync classification,
- failure-safe draft preservation.

## PERSIST-014 — App Group boundary

Extensions receive minimized, versioned, read-only snapshots or command envelopes. They do not open unrestricted canonical stores or become independent mutation authorities.

## PERSIST-015 — Data-loss stop-ship

Any reproducible path that can silently discard accepted, unsynced, unexported, or unrestorable canonical user data is P0 Red and blocks release.

---
