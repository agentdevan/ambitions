# Native Build And Release

This repo does not check in an `.xcodeproj`. Native contributors generate the project from `project.yml`, then build and validate the `Ambitions` scheme from Xcode or `xcodebuild`.

## Prerequisites

- macOS with Xcode 16 or newer
- Xcode command-line tools selected via `xcode-select`
- Homebrew-installed XcodeGen: `brew install xcodegen`

If you want the repo to bootstrap the common local CLI tooling for you, run:

```bash
./scripts/setup_macos_ios_dev.sh
```

That script installs the repo-required `xcodegen`, plus `xcbeautify`, `swiftformat`, and `swiftlint`, then regenerates `Ambitions.xcodeproj` and verifies the project is discoverable through `xcodebuild`.

## Generate The Project

From the repo root:

```bash
xcodegen generate
```

Expected output:

- `Ambitions.xcodeproj`

## Release Assets

The native target ships its icon set from `Native/Ambitions/Resources/Assets.xcassets/AppIcon.appiconset`.

To regenerate the icon PNGs and `Contents.json` from the repo-owned source script:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/generate_ios_app_icons.ps1
```

The privacy manifest lives at `Native/Ambitions/Resources/PrivacyInfo.xcprivacy`.

## Build The App

Unsigned simulator build:

```bash
xcodebuild \
  -project Ambitions.xcodeproj \
  -scheme Ambitions \
  -sdk iphonesimulator \
  -destination "generic/platform=iOS Simulator" \
  CODE_SIGNING_ALLOWED=NO \
  build
```

Expected output:

- `** BUILD SUCCEEDED **`

## Run Unit Tests

Native unit tests:

```bash
xcodebuild \
  -project Ambitions.xcodeproj \
  -scheme Ambitions \
  -destination "platform=iOS Simulator,name=<available-simulator-name>" \
  -only-testing:AmbitionsTests \
  test
```

Expected output:

- `Test Succeeded`

Choose any available simulator from:

```bash
xcrun simctl list devices available
```

## Run UI Tests

Native UI tests:

```bash
xcodebuild \
  -project Ambitions.xcodeproj \
  -scheme Ambitions \
  -destination "platform=iOS Simulator,name=<available-simulator-name>" \
  -only-testing:AmbitionsUITests \
  test
```

The current UI suite launches the app with `AMBITIONS_BOOTSTRAP_MODE=preview`, so it is intentionally CI-friendly and validates the preview-backed user flows rather than a signed production install path.

Expected output:

- `Test Succeeded`

## Run Tests Sequentially

When running unit tests and UI tests locally, prefer sequential runs.

If you need to keep multiple local runs separate, pass different DerivedData paths to avoid Xcode build database lock errors:

```bash
xcodebuild \
  -project Ambitions.xcodeproj \
  -scheme Ambitions \
  -derivedDataPath output/DerivedData-unit \
  -destination "platform=iOS Simulator,name=<available-simulator-name>" \
  -only-testing:AmbitionsTests \
  test

xcodebuild \
  -project Ambitions.xcodeproj \
  -scheme Ambitions \
  -derivedDataPath output/DerivedData-ui \
  -destination "platform=iOS Simulator,name=<available-simulator-name>" \
  -only-testing:AmbitionsUITests \
  test
