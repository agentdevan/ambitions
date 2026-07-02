# External Adapter EventKit And Reminders Outbox Routing Audit

Status: AMB-1723 Implemented Yellow route audit

Snapshot date: 2026-07-02

Parent: AMB-1668 External Adapter Mutation Enforcement

Baseline inspected: `39ebf1cf1550ad6a169ba7c71fa684ae2fdf56b8` on `main`

Scope: AMB-1723 audits EventKit calendar-event writes, confirmed Time calendar
block writes, Reminders writes, permission-denied paths, side-effect outbox
routing, result receipt linkage, and legacy reminder repository debt against the
AMB-1721 `ExternalCommandAdapter` governance contract. This artifact does not
change Swift behavior, migrate runtime authority, approve EventKit calendar
write behavior, prove Reminders behavior on device, prove permission prompt
behavior, prove release readiness, or close AMB-1724 external projection work.

No EventKit, Reminders, side-effect outbox, device, privacy/legal, release, or runtime Green is claimed.

## Proof Ceiling

Evidence class: Implemented Yellow.

This audit is static source, config, and existing-test inspection only. It uses
the AMB-1721 adapter classifications from
`docs/audits/external-command-adapter-contract.md`: `sideEffectOutbox`,
`rejectionReceipt`, `blockedUnknown`, and `unsafeDebt` are the relevant labels
for this leaf. Existing tests are cited as source evidence; this document does
not claim they were run for this leaf unless closeout records current command
output.

Green requires linked current evidence for the exact route and exact behavior.
Missing linked result receipts, replay proof, device proof, permission prompt
proof, and legacy repository debt keep this leaf Yellow.

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
| EventKit direct store client methods | `sideEffectOutbox` only when called behind the integration-service outbox gate | `Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/EventKitOutbox+EventKitStoreClientLive.swift` contains the direct `EKReminder` and `EKEvent` save calls. `Native/Ambitions/Core/Permissions/CalendarReminders/EventKitIntegrationService+04-EventKitStoreClientLive.swift` exposes them through `EventKitStoreClient.saveReminder` and `saveEvent`. | Source search found inspected callers route through `EventKitIntegrationService` before `storeClient.saveReminder` or `storeClient.saveEvent`. | The direct client methods are not a standalone proof boundary. Any future direct caller outside the integration-service outbox gate would be `unsafeDebt`. No device EventKit proof. |
| Calendar event write from goal step | `sideEffectOutbox` for the local-commit overload; `rejectionReceipt` missing for current no-localCommit callers | `Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/EventKitOutbox.swift` records calendar side-effect requests. `EventKitIntegrationService+02-EventKitIntegrationService.swift` queues a calendar side effect with `.localCommitRequired`, blocks before `storeClient.saveEvent` when no local commit is present, records `.blocked`/`.failedSafely` for denied or invalid paths, and records `.succeeded` after save. `Native/Ambitions/Projection/SurfaceLenses/GoalsFeatureService+10-performMutation.swift` calls the public protocol method without `SideEffectLocalCommitEvidence`. | `Native/AmbitionsTests/App/EventKitIntegrationServiceTests.swift` covers missing suggested date `failedSafely`, authorization-denied blocked ledger, no-localCommit blocked before save, local-commit success ledger records, and distinct ledger entries across repeated successes. | Current production-facing protocol call sites do not pass local commit evidence, so they should be treated as blocked/Yellow, not working write proof. Success records are ledger records, not linked `SideEffectOutbox.recordResult` receipts with an external receipt ID. |
| Confirmed Time calendar block write | `sideEffectOutbox` for the local-commit overload; `rejectionReceipt` missing for no-localCommit callers | `EventKitIntegrationService+03-EventKitIntegrationService.swift` requires executable timing, requests write-only calendar permission, queues a `.localCommitRequired` side effect, blocks before save without local commit evidence, and records a completion record after `storeClient.saveEvent`. | `Native/AmbitionsTests/App/CalendarRealityServiceTests.swift` covers confirmed-block write with local commit, write-only authorization request, no-localCommit blocked before save, and local-only calendar read degradation. | The completion record currently uses `.recordedLocalOnly` while `externalEffect` remains true, and it is not a linked `SideEffectReceipt`. No current production caller was found passing local commit evidence to the confirmed block overload. |
| Calendar read/open-window derivation | `sideEffectOutbox` local-only / no external write | `EventKitIntegrationService+03-EventKitIntegrationService.swift` reads calendar events only after permission allows read context, projects derived busy windows with generic titles, records `.recordedLocalOnly` for successful local read work, and records `.blocked` local-only when permission is denied. | `CalendarRealityServiceTests.swift` covers contextual read request, redacted busy-window titles, denied-access degradation without fetching events, and local-only side-effect records. | Read path is not an external write proof. It remains relevant permission/privacy evidence only. |
| Reminder write from Today or Goals | `sideEffectOutbox` for the local-commit overload; `unsafeDebt` when the optional legacy repository persists reminder objects | `EventKitIntegrationService+02-EventKitIntegrationService.swift` queues a `.localCommitRequired` side effect before `storeClient.saveReminder`, blocks before save without local commit evidence, records `.succeeded` after save, and optionally calls `reminderRepository.saveReminders`. `TodayFeatureService+02-RepositoryBackedTodayService+Repository05-performFeedbackAction.swift` and `GoalsFeatureService+10-performMutation.swift` call the public protocol method without local commit evidence. | `EventKitIntegrationServiceTests.swift` covers reminder authorization denial, local-commit success payload minimization, no-localCommit blocked before save, and optional `SwiftDataReminderRepository` persistence after success. | Reminder permission denial currently throws before recording an outbox rejection/blocked receipt. Optional reminder persistence still uses `Native/Ambitions/Core/Persistence/SwiftDataRepositories+08-SwiftDataReminderRepository.swift`, which remains legacy `unsafeDebt` under AMB-1667/AMB-1719. |
| `ReminderOutbox` canonical anchor | `blockedUnknown` / source-present unused anchor | `Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/ReminderOutbox.swift` can enqueue a reminder write with required local commit evidence, but inspected production write paths use `EventKitOutbox` through `EventKitIntegrationService`; no production call to `ReminderOutbox.enqueueReminderWrite` was found. | `Native/AmbitionsTests/LocalRuntimeOS/SideEffectSystem/SideEffectSystemTests.swift` verifies the SideEffectSystem owner inventory includes `ReminderOutbox.swift`, and the generic outbox tests cover local-commit gating. | Parent Green cannot rely on `ReminderOutbox` consumption until a scoped train either wires it, deletes/collapses it into the actual EventKit reminder path, or records why `EventKitOutbox` is the single canonical reminder side-effect path. |
| SideEffectOutbox local commit gate | `sideEffectOutbox` source-present gate | `Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/SideEffectOutbox.swift` blocks external effects without committed local runtime proof, creates leases when the policy allows external write attempts, and can record result receipts through `recordResult`. `Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/SideEffectLedgerModels.swift` defines the side-effect ledger record/status/boundary model used by the inspected EventKit rows. | `SideEffectSystemTests.swift` covers blocked external attempts with no local commit, blocked attempts with the wrong commit requirement, runtime local commit evidence allowing external attempt, failed-safe result receipts preserving local commit receipt IDs, confirmed external write leasing, and legacy unit-of-work receipts not permitting external writes. | `EventKitIntegrationService` records queued/succeeded/failed ledger rows but does not currently call `SideEffectOutbox.recordResult` for EventKit success/failure result receipt linkage. |

