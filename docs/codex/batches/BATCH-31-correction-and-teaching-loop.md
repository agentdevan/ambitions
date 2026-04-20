# Batch 31 — Ambitions 2.0 Batch 12 / Correction and Teaching Loop

## Status

Completed

## Goal

Build the first canonical correction-and-teaching layer for Ambitions 2.0 so explicit user corrections can be captured as durable, typed, same-goal teaching signals for future interpretation and ranking work.

This batch stayed narrow. It did not change live understanding, contradiction handling, planning, ranking, explainability surfaces, source-audit UI, or product-shell behavior.

## What Landed

- added canonical teaching contracts in `Native/Ambitions/Domain/GoalEngine/GoalTeachingModels.swift`
- added `goalTeachingSchemaVersion` as `goal_teaching.native.v1`
- added durable typed teaching signals with:
  - explicit manual-only source
  - stable same-goal anchors
  - deterministic `applicationKey` supersession
  - additive historical preservation
- added a reusable capture/read teaching service in `Native/Ambitions/Services/GoalTeachingSignalService.swift`
- kept correction capture inside the canonical goal-engine seam by validating against existing orchestration metadata rather than introducing a parallel system
- supported explicit bounded correction categories for:
  - interpretation correction
  - goal-subject correction
  - classification correction
  - requirement relevance correction
  - contradiction disposition correction
  - energy-fit correction
- enforced strict rejection for:
  - cross-goal corrections
  - ambiguous scope
  - unanchored corrections
  - nonexistent or stale targets
- added a standalone teaching repository seam in `Native/Ambitions/Persistence/PersistenceContracts.swift`
- added additive SwiftData persistence for teaching signals without widening existing goal-engine models
- added additive portable snapshot support so older snapshots without teaching signals still decode/import as empty
- kept composition changes thin and wiring-only in app/preview container composition

## What Did Not Land

- no live understanding behavior changes
- no contradiction resolution behavior changes
- no planning or ranking behavior changes
- no implicit learning from behavior, feedback, or outcomes
- no cross-goal teaching generalization
- no explainability or source-audit surfaces
- no UI/product-surface correction flows
- no Batch 32 implementation

## Validation That Actually Ran

- `xcodegen generate`
  - passed
- native simulator build:
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -sdk iphonesimulator -destination "generic/platform=iOS Simulator" CODE_SIGNING_ALLOWED=NO build`
  - passed
- targeted Batch 31 validation:
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests/GoalTeachingModelsTests -only-testing:AmbitionsTests/GoalTeachingSignalServiceTests -only-testing:AmbitionsTests/PersistenceRepositoryTests -only-testing:AmbitionsTests/PortableSnapshotServiceTests test`
  - passed
- authoritative native unit validation:
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests test`
  - passed
- UI/manual simulator validation:
  - not performed, by design for this batch

## Completion Notes

- Batch 31 closed with a capture/read-only correction-and-teaching layer rather than a behavior-changing learning system.
- Teaching signals are durable, typed, explicit/manual-only, and bounded to same-goal stable anchors.
- Read-time supersession is deterministic through `applicationKey`, while older correction history remains preserved.
- Persistence stays additive through a standalone repository seam plus portable snapshot support.
- Existing understanding, contradiction, planning, ranking, and UI behavior remain unchanged in this batch.
- The checked-out branch remained `main` during validation and wrap-up.

## Next Active Batch

Batch 32 — Ambitions 2.0 Batch 13 / Explainability and source audit surfaces
