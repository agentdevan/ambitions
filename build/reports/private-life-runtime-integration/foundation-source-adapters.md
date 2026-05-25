# Foundation Source Adapters

Batch: IOS26-T04K-B01
Scope: Momentum Reflow / Step Time Reallocation source adapters for the canonical Private Life Runtime
Status: Yellow

## Source changes

- Added `StepReallocationEvent` plus the local-only context models `StepReallocationTimeContext`, `StepReallocationMomentumContext`, `StepReallocationPressureImpact`, and `StepReallocationProofImpact` in `Native/Ambitions/Domain/ProjectStepOperationModels.swift`.
- Added `StepReallocationApprovedDecision` so a user-approved reflow decision is the emitter for `StepReallocationEvent`; declined or malformed decisions emit no event.
- Added `StepReallocationSourceAdapter` and `StepReallocationRuntimeInput` in `Native/Ambitions/Domain/ProjectStepOperationModels.swift`.
- The adapter preserves `SourceRecord`, `Receipt`, and `ReplayTrace` on the runtime-input wrapper and converts the approved event into a `PrivateLifeRuntimeKernelDecisionInput`.
- The adapter-derived recommendation trace stays local-only, cites source/receipt/replay IDs, and uses `What Ambitions knows` as the inspection surface.
- The inspection summary exposes the source-adapter boundary without embedding raw history text.

## Test changes

- Added deterministic source-adapter coverage in `Native/AmbitionsTests/Domain/ProjectStepOperationModelsTests.swift`.
- Covered event emission from an approved reflow decision and no event emission from a declined decision.
- Covered inspectability, `SourceRecord`/`Receipt`/`ReplayTrace` preservation, local-only replay, and replay stability until source state changes.
- Covered the no-raw-history inspection boundary by asserting the adapter summary does not leak a marker embedded in source context text.

## Validation

- `python3 scripts/ambitions-champion-coverage-check.py` - passed.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch IOS26-T04K-B01 --prompt prompts/batches/IOS26-T04K-B01-foundation-source-adapters.md` - passed.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch IOS26-T04K-B01 --prompt prompts/batches/IOS26-T04K-B01-foundation-source-adapters.md --changed-from 0202b50fdfa8ac935765fa86ce3e6ed28b1b6c31` - accepted Yellow for `proof_receipt_replay`.
- `python3 scripts/ios26-flagship-preflight.py --batch IOS26-T04K-B01` - passed.
- `python3 scripts/ios26-core-replacement-proof-shape-check.py --batch IOS26-T04K-B01` - passed.
- `swiftc -parse Native/Ambitions/Domain/ProjectStepOperationModels.swift` - passed.
- `swiftc -parse Native/AmbitionsTests/Domain/ProjectStepOperationModelsTests.swift` - passed.

## Validation not run

- Xcode, `xcodebuild`, simulator, device, focused XCTest, UI test, accessibility, performance, CI, TestFlight, App Store, and release lanes were skipped per `AMBITIONS_SKIP_XCODE_TESTING=1`.
- No Xcode proof is claimed from this batch.

## Claims allowed

- The canonical runtime/domain seam now includes source adapters for Momentum Reflow / Step Time Reallocation.
- The adapter is local-only and inspectable through `What Ambitions knows`.
- The preserved source/replay fields and replay stability are covered by deterministic source tests.

## Claims forbidden

- No claim that the app build passed.
- No claim that XCTest, simulator, device, accessibility, performance, CI, TestFlight, App Store, or release proof exists for this batch.
- No claim that Momentum Reflow is fully shipped or universally proven.

## Yellow item

- The batch remains Yellow because the Xcode validation lane is intentionally skipped in this run, so the source adapter is not backed by current app-test execution logs.
