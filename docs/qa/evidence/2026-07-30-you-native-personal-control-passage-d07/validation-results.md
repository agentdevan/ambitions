<!-- markdownlint-disable MD013 -->

# Validation Results

Status: `PASS`

Native proving ID: `AVF-YOU-D07-INT-D07-NATIVE-R01`

Captured source: `801e64094947a786d32097c6ce53e20f3863b47b`

## Native package and fixture host

- `swift build --package-path Packages/AmbitionsPresentation`: pass.
- `swift test --package-path Packages/AmbitionsPresentation --filter YouNativeCalibration`: pass, 6 tests and 0 failures.
- `AmbitionsNativeFoundryHost` Simulator `build-for-testing`: pass, `TEST BUILD SUCCEEDED`.
- Focused `YouNativeCalibrationD07HostUITests`: pass, 3 tests and 0 failures.

The new product-facing Appearance assertion first failed against R00 on `Current truth` and the fixture persistence disclaimer, then passed after the bounded revision. Xcode emitted its existing non-fatal `DebuggerLLDB.DebuggerVersionStore.StoreError` launch-snapshot diagnostic; the focused tests continued and passed.

## Interaction and accessibility assertions

- Root to Appearance uses the existing `NavigationStack` and typed route.
- The framework Back button is present and hittable.
- Back returns to the root at the originating scroll position and exposes Appearance as the return target.
- Appearance depth semantic order is current appearance, native selection, action accent, preview identity, preview truth, and preview action.
- Decorative accent circles remain hidden from accessibility.
- Rendered accessibility labels and values contain no fixture, proof, architecture, implementation, visual-authority, or production-enum language.
- Root Dynamic Type behavior and all-nine-domain order remain unchanged.

These automated semantic checks are not manual VoiceOver, Switch Control, Voice Control, Full Keyboard Access, long-localization, RTL, or physical-device proof.

## Captures and R00 comparison

- Exactly three required PNG files exist; each is 1206 × 2622 pixels.
- `01-you-root-typical-dark.png`: byte-identical to R00; SHA-256 unchanged.
- `02-you-appearance-depth-dark.png`: intentionally changed; SHA-256 changed.
- `03-you-root-accessibility-dark.png`: byte-identical to R00; SHA-256 unchanged.
- Metadata parses as JSON and records device, OS, appearance, Dynamic Type, fixture identity, exact captured-source commit, hashes, R00 comparison, `production_baseline = false`, `direct_device_proof = false`, and `approved_for_swiftui = false`.
- The revised Appearance image was inspected at original resolution.

## Bounded repository checks

- SwiftLint 0.63.2 on the two changed Swift files: pass, 0 violations.
- Local Markdown links in changed records: pass.
- Changed-path audit: pass; only the Foundry Appearance view, its focused UI test, existing You packet records, and the existing evidence package changed.
- `git diff --check`: pass.
- Introduced-range Gitleaks: pass.
- Final worktree inspection: pass; branch clean after evidence commit.

No canon compilation, broad repository audit, external-link check, unrelated test suite, production-app reconstruction check, manual Xcode session, or physical-device lane ran.
