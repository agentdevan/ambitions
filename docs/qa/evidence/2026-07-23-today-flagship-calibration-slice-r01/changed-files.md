# Changed files and boundary audit

Comparison base: `f2781053d1ffcf962f112014b37d916bd677c450`

## Implementation and tests

- `Native/AmbitionsNativeFoundryHost/AmbitionsNativeFoundryHostApp.swift`
- `Native/AmbitionsNativeFoundryHostUITests/TodayFlagshipCalibrationHostUITests.swift`
- `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipCalibrationContent.swift`
- `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipCalibrationFixture.swift`
- `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipCalibrationPreviews.swift`
- `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipCalibrationStyle.swift`
- `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipCalibrationView.swift`
- `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipFocusedStepView.swift`
- `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipJourneyState.swift`
- `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipNavigationChrome.swift`
- `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipRecoveryReviewView.swift`
- `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipReviewView.swift`
- `Packages/AmbitionsPresentation/Tests/AmbitionsNativeVisualFoundryTests/TodayFlagshipCalibrationFixtureTests.swift`
- `Packages/AmbitionsPresentation/Tests/AmbitionsNativeVisualFoundryTests/TodayFlagshipJourneyStateTests.swift`
- `project.yml`

## Plan and evidence

- `docs/superpowers/plans/2026-07-23-today-flagship-calibration-slice.md`
- every file under
  `docs/qa/evidence/2026-07-23-today-flagship-calibration-slice-r01/`

## Changed-path conclusion

- No production app entry or production application target changed.
- No runtime adapter, persistence call, or live data connection was added.
- No legacy frontend source was imported or modified.
- No Goals, Time, You, Search, or Capture surface was calibrated; their names
  appear only in authorized shell navigation context.
- No canon source, generated canon, authority manifest, AVF direction, VC
  closure, screenshot baseline, Figma, or Code Connect artifact changed.
- No `Package.swift`, `Package.resolved`, third-party dependency, injection
  tool, snapshot-testing library, custom MCP, or custom CLI changed.
- `project.yml` adds only the focused Foundry-host UI-test target; the generated
  Xcode project is not hand-edited.