## Acceptance Verdict

AMB-1723 acceptance is satisfied at an Implemented Yellow ceiling:

- EventKit and Reminders writes are inspected and classified.
- External writes are outbox-gated before EventKit save when local commit proof
  is absent.
- Local-commit overloads have focused source/test evidence for queued and
  successful ledger records.
- Calendar read/open-window paths are local-only and redacted in inspected
  source/tests.
- Current Today/Goals reminder and calendar callers use no-localCommit protocol
  methods, so they must be treated as blocked/Yellow rather than successful
  external writes.
- Reminder permission denial lacks an explicit outbox rejection record.
- EventKit success/failure paths record ledger status rows but not linked
  `SideEffectReceipt` result receipts through `SideEffectOutbox.recordResult`.
- Reminder object persistence after external save remains legacy
  `SwiftDataReminderRepository` unsafe debt.

No AMB-1723 route is promoted to Green.

## Proof And Non-Claims

Verified by this audit:

- Static source inspection found EventKit save calls behind the
  `EventKitIntegrationService` outbox gate in the inspected paths.
- Static source inspection found no local commit evidence passed by current
  Today/Goals protocol call sites.
- Static source inspection found no production caller for
  `ReminderOutbox.enqueueReminderWrite`.
- Existing test sources cover local commit gating, denied/missing-data calendar
  paths, local-commit success ledger rows, reminder payload minimization, and
  generic side-effect receipt behavior.

Not verified by this audit:

- Current Xcode test execution.
- Device EventKit, Reminders, or permission prompt behavior.
- Real Calendar or Reminders app write behavior.
- App Store privacy/data-safety readiness.
- Accessibility, visual, performance, TestFlight, release, privacy/legal, R2,
  Source Atlas production, CloudKit, widget, notification, Live Activity, or
  external projection readiness.

## Closeout Boundary

- Final Architecture Tree inspected: yes, through
  `docs/truth/PRODUCT_DESIGN_TRUTH.md`.
- Canonical owners touched by AMB-1723: `docs/audits` only.
- Swift owners touched: none.
- Files moved or created in Swift source: none.
- Old/noncanonical source paths removed: none.
- Compatibility shims left behind: none.
- Architecture debt remains: yes, in no-localCommit Today/Goals EventKit and
  Reminders callers, missing reminder permission-denied outbox receipt, missing
  linked EventKit result receipts, unconsumed `ReminderOutbox`, and legacy
  `SwiftDataReminderRepository` persistence after reminder save.
- Next AMB-1668 repair train: AMB-1724 for projection-only snapshot and
  redaction tests.
- No equivalent folder/path interpretation was used.
- No EventKit, Reminders, outbox, runtime authority, device, privacy/legal, or
  release Green claim is made.