```

## Archive Sanity Check

Unsigned archive generation validates Release-mode compilation, bundle assembly, app icon wiring, and the privacy manifest without pretending to perform signing or App Store validation:

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

Expected output:

- `** ARCHIVE SUCCEEDED **`
- `output/Ambitions.xcarchive`

## Signed App Store Validation

This repo does not include signing identities, provisioning profiles, or App Store Connect credentials, so final Apple-side validation remains a local Mac release step:

1. Regenerate the project with `xcodegen generate`.
2. Open `Ambitions.xcodeproj` in Xcode.
3. Select the `Ambitions` scheme and a generic iOS device destination.
4. Run `Product > Archive`.
5. In Organizer, choose `Validate App` for App Store checks.
6. Use `Distribute App` only after validation passes.

GitHub Actions does not perform these signed validation or distribution steps.

## Launch Planning And Submission Operations

Use the following documents together when the task is no longer just build/test/archive validation:

- [canon/Ambitions_Launch_Master_Checklist.md](canon/Ambitions_Launch_Master_Checklist.md)
  Locked launch strategy, launch doctrine, launch tracks, and now-to-launch phases.
- [canon/Ambitions_App_Store_Release_Compliance.md](canon/Ambitions_App_Store_Release_Compliance.md)
  Final submission-gate canon and conditional gate truth.
- [canon/Ambitions_Accessibility_Nutrition_Labels_Audit.md](canon/Ambitions_Accessibility_Nutrition_Labels_Audit.md)
  Honest accessibility-label audit and evidence requirements.
- [codex/Launch_Operator_Runbook.md](codex/Launch_Operator_Runbook.md)
  Short operator checklist for App Store Connect, TestFlight, metadata, reviewer notes, submission, and launch monitoring.

## GitHub Actions CI Coverage

The native CI workflow lives in [.github/workflows/ios-validate.yml](../.github/workflows/ios-validate.yml) and runs on `macos-15`.

### Build, Unit Tests, Archive job

This job verifies:

- `project.yml` can regenerate `Ambitions.xcodeproj`
- the generated project still exposes the expected scheme
- Swift package resolution succeeds
- the native app target builds for `iphonesimulator`
- `AmbitionsTests` pass on an available simulator
- an unsigned Release archive can be produced
- an unsigned `.ipa` container can be packaged from that archive and uploaded as an artifact with an explicit unsigned limitation note

Core commands used in CI:

```bash
xcodegen generate

xcodebuild \
  -project Ambitions.xcodeproj \
  -scheme Ambitions \
  -resolvePackageDependencies

xcodebuild \
  -project Ambitions.xcodeproj \
  -scheme Ambitions \
  -sdk iphonesimulator \
  -destination "generic/platform=iOS Simulator" \
  CODE_SIGNING_ALLOWED=NO \
  build

xcodebuild \
  -project Ambitions.xcodeproj \
  -scheme Ambitions \
  -destination "platform=iOS Simulator,id=<selected-simulator-udid>" \
  -only-testing:AmbitionsTests \
  test

xcodebuild \
  -project Ambitions.xcodeproj \
  -scheme Ambitions \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -archivePath "$RUNNER_TEMP/Ambitions.xcarchive" \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGN_IDENTITY="" \
  archive
```

CI then packages `Payload/Ambitions.app` from the unsigned archive into `Ambitions-unsigned.ipa` and uploads it as an artifact. This is intentionally not described as sideloadable or installable; device installation still requires signing and provisioning outside GitHub Actions.

### UI Tests job

This job verifies:

- the UI test bundle builds for testing
- the current preview-backed UI suite executes on a deterministic simulator destination

Core commands used in CI:

```bash
xcodebuild \
  -project Ambitions.xcodeproj \
  -scheme Ambitions \
  -destination "platform=iOS Simulator,id=<selected-simulator-udid>" \
  -only-testing:AmbitionsUITests \
  build-for-testing

xcodebuild \
  -project Ambitions.xcodeproj \
  -scheme Ambitions \
  -destination "platform=iOS Simulator,id=<selected-simulator-udid>" \
  -only-testing:AmbitionsUITests \
  test-without-building
```

The workflow selects the simulator dynamically from the first available preferred device in this order:

1. `iPhone 16 Pro`
2. `iPhone 16`
3. `iPhone 15 Pro`
4. `iPhone 15`

Both test jobs upload `.xcresult` bundles so failures can be inspected from GitHub Actions artifacts.

## What CI Does Not Validate

CI intentionally does not claim the following:

- signed archives
- provisioning profile correctness
- TestFlight upload readiness
- App Store Connect validation
- App Store distribution
- physical-device install or runtime behavior

R03 adds a code-backed simulator/source readiness ledger in `ReleaseDeviceQAReadinessReport`, but it does not replace this physical-device gate. Do not use TestFlight-ready, real-device verified, or App Store-ready language until the device checks above have separate evidence.
