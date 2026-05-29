# Batch 13 — Canon Batch 10 / Life Graph Foundation

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_surface_multiple_active_batches, stale_or_unknown_active_status
> Prior recommended actions: Expedite
> Candidate references: AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-96568748, AMB28-stale_or_unknown_active_status-59313847

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

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

Build the life graph foundation so Ambitions can represent structured life domains, roles, and long-range path objects in a way that future path systems, learning, household coordination, and device/runtime work can consume without inventing a second model layer later.

## In Scope

- audit current goal, actor, relationship, parent/child/support, tags, timing, and progress seams
- define the minimum shared life-graph model needed now for life domains, roles, long-range path objects, and milestone dependencies
- add or refine domain models only where they are immediately useful and future-safe
- connect life-graph primitives to existing goal/draft structures in a compatibility-safe way
- add or refine service/domain helpers for resolving graph relationships and domain grouping
- add/update focused tests for graph relationships, domain grouping, role modeling, and compatibility with existing goal flows
- keep the implementation local-first and persistence-safe

## Out Of Scope

- household/shared-life collaboration features
- multi-user logic
- device/runtime-separation work
- cloud sync expansion
- App Intents / widgets / Live Activities work
- broad UI redesign
- major path-planning UX
- speculative life surface surfaces
- any second planner or second persistence stack

## Dependency Rules

- do not skip ahead
- life graph must build on existing goal/draft/actor/relationship seams
- do not create a parallel model universe for long-range planning
- keep the graph foundation in shared domain/services, not screens
- prefer additive compatibility-safe model work over disruptive renames
- no household or shared-user assumptions in this batch

## Extra Constraints

- keep `LifeGraphContext` as an additive envelope on existing `GoalBlueprint`, `GoalDraft`, and `Goal`
- preserve backward compatibility for existing goal/draft decoding and stored snapshots with `lifeGraph == nil`
- use explicit compatibility initializers with defaulted trailing `lifeGraph` parameters
- keep `LifeGraphResolver` structural only for primary domain resolution, domain grouping, parent/child/support resolution, and milestone dependency resolution
- do not add new SwiftData columns unless compile reality absolutely forces it
- preserve `lifeGraph` through manual `Goal` rebuild paths without expanding UI/reporting behavior
- stay conservative in intake and planner inference
- use existing `dependencyStepIDs` for step-level dependencies and keep long-range milestone dependencies inside `LifeGraphMilestone`
- mark the batch completed only if generation, build, corrected focused tests, and full `AmbitionsTests` validation pass

## Current Repo Notes

- The native canonical model layer already lives in `GoalBlueprint`, `GoalDraft`, and `Goal`.
- Relationship and ownership seams already exist through `GoalRelationshipKind`, `GoalActor`, `parentGoalID`, `childGoalIDs`, and `supportGoalIDs`.
- SwiftData repositories already persist full codable snapshots, which keeps this batch additive and migration-light.
- Several services manually rebuild `Goal` values, so preservation work is required even though UI work is out of scope.

## Exit Criteria

- `LifeGraphContext` exists as the minimum shared graph envelope on blueprints, drafts, and goals
- additive life-graph metadata round-trips through snapshot-backed persistence without schema changes
- structural graph helpers exist for primary domain resolution, grouping, relationship resolution, and milestone dependencies
- intake/planner defaults stay conservative and compatibility-safe
- existing goal flows keep working when `lifeGraph` is absent
- generation, build, corrected focused tests, and full `AmbitionsTests` validation pass before this batch is marked completed

## Validation

- `xcodegen generate`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -sdk iphonesimulator -destination "generic/platform=iOS Simulator" CODE_SIGNING_ALLOWED=NO build`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests/LifeGraphModelsTests -only-testing:AmbitionsTests/GoalCreationServiceTests -only-testing:AmbitionsTests/PlanningDomainModelsTests -only-testing:AmbitionsTests/PersistenceRepositoryTests test`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" test`

## Completion Notes

- Added `LifeGraphContext` and related life-domain, role, path, and milestone models in the shared domain layer without introducing a second repository, second snapshot family, or planner model.
- Threaded additive `lifeGraph` support through `GoalBlueprint`, `GoalDraft`, and `Goal` with compatibility-safe initializers and nil-safe decoding.
- Added `LifeGraphResolver` for primary domain resolution, domain grouping, structural parent/child/support lookups, and milestone dependency resolution only.
- Preserved `lifeGraph` through intake, deterministic planning, snapshot-backed persistence, legacy import, demo seeding, and feature-service goal rebuild paths.
- Added focused tests for domain grouping, relationship resolution, goal-creation compatibility, blueprint forwarding, and repository round-trips.
- Hardened `AmbitionsUITests.testPreviewBootstrapCanCreateGoalFromEmptyState()` by targeting the concrete text field and removing the brittle keyboard-dismiss fallback that was terminating the create-goal path.
- Validation passed for XcodeGen generation, simulator build, corrected focused life-graph/unit tests, full `AmbitionsTests` validation, and full scheme UI tests.

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
