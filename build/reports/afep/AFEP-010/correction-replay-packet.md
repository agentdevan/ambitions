# AFEP-010 Correction Replay Packet

Batch: `AFEP-010`
Starting commit: `d7278063cdefd110a5e78ee2c2e01d1e2c74ddc1`

## Scope

AFEP-010 extends the existing correction, recommendation trace, runtime ledger, replay, and You inspection owners. It does not add a parallel correction engine, learning engine, recommendation engine, proof ledger, receipt ledger, replay engine, runtime snapshot path, privacy class system, persistence owner, or You inspection owner.

## Replay Packet

Named local replay inputs:

- Runtime decision key: `today.start-here`
- Local runtime mode: `localOnly`
- Source route: `source.local`
- Recommendation route: `RecommendationTrace.rejectionLearningInfluences`
- Correction record route: `CorrectionFoldRecord.recommendation`
- Learning influence route: `CorrectionFoldRecommendationLearningInfluence`
- Runtime ledger route: `PersonalizationFactorLedger.personalRuntimeLearningSignals`
- Replay route: `PersonalizationFactorLedger.replayProjection.stableFingerprint`
- You inspection route: `you://personal-runtime/<recommendationID>/reset`
- You disable route: `you://personal-runtime/<recommendationID>/disable`
- You delete route: `you://personal-runtime/<recommendationID>/delete`

The focused runtime fixture `PersonalizationFactorLedgerTests.testRecommendationRejectionLearningSignalIsProjectedIntoLedger` records a rejected recommendation correction with `allowsFutureLearning: true`, projects it into the local runtime ledger, and asserts source-tied reset, disable, delete, visible copy, and inspectable/control labels.

The focused runtime fixture `PersonalizationFactorLedgerTests.testSameBucketDifferentRealityChangesLedgerAndRejectedCandidates` preserves the Private Life Runtime moat proof target by asserting that the same intent with different local context changes cadence, milestone, Start Here explanation, explanation summary, rejected candidate IDs, replay fingerprint, and sensitive-factor blocking.

## Replay Boundaries

- Replay evidence is local-source and focused-test evidence only.
- The packet does not claim full-suite proof, device proof, screenshot proof, release readiness, privacy/legal approval, accessibility conformance, TestFlight readiness, App Store readiness, or CI proof.
- If the replay fingerprint diverges for the same named inputs, AFEP-010 must roll back to the existing AFRI correction, proof, recommendation, and recovery routes and disable elevated correction learning.

## Validation Evidence

Repair-pass validation evidence:

- `python3 scripts/ambitions-champion-coverage-check.py`
  - Status: `GREEN`
  - Report: `build/reports/intelligence-consolidation/champion-coverage-check.md`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AFEP-010 --prompt prompts/batches/AFEP-010.md`
  - Status: `GREEN`
  - Report: `build/reports/parallel-implementation-guard/AFEP-010-pre.md`
- `xcodegen generate`
  - Status: passed
- `make xcode-build-for-testing BATCH=AFEP-010`
  - Status: passed
  - Current summary: `.codex/xcode-summaries/AFEP-010/20260601T102004Z/build-for-testing-summary.json`
- `make xcode-focused-test BATCH=AFEP-010 TEST=AmbitionsTests/PersonalizationFactorLedgerTests`
  - Status: passed after repairing stale equality assumptions while preserving runtime differentiation assertions
  - Current summary: `.codex/xcode-summaries/AFEP-010/20260601T102057Z/focused-test-summary.json`
- `make xcode-focused-test BATCH=AFEP-010 TEST=AmbitionsTests/ReplayableDecisionTraceTests`
  - Status: passed
  - Current summary: `.codex/xcode-summaries/AFEP-010/20260601T102140Z/focused-test-summary.json`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AFEP-010 --prompt prompts/batches/AFEP-010.md --changed-from d7278063cdefd110a5e78ee2c2e01d1e2c74ddc1`
  - Status: `GREEN`
  - Report: `build/reports/parallel-implementation-guard/AFEP-010-post.md`
- `git diff --check`
  - Status: passed
