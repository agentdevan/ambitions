# Permissions and Privacy Foundation

This document records the current shipped state of the native iOS app across permissions, entitlements, shared-capability wiring, and still-unshipped OS surfaces.

## Current shipped state

- `Native/Ambitions/Support/Info.plist` declares the current production usage strings for:
  - `NSCalendarsFullAccessUsageDescription`
  - `NSRemindersFullAccessUsageDescription`
- The app ships an entitlements file at `Native/Ambitions/Support/Ambitions.entitlements`.
- The widget extension ships an entitlements file at `Native/AmbitionsWidgetExtension/AmbitionsWidgetExtension.entitlements`.
- Both targets currently use the shared App Group `group.com.ambitions.shared`.
- `Native/Ambitions/Support/Info.plist` declares `NSSupportsLiveActivities`.
- `Native/Ambitions/Resources/PrivacyInfo.xcprivacy` currently declares:
  - no tracking
  - no collected data types
  - no required accessed API reasons
- The shipping app is still local-first. Runtime permission requests are limited to features already wired into production code, especially EventKit-backed calendar/reminder actions.

## Current capability map

| Integration | Current repo state | Permission or capability status | Review considerations |
| --- | --- | --- | --- |
| Notifications | Shipped local notification foundation and runtime wiring in the app target. | No Info.plist usage string is required for notification authorization. Prompt timing and copy should still stay intentional and user-triggered. | Review the in-app explanation and permission timing on device before submission. |
| Calendar / Reminders | Shipped EventKit integration service for selected goal/today actions. | Production Info.plist includes the current full-access EventKit usage strings used by the iOS 17+ authorization APIs. | Review should see a clear user benefit tied to scheduling next steps, not generic calendar access. |
| Widgets / Live Activities | Shipped widget extension plus shared snapshot wiring and Live Activity support. | App and extension both use the shared App Group entitlement. App Info.plist declares Live Activities support. | Manual validation should confirm widget rendering, shared snapshot updates, and Live Activity behavior on device. |
| Share extension | Not shipped yet. | No share-extension target is wired today. | Keep this explicitly future work until the target and intake path actually exist. |
| App Intents | Not shipped yet as a product surface. | No concrete App Intents dependency or user-facing shortcut surface is wired today. | Do not imply Siri/Shortcuts support until the target and action routing are real. |

## Operational rules

- Keep permission strings and entitlements aligned with production code, not roadmap items.
- When a capability is shipped, keep the wording specific to the user-visible benefit.
- If a future capability needs shared storage, confirm the App Group is still the narrowest correct solution before expanding it.
- Keep the privacy manifest aligned with actual accessed APIs and collected data, not with imported frameworks alone.

## Next wiring points for unshipped surfaces

- `Native/Ambitions/App/AppBootstrapper.swift`
- `Native/Ambitions/App/AppExternalRouting.swift`
- `Native/Ambitions/Services/AppServices.swift`
- `Native/Ambitions/Support/FutureIntegrationPlaceholders.swift`
