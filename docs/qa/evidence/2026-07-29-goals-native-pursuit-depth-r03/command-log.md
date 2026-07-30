# Command log

Representative commands executed from the isolated R03 worktree:

```text
git fetch origin --prune
git worktree add -b codex/goals-native-pursuit-depth-r03 .worktrees/goals-native-pursuit-depth-r03 origin/main
swift test --package-path Packages/AmbitionsPresentation --filter GoalsNativeCalibration
xcodebuild -project Ambitions.xcodeproj -scheme AmbitionsNativeFoundryHost -destination platform=iOS\ Simulator,id=396F4B4A-2DAD-4345-B26E-ABD2EF69BF5E -derivedDataPath .codex/DerivedData-R03-UI2 build-for-testing
xcodebuild ... test-without-building -only-testing:AmbitionsNativeFoundryHostUITests/GoalsNativeCalibrationR03HostUITests
xcodebuild ... test-without-building -parallel-testing-enabled NO -only-testing:AmbitionsNativeFoundryHostUITests/GoalsNativeCalibrationR03RecordingUITests
xcodebuild ... test-without-building -parallel-testing-enabled NO -only-testing:AmbitionsNativeFoundryHostUITests/GoalsNativeCalibrationR03HostUITests -only-testing:AmbitionsNativeFoundryHostUITests/GoalsNativeCalibrationHostUITests -only-testing:AmbitionsNativeFoundryHostUITests/GoalsNativeCalibrationR03RecordingUITests -resultBundlePath /tmp/GoalsNativeR03-final-clean-1.xcresult
xcrun simctl ui 396F4B4A-2DAD-4345-B26E-ABD2EF69BF5E content_size large
xcrun simctl ui 396F4B4A-2DAD-4345-B26E-ABD2EF69BF5E increase_contrast enabled
xcrun simctl io 396F4B4A-2DAD-4345-B26E-ABD2EF69BF5E screenshot <artifact>
xcrun xcresulttool export attachments --path /tmp/R03-recording-frames.xcresult --output-path <temporary-directory>
swift -e <AVAssetWriter H.264 semantic-frame encoder> <recording> <ordered-XCTest-native-frames>
magick compare -metric AE <baseline> <final> null:
python3 scripts/ambitions-canon.py check
python3 -m unittest discover -s tools/tests -p 'test_ambitions_canon_compiler.py'
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/ambitions-flagship-boundary-audit.py
python3 scripts/ambitions-runtime-direct-write-audit.py
python3 scripts/ci/ambitions-no-weak-implementation-scan.py
GITHUB_BASE_SHA=d3c99c8b287d0aa98fc83c17e4d4f8b77d3c8b9d bash scripts/ci/ambitions-gitleaks-scan.sh --range-only
jq -r '.artifacts[] | "\(.sha256)  \(.file)"' <metadata> | shasum -a 256 -c -
git diff --check
```

The exact final validation commands and outcomes are listed in `validation-results.md`.

Raw `simctl recordVideo` trials were rejected after time-sampled frames showed the base framebuffer rather than Xcode 26's UI-automation surface. They are not included in the package. The retained clips are encoded from ordered `XCUIScreen` captures made only after each XCUI journey assertion passed.
