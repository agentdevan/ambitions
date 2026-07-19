# External Adapter EventKit And Reminders Outbox Routing Audit

Status: AMB-1723 Implemented Yellow route audit with AMB-1732 result receipt source repair addendum

Snapshot date: 2026-07-03

AMB-1732 source repair addendum: 2026-07-03

Parent: AMB-1668 External Adapter Mutation Enforcement

Baseline inspected: `39ebf1cf1550ad6a169ba7c71fa684ae2fdf56b8` on `main`

Scope: AMB-1723 audits EventKit calendar-event writes, confirmed Time calendar
block writes, Reminders writes, permission-denied paths, side-effect outbox
routing, result receipt linkage, and reminder outbox ownership collapse
against the AMB-1721 `ExternalCommandAdapter` governance contract. The
AMB-1732 addendum records the source repair that now links EventKit and
Reminders results through `SideEffectOutbox.recordResult`. This artifact does
not approve EventKit calendar write behavior, prove Reminders behavior on
device, prove permission prompt behavior, prove release readiness, or close
AMB-1724 external projection work.

No EventKit, Reminders, side-effect outbox, device, privacy/legal, release, or runtime Green is claimed.

## Proof Ceiling

Evidence class: Implemented Yellow.

The original AMB-1723 audit was static source, config, and existing-test
inspection. The AMB-1732 addendum is source and focused simulator XCTest
evidence. It uses the AMB-1721 adapter classifications from
`docs/audits/external-command-adapter-contract.md`: `sideEffectOutbox`,
`rejectionReceipt`, and `blockedUnknown` are the relevant labels for this leaf.

Green requires linked current evidence for the exact route and exact behavior.
Device proof, permission prompt proof, external-surface lifecycle proof, and
replay proof beyond focused unit tests keep this leaf Yellow.

## Canonical Laws Preserved

External OS writes must preserve:

```text
Command -> Event -> Projection -> Receipt -> Replay
```

EventKit and Reminders writes must not become unreplayable side effects. A
write attempt needs local commit evidence or an explicit no-user-state-mutation
decision, outbox/ledger inspection, permission-denied safe handling, and receipt
linkage before Green.

Calendar access remains contextual. `docs/platform/APPLE_PLATFORM_SOURCE_ATLAS_IOS.md`
states that EventKit calendar write is not approved by default, Calendar may
inform fixed points, and Ambitions must not become a calendar clone.

## Route Classification Matrix

