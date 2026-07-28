# B02 changed-file inventory

The exact path-by-path inventory relative to B01 base
`92048f7622b06f78ee6e5667e84facd0c4beb2f4` is stored in
`changed-files-manifest.txt`.

Status: `COMPLETE AT HANDOFF`

- Starting SHA: `92048f7622b06f78ee6e5667e84facd0c4beb2f4`
- Rendered-source SHA: `75fb51f96d911cd6da92094b72b2248c99922ea1`
- Ending branch SHA: resolved by `git rev-parse HEAD` after the final evidence
  commit and reported in the owner handoff; a Git commit cannot embed its own
  object ID.
- Branch: `codex/today-open-continuity-field`

## Foundry package source

- `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipArticulatedAnatomy.swift`
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
- `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayOpenContinuityFocusedObject.swift`
- `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayOpenContinuityFullDayView.swift`
- `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayOpenContinuityGrammar.swift`
- `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayOpenContinuityResilience.swift`
- `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayOpenContinuityRoot.swift`
- `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayOpenContinuitySpine.swift`
- `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayOpenContinuityTimeline.swift`
- `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayOpenContinuityTruthFlow.swift`

## Fixture host and tests

- `Native/AmbitionsNativeFoundryHost/AmbitionsNativeFoundryHostApp.swift`
- `Native/AmbitionsNativeFoundryHostUITests/TodayFlagshipCalibrationHostUITests.swift`
- `Native/AmbitionsNativeFoundryHostUITests/TodayOpenContinuityRecordingDriverUITests.swift`
- `Packages/AmbitionsPresentation/Tests/AmbitionsNativeVisualFoundryTests/TodayFlagshipCalibrationFixtureTests.swift`
- `Packages/AmbitionsPresentation/Tests/AmbitionsNativeVisualFoundryTests/TodayFlagshipJourneyStateTests.swift`

## Specification and execution records

- `docs/superpowers/specs/2026-07-23-today-open-continuity-field-design.md`
- `docs/superpowers/plans/2026-07-23-today-open-continuity-field.md`
- `.superpowers/sdd/` B02 phase briefs, reports, reviews, and progress records
- `docs/qa/evidence/2026-07-23-today-open-continuity-field-b02-r00/`

The evidence directory contains narrative records, immutable reference hashes,
native Foundry screenshots, recordings, contact sheets, and machine-readable
metadata. Final exact media inventory and hashes are owned by the final metadata
files rather than duplicated here.

## Explicitly unchanged or absent

- Canon and generated canon
- `project.yml` and tracked Xcode project state
- Production app entry and live runtime adapters
- Legacy frontend and unrelated product surfaces
- Package/dependency resolution
- R01, R02, and B01 evidence media and hashes
- Figma and Code Connect artifacts
- Production screenshot baselines

The closeout reconciles this list against
`git diff --name-only 92048f762..HEAD`; the final handoff reports the exact
ending object ID after the last commit.

Task 11 is committed at `133c040e5` (`test(foundry): lock open continuity
behavior`). Its only production-intended source repair is the bounded 48-point
intrinsic recovery-label envelope in the existing native sheet.
