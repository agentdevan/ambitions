# External Adapter Projection Snapshot And Redaction Audit

Status: AMB-1724 Implemented Yellow source/test boundary

Snapshot date: 2026-07-02

Parent: AMB-1668 External Adapter Mutation Enforcement

Baseline inspected: `38f142973fbecca15efd71a39fcac4ec5fe0c6ed` on `main`

Scope: AMB-1724 audits external projection snapshot writers, widget/Live
Activity snapshot readers, app-group snapshot records, Spotlight/Handoff
payloads, and redaction tests against the AMB-1721 `ExternalCommandAdapter`
governance contract. This slice adds focused XCTest coverage in
`Native/AmbitionsTests/App/ExternalSurfaceSnapshotBoundaryTests.swift` for the
external snapshot JSON field boundary and fail-closed shared snapshot record
reads. It does not start source migration parents, migrate runtime authority,
change SwiftUI widget UI, add widget interactivity, change App Intent behavior,
change Share Extension lifecycle behavior, or prove device behavior.

No widget, Live Activity, external snapshot, app-group, device, privacy/legal,
release, or parent Green is claimed.

## Proof Ceiling

Evidence class: Implemented Yellow.

This audit uses static source inspection plus focused test source. Current test
execution must be recorded in closeout before the new test can count as current
validation evidence. Even with passing tests, this leaf remains Yellow because
device widget rendering, device Live Activity behavior, extension lifecycle,
terminated-app behavior, app-group read/write behavior on device, privacy/legal
approval, and release readiness are not proven.

Green requires linked current evidence for the exact route and exact behavior.
Source names, truth files, test source, and audit prose cannot make a system
surface Green without current validation artifacts and the missing device/lifecycle
proof.

## Canonical Laws Preserved

External projection surfaces must preserve:

```text
Command -> Event -> Projection -> Receipt -> Replay
```

External readers are projection-only by default. App-group storage may hold
redacted projection snapshots and extension-safe handoff records, but it must
not become canonical private life graph storage. Widgets and Live Activities
must read only approved, redacted projection payloads and route any meaningful
mutation back through app/runtime validation.

## Route Classification Matrix

| Route | AMB-1724 classification | Static source evidence | Test evidence inspected or added | Yellow gap or follow-up |
| --- | --- | --- | --- | --- |
| External snapshot writer | `projectionOnlyReader` | `Native/Ambitions/Projection/ExternalSnapshots/ExternalSurfaceSnapshotWriter.swift` reads `ProjectionStore` records for `.widget` and `.privacy`, decodes `WidgetProjection` and `PrivacyProjection`, validates privacy classes and redaction IDs, builds `ExternalSurfaceSnapshot`, creates an `AppGroupSnapshotRecord` with `containsPrivateRuntimeData: false`, evaluates `PrivacyExternalBoundaryGate`, writes through `AppGroupSnapshotStore`, and records local-only side-effect ledger status. | Existing `ExternalSurfaceSnapshotTests.testSnapshotWriterConsumesSanitizedProjectionsAndWritesSafeAppGroupRecord` covers sanitized projection consumption, no raw graph read, no private command summary/ID in payload JSON, safe app-group record, and local-only side-effect record. AMB-1724 adds `ExternalSurfaceSnapshotBoundaryTests.testExternalSnapshotProjectionPayloadUsesOnlyApprovedJSONFields` to lock the projection snapshot JSON to an approved key set and forbid raw projection/store/private fields. | No device app-group write proof. No widget extension process proof. No release-build proof. |
| App-group snapshot store | `projectionOnlyReader` storage boundary | `Native/Ambitions/Core/LocalRuntimeOS/Storage/AppGroupSnapshotStore.swift` rejects unsafe external snapshots, empty payloads, checksum mismatches, and unsafe reads. `Native/Ambitions/Projection/ExternalSnapshots/SharedExternalSnapshotStore.swift` exposes `SharedExternalSnapshotRecord.verifiedPayloadData()` for extension readers. | Existing tests cover safe written records. AMB-1724 adds `ExternalSurfaceSnapshotBoundaryTests.testSharedExternalSnapshotRecordRejectsPrivateOrCorruptRecordsBeforePayloadDecode`, proving private-class and checksum-corrupt shared records throw before payload decode. | No physical app-group container proof. No extension-process file protection proof. |
| Widget and Live Activity readers | `projectionOnlyReader` | `Native/AmbitionsWidgetExtension/NextStepWidget.swift` reads `SharedExternalSnapshotRecord.verifiedPayloadData()`, decodes `ExternalSurfaceSnapshot`, renders `ExternalWidgetProjection`, and uses deep links instead of direct mutation. `Native/AmbitionsWidgetExtension/NextStepLiveActivityWidget.swift` renders ActivityKit state from bounded snapshot content. | Existing `ExternalWidgetProjectionTests`, `ExternalSurfaceSnapshotTests`, and `ExternalSurfaceActionPayloadTests` cover privacy-safe widget projection, stale/unavailable fallback, Live Activity stale privacy suppression, bounded content windows, safe deep links, and redacted route payloads. | No widget or Live Activity screenshot/device proof. No Lock Screen privacy proof. No App Intent interactivity proof for widget buttons. |
| Privacy external boundary gate | `projectionOnlyReader` privacy gate | `Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/PrivacyExternalBoundaryGate.swift` denies external snapshots with unsafe records, empty payloads, missing checksums, private runtime data, private/sensitive privacy classes, unsafe widget rows, or widget/privacy redaction mismatches. | Existing `PrivacySecurityTests.testPrivacyExternalBoundaryGateEvaluatesExternalSnapshotsAndBridgeHandoffs` covers permitted sanitized snapshots, denied unsafe snapshots, and app-intent/share bridge evidence gating. | This is source/test boundary proof only. It is not privacy/legal approval or device proof. |
| Spotlight/Handoff external object reopening payloads | `projectionOnlyReader` | `Native/Ambitions/Projection/ExternalSnapshots/ExternalSurfaceActionPayloads.swift` and `ExternalObjectReopeningProjector.swift` build safe routes, continuation tokens, index records, and handoff records with redaction labels. | Existing `ExternalSurfaceActionPayloadTests` covers redacted sensitive Spotlight records, safe canonical root records, continuation token ID suppression where redaction requires fallback, and Handoff fallback for sensitive step reopening. | No OS Spotlight indexing or Handoff device proof. |
| Widget payload mutation bridge | `blockedUnknown` unchanged | AMB-1722 found current widget UI does not emit mutating controls, but app-level widget payload handling can execute commands if invoked. | AMB-1724 does not add command receipt/replay proof for mutating widget payloads. | Remains a parent residual gap. Do not claim interactive widget mutation Green. |

