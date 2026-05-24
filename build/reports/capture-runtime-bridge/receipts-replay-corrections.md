# Capture Runtime Receipts, Replay, and Corrections

Batch: `IOS26-T04D-B05`

## Scope

Added a local-only capture runtime receipt and replay value layer:

- `CaptureRuntimeReceiptKind`
- `CaptureRuntimeCorrectionKind`
- `CaptureRuntimeCorrectionInput`
- `CaptureRuntimeUseStatus`
- `CaptureRuntimeProposedDestination`
- `CaptureRuntimeUserDecision`
- `CaptureRuntimeFutureUse`
- `CaptureRuntimeReceipt`
- `CaptureRuntimeReplayTrace`

The new layer is a deterministic extension on `SmartAttachmentResult` and does not add cloud, LLM, analytics, calendar mutation, or silent goal attachment behavior.

## Behavior Implemented

- Reconstructs a replay trace from the existing Smart Attachment result payload.
- Preserves raw capture, semantic extraction, ambiguity, relevance scan, proposed destinations, user decision, runtime-use status, receipt, and future-use summary.
- Emits the required receipt kinds:
  - `captureExtracted`
  - `captureNeedsClarification`
  - `captureMatchedGoal`
  - `captureWeakMatchRejected`
  - `captureSavedAsFutureContext`
  - `captureProposedForTime`
  - `captureAddedToTime`
  - `captureAttachedToGoal`
  - `captureSavedAsProof`
  - `captureRuntimeUsePaused`
  - `captureCorrectionApplied`
  - `captureReplayGenerated`
- Supports pure correction inputs for:
  - wrong activity
  - wrong time
  - wrong goal
  - do not use for planning
  - save only as note
  - attach to different goal
  - delete context
- Corrections are deterministic and only affect the replay/future-use projection.
- Sensitive capture text is redacted in the receipt when privacy requires it.

## Validation

Passed:

- `git diff --check -- Native/Ambitions/Domain/CaptureRuntimeReceipt.swift Native/AmbitionsTests/Domain/CaptureRuntimeReceiptTests.swift build/reports/capture-runtime-bridge/receipts-replay-corrections.md`
- `make xcode-focused-test BATCH=IOS26-T04D-B05 TEST=AmbitionsTests`
  - Summary: `.codex/xcode-summaries/IOS26-T04D-B05/20260524T035032Z/focused-test-summary.json`
  - Status: passed
  - Log: `.codex/xcode-logs/IOS26-T04D-B05/20260524T035032Z/focused-test.log`
- `make xcode-focused-test BATCH=IOS26-T04D-B05 TEST=CaptureRuntimeReceiptTests`
  - Summary: `.codex/xcode-summaries/IOS26-T04D-B05/20260524T040413Z/focused-test-summary.json`
  - Status: passed
  - Log: `.codex/xcode-logs/IOS26-T04D-B05/20260524T040413Z/focused-test.log`

Blocked / yellow:

- `make xcode-focused-test BATCH=IOS26-T04D-B05 TEST=AmbitionsUITests`
  - Current log: `.codex/xcode-logs/IOS26-T04D-B05/20260524T035557Z/focused-test.log`
  - Existing failures observed in the harness path:
    - `AmbitionsUITests.swift:536` in `testCapturePromotionOpensComposerWithSeededText`
    - `AmbitionsUITests.swift:405` in `testDemoGoalsAtlasLoadsCoreModules`
    - `AmbitionsUITests.swift:160` in `testPreviewBootstrapExposesCanonicalFiveTabShellAndSecondarySurfaces`
  - The UI lane did not provide batch-specific proof for this receipt slice.

## Claims

Allowed:

- Capture replay can be reconstructed locally from the Smart Attachment result.
- Corrections are pure value transformations that change future routing projections.
- The receipt redaction boundary is local and inspectable.

Forbidden:

- Release readiness
- UI automation proof
- Device proof
- Accessibility proof
- Calendar write proof
- Goal attachment mutation proof
- Cloud or analytics dependency claims
