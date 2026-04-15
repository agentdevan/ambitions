# Permissions and Privacy Foundation

This document records the current shipped state of the native iOS app and maps the OS integrations that are planned for later work.

## Current shipped state

- `Native/Ambitions/Support/Info.plist` does not declare any permission usage strings today.
- The app does not ship an entitlements file today.
- `Native/Ambitions/Resources/PrivacyInfo.xcprivacy` is intentionally empty because the current native code does not declare tracked data collection or accessed system APIs that require entries in the privacy manifest.
- The shipping app remains local-first and does not request runtime permissions unless a feature already depends on them.

## Future integration map

| Integration | Likely Apple surface | Likely permission or capability work | Review considerations |
| --- | --- | --- | --- |
| Notifications | UserNotifications | Add a user-facing explanation before any request prompt, register categories, and only request authorization when notification delivery ships. | Review wording should match the exact alert use case. If the feature is optional, defer the prompt until the user opts in. |
| Calendar / Reminders | EventKit | Add usage strings before access, scope reads to the smallest data set needed, and separate calendar reads from reminder writes if both are ever supported. | Apple review expects a clear benefit statement and a strong reason for system data access. Keep read/write paths explicit. |
| Widgets / Live Activities | WidgetKit, ActivityKit | Add extension targets and shared snapshot data structures before wiring any capability. Live Activities need a separate ActivityKit path from widgets. | Widgets and Live Activities should not be inferred from in-app code alone; they need explicit extension or activity entry points. |
| Share extension | Share extension target, App Group if shared persistence is needed | Add a dedicated extension target and a narrow handoff model before accepting shared content from other apps. | Review focuses on whether the extension does only one job and handles shared data safely. Keep it separate from the main app flow. |
| App Intents | AppIntents, Siri / Shortcuts surfaces | Add stable intent definitions and execution routing only after the underlying action is already supported in-app. | Intent metadata should reflect actual behavior. Do not expose shortcuts for flows that are not yet reliable in the app. |

## Operational rules

- Do not add runtime permission prompts until the feature that needs them is shipping.
- Do not add entitlements or plist usage strings until the corresponding Apple framework is wired into production code.
- If a future capability needs shared storage, review whether an App Group is actually required before adding one.
- Keep the privacy manifest aligned with what the code imports and executes, not with roadmap items.

## Suggested next wiring points

- `Native/Ambitions/App/AppBootstrapper.swift`
- `Native/Ambitions/App/AppExternalRouting.swift`
- `Native/Ambitions/Services/AppServices.swift`
- `Native/Ambitions/Support/FutureIntegrationPlaceholders.swift`

