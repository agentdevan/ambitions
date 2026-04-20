# Batch 23 — Ambitions 2.0 Batch 04 / Generalized Goal Understanding Contracts

## Status

Completed

## Goal

Build the canonical post-clarification goal-understanding contract so Ambitions can turn raw goal input, clarification state, and optional knowledge context into a stable machine-usable understanding object before later compiler work.

This batch stayed contract-and-composition work only. It did not add path compilation, domain-pack logic, resource ranking, explanation surfaces, UI, LLM calls, live web search, external API calls, runtime widening, or SwiftData columns.

## What Landed

- added the canonical downstream understanding contract in `Native/Ambitions/Domain/GoalEngine/GoalUnderstandingModels.swift`
- added deterministic local composition in `Native/Ambitions/Services/GoalUnderstandingService.swift`
- updated `Native/Ambitions/Domain/GoalEngine/GoalEngineContracts.swift` so:
  - `GoalUnderstanding` is carried as the canonical downstream orchestration contract
  - `GoalPlannerInput` can receive `understanding` without changing planner behavior
  - optional narrow knowledge context can be threaded structurally without requiring live retrieval
- updated `Native/Ambitions/Domain/GoalEngine/GoalEngineOrchestrator.swift` so understanding is built after clarification and attached to orchestration metadata
- kept `ClassificationResult` and `GoalClarificationAnalysis` intact as upstream inputs instead of collapsing or replacing them
- preserved ambiguity structurally through one primary interpretation plus alternate interpretations when ambiguity remains active
- kept readiness derived from `GoalClarificationDecision` instead of inventing a second proceed-vs-block gate
- kept knowledge context optional and narrow
- added backward-compatible decoding for older orchestration metadata so legacy drafts can derive understanding without SwiftData schema changes
- added focused tests for understanding models, understanding service composition, orchestration metadata threading, goal creation compatibility, and persistence round-tripping

## What Did Not Land

- no path compiler implementation
- no domain-pack implementation
- no resource graph or source ranking implementation
- no explainability or recommendation-copy surfaces
- no product shell UI
- no LLM integration
- no live web search or external API calls
- no runtime contract widening
- no SwiftData schema expansion or new columns
- no Batch 24 implementation

## Validation That Actually Ran

- `xcodegen generate`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -sdk iphonesimulator -destination "generic/platform=iOS Simulator" CODE_SIGNING_ALLOWED=NO build`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests/Domain/GoalUnderstandingModelsTests -only-testing:AmbitionsTests/Services/GoalUnderstandingServiceTests -only-testing:AmbitionsTests/GoalEngine/GoalEngineOrchestratorTests -only-testing:AmbitionsTests/Goals/GoalCreationServiceTests -only-testing:AmbitionsTests/Persistence/PersistenceRepositoryTests test`
  - this compiled, linked, and signed successfully in that environment, but then hung without emitting a final XCTest summary, so it cannot be truthfully claimed as passed
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests test`
  - this also compiled, linked, and signed successfully in that environment, but then hung without emitting a final XCTest summary, so it cannot be truthfully claimed as passed
- branch state during completion recording: `main`

## Completion Notes

- `GoalUnderstanding` is now the canonical downstream post-clarification contract for goal understanding.
- `ClassificationResult` and `GoalClarificationAnalysis` remain the intact upstream inputs that feed the understanding layer.
- ambiguity, assumptions, uncertainty, and alternates remain structural instead of being flattened into fake certainty.
- backward-compatible metadata decoding keeps existing draft snapshots readable without adding persistence schema surface.

## Next Active Batch

Batch 24 — Ambitions 2.0 Batch 05 / Path compiler foundation
