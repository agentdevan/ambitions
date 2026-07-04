# External Adapter App Intent Widget Share Notification Routing Audit

Status: AMB-1722 Implemented Yellow route audit with AMB-1732 partial source repair addendum

Snapshot date: 2026-07-02

AMB-1732 source repair addendum: 2026-07-03

Parent: AMB-1668 External Adapter Mutation Enforcement

Baseline inspected: `3ae3b884701babb3694e40a9e5fbaf2f5e62949f` on `main`

Scope: AMB-1722 audits App Intent, widget payload, share extension,
notification action, and app external-route mutation paths against the
AMB-1721 `ExternalCommandAdapter` governance contract. This artifact does not
change Swift behavior, add a Swift adapter protocol, migrate runtime
authority, change app routing, prove terminated-app behavior, prove extension
lifecycle behavior, prove widget rendering, prove notification delivery,
prove Shortcuts or Siri invocation, prove Live Activity behavior, or close
EventKit, Reminders, CloudKit, Source Atlas, R2, TestFlight, App Store,
accessibility, privacy/legal, or release readiness.

No adapter Green is claimed.

## Proof Ceiling

Evidence class: Implemented Yellow.

This audit is static source, config, and existing-test inspection only. It
classifies each AMB-1722 route as `projectionOnlyReader`, `commandHandoff`,
`sideEffectOutbox`, `rejectionReceipt`, `blockedUnknown`, or `unsafeDebt` per
`docs/audits/external-command-adapter-contract.md`. Existing tests are cited as
source evidence; this document does not claim that those tests were run for
this leaf unless the closeout comment records current command output.

Green requires linked current evidence for the exact route and behavior. Missing
device, lifecycle, receipt, replay, and rejection proof keeps this leaf Yellow.

## Canonical Laws Preserved

External/system routes must preserve:

```text
Command -> Event -> Projection -> Receipt -> Replay
```

The remediation posture remains:

```text
law over lore
deep runtime, boring UI
delete before naming
Green requires linked evidence
```

Today / Goals / Time / You remain the only persistent surfaces. Capture remains
the global composer. Motion remains behavior under Stage/Motion. App group
storage is not canonical private graph storage. Widgets, Live Activities, and
notification payloads must stay private by default and must not silently mutate
the private life graph.

## Route Classification Matrix