| Route | AMB-1723 classification | Static source evidence | Existing test/config evidence inspected | Yellow gap or follow-up |
| --- | --- | --- | --- | --- |
| EventKit direct store client methods | `sideEffectOutbox` only when called behind the integration-service outbox gate | `Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/EventKitOutbox+EventKitStoreClientLive.swift` contains the direct `EKReminder` and `EKEvent` save calls. `Native/Ambitions/Core/Permissions/CalendarReminders/EventKitIntegrationService+04-EventKitStoreClientLive.swift` exposes them through `EventKitStoreClient.saveReminder` and `saveEvent`. | Source search found inspected callers route through `EventKitIntegrationService` before `storeClient.saveReminder` or `storeClient.saveEvent`. | The direct client methods are not a standalone proof boundary. Any future direct caller outside the integration-service outbox gate would be `unsafeDebt`. No device EventKit proof. |
| Calendar event write from goal step | `sideEffectOutbox` for the local-commit overload; no-localCommit callers remain blocked/Yellow | `Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/EventKitOutbox.swift` records calendar side-effect requests and result receipts. `EventKitIntegrationService+02-EventKitIntegrationService.swift` queues a calendar side effect with `.localCommitRequired`, blocks before `storeClient.saveEvent` when no local commit is present, records permission-denied results when permission is unavailable, records `.succeeded` results with the external EventKit identifier after save, and records `.failedSafely` results when save throws. `Native/Ambitions/Projection/SurfaceLenses/GoalsFeatureService+10-performMutation.swift` calls the public protocol method without `SideEffectLocalCommitEvidence`, so it remains blocked/Yellow. | `Native/AmbitionsTests/App/EventKitIntegrationServiceTests.swift` covers missing suggested date `failedSafely`, authorization-denied result records, no-localCommit blocked before save, local-commit success result records with external receipt IDs, save-failure result records, and distinct ledger entries across repeated successes. Focused simulator XCTest passed on 2026-07-03. | Result receipts are now linked in focused tests. Device EventKit behavior, real permission prompt behavior, and replay/lifecycle proof remain missing. |
| Confirmed Time calendar block write | `sideEffectOutbox` for the local-commit overload; no-localCommit callers remain blocked/Yellow | `EventKitIntegrationService+03-EventKitIntegrationService.swift` requires executable timing, requests write-only calendar permission, queues a `.localCommitRequired` side effect, blocks before save without local commit evidence, records permission-denied results when write permission is unavailable, records `.succeeded` results with the external EventKit identifier after save, and records `.failedSafely` results when save throws. | `Native/AmbitionsTests/App/CalendarRealityServiceTests.swift` covers confirmed-block write with local commit, write-only authorization request, no-localCommit blocked before save, permission-denied result receipts, and local-only calendar read degradation. Focused simulator XCTest passed on 2026-07-03. | Result receipts are now linked in focused tests. No current production caller was found passing local commit evidence to the confirmed block overload; device EventKit behavior and replay/lifecycle proof remain missing. |
| Calendar read/open-window derivation | `sideEffectOutbox` local-only / no external write | `EventKitIntegrationService+03-EventKitIntegrationService.swift` reads calendar events only after permission allows read context, projects derived busy windows with generic titles, records `.recordedLocalOnly` for successful local read work, and records `.blocked` local-only when permission is denied. | `CalendarRealityServiceTests.swift` covers contextual read request, redacted busy-window titles, denied-access degradation without fetching events, and local-only side-effect records. | Read path is not an external write proof. It remains relevant permission/privacy evidence only. |
| Reminder write from Today or Goals | `sideEffectOutbox` for the local-commit overload; no-localCommit callers remain blocked/Yellow | `EventKitIntegrationService+02-EventKitIntegrationService.swift` queues a `.localCommitRequired` side effect before `storeClient.saveReminder`, blocks before save without local commit evidence, records permission-denied results when permission is unavailable, records `.succeeded` results with the external reminder identifier after save, records `.failedSafely` results when save throws, and optionally persists a local reminder object through `Native/Ambitions/Core/LocalRuntimeOS/Storage/SwiftDataReminderRepository.swift`. `TodayFeatureService+02-RepositoryBackedTodayService+Repository05-performFeedbackAction.swift` and `GoalsFeatureService+10-performMutation.swift` call the public protocol method without local commit evidence. AMB-1732 deleted the unused `ReminderOutbox.swift` duplicate anchor after source search found no production callers. | `EventKitIntegrationServiceTests.swift` covers reminder authorization denial result records, local-commit success payload minimization and result receipts, no-localCommit blocked before save, save-failure result receipts, and optional `SwiftDataReminderRepository` persistence after success. `ExternalWritesTests.swift` now asserts the deleted duplicate owner does not exist. Focused simulator XCTest passed on 2026-07-03. | Result receipts are now linked in focused tests and the reminder repository owner is canonical LocalRuntimeOS storage. Device Reminders behavior, real permission prompt behavior, and replay/lifecycle proof remain missing. |
| SideEffectOutbox local commit gate | `sideEffectOutbox` source-present gate | `Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/SideEffectOutbox.swift` blocks external effects without committed local runtime proof, creates leases when the policy allows external write attempts, and records result receipts through `recordResult`. `Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/SideEffectLedgerModels.swift` defines the side-effect ledger record/status/boundary model used by the inspected EventKit rows. | `ExternalWritesTests.swift` covers blocked external attempts with no local commit, blocked attempts with the wrong commit requirement, explicit unsupported boundary preservation, runtime local commit evidence allowing external attempt, failed-safe result receipts preserving local commit receipt IDs, confirmed external write leasing, and legacy unit-of-work receipts not permitting external writes. Focused simulator XCTest passed on 2026-07-03. | EventKit and Reminders write paths now call `SideEffectOutbox.recordResult` through `EventKitOutbox`. Replay/lifecycle proof remains bounded to focused unit tests. |

## Acceptance Verdict

AMB-1723 acceptance is satisfied at an Implemented Yellow ceiling:

- EventKit and Reminders writes are inspected and classified.
- External writes are outbox-gated before EventKit save when local commit proof
  is absent.
- Local-commit overloads have focused source/test evidence for queued attempts
  and success, failure, and permission-denied result receipts.
- Calendar read/open-window paths are local-only and redacted in inspected
  source/tests.
- Current Today/Goals reminder and calendar callers use no-localCommit protocol
  methods, so they must be treated as blocked/Yellow rather than successful
  external writes.
- Permission denial now records result receipts for reminders, calendar-event
  writes, and confirmed Time calendar-block writes in focused tests.
- EventKit success/failure paths now create linked `SideEffectReceipt` result
  receipts through `SideEffectOutbox.recordResult`.
- Reminder object persistence after external save uses canonical
  `SwiftDataReminderRepository` under `Core/LocalRuntimeOS/Storage`.
- `ReminderOutbox` duplicate authority was removed; the inspected reminder
  side-effect path is `EventKitOutbox` through `EventKitIntegrationService`.

No AMB-1723 route is promoted to Green.

## Proof And Non-Claims

Verified by this audit:

- Static source inspection found EventKit save calls behind the
  `EventKitIntegrationService` outbox gate in the inspected paths.
- Static source inspection found no local commit evidence passed by current
  Today/Goals protocol call sites.
