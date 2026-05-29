# Batch 29 — Ambitions 2.0 Batch 10 / Energy Learning and Ranking

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_surface_multiple_active_batches, stale_or_unknown_active_status
> Prior recommended actions: Expedite
> Candidate references: AMB28-same_surface_multiple_active_batches-13212827, AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-66075429, AMB28-stale_or_unknown_active_status-93824196

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, merge-overlap-before-proof, status-expedite
> Dispositions: clarify-status-before-use, merge-before-proof, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

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

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
