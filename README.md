# Ambitions Native iOS App

Ambitions is a native iOS SwiftUI application.

## Source of truth

- `Native/Ambitions/` is the UI source of truth for the shipping app.
- `Sources/` contains the `AmbitionsDesignSystem` Swift package used by the native app.
- `AppUI/Sources/` contains the `AmbitionsWidgetUI` Swift package used by the native app.

## Canonical planning stack

Use [docs/codex/CONTEXT_INDEX.md](docs/codex/CONTEXT_INDEX.md) for the full source-of-truth hierarchy.
The permanent planning docs live in [docs/canon](docs/canon):

- [Ambitions_OS_Master_Roadmap.md](docs/canon/Ambitions_OS_Master_Roadmap.md)
- [Ambitions_Surgical_Execution_Plan.md](docs/canon/Ambitions_Surgical_Execution_Plan.md)
- [Ambitions_Codex_Batch_Plan.md](docs/canon/Ambitions_Codex_Batch_Plan.md)

## Native structure

- `Native/Ambitions/App`
  App entry, bootstrapper, dependency container, environment injection, root tabs.
- `Native/Ambitions/Domain`
  Native domain models for launch/session and first-pass dashboard contracts.
- `Native/Ambitions/Services`
  Startup and feature service protocols plus repository-backed implementations for Today, Goals, Habits, Insights, and Profile.
- `Native/Ambitions/Persistence`
  SwiftData-backed native persistence for goals, drafts, evidence, feedback, and app preferences.
- `Native/Ambitions/Features`
  Today, Captures, Goals, Habits, Insights, and Profile screens.
- `Native/Ambitions/UI`
  Shared shell UI like the launch gate and background canvas.
- `Native/Ambitions/PreviewSupport`
  Preview-safe bootstrap and fixture data.

## Repo boundaries

- Do not add new production UI work outside `Native/Ambitions/`, `Sources/`, or `AppUI/Sources/`.
- Do not reintroduce Expo, React Native, or TypeScript runtime files.

## Running the native app

This repo includes an XcodeGen spec rather than a checked-in `.xcodeproj`.

On a Mac with Xcode 16+ and XcodeGen installed:

1. Run `xcodegen generate`.
2. Open `Ambitions.xcodeproj`.
3. Build and run the `Ambitions` scheme on an iOS Simulator.

The full reproducible native generation, build, test, UI test, and archive flow lives in [docs/native-build-and-release.md](docs/native-build-and-release.md).

## Docs status

Use [docs/README.md](docs/README.md) as the index for current native docs and retained reference material.
Batch control status for active work now lives in [docs/codex/BATCH_REGISTRY.md](docs/codex/BATCH_REGISTRY.md).

## Codex workflow

Shared Codex behavior starts with [docs/codex/CONTEXT_INDEX.md](docs/codex/CONTEXT_INDEX.md), then [docs/codex/MASTER_CODEX_SYSTEM.md](docs/codex/MASTER_CODEX_SYSTEM.md). Windows and Mac Codex sessions should both pull the latest repo state from GitHub and use those files as standing session context; Mac sessions can start from [docs/codex/MAC_SESSION_BOOT_PROMPT.md](docs/codex/MAC_SESSION_BOOT_PROMPT.md).

## iOS native validation

GitHub Actions validates iOS-native integrity on `macos-15` in [.github/workflows/ios-validate.yml](.github/workflows/ios-validate.yml).

What the workflow verifies now:

- Installs XcodeGen and regenerates `Ambitions.xcodeproj` from `project.yml`.
- Derives the project name and primary scheme from `project.yml` and fails if generation drifts.
- Lists the generated project and resolves Swift package dependencies.
- Builds the native app target for `iphonesimulator` with signing disabled.
- Runs `AmbitionsTests` on a deterministically selected available simulator.
- Runs `AmbitionsUITests` in a separate macOS job using `build-for-testing` plus `test-without-building`.
- Runs an unsigned Release archive sanity check with `CODE_SIGNING_ALLOWED=NO`.
- Uploads `.xcresult` bundles for unit and UI test jobs.

What the workflow does not verify:

- Signed archives
- TestFlight or App Store Connect validation
- Distribution exports
- Physical-device behavior

The UI test job is honest but scoped: it validates the current preview-bootstrapped UI flow, not a signed production install path.

Local reproduction, including exact build, unit test, UI test, and archive commands, is documented in [docs/native-build-and-release.md](docs/native-build-and-release.md).

## Runtime behavior

- Appearance defaults to `System` and can be explicitly switched to Light or Dark from Profile.
- First-run identity is blank and neutral until the user enters personal data; preview/demo fixtures remain clearly non-production.
- The current shipped surface is local-first and on-device first.
- Today quick capture persists into the Captures tab through the native capture service.
- Notification scheduling and calendar/reminder wiring exist in the native app.
- Widget and Live Activity foundations exist in the repo, but they still need separate validation and should not be treated as fully verified shipped behavior from this README alone.
- Account sync is not implemented.
- The iOS target now includes a complete native app icon set and `PrivacyInfo.xcprivacy`.

## Current status

The app boots through the native SwiftUI entry point, persists state through SwiftData, and ships repository-backed Today, Captures, Goals, Habits, Insights, and Profile surfaces while the repo still retains older legacy Expo/React Native reference material.
