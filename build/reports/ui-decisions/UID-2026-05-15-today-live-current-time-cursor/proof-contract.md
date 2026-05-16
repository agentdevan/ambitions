# UI Decision Proof Contract

Decision ID: `UID-2026-05-15-today-live-current-time-cursor`

## Source Installation Status

Source-installed:

- `Sources/Components/RealityMeridianTemporalPrimitives.swift`
- `Sources/Previews/RealityMeridianTemporalPreviews.swift`
- `Native/Ambitions/Features/Today/TodayDayRailCurrentTimeFusion.swift`
- `Native/Ambitions/Features/Today/TodayScreen.swift`
- `Native/AmbitionsTests/DesignSystem/RealityMeridianTemporalWindowTests.swift`
- `scripts/ambitions-ui-decision-final-gate.py`

## Proof Added

- `RealityMeridianTemporalWindow` owns the proportional time-position model.
- `RealityMeridianCurrentTimeCursor` renders a proportional 6 AM to 10 PM mini-spine with exact current-time label and minute-level refresh.
- `RealityMeridianScheduledNode` exists as the paired scheduled-node primitive.
- `TodayDayRailCurrentTimeFusion.swift` extends `DayTimelineRail` with `fusedCurrentTimeCursor()`, so the fusion is owned by the rail layer instead of `TodayScreen`.
- `TodayScreen` renders `DayTimelineRail(...).fusedCurrentTimeCursor()`.
- The obsolete `TodayRealityMeridianFusedRail.swift` wrapper was removed from the active path.
- `RealityMeridianTemporalWindowTests` covers start, middle, end, clamping, exact-minute position, invalid-window normalization, and calendar-driven date progress.
- The UI decision final gate now checks the current-time lane for the rail-layer fusion file, absent obsolete wrapper, non-blocking hit testing, Today usage, and temporal tests.

## Required Remaining Evidence

- local Swift/Xcode compile proof
- local XCTest execution proof
- rendered preview or simulator screenshot proof
- accessibility review for exact-time label, Dynamic Type, contrast, and VoiceOver order

## Boundary

This proof contract confirms source files were installed in the repo. It does not claim release readiness or App Store readiness.