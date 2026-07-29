# Command log

Representative commands:

```text
git fetch --prune origin
xcrun mcpbridge --help
swift test --filter GoalsNativeCalibrationPresentationTests
xcodebuild build-for-testing -project Ambitions.xcodeproj -scheme AmbitionsNativeFoundryHost -destination 'platform=iOS Simulator,id=396F4B4A-2DAD-4345-B26E-ABD2EF69BF5E'
xcodebuild test-without-building -project Ambitions.xcodeproj -scheme AmbitionsNativeFoundryHost -destination 'platform=iOS Simulator,id=396F4B4A-2DAD-4345-B26E-ABD2EF69BF5E' -only-testing:AmbitionsNativeFoundryHostUITests/GoalsNativeCalibrationHostUITests -only-testing:AmbitionsNativeFoundryHostUITests/GoalsNativeCalibrationScreenshotCaptureUITests -resultBundlePath /tmp/GoalsNativeR02-final-20260729-1206.xcresult
xcrun xcresulttool export attachments --path /tmp/GoalsNativeR02-final-20260729-1206.xcresult --output-path /tmp/goals-native-r02-final-attachments
swift test
swiftlint lint --strict <eight changed Swift files>
python3 scripts/ambitions-canon.py check
python3 -m unittest discover -s tools/tests -p 'test_ambitions_canon_compiler.py'
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/ambitions-runtime-direct-write-audit.py
python3 scripts/ci/ambitions-no-weak-implementation-scan.py
GITHUB_BASE_SHA=4b123bf94bff927bb33c0a69d818c55b50f19698 bash scripts/ci/ambitions-gitleaks-scan.sh --range-only
jq -r '.frames[] | "\(.sha256)  \(.file)"' screenshot-metadata.json | shasum -a 256 -c -
jq -r '.contact_sheets[] | "\(.sha256)  \(.file)"' contact-sheet-metadata.json | shasum -a 256 -c -
git diff --check
```

The contact sheets were assembled mechanically from the final native capture
attachments with ImageMagick. No generated or image-backed UI was used.
