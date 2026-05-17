# UI Decision Proof Contract

Decision ID: `UID-2026-05-15-today-live-current-time-cursor`

## Source Installation Status

Source-installed:

- `Sources/Components/RealityMeridianTemporalPrimitives.swift`
- `Sources/Components/RealityMeridianTimeBand.swift`
- `Sources/Previews/RealityMeridianTemporalPreviews.swift`
- `Sources/Previews/RealityMeridianRichnessPreviews.swift`
- `Native/Ambitions/Features/Today/TodayDayRailCurrentTimeFusion.swift`
- `Native/Ambitions/Features/Today/TodayScreen.swift`
- `Native/Ambitions/Features/Today/TodayMasthead.swift`
- `Native/AmbitionsTests/DesignSystem/RealityMeridianTemporalWindowTests.swift`
- `scripts/ambitions-ui-decision-final-gate.py`

## Proof Added

- `RealityMeridianTimeBand` is source-installed as the richer Start Here / Now / Next / Later visual time instrument.
- `DayTimelineRail.fusedCurrentTimeCursor()` renders `RealityMeridianTimeBand()` before the rail content.
- The rail path still overlays `RealityMeridianCurrentTimeCursor(presentation: .railOverlay)` without blocking taps.
- `TodayMasthead` is source-installed for future masthead chrome, but is not yet active in `TodayScreen`.
- Existing temporal tests remain installed.
- The UI decision final gate checks this lane for source-shape drift.

## Required Remaining Evidence

- local Swift/Xcode compile proof
- local XCTest execution proof
- rendered preview or simulator screenshot proof
- accessibility review for exact-time label, Dynamic Type, contrast, and VoiceOver order
- optional safe activation of `TodayMasthead` in `TodayScreen` after local compile feedback

## Boundary

This proof contract confirms source files were installed in the repo. It does not claim release readiness or App Store readiness.