| Route | AMB-1722 classification | Static source evidence | Existing test/config evidence inspected | Yellow gap or follow-up |
| --- | --- | --- | --- | --- |
| App Intent capture and goal-draft creation | `commandHandoff` | `Native/Ambitions/App/Intents/AmbitionsCreationIntents.swift` builds `ExternalCreationRequest` values and calls `AppIntentBridge.defaultExternalSurfaceBridge().enqueueExternalCreation`; `Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/AppIntentBridge.swift` writes durable external-creation handoff records through the shared store; `Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/ExternalCreationImportService.swift` drains handoff records and imports them as `AmbitionsCommand(kind: .quickCapture, actor: .externalSurface)`. | `Native/AmbitionsTests/App/AppIntentRoutingTests.swift` covers App Intent local review request shape and launch routing; `Native/AmbitionsTests/App/ExternalCreationImportServiceTests.swift` covers app import, command journal metadata, command receipt ID metadata, and duplicate request replay behavior. | No Shortcuts/Siri device invocation proof. No terminated-app import proof. No adapter Green. |
| App Intent navigation, step inspection, guarded close, and system controls | `commandHandoff` with missing `rejectionReceipt` proof for guarded actions | `Native/Ambitions/App/Intents/AmbitionsStepInspectionIntents.swift`, `Native/Ambitions/App/Intents/AmbitionsSystemControlIntent.swift`, `Native/Ambitions/App/Intents/OpenAmbitionsDestinationIntent.swift`, and `Native/Ambitions/App/Intents/AmbitionsDeepActionShortcut.swift` set `openAppWhenRun = true`, model deep-action posture, and queue URLs through `Native/Ambitions/App/AppIntentLaunchRouter.swift`. Guarded close opens the app for confirmation instead of directly writing canonical state. | `Native/AmbitionsTests/App/AppIntentRoutingTests.swift` verifies deep-action descriptors, `requiresInAppConfirmation`, `producesReceipt`, and pending URL consume behavior. | Descriptor proof is not post-launch mutation or receipt proof. In-memory pending URL behavior is not terminated-app lifecycle proof. No Siri/Shortcuts device proof. |
| Share extension save | `commandHandoff` | `Native/AmbitionsShareExtension/ShareViewController.swift` trims shared text/URL, builds an `ExternalCreationRequest`, calls `SharedExternalCreationStore.enqueueDurableRequest`, opens Ambitions, and completes the extension context. `Native/AmbitionsShareExtension/ShareIntakeView.swift` keeps the user in an edit/confirm flow. App import is handled by `ExternalCreationImportService.swift`. | `Native/AmbitionsTests/App/ExternalCreationImportServiceTests.swift` covers durable handoff drain, app import, duplicate replay, command journal metadata, and command receipt ID metadata. App, widget, and share entitlements point at `group.com.ambitions.shared` through `project.yml` and entitlements files. | The inspected `ShareViewController` path writes the durable handoff directly; extension-side `ShareExtensionIntake` outbox receipt proof is not shown on that path. No extension lifecycle, redaction-on-device, app-group device, or terminated-app import proof. |
| Deep links and app external routes | `projectionOnlyReader` for route-only Stage handoff | `Native/Ambitions/App/AmbitionsRootScene.swift`, `Native/Ambitions/App/AppBootstrapper.swift`, `Native/Ambitions/App/AppExternalRouting.swift`, `Native/Ambitions/App/AppExternalRouteTranslator.swift`, and related payload translators select tabs, goal detail, Time routes, You routes, Capture composer overlays, or generic external-entry fallback. They do not directly write canonical private graph state in the inspected paths. | `Native/AmbitionsTests/App/ExternalRoutingTests.swift` covers deep link route decoding, notification/widget payload route decoding, legacy tab fallback for stale `motion`/`pulse` names, generic fallback, and route dispatch. | If a route opens Capture, Create Goal, or another in-app mutating UI, downstream mutation remains AMB-1666/AMB-1667 scope. No device URL-open proof. |
| Widget and Live Activity UI reads | `projectionOnlyReader` | `Native/AmbitionsWidgetExtension/NextStepWidget.swift` reads `SharedExternalSnapshotRecord.verifiedPayloadData()` from `Native/Ambitions/Projection/ExternalSnapshots/SharedExternalSnapshotStore.swift`, decodes `ExternalSurfaceSnapshot`, renders `ExternalWidgetProjection`, and uses `.widgetURL(projection.primaryURL)`. `Native/AmbitionsWidgetExtension/NextStepLiveActivityWidget.swift` renders ActivityKit content state and uses `Link`/`.widgetURL` deep links. No mutating widget `Button`/App Intent control was found in the inspected widget source. | `Native/AmbitionsTests/App/ExternalWidgetProjectionTests.swift`, `Native/AmbitionsTests/App/ExternalSurfaceActionPayloadTests.swift`, and `Native/AmbitionsTests/App/ExternalSurfaceVerificationChecklistTests.swift` cover privacy-safe widget projection, stale/unavailable fallback, payload route shape, and checklist readiness ceilings. | AMB-1724 still owns external projection snapshot writer/reader privacy, staleness, widget rendering, Live Activity, and device proof. No widget or Live Activity Green. |
| Widget payload action bridge | `rejectionReceipt` source-present; focused XCTest passed | `Native/Ambitions/App/AppBootstrapper.swift` calls `ExternalActionCommand(widgetPayload:)`; AMB-1732 changed `Native/Ambitions/Core/LocalRuntimeOS/Commands/ExternalActionCommandService.swift` so widget payloads for `complete`, `delay`, `snooze`, and `askForSmallerStep` downgrade to `openToday`, preserve the rejected action kind, and record a local-only `commandBridge` side-effect receipt when a recorder is configured. Current widget UI source still does not emit a mutating payload. | AMB-1732 added and ran `testAMB1732WidgetMutationPayloadRecordsRejectionReceiptInsteadOfMutating` in `Native/AmbitionsTests/LocalRuntimeOS/Commands/ExternalActionCommandServiceTests.swift`, asserting no Today mutation, Today review routing, `SideEffectReceipt.status == .failedSafely`, `commandBridge`, `.unsupported` boundary, `.markDone`, target object preservation, and no private life graph state change. | Source now rejects the widget mutation bridge instead of executing it, and focused simulator XCTest passed. Device/lifecycle and replay proof remain missing before parent Green. |
| Notification scheduling and local notification side effects | `sideEffectOutbox` | `Native/Ambitions/Core/Permissions/LocalNotificationFoundation.swift` reads verified external snapshots, builds private-default notification request content and route payloads, schedules/replaces pending requests, refreshes Live Activity state, and records notification side effects through `Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/NotificationOutbox.swift`. | `Native/AmbitionsTests/App/LocalNotificationFoundationTests.swift` covers private request copy, route payload keys, authorization-missing ledger records, snapshot failure `failedSafely`, no-next-action clearing, lifecycle cleanup, and no private terms in payload/copy. | No real device authorization, delivery, action, pending/delivered notification, or Lock Screen proof. No release readiness. |
| Notification response parser and action payload handling | `rejectionReceipt` source-present; focused XCTest passed | `Native/Ambitions/Core/Permissions/NotificationRuntime.swift` parses notification responses and forwards payloads to `AppBootstrapper.handleNotificationPayload`. AMB-1732 changed `ExternalActionCommand(notificationPayload:)` so mutating `complete`, `snooze`, `delay`, and `askForSmallerStep` payloads downgrade to open Today, preserve the rejected action kind, and record a local-only `commandBridge` side-effect receipt when a recorder is configured. `AppExternalRouteTranslator.route(fromNotification:)` still maps notification recovery routes to Today. | `Native/AmbitionsTests/App/NotificationResponsePayloadParserTests.swift` covers system open, snooze, complete, and payload preservation. AMB-1732 added and ran `testAMB1732NotificationMutationPayloadRoutesAndRecordsRejectionReceipts`, asserting no Today mutation, Today review routing, failed-safely local-only receipts, `commandBridge`, `.unsupported` boundary, `.markDone` for complete, `.deferAction` for snooze, and unsupported-source reason facts. `Native/AmbitionsTests/App/ExternalRoutingTests.swift` covers notification `complete` routing to Today recovery. | Source now records explicit rejection receipts for notification mutation payloads, and focused simulator XCTest passed. Device notification action and replay proof remain missing before parent Green. |

