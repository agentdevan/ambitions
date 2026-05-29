# Batch 30 — Ambitions 2.0 Batch 11 / Contradiction Engine

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches, stale_or_unknown_active_status
> Prior recommended actions: Expedite, Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-94672703, AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-96568748, AMB28-stale_or_unknown_active_status-32509722

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, merge-overlap-before-proof, status-expedite
> Dispositions: clarify-status-before-use, merge-before-proof, merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

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
