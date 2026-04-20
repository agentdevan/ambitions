# Batch 28 — Ambitions 2.0 Batch 09 / Energy Model Foundation

## Status

Completed

## Goal

Create the foundational energy domain model and service boundary that Ambitions can use to reason about energy-fit deterministically and explainably.

This batch stayed foundation-only. It did not add learned energy patterns, personalized ranking, focus-window learning, live user-state sensing, UI surfaces, widgets, Live Activities, notifications, App Intents, SwiftData schema changes, sync/runtime widening, or recommendation ranking behavior changes.

## What Landed

- added canonical energy-fit contracts in `Native/Ambitions/Domain/GoalEngine/GoalEnergyFitModels.swift`
- added `goalEnergyFitSchemaVersion` as `goal_energy_fit.native.v1`
- modeled planning-time energy context with explicit unknown and assumed-neutral states instead of live-state or biometric claims
- added typed taxonomy for capacity level, recovery state, pacing posture, work shape, effort demand, focus demand, recovery compatibility, fit bands, target kind, and planning-summary source
- added structural `GoalEnergyFitReasonCode` values so deterministic logic and tests key off stable reason codes rather than prose
- added canonical model outputs:
  - `GoalEnergyFitEvaluation`
  - `GoalEnergyCandidateSummary`
  - `GoalEnergyModelAuditEntry`
  - `GoalEnergyModelAuditMetadata`
  - `GoalEnergyModel`
  - `PlanningEnergyFitSummary`
- added `.unevaluated()` as a safe compatibility fallback for older metadata
- added the single reusable evaluation path in `Native/Ambitions/Services/GoalEnergyFitService.swift`
- kept scoring simple, bounded to `0...1`, deterministic, and explainable from explicit structural rules
- attached `GoalOrchestrationMetadata.energyModel` through existing orchestration metadata with `decodeIfPresent` fallback
- injected the energy-fit service through existing constructor/factory patterns instead of hardwiring an independent evaluator path
- threaded canonical energy metadata into planning read-through through one optional nested `PlanningEnergyFitSummary`
- preferred canonical orchestration-produced metadata when available and used the same service path for fallback summaries
- left recommendation score calculation, sorting, tie-breaking, and learned-fit behavior unchanged
- kept legacy `LearningAnticipationModels` and older learned-fit types isolated for later batches
- added focused model, service, orchestration, planning, and persistence tests for deterministic evaluation, bounded scores, structural reason markers, canonical consistency, legacy decode, and unchanged recommendation ordering

## What Did Not Land

- no energy learning system
- no history-based personalization or ranking
- no focus-window learning
- no correction or teaching loop
- no live fatigue, biometric, or current-state inference
- no user-facing energy UI or explanations
- no widgets, Live Activities, notifications, App Intents, or extension work
- no recommendation ranking changes
- no SwiftData models, repositories, migrations, sync work, or backend/runtime separation work
- no Batch 29 implementation

## Validation That Actually Ran

- `xcodegen generate`
- simulator build:
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -sdk iphonesimulator -destination "generic/platform=iOS Simulator" CODE_SIGNING_ALLOWED=NO build`
  - passed
- targeted Batch 28 selection:
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests/GoalEnergyFitModelsTests -only-testing:AmbitionsTests/GoalEnergyFitServiceTests -only-testing:AmbitionsTests/GoalEngineOrchestratorTests -only-testing:AmbitionsTests/PlanningDomainModelsTests -only-testing:AmbitionsTests/PersistenceRepositoryTests test`
  - passed with 36 tests and 0 failures
- authoritative validation:
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests test`
  - passed with 273 tests and 0 failures

The requested `iPhone 16` simulator destination was unavailable in the execution environment, so simulator tests used `iPhone 17`.

## Completion Notes

- Batch 28 closed with energy-fit represented as canonical orchestration metadata and a reusable service boundary.
- Planning consumers now have a compact optional energy summary for later batches without changing recommendation behavior.
- Older metadata without `energyModel` decodes safely to `.unevaluated()`.
- The checked-out branch remained `main` during implementation, validation, and wrap-up.

## Next Active Batch

Batch 29 — Ambitions 2.0 Batch 10 / Energy learning and ranking
