# External Command Adapter Contract

Status: AMB-1721 Implemented Yellow contract

Snapshot date: 2026-07-02

Parent: AMB-1668 External Adapter Mutation Enforcement

Baseline inspected: `35975f72cb5d4918057b879ecfc31f350fdd8121` on `main`

Scope: AMB-1721 defines the common contract for system-surface mutation
adapters. It does not change Swift behavior, migrate runtime authority, prove
terminated-app behavior, prove extension lifecycle behavior, prove device
notifications, prove widget or Live Activity behavior, approve CloudKit private
graph sync, or make external adapters Green.

`ExternalCommandAdapter` is used here as the Linear contract name. This artifact
does not add a new Swift protocol or source architecture noun. Later AMB-1668
leaves must either enforce this contract through existing command, outbox, and
projection types, or justify a source-level consolidation with deletion or
collapse of duplicate authority in the same scoped train.

## Proof Ceiling

Evidence class: Implemented Yellow.

This artifact is static source and governance evidence only. It defines required
adapter behavior, receipt fields, rejection behavior, privacy boundaries, and
follow-up proof. It does not prove runtime correctness, release-build behavior,
device behavior, accessibility behavior, privacy/legal approval, TestFlight
readiness, App Store readiness, or total LocalRuntimeOS completion.

No adapter Green is claimed. Green requires linked current evidence for the
exact surface and exact behavior.

## Canonical Laws

External and system surfaces must preserve:

```text
Command -> Event -> Projection -> Receipt -> Replay
```

Current architecture direction remains:

```text
law over lore
deep runtime, boring UI
delete before naming
Green requires linked evidence
```

System surfaces must keep the user-facing UI plain, native, and object-led.
Runtime words such as command, projection, receipt, ledger, outbox, adapter,
kernel, engine, and authority must not become first-viewport product language.

Persistent product surfaces remain Today / Goals / Time / You. Capture remains
the global composer. Motion remains behavior under Stage/Motion. R2 and Source
Atlas remain public/reference/freshness infrastructure only; they are not a
private life graph backend.

## Adapter Classification

| Classification | Required meaning | Green allowed? |
| --- | --- | --- |
| `projectionOnlyReader` | Surface reads or materializes redacted projection data and cannot mutate canonical private graph state. | No, until privacy, staleness, and runtime behavior proof exists for the exact surface. |
| `commandHandoff` | Surface records extension-safe input and the app imports it as an `AmbitionsCommand` or equivalent existing command path before meaningful mutation. | No, until import, receipt, replay, and lifecycle proof exists. |
| `sideEffectOutbox` | Surface requests an external OS side effect only after local commit evidence or a no-user-state-mutation policy decision, then records ledger/outbox status. | No, until side-effect result and receipt proof exists. |
| `rejectionReceipt` | Unsupported, unsafe, privacy-sensitive, or unproven mutation attempts produce an explicit blocked, unsupported, failed-safely, or degraded receipt instead of mutating state. | No, until rejection receipt proof exists. |
| `blockedUnknown` | Static evidence cannot prove projection-only, command handoff, side-effect outbox, or rejection receipt behavior. | No. Must link a follow-up issue and stay Yellow or Red. |
| `unsafeDebt` | A direct canonical write or external write marker remains outside the required authority path. | No. Must be moved, deleted, quarantined, or proven adapter-only by a scoped train. |

## Required Evidence Record

Each external/system surface must be representable by a proof record with these
fields before it can be accepted beyond Yellow:

