# UI Decision Proof Contract

Decision ID: `UID-2026-05-15-today-live-current-time-cursor`

## Source Installation Status

Source-installed:

- `Sources/Components/RealityMeridianTemporalPrimitives.swift`
- `Sources/Previews/RealityMeridianTemporalPreviews.swift`
- `Native/Ambitions/Features/Today/TodayDayRailCurrentTimeFusion.swift`
- `Native/Ambitions/Features/Today/TodayScreen.swift`

## Proof Added

- `RealityMeridianCurrentTimeCursor` renders a proportional 6 AM to 10 PM mini-spine with exact current-time label and minute-level refresh.
- `RealityMeridianScheduledNode` exists as the paired scheduled-node primitive.
- `TodayDayRailCurrentTimeFusion.swift` extends `DayTimelineRail` with `fusedCurrentTimeCursor()`, so the fusion is owned by the rail layer instead of `TodayScreen`.
- `TodayScreen` renders `DayTimelineRail(...).fusedCurrentTimeCursor()`.
- The obsolete `TodayRealityMeridianFusedRail.swift` wrapper was removed from the active path.
- The fused composition exposes `TodayRealityMeridianFusedRail` and `TodayRealityMeridianCurrentTimeCursor` identifiers.

## Required Remaining Evidence

- local Swift/Xcode compile proof
- rendered preview or simulator screenshot proof
- accessibility review for exact-time label, Dynamic Type, contrast, and VoiceOver order
- optional future direct edit inside `TodayDayRailPanels.swift` if the cursor must be physically authored in the same source file as Start Here, Now/Next/Later, and continuity

## Boundary

This proof contract confirms source files were installed in the repo. It does not claim release readiness or App Store readiness.
