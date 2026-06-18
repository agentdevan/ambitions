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

This writes ignored local `.codex/xcode-*` output for the current run.

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

Use focused lanes before broad test runs when the touched scope is narrow.

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
