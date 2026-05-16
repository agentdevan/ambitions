# UI Decision Implementation Receipt

Decision ID: `UID-2026-05-15-today-live-current-time-cursor`

Status: source-installed, validation still required

## Current Source Files

- `Sources/Components/RealityMeridianTemporalPrimitives.swift`
- `Sources/Previews/RealityMeridianTemporalPreviews.swift`
- `Native/Ambitions/Features/Today/TodayDayRailCurrentTimeFusion.swift`
- `Native/Ambitions/Features/Today/TodayScreen.swift`

## What Changed

- `RealityMeridianCurrentTimeCursor` renders a proportional 6 AM to 10 PM mini-spine with exact current-time label and minute refresh.
- `RealityMeridianScheduledNode` remains the paired scheduled-node primitive.
- `DayTimelineRail.fusedCurrentTimeCursor()` now owns the current-time fusion at the rail layer.
- `TodayScreen` renders `DayTimelineRail(...).fusedCurrentTimeCursor()`.
- The older wrapper file `TodayRealityMeridianFusedRail.swift` is no longer active.

## Proof Collected

- Source files are installed in the repo.
- Decision file and design-system matrix point to the rail-layer fusion source.
- Gap report and proof contract were updated for the `DayTimelineRail.fusedCurrentTimeCursor()` path.

## Proof Still Required

- local Swift/Xcode compile proof
- rendered preview or simulator screenshot proof
- accessibility review for VoiceOver order, contrast, and Dynamic Type behavior

## Boundary

This receipt does not claim release readiness, device proof, hosted CI proof, or App Store readiness.
