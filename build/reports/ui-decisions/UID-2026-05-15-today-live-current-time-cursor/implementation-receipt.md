# UI Decision Implementation Receipt

Decision ID: `UID-2026-05-15-today-live-current-time-cursor`

Status: source-installed, validation still required

## Changed Source Files

- `Sources/Components/RealityMeridianTemporalPrimitives.swift`
- `Sources/Previews/RealityMeridianTemporalPreviews.swift`
- `Native/Ambitions/Features/Today/TodayScreen.swift`

## What Changed

- Added `RealityMeridianCurrentTimeCursor` as a reusable AmbitionsDesignSystem primitive for exact current-time display.
- Upgraded `RealityMeridianCurrentTimeCursor` to render a proportional 6 AM to 10 PM vertical mini-spine with an exact current-time label and minute-level refresh.
- Added `RealityMeridianScheduledNode` as the paired reusable AmbitionsDesignSystem primitive for scheduled node display.
- Added a design-system preview fixture for the temporal primitives.
- Placed `RealityMeridianCurrentTimeCursor()` above the existing Today Reality Meridian rail as the first app-level integration.

## Proof Collected

- Source files are installed in the repo.
- Decision file and design-system matrix now mark the primitives as existing.
- Gap report and proof contract were updated to reflect the proportional mini-spine source installation.

## Proof Still Required

- local Swift/Xcode compile proof
- rendered preview or simulator screenshot proof
- accessibility review for VoiceOver order, contrast, and Dynamic Type behavior
- optional future full in-rail fusion if the current-time cursor should be embedded beside scheduled nodes in the existing rail component

## Boundary

This receipt does not claim release readiness, device proof, hosted CI proof, or App Store readiness.
