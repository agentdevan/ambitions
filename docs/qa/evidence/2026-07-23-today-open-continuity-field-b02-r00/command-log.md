# Command log

Phase 0 commands were run from the isolated B02 worktree.

```sh
git fetch origin
git rev-parse HEAD main origin/main codex/today-flagship-calibration-slice
git status --short --branch
shasum -a 256 <owner-reference> <B01-full-matrix>
python3 scripts/ambitions-canon.py query "Today"
python3 scripts/ambitions-canon.py query "Start Here"
python3 scripts/ambitions-canon.py query "Crowned Edge Dock"
python3 scripts/ambitions-canon.py query "Still counts"
swift build --package-path Packages/AmbitionsPresentation --target AmbitionsNativeVisualFoundry
swift test --package-path Packages/AmbitionsPresentation
xcodegen generate
xcodebuild -project Ambitions.xcodeproj -scheme AmbitionsNativeFoundryHost \
  -destination 'platform=iOS Simulator,id=EDE1E954-C663-47FB-855B-95F96AE2DBDD' \
  build CODE_SIGNING_ALLOWED=NO
git diff --check
```

No `clean` command was used. XcodeGen produced ignored local project state from
the unchanged tracked `project.yml`.

## Implementation and warm-loop commands

The package-backed preview loop used the repository package directly:

```sh
node /Users/devan/.codex/plugins/cache/openai-curated-remote/build-ios-apps/0.1.2/skills/ios-simulator-browser/scripts/swiftui-preview-browser.mjs \
  Packages/AmbitionsPresentation/Package.swift \
  --package-target AmbitionsNativeVisualFoundry \
  --device EDE1E954-C663-47FB-855B-95F96AE2DBDD \
  --preview-filter '<phase preview filter>'
```

Source-changing warm reloads were run during root, focused-object, and
motion/material composition. Intended source was restored after each benchmark.
No host relaunch, injection dependency, or clean build was used for warm runs.

Recurring changed-scope validation:

```sh
swift build --package-path Packages/AmbitionsPresentation \
  --target AmbitionsNativeVisualFoundry
swift test --package-path Packages/AmbitionsPresentation
xcodebuild -project Ambitions.xcodeproj \
  -scheme AmbitionsNativeFoundryHost \
  -destination 'platform=iOS Simulator,id=EDE1E954-C663-47FB-855B-95F96AE2DBDD' \
  build CODE_SIGNING_ALLOWED=NO
swiftlint lint --strict <changed Swift paths>
git diff --check
```

Simulator accessibility/adaptivity inspection used `xcrun simctl ui` for
supported system settings, device-specific host variants, and the focused host
UI matrix. Settings were restored to Dark, Large, Increased Contrast disabled
after capture.

## Final verification commands and outcomes

The final run used the commands below. No command used `clean`.

```sh
swift build --package-path Packages/AmbitionsPresentation \
  --target AmbitionsNativeVisualFoundry
swift test --package-path Packages/AmbitionsPresentation
xcodebuild -project Ambitions.xcodeproj \
  -scheme AmbitionsNativeFoundryHost \
  -destination 'platform=iOS Simulator,id=396F4B4A-2DAD-4345-B26E-ABD2EF69BF5E' \
  build CODE_SIGNING_ALLOWED=NO
xcodebuild -project Ambitions.xcodeproj \
  -scheme AmbitionsNativeFoundryHost \
  -destination 'platform=iOS Simulator,id=396F4B4A-2DAD-4345-B26E-ABD2EF69BF5E' \
  test-without-building \
  -skip-testing:AmbitionsNativeFoundryHostUITests/TodayFlagshipCalibrationHostUITests/testArabicSaudiFixtureRendersGenuineRTLAndLocalizedReviewCopy \
  -skip-testing:AmbitionsNativeFoundryHostUITests/TodayFlagshipCalibrationHostUITests/testB02ArabicRootAndDockLabelTreeContainsNoUnapprovedEnglish \
  -skip-testing:AmbitionsNativeFoundryHostUITests/TodayFlagshipCalibrationHostUITests/testB02AccessibilityAndAdaptivityMatrix \
  CODE_SIGNING_ALLOWED=NO
git diff --name-only 92048f7622b06f78ee6e5667e84facd0c4beb2f4..HEAD \
  -- '*.swift' | xargs swiftlint lint --strict
python3 scripts/ambitions-canon.py build
python3 -m unittest discover -s tools/tests \
  -p 'test_ambitions_canon_compiler.py'
python3 scripts/ambitions-canon.py check
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/ambitions-runtime-direct-write-audit.py
python3 scripts/ci/ambitions-no-weak-implementation-scan.py
bash scripts/ci/ambitions-gitleaks-scan.sh
GITHUB_BASE_SHA=92048f7622b06f78ee6e5667e84facd0c4beb2f4 \
  bash scripts/ci/ambitions-gitleaks-scan.sh --range-only
python3 /tmp/b02_validate_metadata.py
xcodegen generate
git diff --check
```

Outcomes: target build passed; 50 package tests passed; fixture-host build
passed; 33 English-only UI tests passed in 823.675 seconds; SwiftLint reported
0 violations across 24 paths; canon build/check and 44 compiler tests passed;
boundary and direct-write scans were GREEN; full and B01-to-B02 Gitleaks scans
found no leaks; 25 screenshot, five recording, and four contact-sheet metadata
rows passed integrity validation; reference hashes and protected paths remained
unchanged.

Final command log status: `COMPLETE`.

## Recording commands

Each journey used a continuous native framebuffer recording around its passing
XCUI driver:

```sh
xcrun simctl io 396F4B4A-2DAD-4345-B26E-ABD2EF69BF5E \
  recordVideo --force /tmp/TFCS-J0X-raw.mov
xcodebuild ... test-without-building \
  -only-testing:AmbitionsNativeFoundryHostUITests/TodayFlagshipCalibrationHostUITests/testB02J0X...
```

AVFoundation passthrough trimming removed Simulator pre-roll and post-test Home
frames. Representative samples from every final movie were visually inspected.

The final visual review found a residual Home transition in J03, J04, and J05.
The bounded evidence repair used `avconvert` with `PresetPassthrough` to trim the
three files to 44.5, 23.7, and 13.9 seconds. Metadata hashes and durations were
regenerated, and 99-percent-duration samples from each revised movie were
visually verified as Foundry-host frames before final metadata validation.

## Task 11 committed regression guards

Commit: `133c040e5` (`test(foundry): lock open continuity behavior`).

Observed focused commands covered the full package suite, five English-only
recording drivers, recovery target geometry, History disclosure, and diff
checking. The final Phase 9 run must repeat the committed-SHA English-only UI
selection. Historical Arabic/RTL-only cases are not part of capture or proof.
