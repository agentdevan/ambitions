# VC-14 Native Foundry validation record

Date: 2026-07-23

Base: `8ae1a587fa6400cbf5495dd0c6457e8cb17016f3`

Branch: `codex/vc14-native-foundry-bootstrap`

## Exact outcomes

### Canon

```sh
python3 scripts/ambitions-canon.py build
```

PASS — 66 documents, 466 requirements, 47 UX screens, 39 visual contracts,
16 local links, and 24 JSON files generated.

```sh
python3 scripts/ambitions-canon.py check
```

PASS — the same source inventory validated with no generated-output drift.

```sh
python3 -m unittest discover -s tools/tests -p 'test_ambitions_canon_compiler.py'
```

PASS — 44 tests, 0 failures.

### Foundry package

```sh
swift build --package-path Packages/AmbitionsPresentation \
  --target AmbitionsNativeVisualFoundry
```

PASS — target build completed.

```sh
swift test --package-path Packages/AmbitionsPresentation
```

PASS — 8 tests, 0 failures: 5 presentation-contract tests and 3 focused
Foundry fixture tests.

### Fixture-only host and render

```sh
xcodegen generate
xcodebuild \
  -project Ambitions.xcodeproj \
  -scheme AmbitionsNativeFoundryHost \
  -configuration Debug \
  -destination id=DD9B9C84-7188-48FA-AA2A-AB5C1D0EE2B6 \
  -derivedDataPath /tmp/ambitions-vc14-native-foundry-derived-data \
  CODE_SIGNING_ALLOWED=NO \
  build
```

PASS — XcodeGen regenerated the ignored project state from `project.yml`; the
Simulator host build ended with `** BUILD SUCCEEDED **`.

```sh
xcrun simctl install DD9B9C84-7188-48FA-AA2A-AB5C1D0EE2B6 \
  /tmp/ambitions-vc14-native-foundry-derived-data/Build/Products/Debug-iphonesimulator/AmbitionsNativeFoundryHost.app
xcrun simctl launch --terminate-running-process \
  DD9B9C84-7188-48FA-AA2A-AB5C1D0EE2B6 \
  com.ambitions.ios.nativefoundry -FoundryVariant typical-light
xcrun simctl io DD9B9C84-7188-48FA-AA2A-AB5C1D0EE2B6 \
  screenshot /tmp/vc14-final-render.png
```

PASS — process `26611` ran the fixture host with `typical-light`; `simctl`
captured a real 1320 × 2868 PNG native frame. This post-repair render is
temporary verification; the three tracked evaluation frames and their hashes
are in `screenshot-metadata.json`.

XcodeBuildMCP session initialization was attempted twice and returned
`Transport closed`, including after `make native-mcp-lifecycle-check` passed.
This is recorded as a tool-path failure. The required Path B result was still
proved with the allowed normal incremental Xcode/Simulator workflow.

### Changed-scope quality lanes

```sh
swiftlint lint --strict --reporter xcode \
  $(git diff --name-only 8ae1a587fa6400cbf5495dd0c6457e8cb17016f3 -- '*.swift')
```

PASS — 7 changed Swift files linted, 0 violations.

```sh
GITHUB_BASE_SHA=8ae1a587fa6400cbf5495dd0c6457e8cb17016f3 \
  bash scripts/ci/ambitions-gitleaks-scan.sh --range-only
```

PASS — 6 commits scanned, no leaks found.

```sh
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/ambitions-runtime-direct-write-audit.py
python3 scripts/ci/ambitions-no-weak-implementation-scan.py
```

PASS — local-first boundaries green; no unsafe or unknown production direct
writes; no newly introduced weak implementation patterns.

```sh
git diff --check 8ae1a587fa6400cbf5495dd0c6457e8cb17016f3
jq empty docs/qa/evidence/2026-07-23-vc14-native-foundry-bootstrap/screenshot-metadata.json
```

PASS — whitespace and JSON syntax clean.

## Changed-path audit

