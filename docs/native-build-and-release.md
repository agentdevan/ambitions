# Native Build And Release

Ambitions does not check in `Ambitions.xcodeproj`. Generate it from `project.yml`, then build and validate the `Ambitions` scheme locally.

This document is a build/release front door only. It does not prove build success, test success, device readiness, TestFlight readiness, App Store readiness, accessibility conformance, privacy/legal approval, or human release approval.

## Prerequisites

- macOS with the active project Xcode installed
- Xcode command-line tools selected with `xcode-select`
- XcodeGen available on `PATH`

Bootstrap common local tooling:

```bash
./scripts/setup_macos_ios_dev.sh
```

## Generate The Project

```bash
xcodegen generate
```

Expected local output:

```text
Ambitions.xcodeproj
```

`Ambitions.xcodeproj` is generated and ignored. Source truth remains `project.yml`.

## Local Build

```bash
./scripts/build-local.sh
```

Equivalent manual build:

```bash
xcodebuild \
  -project Ambitions.xcodeproj \
  -scheme Ambitions \
  -sdk iphonesimulator \
  -destination "generic/platform=iOS Simulator" \
  CODE_SIGNING_ALLOWED=NO \
  build
```

## Build For Testing

```bash
./scripts/ambitions-xcode-build-for-testing.sh --batch LOCAL
```

This is the default broad local build proof lane. It writes ignored local
`.codex/xcode-*` output for the current run, uses the repo-local DerivedData
path, applies the retained wall-clock timeout policy, and records Xcode build
timing in the log.

## Focused Tests

```bash
./scripts/ambitions-xcode-test-focused.sh \
  --batch LOCAL \
  --test AmbitionsTests/SemanticDesignTokenCatalogTests
```

## Validation Wrapper

```bash
./scripts/ambitions-xcode-validate.sh --batch LOCAL --lane build-for-testing
```

Use focused lanes before broad test runs when the touched scope is narrow. For
test-plan execution, the validator prebuilds the matching scheme once and then
runs `test-without-building`:

```bash
./scripts/ambitions-xcode-validate.sh --batch LOCAL --lane test-plan --test-plan Smoke
./scripts/ambitions-xcode-validate.sh --batch LOCAL --lane ui-proof
```

Do not use XcodeBuildMCP build/test calls as the primary broad validation lane;
they can hit a tool timeout while the underlying `xcodebuild` is still actively
compiling. Use XcodeBuildMCP for simulator defaults, install/launch, screenshots,
and focused UI interaction proof.

## Release Assets

App icon set:

```text
Native/Ambitions/Resources/Assets.xcassets/AppIcon.appiconset
```

Regenerate app icons when explicitly scoped:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/generate_ios_app_icons.ps1
```

Privacy manifest:

```text
Native/Ambitions/Resources/PrivacyInfo.xcprivacy
```

## Archive Sanity Check

Unsigned archive generation validates Release-mode compilation and bundle assembly. It is not signing proof, install proof, TestFlight proof, App Store proof, or physical-device proof.

```bash
xcodebuild \
  -project Ambitions.xcodeproj \
  -scheme Ambitions \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -archivePath output/Ambitions.xcarchive \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGN_IDENTITY="" \
  archive
