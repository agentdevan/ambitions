# UI Decision Proof Contract

Decision ID: `UID-2026-05-15-today-live-current-time-cursor`

## Source Installation Status

Source-installed:

- `Sources/Components/RealityMeridianTemporalPrimitives.swift`
- `Sources/Previews/RealityMeridianTemporalPreviews.swift`
- `Native/Ambitions/Features/Today/TodayScreen.swift`

## Proof Added

- `RealityMeridianCurrentTimeCursor` now renders a proportional 6 AM to 10 PM mini-spine with exact current-time label and minute-level refresh.
- `RealityMeridianScheduledNode` exists as the paired scheduled-node primitive.
- `TodayScreen` uses the current-time cursor above the existing Reality Meridian rail.

## Required Remaining Evidence

- local Swift/Xcode compile proof
- rendered preview or simulator screenshot proof
- accessibility review for exact-time label, Dynamic Type, contrast, and VoiceOver order
- optional future full in-rail fusion if the cursor should be embedded beside scheduled nodes in the existing rail component

## Boundary

This proof contract confirms source files were installed in the repo. It does not claim release readiness or App Store readiness.
