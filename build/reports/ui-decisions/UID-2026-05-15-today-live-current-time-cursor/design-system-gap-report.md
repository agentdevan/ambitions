# Design System Gap Report

Decision ID: `UID-2026-05-15-today-live-current-time-cursor`

## Primitive Status

- `RealityMeridianCurrentTimeCursor` in `Sources/Components/RealityMeridianTemporalPrimitives.swift` — source-installed as a proportional mini-spine cursor
- `RealityMeridianScheduledNode` in `Sources/Components/RealityMeridianTemporalPrimitives.swift` — source-installed

## App Usage

- `Native/Ambitions/Features/Today/TodayRealityMeridianFusedRail.swift` now owns the rail/cursor fusion.
- `TodayRealityMeridianFusedRail` wraps `DayTimelineRail` and overlays `RealityMeridianCurrentTimeCursor()` at the rail layer.
- `Native/Ambitions/Features/Today/TodayScreen.swift` now delegates to `TodayRealityMeridianFusedRail` instead of owning the cursor overlay inline.
- The cursor primitive renders a proportional 6 AM to 10 PM vertical mini-spine with an exact current-time label and minute-level TimelineView refresh.
- The fused rail composition is identified as `TodayRealityMeridianFusedRail`; the cursor remains identified as `TodayRealityMeridianCurrentTimeCursor`.

## Preview Fixture

- `Sources/Previews/RealityMeridianTemporalPreviews.swift`

## Remaining Proof Needed

- local Swift/Xcode compile proof
- rendered preview or simulator screenshot proof
- accessibility review for exact-time label, Dynamic Type, contrast, and VoiceOver order
- optional future deep fusion into `TodayDayRailPanels.swift` if the cursor should share the exact same internal node/spine layout code as scheduled row nodes

## Boundary

This report records source installation. It does not claim release readiness.
