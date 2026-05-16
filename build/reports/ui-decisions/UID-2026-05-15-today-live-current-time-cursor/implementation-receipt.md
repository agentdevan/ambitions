# UI Decision Implementation Receipt

Decision ID: `UID-2026-05-15-today-live-current-time-cursor`

Status: source-installed, validation still required

## Current Source Files

- `Sources/Components/RealityMeridianTemporalPrimitives.swift`
- `Sources/Previews/RealityMeridianTemporalPreviews.swift`
- `Native/Ambitions/Features/Today/TodayDayRailCurrentTimeFusion.swift`
- `Native/Ambitions/Features/Today/TodayScreen.swift`
- `Native/AmbitionsTests/DesignSystem/RealityMeridianTemporalWindowTests.swift`
- `scripts/ambitions-ui-decision-final-gate.py`

## What Changed

- `RealityMeridianTemporalWindow` now owns proportional time-position math for the Reality Meridian cursor.
- `RealityMeridianCurrentTimeCursor` uses that model to render a proportional 6 AM to 10 PM mini-spine with exact current-time label and minute refresh.
- `RealityMeridianScheduledNode` remains the paired scheduled-node primitive.
- `DayTimelineRail.fusedCurrentTimeCursor()` owns the current-time fusion at the rail layer.
- `TodayScreen` renders `DayTimelineRail(...).fusedCurrentTimeCursor()`.
- `RealityMeridianTemporalWindowTests` covers start, middle, end, clamping, exact-minute position, invalid-window normalization, and calendar-driven date progress.
- The UI decision final gate now checks the current-time cursor lane for the rail-layer fusion file, absent obsolete wrapper, non-blocking hit testing, Today usage, and temporal tests.

## Proof Collected

- Source files are installed in the repo.
- Decision file and design-system matrix point to the rail-layer fusion source.
- Gap report and proof contract were updated for the `DayTimelineRail.fusedCurrentTimeCursor()` path.
- Source-shape gate logic was tightened for this lane.

## Proof Still Required

- local Swift/Xcode compile proof
- local XCTest execution proof
- rendered preview or simulator screenshot proof
- accessibility review for VoiceOver order, contrast, and Dynamic Type behavior

## Boundary

This receipt does not claim release readiness, device proof, hosted CI proof, or App Store readiness.