| Field | Required content |
| --- | --- |
| Adapter ID | Stable surface and action name, such as widget snapshot read, App Intent capture creation, notification action payload, EventKit write, or share extension intake. |
| Source surface | Widget, Live Activity, App Intent, Share Extension, notification, EventKit, Reminders, background task, deep link, Spotlight/Handoff, continuity, or preview/debug fixture. |
| Input boundary | The exact payload type, schema version when present, extension-safety rule, and whether the payload is app-group handoff data, redacted projection data, or in-app command data. |
| Privacy boundary | Privacy classification, redaction decision, local-only status, `containsPrivateRuntimeData` decision when applicable, and the proof artifact that blocked private graph egress. |
| Routing classification | One of `projectionOnlyReader`, `commandHandoff`, `sideEffectOutbox`, `rejectionReceipt`, `blockedUnknown`, or `unsafeDebt`. |
| Command route | The exact existing command, command executor, app import, or command service used for mutation, or an explicit statement that no mutation is allowed. |
| Projection route | The exact projection snapshot, surface read adapter, or redacted app-group snapshot used by read-only external surfaces. |
| Receipt route | Command receipt, side-effect ledger record, rejection receipt, degraded fact, or explicit unsupported receipt. Missing receipt proof keeps the surface Yellow. |
| Local commit evidence | Required for any external write that depends on user-state mutation. The proof must identify the local commit receipt or state that no user-state mutation is allowed. |
| Forbidden writer check | Evidence that the external surface did not write canonical private graph state directly, plus any remaining unsafe or unknown direct-write markers. |
| Replay and recovery | How the command or event can be replayed, rejected, or safely ignored after app relaunch, extension termination, duplicate delivery, stale snapshot, or denied permission. |
| Validation artifacts | Tests, audit command output, device proof, simulator proof, or exact not-run reason. |
| Follow-up owner | The AMB leaf that must close any missing proof. |

## Contract Rules

1. External readers are projection-only by default.
   Widget, Live Activity, Spotlight/Handoff, and other external readers may read
   only redacted projection snapshots. They must not write canonical private
   graph state.

2. External mutators must enter the command path or be rejected.
   App Intents, share extension intake, notification actions, widget payloads,
   deep links, and background entry points must route meaningful mutation into
   existing command authority before state changes. Unsupported or unsafe actions
   must produce `rejectionReceipt` evidence instead of silently mutating.

3. App group storage is not canonical graph storage.
   App group files may hold extension-safe handoff queues or redacted projection
   snapshots. They must not become private life graph authority.

4. External OS writes require local commit evidence.
   EventKit and Reminders writes must be guarded by local commit evidence or an
   explicit no-user-state-mutation policy decision, then recorded through the
   ExternalWrites outbox and ledger. Legacy repository writes after external
   saves remain unsafe debt until a scoped train closes them.

5. Notification actions degrade before unsafe mutation.
   Notification payloads that cannot prove command, receipt, and replay behavior
   must open Ambitions or route to review instead of completing, snoozing,
   delaying, or shrinking steps directly.

6. Projection export must be redacted and stale-aware.
   External snapshot writers must validate projection privacy, avoid private user
   text and sensitive classes, record failed-safely outcomes, and preserve stale
   or unavailable states rather than fabricating fresh state.

7. Continuity cannot apply private graph data remotely.
   CloudKit and continuity paths remain local-first and disabled or review-gated
   for private graph state unless a future canon approves user-owned sync with
   linked proof. Zone setup or account status checks are not private graph sync
   approval.

8. Preview/debug fixtures are not production authority proof.
   Preview and test-only adapters can support local tests, but they cannot prove
   release-build adapter behavior. Unknown preview direct-write markers remain
   audit sentinels until release-build and adapter behavior proof exists.

## Shared Source Anchors

These source anchors are not a new adapter layer. They are the existing paths
that later AMB-1668 proof leaves must inspect against this contract.

| Anchor group | Existing source paths | Contract role |
| --- | --- | --- |
| Command bridge and external actions | `Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/AppIntentBridge.swift`, `Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/ExternalCreationImportService.swift`, `Native/Ambitions/Core/LocalRuntimeOS/Commands/ExternalActionCommandService.swift` | Existing command handoff and action-routing anchors for App Intents, Share Extension import, notification actions, and widget payload handling. |
| Side-effect and receipt ledger | `Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/SideEffectOutbox.swift`, `Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/SideEffectLedgerModels.swift`, `Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/ExternalReconciliation.swift` | Existing outbox, receipt, blocked/degraded status, and review-summary anchors for external side effects and rejection evidence. |
| Surface-specific outboxes and intake | `Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/NotificationOutbox.swift`, `Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/EventKitOutbox.swift`, `Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/WidgetRefreshOutbox.swift`, `Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/ShareExtensionIntake.swift` | Existing per-surface recording anchors for notification refreshes, calendar/reminder side effects, widget refresh receipts, and share-extension intake receipts. |
| External snapshots and handoff storage | `Native/Ambitions/Projection/ExternalSnapshots/ExternalCreationContracts.swift`, `Native/Ambitions/Projection/ExternalSnapshots/ExternalSurfaceSnapshotWriter.swift`, `Native/Ambitions/Projection/ExternalSnapshots/SharedExternalSnapshotStore.swift`, `Native/Ambitions/Projection/ExternalSnapshots/ExternalWidgetProjection.swift` | Existing projection-only and extension-safe handoff anchors for app-group snapshots and external creation queues. |

