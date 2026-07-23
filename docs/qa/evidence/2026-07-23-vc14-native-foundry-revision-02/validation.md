# VC-14 Native Foundry revision 02 validation

Date: 2026-07-23

Revision parent: `c72634655ec24958fb33aee195e9ec991bcbb597`

Branch: `codex/vc14-native-foundry-bootstrap`

## Test-driven Adaptive Navigation Passage contract

The focused test first asserted the locked roots and global-action groups before
the typed command contract existed.

```sh
swift test --package-path Packages/AmbitionsPresentation \
  --filter TodayBootstrapFixtureTests/testAdaptiveNavigationPassageKeepsLockedOrderAndGrouping
```

EXPECTED FAIL — the test target did not compile because
`TodayBootstrapNavigationCommand` was not in scope. After adding the internal
Foundry-only command contract and passage, the same command passed with 1 test
and 0 failures.

## Foundry package and lightweight tests

```sh
swift build --package-path Packages/AmbitionsPresentation \
  --target AmbitionsNativeVisualFoundry
```

PASS — target build completed in 6.64 seconds.

```sh
swift test --package-path Packages/AmbitionsPresentation
```

PASS — build completed in 4.34 seconds; 9 tests executed with 0 failures (5
presentation contract tests and 4 Foundry fixture tests).

```sh
swiftlint lint --strict --reporter xcode \
  Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayBootstrapView.swift \
  Packages/AmbitionsPresentation/Tests/AmbitionsNativeVisualFoundryTests/TodayBootstrapFixtureTests.swift
```

PASS — 2 changed Swift files, 0 violations.

## Fixture-only host build

```sh
xcodebuild \
  -project Ambitions.xcodeproj \
  -scheme AmbitionsNativeFoundryHost \
  -configuration Debug \
  -destination id=EDE1E954-C663-47FB-855B-95F96AE2DBDD \
  -derivedDataPath /tmp/ambitions-vc14-native-foundry-revision02-derived-data \
  CODE_SIGNING_ALLOWED=NO \
  build
```

PASS — `** BUILD SUCCEEDED **` against the iPhone 17 Pro Simulator in 7.659
seconds. No clean was used.

## Native render, passage, and scroll verification

The existing fixture-only host launched the three unchanged preview variants
on the iPhone 17 Pro Simulator. Direct `simctl io` capture produced real 1206 ×
2622 native frames. The accessibility host rendered the Adaptive Navigation
Passage in normal scroll flow with the locked command order and separate
Roots/Global actions groups.

The continuation evidence used a real vertical pointer drag through the booted
Simulator before direct capture. It exposes the action and later timeline
content after upstream content naturally exits through the top scroll boundary;
it is not a synthetic viewport or a loaded preview page.

Manual inspection of every full-resolution capture confirms:

- Light and Dark have identical anatomy and the same object-first hierarchy.
- No resting text is clipped, covered, or placed beneath the ordinary Peek
  envelope. The ordinary layout keeps 68 points of trailing content reserve.
- The visible Peek seam remains small and edge-attached while its interaction
  envelope is 44 × 64 points.
- The accessibility passage has no overlay dock; every command has at least a
  52-point row target, and the remaining Today content is naturally scrollable.
- In the continuation capture, only content that has naturally passed the top
  boundary is clipped; all visible text is unobscured.

`screenshot-metadata.json` records dimensions, capture times, byte sizes, and
SHA-256 digests. A metadata-to-file audit passed for all six listed PNGs,
including exact hash, byte-size, width, and height matches.

## Fresh canon and compiler checks

No canon source, generated canon, compiler, or authority file changed.

```sh
python3 scripts/ambitions-canon.py check
```

PASS — 66 documents, 466 requirements, 47 UX screens, 39 visual contracts, 16
local links, and 26 JSON files checked with no generated-output drift.

```sh
python3 -m unittest discover -s tools/tests \
  -p 'test_ambitions_canon_compiler.py'
```

PASS — 44 tests executed in 13.290 seconds with 0 failures.

The VC-14 authority remains unchanged: VC-01 through VC-14 and the planning
program are closed; Figma authorization and all broad implementation,
reconstruction, and cutover gates remain false; the four narrow Foundry
calibration permissions remain true; direct-device proof remains required and
incomplete.

## Boundary and diff hygiene

```sh
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/ambitions-runtime-direct-write-audit.py
python3 scripts/ci/ambitions-no-weak-implementation-scan.py
```

PASS — local-first boundaries green; no unsafe/unknown production direct-write
rows; no newly introduced weak implementation patterns.

```sh
git diff --check c72634655ec24958fb33aee195e9ec991bcbb597
jq empty \
  docs/qa/evidence/2026-07-23-vc14-native-foundry-revision-02/screenshot-metadata.json
```

PASS — whitespace and JSON syntax clean.

The source scan also confirms that the viewport contains no generic
`Open navigation` intermediary, decorative `Circle()` timeline bullet, Back
chevron, or repeated `Divider` anatomy.

## Changed-path audit

Relative to revision parent `c72634655ec24958fb33aee195e9ec991bcbb597`, the
only changed paths are:

```text
Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayBootstrapView.swift
Packages/AmbitionsPresentation/Tests/AmbitionsNativeVisualFoundryTests/TodayBootstrapFixtureTests.swift
docs/qa/evidence/2026-07-23-vc14-native-foundry-revision-02/**
```

Audit result:

- No canon, compiler, generated authority, or VC authority path changed.
- No package manifest, lockfile, dependency, fixture, preview declaration,
  fixture-only host, project configuration, or Foundry boundary changed.
- No path under `Native/Ambitions/` changed; the live app entry is untouched.
- No legacy frontend path changed; no runtime adapter or runtime dependency was
  introduced.
- No other root, matched-matrix frame, or complete Today journey was added.

## Warm-loop result

The unchanged package-backed preview workflow rendered two kept warm revisions
in 10 seconds and 10 seconds (2/2 success). Both are excellent. See
`benchmark-report.md` for timestamps and the exact launcher command.
