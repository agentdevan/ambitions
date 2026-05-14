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

No CloudKit sync is implemented in this batch.

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
10. No external backend, no hosted user-data server, and no external LLM/cloud intelligence dependency.

## Gate Rule

CloudKit work is not allowed to proceed unless the future patch includes explicit owner approval, matching source-truth updates, and fresh local/device proof for the planned sync behavior.
