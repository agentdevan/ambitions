# Batch 32 — Ambitions 2.0 Batch 13 / Explainability and Source Audit Surfaces

## Status

Completed

## Goal

Build the first user-facing explainability and source-audit layer for Ambitions 2.0 by surfacing why-this, source audit, freshness, confidence, contradiction summaries, and bounded correction controls from the existing canonical understanding/path/resource/freshness/energy/contradiction/teaching stack.

This batch stayed narrow. It did not add new engine inference, ranking, contradiction, or freshness logic, and it did not broaden explainability across the shell.

## What Landed

- added a read-only canonical projector in `Native/Ambitions/Services/GoalExplainabilityProjector.swift`
- kept explainability mapping deterministic and metadata-backed by projecting:
  - `GoalOrchestrationMetadata.understanding`
  - `GoalOrchestrationMetadata.compiledPath`
  - `GoalOrchestrationMetadata.resourceGraph`
  - `GoalOrchestrationMetadata.energyModel`
  - `GoalOrchestrationMetadata.contradictionReport`
  - `GoalTeachingApplicableSet`
- added additive explainability/read-model types in `Native/Ambitions/Features/Goals/GoalsFeatureModels.swift`
- extended `GoalDetailPresentation` with additive explainability state only
- added Goal Detail explainability sections in `Native/Ambitions/Features/Goals/GoalDetailScreen.swift` for:
  - why this
  - source audit
  - freshness
  - confidence
  - contradiction summaries
  - bounded correction controls
- kept Goal Detail as the only full explainability and source-audit surface in this batch
- reused the same projector in `Native/Ambitions/Features/Today/TodayFeatureService.swift` only for compact why-this inline copy when draft metadata exists
- added explicit explainability correction submission in the goals service seam and routed writes through `DefaultGoalTeachingSignalService`
- kept correction controls strictly artifact-anchored to visible canonical artifacts:
  - resource-hook relevance corrections
  - contradiction disposition corrections
  - energy-fit lighter-version corrections
- added read-only applied teaching badges from the canonical teaching read path
- updated wrapper services to preserve existing notification/snapshot refresh behavior after explicit correction writes
- added focused tests covering projector output, explainability correction writes, and Today compact why-this reuse

## What Did Not Land

- no new engine inference or explanation generation
- no new ranking logic
- no new contradiction logic or resolution workflow
- no new freshness logic
- no shell-wide explainability badges or dashboard expansion
- no goal-list explainability cards
- no Insights explainability expansion
- no runtime-wide Batch 33 integration
- no broad Goal Detail redesign
- no silent application of teaching signals to planning or ranking behavior in this batch

## Validation That Actually Ran

- `xcodegen generate`
  - passed
- native app build:
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -sdk iphonesimulator -destination "generic/platform=iOS Simulator" CODE_SIGNING_ALLOWED=NO build`
  - passed
- targeted explainability/correction validation:
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,id=8ACCD665-4807-4102-B526-5A1AE20686A8" -only-testing:AmbitionsTests/GoalExplainabilityProjectionTests -only-testing:AmbitionsTests/GoalDetailExplainabilityActionTests -only-testing:AmbitionsTests/TodayFreshGoalVisibilityTests test`
  - passed
- targeted canonical teaching validation:
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,id=8ACCD665-4807-4102-B526-5A1AE20686A8" -only-testing:AmbitionsTests/GoalTeachingSignalServiceTests test`
  - passed
- authoritative native unit validation:
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,id=8ACCD665-4807-4102-B526-5A1AE20686A8" -only-testing:AmbitionsTests test`
  - passed
  - result: 316 tests, 0 failures

## Completion Notes

- Goal Detail is the only full explainability and source-audit host in Batch 32.
- Explainability surfaces are powered by canonical metadata through a read-only projector rather than view-local business logic.
- Correction controls remain bounded to visible anchored artifacts and write through the canonical Batch 31 teaching service.
- Today only reuses the projector for compact why-this copy and continues to hand off into Goal Detail for the full audit surface.
- Insights remains unchanged.
- The checked-out branch remained `main` during implementation, validation, and wrap-up.

## Next Active Batch

Batch 33 — Ambitions 2.0 Batch 14 / Intelligence runtime integration
