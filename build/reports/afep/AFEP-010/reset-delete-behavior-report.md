# AFEP-010 Reset/Delete Behavior Report

Batch: `AFEP-010`
Starting commit: `d7278063cdefd110a5e78ee2c2e01d1e2c74ddc1`

## Reset, Disable, Delete Boundary

AFEP-010 keeps correction learning reversible through existing value-model and You inspection routes:

- `CorrectionFoldCorrectedLearningInput.reset` removes the learning input from future use.
- `CorrectionFoldCorrectedLearningInput.disableSignal` disables source-tied reuse without deleting the underlying correction route.
- `CorrectionFoldCorrectedLearningInput.delete` keeps destructive behavior explicit and receipt-backed.
- `CorrectionFoldReceiptAction.disabled` separates disable receipts from reset receipts.
- `PersonalRuntimeLearningSignal.personalRuntimeResetRoute` points to a source-tied reset route.
- `PersonalRuntimeLearningSignal.personalRuntimeDisableRoute` points to a source-tied disable route.
- `PersonalRuntimeLearningSignal.personalRuntimeDeleteRoute` points to a source-tied delete route.
- `YouFeatureService` projects reset, disable, and delete copy without claiming broad destructive delete.

## Behavior Provenance

The current source route keeps reset/delete behavior provenance-aware:

- Correction records remain `CorrectionFoldRecord` values.
- Recommendation influence remains attached through `RecommendationTrace.rejectionLearningInfluences`.
- Local runtime projection remains in `PersonalizationFactorLedger.personalRuntimeLearningSignals`.
- You inspection copy remains source-tied and export-safe.

## Explicit Non-Claims

This report does not claim:

- broad deletion of all Ambitions memory
- silent mutation of recommendations, profile facts, proof, closure, receipts, or runtime snapshots
- irreversible learning
- privacy/legal approval
- accessibility conformance
- release readiness
- device, TestFlight, App Store, CI, or full-suite proof

## Rollback Boundary

If reset, disable, delete, provenance, redaction, export-safe behavior, or deterministic influence evidence fails, disable AFEP-010 elevated correction learning and continue through the existing AFRI correction, proof, recommendation, and recovery routes.

## Validation Evidence

- `make xcode-focused-test BATCH=AFEP-010 TEST=AmbitionsTests/CorrectionFoldModelsTests`
  - Status: passed
  - Summary: `.codex/xcode-summaries/AFEP-010/20260601T101411Z/focused-test-summary.json`
- `make xcode-focused-test BATCH=AFEP-010 TEST=AmbitionsTests/RecommendationExplanationModelsTests`
  - Status: passed
  - Summary: `.codex/xcode-summaries/AFEP-010/20260601T101549Z/focused-test-summary.json`
- `make xcode-focused-test BATCH=AFEP-010 TEST=AmbitionsTests/PersonalizationFactorLedgerTests`
  - Status: passed
  - Summary: `.codex/xcode-summaries/AFEP-010/20260601T102057Z/focused-test-summary.json`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AFEP-010 --prompt prompts/batches/AFEP-010.md --changed-from d7278063cdefd110a5e78ee2c2e01d1e2c74ddc1`
  - Status: `GREEN`
  - Report: `build/reports/parallel-implementation-guard/AFEP-010-post.md`
