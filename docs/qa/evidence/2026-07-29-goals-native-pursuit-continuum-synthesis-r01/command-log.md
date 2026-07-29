# Command log

Representative commands used for this synthesis:

```text
git fetch --prune origin
python3 scripts/ambitions-canon.py query Goals
xcrun mcpbridge --help
swift test --filter GoalsNativeCalibration
xcodegen generate
xcodebuild build-for-testing -project Ambitions.xcodeproj -scheme AmbitionsNativeFoundryHost -destination 'platform=iOS Simulator,id=396F4B4A-2DAD-4345-B26E-ABD2EF69BF5E'
xcodebuild test-without-building -project Ambitions.xcodeproj -scheme AmbitionsNativeFoundryHost -destination 'platform=iOS Simulator,id=396F4B4A-2DAD-4345-B26E-ABD2EF69BF5E' -only-testing:AmbitionsNativeFoundryHostUITests/GoalsNativeCalibrationHostUITests -only-testing:AmbitionsNativeFoundryHostUITests/GoalsNativeCalibrationScreenshotCaptureUITests -resultBundlePath /tmp/GoalsNativePursuitSynthesis-final-20260729.xcresult
xcrun xcresulttool export attachments --path /tmp/GoalsNativePursuitSynthesis-final-20260729.xcresult --output-path /tmp/goals-pursuit-synthesis-final-attachments
swift test
swiftlint lint --strict --reporter github-actions-logging <13 changed Swift files>
python3 scripts/ambitions-canon.py check
python3 -m unittest discover -s tools/tests -p 'test_ambitions_canon_compiler.py'
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/ambitions-runtime-direct-write-audit.py
python3 scripts/ci/ambitions-no-weak-implementation-scan.py
GITHUB_BASE_SHA=2186404af40cacc391fd4a8f084b03b09470603a bash scripts/ci/ambitions-gitleaks-scan.sh --range-only
jq -r '.frames[] | "\(.sha256)  \(.file)"' screenshot-metadata.json | shasum -a 256 -c -
jq -r '.contact_sheets[] | "\(.sha256)  \(.file)"' contact-sheet-metadata.json | shasum -a 256 -c -
git diff --check
```

The direct Xcode bridge discovered the active Ambitions project. Direct preview
and editor diagnostics were limited by the active scheme/editor service, so
Simulator automation and evidence capture used direct `xcodebuild` fallback.
