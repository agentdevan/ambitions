# AMB-1815 Deterministic Screenshot Lane

Status: lane installed; screenshot execution not claimed under the active user instruction authorizing issue completion without testing until advised otherwise.

## Lane

- Lane id: `amb-1815-time-root-light-m`
- Test: `AmbitionsUITests/DeterministicScreenshotLaneUITests/testAMB1815TimeRootLightMScreenshotLane`
- Runner: `scripts/ambitions-run-deterministic-screenshot-lane.sh`
- Surface: Time root
- Appearance: Light
- Dynamic Type: `UICTContentSizeCategoryM`
- Bootstrap mode: preview
- Launch URL: `ambitions://tab/time`
- Initial surface: `time`
- Screenshot mode: `AmbitionsScreenshotMode=YES`
- Time render state: `AmbitionsTimeRenderState=manual-only`
- Required rendered anchor before capture: `time.life-shape-field`

## Artifacts

When the lane runs, the UI test keeps these XCTest attachments:

- Screenshot attachment: `amb-1815-time-root-light-m-screenshot`
- Metadata attachment: `amb-1815-time-root-light-m-metadata`

The wrapper uses the existing focused Xcode runner, so result bundles, logs, summaries, and extracted screenshots remain under `.codex/xcode-results`, `.codex/xcode-logs`, and `.codex/xcode-summaries`.

## Non-Claims

This lane does not claim Visual Green, independent visual acceptance, current screenshot proof for this commit, Dynamic Type coverage beyond the configured M size, dark-mode proof, physical-device proof, CI artifact upload, TestFlight/App Store readiness, or release proof.

## Required Follow-Up Before Visual Claims

Run `scripts/ambitions-run-deterministic-screenshot-lane.sh`, extract the `.xcresult`, review the generated screenshot, and link the retained artifact before using this lane as current rendered visual proof.