## Acceptance Verdict

AMB-1722 acceptance is satisfied at an Implemented Yellow ceiling:

- App Intent creation routes are command-handoff paths.
- App Intent navigation/control routes open the app and do not directly mutate
  canonical state, but guarded-action receipt proof is missing.
- Share extension intake is a command-handoff path through durable app-group
  intake and app import, but extension-side outbox/lifecycle proof is missing.
- Deep links and app external routes are route-only Stage handoffs with no
  direct canonical write found in the inspected source.
- Widget and Live Activity UI are projection-only readers in current source,
  but AMB-1724 still owns projection privacy, stale-state, render, and device
  proof.
- Widget payload mutation handling is no longer `blockedUnknown` in source:
  AMB-1732 downgrades mutating widget payloads to Today review routing and
  records a local-only `commandBridge` rejection receipt when a recorder is
  configured. Focused simulator XCTest passed. It remains Yellow until
  device/lifecycle and replay proof complete.
- Notification scheduling is a side-effect outbox path.
- Notification action payloads downgrade mutating actions to app-open routing
  and now have source-present local-only rejection receipt recording. Focused
  simulator XCTest passed; device action proof is still missing.

No AMB-1722 route is promoted to Green.

## Proof And Non-Claims

Verified by this audit:

- Static source/config inspection found no current widget UI mutating control.
- Static source/config inspection found App Intent and Share Extension creation
  input entering durable handoff plus app import paths.
