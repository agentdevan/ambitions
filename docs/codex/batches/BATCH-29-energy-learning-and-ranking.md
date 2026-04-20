# Batch 29 — Ambitions 2.0 Batch 10 / Energy Learning and Ranking

## Status

Completed

## Goal

Add the first canonical energy-learning layer on top of the Batch 28 energy foundation so Ambitions can learn sustainable execution fit from explicit historical evidence and use that learning in recommendation ranking deterministically, locally, and explainably.

This batch stayed narrow. It did not add focus-window learning, contradiction logic, user-facing explanation UI, live-state sensing, SwiftData schema changes, runtime/extension widening, or broader anticipation expansion.

## What Landed

- added canonical energy-learning contracts in `Native/Ambitions/Domain/GoalEngine/GoalEnergyLearningModels.swift`
- added `goalEnergyLearningSchemaVersion` as `goal_energy_learning.native.v1`
- added stable typed reason, tendency, and evidence-reference codes so logic and tests rely on structured fields rather than prose
- added the derived-on-read learning service in `Native/Ambitions/Services/GoalEnergyLearningService.swift`
- kept learning local and compatibility-safe:
  - same goal + same step first
  - same goal + same step type fallback only when safe local matches exist
  - no cross-goal generalization
  - no persisted learned profile
- kept ambiguous or sparse history conservative:
  - fewer than 3 explicit signals stays neutral
  - conflicting history stays neutral
  - missing canonical energy fit stays neutral
  - no safe same-goal fallback stays neutral
- added bounded planning-time ranking nudges through `PlanningEnergyLearningSummary`
- kept ranking adjustment simple, explicit, and clamped to `-0.08...0.08`
- updated `PlanningNextStepSelector` so canonical energy learning contributes the history-based energy ranking term
- removed legacy selector-path energy double-counting by replacing the old learned-fit energy contribution in selector scoring instead of stacking both systems
- kept energy learning downstream of existing blocker/dependency eligibility checks so blocked or dependency-invalid candidates are never promoted by learned energy
- threaded the new dependency through existing runtime and Today injection seams without adding new UI fields or surfaces
- kept Today wiring dependency-only by reusing the shared selector rather than introducing a separate Today-only ranking path
- added focused service and selector regression tests for:
  - boundedness
  - sparse-history neutrality
  - conflicting-history neutrality
  - local fallback behavior
  - no double-counting with legacy learned fit
  - deterministic ordering
  - blocked/dependency-invalid candidate protection

## What Did Not Land

- no focus-window learning
- no contradiction engine logic
- no correction/teaching loop
- no user-facing explanation surfaces
- no live fatigue, biometric, or current-state inference
- no widgets, Live Activities, notifications, App Intents, or extension work
- no SwiftData models, repositories, migrations, or stored learned profiles
- no sync/backend/runtime expansion
- no Batch 30 implementation

## Validation That Actually Ran

- simulator used:
  - `iPhone 17` on `iOS 26.3`
  - destination: `platform=iOS Simulator,name=iPhone 17`
- `xcodegen generate`
  - passed
- native simulator build:
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -sdk iphonesimulator -destination "generic/platform=iOS Simulator" CODE_SIGNING_ALLOWED=NO build`
  - passed
- targeted Batch 29 validation:
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests/GoalEnergyLearningServiceTests -only-testing:AmbitionsTests/PlanningDomainModelsTests test`
  - first run found one real Batch 29 issue in sparse-history neutral reasoning
  - after the fix, rerun passed with 18 tests and 0 failures
- wider affected validation:
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests/GoalEnergyLearningServiceTests -only-testing:AmbitionsTests/PlanningDomainModelsTests -only-testing:AmbitionsTests/GoalEnergyFitModelsTests -only-testing:AmbitionsTests/GoalEnergyFitServiceTests -only-testing:AmbitionsTests/TodayViewModelTests -only-testing:AmbitionsTests/PersistenceRepositoryTests test`
  - passed with 43 tests and 0 failures
- authoritative validation:
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests test`
  - passed with 283 tests and 0 failures

## Validation Fix Closed During Testing

- file:
  - `Native/Ambitions/Services/GoalEnergyLearningService.swift`
- fix:
  - exact same-step local evidence with fewer than 3 explicit signals now returns `.insufficientSignals` instead of `.noSafeSameGoalMatch`
- effect:
  - sparse same-step history stays structurally neutral in the way Batch 29 intended and tests required

## Completion Notes

- Batch 29 closed with a canonical energy-learning layer that remains derived on read and explainable from explicit evidence.
- Recommendation ranking now gets a bounded, typed, deterministic energy-learning nudge without bypassing structural eligibility rules.
- Legacy learned-fit scoring remains available for non-selector surfaces, while selector-path energy double-counting is removed.
- Today integration stayed dependency-only, with no new user-facing fields or UI expansion.
- The checked-out branch remained `main` during implementation, validation, and wrap-up.

## Next Active Batch

Batch 30 — Ambitions 2.0 Batch 11 / Contradiction engine
