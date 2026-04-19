# Batch 15 — Canon Batch 12 / Learning and Anticipation Engine

## Status

Completed

## Goal

Build the learning and anticipation engine so Ambitions can use accumulated user history, rhythm patterns, drift history, fit signals, and life/path context to produce more personal, explainable recommendations without turning into a black-box planner.

## In Scope

- audit existing Goal Memory, feedback history, evidence history, planning evaluation, recovery, ritual, and time-orchestration seams
- define the minimum shared learning/anticipation model needed now for:
  - energy-fit patterns
  - focus-window patterns
  - recommendation ranking by historical fit
  - underrepresented-goal detection
  - procrastination / drift trigger patterns
  - timeline risk forecasting
  - "why now?" explanation support
- add or refine shared domain models only where they are immediately useful and compatibility-safe
- add or refine service/domain helpers for:
  - pattern aggregation from existing evidence/feedback/history
  - lightweight fit scoring
  - anticipation/risk summaries
  - explanation metadata
- allow existing planning/recovery/ritual/time layers to consume these learned summaries only where clearly justified
- add or update focused tests for learning-pattern derivation, anticipation summaries, historical-fit ranking signals, and explanation metadata

## Out Of Scope

- internet retrieval
- LLM integration
- cloud sync expansion
- household/shared-user logic
- device/runtime separation
- broad new UI surfaces
- full energy-map UX shell
- speculative black-box recommendation behavior
- a second planner or second persistence stack

## Dependency Rules

- do not skip ahead
- build on existing evidence, feedback, planning, recovery, ritual, and time seams rather than inventing a separate memory universe
- keep learning logic in shared domain/services, not screens
- prefer additive compatibility-safe model work over disruptive renames
- recommendations must remain explainable and traceable to observed patterns
- do not let feature services become owners of learning logic

## Extra Constraints

- keep `LearningAnticipationService` fully derived/read-time only in this batch
- do not add new SwiftData entities, repository types, or persisted learning snapshots
- learning outputs must stay traceable to observed signals only:
  - `ProgressEvidence`
  - `GoalFeedbackEvent`
  - existing timing/history context
  - current life/path structure
- `EnergyFitPattern` and `FocusWindowPattern` must remain heuristic and conservative
- use explicit sparse-history fallbacks instead of strong-fit wording when signal counts are low
- keep one shared learned-fit scorer reused by ranking, recovery, ritual, and explanation consumers
- `PlanningEvaluation` and `RescheduleEngine` must remain consumers of compact learned summaries only
- `WhyNowExplanationMetadata` must stay concise, deterministic, and evidence-based
- do not widen external snapshots, widgets, Live Activities, or notification payloads unless compile reality forces a tiny parity change
- keep goal/plan persisted contracts unchanged unless a compile-critical additive compatibility field is unavoidable, and report that explicitly if it happens
- mark Batch 15 completed only if generation, build, targeted tests, and full scheme validation all pass

## Current Repo Notes

- `ProgressEvidence` and `GoalFeedbackEvent` already provide the raw historical signal this batch should build on.
- `PlanningEvaluation`, `PlanningNextStepSelector`, `RescheduleEngine`, `RitualOrchestrationService`, `TodayFeatureService`, and `GoalsFeatureService` already expose the bounded consumer seams that should read derived learning outputs.
- `LifeGraphResolver.pathStateSummary(for:)` already provides path readiness and progression context that can contribute to underrepresented-goal and timeline-risk summaries.
- The repo does not currently have a dedicated persisted Goal Memory layer, so this batch should remain read-time and migration-light.

## Exit Criteria

- one shared read-time learning service derives conservative fit, drift, risk, and why-now summaries from existing evidence/feedback/path context
- ranking, recovery, ritual, and bounded Today/Goals copy consume the same learned-fit scorer instead of inventing local heuristics
- sparse history falls back cleanly to current behavior
- no new persistence model, repository type, or external-surface payload expansion is introduced unless compile-critical and compatibility-safe
- generation, build, targeted tests, and full scheme validation all pass before the batch is marked completed

## Validation

- `xcodegen generate`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -sdk iphonesimulator -destination "generic/platform=iOS Simulator" CODE_SIGNING_ALLOWED=NO build`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests/LearningAnticipationServiceTests -only-testing:AmbitionsTests/PlanningDomainModelsTests -only-testing:AmbitionsTests/RescheduleEngineTests -only-testing:AmbitionsTests/RitualOrchestrationServiceTests test`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" test`

## Completion Notes

- Added a shared read-time learning layer over `ProgressEvidence`, `GoalFeedbackEvent`, current timing/history context, and life/path structure only.
- Kept persistence contracts unchanged and did not add new SwiftData entities, repositories, or persisted learning snapshots.
- Kept `EnergyFitPattern` and `FocusWindowPattern` conservative and heuristic, with explicit sparse-history fallback behavior.
- Reused one learned-fit scorer across planning selection, recovery, ritual orchestration, Today, and Goals consumers.
- Did not widen `ExternalSurfaceSnapshotBuilder`, widgets, Live Activities, or notification payloads in this batch.
