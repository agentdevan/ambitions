# Ambitions Privacy Data Map And App Privacy Labels
<!-- markdownlint-disable MD013 -->

Status: Active PFC24 privacy data map and App Privacy label draft
Date: 2026-05-05
Owner: Privacy / Platform / Legal
Result: Green source-truth draft with human App Store/legal review still gated

## Purpose

This document maps Ambitions' current repo-backed data behavior to a draft App
Store App Privacy disclosure posture.

It is not a legal compliance certification, App Store Connect submission,
privacy policy, privacy manifest implementation, required-reason API audit, or
public release claim. PFC24 creates the draft that later human legal/privacy and
release operators must reconcile against the final signed binary.

## Source Truth

- `Native/Ambitions/Resources/PrivacyInfo.xcprivacy`
- `Native/Ambitions/Support/Info.plist`
- `Native/Ambitions/Support/Ambitions.entitlements`
- `Native/AmbitionsWidgetExtension/AmbitionsWidgetExtension.entitlements`
- `Native/AmbitionsShareExtension/AmbitionsShareExtension.entitlements`
- `Native/Ambitions/Persistence/SwiftDataModels.swift`
- `Native/Ambitions/Integrations/CalendarReminders/EventKitIntegrationService.swift`
- `Native/Ambitions/Notifications/LocalNotificationFoundation.swift`
- `Native/Ambitions/Support/ReleaseExternalTruthReadinessPacket.swift`
- `docs/permissions-privacy-foundation.md`
- `docs/canon/Ambitions_App_Store_Release_Compliance.md`
- `docs/canon/Ambitions_Platform_Legal_And_Framework_Completion_Plan.md`
- `docs/canon/Ambitions_3_0_Privacy_Threat_Model.md`
- `docs/canon/Ambitions_StoreKit_Monetization_Strategy.md`

## Current Repo Privacy Facts

- The native app is local-first and currently requires no Ambitions account.
- `PrivacyInfo.xcprivacy` currently declares:
  - `NSPrivacyTracking` as false;
  - `NSPrivacyCollectedDataTypes` as an empty array;
  - `NSPrivacyAccessedAPITypes` as an empty array.
- No active StoreKit runtime, subscription, IAP, paywall, ad SDK, analytics
  SDK, crash-reporting SDK, tracking SDK, or third-party network service was
  found in the current source inventory.
- `Package.swift` defines local package targets only and no remote package
  dependencies.
- App and widget targets use `group.com.ambitions.shared` for local App Group
  sharing.
- The app declares Calendar and Reminders full-access purpose strings.
- The app declares Live Activities support and an `ambitions` custom URL scheme.
- Current external surfaces are local projections: widgets, Live Activities,
  notifications, share extension, App Intents, and custom routes.

## Data Map

| Data area | Current source | Storage / processing | Developer collection | App Privacy draft | Boundary |
| --- | --- | --- | --- | --- | --- |
| Goals, plans, steps, drafts, sections, progress strategy, and snapshots | SwiftData records | On-device SwiftData | No repo evidence of collection by developer | Not collected | If cloud, account, analytics, or sync is added, reclassify before release. |
| Captures and shared intake | SwiftData plus share-extension App Group handoff | On-device / local App Group | No repo evidence of collection by developer | Not collected | Share Extension imports locally into Capture; no backend claim. |
| Proof, evidence, feedback, receipts, reviews, teaching signals, and app state | SwiftData / local domain models | On-device | No repo evidence of collection by developer | Not collected | Proof and receipts may contain private life detail; keep local and privacy-safe in projections. |
| Calendar-derived context | EventKit integration after user action and authorization | Device EventKit read/write and local derived summaries | No repo evidence of developer collection | Not collected | Calendar access is Plan-owned, user-initiated, and must be reviewed before submission. |
| Reminders writes | EventKit integration after user action and authorization | Device Reminders write | No repo evidence of developer collection | Not collected | Reminder creation must remain explicit and user-initiated. |
| Notifications | UserNotifications pending request payloads | Device notification center | No repo evidence of developer collection | Not collected | Payloads must remain privacy-safe for Lock Screen / Notification Center. |
| Widgets and Live Activities | App Group snapshot and ActivityKit state | Local extension/App Group/ActivityKit projection | No repo evidence of developer collection | Not collected | External projections must hide private detail by default. |
| App Intents and routes | Local shortcut/deep-link routing | On-device route invocation | No repo evidence of developer collection | Not collected | Intent payloads must stay route/local-capture bounded. |
| Preferences, appearance, defaults, onboarding, and You/Profile trust state | App preferences / app state repositories | On-device | No repo evidence of developer collection | Not collected | User control and privacy controls must not be paywalled. |
| Diagnostics, analytics, advertising, and tracking | No active SDK/runtime evidence found | None in current repo inventory | No | Not collected / no tracking | Introducing telemetry, crash reporting, ads, or tracking triggers PFC29 and privacy label review. |
| Purchases and subscriptions | PFC21 defers StoreKit runtime | None in current launch posture | No | Not collected | StoreKit data cannot be claimed absent PFC22/PFC23 approval and implementation. |

