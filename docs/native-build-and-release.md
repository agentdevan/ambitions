# Native Build And Release

This repo does not check in an `.xcodeproj`. Native contributors generate the project from `project.yml`, then build and validate the `Ambitions` scheme from Xcode or `xcodebuild`.

## Prerequisites

- macOS with Xcode 16 or newer
- Xcode command-line tools selected via `xcode-select`
- Homebrew-installed XcodeGen: `brew install xcodegen`

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
  -destination "platform=iOS Simulator,name=iPhone 16" \
  CODE_SIGNING_ALLOWED=NO \
  build
```

Expected output:

- `** BUILD SUCCEEDED **`

If your local Xcode image does not have `iPhone 16`, substitute any available simulator from:

```bash
xcrun simctl list devices available
```

## Run Unit And UI Tests

Run the full native suite:

```bash
xcodebuild \
  -project Ambitions.xcodeproj \
  -scheme Ambitions \
  -destination "platform=iOS Simulator,name=iPhone 16" \
  test
```

Run only the UI suite:

```bash
xcodebuild \
  -project Ambitions.xcodeproj \
  -scheme Ambitions \
  -destination "platform=iOS Simulator,name=iPhone 16" \
  -only-testing:AmbitionsUITests \
  test
```

Expected output:

- `Test Succeeded`

## Archive Sanity Check

Unsigned archive generation validates release-mode compilation, app icon wiring, the privacy manifest, and bundle assembly:

```bash
xcodebuild \
  -project Ambitions.xcodeproj \
  -scheme Ambitions \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -archivePath output/Ambitions.xcarchive \
  CODE_SIGNING_ALLOWED=NO \
  archive
```

Expected output:

- `** ARCHIVE SUCCEEDED **`
- `output/Ambitions.xcarchive`

## Signed App Store Validation

This repo does not include signing identities or App Store Connect credentials, so final App Store validation remains a Mac-hosted release step:

1. Regenerate the project with `xcodegen generate`.
2. Open `Ambitions.xcodeproj` in Xcode.
3. Select the `Ambitions` scheme and a generic iOS device destination.
4. Run `Product > Archive`.
5. In Organizer, choose `Validate App` for App Store checks and `Distribute App` when validation passes.

## CI Coverage

GitHub Actions currently verifies the XcodeGen spec, generates `Ambitions.xcodeproj`, resolves packages, lists the scheme, and runs an unsigned simulator build on `macos-latest`.
