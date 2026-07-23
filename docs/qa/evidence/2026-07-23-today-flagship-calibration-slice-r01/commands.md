# Exact command ledger

All commands ran from the isolated worktree unless an absolute path is shown.
No `clean` command was used.

## Preflight and authority discovery

```sh
git fetch origin
git rev-parse main origin/main
git status --short --branch
git worktree add -b codex/today-flagship-calibration-slice .worktrees/today-flagship-calibration-slice f2781053d1ffcf962f112014b37d916bd677c450
python3 scripts/ambitions-canon.py query "Today"
python3 scripts/ambitions-canon.py query "Still counts"
python3 scripts/ambitions-canon.py query "Crowned Edge Dock"
```

## Builds and tests used during implementation

```sh
swift build --package-path Packages/AmbitionsPresentation --target AmbitionsNativeVisualFoundry
swift test --package-path Packages/AmbitionsPresentation --filter AmbitionsNativeVisualFoundryTests
xcodegen generate
xcodebuild -project Ambitions.xcodeproj -scheme AmbitionsNativeFoundryHost -destination 'platform=iOS Simulator,id=EDE1E954-C663-47FB-855B-95F96AE2DBDD' build
xcodebuild -project Ambitions.xcodeproj -scheme AmbitionsNativeFoundryHost -destination 'platform=iOS Simulator,id=EDE1E954-C663-47FB-855B-95F96AE2DBDD' -only-testing:AmbitionsNativeFoundryHostUITests test
```

## Preview benchmark

```sh
node /Users/devan/.codex/plugins/cache/openai-curated-remote/build-ios-apps/0.1.2/skills/ios-simulator-browser/scripts/swiftui-preview-browser.mjs \
  /Users/devan/Documents/GitHub/ambitions/.worktrees/today-flagship-calibration-slice/Packages/AmbitionsPresentation/Package.swift \
  --package-target AmbitionsNativeVisualFoundry \
  --device EDE1E954-C663-47FB-855B-95F96AE2DBDD \
  --preview-filter 'TFCS-F01'
```

## Capture commands

```sh
xcrun simctl io EDE1E954-C663-47FB-855B-95F96AE2DBDD screenshot <evidence-path>.png
xcrun simctl io EDE1E954-C663-47FB-855B-95F96AE2DBDD recordVideo --codec=h264 <evidence-path>.mov
```

Host fixture variants selected the exact semantic state before each capture;
`TFCS-F03` additionally used a real native vertical drag. The three journey
recordings used deterministic fixture-host semantic walkthroughs.

## Final validation set

```sh
swift build --package-path Packages/AmbitionsPresentation --target AmbitionsNativeVisualFoundry
swift test --package-path Packages/AmbitionsPresentation
xcodegen generate
xcodebuild -project Ambitions.xcodeproj -scheme AmbitionsNativeFoundryHost -destination 'platform=iOS Simulator,id=EDE1E954-C663-47FB-855B-95F96AE2DBDD' build
xcodebuild -project Ambitions.xcodeproj -scheme AmbitionsNativeFoundryHost -destination 'platform=iOS Simulator,id=EDE1E954-C663-47FB-855B-95F96AE2DBDD' -only-testing:AmbitionsNativeFoundryHostUITests test
swiftlint lint --strict <changed Swift files>
python3 scripts/ambitions-canon.py build
python3 scripts/ambitions-canon.py check
python3 -m unittest discover -s tools/tests -p 'test_ambitions_canon_compiler.py'
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/ambitions-runtime-direct-write-audit.py
python3 scripts/ci/ambitions-no-weak-implementation-scan.py
GITHUB_BASE_SHA=f2781053d1ffcf962f112014b37d916bd677c450 bash scripts/ci/ambitions-gitleaks-scan.sh
git diff --check f2781053d1ffcf962f112014b37d916bd677c450 HEAD
```

Machine-readable screenshot and journey metadata are additionally checked for
schema fields and counts with `jq`; file existence and byte sizes with `test`
and `stat`; SHA-256 with `shasum -a 256`; PNG dimensions with `sips`; and MOV
duration with an `xcrun swift` AVFoundation read. Every recorded value is
compared to its metadata, with a 0.02-second duration tolerance.
`validation-results.md` records the exact fresh outcomes.
