# Exact command ledger

Commands are run from the isolated B01 worktree. No `clean` command is used.

## Preflight and ownership

```sh
git fetch origin
git rev-parse main origin/main codex/today-flagship-calibration-slice HEAD
git status --short --branch
python3 scripts/ambitions-canon.py query "Today"
python3 scripts/ambitions-canon.py query "Still counts"
```

## Build and tests

```sh
swift build --package-path Packages/AmbitionsPresentation --target AmbitionsNativeVisualFoundry
swift test --package-path Packages/AmbitionsPresentation
xcodebuild -project Ambitions.xcodeproj -scheme AmbitionsNativeFoundryHost \
  -destination 'platform=iOS Simulator,id=EDE1E954-C663-47FB-855B-95F96AE2DBDD' build
xcodebuild -project Ambitions.xcodeproj -scheme AmbitionsNativeFoundryHost \
  -destination 'platform=iOS Simulator,id=EDE1E954-C663-47FB-855B-95F96AE2DBDD' test
```

The first complete closeout run exposed the 32-point Start Here accessibility
frame. After the narrow repair, the two affected tests were rerun with
`-only-testing`, followed by a fresh complete 14-test fixture-host suite. The
failed run and repair are part of the validation record; they are not hidden.

## Package preview

```sh
node /Users/devan/.codex/plugins/cache/openai-curated-remote/build-ios-apps/0.1.2/skills/ios-simulator-browser/scripts/swiftui-preview-browser.mjs \
  Packages/AmbitionsPresentation/Package.swift \
  --package-target AmbitionsNativeVisualFoundry \
  --device EDE1E954-C663-47FB-855B-95F96AE2DBDD \
  --preview-filter 'TFCS-F01'
```

## Native Foundry media

```sh
xcrun simctl io EDE1E954-C663-47FB-855B-95F96AE2DBDD screenshot --type=png <path>.png
xcrun simctl ui EDE1E954-C663-47FB-855B-95F96AE2DBDD increase_contrast enabled
xcodebuild test-without-building ... -only-testing:<B01 journey driver>
swift <AVAssetWriter frame-sequence encoder>
```

The first direct `simctl recordVideo` attempt was rejected because it retained
stale rendered regions across native presentations. Final recordings instead
use continuous Simulator framebuffer frames while the XCUI drivers perform the
real native journey. This correction is retained in the command history rather
than hidden.

## Repository validation

```sh
swiftlint lint --strict <changed Swift files>
python3 scripts/ambitions-canon.py build
python3 scripts/ambitions-canon.py check
python3 -m unittest discover -s tools/tests -p 'test_ambitions_canon_compiler.py'
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/ambitions-runtime-direct-write-audit.py
python3 scripts/ci/ambitions-no-weak-implementation-scan.py
bash scripts/ci/ambitions-gitleaks-scan.sh
GITHUB_BASE_SHA=77e818823b58ee2911e68962dd8bd8115e1d26aa bash scripts/ci/ambitions-gitleaks-scan.sh --range-only
git diff --check 77e818823b58ee2911e68962dd8bd8115e1d26aa HEAD
```

Metadata validation uses `jq`, `stat`, `shasum -a 256`, `sips`, and native
AVFoundation duration reads through `swift`.
