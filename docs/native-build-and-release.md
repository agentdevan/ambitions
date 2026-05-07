# Native Build And Release

This repo does not check in an `.xcodeproj`. Native contributors generate the project from `project.yml`, then build and validate the `Ambitions` scheme from Xcode or `xcodebuild`.

Hosted workflows are intentionally absent. Current Ambitions validation is local/Codex-operated only, through checked-in scripts, explicit local terminal logs, local Xcode / `xcodebuild` commands, proof artifacts, and terminal gates.

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

## Release Candidate Decision Status

R05 records the current repo release posture in `ReleaseCandidateLockDecisionReport` as `Candidate prepared; human approval required`.

That status is not a substitute for the native release workflow below. TestFlight, App Store submission, final RC lock, and public accessibility/platform claims still require terminal physical-device proof, manual accessibility proof, signed archive/App Store Connect validation, rendered external-surface checks, current store assets, live support/privacy URLs, and explicit human approval.

## Local Validation Coverage

Local validation should preserve the same evidence categories formerly represented by hosted validation, without treating hosted runs or artifacts as current proof.

At minimum, local proof packets should include:

- repo status and commit identity
- project generation
- package dependency resolution
- simulator build
- unit tests
- UI tests
- unsigned Release archive sanity
- signed App Store validation handoff when the release gate requires it
- explicit non-claim notes for device, App Store, TestFlight, public accessibility, legal/privacy, and human approval gaps

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

## Resolve Swift Package Dependencies

```bash
xcodebuild \
  -project Ambitions.xcodeproj \
  -scheme Ambitions \
  -resolvePackageDependencies
```

Expected output:

- package resolution completes without unresolved dependency errors

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

The current UI suite launches the app with `AMBITIONS_BOOTSTRAP_MODE=preview`, so it validates preview-backed user flows rather than a signed production install path.

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

This unsigned archive is not installable proof, TestFlight proof, App Store proof, signed-RC proof, or physical-device proof.

## Signed App Store Validation

This repo does not include signing identities, provisioning profiles, or App Store Connect credentials, so final Apple-side validation remains a local Mac release step:

1. Regenerate the project with `xcodegen generate`.
2. Open `Ambitions.xcodeproj` in Xcode.
3. Select the `Ambitions` scheme and a generic iOS device destination.
4. Run `Product > Archive`.
5. In Organizer, choose `Validate App` for App Store checks.
6. Use `Distribute App` only after validation passes and the owning release gate explicitly authorizes distribution.

These signed validation or distribution steps are not proven by docs alone.

## R04 External Truth Packet

`ReleaseExternalTruthReadinessPacket` records the current App Store/privacy/marketing/demo truth from repo evidence. It is useful for drafting metadata and review materials, but it is not a signed archive, App Store Connect validation, screenshot set, support URL proof, TestFlight upload, physical-device proof, or RC lock.

Before submission, reconcile the packet against:

- the final signed build and bundle metadata
- current App Store screenshots from privacy-safe demo data
- live support and privacy URLs
- App Privacy disclosures for the submitted binary
- terminal physical-device proof for external surfaces where enabled
- human approval recorded during the R05 gate

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

## Physical Device Terminal Gate

Physical-device proof is terminal-only. It may not be used as a discovery phase.

Before device proof begins, all feature, product-object, primitive, intelligence, source/freshness, accessibility, visual, performance, privacy/legal, platform, release, signed-RC, and claim-safety gates must close.

If the physical-device gate fails, the release candidate is invalidated and the train routes back to the owning repair batch. No code changes occur inside the device gate.

The future terminal device gate is documented in:

- [codex/batches/DPTG00_Physical_Device_Terminal_Gate_Lock_Prompt.md](codex/batches/DPTG00_Physical_Device_Terminal_Gate_Lock_Prompt.md)
- [codex/FLAGSHIP_IMPLEMENTATION_UPGRADE_OVERLAY.md](codex/FLAGSHIP_IMPLEMENTATION_UPGRADE_OVERLAY.md)

## What Local Validation Does Not Validate

Local simulator/build/archive evidence does not claim the following unless a later owning release gate records matching proof:

- signed archives
- provisioning profile correctness
- TestFlight upload readiness
- App Store Connect validation
- App Store distribution
- physical-device install or runtime behavior
- public accessibility conformance
- legal/privacy compliance
- human approval

R03 adds a code-backed simulator/source readiness ledger in `ReleaseDeviceQAReadinessReport`, but it does not replace the terminal physical-device gate. Do not use TestFlight-ready, real-device verified, or App Store-ready language until the terminal gate has separate evidence.
