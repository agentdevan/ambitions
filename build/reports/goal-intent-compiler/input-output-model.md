# Goal Intent Compiler Input / Output Model

Batch: `IOS26-T04-B01`
Date: `2026-05-22`

## Scope

Added a deterministic goal intent-to-day compiler value-model seam:

- `GoalIntent`
- `GoalIntentAssumption`
- `GoalIntentClarification`
- `GoalIntentBlockedReason`
- `GoalIntentDayCompilerInput`
- `CompiledStep`
- `CompiledStepReceipt`
- `GoalIntentDayCompilerOutput`

Added mapper helpers from:

- `GoalDraft`
- `GoalCompiledPath`
- `PlanStep`
- `Step`

## Contract Notes

- The contract is local-only and deterministic.
- The contract preserves clear, ambiguous, and blocked states explicitly.
- The contract does not introduce network, cloud, hosted backend, or LLM dependencies.
- The output can round-trip through `Codable` without losing the compiler fields.
- Daily compiled steps can map back into existing `PlanStep` and `Step` shapes.

## Validation

Passed:

- `xcodegen generate`
- `scripts/build-local.sh`
- `scripts/ambitions-xcode-validate.sh --batch IOS26-T04-B01 --lane build-for-testing`
- `make xcode-focused-test BATCH=IOS26-T04-B01 TEST=AmbitionsTests/GoalIntentCompilerModelsTests`

Latest repair-pass evidence:

- Local build log: `output/logs/build-local-20260522-144853.log`
- Build-for-testing summary: `.codex/xcode-summaries/IOS26-T04-B01/20260522T185042Z/build-for-testing-summary.json`
- Focused wrapper summary: `.codex/xcode-summaries/IOS26-T04-B01/20260522T185225Z/focused-test-summary.json`
- Focused wrapper log: `.codex/xcode-logs/IOS26-T04-B01/20260522T185225Z/focused-test.log` executed 5 tests with 0 failures.

## Notes

- `xcodegen generate` and the build wrapper regenerated the project in place, but no tracked project diff remained after the run.
- No device, accessibility, performance, TestFlight, or App Store proof was collected for this batch.