## Acceptance Verdict

AMB-1724 acceptance is satisfied at an Implemented Yellow ceiling:

- External snapshot writer and reader paths are classified as projection-only.
- Snapshot export reads `WidgetProjection` and `PrivacyProjection`, not raw
  goal/capture repositories.
- App-group snapshot records declare `containsPrivateRuntimeData: false` and
  are privacy-gated before write.
- Shared snapshot records fail closed before payload decode when private classes
  or checksum corruption are present.
- The external snapshot JSON payload is constrained to an approved field set in
  focused test source and excludes raw projection, storage, cursor, event, and
  private runtime fields.
- Widget/Live Activity projection tests cover stale/unavailable redaction and
  private-copy suppression in source-level XCTest.

No AMB-1724 route is promoted to Green.

## Proof And Non-Claims

Verified by this audit:

- Static source inspection found the external snapshot writer consumes
  projection-store `WidgetProjection` and `PrivacyProjection` records.
- Static source inspection found the widget extension reads through verified
  shared snapshot payload data before decoding.
- Static source inspection found privacy gate checks for private classes,
  private runtime data, checksum/payload safety, unsafe widget rows, and
  widget/privacy redaction mismatches.
- New test source locks external snapshot JSON to approved field names and
  rejects private/corrupt shared snapshot records before payload decode.

Not verified by this audit:

- Device widget rendering or interaction.
- Device Live Activity request/update/end behavior.
- Lock Screen privacy behavior.
- Physical app-group read/write behavior.
- Extension lifecycle or terminated-app behavior.
- Current Xcode test execution unless the closeout comment records a passing
  command.
- Accessibility, visual, performance, TestFlight, App Store, privacy/legal, R2,
  Source Atlas production, CloudKit, EventKit, Reminders, or release readiness.

## Closeout Boundary

- Final Architecture Tree inspected: yes, through
  `docs/truth/PRODUCT_DESIGN_TRUTH.md`.
- Canonical owners touched by AMB-1724: `Native/AmbitionsTests/App` and
  `docs/audits`.
- Swift production owners touched: none.
- Files moved or created in production Swift source: none.
- Old/noncanonical source paths removed: none.
- Compatibility shims left behind: none.
- Architecture debt remains: yes, in widget payload mutation receipt/replay
  proof, device widget/Live Activity proof, app-group device proof, extension
  lifecycle proof, and broader AMB-1668 residual adapter gaps.
- Next remediation train after AMB-1668 parent Yellow closeout: AMB-1680 Source Atlas Scope Freeze, unless Linear inserts a more specific AMB-1668 repair leaf.
- No equivalent folder/path interpretation was used.
- No widget, Live Activity, external snapshot, runtime authority, device,
  privacy/legal, release, or parent Green claim is made.
