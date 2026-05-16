# Design System Gap Report

Decision ID: `UID-2026-05-15-today-live-current-time-cursor`

## Primitive Status

- `RealityMeridianCurrentTimeCursor` in `Sources/Components/RealityMeridianTemporalPrimitives.swift` — source-installed
- `RealityMeridianScheduledNode` in `Sources/Components/RealityMeridianTemporalPrimitives.swift` — source-installed

## App Usage

- `Native/Ambitions/Features/Today/TodayScreen.swift` now places `RealityMeridianCurrentTimeCursor()` above the existing Today Reality Meridian rail as a safe first-pass current-time object.

## Preview Fixture

- `Sources/Previews/RealityMeridianTemporalPreviews.swift`

## Remaining Proof Needed

- local Swift/Xcode compile proof
- rendered preview or simulator screenshot proof
- accessibility review for exact-time label, Dynamic Type, and VoiceOver order
- future rail-spine integration if the cursor needs to align to a proportional vertical day spine instead of the current safe first-pass placement

## Boundary

This report records source installation. It does not claim release readiness.
