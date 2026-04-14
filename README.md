# Ambitions Native iOS Pivot

Ambitions is now pivoting from an Expo/React Native prototype into a single native iOS SwiftUI application.

## Source of truth

- `Native/Ambitions/` is the new UI source of truth for the shipping app.
- `Sources/` contains the `AmbitionsDesignSystem` Swift package used by the native app.
- `AppUI/Sources/` contains the `AmbitionsWidgetUI` Swift package used by the native app.
- `src/`, `App.tsx`, Expo config, and the TypeScript goal engine remain in the repo as reference material only.

## What changed

- Added a native app shell with a real `@main` entry point, bootstrap flow, dependency container, and root tab navigation.
- Added a production-minded folder layout for app, domain, services, persistence, features, UI, and preview support.
- Added `project.yml` so XcodeGen can create the native iOS target against the existing local Swift packages.

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

- Do not add new production UI work to Expo or React Native files.
- Do not bridge React Native screens into SwiftUI.
- If behavior from the old client is still useful, treat the TypeScript implementation as a specification/reference input for the native rewrite.

## Running the native app

This repo now includes an XcodeGen spec rather than a checked-in `.xcodeproj`, because this environment does not have Apple tooling.

On a Mac with Xcode and XcodeGen installed:

1. Run `xcodegen generate`.
2. Open `Ambitions.xcodeproj`.
3. Build and run the `Ambitions` scheme on an iOS Simulator.

## Current placeholder scope

The native shell is production-oriented structurally, but the following still use placeholder/demo data:

- startup/session bootstrap
- all five tab dashboards
- widget actions
- persistence
- account/auth state
- analytics and insights history

The next step is replacing the stub services with native persistence-backed feature pipelines, starting with Today and Goals.
