# B02 baseline validation

Starting branch SHA: `92048f7622b06f78ee6e5667e84facd0c4beb2f4`

## Repository

- Local `main`: `f2781053d1ffcf962f112014b37d916bd677c450`
- `origin/main`: `f2781053d1ffcf962f112014b37d916bd677c450`
- R02: `77e818823b58ee2911e68962dd8bd8115e1d26aa`
- B01/B02 base: `92048f7622b06f78ee6e5667e84facd0c4beb2f4`
- B02 began clean and unmerged.

## Fresh build and tests

- Foundry target build: PASS, cached after package test, 0.43 seconds.
- Full package test: PASS, 31 tests, zero failures. Initial isolated
  worktree compilation took 79.79 seconds; test execution took 0.121 seconds.
- Fixture-host Simulator build: PASS on VC14 iPhone 17 Pro,
  `EDE1E954-C663-47FB-855B-95F96AE2DBDD`, iOS 26.5. Generated from unchanged
  `project.yml`; build took 35.98 seconds.
- Focused native root UI baseline: PASS, one test, zero failures, 20.985 seconds
  test execution and 51.88 seconds total build/test orchestration.

The initial parallel package build waited on the same SwiftPM build directory
while the package test compiled. It completed successfully after the test and
is retained as an observed orchestration detail, not a product failure.

## Evidence boundary

No production app build, launch, screenshot, or recording was used. The host
dependency graph contains only `AmbitionsNativeFoundryHost` and
`AmbitionsNativeVisualFoundry` for this proof.

## Preserved B01 warm-loop baseline

The immutable B01 benchmark is the comparison floor:

- Initial package preview launch: 22 seconds
- Root warm changes: 13, 19, 19, and 14 seconds
- Deep warm changes: 11, 7, 7, and 8 seconds
- Deep steady-state median: 7.5 seconds
- Cached fixture-host build: 6 seconds
- Clean builds required: none

B02 will record a new initial launch, four root changes, four focused/review
changes, four motion/material changes, a cached host build, and a host launch.
Each row records elapsed time, success, visible change, host relaunch, and clean
build requirement.
