# Source Atlas Runtime Bridge Receipts Replay

Batch: `IOS26-T04C-B04`
Date: `2026-05-23`

## Scope

Added a local-first receipt/replay value-model layer for Source Atlas runtime bridge snapshots.

The new replay snapshot captures:

- raw intent summary with redaction
- selected and rejected pack selection
- selected and rejected path composition
- expanded step candidates
- selected Start Here recommendation summary
- factor ledger fingerprint
- simulation summary
- user correction receipts

## What Changed

- Added `Native/Ambitions/Domain/SourceAtlasBridgeReceiptReplayModels.swift`.
- Added `Native/Ambitions/Runtime/SourceAtlasRuntimeBridgeReplay.swift`.
- Added `Native/AmbitionsTests/Runtime/SourceAtlasRuntimeBridgeReplayTests.swift`.

## Receipt Proof

Verified receipt kinds:

- `sourceAtlasIntentMatched`
- `sourceAtlasPackSelected`
- `sourceAtlasPackRejected`
- `sourceAtlasPathComposed`
- `sourceAtlasPathRejected`
- `sourceAtlasStepCandidatesExpanded`
- `sourceAtlasUnsupportedGoalFallback`
- `sourceAtlasFreshnessBlocked`
- `sourceAtlasUserCorrectionApplied`
- `sourceAtlasReplayGenerated`

The replay snapshot encodes the required receipts in a deterministic order and redacts sensitive raw intent and custom correction text.

## Replay Proof

- The replay snapshot stores the selected recommendation summary and simulation summary from the generated `StepCandidateField`.
- The replay snapshot preserves the factor ledger replay fingerprint from `PersonalizationFactorLedger.replayProjection.stableFingerprint`.
- The replay snapshot preserves selected and rejected path IDs and selected and rejected pack IDs.
- The replay snapshot remains local-only.

## Validation

Verified:

- `make xcode-focused-test BATCH=IOS26-T04C-B04 TEST=AmbitionsTests/SourceAtlasRuntimeBridgeReplayTests`
- `make xcode-focused-test BATCH=IOS26-T04C-B04 TEST=AmbitionsTests/ReplayableDecisionTraceTests`
- `make xcode-focused-test BATCH=IOS26-T04C-B04 TEST=AmbitionsTests/StepCandidateFieldGeneratorTests`
- `make xcode-focused-test BATCH=IOS26-T04C-B04 TEST=AmbitionsTests/SourceAtlasCapabilityPathCompositionModelsTests`
- `make xcode-focused-test BATCH=IOS26-T04C-B04 TEST=AmbitionsTests`

Blocked / not yet green:

- `make xcode-focused-test BATCH=IOS26-T04C-B04 TEST=AmbitionsUITests`

The UI lane is still exhibiting the existing `TodayStartHereShowAnother` wait pattern and repeated idle-notification retries, so it cannot be claimed Green from this batch.

Accepted Yellow:

- Owner: `Today/UITest reliability owner`
- Safety reason: B04 only adds local-first value models, replay construction, and unit tests; it does not change Today UI, shell routing, accessibility identifiers, app lifecycle, or user-facing navigation.
- No-claim boundary: UI regression proof, accessibility proof, device proof, release readiness, and performance proof are not claimed by this batch.
- Follow-up gate: repair the existing `TodayStartHereShowAnother` UI wait/idle-notification lane before using B04 as full UI regression evidence.

## Claims Allowed

- Source Atlas runtime bridge replay value models exist.
- Required Source Atlas bridge receipt kinds are represented.
- Sensitive raw intent and custom correction text are redacted in encoded replay payloads.
- Path correction can deterministically change selected path and candidate output.

## Claims Forbidden

- UI regression proof.
- accessibility proof.
- release readiness.
- device proof.
- privacy/legal approval.
- performance proof.

## Rollback Notes

Rollback only files touched by IOS26-T04C-B04:

- `Native/Ambitions/Domain/SourceAtlasBridgeReceiptReplayModels.swift`
- `Native/Ambitions/Runtime/SourceAtlasRuntimeBridgeReplay.swift`
- `Native/AmbitionsTests/Runtime/SourceAtlasRuntimeBridgeReplayTests.swift`
- `build/reports/source-atlas-runtime-bridge/receipts-replay.md`
