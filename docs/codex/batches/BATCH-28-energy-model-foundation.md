# Batch 28 — Ambitions 2.0 Batch 09 / Energy Model Foundation

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_surface_multiple_active_batches, stale_or_unknown_active_status
> Prior recommended actions: Expedite
> Candidate references: AMB28-same_surface_multiple_active_batches-66075429, AMB28-stale_or_unknown_active_status-91976799

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
