# Exact command log

Commands are shown with task-relevant arguments. Temporary paths and shell-generated attachment UUIDs are preserved where material.

## Preflight and authority

```sh
git fetch origin --prune
git rev-parse main
git rev-parse origin/main
git status --short --branch
git worktree add -b codex/goals-native-calibration-r01 .worktrees/goals-native-calibration-r01 e4a8260b5b7a776a0190c18efc33c7da9a70ceeb
python3 scripts/ambitions-canon.py query Goals
```

## TDD and package iteration

```sh
swift build --package-path Packages/AmbitionsPresentation --target AmbitionsNativeVisualFoundry
swift test --package-path Packages/AmbitionsPresentation
swift test --package-path Packages/AmbitionsPresentation --filter GoalsNativeCalibrationFixtureTests
swift test --package-path Packages/AmbitionsPresentation --filter GoalsNativeCalibrationJourneyStateTests
swift test --package-path Packages/AmbitionsPresentation --filter GoalsNativeCalibrationPresentationTests
swift test --package-path Packages/AmbitionsPresentation --filter GoalsNativeCalibrationPathTests
```

The initial filtered test invocations were intentionally red before fixture, state, focused-depth, relationship, Path, and accessibility implementations existed. Subsequent filtered runs passed.

## Fixture host and native capture

```sh
xcodegen generate
xcodebuild -project Ambitions.xcodeproj -scheme AmbitionsNativeFoundryHost -destination 'platform=iOS Simulator,id=396F4B4A-2DAD-4345-B26E-ABD2EF69BF5E' build-for-testing
xcodebuild test-without-building -project Ambitions.xcodeproj -scheme AmbitionsNativeFoundryHost -destination 'platform=iOS Simulator,id=396F4B4A-2DAD-4345-B26E-ABD2EF69BF5E' -only-testing:AmbitionsNativeFoundryHostUITests/GoalsNativeCalibrationHostUITests
xcodebuild test-without-building -project Ambitions.xcodeproj -scheme AmbitionsNativeFoundryHost -destination 'platform=iOS Simulator,id=396F4B4A-2DAD-4345-B26E-ABD2EF69BF5E' -only-testing:AmbitionsNativeFoundryHostUITests/GoalsNativeCalibrationScreenshotCaptureUITests -resultBundlePath /tmp/GoalsNativeCalibrationR01Capture-d7eb47f.xcresult
xcrun xcresulttool export attachments --path /tmp/GoalsNativeCalibrationR01Capture-d7eb47f.xcresult --output-path /tmp/goals-r01-final-attachments.td1bbg
```

## Evidence generation and inspection

```sh
magick identify docs/qa/evidence/2026-07-28-goals-native-calibration-r01/screenshots/*.png
magick montage ... docs/qa/evidence/2026-07-28-goals-native-calibration-r01/contact-sheets/GNC-C01-full-matrix.png
magick ... docs/qa/evidence/2026-07-28-goals-native-calibration-r01/contact-sheets/GNC-C02-r14-cross-root-transfer.png
shasum -a 256 docs/qa/evidence/2026-07-28-goals-native-calibration-r01/screenshots/*.png
shasum -a 256 docs/qa/evidence/2026-07-28-goals-native-calibration-r01/contact-sheets/*.png
```

## Final validation

Final commands and outcomes are appended to `validation-results.md` after the single final reviewer gate.

