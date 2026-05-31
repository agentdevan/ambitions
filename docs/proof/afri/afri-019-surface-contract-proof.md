# AFRI-019 Surface Contract Proof

Batch: AMB-371 / AFRI-019
Date: 2026-05-31

## Scope

AFRI-019 binds the active app tab/navigation owner to the canonical one-primary-object contract for each top-level Ambitions surface.

Canonical mapping:

- Today -> Reality Meridian
- Goals -> Constellation Atlas
- Capture -> Atmosphere Composer
- Time -> LifeShape Field
- You -> User System Profile

The contract preserves runtime inspection requirements for SourceRecord, Receipt, ReplayTrace, and You / What Ambitions knows. It does not create recommendation, planning, source, receipt, replay, or SwiftUI display logic.

## Changed Source

- `Native/Ambitions/App/AppTab.swift`
- `Native/AmbitionsTests/App/AppShellNavigationTests.swift`

## Validation

- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-371 --prompt /tmp/AMB-371-AFRI-019-guard-prompt.md`
- `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsTests/AppShellNavigationTests`

The focused Xcode lane executed 30 tests with 0 failures.

## Proof Boundary

Verified:

- App tab order remains Today, Goals, Capture, Time, You.
- Each active top-level tab has exactly one canonical primary object.
- A competing primary-object assignment fails contract validation.
- Surface contracts retain runtime inspection requirements instead of bypassing SourceRecord, Receipt, ReplayTrace, or You / What Ambitions knows.

Not verified:

- Full visual proof for every surface.
- Device, signed archive, TestFlight, App Store, accessibility, or release readiness.
- Final object-first UI replacement work for AFRI-021 through AFRI-027.
