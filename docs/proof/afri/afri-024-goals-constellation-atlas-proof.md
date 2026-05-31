# AFRI-024 Goals Constellation Atlas Proof

Status: Green, local simulator proof only
Issue: AMB-376 / AFRI-024
Date: 2026-05-31

## Scope

AFRI-024 strengthens the existing Goals surface around the active Constellation Atlas product object. The patch does not add a new top-level destination, redesign the Goals screen, or introduce cloud, analytics, telemetry, or hosted intelligence.

The scoped implementation adds an inspectable local basis line to the Goals primary object so the atlas explains what it knows from SourceRecord inputs, what proof or closure receipts exist, how the current lane placement can be replayed, and how Orbital Lens keeps one goal thread connected to Today.

## Source Changes

- `Native/Ambitions/Features/Goals/GoalsFeatureModels.swift`
  - Adds derived Constellation Atlas inspection summaries to `GoalsOverview`.
  - Keeps the summary local-source based and computed from existing Goals, draft, evidence, capture, Life Area, proof, receipt, and lane state.
- `Native/Ambitions/Features/Goals/GoalComponents.swift`
  - Surfaces the inspection summary inside the existing Goals primary object.
  - Adds a stable accessibility identifier for the inspection line.
  - Includes the inspection basis in the combined VoiceOver label.
- `Native/AmbitionsTests/Goals/GoalsOverviewBoardTests.swift`
  - Adds AFRI-024 coverage proving the summary exposes SourceRecord, Receipt, ReplayTrace, and You / What Ambitions knows labels while preserving milestone, proof, current-step, Today connection, and no-dashboard/no-score/no-streak boundaries.

## Proof

Verified locally:

- Pre implementation guard:
  - `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-376 --prompt /tmp/AMB-376-AFRI-024-guard-prompt.md`
  - Result: Green after repairing the prompt to remove old-term trigger words before implementation.
- Focused AFRI-024 Goals overview test:
  - `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsTests/GoalsOverviewAtlasTests/testAFRI024GoalsConstellationAtlasExposesInspectableLocalSourceReceiptAndReplayBasis`
  - Result: Red on the first run because the test expected a milestone title while the existing card contract reports milestone visibility counts; repaired to the existing contract, then Green, 1 test, 0 failures.
- Goals overview atlas lane:
  - `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsTests/GoalsOverviewAtlasTests`
  - Result: Green, 13 tests, 0 failures.
- Focused post-repair AFRI-024 test:
  - `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsTests/GoalsOverviewAtlasTests/testAFRI024GoalsConstellationAtlasExposesInspectableLocalSourceReceiptAndReplayBasis`
  - Result: Green, 1 test, 0 failures.
- Goals preview UI smoke:
  - `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsUITests/AmbitionsUITests/testPreviewBootstrapShowsEmptyGoalsState`
  - Result: Green, 1 test, 0 failures.
- Demo Goals deep module UI smoke:
  - `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsUITests/AmbitionsUITests/testDemoGoalsAtlasLoadsCoreModules`
  - Result: Yellow/blocked after two runs. The app reached `goals.screen` and `goals.mission-control-lanes`, then the simulator timed out while evaluating off-screen accessibility queries for the existing `Direction depth` disclosure after scrolling. A helper repair attempt to query `goals.direction-depth` did not clear the simulator timeout and was not kept.
- Post implementation guard:
  - `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-376 --prompt /tmp/AMB-376-AFRI-024-guard-prompt.md --changed-from HEAD --changed-path Native/Ambitions/Features/Goals/GoalsFeatureModels.swift --changed-path Native/Ambitions/Features/Goals/GoalComponents.swift --changed-path Native/AmbitionsTests/Goals/GoalsOverviewBoardTests.swift --changed-path docs/proof/afri/afri-024-goals-constellation-atlas-proof.md`
  - Result: Green.

## Boundaries

- This is local source, unit, and simulator proof only after validation completes.
- This does not claim device, signed archive, TestFlight, App Store, release, legal, privacy-review, accessibility audit, or CI proof.
- No new top-level IA, cloud AI, hosted backend, analytics, telemetry, or network dependency was added.
