# Train 7 Capture Composer Refraction Closeout

Status: Green  
Branch: `main`  
Closeout date: 2026-06-18 local / 2026-06-19 UTC artifacts  
Scope: Train 7 - Capture Composer Refraction

## Canon And Architecture Mapping

- Preserved persistent surfaces as Today / Goals / Time / You. Capture remains a global composer/overlay, not a root tab.
- Replaced the old activated-Capture diagnostic anatomy with `Native/Ambitions/App/AppShellActivatedCaptureSeam.swift`.
- Kept Train 7 within the attached architecture tree boundaries:
  - `App/`: shell activation, source policy, and command routing.
  - `Composer/Capture` equivalent in current repo: `Native/Ambitions/Features/Capture/CaptureAtmosphereComposer.swift`.
  - `Core/Domain` equivalent in current repo: `Native/Ambitions/Domain/CaptureModels.swift`.
- Did not create `Surfaces/Capture`, `Surfaces/Motion`, a root Capture tab, or a Motion destination.
- Did not edit canon files under `docs/truth/`.

## Source Changes

Created:
- `Native/Ambitions/App/AppShellActivatedCaptureSeam.swift`
- `Native/Ambitions/App/AppShellCaptureSourcePolicy.swift`

Modified:
- `Native/Ambitions/App/AmbitionsRootView.swift`
- `Native/Ambitions/App/AppShellView.swift`
- `Native/Ambitions/App/ShellCommandRouter.swift`
- `Native/Ambitions/Domain/CaptureModels.swift`
- `Native/Ambitions/Features/Capture/CaptureAtmosphereComposer.swift`
- `Native/AmbitionsTests/App/CaptureRoutingPrimitiveFamilyTests.swift`
- `Native/AmbitionsTests/Capture/CapturePlacementReviewStateTests.swift`
- `Native/AmbitionsTests/Capture/CaptureViewModelTests.swift`
- `Native/AmbitionsTests/Persistence/CaptureServiceTests.swift`
- `Native/AmbitionsUITests/AmbitionsUITests.swift`

Deleted by replacement:
- Inline `AppShellActivatedCaptureSeam` implementation from `AppShellView`.
- Unsupported quick-capture chip rails for camera/photos/files/scan/date/repeat/location/flag.
- Diagnostic route-state/detail anatomy that duplicated `CaptureAtmosphereComposer`.

## Product Proof

- Global Capture uses the shared `CaptureAtmosphereComposer` for both shell quick capture and activated Capture.
- Shell-driven Capture saves now carry `CaptureSourceType.shellComposer` instead of a nil source.
- Route correction is user-visible through route-choice buttons and writes the selected route into the local save request.
- Dictation no longer claims real voice capture. The UI says keyboard dictation only and points to the iOS keyboard microphone.
- Offline/local save path is preserved through `captureService.createCapture(...)` using `decision.createCaptureRequest(...)`.
- Unsupported route controls are hidden when the current draft text does not produce that choice.

## Validation

Passed:
- `xcodegen generate`
- `git diff --check`
- `scripts/ambitions-xcode-build-for-testing.sh --batch TRAIN_07_CAPTURE_SHELL --timeout 30m --kill-after 60s`
  - Latest summary: `.codex/xcode-summaries/TRAIN_07_CAPTURE_SHELL/20260619T020831Z/extract/summary.json`
- `scripts/ambitions-xcode-test-focused.sh --batch TRAIN_07_CAPTURE_SHELL --test AmbitionsTests/CaptureRoutingPrimitiveFamilyTests --timeout 15m --kill-after 60s`
  - Latest summary: `.codex/xcode-summaries/TRAIN_07_CAPTURE_SHELL/20260619T021842Z-AmbitionsTests-CaptureRoutingPrimitiveFamilyTests-90368-25342/extract/summary.json`
  - Result: 5 executed, 0 failures, 1 expected skip for absent historical primitive registry.
