# Design System Gap Report

Decision ID: `UID-2026-05-15-today-live-current-time-cursor`

## Primitive Status

- `RealityMeridianCurrentTimeCursor` in `Sources/Components/RealityMeridianTemporalPrimitives.swift` — source-installed as a proportional mini-spine cursor
- `RealityMeridianScheduledNode` in `Sources/Components/RealityMeridianTemporalPrimitives.swift` — source-installed

## App Usage

- `Native/Ambitions/Features/Today/TodayDayRailCurrentTimeFusion.swift` now owns the rail-layer cursor fusion by extending `DayTimelineRail` with `fusedCurrentTimeCursor()`.
- `Native/Ambitions/Features/Today/TodayScreen.swift` renders `DayTimelineRail(...).fusedCurrentTimeCursor()` instead of owning an inline overlay or delegating through a separate wrapper component.
- The obsolete `TodayRealityMeridianFusedRail.swift` wrapper was removed from the active path.
- The cursor primitive renders a proportional 6 AM to 10 PM vertical mini-spine with an exact current-time label and minute-level TimelineView refresh.
- The fused rail composition is identified as `TodayRealityMeridianFusedRail`; the cursor remains identified as `TodayRealityMeridianCurrentTimeCursor`.

## Preview Fixture

- `Sources/Previews/RealityMeridianTemporalPreviews.swift`

## Remaining Proof Needed

- local Swift/Xcode compile proof
- rendered preview or simulator screenshot proof
- accessibility review for exact-time label, Dynamic Type, contrast, and VoiceOver order
- optional future direct edit inside `TodayDayRailPanels.swift` if the cursor should be physically authored in the same source file as Start Here, Now/Next/Later, and continuity

## Boundary

This report records source installation. It does not claim release readiness.