- Static source inspection found notification action payload downgrades before
  direct mutation.
- Existing test sources cover route translation, external creation import,
  notification payload parsing, notification scheduling safety, widget
  projection privacy, and checklist proof ceilings.
- AMB-1732 source diff adds explicit local-only `commandBridge` rejection
  receipt handling for mutating notification and widget payloads in
  `ExternalActionCommandService`.
- AMB-1732 test diff adds focused Commands assertions for widget and
  notification payload rejection receipts.
- AMB-1732 simulator validation now covers
  `AmbitionsTests/ExternalActionCommandServiceTests` directly and in the
  combined EventKit/Reminders result-receipt run.

Not verified by this audit:

- Device widget rendering or interaction.
- Device notification delivery or action handling.
- Live Activity request/update/end behavior on device.
- Shortcuts or Siri invocation.
- Share extension lifecycle on device.
- Terminated-app handoff import.
- App group read/write behavior on device.
- Accessibility, performance, privacy/legal, TestFlight, App Store, R2, Source
  Atlas production, CloudKit, EventKit, or Reminders readiness.

## AMB-1732 Source Repair Addendum

Changed source:

- `Native/Ambitions/Core/LocalRuntimeOS/Commands/ExternalActionCommandService.swift`
  preserves rejected mutating external payload action kinds, downgrades
  notification and widget mutation payloads to `openToday`, and records
  local-only `SideEffectOutbox` `commandBridge` receipts with `.unsupported`
  initial boundary and failed-safely result receipts when a recorder is
  configured.
- `Native/AmbitionsTests/LocalRuntimeOS/Commands/ExternalActionCommandServiceTests.swift`
  replaces the prior widget-payload execution expectation with rejection
  receipt proof expectations and adds notification mutation-payload rejection
  receipt expectations.
- `Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/SideEffectPolicyEngine.swift`
  preserves an explicit `.unsupported` requested boundary when a blocked
  external adapter request records a rejection receipt.
- `Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/EventKitOutbox.swift`
  exposes result recording for EventKit/Reminders attempts through
  `SideEffectOutbox.recordResult`.
- `Native/Ambitions/Core/Permissions/CalendarReminders/EventKitIntegrationService+02-EventKitIntegrationService.swift`
  records reminder and calendar-event success, failed-save, and
  permission-denied results.
- `Native/Ambitions/Core/Permissions/CalendarReminders/EventKitIntegrationService+03-EventKitIntegrationService.swift`
  records confirmed Time calendar-block success, failure, and
  permission-denied results.
- `Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/ReminderOutbox.swift`
  was deleted because it had no production callers and duplicated the
  `EventKitOutbox` reminder side-effect path used by
  `EventKitIntegrationService`.
- `Native/AmbitionsTests/App/EventKitIntegrationServiceTests.swift`,
  `Native/AmbitionsTests/App/CalendarRealityServiceTests.swift`,
  `Native/AmbitionsTests/App/EventKitIntegrationTestDoubles.swift`, and
  `Native/AmbitionsTests/LocalRuntimeOS/SideEffectSystem/SideEffectSystemTests.swift`
  add focused result-receipt coverage and shared EventKit test doubles.

Validation recorded in this addendum:

- `xcrun simctl boot 0F5F5AC4-4303-47C8-9BDC-EB5F57A0F79E`: exit 0.
- `xcrun simctl bootstatus 0F5F5AC4-4303-47C8-9BDC-EB5F57A0F79E -b`:
  exit 0.
- `xcodegen generate`: exit 0 after deleting the unused `ReminderOutbox`
  source owner.
