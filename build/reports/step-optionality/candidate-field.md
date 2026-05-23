# Step Candidate Field Proof

Batch: `IOS26-T04B-B01`
Date: `2026-05-23`

## What changed

- Added the local-first candidate field model layer in `Native/Ambitions/Domain/GoalEngine/StepCandidateFieldModels.swift`.
- Added deterministic candidate generation in `Native/Ambitions/Runtime/StepCandidateFieldGenerator.swift`.
- Added focused tests in `Native/AmbitionsTests/Domain/StepCandidateFieldModelsTests.swift`.
- Added focused tests in `Native/AmbitionsTests/Runtime/StepCandidateFieldGeneratorTests.swift`.

## Verified claims

- Multiple real candidates are generated for the same goal when compiler output is present.
- Candidate duplicates are removed by a stable normalized semantic signature, not by title comparison alone.
- Candidate ranking is deterministic for the same input.
- Candidate ranking uses `PersonalizationFactorLedger` evidence when available.
- Missing context degrades to fallback/review-safe candidates instead of pretending certainty.
- Replay metadata is preserved through the ranking trace without carrying raw sensitive text into the field payload.

## Validation run

- `make xcode-focused-test BATCH=IOS26-T04B-B01 TEST=AmbitionsTests/StepCandidateFieldModelsTests`
- `make xcode-focused-test BATCH=IOS26-T04B-B01 TEST=AmbitionsTests/StepCandidateFieldGeneratorTests`
- `make xcode-focused-test BATCH=IOS26-T04B-B01 TEST=AmbitionsTests/ReplayableDecisionTraceTests`

## Validation results

- `AmbitionsTests/StepCandidateFieldModelsTests`: passed
- `AmbitionsTests/StepCandidateFieldGeneratorTests`: passed
- `AmbitionsTests/ReplayableDecisionTraceTests`: passed
- `AmbitionsTests`: passed
- `AmbitionsUITests`: failed with 5 existing UI test failures in the Today / You surface lane

## Claim boundaries

- No release-readiness claim.
- No accessibility proof claim.
- No device proof claim.
- No performance proof claim.
- No privacy/legal approval claim.
- No UI feature-shipped claim beyond the model/runtime field proof.

## Notes

- The UI failure is outside the approved candidate-field slice and is visible in the existing UI test log stream.
- The new candidate field remains source-local and deterministic.
