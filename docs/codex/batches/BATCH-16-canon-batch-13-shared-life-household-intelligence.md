# Batch 16 — Canon Batch 13 / Shared Life / Household Intelligence

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, merge-overlap-before-proof, status-expedite, terminology-quarantine
> Dispositions: clarify-status-before-use, merge-before-proof, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

## Status

Completed

## Goal

Build the shared life / household intelligence foundation so Ambitions can support partner/shared goals, delegated work, care responsibilities, and household coordination in a calm, consumer-native way without becoming workplace collaboration software or a second product model.

## In Scope

- audit the current support/delegation, relationship, child/support link, path, ritual, and timing seams already in the native app
- define the minimum shared-life model needed now for:
  - partner/shared goals
  - delegated work objects
  - care/responsibility-aware planning
  - household logistics primitives
  - shared appointment / coordination context where current timing seams already exist
- keep all shared-life modeling additive under `LifeGraphContext`
- add or refine only compatibility-safe shared domain models and derived summary DTOs
- add a read-time-only `SharedLifeCoordinationService` derived from existing goals, evidence, feedback, timing, and `lifeGraph` metadata
- allow existing planning, recovery, learning, ritual, and Today layers to consume compact shared-life summaries only where clearly justified
- add or update focused tests for shared-life derivation, delegated/support flows, care-aware context, and persistence compatibility

## Out Of Scope

- real-time multi-user sync
- accounts/auth
- cloud collaboration rollout
- messaging/chat systems
- enterprise/team behavior
- runtime separation
- device prototype work
- broad new UI surfaces
- speculative family dashboards
- a second planner, second persistence stack, or second household domain
- widget, Live Activity, notification, external snapshot, or sync expansion unless compile reality forces a tiny additive parity fix

## Dependency Rules

- do not skip ahead
- build on `GoalActor`, `GoalRelationshipKind`, `GoalSupportScope`, `childGoalIDs`, `supportGoalIDs`, `LifeGraphContext`, path systems, ritual, and current timing seams
- keep shared-life logic in shared domain/services, not screens
- prefer additive compatibility-safe model work over disruptive renames
- keep recommendations personal, humane, and explainable
- do not let feature services or engine-local code become owners of household heuristics

## Extra Constraints

- keep shared-life modeling additive under `LifeGraphContext`; do not create a parallel household domain, separate participant repository, or multi-user identity system
- `SharedLifeCoordinationService` must remain read-time only and derived from existing goals, evidence, feedback, timing, and `lifeGraph` metadata
- do not add new SwiftData entities, repository types, or persisted coordination snapshots
- `SharedLifeParticipant` and related types must represent role/context only, not authenticated users or sync identities
- `PlanningEvaluation`, `RescheduleEngine`, `LearningAnticipationService`, `RitualOrchestrationService`, and `TodayFeatureService` must remain consumers of compact shared-life summaries only
- keep shared appointment/logistics handling lightweight and dependent on existing timing/time-orchestration seams
- preserve backward compatibility for goal/draft/snapshot decoding; all new fields must be optional/defaultable
- keep care-aware and delegated-support adjustments small, humane, and explainable
- run full scheme validation unconditionally
- mark Batch 16 completed only if generation, build, targeted tests, and full scheme validation all pass

## Current Repo Notes

- `GoalActor`, `ExecutionOwnership`, `GoalRelationshipKind`, `GoalSupportScope`, `childGoalIDs`, and `supportGoalIDs` already exist and should remain the core relationship seams.
- `LifeGraphContext` already round-trips through goal blueprints, drafts, goals, snapshot-backed persistence, and portable export/import.
- `LifeGraphResolver.relationshipGraph(for:within:)` already resolves parent, child, and support links and is the right place for shared structural derivation.
- `ProgressEvidenceKind.delegatedUpdate` already exists and should remain the primary support-progress evidence seam.
- Batch 15's learning layer is already derived/read-time only, so Batch 16 should follow that pattern.
- Widgets, Live Activities, notifications, and external snapshots already consume privacy-safe shared data; they must remain untouched unless compile parity forces a tiny additive fix.

## Exit Criteria

- additive shared-life metadata lives only under `LifeGraphContext` and keeps decode compatibility when absent
- one read-time `SharedLifeCoordinationService` derives delegated/support, responsibility, care, logistics, and compact coordination summaries from existing app data only
- planning, recovery, learning, ritual, and Today consume compact shared-life summaries without owning the logic locally
- repository and portable snapshot round-trips preserve the new additive metadata without new schema columns or snapshot families
- generation, build, targeted tests, and full scheme validation all pass before the batch is marked completed

## Validation

- `xcodegen generate`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -sdk iphonesimulator -destination "generic/platform=iOS Simulator" CODE_SIGNING_ALLOWED=NO build`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests/Domain/LifeGraphModelsTests -only-testing:AmbitionsTests/Domain/SharedLifeCoordinationServiceTests -only-testing:AmbitionsTests/Domain/LearningAnticipationServiceTests -only-testing:AmbitionsTests/Ritual/RitualOrchestrationServiceTests -only-testing:AmbitionsTests/Today/TodayViewModelTests -only-testing:AmbitionsTests/Persistence/PersistenceRepositoryTests -only-testing:AmbitionsTests/Persistence/PortableSnapshotServiceTests test`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" test`

## Completion Notes

- Added additive shared-life metadata under `LifeGraphContext` only, including role/context participants, responsibilities, and lightweight coordination context that remain optional/defaultable for backward-compatible decode behavior.
- Added read-time-only `SharedLifeCoordinationService` and shared resolver summaries so delegated/support work, care load, household logistics, and compact timing signals can be derived from existing goals, evidence, feedback, and timing without new persistence entities or sync identity concepts.
- Updated planning, reschedule, learning, ritual, and Today to consume compact shared-life summaries only, with small humane adjustments and no new feature-local household heuristics.
- Added focused tests covering shared-life derivation, read-time coordination summaries, ritual/Today consumption, and persistence/export round-trips.
- Validation passed on April 19, 2026 with:
  - `xcodegen generate`
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -sdk iphonesimulator -destination "generic/platform=iOS Simulator" CODE_SIGNING_ALLOWED=NO build`
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests/Domain/LifeGraphModelsTests -only-testing:AmbitionsTests/Domain/SharedLifeCoordinationServiceTests -only-testing:AmbitionsTests/Domain/LearningAnticipationServiceTests -only-testing:AmbitionsTests/Ritual/RitualOrchestrationServiceTests -only-testing:AmbitionsTests/Today/TodayViewModelTests -only-testing:AmbitionsTests/Persistence/PersistenceRepositoryTests -only-testing:AmbitionsTests/Persistence/PortableSnapshotServiceTests test`
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" test`
- No widget, Live Activity, notification, external snapshot, or sync-boundary changes were required for compile parity in this batch.

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
