# Batch 13 — Canon Batch 10 / Life Graph Foundation

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
- speculative life dashboard surfaces
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
