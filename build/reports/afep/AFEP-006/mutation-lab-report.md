# AFEP-006 Mutation Lab Report

Batch: AFEP-006
Branch: main
Starting commit: `0eb5d99478499893b6f7207eba77cfa5fcb5f7f6`
Run directory: `.codex/runs/AFEP-006/20260601T062341Z`
Generated at: `2026-06-01T06:54:46Z`

## Scope

Deterministic mutation fixtures for recommendation and context perturbations, with explicit source, receipt, replay trace, and `You / What Ambitions knows` inspection seams.

## Source Changes

- Added [`Native/Ambitions/Domain/RecommendationMutationLabModels.swift`](/Users/devan/Documents/GitHub/ambitions/Native/Ambitions/Domain/RecommendationMutationLabModels.swift)
- Added [`Native/AmbitionsTests/Domain/RecommendationMutationLabModelsTests.swift`](/Users/devan/Documents/GitHub/ambitions/Native/AmbitionsTests/Domain/RecommendationMutationLabModelsTests.swift)
- Added [`prompts/batches/AFEP-006.md`](/Users/devan/Documents/GitHub/ambitions/prompts/batches/AFEP-006.md)
- Updated [`docs/codex/existing-code-champion-coverage.yml`](/Users/devan/Documents/GitHub/ambitions/docs/codex/existing-code-champion-coverage.yml)
- Updated [`docs/codex/concept-lock-registry.yml`](/Users/devan/Documents/GitHub/ambitions/docs/codex/concept-lock-registry.yml)
- Updated champion coverage outputs under `build/reports/intelligence-consolidation/`.
- Phase 03 repair tightened non-determinism detection so bounded context-driven recommendation changes are not mislabeled as same-input output drift.

## Mutation Lab Model Summary

- `RecommendationMutationLabInspectionSeam` preserves explicit `SourceRecord`, `Receipt`, `ReplayTrace`, and `You / What Ambitions knows` labels on each observation.
- `RecommendationMutationLabVariant` captures one deterministic observation of a recommendation mutation, including the recommendation trace, optional reason graph, optional recommendation and planning counterfactual diffs, replay trace, and context boundary identifiers.
- `RecommendationMutationLabComparison` compares baseline and mutated variants, classifies the shift as stable, needs review, or unstable, and flags missing explanation delta, non-deterministic output, unbounded context, missing reason graph, missing counterfactual evidence, missing inspection seams, and missing replay traces.
- `RecommendationMutationLabReport` aggregates comparison rows and summarizes stable, review-required, and unstable comparisons.

## Validation Evidence

| Command | State | Notes |
| --- | --- | --- |
| `python3 scripts/ambitions-champion-coverage-check.py --batch AFEP-006` | PASS | Registry classification updated for the two new Swift files. |
| `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AFEP-006 --prompt prompts/batches/AFEP-006.md` | PASS | No ownership or runtime wiring violations. |
| `xcodegen generate` | PASS | Project regenerated cleanly. |
| `make xcode-build-for-testing BATCH=AFEP-006` | PASS | Wrapper build passed after Phase 03 repair. |
| `make xcode-focused-test BATCH=AFEP-006 TEST=AmbitionsTests/Domain/RecommendationMutationLabModelsTests` | PASS | Mutation lab focused lane passed after adding bounded-shift and same-input non-determinism coverage. |
| `make xcode-focused-test BATCH=AFEP-006 TEST=AmbitionsTests/Domain/RecommendationExplanationModelsTests` | PASS | Adjacent explanation lane passed after Phase 03 repair. |
| `make xcode-focused-test BATCH=AFEP-006 TEST=AmbitionsTests/Runtime/ReplayableDecisionTraceTests` | PASS | Adjacent replay lane passed after Phase 03 repair. |

Wrapper artifacts:

- `.codex/xcode-summaries/AFEP-006/20260601T065116Z/build-for-testing-summary.json`
- `.codex/xcode-summaries/AFEP-006/20260601T065236Z/focused-test-summary.json`
- `.codex/xcode-summaries/AFEP-006/20260601T065325Z/focused-test-summary.json`
- `.codex/xcode-summaries/AFEP-006/20260601T065406Z/focused-test-summary.json`

## Behavior Proven

- Stable comparisons stay stable when the output fingerprint and inspection seams are bounded.
- Unstable comparisons flag missing explanation delta, non-deterministic output, missing reason graph, missing counterfactual evidence, and unbounded mutation context.
- Bounded recommendation shifts with explicit context deltas and source/receipt/replay inspection seams are accepted as intentional local sensitivity.
- Same-input output drift is still flagged as non-deterministic.
- The lab models remain deterministic, Codable, Sendable, and Equatable.
- The report row preserves the explicit provenance and inspection seams required by the batch prompt.

## Non-Claims

- No release, device, accessibility, privacy, performance, CI, TestFlight, or App Store proof is claimed.
- No cloud AI, backend, analytics, or hosted inference dependency was added.
- No user data mutation path was introduced.

## Rollback

Restore only the AFEP-006 source/report slice if needed:

```bash
git restore -- Native/Ambitions/Domain/RecommendationMutationLabModels.swift Native/AmbitionsTests/Domain/RecommendationMutationLabModelsTests.swift docs/codex/concept-lock-registry.yml docs/codex/existing-code-champion-coverage.yml build/reports/intelligence-consolidation/champion-coverage-check.md build/reports/intelligence-consolidation/champion-coverage-check.json build/reports/afep/AFEP-006/mutation-lab-report.md prompts/batches/AFEP-006.md
```
