# Personal Operating Model

Batch: `IOS26-T04K-B04`

## What changed

- Added a `PersonalRuntimeLearningSignal` model for `momentum_reflow`.
- Wired `StepReallocationEvent` to emit a source-tied momentum-reflow signal with `SourceRecord`, `Receipt`, and `ReplayTrace`.
- Extended `You` memory projection helpers so momentum-reflow learning can be surfaced in `What Ambitions knows` when such signals are available.
- Added deterministic contract coverage for sensitive review, disable/reset/delete, and export/delete boundary behavior.

## What is verified

- The signal model is inspectable and source-tied.
- Sensitive or protected step context can resolve to review-required learning.
- Export and delete selections distinguish whether the related source is included.
- Reset, disable, and delete states exclude the signal from future ranking.
- The signal boundary does not infer medical advice.

## What is not verified

- Xcode build, XCTest, simulator, device, accessibility, performance, CI, TestFlight, App Store, or release proof.
- Runtime persistence of real stored momentum-reflow records in the live app shell.
- End-to-end user interaction proof for the new rows on device.

## Validation posture

- `AMBITIONS_SKIP_XCODE_TESTING=1` is in force for this batch.
- Xcode-based validation was intentionally skipped and must remain a Yellow item.
- Non-Xcode validation remains the only allowed proof lane here.

## Claim boundary

- This batch may claim source and contract changes only.
- It must not claim product completeness, release readiness, accessibility verification, or performance validation.
