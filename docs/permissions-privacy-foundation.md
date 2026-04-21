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
- `Native/Ambitions/Support/Info.plist` declares the `ambitions` custom URL scheme used by external routes, widget taps, Live Activity taps, and navigation-only App Intents.
- `Native/Ambitions/Resources/PrivacyInfo.xcprivacy` currently declares:
  - no tracking
  - no collected data types
  - no required accessed API reasons
- The shipping app is still local-first. Runtime permission requests are limited to features already wired into production code, especially EventKit-backed calendar/reminder actions.

## Current capability map

| Integration | Current repo state | Permission or capability status | Review considerations |
| --- | --- | --- | --- |
| Notifications | Available in this build, pending Batch 36 validation. Local notification foundation and runtime wiring already exist in the app target. | No Info.plist usage string is required for notification authorization. Prompt timing and copy should still stay intentional and user-triggered. | Review the in-app explanation, Profile auth state, and permission timing on device before submission. |
| Calendar / Reminders | Shipped EventKit integration service for selected goal/today actions. | Production Info.plist includes the current full-access EventKit usage strings used by the iOS 17+ authorization APIs. | Review should see a clear user benefit tied to scheduling next steps, not generic calendar access. |
| External routes | Available in this build, validated in Batch 36 for canonical `ambitions://tab/plan` and `ambitions://captures/inbox` entry points. | App Info.plist now registers the `ambitions` URL scheme, and routing still resolves through the centralized app-entry seam. | Keep future route additions on the canonical routing seam and do not widen payload shape without a concrete compatibility bug. |
| Widgets / Live Activities | Available in this build, pending Batch 36 validation. Widget extension, shared snapshot wiring, and Live Activity support already exist. | App and extension both use the shared App Group entitlement. App Info.plist declares Live Activities support. | Manual validation should confirm widget rendering, shared snapshot updates, Live Activity appear/update/end behavior, and tap routing on device. |
| Share extension | Not shipped in this build. | No share-extension target is wired today. | Keep this explicitly future work until the target and intake path actually exist. |
| App Intents | Available in this build, pending Batch 36 validation, as navigation-only shortcuts. | App-target shortcuts should remain bounded to canonical destinations and should not imply mutation or capture intake support. | Confirm Shortcuts visibility and canonical destination opening before promoting the claim beyond pending validation. |

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