- `/usr/local/bin/gtimeout 900 xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,id=0F5F5AC4-4303-47C8-9BDC-EB5F57A0F79E" -derivedDataPath output/DerivedData-XcodeBuildMCP -skipMacroValidation -skipPackagePluginValidation -collect-test-diagnostics never -only-testing:AmbitionsTests/ExternalActionCommandServiceTests -resultBundlePath output/amb1732-external-action-command-service-current.xcresult COMPILER_INDEX_STORE_ENABLE=NO ONLY_ACTIVE_ARCH=YES`:
  exit 0, 11 tests passed.
- `/usr/local/bin/gtimeout 1200 xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,id=0F5F5AC4-4303-47C8-9BDC-EB5F57A0F79E" -derivedDataPath output/DerivedData-XcodeBuildMCP -skipMacroValidation -skipPackagePluginValidation -collect-test-diagnostics never -only-testing:AmbitionsTests/EventKitIntegrationServiceTests -only-testing:AmbitionsTests/CalendarRealityServiceTests -only-testing:AmbitionsTests/SideEffectSystemTests -only-testing:AmbitionsTests/ExternalActionCommandServiceTests -resultBundlePath output/amb1732-eventkit-reminders-result-receipts-after-prune.xcresult COMPILER_INDEX_STORE_ENABLE=NO ONLY_ACTIVE_ARCH=YES`:
  exit 0, 40 tests passed.

Remaining AMB-1732 blockers:

- Device notification action, widget/lifecycle, Share Extension lifecycle, App
  Intent/Shortcuts invocation, terminated-app proof, and EventKit/Reminders
  device permission/write proof remain unproven.
- Replay proof for external payload rejection receipts and EventKit/Reminders
  result receipts remains bounded to focused unit tests.

## Closeout Boundary

- Final Architecture Tree inspected: yes, through
  `docs/truth/PRODUCT_DESIGN_TRUTH.md`.
- Canonical owners touched by the AMB-1732 addendum:
  `Core/LocalRuntimeOS/Commands`,
  `Core/LocalRuntimeOS/SideEffectSystem`,
  `Core/Permissions/CalendarReminders`, and `Native/AmbitionsTests`.
- Swift owners touched:
  `Native/Ambitions/Core/LocalRuntimeOS/Commands/ExternalActionCommandService.swift`,
  `Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/EventKitOutbox.swift`,
  `Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/ReminderOutbox.swift`
  deleted as unused duplicate authority,
  `Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/SideEffectPolicyEngine.swift`,
  `Native/Ambitions/Core/Permissions/CalendarReminders/EventKitIntegrationService+02-EventKitIntegrationService.swift`,
  `Native/Ambitions/Core/Permissions/CalendarReminders/EventKitIntegrationService+03-EventKitIntegrationService.swift`,
  `Native/AmbitionsTests/LocalRuntimeOS/Commands/ExternalActionCommandServiceTests.swift`,
  `Native/AmbitionsTests/LocalRuntimeOS/SideEffectSystem/SideEffectSystemTests.swift`,
  `Native/AmbitionsTests/App/EventKitIntegrationServiceTests.swift`, and
  `Native/AmbitionsTests/App/CalendarRealityServiceTests.swift`.
- Files moved or created in Swift source:
  `Native/AmbitionsTests/App/EventKitIntegrationTestDoubles.swift` was created
  as test-only support.
- Old/noncanonical source paths removed:
  `Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/ReminderOutbox.swift`
  was removed after source search found no production callers.
- Compatibility shims left behind: none.
- Architecture debt remains: yes, in widget payload replay/device proof,
  notification device-action proof, App Intent/Share Extension lifecycle proof,
  EventKit/Reminders device permission/write proof, and downstream in-app
  mutation paths covered by AMB-1666/AMB-1667.
- Next AMB-1668 repair train: external-surface device/lifecycle proof under
  AMB-1668 release/device blockers.
- No equivalent folder/path interpretation was used.
- No adapter Green, runtime authority Green, release readiness, or device proof
  claim is made.
