# IOS26-T04B-B04 Approval, Receipts, and Learning

## Scope

Implemented the bounded approval/receipt learning slice in:
- `Native/Ambitions/Domain/ActionClosureReceiptModels.swift`
- `Native/Ambitions/Runtime/StepCandidateFieldGenerator.swift`
- `Native/Ambitions/Runtime/ReplayableDecisionTraceModels.swift`
- `Native/Ambitions/Features/Today/TodayFeatureSnapshot.swift`

Updated tests in:
- `Native/AmbitionsTests/Domain/ActionClosureReceiptModelsTests.swift`
- `Native/AmbitionsTests/Runtime/StepCandidateFieldGeneratorTests.swift`
- `Native/AmbitionsTests/Runtime/ReplayableDecisionTraceTests.swift`
- `Native/AmbitionsTests/Today/TodayViewModelTests.swift`
- `Native/AmbitionsTests/Persistence/ActionReceiptHistoryRepositoryTests.swift`

## What Changed

- Added receipt kinds for rejection, reason saving, alternate generation and approval, deadline pressure, on-track, at-risk, scope review, suppression, and learning.
- Added local approval gating for material timeline pressure in step-candidate generation.
- Added replayable decision-trace receipt facts so local receipt evidence can reconstruct the decision boundary.
- Routed Today rejection handling through the new `stepRejectedReceipt` semantics and preserved feedback lookup for legacy rejection facts.
- Kept rejection reasons and learning local-first and redacted from projection output.

## Validation

### Passed

- `make xcode-focused-test BATCH=IOS26-T04B-B04 TEST=AmbitionsTests`
- `make xcode-focused-test BATCH=IOS26-T04B-B04 TEST=AmbitionsTests/Domain/ActionClosureReceiptModelsTests`
- `make xcode-focused-test BATCH=IOS26-T04B-B04 TEST=AmbitionsTests/Runtime/StepCandidateFieldGeneratorTests`

The full unit lane passed with:
- `1658 tests, 0 failures`

### Not fully verified

- `make xcode-focused-test BATCH=IOS26-T04B-B04 TEST=AmbitionsUITests`

The UI lane still fails on pre-existing issues in `Native/AmbitionsUITests/AmbitionsUITests.swift`:
- line 414 in `testCapturePromotionOpensComposerWithSeededText`
- line 283 in `testDemoGoalsAtlasLoadsCoreModules`

The standalone replay-trace focused lane was attempted, but the wrapper did not return a final summary in time; the broader `AmbitionsTests` lane already covered the replay code path.

## Proof Boundaries

- No cloud dependency added.
- No LLM dependency added.
- No top-level IA change.
- No silent plan mutation introduced.
- No sensitive rejection text emitted in projections.
- No unrelated proof JSON files were modified.

## Rollback

If this slice needs to be reverted, restore only the touched source/test files and delete this report file.
