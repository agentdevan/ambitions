# IOS26 API Verification Ledger

Status: docs-only API ledger; not API adoption proof
Generated: 2026-05-22

## Toolchain Evidence

Observed locally:

```text
Apple Swift version 6.2.4 (swiftlang-6.2.4.1.4 clang-1700.6.4.2)
Target: x86_64-apple-macosx15.0
```

Blocked during this phase:

- `xcodebuild -version || true` was rejected by local command policy, so current Xcode version and SDK catalog could not be confirmed from this run.

## Ledger

| API / Framework | Status | Evidence / note |
| --- | --- | --- |
| Liquid Glass / `GlassEffectContainer` | Candidate, not verified | Not found in the scanned source. Treat as requiring local SDK confirmation before any adoption claim. |
| iOS 26 tab APIs (`tabBarMinimizeBehavior`, `tabViewBottomAccessory`) | Candidate, not verified | Standard `TabView` exists in source, but the iOS 26-specific tab modifiers were not found in the scan. SDK confirmation still required. |
| `TabView` / standard tab routing | Verified source-present | `Native/Ambitions/App/AmbitionsRootView.swift` uses `TabView(selection:)` with `.tabItem` wiring. |
| `SwiftData` | Verified source-present | `Native/Ambitions/Persistence/SwiftDataStore.swift` and related model/store files import and use `SwiftData`. |
| `WidgetKit` | Verified source-present | `Native/AmbitionsWidgetExtension/NextStepWidget.swift` imports `WidgetKit`. |
| `ActivityKit` | Verified source-present | `Native/Ambitions/ExternalSnapshots/NextStepActivityAttributes.swift`, `Native/AmbitionsWidgetExtension/AmbitionsWidgetBundle.swift`, `Native/AmbitionsWidgetExtension/NextStepLiveActivityWidget.swift`, and `Native/Ambitions/Notifications/NextStepLiveActivityService.swift` import `ActivityKit`. |
| `AppIntents` | Verified source-present | `Native/Ambitions/AppIntents/AmbitionsSystemControlIntent.swift` and `Native/Ambitions/AppIntents/OpenAmbitionsDestinationIntent.swift` import `AppIntents`. |
| Spotlight / CoreSpotlight | Not found in scanned source | No current source proof in the inspected areas. Keep as unverified. |
| BackgroundTasks | Not found in scanned source | No current source proof in the inspected areas. Keep as unverified. |
| Accessibility APIs | Verified source-present | The repo uses `accessibilityReduceMotion`, `dynamicTypeSize`, `accessibilityHidden`, `accessibilityLabel`, `accessibilityValue`, and related SwiftUI accessibility modifiers throughout `Sources/` and `Native/Ambitions/`. |

## Verification Notes

- Source presence is not adoption proof.
- iOS 26-only candidates stay Yellow until the local SDK is confirmed and a focused source batch proves the symbol is available and intentionally used.
- Public accessibility claims remain blocked until manual proof exists, even though accessibility APIs are present in source.

## Claim Boundary

This ledger does not prove implementation completeness, build success, device behavior, accessibility conformance, performance, TestFlight readiness, App Store readiness, or release readiness.