The base-to-branch diff contains exactly these 38 paths:

```text
.agents/skills/ambitions-native-visual-foundry/SKILL.md
Native/AmbitionsNativeFoundryHost/AmbitionsNativeFoundryHostApp.swift
Packages/AmbitionsPresentation/Package.swift
Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayBootstrapContent.swift
Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayBootstrapFixture.swift
Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayBootstrapPreviews.swift
Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayBootstrapView.swift
Packages/AmbitionsPresentation/Tests/AmbitionsNativeVisualFoundryTests/TodayBootstrapFixtureTests.swift
docs/adr/ADR-2026-07-23-native-visual-foundry-bootstrap-boundary.md
docs/canon/MANIFEST.toml
docs/canon/README.md
docs/canon/design/VC_14_NATIVE_MATCHED_CLOSURE.md
docs/canon/design/VISUAL_CLOSURE_INPUT_CONTRACT.md
docs/canon/design/VISUAL_SYSTEM_R1.md
docs/canon/design/vc-14-native-matched-closure.json
docs/canon/design/visual-closure-input-contract.json
docs/canon/generated/CODEX_START_HERE.md
docs/canon/generated/INDEX.md
docs/canon/generated/canon-index.json
docs/canon/generated/object-boundary-matrix.md
docs/canon/generated/requirement-graph.json
docs/canon/generated/requirement-traceability.json
docs/canon/generated/visual-authority-manifest.json
docs/canon/migration/UX_BLUEPRINT.md
docs/canon/migration/ux-blueprint-requirement-dispositions.json
docs/canon/migration/ux-blueprint.json
docs/qa/evidence/2026-07-23-vc14-native-foundry-bootstrap/benchmark-report.md
docs/qa/evidence/2026-07-23-vc14-native-foundry-bootstrap/manifest.md
docs/qa/evidence/2026-07-23-vc14-native-foundry-bootstrap/screens/today-bootstrap-accessibility-dynamic-type-dark.png
docs/qa/evidence/2026-07-23-vc14-native-foundry-bootstrap/screens/today-bootstrap-typical-dark.png
docs/qa/evidence/2026-07-23-vc14-native-foundry-bootstrap/screens/today-bootstrap-typical-light.png
docs/qa/evidence/2026-07-23-vc14-native-foundry-bootstrap/screenshot-metadata.json
docs/qa/evidence/2026-07-23-vc14-native-foundry-bootstrap/skill-validation.md
docs/qa/evidence/2026-07-23-vc14-native-foundry-bootstrap/validation.md
docs/superpowers/plans/2026-07-23-vc14-native-foundry-bootstrap.md
project.yml
tools/ambitions_canon/compiler.py
tools/tests/test_ambitions_canon_compiler.py
```

Audit result:

- No path under `Native/Ambitions/` changed; the live app entry
  `Native/Ambitions/App/AmbitionsApp.swift` is untouched.
- No existing legacy frontend path changed and no legacy view code was copied.
- The new host imports only `AmbitionsNativeVisualFoundry`; the live
  `Ambitions` target did not gain a dependency on the host or Foundry product.
- No `Package.resolved` changed, and no external URL/version dependency was
  added to `Package.swift` or `project.yml`.
- No runtime adapter or runtime module dependency was added to the Foundry
  target.
- Source search found none of the temporary benchmark mutation markers.
- Only the one requested repository-local skill was added.

## Authority result

The source record and generated authority manifest agree:

- VC-01 through VC-14: `CLOSED`
- Visual-closure planning program: `CLOSED`
- Figma, `APPROVED FOR SWIFTUI`, broad production implementation, broad
  frontend reconstruction, and legacy frontend cutover: `false`
- Native Visual Foundry bootstrap, fixture-driven previews, Today calibration
  slice, and screenshot owner review: narrowly authorized
- Direct-device proof: required and incomplete

The broad reconstruction gate remains closed. Owner visual review is the stop
condition for this bootstrap.