## Current Source Mapping

| Surface | Existing source anchor | AMB-1721 classification | Proof ceiling and follow-up |
| --- | --- | --- | --- |
| App Intent creation | `Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/AppIntentBridge.swift`, `Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/ExternalCreationImportService.swift`, `Native/Ambitions/App/Intents/AmbitionsCreationIntents.swift` | `commandHandoff` | Durable handoff then `AmbitionsCommand(kind: .quickCapture)` import is source-present. Terminated-app import and adapter receipt proof remain AMB-1722. |
| App Intent navigation and guarded controls | `Native/Ambitions/App/Intents/AmbitionsStepInspectionIntents.swift`, `Native/Ambitions/App/Intents/AmbitionsSystemControlIntent.swift`, `Native/Ambitions/App/Intents/OpenAmbitionsDestinationIntent.swift`, `Native/Ambitions/App/AppIntentLaunchRouter.swift` | `commandHandoff` or `rejectionReceipt` | Static source queues routes and opens app for guarded controls. Mutation proof and rejection receipt proof remain AMB-1722. |
| Share Extension intake | `Native/AmbitionsShareExtension/ShareViewController.swift`, `Native/AmbitionsShareExtension/ShareIntakeView.swift`, `Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/ShareExtensionIntake.swift`, `Native/Ambitions/Projection/ExternalSnapshots/ExternalCreationContracts.swift`, `Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/ExternalCreationImportService.swift` | `commandHandoff` | Extension-safe handoff and app import are source-present. Lifecycle, redaction, duplicate delivery, and receipt proof remain AMB-1722. |
| Widget and Live Activity UI reads | `Native/AmbitionsWidgetExtension/NextStepWidget.swift`, `Native/AmbitionsWidgetExtension/NextStepLiveActivityWidget.swift`, `Native/Ambitions/Projection/ExternalSnapshots/ExternalWidgetProjection.swift`, `Native/Ambitions/Projection/ExternalSnapshots/SharedExternalSnapshotStore.swift` | `projectionOnlyReader` | Read-only snapshot rendering is source-present. Device/widget privacy, stale snapshot, and Live Activity proof remain AMB-1724. |
| Widget payload action bridge | `Native/Ambitions/App/AppBootstrapper.swift`, `Native/Ambitions/Core/LocalRuntimeOS/Commands/ExternalActionCommandService.swift`, `Native/Ambitions/Core/LocalRuntimeOS/Boundary/AmbitionsRuntimeServices.swift` | `rejectionReceipt` source-present / focused XCTest passed | AMB-1732 downgrades mutating widget payloads to Today review routing and records local-only `commandBridge` rejection receipts when a recorder is configured. Focused simulator XCTest passed on 2026-07-03. Device/lifecycle and replay proof remain before any parent Green. |
| Notification scheduling | `Native/Ambitions/Core/Permissions/LocalNotificationFoundation.swift`, `Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/NotificationOutbox.swift` | `sideEffectOutbox` | Scheduling reads safe snapshots and records side effects. Device notification proof and authorization-denied receipt proof remain AMB-1722. |
| Notification action payloads | `Native/Ambitions/App/AppBootstrapper.swift`, `Native/Ambitions/Core/LocalRuntimeOS/Commands/ExternalActionCommandService.swift`, `Native/Ambitions/App/AppExternalRouteTranslator.swift` | `rejectionReceipt` source-present / focused XCTest passed | AMB-1732 downgrades mutating notification payloads to open-Today routing and records local-only `commandBridge` rejection receipts when a recorder is configured. Focused simulator XCTest passed on 2026-07-03. Device notification action proof remains before any parent Green. |
| EventKit writes | `Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/EventKitOutbox.swift`, `Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/EventKitOutbox+EventKitStoreClientLive.swift`, `Native/Ambitions/Core/Permissions/CalendarReminders/EventKitIntegrationService+02-EventKitIntegrationService.swift`, `Native/Ambitions/Core/Permissions/CalendarReminders/EventKitIntegrationService+03-EventKitIntegrationService.swift` | `sideEffectOutbox` source-present / focused XCTest passed | AMB-1732 records EventKit calendar-event and confirmed Time calendar-block success, failure, and permission-denied results through `SideEffectOutbox.recordResult` after local-commit gating. Device EventKit and replay proof remain before any parent Green. |
| Reminders writes | `Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/EventKitOutbox.swift`, `Native/Ambitions/Core/LocalRuntimeOS/Storage/SwiftDataReminderRepository.swift` | `sideEffectOutbox` source-present / focused XCTest passed | AMB-1732 records reminder success, failed-save, and permission-denied results through `SideEffectOutbox.recordResult` after local-commit gating. AMB-1732 also removes the unused `ReminderOutbox` anchor so the inspected reminder side-effect path is `EventKitOutbox` through `EventKitIntegrationService`. Device Reminders proof remains before any parent Green. |
| External projection export | `Native/Ambitions/Projection/ExternalSnapshots/ExternalSurfaceSnapshotWriter.swift`, `Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/WidgetRefreshOutbox.swift`, `Native/Ambitions/Core/LocalRuntimeOS/Storage/AppGroupSnapshotStore.swift`, `Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/PrivacyExternalBoundaryGate.swift` | `projectionOnlyReader` | Privacy validation and failed-safely recording are source-present. Privacy/staleness tests and external reader proof remain AMB-1724. |
| Spotlight/Handoff and external object reopening payloads | `Native/Ambitions/Projection/ExternalSnapshots/ExternalSurfaceActionPayloads.swift`, `Native/Ambitions/Projection/ExternalSnapshots/ExternalObjectReopeningProjector.swift`, `Native/Ambitions/Projection/ExternalSnapshots/ExternalSurfaceControlContracts.swift` | `projectionOnlyReader` | Safe titles, routes, and optional contracts are source-present; export/indexing proof remains AMB-1724. |
| CloudKit continuity | `Native/Ambitions/Core/LocalRuntimeOS/Continuity/CloudKitContinuityClient.swift`, `Native/Ambitions/Core/LocalRuntimeOS/Continuity/ContinuityAuthorityGate.swift`, `Native/Ambitions/Core/LocalRuntimeOS/Continuity/SyncEligibilityPolicy.swift`, `Native/Ambitions/Core/LocalRuntimeOS/Continuity/LocalAuthoritativeSyncModel.swift` | `blockedUnknown` for private graph apply | Prior audit found no remote private-graph apply writer and continuity defaults local-only/disabled, but this is not sync approval or behavior proof. Follow-up remains AMB-1680 and any AMB-1668 overlap. |
| Preview/debug external creation handoff | `Native/Ambitions/PreviewSupport/PreviewAppContainer.swift`, `Native/AmbitionsTests/App/ExternalCreationImportServiceTests.swift` | `blockedUnknown` support evidence | Preview import tests support command handoff only. Preview temporary storage remains an unknown direct-write sentinel and not production proof. |

