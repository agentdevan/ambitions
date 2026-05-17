# Design System Gap Report

Decision ID: `UID-2026-05-15-today-live-current-time-cursor`

## Primitive Status

- `RealityMeridianCurrentTimeCursor` in `Sources/Components/RealityMeridianTemporalPrimitives.swift` — source-installed as a proportional current-time cursor
- `RealityMeridianScheduledNode` in `Sources/Components/RealityMeridianTemporalPrimitives.swift` — source-installed
- `RealityMeridianTimeBand` in `Sources/Components/RealityMeridianTimeBand.swift` — source-installed as the richer Start Here / Now / Next / Later visual time instrument
- `RealityMeridianTimeBandZone` in `Sources/Components/RealityMeridianTimeBand.swift` — source-installed
- `TodayMasthead` in `Native/Ambitions/Features/Today/TodayMasthead.swift` — source-installed, not yet active in `TodayScreen`

## App Usage

- `Native/Ambitions/Features/Today/TodayDayRailCurrentTimeFusion.swift` owns the rail-layer time fusion by extending `DayTimelineRail` with `fusedCurrentTimeCursor()`.
- `DayTimelineRail.fusedCurrentTimeCursor()` now renders `RealityMeridianTimeBand()` before the rail content and overlays `RealityMeridianCurrentTimeCursor(presentation: .railOverlay)` on the rail.
- `Native/Ambitions/Features/Today/TodayScreen.swift` still renders `DayTimelineRail(...).fusedCurrentTimeCursor()`.
- The obsolete `TodayRealityMeridianFusedRail.swift` wrapper remains removed from the active path.

## Preview Fixture

- `Sources/Previews/RealityMeridianTemporalPreviews.swift`
- `Sources/Previews/RealityMeridianRichnessPreviews.swift`

## Remaining Proof Needed

- local Swift/Xcode compile proof
- rendered preview or simulator screenshot proof
- accessibility review for exact-time label, Dynamic Type, contrast, and VoiceOver order
- optional safe activation of `TodayMasthead` in `TodayScreen` after local compile feedback

## Boundary

This report records source installation. It does not claim release readiness.
