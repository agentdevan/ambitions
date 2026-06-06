# AOR-002 Report

- Commit: final AMB-526 commit on `main` (`AMB-526 add deterministic screenshot harness`; exact pushed hash recorded in Linear closeout)
- Project: `Ambitions.xcodeproj`
- Workspace: `N/A` (project-based run)
- Package graph: `Ambitions.xcodeproj` with local packages `AmbitionsDesignSystem` and `AmbitionsExperienceKernel`
- Scheme: `Ambitions`
- Simulator used: `iPhone 17e` (`81485ACD-AF10-4B92-8C03-9BB8805A4A23`) on runtime `iOS 26.3` (`26.3.1 - 23D8133`, `com.apple.CoreSimulator.SimRuntime.iOS-26-3`)
- Bundle identifier: `com.ambitions.ios`

## Launch implementation
- File: `Native/Ambitions/App/AppBootstrapper.swift`
- Excerpts:
  - Lines 42-45: `applyDebugLaunchOverridesIfNeeded(to:)` is invoked in `start()` immediately after `AppContainerFactory.make(...)` and before `phase = .ready(container)`.
  - Lines 153-160: allowed launch surfaces are mapped only to `today`, `goals`, `time`, `motion`, and `you`.
  - Lines 168-178: `launchConfiguration(fromArguments:)` reads `AmbitionsInitialSurface` and `AmbitionsScreenshotMode` from launch arguments only.
  - Lines 187-190: a valid initial surface calls `container.navigation.selectTab(initialSurface)`.
  - Lines 193-199: `launchArgumentValue(for:fromArguments:)` reads only `-<key>` launch argument pairs and does not consult environment values.
  - DEBUG parser extracts:
    - `-AmbitionsInitialSurface` via `launchConfiguration(fromArguments:)`
    - `-AmbitionsScreenshotMode` via `launchConfiguration(fromArguments:)`
  - Allowed launch surfaces are hard-coded to: `today`, `goals`, `time`, `motion`, `you`.
  - Legacy/capture values are intentionally unmapped and resolve to `nil`.
  - Invalid values are ignored (no nav override).

## Commands
- Build-for-testing: `make xcode-build-for-testing BATCH=AMB-526`
- Focused test: `make xcode-focused-test BATCH=AMB-526 TEST=AmbitionsTests/AppShellNavigationTests`
- Focused guard post: `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-526 --prompt prompts/batches/AMB-526.md --changed-from 0d2aa00be165a455579e1427ea57b793087a8524 --batch-type source-changing`
- App launch + screenshot:
  - `mkdir -p artifacts/ambitions-ui-reconstruction/screenshots`
  - `xcrun simctl install booted .codex/DerivedData/Ambitions/Build/Products/Debug-iphonesimulator/Ambitions.app`
  - `xcrun simctl launch booted com.ambitions.ios --args -AmbitionsInitialSurface today -AmbitionsScreenshotMode YES`
  - `xcrun simctl io booted screenshot artifacts/ambitions-ui-reconstruction/screenshots/today-default-before.png`

## Evidence
- Screenshot:
  - `artifacts/ambitions-ui-reconstruction/screenshots/today-default-before.png`
- Wrapper summaries:
  - Build-for-testing passed: `.codex/xcode-summaries/AMB-526/20260606T192557Z-bft-34477-32608/build-for-testing-summary.json`
  - Focused tests passed: `.codex/xcode-summaries/AMB-526/20260606T192829Z-AmbitionsTests-AppShellNavigationTests-35927-6743/focused-test-summary.json`
  - Post-guard passed: `build/reports/parallel-implementation-guard/AMB-526-post.md`

## Validation coverage
- `AppShellNavigationTests` additions verify:
  - canonical defaults and strict screenshot mode parsing
  - deterministic canonical surface parsing for `today|goals|time|motion|you`
  - invalid and legacy surfaces (`capture`, `captures`, `pulse`, `plan`, `habits`, `insights`) do not map to top-level tabs
  - environment values are not accepted for AMB-526 screenshot launch configuration
- Build-for-testing and focused tests both passed after fixes.

## Fallback
- Manual fallback not required.
