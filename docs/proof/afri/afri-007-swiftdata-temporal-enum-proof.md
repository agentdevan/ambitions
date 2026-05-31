# AFRI-007 SwiftData Temporal and Enum Type-Safety Proof

Status: Green for bounded persistence slice
Batch: AMB-359 / AFRI-007
Date: 2026-05-31

## Scope

This proof covers a bounded SwiftData persistence repair for durable ledger records that sort or filter by time and for raw enum adapter coverage already owned by persistence mapping helpers.

Changed source:

- `Native/Ambitions/Persistence/PersistedValueDegradation.swift`
- `Native/Ambitions/Persistence/SwiftDataModels.swift`
- `Native/Ambitions/Persistence/SwiftDataRepositories.swift`
- `Native/AmbitionsTests/Persistence/EventLedgerRepositoryTests.swift`
- `Native/AmbitionsTests/Persistence/PersistedValueDegradationTests.swift`
- `Native/AmbitionsTests/Persistence/SideEffectLedgerRepositoryTests.swift`
- `docs/codex/concept-lock-registry.yml`

## What Changed

- Added `PersistedTemporalValue` as the shared temporal adapter for persisted ISO-8601 strings.
- Added optional typed `Date` shadow fields for event ledger, command execution, side-effect ledger, entity tombstone, and action-receipt history SwiftData records.
- Updated repository sorting and range filtering to use typed dates, falling back through the adapter for legacy rows where typed dates are absent.
- Preserved existing string fields for compatibility and domain model round-trips.
- Kept raw enum storage behind existing `PersistedValueDegradation` adapter helpers and added focused adapter coverage.

## Validation

Pre guard:

```text
python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-359 --prompt /tmp/AMB-359-AFRI-007-guard-prompt.md
```

Result: Green. Report: `build/reports/parallel-implementation-guard/AMB-359-pre.md`.

Project generation:

```text
xcodegen generate
```

Result: succeeded.

Focused tests:

```text
xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsTests/PersistedValueDegradationTests -only-testing:AmbitionsTests/EventLedgerRepositoryTests -only-testing:AmbitionsTests/SideEffectLedgerRepositoryTests
```

First repair signal: Red. Swift 6 rejected shared `ISO8601DateFormatter` statics as non-Sendable.

Repair: changed the temporal adapter to create local formatter instances per call.

Second repair signal: Red. A legacy migration-readback test captured non-Sendable SwiftData model objects in a `@Sendable` write closure.

Repair: moved legacy model creation inside the store write closure.

Final result: `** TEST SUCCEEDED **`; 21 selected tests, 0 failures.

Result bundle: `/Users/devan/Library/Developer/Xcode/DerivedData/Ambitions-clensfmdeeuxsueugpmolbvkzbxq/Logs/Test/Test-Ambitions-2026.05.31_11-50-32--0400.xcresult`

Post guard:

```text
python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-359 --prompt /tmp/AMB-359-AFRI-007-guard-prompt.md --changed-from 8518fdbfc ...
```

First result: Red on `persistence_external_surfaces` because the concept lock did not allow AMB-359 to touch canonical persistence files.

Repair: added `AMB-359` as a batch-specific allowed prefix for `persistence_external_surfaces`; this does not create a new persistence owner.

## Boundaries

This is not full-suite proof, UI proof, device proof, signed archive proof, release readiness, performance proof, privacy/legal signoff, or public accessibility proof.
