# Repository map

## Authority and proof

- Generated entry: `docs/canon/generated/CODEX_START_HERE.md`
- Today owner: `docs/canon/specifications/surfaces/today.md`
- Shell owner: `docs/canon/specifications/app/shell.md`
- Active visual law: `docs/canon/design/VISUAL_SYSTEM_R1.md`
- VC-14 boundary: `docs/canon/design/VC_14_NATIVE_MATCHED_CLOSURE.md`
- Historical evidence: sibling R01, R02, and B01 evidence packages

## Foundry semantic boundary

- Immutable snapshots: `TodayFlagshipCalibrationContent.swift`
- Deterministic fixtures: `TodayFlagshipCalibrationFixture.swift`
- Journey phases and guarded transitions: `TodayFlagshipJourneyState.swift`
- Fixture host: `Native/AmbitionsNativeFoundryHost/AmbitionsNativeFoundryHostApp.swift`

## Foundry presentation boundary

- Root and return: `TodayFlagshipCalibrationView.swift`
- Existing local grammar: `TodayFlagshipArticulatedAnatomy.swift`
- Local appearance roles: `TodayFlagshipCalibrationStyle.swift`
- Shell chrome: `TodayFlagshipNavigationChrome.swift`
- Focused Step: `TodayFlagshipFocusedStepView.swift`
- Review and saving: `TodayFlagshipReviewView.swift`
- Recovery: `TodayFlagshipRecoveryReviewView.swift`
- Preview family: `TodayFlagshipCalibrationPreviews.swift`

## Tests

- Fixture/source guards: `TodayFlagshipCalibrationFixtureTests.swift`
- State machine: `TodayFlagshipJourneyStateTests.swift`
- Native interaction and accessibility frames:
  `Native/AmbitionsNativeFoundryHostUITests/TodayFlagshipCalibrationHostUITests.swift`

## Explicitly outside B02

The production entry is `Native/Ambitions/App/AmbitionsApp.swift`. It mounts
production surfaces through `AmbitionsRootStageSurfaceHost.swift`. Neither path
is a Foundry evidence source or an authorized edit target.
