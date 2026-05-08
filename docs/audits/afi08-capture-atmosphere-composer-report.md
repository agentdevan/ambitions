# AFI08 Capture Atmosphere Composer Report

<!-- markdownlint-disable MD013 -->

Date: 2026-05-08
Status: Accepted Yellow
Batch: AFI08 Capture Atmosphere Composer

## Result

AFI08 aligned Capture with active AFI source truth: Capture Anything /
Atmosphere Composer, with route reveal still gated behind user input and the
approved route states Needs a Place, Ready to Place, and Grow into Goal.

## Files Changed

- `Native/Ambitions/Domain/SmartAttachmentPlacementPreview.swift`
- `Native/Ambitions/Domain/ScreenContractModels.swift`
- `Native/Ambitions/Features/Captures/CaptureAtmosphereComposer.swift`
- `Native/Ambitions/Features/Captures/CapturesScreen.swift`
- `Native/Ambitions/Features/Captures/CapturesViewModel.swift`
- `Native/Ambitions/Features/Shared/DegradedStateOrchestrator.swift`
- `Sources/Components/TopLevelSurfaceCompositionPrimitives.swift`
- `Sources/Previews/DynamicAdaptiveVisualPreviews.swift`
- `Sources/Previews/SignatureInterfaceVisualQAFixtures.swift`
- focused Capture/app contract tests
- batch/state/report docs

## Behavior Changed

Capture now presents the top-level object as Capture Anything / Atmosphere
Composer. Post-input routing copy no longer uses the older Suggested Place or
Needs a Decision labels in the touched active route preview path; it uses Needs
a Place, Ready to Place, or Grow into Goal. Route reveal still appears only
after input, and saving still requires explicit user action.

The plural `Captures` implementation folder and internal compatibility names
remain unchanged.

## Tests Run

- `xcodegen generate`
- Focused Capture/cross-surface lane:
  `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/CapturesViewModelTests -only-testing:AmbitionsTests/CapturePlacementReviewStateTests -only-testing:AmbitionsTests/SmartAttachmentServiceTests -only-testing:AmbitionsTests/SmartAttachmentModelsTests -only-testing:AmbitionsTests/ScreenContractRegistryTests -only-testing:AmbitionsTests/TopLevelSurfaceCompositionTests -only-testing:AmbitionsTests/LoadingDegradedStateDesignSystemTests test CODE_SIGNING_ALLOWED=NO`
  passed with 66 selected tests, 0 failures. Raw log:
  `.codex/logs/2026-05-08T13-afi08-focused-tests.raw.log`.

## Tests Not Run

- Rendered screenshots / keyboard-visible preview proof.
- Full UI test suite.
- Manual accessibility traversal.

## Known Risks

- The app build emitted unsigned simulator app-group warnings during the focused
  test run; the selected tests still passed.
- Historical docs still contain older Capture Placement Shelf, Suggested Place,
  or Plan-era terms as completed-history evidence. They were not treated as
  active AFI source truth.
- Rendered screenshot and manual accessibility proof remain Yellow.
- The preserved stash remains Yellow evidence and was not applied.

## Claims

The touched Capture route-preview, screen contract, degraded-state, composition,
and preview-fixture seams now use active AFI Capture Anything / Atmosphere
Composer language and approved route-state labels.

## Non-Claims

No route/raw-value rename, persistence/schema migration, feed/inbox/chat mode,
automatic goal promotion, keyboard screenshot proof, accessibility conformance,
performance proof, release readiness, App Store readiness, TestFlight readiness,
physical-device proof, privacy/legal approval, sync readiness, backend
completion, or production readiness is claimed.

## Next Eligible Batch

AFI09 Time LifeShape Field.

