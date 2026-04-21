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
| Notifications | Available in this build, manual verification still required. Local notification foundation and runtime wiring already exist in the app target. | No Info.plist usage string is required for notification authorization. Prompt timing and copy should still stay intentional and user-triggered. | Review the in-app explanation, Profile auth state, and permission timing on device before submission. |
| Calendar / Reminders | Shipped EventKit integration service for selected goal/today actions. | Production Info.plist includes the current full-access EventKit usage strings used by the iOS 17+ authorization APIs. | Review should see a clear user benefit tied to scheduling next steps, not generic calendar access. |
| External routes | Canonical routing verified in repo validation for `ambitions://tab/plan` and `ambitions://captures/inbox`. | App Info.plist now registers the `ambitions` URL scheme, and routing still resolves through the centralized app-entry seam. | Keep future route additions on the canonical routing seam and do not widen payload shape without a concrete compatibility bug. |
| Widgets / Live Activities | Available in this build, manual verification still required. Widget extension, shared snapshot wiring, and Live Activity support already exist. | App and extension both use the shared App Group entitlement. App Info.plist declares Live Activities support. | Manual validation should confirm widget rendering, shared snapshot updates, Live Activity appear/update/end behavior, and tap routing on device. |
| Share extension | Not shipped in this build. | No share-extension target is wired today. | Keep this explicitly future work until the target and intake path actually exist. |
| App Intents | Available in this build, manual verification still required, as navigation-only shortcuts. | App-target shortcuts should remain bounded to canonical destinations and should not imply mutation or capture intake support. | Confirm Shortcuts visibility and canonical destination opening before promoting the claim beyond this conservative wording. |

## Manual verification checklist

Use this checklist when validating the current external surfaces without widening their scope:

### Notifications

1. Launch the app and open Profile.
2. Confirm the current notification state is shown accurately before requesting access.
3. Tap `Enable notifications` and verify the system prompt appears only from that user action.
4. Return to Profile and confirm the status copy updates to match the resulting system state.

### App Shortcuts

1. Build and run the app on a simulator or device that supports Shortcuts indexing.
2. Open the Shortcuts app and confirm the navigation-only shortcuts appear for Today, Plan, and Captures inbox.
3. Run each shortcut and confirm Ambitions opens the matching canonical destination without creating or mutating records.

### Calendar and reminders

1. From Today or Goal Detail, trigger the existing reminder or calendar-event action for a step with scheduling data.
2. Confirm the EventKit permission prompt only appears when the action is invoked.
3. Verify the created reminder or calendar event title matches the selected step.
4. If a calendar event is created, confirm any conflict-aware follow-up copy remains descriptive rather than promotional.

### Widgets and Live Activity

Use [widget-live-activity-manual-testing.md](widget-live-activity-manual-testing.md) for the read-only widget and Live Activity checklist.

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