```

## Signed App Store Validation

This repo does not include signing identities, provisioning profiles, App Store Connect credentials, support URL proof, privacy URL proof, or public release approval.

Final Apple-side validation requires a local Mac release step:

1. Regenerate the project with `xcodegen generate`.
2. Open `Ambitions.xcodeproj` in Xcode.
3. Select the `Ambitions` scheme and a generic iOS device destination.
4. Run `Product > Archive`.
5. In Organizer, choose `Validate App`.
6. Distribute only after validation passes and the owning release gate explicitly authorizes distribution.

## Required Evidence For Release Claims

Release-facing claims must cite current evidence:

- branch and commit SHA
- date/time and environment
- Xcode and XcodeGen versions when relevant
- exact command or manual procedure
- destination/simulator/device
- exit code and summarized output
- artifact path when applicable
- explicit non-claims for skipped proof

Use [truth/RELEASE_TRUTH.md](truth/RELEASE_TRUTH.md) as the claim boundary.

## Current Document Validation Metadata

- Branch: `main`
- Commit SHA: `162182e62e179c5a148be8d71d108660855acdef`
- Environment: local macOS Ambitions workspace at `/Users/devan/Documents/GitHub/ambitions`
- Xcode version: `Xcode 26.6 (17F113)`
- XcodeGen version: `2.45.4`
- Simulator / Destination: `iOS Simulator DD9B9C84-7188-48FA-AA2A-AB5C1D0EE2B6` for focused validation

Validation run:

- `bash -n scripts/ambitions-xcode-build-for-testing.sh scripts/ambitions-xcode-test-focused.sh scripts/ambitions-xcode-test-plan.sh scripts/ambitions-xcode-validate.sh scripts/ambitions-xcode-benchmark.sh scripts/ambitions-run-ui-screenshot-matrix.sh` -> exit code `0`.
- `scripts/ambitions-bounded-xcodebuild.sh --timeout 1m --kill-after 10s --log .codex/xcode-logs/BUILD_PROCESS_OPTIMIZATION/xcodebuild-version.log -- -version` -> exit code `0`.
- `scripts/ambitions-xcode-validate.sh --batch BUILD_PROCESS_OPTIMIZATION --lane none --json` -> exit code `10`, expected skipped/no-validation sentinel.
- `scripts/ambitions-xcode-validate.sh --batch BUILD_PROCESS_OPTIMIZATION_FOCUSED_V3 --lane focused-test --test AmbitionsTests/StageBackGestureTests --json` -> exit code `0`, `focused_executed_tests=3`, `duration_seconds=100`.
- `git diff --check` -> exit code `0`.
- `python3 scripts/ambitions-release-non-claim-gate.py docs/native-build-and-release.md` -> exit code `0`.
- `python3 scripts/ambitions-flagship-ios-standards-check.py` -> exit code `0`.
- `python3 scripts/ambitions-quality-gate.py --self-test` -> exit code `0`.
- `python3 scripts/ambitions-quality-gate.py` -> exit code `0`.

Validation not run:

- Full build-for-testing was not rerun after this document edit; this page describes the build process and does not claim broad build success.
- Full UI suite, physical-device validation, signed archive, TestFlight upload, App Store validation, privacy/legal review, and manual accessibility proof were not run by this document update.

Exit code summary:

- Script syntax, wrapper smoke, focused validation, whitespace check, and flagship standards check passed.
- The no-validation validate lane intentionally returned `10` and is labeled `skipped`, not build/test failure.

Proof artifacts:

The local `.codex` paths below are local working evidence for wrapper behavior
only; they are not visual acceptance, device readiness, release readiness, or
App Store/TestFlight proof.

- `.codex/xcode-logs/BUILD_PROCESS_OPTIMIZATION/xcodebuild-version.log`
- `.codex/xcode-logs/BUILD_PROCESS_OPTIMIZATION_FOCUSED_V3/20260707T183800Z-AmbitionsTests-StageBackGestureTests-30036-27444/focused-test.log`
- `.codex/xcode-summaries/BUILD_PROCESS_OPTIMIZATION_FOCUSED_V3/20260707T183757Z-validate-29824-26507/validate-summary.json`
- `.codex/xcode-benchmarks/BUILD_PROCESS_OPTIMIZATION_FOCUSED_V3/20260707T183757Z-validate-29824-26507/validate-benchmark.json`
- `.codex/xcode-results/BUILD_PROCESS_OPTIMIZATION_FOCUSED_V3/20260707T183800Z-AmbitionsTests-StageBackGestureTests-30036-27444/focused-test.xcresult`

Non-Claims:

- This document update does not prove release readiness, build success for every target, full test success, UI suite success, device readiness, TestFlight readiness, App Store readiness, accessibility conformance, privacy/legal approval, or human release approval.
