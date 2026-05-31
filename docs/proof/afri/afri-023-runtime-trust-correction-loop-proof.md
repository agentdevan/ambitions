# AFRI-023 Runtime Trust Correction Loop Proof

Status: Green, local simulator proof only
Issue: AMB-375 / AFRI-023
Date: 2026-05-31

## Scope

AFRI-023 extends the existing `CorrectionFold` and Personal Runtime learning owners so user corrections can shape future local recommendations without cloud dependence or silent mutation.

The scoped implementation adds deterministic correction reasons for wrong reason, wrong context, wrong capacity, unavailable, Still Counts, Blocked, Waiting, and Needs Recovery. Each correction remains receipt-backed, local-only, inspectable through You / What Ambitions knows, and reset/delete compatible before it can influence future recommendation ranking.

## Source Changes

- `Native/Ambitions/Domain/CorrectionFoldModels.swift`
  - Adds AMB-375 correction reasons to `CorrectionFoldRecommendationValue`.
  - Maps each reason to a deterministic `CorrectionFoldRecommendationLearningAdjustment`.
  - Keeps correction learning local-only, receipt-backed, SourceRecord-labeled, ReplayTrace-labeled, non-silent, and reset/delete compatible.
- `Native/Ambitions/Domain/RecommendationExplanationModels.swift`
  - Adds Personal Runtime inspection and clear routes for correction learning signals.
- `Native/AmbitionsTests/Domain/CorrectionFoldModelsTests.swift`
  - Adds AFRI-023 coverage for all new correction reasons, rank adjustments, receipt requirements, local-only learning, and You inspection/reset/delete routes.
- `docs/codex/concept-lock-registry.yml`
  - Allows AMB-375 to touch the locked proof/receipt/replay concept for this scoped correction-learning issue.

## Proof

Verified locally:

- Pre implementation guard:
  - `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-375 --prompt /tmp/AMB-375-AFRI-023-guard-prompt.md`
  - Result: Green
- Focused AFRI-023 correction loop test:
  - `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsTests/CorrectionFoldModelsTests/testAFRI023RuntimeTrustCorrectionReasonsProduceLocalInspectableLearning`
  - Result: Red on the first run because the assertion expected unsorted signal-key order; repaired to the existing ordered-unique contract, then Green, 1 test, 0 failures.
- Correction fold domain lane:
  - `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsTests/CorrectionFoldModelsTests`
  - Result: Green, 9 tests, 0 failures
- Runtime replay learning projection:
  - `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsTests/ReplayableDecisionTraceTests/testReplayableDecisionTraceProjectsPersonalRuntimeLearningSignalsFromRejectionLearningInfluence`
  - Result: Green, 1 test, 0 failures
- Personalization factor ledger projection:
  - `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsTests/PersonalizationFactorLedgerTests/testRecommendationRejectionLearningSignalIsProjectedIntoLedger`
  - Result: Green, 1 test, 0 failures
- Post-guard repair cycle:
  - Initial post guard was Red because the changed runtime files did not carry explicit SourceRecord and ReplayTrace inspection language and AMB-375 was not allowed on the proof/receipt/replay lock.
  - Repair added computed SourceRecord/ReplayTrace inspection labels without changing persisted Codable fields and added AMB-375 to the scoped lock allowlist.
- Post implementation guard:
  - `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-375 --prompt /tmp/AMB-375-AFRI-023-guard-prompt.md --changed-from HEAD --changed-path Native/Ambitions/Domain/CorrectionFoldModels.swift --changed-path Native/Ambitions/Domain/RecommendationExplanationModels.swift --changed-path Native/AmbitionsTests/Domain/CorrectionFoldModelsTests.swift --changed-path docs/codex/concept-lock-registry.yml --changed-path docs/proof/afri/afri-023-runtime-trust-correction-loop-proof.md`
  - Result: Green
- Post-repair correction fold domain lane:
  - `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsTests/CorrectionFoldModelsTests`
  - Result: Green, 9 tests, 0 failures
- Post-repair replay and ledger projection:
  - `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsTests/ReplayableDecisionTraceTests/testReplayableDecisionTraceProjectsPersonalRuntimeLearningSignalsFromRejectionLearningInfluence -only-testing:AmbitionsTests/PersonalizationFactorLedgerTests/testRecommendationRejectionLearningSignalIsProjectedIntoLedger`
  - Result: Green, 2 tests, 0 failures
- No-network source check on touched source/test files:
  - `rg -n "URLSession|OpenAI|Analytics|Telemetry|http|https|network|backend|cloud|LLM|remote" Native/Ambitions/Domain/CorrectionFoldModels.swift Native/Ambitions/Domain/RecommendationExplanationModels.swift Native/AmbitionsTests/Domain/CorrectionFoldModelsTests.swift`
  - Result: no matches

## Boundaries

- This is local simulator/unit proof only, not device, signed archive, TestFlight, App Store, release, legal, privacy-review, accessibility, or CI proof.
- This proof covers the correction taxonomy, deterministic learning adjustments, receipt requirement, local-only posture, and inspection/reset/delete route contracts. It does not claim a full user-facing correction UI flow or every future recommendation selector path is complete.
- No cloud AI, hosted backend, analytics, telemetry, or network dependency was added.
