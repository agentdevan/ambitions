# AFRI-022 Action Closure Receipt Replay Proof

Status: Green, local simulator proof only
Issue: AMB-374 / AFRI-022
Date: 2026-05-31

## Scope

AFRI-022 connects Today action closure confirmation to receipt history so meaningful closure outcomes persist as local Action Receipt records, retain SourceRecord and ReplayTrace inspection labels, and feed the next local Today recommendation snapshot without shame or silent mutation.

The implementation keeps the existing Today closure grammar and adds the persistence bridge at the Today service boundary. It does not add a cloud service, analytics path, hosted planning runtime, or a new user-facing top-level destination.

## Source Changes

- `Native/Ambitions/Features/Today/TodayActionClosureSheetState.swift`
  - Marks closure sheet state values as `Sendable` for the async Today service boundary.
- `Native/Ambitions/Features/Today/TodayProofReceiptLedgerState.swift`
  - Builds receipt peek state from the same Action Receipt history record used for persistence.
  - Adds stable receipt IDs, proof relevance, local-only privacy posture, changed-fact summaries, SourceRecord language, ReplayTrace language, and You inspection continuity.
- `Native/Ambitions/Services/AppServices.swift`
  - Adds the `TodayServicing.recordActionClosure` contract with a safe warning fallback for preview/non-persistent service implementations.
- `Native/Ambitions/Features/Today/TodayFeatureSnapshot.swift`
  - Persists Today action closure records through `ActionReceiptHistoryRepository`.
  - Projects local receipt feedback into subsequent Today snapshots.
- `Native/Ambitions/Features/Today/TodayViewModel.swift`
  - Confirms action closure outcomes through the service, shows the resulting receipt message, and refreshes the local snapshot.
- `Native/Ambitions/Features/Today/TodayScreen.swift`
  - Routes closure sheet confirmation through the new view model confirmation path.
- `Native/Ambitions/Features/Today/StubTodayService.swift`
  - Implements the new service contract for preview/test stubs.
- `Native/AmbitionsTests/Today/TodayViewModelTests.swift`
  - Adds persisted receipt/replay coverage for Still Counts closure confirmation.
  - Renames older receipt-preview tests to reflect the implemented persistence boundary.
- `docs/codex/concept-lock-registry.yml`
  - Allows AMB-374 to touch the locked proof/receipt/replay concept for this scoped issue.

## Proof

Verified locally:

- Pre implementation guard:
  - `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-374 --prompt /tmp/AMB-374-AFRI-022-guard-prompt.md`
  - Result: Green after repairing the prompt to explicitly require SourceRecord, Receipt, ReplayTrace, and You inspection continuity.
- Focused AFRI-022 unit test:
  - `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsTests/TodayViewModelTests/testAFRI022ActionClosureConfirmationPersistsReceiptAndFeedsLocalReplayInspection`
  - Result: Green, 1 test, 0 failures
- Today unit lane:
  - `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsTests/TodayViewModelTests`
  - Result: Green, 46 tests, 0 failures
- Today UI smoke lane:
  - `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsUITests/AmbitionsUITests/testTodaySurfaceShowsDominantHeroAndPrimaryAction`
  - Result: Green, 1 test, 0 failures
- Post implementation guard:
  - `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-374 --prompt /tmp/AMB-374-AFRI-022-guard-prompt.md --changed-from HEAD --changed-path Native/Ambitions/Features/Today/StubTodayService.swift --changed-path Native/Ambitions/Features/Today/TodayActionClosureSheetState.swift --changed-path Native/Ambitions/Features/Today/TodayFeatureSnapshot.swift --changed-path Native/Ambitions/Features/Today/TodayProofReceiptLedgerState.swift --changed-path Native/Ambitions/Features/Today/TodayScreen.swift --changed-path Native/Ambitions/Features/Today/TodayViewModel.swift --changed-path Native/Ambitions/Services/AppServices.swift --changed-path Native/AmbitionsTests/Today/TodayViewModelTests.swift --changed-path docs/codex/concept-lock-registry.yml`
  - Result: Green after allowing AMB-374 on the scoped proof/receipt/replay lock.

## Boundaries

- This is local simulator/unit/UI proof only, not device, signed archive, TestFlight, App Store, release, legal, privacy-review, or CI proof.
- The proof covers Today action closure persistence and local replay inspection for the tested Still Counts path. It does not claim full Trust Center, Goal Detail, or all-surface receipt UI completion.
- Screenshot export proof is not claimed here. The UI smoke verified the live Today route by accessibility identifiers.
- The proof keeps the receipt history local-first and does not authorize a cloud AI, analytics, telemetry, or backend planning dependency.