## Required AMB-1668 Follow-Up Proof

| Follow-up | Required proof before parent closure |
| --- | --- |
| AMB-1722 | Audit App Intent, widget payload, share extension, notification, and app external-route mutation paths against this contract. Produce receipt/rejection proof or keep explicit Yellow/Red gaps. |
| AMB-1723 | Audit EventKit and Reminders writes against local commit, side-effect outbox, result receipt, permission-denied, and legacy repository-debt requirements. |
| AMB-1724 | Audit external projection snapshot writers and readers for projection-only behavior, privacy redaction, stale/unavailable handling, and no direct canonical writes. |
| AMB-1668 parent | Close only after child evidence shows every mutating system surface has command receipt or explicit rejection receipt, and every external reader is projection-only with privacy proof. |

## Closeout Boundary

- Final Architecture Tree inspected: yes, through
  `docs/truth/PRODUCT_DESIGN_TRUTH.md`.
- Canonical owners touched by AMB-1721: `docs/audits` only.
- Swift owners touched by AMB-1721: none. AMB-1732 source owners are recorded
  in the child audit addenda for widget/notification rejection receipts and
  EventKit/Reminders result receipts.
- Files moved or created in Swift source by AMB-1721: none.
- Old/noncanonical source paths removed: none.
- Compatibility shims left behind: none.
- Architecture debt remains: yes, in device/lifecycle system adapter proof,
  external projection privacy/staleness proof, CloudKit continuity proof limits,
  external payload replay proof beyond focused unit tests, and the preview
  temporary external-creation audit sentinel.
- Next repair train: AMB-1722 under AMB-1668.
- No equivalent folder/path interpretation was used.
- No adapter Green or runtime authority Green claim is made.
