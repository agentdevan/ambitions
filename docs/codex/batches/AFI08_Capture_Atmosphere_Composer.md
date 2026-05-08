# AFI08 Capture Atmosphere Composer

<!-- markdownlint-disable MD013 -->

Status: Complete / Accepted Yellow
Date: 2026-05-08

## Purpose

Complete Capture as Capture Anything / Atmosphere Composer in the active AFI
lane while preserving the existing local-first Capture implementation.

## Source Truth

- `docs/AmbitionsCanon/03_Signature_Object_Specs.md`
- `docs/AmbitionsCanon/10_Ambitions_Flagship_Interface_Canon.md`
- `docs/AmbitionsCanon/15_AFI_Implementation_Lane.md`
- `docs/AmbitionsCanon/16_Surface_Identity_And_Signature_Moments.md`
- `docs/codex/AMBITIONS_CANON_UI_COMPLETION_INSERTION_OVERLAY.md`

## Scope

- Keep Capture composer-first, bottom-oriented, and keyboard-native.
- Keep route reveal hidden until there is input.
- Use the approved post-input route states: Needs a Place, Ready to Place, and
  Grow into Goal.
- Preserve local-only proof, correction, privacy, and receipt wording.
- Preserve `Captures` file/folder names as implementation compatibility seams.

## Forbidden

- Do not turn Capture into a feed, inbox, notes list, chatbot, category board,
  task board, or top-level plus tab.
- Do not create automatic goal promotion, hidden learning, or calendar/network
  behavior.
- Do not change route raw values, persistence schema, package boundaries,
  signing, entitlements, hosted workflows, sync/cloud behavior, or release
  posture.

## Validation

- `xcodegen generate`
- Focused Capture/cross-surface test lane:
  `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/CapturesViewModelTests -only-testing:AmbitionsTests/CapturePlacementReviewStateTests -only-testing:AmbitionsTests/SmartAttachmentServiceTests -only-testing:AmbitionsTests/SmartAttachmentModelsTests -only-testing:AmbitionsTests/ScreenContractRegistryTests -only-testing:AmbitionsTests/TopLevelSurfaceCompositionTests -only-testing:AmbitionsTests/LoadingDegradedStateDesignSystemTests test CODE_SIGNING_ALLOWED=NO`

## Closeout

Result: Accepted Yellow. Focused tests passed. Rendered screenshot /
keyboard-visible proof, full UI test suite, and manual accessibility traversal
remain unclaimed.