- `scripts/ambitions-xcode-test-focused.sh --batch TRAIN_07_CAPTURE_SHELL --test AmbitionsTests/CaptureViewModelTests --timeout 15m --kill-after 60s`
  - Latest summary: `.codex/xcode-summaries/TRAIN_07_CAPTURE_SHELL/20260619T021950Z-AmbitionsTests-CaptureViewModelTests-90789-1738/extract/summary.json`
  - Result: 21 executed, 0 failures.
- `scripts/ambitions-xcode-test-focused.sh --batch TRAIN_07_CAPTURE_SHELL --test AmbitionsTests/CaptureServiceTests --timeout 15m --kill-after 60s`
  - Latest summary: `.codex/xcode-summaries/TRAIN_07_CAPTURE_SHELL/20260619T022036Z-AmbitionsTests-CaptureServiceTests-91318-17204/extract/summary.json`
  - Result: 16 executed, 0 failures.
- `scripts/ambitions-xcode-test-focused.sh --batch TRAIN_07_CAPTURE_SHELL --test AmbitionsTests/ShellCommandRouterTests --timeout 15m --kill-after 60s`
  - Latest summary: `.codex/xcode-summaries/TRAIN_07_CAPTURE_SHELL/20260619T022120Z-AmbitionsTests-ShellCommandRouterTests-91798-25884/extract/summary.json`
  - Result: 12 executed, 0 failures.
- `scripts/ambitions-xcode-test-focused.sh --batch TRAIN_07_CAPTURE_SHELL_UI --test AmbitionsUITests/AmbitionsUITests/testLaunchURLCanOpenGlobalCaptureWithoutTopLevelCaptureTab --timeout 20m --kill-after 60s`
  - Latest summary: `.codex/xcode-summaries/TRAIN_07_CAPTURE_SHELL_UI/20260619T020902Z-AmbitionsUITests-AmbitionsUITests-testLaunchURLCanOpenGlobalCaptureWithoutTopLev-85448-17025/extract/summary.json`
  - Result: 1 executed, 0 failures.
- `scripts/release-claim-safety-scan.sh`
  - Green: no proof-sensitive release claims found.
- `scripts/no-unsupported-ai-claim-scan.sh`
  - Yellow advisory only; no blocking claim introduced in changed files.
- `python3 scripts/ambitions-copy-contract-lint.py`
  - Passed.
- `python3 scripts/ambitions-local-first-boundary-scan.py`
  - Green.
- `python3 scripts/ambitions-vocabulary-drift-scan.py`
  - Green.
- `scripts/canon-language-drift-scan.sh`
  - Green for changed files; existing backlog hits remain outside this Train 7 slice.

## Screenshot And Accessibility

Screenshot visually reviewed:
- `.codex/screenshots/TRAIN_07_CAPTURE_SHELL/activated-capture-seam.png`

Visual notes:
- Activated Open Field seam is visible above the keyboard with readable proof chips, input field, keyboard-dictation affordance, and save control.
- The keyboard does not cover the input or save affordance.
- Supporting copy below the field is scrollable when the keyboard is up.

Accessibility proof:
- Focused UI test proved no root Capture/Pulse destination, seam activation, keyboard state, local-read state, route reveal, Task/Goal route choices, hidden unsupported Idea choice for the tested draft, route correction receipt, keyboard dictation button, local save receipt, and large Dynamic Type save/route/source-trust presence.
- `CaptureAtmosphereComposer` no longer masks child control accessibility identifiers with its root identifier.
- Route strip no longer masks route-choice button identifiers.

## Known Risks

- The manually reviewed screenshot captures the focused empty composer state, not every typed route state. Typed route behavior is covered by the passing focused UI test and prior extracted accessibility hierarchy.
- The historical primitive registry test is skipped because `docs/codex/ambitions_primitive_invention_registry.md` is not retained in current repo truth.
- Full screenshot matrix was not run for all Capture states; Train 7 proof is focused to the touched global Capture flows.

## Rollback Plan

- Revert the Train 7 commit to restore the previous shell capture implementation and tests.
- Regenerate with `xcodegen generate`.
- Re-run the Train 7 focused build and tests listed above.

