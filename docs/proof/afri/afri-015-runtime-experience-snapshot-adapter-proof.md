# AFRI-015 Runtime Experience Snapshot Adapter Proof

Batch: AMB-367 / AFRI-015
Date: 2026-05-31

## Scope

AFRI-015 adds a runtime adapter that maps real Private Life Runtime context into the deterministic Ambitions OS experience compiler input. The adapter lives below SwiftUI and preserves the runtime as the source of truth for schedule, capacity, recovery, source freshness, proof, receipt, replay, and privacy posture signals.

## Changed Source

- `Native/Ambitions/Runtime/AmbitionsRuntimeExperienceSnapshotAdapter.swift`
- `Native/AmbitionsTests/Runtime/AmbitionsRuntimeExperienceSnapshotAdapterTests.swift`

## Validation

- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-367 --prompt /tmp/AMB-367-AFRI-015-guard-prompt.md`
- `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsTests/AmbitionsRuntimeExperienceSnapshotAdapterTests`

The focused Xcode lane executed 3 tests with 0 failures after repairing a Yellow 0-test run by regenerating the Xcode project and then repairing an enum exhaustiveness compile failure.

## Proof Boundary

Verified:

- Runtime context facts deterministically compile into semantic visual state.
- Unavailable source records cannot present as current source freshness.
- Local-only runtime, sync, and knowledge provider posture produces a positive no-network proof flag.
- SourceRecord, Receipt, and ReplayTrace identifiers remain inspectable in the snapshot summary for You / What Ambitions knows.

Not verified:

- Full app integration wiring into SwiftUI.
- Device, signed archive, TestFlight, App Store, accessibility, or release readiness.
- External package integration for blocked AFRI-012 through AFRI-014 work.
