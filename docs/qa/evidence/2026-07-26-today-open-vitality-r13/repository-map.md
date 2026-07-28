# Repository Map

## Verified state

- Local `main`: `5670f24fb82adefd27cffee5ddf8fb70676ed049`
- `origin/main`: `5670f24fb82adefd27cffee5ddf8fb70676ed049`
- Source B02: `ac7ed07d090d65bdc469a9a2309f6899dc6135e6`
- R13 branch: `codex/today-open-vitality-r13`
- R13 worktree: `.worktrees/today-open-vitality-r13`
- R13 starting SHA: `ac7ed07d090d65bdc469a9a2309f6899dc6135e6`

The source B02 worktree and the new R13 worktree were clean at preflight. R01,
R02, B01, and B02 evidence packages and recorded hashes remain present.

## Foundry boundary

- Package: `Packages/AmbitionsPresentation/Package.swift`
- Foundry module: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/`
- Package tests: `Packages/AmbitionsPresentation/Tests/AmbitionsNativeVisualFoundryTests/`
- Fixture host: `Native/AmbitionsNativeFoundryHost/`
- Fixture-host UI tests: `Native/AmbitionsNativeFoundryHostUITests/`
- XcodeGen owner: `project.yml`

The production app entry, production surfaces, runtime, stage, and legacy
frontend are outside the changed-path envelope.

## Existing semantic interfaces retained

- `TodayFlagshipCalibrationContent`: immutable render snapshot.
- `TodayFlagshipCalibrationFixture`: deterministic fixture family.
- `TodayFlagshipJourneyState`: routes, phase, presentation, and focus.
- `TodayFlagshipCalibrationView`: public Foundry composition entry.
- `TodayFlagshipNavigationChrome`: dock and adaptive passage.
- `TodayOpenContinuity*`: B02 semantic and interaction harness to be translated,
  not discarded.

## Baseline validation

- Foundry target build: passed.
- Package test suite: 50 tests passed.
- Fixture-host Simulator build: passed on iPhone 17 Pro, iOS 26.5.
