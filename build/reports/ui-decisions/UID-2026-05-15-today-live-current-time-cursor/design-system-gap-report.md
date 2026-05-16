# Design System Gap Report

Decision ID: `UID-2026-05-15-today-live-current-time-cursor`

## Primitive Status

- `RealityMeridianCurrentTimeCursor` in `Sources/Components/RealityMeridianTemporalPrimitives.swift` — source-installed as a proportional mini-spine cursor
- `RealityMeridianScheduledNode` in `Sources/Components/RealityMeridianTemporalPrimitives.swift` — source-installed

## App Usage

- `Native/Ambitions/Features/Today/TodayScreen.swift` places `RealityMeridianCurrentTimeCursor()` above the existing Today Reality Meridian rail.
- The cursor primitive now renders a proportional 6 AM to 10 PM vertical mini-spine with an exact current-time label and minute-level TimelineView refresh.

## Preview Fixture

- `Sources/Previews/RealityMeridianTemporalPreviews.swift`

## Remaining Proof Needed

- local Swift/Xcode compile proof
- rendered preview or simulator screenshot proof
- accessibility review for exact-time label, Dynamic Type, contrast, and VoiceOver order
- optional future full in-rail fusion if the current-time cursor should be embedded into the existing rail spine beside scheduled nodes rather than rendered as the mini-spine above it

## Boundary

This report records source installation. It does not claim release readiness.