## Draft App Privacy Labels

Draft for the current repo-backed launch posture:

| App Store privacy question | Draft answer | Evidence | Caveat |
| --- | --- | --- | --- |
| Does the app collect data from this app? | No, for current repo behavior. | `PrivacyInfo.xcprivacy` collected data array is empty; no account/backend/analytics/tracking SDK found. | Must be rechecked against the final signed binary and App Store Connect taxonomy. |
| Is data linked to the user? | No collection by developer is evidenced. | Local SwiftData/App Group/permission surfaces only. | Local personal data exists on device and must be protected; this is not a claim that the app contains no private details. |
| Is data used to track the user? | No. | `NSPrivacyTracking` is false; no ad/tracking SDK evidence found. | Adding ads, cross-app tracking, or tracking SDKs is forbidden without a new privacy/legal batch. |
| Are diagnostics or analytics collected? | No current repo evidence. | No analytics, telemetry, crash-reporting, or network SDK evidence found. | PFC29 must review any future diagnostics or observability posture. |
| Are third-party SDKs collecting data? | No current repo evidence. | Package and source inventory show local targets only. | PFC04/PFC25/PFC29 must re-audit if dependencies are added. |

Recommended App Privacy draft posture: **Data Not Collected** and **No
Tracking**, based on current repo evidence only.

## Permission And Capability Disclosure Boundary

Calendar and Reminders are not developer data collection in the current repo
posture, but they are private OS permission surfaces. App review copy must
explain that Ambitions uses Calendar access to schedule selected next steps,
check nearby conflicts, or find room around them, and uses Reminders access to
save selected next steps for follow-through.

Notifications, widgets, Live Activities, App Intents, custom routes, and Share
Extension flows must be disclosed in reviewer notes where relevant. They do not
create a data-collection claim unless future code sends their payloads to a
developer or third party.

## Final Submission Gates

Before App Store submission, the operator must:

1. Re-run source inventory against the exact signed release candidate.
2. Reconcile App Store Connect labels against the final binary, privacy
   manifest, entitlements, permissions, and any enabled external surfaces.
3. Confirm no analytics, crash reporting, ads, tracking, account backend,
   cloud sync, StoreKit, or third-party SDK was added after PFC24 without
   privacy-label updates.
4. Confirm Calendar, Reminders, notification, widget, Live Activity, App
   Intent, and Share Extension reviewer notes match shipped behavior.
5. Complete human legal/privacy review and provide a live privacy policy URL
   before submission.

## Stop Conditions

Stop and re-open privacy labels if any future batch adds or changes:

- account, auth, cloud, sync, backend, or external service behavior;
- analytics, telemetry, crash reporting, ads, tracking, or attribution;
- StoreKit products, subscriptions, purchases, receipt validation, or paywall;
- Calendar/Reminders read depth, permission timing, or write behavior;
- notifications, widgets, Live Activities, App Intents, Share Extension, or
  external-route payload details;
- third-party SDKs, dependency manifests, privacy manifests, or entitlements;
- public privacy, legal, App Store, accessibility, device, TestFlight, or
  release-readiness claims.

## PFC24 Decision

PFC24 closes as a repo-evidence privacy data map and App Privacy label draft.
The safe current draft is **Data Not Collected** and **No Tracking**. This
remains a draft until final binary review, App Store Connect entry, live privacy
policy URL, and human legal/privacy signoff are complete.
