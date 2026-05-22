# IOS26-T04-B02 Capacity-Aware Compilation

Batch: `IOS26-T04-B02`
Branch: `main`
Starting commit: `45028d344d8ff7ce8c549a28f4bc7262be86427b`

## Scope

- Added a local capacity envelope to the goal intent day compiler contract.
- Adjusted emitted compiled steps deterministically for normal, low-capacity, protected-time conflict, and recovery contexts.
- Kept the change local-only and confined to compiler models plus focused tests.

## Files Changed

- `Native/Ambitions/Domain/GoalEngine/GoalIntentCompilerModels.swift`
- `Native/AmbitionsTests/Domain/GoalIntentCompilerModelsTests.swift`
- `build/reports/goal-intent-compiler/capacity-aware-compilation.md`

## Validation

Passed:

```bash
xcodegen generate
scripts/build-local.sh
make xcode-focused-test BATCH=IOS26-T04-B02 TEST=AmbitionsTests/GoalIntentCompilerModelsTests
scripts/ambitions-xcode-validate.sh --batch IOS26-T04-B02 --lane focused-test --test AmbitionsTests/GoalIntentCompilerModelsTests
make xcode-build-for-testing BATCH=IOS26-T04-B02
scripts/ambitions-xcode-validate.sh --batch IOS26-T04-B02 --lane focused-test --test AmbitionsTests/GoalIntentCompilerModelsTests
```

## Evidence

- `xcodegen generate` completed successfully.
- `scripts/build-local.sh` completed successfully with `Build Succeeded`.
- The focused test lane passed for `AmbitionsTests/GoalIntentCompilerModelsTests`.
- The explicit validation script also returned `xcode validation passed`.
- Review reran `build-for-testing` before the final focused-test pass so `test-without-building` used a current test bundle.
- The final focused-test log executed 8 tests, including the low-capacity, protected-time conflict, and recovery capacity cases.

## Notes

- No UI, persistence, networking, calendar-write, backend, or dependency changes were made.
- Accessibility and device-level proof were not part of this batch.
- The compiler now carries capacity-envelope context into output receipts and step synthesis.
