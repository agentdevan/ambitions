# AFEP-008 Replay and Provenance Artifact Packet

## Purpose

Document the deterministic Reality Meridian continuity projection added in this batch and the replay/provenance seams it preserves.

## Source Changes

- `Native/Ambitions/Features/Today/DayRailViewState.swift`
- `Native/Ambitions/Features/Today/TodayExecutionViewState.swift`
- `Native/Ambitions/Features/Today/TodayExecutionProjector.swift`
- `Native/Ambitions/Features/Today/TodayExecutionCompatibility.swift`
- `Native/AmbitionsTests/Today/TodayViewModelTests.swift`
- `Native/AmbitionsTests/Today/TodayDerivedReadModelCacheTests.swift`

## Added Projection State

- `RealityMeridianContinuityProjectionState`
- The projection keeps the primary Today object rooted in Reality Meridian.
- The projection records recommendation, time reality, capacity/fit, source freshness, proof, provenance, recovery, and continuation/restoration identity in one value model.

## Preserved Inspection Seams

- `SourceRecord`
- `Receipt`
- `ReplayTrace`
- `You / What Ambitions knows`

## Accessibility Safety Fields

- Reduced motion summary
- Differentiate-without-color summary
- Dynamic Type summary
- VoiceOver order list

## Proof Notes

- The replay/provenance seams are wired through the existing DayRail and Today execution state rather than a new engine.
- The state remains deterministic from named inputs and is reused by the cached read-model path.
