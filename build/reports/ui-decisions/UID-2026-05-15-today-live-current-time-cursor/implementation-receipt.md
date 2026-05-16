# UI Decision Implementation Receipt

Decision ID: `UID-2026-05-15-today-live-current-time-cursor`

Status: source-installed, validation still required

## Changed Source Files

- `Sources/Components/RealityMeridianTemporalPrimitives.swift`
- `Sources/Previews/RealityMeridianTemporalPreviews.swift`
- `Native/Ambitions/Features/Today/TodayRealityMeridianFusedRail.swift`
- `Native/Ambitions/Features/Today/TodayScreen.swift`

## What Changed

- Added `RealityMeridianCurrentTimeCursor` as a reusable AmbitionsDesignSystem primitive for exact current-time display.
- Upgraded `RealityMeridianCurrentTimeCursor` to render a proportional 6 AM to 10 PM vertical mini-spine with an exact current-time label and minute-level refresh.
- Added `RealityMeridianScheduledNode` as the paired reusable AmbitionsDesignSystem primitive for scheduled node display.
- Added a design-system preview fixture for the temporal primitives.
- Added `TodayRealityMeridianFusedRail`, a Today feature component that wraps `DayTimelineRail` and owns the cursor overlay.
- Simplified `TodayScreen` so it delegates to `TodayRealityMeridianFusedRail` instead of owning the cursor overlay inline.

## Proof Collected

- Source files are installed in the repo.
- Decision file and design-system matrix now mark the primitives and fused rail source as active source candidates.
- Gap report and proof contract were updated to reflect the rail-owned fused component.
- Today exposes `TodayRealityMeridianFusedRail` and `TodayRealityMeridianCurrentTimeCursor` identifiers.

## Proof Still Required

- local Swift/Xcode compile proof
- rendered preview or simulator screenshot proof
- accessibility review for VoiceOver order, contrast, and Dynamic Type behavior
- optional future deep fusion into `TodayDayRailPanels.swift` if the cursor should share the exact same internal node/spine layout code as scheduled row nodes

## Boundary

This receipt does not claim release readiness, device proof, hosted CI proof, or App Store readiness.
