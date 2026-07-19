# Train 5.5 - Today Viewport Safety And Accessibility Proof Recovery

Date: 2026-06-18
Baseline commit: `bd382be1a95b2fb153d40b3b0b4b8ff06797e1b1`
Status: Yellow

## Current Uncommitted Train 5 Files

- `Native/Ambitions/App/AppCapabilities.swift`
- `Native/Ambitions/App/AppContainer.swift`
- `Native/Ambitions/App/AppContainerFactory.swift`
- `Native/Ambitions/Core/Time/AmbitionsClock.swift`
- `Native/Ambitions/Features/Today/TodayActionClosureSheet.swift`
- `Native/Ambitions/Features/Today/TodayBackground.swift`
- `Native/Ambitions/Features/Today/TodayClosureRecord.swift`
- `Native/Ambitions/Features/Today/TodayCommandHandler.swift`
- `Native/Ambitions/Features/Today/TodayDayBoundaryRefreshPolicy.swift`
- `Native/Ambitions/Features/Today/TodayDayRailPanels.swift`
- `Native/Ambitions/Features/Today/TodayFeatureService.swift`
- `Native/Ambitions/Features/Today/TodayMasthead.swift`
- `Native/Ambitions/Features/Today/TodayRealityMeridianFlagshipAdapter.swift`
- `Native/Ambitions/Features/Today/TodayScreen.swift`
- `Native/Ambitions/Features/Today/TodayStageProjection.swift`
- `Native/Ambitions/Features/Today/TodayStepReplacementSheet.swift`
- `Native/Ambitions/Features/Today/TodayViewModel.swift`
- `Native/Ambitions/PreviewSupport/PreviewAppContainer.swift`
- `Native/Ambitions/Runtime/AmbitionsRuntimeFactory.swift`
- `Native/Ambitions/Services/AppServices.swift`
- `Native/AmbitionsTests/Today/TodayClockTests.swift`
- `Native/AmbitionsTests/Today/TodayFreshGoalVisibilityTests.swift`
- `Native/AmbitionsTests/Today/TodayRealityMeridianExperienceElevationTests.swift`
- `Native/AmbitionsTests/Today/TodayViewModelTests.swift`
- `Native/AmbitionsUITests/AmbitionsUITests.swift`

## Train 5.5 Files Changed

- `Native/Ambitions/Features/Today/TodayDayRailPanels.swift`
- `Native/Ambitions/Features/Today/TodayRealityMeridianFlagshipAdapter.swift`
- `Native/Ambitions/Features/Today/TodayScreen.swift`
- `Native/Ambitions/Features/Today/TodayViewportSafety.swift`
- `Native/AmbitionsTests/Today/TodayViewportSafetyTests.swift`

## Runtime And Layout Behavior

Product runtime behavior changed: No.

Today layout behavior changed: Yes. Train 5.5 added Today-specific viewport safety policy for top clearance, floating dock clearance, large-content rail stacking, no-step action spacing, and stage metric suppression for larger text.

## Screenshot Artifacts Reviewed

Train 5 baseline reviewed:

```text
.codex/xcode-summaries/DESIGN_TRUTH_TRAIN_05/20260618T215033Z-AmbitionsUITests-AmbitionsUITests-testAMB962TodayReconstructionScreenshotMatrix-44491-21506/extract/screenshots
```

Train 5.5 regenerated and reviewed:

```text
.codex/xcode-summaries/DESIGN_TRUTH_TRAIN_05_5/20260618T230657Z-AmbitionsUITests-AmbitionsUITests-testAMB962TodayReconstructionScreenshotMatrix/extract/screenshots
```

Result bundle:

```text
.codex/xcode-results/DESIGN_TRUTH_TRAIN_05_5/20260618T230657Z-AmbitionsUITests-AmbitionsUITests-testAMB962TodayReconstructionScreenshotMatrix.xcresult
```

## Before And After Visual Findings

Before:

- Large Dynamic Type rendered content under or near the status area.
- Large Dynamic Type could hide the primary action under the dock band.
- No-step final action was too close to or hidden by the dock band.

After:

- Large Dynamic Type `Start here`, recommendation text, and `Start now` action are visible and clear.
- Normal Today crown/status spacing is visually clear.
- No-step `Protect this window` has clear dock clearance.

## Accessibility Results

- Dynamic Type: inspected through AMB-962 large Dynamic Type screenshot; passed visual viewport check.
- Dock clearance: inspected through AMB-962 large Dynamic Type and no-step screenshots; passed visual viewport check.
- Status-area/crown clearance: inspected through AMB-962 default, large Dynamic Type, and no-step screenshots; passed visual viewport check.
- No-step final action clearance: inspected through AMB-962 no-step screenshot; passed visual viewport check.
- Reduce Motion: AMB-962 reduce-motion static-equivalent screenshot generated and reviewed for layout safety.
- VoiceOver: not run.
- Increase Contrast: not run.
- Reduce Transparency: not run.

## Tests Executed

- `xcodegen generate`: passed.
- `scripts/ambitions-xcode-build-for-testing.sh --batch DESIGN_TRUTH_TRAIN_05_5`: Test Build Succeeded; wrapper printed `FAILURE_CLASS=unknown` despite success.
- Focused Today unit batch: 30 tests executed, 1 existing source-tree sandbox skip, 0 failures.
- `TodayViewportSafetyTests`: 5 tests, 0 failures.
- `testAMB962TodayReconstructionScreenshotMatrix`: 1 UI test, 0 failures, 7 screenshots extracted.
- Direct Today time-read scan: only `Native/Ambitions/Core/Time/AmbitionsClock.swift` reads `Date()` through `SystemClock`.
- `git diff --check`: passed.
- Changed-file canon scan: changed-file Green; existing backlog hits reported separately.
- Copy lint: passed.
- Release-claim scan: Green.

## Commit And Train 6 Readiness

Train 5 + 5.5 can be committed together with honest Yellow status because automated build, focused tests, screenshot proof, and viewport visual review are current, but manual VoiceOver, Increase Contrast, and Reduce Transparency proof was not run.

Train 6 readiness: Yellow-ready, not Green-ready.
