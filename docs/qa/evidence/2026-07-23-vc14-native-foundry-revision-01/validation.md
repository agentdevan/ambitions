# VC-14 Native Foundry revision 01 validation

Date: 2026-07-23

Revision parent: `d42334f6c`

Branch: `codex/vc14-native-foundry-bootstrap`

## Test-driven fixture copy change

The focused `TodayBootstrapFixtureTests` expectation was first changed to
`Continue nursery setup` while the fixture still returned `Open step`.

```sh
swift test --package-path Packages/AmbitionsPresentation \
  --filter TodayBootstrapFixtureTests/testPreparingForBabyFixtureIsStableSparseAndSynthetic
```

EXPECTED FAIL — 1 test executed with 2 assertion failures, proving the old
generic label was still present. After changing only the fixture copy, the same
focused command passed with 1 test and 0 failures.

## Final package build and lightweight tests

```sh
swift build --package-path Packages/AmbitionsPresentation \
  --target AmbitionsNativeVisualFoundry
```

PASS — target build completed in 0.47 seconds.

```sh
swift test --package-path Packages/AmbitionsPresentation
```

PASS — build completed in 4.21 seconds; 8 tests executed with 0 failures (5
presentation contract tests and 3 Foundry fixture tests).

```sh
swiftlint lint --strict --reporter xcode \
  Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayBootstrapFixture.swift \
  Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayBootstrapView.swift \
  Packages/AmbitionsPresentation/Tests/AmbitionsNativeVisualFoundryTests/TodayBootstrapFixtureTests.swift
```

PASS — 3 changed Swift files, 0 violations.

## Fixture-only host build

```sh
xcodebuild \
  -project Ambitions.xcodeproj \
  -scheme AmbitionsNativeFoundryHost \
  -configuration Debug \
  -destination id=EDE1E954-C663-47FB-855B-95F96AE2DBDD \
  -derivedDataPath /tmp/ambitions-vc14-native-foundry-revision-derived-data \
  CODE_SIGNING_ALLOWED=NO \
  build
```

PASS — `** BUILD SUCCEEDED **` against the iPhone 17 Pro Simulator. No clean
was used.

## Native render and scroll verification

The host was installed and launched with the existing `-FoundryVariant`
arguments. The final launches returned live process IDs `38478`, `38535`, and
`42981` for Typical Dark, Typical Light, and Accessibility Dark. `simctl io`
then captured real 1206 × 2622 native frames from the iPhone 17 Pro display.

The continuation evidence used a real vertical pointer drag through the booted
Simulator, followed by another direct `simctl io` capture. It exposes all three
timeline objects after the resting accessibility frame shows the timeline
beginning. This is a rendered interaction result, not a loaded preview page or
a synthetic screenshot.

Manual inspection of the full-resolution captures confirms:

- Light and Dark have identical hierarchy and reserved trailing dock space.
- No resting text is clipped, covered, or positioned beneath the ordinary
  dock's 44 × 88 point interaction envelope.
- The accessibility variant has no overlay dock; its navigation passage is in
  normal flow and all remaining timeline text is reachable by natural scroll.
- In the continuation capture, only upstream content that has naturally exited
  through the top scroll boundary is clipped; the visible timeline content is
  unobscured.
- The captures contain a native app frame, not preview-browser chrome.

Dimensions, capture times, byte sizes, and SHA-256 digests are recorded in
`screenshot-metadata.json`. A fresh metadata-to-file audit passed for all six
listed PNGs, including exact hash, byte-size, width, and height matches.

## Fresh canon and compiler checks

No canon source, generated canon, compiler, or authority file changed in this
revision.

```sh
python3 scripts/ambitions-canon.py check
```

PASS — 66 documents, 466 requirements, 47 UX screens, 39 visual contracts, 16
local links, and 25 JSON files checked with no generated-output drift.

```sh
python3 -m unittest discover -s tools/tests \
  -p 'test_ambitions_canon_compiler.py'
```

PASS — 44 tests executed in 18.013 seconds with 0 failures.

The existing VC-14 authority therefore remains unchanged: VC-01 through VC-14
and the planning program are closed; Figma authorization and all broad
implementation/reconstruction/cutover gates remain false; the four narrow
Foundry calibration permissions remain true; direct-device proof remains
required and incomplete.

## Boundary and diff hygiene

```sh
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/ambitions-runtime-direct-write-audit.py
python3 scripts/ci/ambitions-no-weak-implementation-scan.py
```

PASS — local-first boundaries green; no unsafe/unknown production direct-write
rows; no newly introduced weak implementation patterns.

```sh
git diff --check d42334f6c
jq empty \
  docs/qa/evidence/2026-07-23-vc14-native-foundry-revision-01/screenshot-metadata.json
```

PASS — whitespace and JSON syntax clean.

## Changed-path audit

Relative to revision parent `d42334f6c`, the only changed paths are:

```text
Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayBootstrapFixture.swift
Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayBootstrapView.swift
Packages/AmbitionsPresentation/Tests/AmbitionsNativeVisualFoundryTests/TodayBootstrapFixtureTests.swift
docs/qa/evidence/2026-07-23-vc14-native-foundry-revision-01/**
```

Audit result:

- No canon or authority path changed.
- No `project.yml`, package manifest, lockfile, dependency, preview-variant
  declaration, fixture host, or module boundary changed.
- No path under `Native/Ambitions/` changed; the live app entry is untouched.
- No legacy frontend path changed and no runtime adapter or runtime dependency
  was introduced.
- No other root, matrix frame, or complete Today journey was added.

## Warm-loop result

The unchanged package-backed preview workflow rendered two kept warm revisions
in 14 seconds and 11 seconds (2/2 success). Both are excellent. See
`benchmark-report.md` for timestamps and the exact launcher command.
