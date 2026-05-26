# Foundation Source Adapters

Batch: IOS26-T04K-B01
Scope: Runtime bridge for Momentum Reflow / Step Time Reallocation source adapters
Status: Yellow

## Source changes

- Added `StepReallocationRuntimeBridge` in `Native/Ambitions/Runtime/StepReallocationRuntimeBridge.swift`.
- Added runtime-focused tests in `Native/AmbitionsTests/Runtime/StepReallocationRuntimeBridgeTests.swift`.
- `StepReallocationRuntimeBridge`:
  - Converts approved `StepReallocationApprovedDecision` to local runtime input via `StepReallocationSourceAdapter`.
  - Converts source adapters to replayable runtime inputs and `ReplayTrace` outputs.
  - Preserves `SourceRecord` and `ReplayTrace` fields for `What Ambitions knows` inspection.

## Validation

- `python3 scripts/ios26-flagship-preflight.py --batch IOS26-T04K-B01` - passed.
- `python3 scripts/ios26-core-replacement-proof-shape-check.py --batch IOS26-T04K-B01` - passed.
- `swiftc -parse Native/Ambitions/Runtime/StepReallocationRuntimeBridge.swift` - passed.
- `make xcode-build-for-testing BATCH=IOS26-T04K-B01` - failed.
  - Failure category: compile failure in existing unrelated app target file.
  - Observed compile error: `Native/Ambitions/Services/MemoryLensService.swift:345:80` ambiguous `+` operator.
  - Failure prevented focused runtime test execution.
- `make xcode-focused-test BATCH=IOS26-T04K-B01 TEST=AmbitionsTests/Runtime/StepReallocationRuntimeBridgeTests` - failed.
  - Initial attempt failed with simulator launch bundle ID issue.
  - Retried after simulator/DerivedData repair; second attempt still failed because build-for-testing did not produce a launchable Ambitions test app.

## Validation not run

- Focused XCTest execution for assertions is blocked by build/test infra in this phase.
- No accessibility, privacy/legal, performance, simulator UI, device proof, release, CI, TestFlight, or App Store claims are made in this batch.

## Claims allowed

- The runtime bridge is added for Momentum Reflow / Step Time Reallocation adapters and wired through local runtime kernel conversion.
- The bridge preserves source/replay context and produces local replayable decision traces.
- Proof/behavioral claims are limited to the command outputs and logs collected in this phase.

## Claims forbidden

- No claim that Momentum Reflow runtime is fully proven in app flow for this batch.
- No release-readiness, TestFlight, App Store, accessibility, privacy/legal, or performance claims without matching proof.

## Yellow item

- Build/validation remains Yellow due an unrelated compile blocker in `Native/Ambitions/Services/MemoryLensService.swift` preventing focused test execution for this batch.
