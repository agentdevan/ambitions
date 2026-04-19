# Batch 05 — Canon Batch 3 / Planning Engine v2

## Status

Completed

## Goal

Strengthen Ambitions' canonical planning brain so the app can derive a more believable, explainable next move with explicit confidence and plan-risk signals before recovery, time orchestration, or ambient surfaces expand.

## In Scope

- audit the current planning/recommendation pipeline
- formalize feasibility scoring where justified
- formalize recommendation confidence usage through the planning flow
- add fragility and pressure markers for plans or recommendations where justified
- add pacing and effort-posture rules at existing planner seams
- strengthen canonical next-step derivation rules
- refine planning-domain outputs/contracts only where needed
- add focused tests for feasibility, confidence, next-step derivation, and planning-output behavior

## Out Of Scope

- recovery engine behavior changes
- cause-of-drift or reschedule behavior changes beyond compile compatibility
- time orchestration / EventKit work
- calendar conflict logic
- App Intents
- widgets / Live Activities
- sync
- life graph / household / device work
- large UI redesigns
- speculative AI or narration behavior

## Current Repo Notes

- `GoalEngineOrchestrator`, `GoalPlanner`, inference confidence, plan linting, feedback confidence, Today ranking, and external next-action snapshots already exist.
- `RepositoryBackedGoalsService.createGoal` still has a deterministic micro-plan path and should be routed narrowly through the canonical goal engine without redesigning the create-goal UX.
- Planning evaluation metadata should round-trip through additive Codable fields and existing snapshot payloads. No SwiftData columns are expected.
- Today and external snapshots should consume one shared next-step selector instead of separate ranking logic.

## Exit Criteria

- planning outputs expose deterministic feasibility, confidence, pressure, fragility, and effort-posture metadata
- goal creation uses the canonical planning engine while preserving clear planned / starter / clarification / blocked persistence behavior
- Today and external snapshots use the same next-step selector
- focused tests cover planning evaluation, canonical goal creation, selector reuse, and persistence compatibility
- XcodeGen generation, build, targeted tests, and full AmbitionsTests validation pass before this batch is marked completed

## Completion Note

Completed after `xcodegen generate`, simulator build, targeted Batch 3 tests, and full `AmbitionsTests` validation passed on iPhone 17 simulator.
