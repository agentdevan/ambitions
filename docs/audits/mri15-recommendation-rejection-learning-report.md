# MRI15 Recommendation Rejection Learning Report

Status: Green
Date: 2026-05-13
Branch: `main`
Starting commit: `6a767fea1ce7b59088d49945c282e29ce61b4a5b`

## Operating System

Inspectable Intelligence Engine.

## Product Loop

Source-to-recommendation.

## Source Truth Inspected

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`
- `.codex/state/active-batch.yml`
- `.codex/reports/current-run-state.md`
- `prompts/batches/MRI15-RECOMMENDATION-REJECTION-LEARNING.md`
- `docs/codex/MOAT_RUNTIME_INTEGRATION_MASTER_PLAN.md`
- `docs/codex/MOAT_RUNTIME_LOOP_MATRIX.md`
- `docs/codex/MOAT_RUNTIME_ACCEPTANCE_CRITERIA.md`
- `docs/codex/MOAT_RUNTIME_GOLDEN_SCENARIOS.md`
- `docs/codex/MOAT_RUNTIME_BATCH_OVERLAY.json`
- `Native/Ambitions/Domain/CorrectionFoldModels.swift`
- `Native/Ambitions/Domain/RecommendationExplanationModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSRecommendationStartHereModels.swift`
- `Native/AmbitionsTests/Domain/CorrectionFoldModelsTests.swift`
- `Native/AmbitionsTests/Domain/RecommendationExplanationModelsTests.swift`
- `Native/AmbitionsTests/Domain/AmbitionsOSRecommendationStartHereModelsTests.swift`

## Files Changed

- `Native/Ambitions/Domain/CorrectionFoldModels.swift`
- `Native/Ambitions/Domain/RecommendationExplanationModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSRecommendationStartHereModels.swift`
- `Native/AmbitionsTests/Domain/CorrectionFoldModelsTests.swift`
- `Native/AmbitionsTests/Domain/RecommendationExplanationModelsTests.swift`
- `Native/AmbitionsTests/Domain/AmbitionsOSRecommendationStartHereModelsTests.swift`
- `docs/audits/mri15-recommendation-rejection-learning-report.md`

## Loop Behavior Added

- Added an explicit Start Here `reject` control action and a value-model helper that creates a structured local recommendation correction record.
- Added inspectable rejection-learning influence modeling for structured reasons: wrong goal, wrong time, too large, already done, wrong source, and low energy/context.
- Rejection learning remains local-only, receipt-linked, reset/delete-compatible, and non-silent.
- `RecommendationTrace` can now carry rejection-learning influences and expose exact suppression or similar-recommendation downranking without mutating plans automatically.
- Review repair added a compatibility decoder so legacy `RecommendationTrace` payloads without rejection-learning keys decode with an empty influence list.

Still deferred:

- No persistence writer for rejection records was added.
- No SwiftUI rejection picker or You reset/delete surface was added.
- No end-to-end runtime recommendation engine ranking behavior is claimed beyond the tested value-model contracts.

## EFC Applicability

Invoked. MRI15 touches local intelligence, recommendation behavior, user control, receipt/reset/delete compatibility, source-to-recommendation behavior, and claim boundaries. The patch stays value-model-only and local-first.

## Validation

Phase 04 repair pass reran the focused validation lane after the review compatibility decoder repair:

- `xcrun swiftc -parse Native/Ambitions/Domain/CorrectionFoldModels.swift Native/Ambitions/Domain/RecommendationExplanationModels.swift Native/Ambitions/Domain/AmbitionsOSRecommendationStartHereModels.swift Native/AmbitionsTests/Domain/CorrectionFoldModelsTests.swift Native/AmbitionsTests/Domain/RecommendationExplanationModelsTests.swift Native/AmbitionsTests/Domain/AmbitionsOSRecommendationStartHereModelsTests.swift`
  - Exit code: `0`
  - Result: parse passed for touched source/test files.
- `xcodegen generate`
  - Exit code: `0`
  - Result: project generated.
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/CorrectionFoldModelsTests -only-testing:AmbitionsTests/RecommendationExplanationModelsTests -only-testing:AmbitionsTests/AmbitionsOSRecommendationStartHereModelsTests test CODE_SIGNING_ALLOWED=NO`
  - Result: not executed by shell; rejected before launch by outer policy with `approval required by policy, but AskForApproval is set to Never`.
