# AFEP-010 Golden Correction Cases

Batch: `AFEP-010`
Starting commit: `d7278063cdefd110a5e78ee2c2e01d1e2c74ddc1`

## Case 1: Same Intent, Different Local Reality

Fixture:

- `PersonalizationFactorLedgerTests.testSameBucketDifferentRealityChangesLedgerAndRejectedCandidates`

Expected golden behavior:

- Same goal text can produce different local runtime outputs when schedule, transport, recovery, facility, source freshness, and sensitive-factor permissions differ.
- The constrained context rejects `candidate.recent_drift` and `candidate.safety_constraint`.
- Sensitive safety context remains blocked through `factor.safety_constraint`.
- Replay fingerprints differ because the named local inputs differ.

Acceptance covered:

- deterministic local-context influence
- recovery-aware adaptation posture
- no protected/sensitive inference reuse when runtime use is blocked
- replay packet differentiation

## Case 2: Rejected Recommendation Becomes Inspectable Local Learning

Fixture:

- `PersonalizationFactorLedgerTests.testRecommendationRejectionLearningSignalIsProjectedIntoLedger`

Expected golden behavior:

- A source-tied rejected recommendation correction with `allowsFutureLearning: true` becomes one local runtime learning signal.
- The signal keeps correction record ID, recommendation ID, rejection reason, and adjustment.
- The signal exposes reset, disable, and delete routes under `you://personal-runtime/decision.runtime.learning/...`.
- Visible copy includes the disable route and the inspectable summary.

Acceptance covered:

- corrections can influence later recommendation behavior locally
- learned effects are inspectable and controllable
- reset/disable/delete controls remain source-tied
- You inspection projection remains value-only and export-safe

## Case 3: Reset/Disable/Delete Does Not Become Broad Memory Deletion

Fixtures:

- `CorrectionFoldModelsTests`
- `RecommendationExplanationModelsTests`
- `PersonalizationFactorLedgerTests`

Expected golden behavior:

- Reset removes learning use.
- Disable records disabled reuse distinctly.
- Delete remains explicit and confirmation/provenance bounded.
- Export-safe copy avoids broad destructive-delete claims.

Acceptance covered:

- reversibility
- reset/delete clarity
- proof/receipt/replay provenance
- no silent mutation

## Proof Boundary

These are focused golden cases for AFEP-010. They are not screenshot proof, device proof, release proof, accessibility conformance, privacy/legal approval, CI proof, TestFlight proof, App Store proof, or broad full-suite proof.

## Validation Evidence

- `make xcode-focused-test BATCH=AFEP-010 TEST=AmbitionsTests/CorrectionFoldModelsTests`
  - Status: passed
  - Summary: `.codex/xcode-summaries/AFEP-010/20260601T101411Z/focused-test-summary.json`
- `make xcode-focused-test BATCH=AFEP-010 TEST=AmbitionsTests/InspectableIntelligenceGoldenScenarioTests`
  - Status: passed
  - Summary: `.codex/xcode-summaries/AFEP-010/20260601T101501Z/focused-test-summary.json`
- `make xcode-focused-test BATCH=AFEP-010 TEST=AmbitionsTests/RecommendationExplanationModelsTests`
  - Status: passed
  - Summary: `.codex/xcode-summaries/AFEP-010/20260601T101549Z/focused-test-summary.json`
- `make xcode-focused-test BATCH=AFEP-010 TEST=AmbitionsTests/PersonalizationFactorLedgerTests`
  - Status: passed
  - Summary: `.codex/xcode-summaries/AFEP-010/20260601T102057Z/focused-test-summary.json`
- `make xcode-focused-test BATCH=AFEP-010 TEST=AmbitionsTests/ReplayableDecisionTraceTests`
  - Status: passed
  - Summary: `.codex/xcode-summaries/AFEP-010/20260601T102140Z/focused-test-summary.json`
