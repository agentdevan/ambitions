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

## Current status

The app now boots through the native SwiftUI entry point and uses native repositories/services for Today, Goals, Habits, Insights, and Profile.

Remaining legacy TypeScript code is retained only as migration/reference material and should not be treated as runnable product code.
