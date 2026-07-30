# Command log

Commands were run from the isolated
`.worktrees/time-world-class-structural-entry` worktree.

## Generation and focused tests

```text
xcodegen generate
swift test --package-path Packages/AmbitionsPresentation --filter TimeNativeCalibration
```

## Native host build and UI proof

```text
scripts/ambitions-bounded-xcodebuild.sh ... \
  -project Ambitions.xcodeproj \
  -scheme AmbitionsNativeFoundryHost \
  -destination platform=iOS\ Simulator,id=EDE1E954-C663-47FB-855B-95F96AE2DBDD \
  -derivedDataPath .codex/DerivedData/TimeD07 build

scripts/ambitions-bounded-xcodebuild.sh ... \
  -project Ambitions.xcodeproj \
  -scheme AmbitionsNativeFoundryHost \
  -destination platform=iOS\ Simulator,id=EDE1E954-C663-47FB-855B-95F96AE2DBDD \
  -derivedDataPath .codex/DerivedData/TimeD07 \
  -only-testing:AmbitionsNativeFoundryHostUITests/\
TimeNativeCalibrationD07HostUITests test
```

The five final frames were captured from the standalone signed fixture host with
`xcrun simctl launch` and `xcrun simctl io screenshot`. An invalid blank batch
from the XCTest-injected host bundle was overwritten and excluded; final files
were accepted only after distinct-hash and visual inspection.
