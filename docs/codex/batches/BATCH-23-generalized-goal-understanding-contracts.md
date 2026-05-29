# Batch 23 — Ambitions 2.0 Batch 04 / Generalized Goal Understanding Contracts

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, status-expedite
> Dispositions: clarify-status-before-use, merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

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
