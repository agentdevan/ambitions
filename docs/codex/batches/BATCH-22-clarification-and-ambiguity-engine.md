# Batch 22 — Ambitions 2.0 Batch 03 / Clarification and Ambiguity Engine

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, merge-overlap-before-proof, status-expedite
> Dispositions: clarify-status-before-use, merge-before-proof, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

## Status

Completed

## Goal

Build the clarification and ambiguity boundary that detects when a life goal is underspecified, ambiguous, multi-interpretation, or missing critical context, then emits structural clarification outputs instead of letting later planning systems pretend certainty.

This batch stayed inside the existing goal-engine/orchestration seam. It did not add UI, LLM calls, network calls, runtime widening, or SwiftData columns.

## What Landed

- added shared structural clarification contracts in `Native/Ambitions/Domain/GoalEngine/GoalClarificationModels.swift`
- added deterministic local-only analysis in `Native/Ambitions/Services/GoalClarificationService.swift`
- updated goal-engine orchestration so `GoalClarificationAnalysis` is the structural source of truth inside the existing intake/orchestration seam
- preserved compatibility projections and current result flows for:
  - `ClarificationSet`
  - `GoalOrchestrationClarification`
  - blocked / clarification-required / starter-planned behavior
- added structural support for:
  - candidate interpretations
  - ambiguity taxonomy beyond `MissingFieldKey`
  - missing-context detection
  - explicit assumptions
  - machine-usable clarification question contracts
  - canonical proceed-vs-block gating through `GoalClarificationDecision`
- updated planner compatibility so starter-plan assumptions come from the clarification layer when the decision is safe to proceed
- added focused tests for clarification models, clarification service behavior, and compatibility across current goal orchestration and draft persistence flows

## What Did Not Land

- no product shell UI
- no chat interface
- no LLM integration
- no network calls or provider lookups
- no runtime contract widening
- no SwiftData schema expansion or new columns
- no generalized goal understanding implementation beyond the clarification boundary
- no Batch 23 work

## Validation That Actually Ran

- `xcodegen generate`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -sdk iphonesimulator -destination "generic/platform=iOS Simulator" CODE_SIGNING_ALLOWED=NO build`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests/Domain/GoalClarificationModelsTests -only-testing:AmbitionsTests/Services/GoalClarificationServiceTests -only-testing:AmbitionsTests/GoalEngine/GoalEngineOrchestratorTests -only-testing:AmbitionsTests/Goals/GoalCreationServiceTests -only-testing:AmbitionsTests/Persistence/PersistenceRepositoryTests test`
  - this was attempted in that environment, but Xcode reported `0 tests`, so it was not treated as the real validation pass
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests test`
  - passed with 222 tests and 0 failures

## Completion Notes

- Batch 22 closed without introducing a second top-level understanding architecture.
- The new clarification layer preserves ambiguity, missing context, assumptions, and multi-interpretation structure instead of collapsing inputs into one guessed reading.
- Compatibility-safe projections keep existing planner, draft, and orchestration seams stable while making `GoalClarificationAnalysis` canonical.

## Next Active Batch

Batch 23 — Ambitions 2.0 Batch 04 / Generalized goal understanding contracts

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
