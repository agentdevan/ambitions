# Batch 30 — Ambitions 2.0 Batch 11 / Contradiction Engine

## Status

Completed

## Goal

Add the first canonical contradiction engine on top of the Batch 20-29 intelligence stack so Ambitions can detect structural conflicts between goals, observed behavior, retrieved requirements, compiled plans, and system assumptions in a deterministic, typed, reusable way.

This batch stayed narrow. It did not change planning, ranking, blocking, recommendation math, correction capture, teaching persistence, explainability surfaces, source-audit UI, or product-shell behavior.

## What Landed

- added canonical contradiction contracts in `Native/Ambitions/Domain/GoalEngine/GoalContradictionModels.swift`
- added `goalContradictionSchemaVersion` as `goal_contradiction.native.v1`
- added stable typed contradiction codes, categories, severities, and typed artifact references so logic and tests rely on structured identity rather than prose
- added a reusable contradiction analyzer service in `Native/Ambitions/Services/GoalContradictionService.swift`
- added a compact deterministic `contradictionReport` to `GoalOrchestrationMetadata`
- kept contradiction derivation in the canonical goal-engine seam:
  - clarification
  - understanding
  - compiled path
  - resource graph
  - energy model
  - explicit evidence and feedback when provided at the orchestration seam
- bridged existing `GoalInputContradiction` values into the canonical report without changing Batch 22 meanings or blocking behavior
- kept requirement/resource contradiction detection structural and conservative:
  - required or readiness-critical artifacts only
  - no optional hint contradiction records
  - no contradiction from uncertainty alone
- kept behavior contradiction detection local and compatibility-safe:
  - same goal + same step first
  - conservative same-goal fallback only where the existing typed seams allow it
  - no cross-goal contradiction inference
- kept output deterministic with typed de-duplication and stable ordering
- preserved backward-compatible metadata decode defaults for older stored orchestration metadata
- required no SwiftData schema migration because contradiction metadata stays inside existing encoded metadata snapshots

## What Did Not Land

- no ranking or blocking behavior changes from contradiction metadata
- no planner selection changes
- no correction capture or teaching persistence
- no contradiction resolution workflow
- no explainability or source-audit surfaces
- no Today, Goals, or Insights contradiction UI
- no runtime, backend, sync, widget, Live Activity, notification, or App Intent expansion
- no Batch 31 implementation

## Validation That Actually Ran

- `xcodegen generate`
  - passed
- native simulator build:
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -sdk iphonesimulator -destination "generic/platform=iOS Simulator" CODE_SIGNING_ALLOWED=NO build`
  - passed
- targeted contradiction/orchestration/persistence validation:
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests/GoalContradictionModelsTests -only-testing:AmbitionsTests/GoalContradictionServiceTests -only-testing:AmbitionsTests/GoalEngineOrchestratorTests -only-testing:AmbitionsTests/PersistenceRepositoryTests test`
  - passed
- authoritative native unit validation:
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests test`
  - passed
- UI/manual simulator validation:
  - not performed, by design for this batch

## Completion Notes

- Batch 30 closed with a detection-only contradiction engine that stays inside the canonical goal-engine/service seam and emits reusable metadata rather than changing behavior.
- The canonical contradiction output is a compact `contradictionReport` attached to `GoalOrchestrationMetadata`.
- Contradiction records are typed, structural, deterministic, and auditable, with stable artifact references rather than free-form identity.
- Existing planning, ranking, blocking, and UI behavior remain unchanged in this batch.
- The checked-out branch remained `main` during implementation, validation, and wrap-up.

## Next Active Batch

Batch 31 — Ambitions 2.0 Batch 12 / Correction and teaching loop
