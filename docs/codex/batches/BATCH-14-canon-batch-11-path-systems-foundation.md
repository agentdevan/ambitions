# Batch 14 — Canon Batch 11 / Path Systems Foundation

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

Build the path systems foundation so Ambitions can represent and reason about long-horizon paths made of prerequisites, milestone chains, readiness signals, and staged progression without creating a second planner or a giant new UI shell.

## In Scope

- audit the newly added life-graph model and current goal/planning/recovery seams
- define the minimum shared path-system model needed now for staged path tracks, prerequisites, readiness / gap signals, milestone-chain progression, and path-state summaries
- add or refine domain models only where they are immediately useful and compatibility-safe
- connect path primitives to existing `LifeGraphContext`, `GoalBlueprint`, `GoalDraft`, and goal flows
- add or refine shared resolver/service helpers for path-stage ordering, prerequisite resolution, readiness/gap detection, and milestone progression summaries
- allow existing planning and recovery layers to consume path metadata only where clearly justified
- add or update focused tests for path-stage resolution, prerequisite handling, readiness/gap evaluation, and compatibility with current goal flows

## Out Of Scope

- broad new UI surfaces
- major path surface UX
- household/shared-life coordination
- multi-user logic
- device/runtime separation
- cloud sync expansion
- App Intents / widgets / Live Activities work
- a second planner or second persistence stack
- speculative recommendation systems beyond what current planning and recovery seams can truthfully consume

## Dependency Rules

- do not skip ahead
- build on `LifeGraphContext` and existing goal/draft models rather than creating a parallel path-model universe
- keep path logic in shared domain/services, not screens
- prefer additive compatibility-safe model work over disruptive renames
- no household or shared-user assumptions in this batch
- no giant UI reveal; this is foundation and compatibility work first

## Extra Constraints

- keep path systems as an additive extension of `LifeGraphContext` and `LifeGraphResolver`
- do not create a second planner, second recovery engine, second persistence stack, or separate path-model universe
- keep persistence snapshot-backed and backward-compatible
- preserve backward decode behavior for stored goals/drafts with `lifeGraph == nil` or missing new path fields
- compute derived path summaries instead of persisting them separately unless compile reality forces a tiny compatibility-safe field
- keep milestone progression conservative when there is no explicit one-to-one step mapping
- mark Batch 14 completed only if generation, build, targeted tests, and full scheme validation all pass

## Current Repo Notes

- `LifeGraphContext` already threads through `GoalBlueprint`, `GoalDraft`, and `Goal`, so this batch should remain additive and migration-light.
- `LifeGraphResolver` already owns structural life-graph helpers and is the correct home for path-stage, prerequisite, readiness, and progression summaries.
- `GoalEngineIntake` and `DeterministicGoalPlanner` already infer conservative life-graph context for obvious career and education signals.
- `GoalsFeatureService` and `TodayFeatureService` already pass compact planning and recovery inputs into shared domain helpers; they should remain pass-through consumers only.

## Exit Criteria

- additive path-system metadata round-trips through snapshot-backed persistence without new schema columns
- `LifeGraphResolver` exposes shared helpers for stage ordering, prerequisite resolution, readiness/gap summaries, milestone progression summaries, and overall path-state summaries
- intake and deterministic planning infer only conservative path metadata for explicit signals
- planning and recovery consume compact derived path summaries without becoming path-logic owners
- existing goal and draft flows keep working when `lifeGraph` is absent
- generation, build, targeted tests, and full scheme validation pass before the batch is marked completed

## Validation

- `xcodegen generate`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -sdk iphonesimulator -destination "generic/platform=iOS Simulator" CODE_SIGNING_ALLOWED=NO build`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests/LifeGraphModelsTests -only-testing:AmbitionsTests/PlanningDomainModelsTests -only-testing:AmbitionsTests/RescheduleEngineTests -only-testing:AmbitionsTests/GoalCreationServiceTests -only-testing:AmbitionsTests/PersistenceRepositoryTests test`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsUITests/AmbitionsUITests/testPreviewBootstrapCanCreateGoalFromEmptyState test`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" test`

## Completion Notes

- Batch 14 remained an additive extension of `LifeGraphContext` and `LifeGraphResolver`; no second planner, recovery engine, persistence stack, or path-model universe was introduced.
- The final stabilization work stayed narrow to the flaky preview create-goal UI path by making `AmbitionsUITests.testPreviewBootstrapCanCreateGoalFromEmptyState` more resilient to keyboard and scroll timing before tapping the submit button.
- Validation completed successfully across XcodeGen generation, simulator build, focused Batch 14 domain tests, the isolated flaky UI test, and the full scheme test run on `iPhone 17`.

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
