# Exact command ledger

Commands ran from the isolated worktree. No `clean` command was used.

## Preflight and ownership

```sh
git fetch origin
git rev-parse main origin/main HEAD
git status --short --branch
python3 scripts/ambitions-canon.py query "Today"
python3 scripts/ambitions-canon.py query "Still counts"
```

The R01 screenshots and complete J01/J02/J03 recordings were inspected before
changing navigation, presentation, scrolling, focus, or settlement behavior.

## Builds and focused tests

```sh
swift build --package-path Packages/AmbitionsPresentation --target AmbitionsNativeVisualFoundry
swift test --package-path Packages/AmbitionsPresentation
xcodebuild -project Ambitions.xcodeproj -scheme AmbitionsNativeFoundryHost \
  -destination 'platform=iOS Simulator,id=EDE1E954-C663-47FB-855B-95F96AE2DBDD' build
xcodebuild -project Ambitions.xcodeproj -scheme AmbitionsNativeFoundryHost \
  -destination 'platform=iOS Simulator,id=EDE1E954-C663-47FB-855B-95F96AE2DBDD' test
```

## Preview benchmark

```sh
node /Users/devan/.codex/plugins/cache/openai-curated-remote/build-ios-apps/0.1.2/skills/ios-simulator-browser/scripts/swiftui-preview-browser.mjs \
  Packages/AmbitionsPresentation/Package.swift \
  --package-target AmbitionsNativeVisualFoundry \
  --device EDE1E954-C663-47FB-855B-95F96AE2DBDD \
  --preview-filter 'TFCS-F01'
```

## Native media

```sh
xcrun simctl io EDE1E954-C663-47FB-855B-95F96AE2DBDD screenshot <path>.png
xcrun simctl io EDE1E954-C663-47FB-855B-95F96AE2DBDD recordVideo --codec=h264 --force <path>.mov
xcrun xcresulttool export attachments --path <F03-result>.xcresult --output-path <directory>
```

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
GITHUB_BASE_SHA=065fa6e9c796381703e5d6f5364a1669c4b3fe7b bash scripts/ci/ambitions-gitleaks-scan.sh --range-only
git diff --check 065fa6e9c796381703e5d6f5364a1669c4b3fe7b HEAD
```

Metadata validation uses `jq`, `stat`, `shasum -a 256`, `sips`, and native
AVFoundation duration reads through `xcrun swift`.
