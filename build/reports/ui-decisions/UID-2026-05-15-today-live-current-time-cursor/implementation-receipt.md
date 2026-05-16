# UI Decision Implementation Receipt

Decision ID: `UID-2026-05-15-today-live-current-time-cursor`

Status: source-installed, validation still required

## Changed Source Files

- `Sources/Components/RealityMeridianTemporalPrimitives.swift`
- `Sources/Previews/RealityMeridianTemporalPreviews.swift`
- `Native/Ambitions/Features/Today/TodayScreen.swift`

## What Changed

- Added `RealityMeridianCurrentTimeCursor` as a reusable AmbitionsDesignSystem primitive for exact current-time display.
- Added `RealityMeridianScheduledNode` as a reusable AmbitionsDesignSystem primitive for scheduled node display.
- Added a design-system preview fixture for the temporal primitives.
- Placed `RealityMeridianCurrentTimeCursor()` above the existing Today Reality Meridian rail as a safe first-pass app integration.

## Proof Collected

- Source files are installed in the repo.
- Decision file and design-system matrix now mark the primitives as existing.
- Gap report and proof contract were updated to reflect source installation.

## Proof Still Required

- local Swift/Xcode compile proof
- rendered preview or simulator screenshot proof
- accessibility review for VoiceOver order, contrast, and Dynamic Type behavior
- future proportional rail-spine integration if exact minute-of-day placement is required inside the vertical rail itself

## Boundary

This receipt does not claim release readiness, device proof, hosted CI proof, or App Store readiness.
