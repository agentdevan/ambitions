# IOS26 Calendar P0 Contract Harness

Status: Green

## Files changed
- `Native/AmbitionsTests/Domain/IOS26CalendarP0ContractHarnessTests.swift`
- `build/reports/core-replacement-contracts/calendar-p0-contract-harness.md`

## User jobs covered
- Calendar scheduling job
- Time Operations contract seam
- Today consumption of calendar-aware reality snapshots

## Replacement P0 gates
- Scheduled blocks: covered by `ScheduledAmbitionsBlock` and `RealityModelProjector`
- Recurrence: tracked as a required evidence gate in the harness fixture; still blocks broad replacement claims
- EventKit permission: covered by `CalendarDerivedContext`
- Denied fallback: covered by the denied-context projection test
- Conflicts: covered by `RealityModelProjector` conflict summaries
- Protected/free time: covered by protected windows and capacity estimates
- Schedule receipts: covered by `RealityIntegrationAdapter.calendarBlockScheduledEntry`
- Today consumption: covered by the live Today-facing reality snapshot seam in source and the contract fixture
- Replay/privacy boundaries: covered by local-only / privacy assertions on the projected snapshot and ledger entries
- Unsupported broad claims: blocked by the harness fixture

## Tests run
- `python3 scripts/ios26-flagship-preflight.py --batch IOS26-T04E-B01` -> Green
- `python3 scripts/ios26-core-replacement-contract-check.py` -> Green
- `python3 scripts/ios26-core-replacement-proof-shape-check.py --batch IOS26-T04E-B01 --require-existing --artifact build/reports/core-replacement-contracts/calendar-p0-contract-harness.md` -> Green
- `make xcode-build-for-testing BATCH=IOS26-COMPILE-DEBT-REPAIR` -> Green after narrow compile-debt repairs
- `make xcode-build-for-testing BATCH=IOS26-T04E-B01` -> Green
- `make xcode-focused-test BATCH=IOS26-T04E-B01 TEST=AmbitionsTests/IOS26CalendarP0ContractHarnessTests` -> Green; executed 3 tests with 0 failures
- `scripts/ambitions-xcode-benchmark.sh --status` -> installed; timing-helper availability only
- Scenario count: 3 XCTest-validated harness scenarios

## Validation not run
- No raw `xcodebuild` lane was run directly; validation used repo wrappers.
- Full app behavior replacement proof was not run; this batch is a contract harness.
- Simulator UI, device, release archive, accessibility audit, privacy/legal approval, and performance measurement were not run.

## Accessibility status
- Not claimed by this batch
- No accessibility verification was performed

## Privacy/local-first status
- Local-first contract gate only
- No cloud LLM, hosted user-data backend, or external analytics was introduced
- No privacy approval is claimed

## Performance status
- Not measured by this batch
- No performance validation is claimed

## Claims allowed
- Calendar P0 contract harness source exists
- Calendar P0 contract harness executed through the repo Xcode wrapper
- Broad Calendar replacement claims are represented as blocked in the source-present harness unless the required evidence is present
- Source-backed schedule, denial fallback, conflict, protected-time, receipt, and privacy boundary assertions are present in test source
- The harness remains contract-only and does not change app behavior

## Claims forbidden
- release-ready
- App Store-ready
- TestFlight-ready
- fully accessible
- performance validated
- privacy approved
- Any claim that Calendar replacement is complete
- Any claim that this batch changed app behavior

## Yellow/Red items
- Yellow: recurrence stays as a required evidence gate in the harness and is not promoted as implementation proof
- Yellow: Today consumption is recorded as a contract seam, not as a full runtime proof claim
- Red: none observed in the bounded patch surface
