# Batch 06 — Canon Batch 4 / Recovery Engine

## Status

Completed

## Goal

Build Ambitions' recovery engine so delayed, skipped, blocked, or low-confidence work produces a calmer, safer, more believable next move without requiring time orchestration, EventKit, or ambient-surface work yet.

## In Scope

- audit the current recovery and reschedule seams
- strengthen `RescheduleEngine` outputs using Batch 1 shared primitives and Batch 3 planning outputs
- add smaller-step fallback generation where justified
- add or refine waiting and dependency-aware states where justified
- classify recovery causes using existing `CauseOfDrift` and planning signals
- add or refine recovery-aware recommendation ranking
- add minimal goal-history writeback only where the existing feedback/history seam naturally supports it
- add focused tests for recovery decisions, fallback behavior, dependency handling, and post-drift next-step selection

## Out Of Scope

- EventKit or time orchestration
- calendar conflict logic
- App Intents
- widgets / Live Activities
- sync
- life graph / household / device work
- broad UI redesign
- speculative narrative UX beyond minimal metadata needed for existing surfaces
- new persistence columns unless absolutely required and justified

## Current Repo Notes

- `RescheduleEngine`, `GoalFeedbackEvent.causeOfDrift`, `GoalFeedbackSignalSnapshot`, `GoalEngineAdaptationService`, and shared next-step selection already exist.
- Today and Goal Detail already write recovery-relevant feedback through native feedback/history seams.
- Waiting and dependency handling should be derived from current `dependencyStepIDs`, blocked step state, `.blockedExternal`, `.notReady`, and existing drift signals rather than a new dependency model.
- Recovery metadata should stay additive and localized so current planner and persistence boundaries remain stable.

## Exit Criteria

- recovery outputs expose deterministic cause, posture, dependency/waiting state, and calmer next-step guidance
- Today and Goal Detail consume shared recovery outputs without adding local ranking logic
- existing feedback/history seams remain the only recovery writeback path
- additive recovery metadata preserves backward decode compatibility
- XcodeGen generation, build, targeted tests, and full `AmbitionsTests` validation pass before this batch is marked completed

## Completion Note

Completed after:

- `xcodegen generate`
- simulator build via `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -sdk iphonesimulator -destination "generic/platform=iOS Simulator" CODE_SIGNING_ALLOWED=NO build`
- targeted recovery validation for `RescheduleEngineTests`, `GoalEngineFeedbackTests`, and `TodayViewModelTests`
- full `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests test`
