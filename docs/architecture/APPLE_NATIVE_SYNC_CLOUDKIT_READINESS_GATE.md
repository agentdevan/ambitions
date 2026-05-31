# Apple Native Sync CloudKit Readiness Gate

Status: Active decision gate
Scope: Future optional Apple-native sync only
Applies to: Ambitions native iPhone app and local persistence posture

This document is a gate, not an implementation. It records the current sync posture and the minimum proof required before any future CloudKit-backed sync proposal is allowed to move forward.

## Current Runtime Posture

Ambitions is currently local-only.

Current source evidence:

- [`Native/Ambitions/Persistence/SyncCapabilityContracts.swift`](../../Native/Ambitions/Persistence/SyncCapabilityContracts.swift)
- [`Native/AmbitionsTests/Persistence/SyncCapabilityTests.swift`](../../Native/AmbitionsTests/Persistence/SyncCapabilityTests.swift)

The current runtime contract is explicit:

- backend kind: local-only
- trust posture: local-only
- availability: unavailable
- detail: Ambitions is running in explicit local-only mode

This batch implements no CloudKit-backed syncing.

## Current Non-Claims

This gate does not claim:

- iCloud entitlement setup
- CloudKit container setup
- cross-device sync behavior
- account/iCloud sign-in UX
- conflict resolution
- tombstone strategy
- export-before-sync behavior
- rollback behavior for sync migrations
- device/iCloud proof
- privacy approval
- production readiness

## Required Future Prerequisites

If CloudKit becomes an approved future path, it must be gated by all of the following before implementation is considered:

1. iCloud entitlement and CloudKit container setup.
2. SwiftData and CloudKit model-compatibility review.
3. Optional account and iCloud state UX.
4. Offline-first behavior with no hidden backend dependency.
5. Conflict, merge, and tombstone strategy.
6. Migration, backup, restore, and rollback proof.
7. Export-before-sync posture.
8. Privacy copy and user-control language.
9. Device and iCloud proof on the supported platforms.
10. No external backend, no hosted user-data server, and no hosted-model/cloud intelligence dependency.

## AFRI-030 Decision Gate Addendum

AMB-382 / AFRI-030 keeps this gate implementation-blocking. The formal ADR is
[`ADR-010 Optional CloudKit Continuity Decision Gate`](../adr/ADR-010-optional-cloudkit-continuity-decision-gate.md).

### Schema Decision Material

Future CloudKit continuity must start from
[`Ambitions_CloudKit_Schema_Zone_Conflict_Model.md`](../canon/Ambitions_CloudKit_Schema_Zone_Conflict_Model.md)
and re-confirm the following before any entitlement, container, schema, or sync runtime work:

- one private custom zone for launch continuity unless a migration-reviewed split is approved
- record family ownership for goals, steps, captures, proof, receipts, memory signals, preferences, tombstones, and sync ledger metadata
- field classification as portable, sensitive, localOnly, derived, or receipt
- tombstone retention, delete-all-memory interaction, export/import compatibility, and rollback behavior
- SourceRecord, Receipt, ReplayTrace, and You / What Ambitions Knows inspection boundaries

### Conflict Model

Future sync must be review-first:

- no silent destructive overwrite
- no silent goal, plan, memory, proof, receipt, or commitment mutation
- local unsynced writes remain durable through account, network, and CloudKit failures
- deletion/correction tombstones prevent resurrection
- ambiguous conflicts create review receipts and keep both sides available until the user chooses

### Opt-In UX And Off Switch

Future UI must expose these states before user-facing sync copy is allowed:

- local-only unavailable
- not signed into iCloud
- iCloud restricted
- network unavailable
- sync paused by user
- sync needs review
- sync healthy only after implementation proof exists

Enablement must be user-initiated. Disabling must preserve local writes and provide export, conflict-review, migration, and rollback guidance.

### Privacy Copy

Current allowed copy:

```text
Ambitions is local-first in this build.
Sync is unavailable in the current local-only runtime.
Apple-native sync is an allowed future option only if privacy and migration proof are approved.
```

Current forbidden copy concepts:

```text
Any claim that iCloud continuity already works.
Any claim that CloudKit-backed syncing already exists.
Any claim that user data already moves across devices.
```

Future privacy copy must describe private iCloud behavior, data classes, off switch, export/import, deletion, conflict review, account-unavailable behavior, and what remains local-only.

### Proof Tests

Future implementation cannot proceed until a proof plan covers:

- local-only capability when CloudKit is absent
- account unavailable does not block local app use
- idempotent zone creation and subscription setup
- record encoding/decoding for every approved record family
- tombstones prevent deleted records from resurrecting
- conflicts create review receipts
- memory deletion/correction wins over stale remote state
- export/import compatibility with synced records
- private content absence in logs, notifications, widgets, Live Activities, App Intents, and reports
- enable, pause, disable, migration, rollback, and restore proof

## Gate Rule

CloudKit work is not allowed to proceed unless the future patch includes explicit owner approval, matching source-truth updates, and fresh local/device proof for the planned sync behavior.

AMB-382 adds no entitlement, container, signing, account UI, sync runtime, production schema, persistence migration, dependency, backend, server, or network path.
