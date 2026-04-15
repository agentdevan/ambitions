# Ambitions Native iOS App

Ambitions is a native iOS SwiftUI application. The old Expo/React Native runtime has been removed from the repo root.

## Source of truth

- `Native/Ambitions/` is the UI source of truth for the shipping app.
- `Sources/` contains the `AmbitionsDesignSystem` Swift package used by the native app.
- `AppUI/Sources/` contains the `AmbitionsWidgetUI` Swift package used by the native app.
- `src/` contains legacy TypeScript reference material for migration/spec work only. It is not a shipping runtime.

## Native structure

- `Native/Ambitions/App`
  App entry, bootstrapper, dependency container, environment injection, root tabs.
- `Native/Ambitions/Domain`
  Native domain models for launch/session and first-pass dashboard contracts.
- `Native/Ambitions/Services`
  Startup and feature service protocols plus current placeholder implementations.
- `Native/Ambitions/Persistence`
  Native persistence boundary, currently in-memory.
- `Native/Ambitions/Features`
  Today, Goals, Habits, Insights, and Profile screens.
- `Native/Ambitions/UI`
  Shared shell UI like the launch gate and background canvas.
- `Native/Ambitions/PreviewSupport`
  Preview-safe bootstrap and fixture data.

## Legacy boundary

- Do not add new production UI work outside `Native/Ambitions/`, `Sources/`, or `AppUI/Sources/`.
- Do not reintroduce Expo or React Native boot/runtime files at the repo root.
- If behavior from the old client is still useful, treat the TypeScript implementation as specification/reference input for the native rewrite.

## Running the native app

This repo includes an XcodeGen spec rather than a checked-in `.xcodeproj`.

On a Mac with Xcode and XcodeGen installed:

1. Run `xcodegen generate`.
2. Open `Ambitions.xcodeproj`.
3. Build and run the `Ambitions` scheme on an iOS Simulator.

## iOS native validation

GitHub Actions validates iOS-native integrity on `macos-latest` in [.github/workflows/ios-validate.yml](/Users/Devan/Documents/GitHub/ambitions/.github/workflows/ios-validate.yml).

What the workflow does:

- Detects whether the repo is Expo prebuild, bare React Native, or native iOS-only.
- Detects `npm`, `yarn`, or `pnpm` from lockfiles before installing JavaScript dependencies.
- Generates native iOS files when required.
- Runs `pod install` only when a `Podfile` exists.
- Runs `xcodebuild` only when the project/workspace and scheme can be discovered from checked-in repo files.
- Otherwise, falls back to validating successful native generation plus the presence of a generated `.xcodeproj` or `.xcworkspace`.

For this repo specifically, the validation path is:

1. `xcodegen generate`
2. Discover the generated `Ambitions.xcodeproj` and `Ambitions` scheme from `project.yml`
3. Run a simulator build with `CODE_SIGNING_ALLOWED=NO`

Local reproduction on a Mac:

1. Install Xcode and XcodeGen.
2. Run `xcodegen generate` from the repo root.
3. If a `Podfile` is ever introduced, run `pod install` in that directory.
4. Run `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -sdk iphonesimulator -destination "generic/platform=iOS Simulator" CODE_SIGNING_ALLOWED=NO build`

## Current status

The app now boots through the native SwiftUI entry point and uses native repositories/services for Today, Goals, Habits, Insights, and Profile.

Remaining legacy TypeScript code is retained only as migration/reference material and should not be treated as runnable product code.
