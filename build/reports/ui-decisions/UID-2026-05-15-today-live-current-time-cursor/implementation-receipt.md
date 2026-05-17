# UI Decision Implementation Receipt

Decision ID: `UID-2026-05-15-today-live-current-time-cursor`

Status: source-installed, validation still required

## Current Source Files

- `Sources/Components/RealityMeridianTemporalPrimitives.swift`
- `Sources/Components/RealityMeridianTimeBand.swift`
- `Sources/Previews/RealityMeridianTemporalPreviews.swift`
- `Sources/Previews/RealityMeridianRichnessPreviews.swift`
- `Native/Ambitions/Features/Today/TodayDayRailCurrentTimeFusion.swift`
- `Native/Ambitions/Features/Today/TodayScreen.swift`
- `Native/Ambitions/Features/Today/TodayMasthead.swift`
- `Native/AmbitionsTests/DesignSystem/RealityMeridianTemporalWindowTests.swift`
- `scripts/ambitions-ui-decision-final-gate.py`

## What Changed

- `RealityMeridianTemporalWindow` owns proportional time-position math for the Reality Meridian cursor.
- `RealityMeridianTimeBand` adds a richer Start Here / Now / Next / Later visual time instrument.
- `DayTimelineRail.fusedCurrentTimeCursor()` now renders `RealityMeridianTimeBand()` before the rail and keeps the rail-overlay current-time cursor.
- `RealityMeridianCurrentTimeCursor` still renders the exact current-time marker with `presentation: .railOverlay` in the rail path.
- `TodayMasthead` was added as source-installed future masthead chrome, but it is not yet active in `TodayScreen`.
- `RealityMeridianRichnessPreviews` was added for the richer time-band and cursor preview.

## Proof Collected

- Source files are installed in the repo.
- Decision file and design-system matrix point to the rail-layer fusion source.
- Final-gate source-shape logic checks the current-time lane.

## Proof Still Required

- local Swift/Xcode compile proof
- local XCTest execution proof
- rendered preview or simulator screenshot proof
- accessibility review for VoiceOver order, contrast, and Dynamic Type behavior
- optional safe activation of `TodayMasthead` once local compile feedback is available

## Boundary

This receipt does not claim release readiness, device proof, hosted CI proof, or App Store readiness.