- Static source inspection found no production caller for
  `ReminderOutbox.enqueueReminderWrite`, so AMB-1732 removed that duplicate
  owner and kept `EventKitOutbox` as the reminder side-effect path.
- Focused simulator tests cover local commit gating, denied/missing-data
  calendar paths, local-commit success result receipts, save-failure result
  receipts, permission-denied result receipts, reminder payload minimization,
  optional local reminder persistence, and generic side-effect receipt behavior.

Not verified by this audit:

- Device EventKit, Reminders, or permission prompt behavior.
- Real Calendar or Reminders app write behavior.
- App Store privacy/data-safety readiness.
- Accessibility, visual, performance, TestFlight, release, privacy/legal, R2,
  Source Atlas production, CloudKit, widget, notification, Live Activity, or
  external projection readiness.

## AMB-1732 Source Repair Addendum

Changed source:

- `Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/EventKitOutbox.swift`
  now exposes result recording through `SideEffectOutbox.recordResult`.
- `Native/Ambitions/Core/Permissions/CalendarReminders/EventKitIntegrationService+02-EventKitIntegrationService.swift`
  records reminder and calendar-event success, save-failure, and
  permission-denied results.
- `Native/Ambitions/Core/Permissions/CalendarReminders/EventKitIntegrationService+03-EventKitIntegrationService.swift`
  records confirmed Time calendar-block success, failure, and
  permission-denied results.
- `Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/SideEffectPolicyEngine.swift`
  preserves explicit requested boundaries for blocked decisions, including the
  `.unsupported` boundary used by external rejection receipts.
- `Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/ReminderOutbox.swift`
  was deleted as unused duplicate authority after source search found no
  production callers.
- `Native/AmbitionsTests/App/EventKitIntegrationServiceTests.swift`,
  `Native/AmbitionsTests/App/CalendarRealityServiceTests.swift`,
  `Native/AmbitionsTests/App/EventKitIntegrationTestDoubles.swift`, and
  `Native/AmbitionsTests/LocalRuntimeOS/ExternalWrites/ExternalWritesTests.swift`
  cover the result receipt behavior.

Validation recorded in this addendum:

- `xcodegen generate`: exit 0 after deleting the unused `ReminderOutbox`
  source owner.
- `/usr/local/bin/gtimeout 1200 xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,id=0F5F5AC4-4303-47C8-9BDC-EB5F57A0F79E" -derivedDataPath output/DerivedData-XcodeBuildMCP -skipMacroValidation -skipPackagePluginValidation -collect-test-diagnostics never -only-testing:AmbitionsTests/EventKitIntegrationServiceTests -only-testing:AmbitionsTests/CalendarRealityServiceTests -only-testing:AmbitionsTests/ExternalWritesTests -only-testing:AmbitionsTests/ExternalActionCommandServiceTests -resultBundlePath output/amb1732-eventkit-reminders-result-receipts-after-prune.xcresult COMPILER_INDEX_STORE_ENABLE=NO ONLY_ACTIVE_ARCH=YES`:
  exit 0, 40 tests passed.

## Closeout Boundary

- Final Architecture Tree inspected: yes, through
  `docs/truth/PRODUCT_DESIGN_TRUTH.md`.
- Canonical owners touched by AMB-1732 addendum:
  `Core/LocalRuntimeOS/ExternalWrites`,
  `Core/Permissions/CalendarReminders`, and `Native/AmbitionsTests`.
- Swift owners touched:
  `Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/EventKitOutbox.swift`,
  `Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/SideEffectPolicyEngine.swift`,
  `Native/Ambitions/Core/Permissions/CalendarReminders/EventKitIntegrationService+02-EventKitIntegrationService.swift`,
  `Native/Ambitions/Core/Permissions/CalendarReminders/EventKitIntegrationService+03-EventKitIntegrationService.swift`,
  `Native/AmbitionsTests/App/EventKitIntegrationServiceTests.swift`,
  `Native/AmbitionsTests/App/CalendarRealityServiceTests.swift`,
  `Native/AmbitionsTests/App/EventKitIntegrationTestDoubles.swift`, and
  `Native/AmbitionsTests/LocalRuntimeOS/ExternalWrites/ExternalWritesTests.swift`.
- Files moved or created in Swift source:
  `Native/AmbitionsTests/App/EventKitIntegrationTestDoubles.swift` was created
  as test-only support.
- Old/noncanonical source paths removed: none.
- Compatibility shims left behind: none.
- Architecture debt remains: yes, in no-localCommit Today/Goals EventKit and
  Reminders callers staying blocked/Yellow, missing device EventKit/Reminders
  permission/write proof, and replay/lifecycle proof beyond focused unit tests.
- Next AMB-1668 repair train: external-surface device/lifecycle proof under
  AMB-1668 release/device blockers.
- No equivalent folder/path interpretation was used.
- No EventKit, Reminders, outbox, runtime authority, device, privacy/legal, or
  release Green claim is made.