- Parallel wrapper attempt for `AmbitionsTests/CorrectionFoldModelsTests`
  - Result: interrupted after `xcodebuild test-without-building` hung without output; rerun singly below passed.
- `scripts/ambitions-xcode-validate.sh --batch MRI15-RECOMMENDATION-REJECTION-LEARNING --lane focused-test --test AmbitionsTests/CorrectionFoldModelsTests`
  - Exit code: `0`
  - Result: xcode validation passed.
  - Phase 04 summary: `.codex/xcode-summaries/MRI15-RECOMMENDATION-REJECTION-LEARNING/20260513T111727Z/validate-summary.json`
- `scripts/ambitions-xcode-validate.sh --batch MRI15-RECOMMENDATION-REJECTION-LEARNING --lane focused-test --test AmbitionsTests/RecommendationExplanationModelsTests`
  - Exit code: `0`
  - Result: xcode validation passed.
  - Phase 04 summary: `.codex/xcode-summaries/MRI15-RECOMMENDATION-REJECTION-LEARNING/20260513T111905Z/validate-summary.json`
- `scripts/ambitions-xcode-validate.sh --batch MRI15-RECOMMENDATION-REJECTION-LEARNING --lane focused-test --test AmbitionsTests/AmbitionsOSRecommendationStartHereModelsTests`
  - Exit code: `0`
  - Result: xcode validation passed.
  - Phase 04 summary: `.codex/xcode-summaries/MRI15-RECOMMENDATION-REJECTION-LEARNING/20260513T112102Z/validate-summary.json`
- `git diff --check`
  - Exit code: `0`
  - Result: passed.
- `python3 scripts/ambitions-state-advance-validate.py || true`
  - Effective shell exit code: `0`
  - Output: `GREEN: state advancement coherent; current=SA16 Source Container Model; next=SA17 URL Source Importer`
- `python3 scripts/ambitions-unsupported-claim-scan.py Native/Ambitions/Domain/CorrectionFoldModels.swift Native/Ambitions/Domain/RecommendationExplanationModels.swift Native/Ambitions/Domain/AmbitionsOSRecommendationStartHereModels.swift Native/AmbitionsTests/Domain/CorrectionFoldModelsTests.swift Native/AmbitionsTests/Domain/RecommendationExplanationModelsTests.swift Native/AmbitionsTests/Domain/AmbitionsOSRecommendationStartHereModelsTests.swift docs/audits/mri15-recommendation-rejection-learning-report.md 2>/dev/null || true`
  - Effective shell exit code: `0`
  - Output: `GREEN: unsupported completion/readiness claim scan passed`

## Claims Not Made

- No release readiness claim.
- No TestFlight readiness claim.
- No App Store readiness claim.
- No device proof claim.
- No public accessibility conformance claim.
- No performance validation claim.
- No privacy/legal approval claim.
- No visual runtime completion claim.
- No global train completion claim.
- No hosted personal-data backend claim.
- No external/cloud model runtime claim.
- No automatic plan mutation claim.

## Rollback Notes

Rollback this phase only:

```bash
git restore -- Native/Ambitions/Domain/CorrectionFoldModels.swift Native/Ambitions/Domain/RecommendationExplanationModels.swift Native/Ambitions/Domain/AmbitionsOSRecommendationStartHereModels.swift Native/AmbitionsTests/Domain/CorrectionFoldModelsTests.swift Native/AmbitionsTests/Domain/RecommendationExplanationModelsTests.swift Native/AmbitionsTests/Domain/AmbitionsOSRecommendationStartHereModelsTests.swift docs/audits/mri15-recommendation-rejection-learning-report.md
```

## Next Handoff

MRI16 can use these value-model contracts for golden tests around source-backed recommendation correction, visible rejection reasons, reset/delete learning controls, and Why This? behavior. Any UI or persistence pass should wire this through explicit receipts and controls without hidden tracking or automatic plan mutation.
