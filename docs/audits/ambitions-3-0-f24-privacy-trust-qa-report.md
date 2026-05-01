# Ambitions 3.0 F24 Privacy / Trust / Local Data / Redaction QA Report

Date: 2026-05-01
Train: F17-F30 FAANG Handoff Completion Train
Batch: F24 Privacy / Trust / Local Data / Redaction QA
Gate: Green
F24.5 Trigger: Not triggered

## Result

F24 is Green.

Focused privacy, trust, local-data, and redaction tests passed across external
surface snapshots, widgets, Live Activity state, Today private projection,
Smart Attachment receipts, and You / What Ambitions Knows trust surfaces.

No F24.5 privacy threat model closure was triggered because the reviewed risks
are already covered by source/test evidence and no unresolved leakage or consent
ambiguity was found in this pass.

FAANG handoff remains PARTIAL until F27 explicitly passes.

## Source Truth

- `docs/canon/Ambitions_3_0_Privacy_Threat_Model.md`
- `docs/canon/Ambitions_3_0_Personalization_Consent_Model.md`
- `Native/AmbitionsTests/App/ExternalSurfaceSnapshotTests.swift`
- `Native/AmbitionsTests/App/ExternalWidgetProjectionTests.swift`
- `Native/AmbitionsTests/Profile/ProfileFeatureServiceTests.swift`
- `Native/AmbitionsTests/Today/TodayViewModelTests.swift`
- `Native/AmbitionsTests/Domain/SmartAttachmentModelsTests.swift`
- `Native/AmbitionsTests/Services/SmartAttachmentServiceTests.swift`

## Privacy / Trust Findings

Private projection:

- Today private/sensitive projection redacts titles and subtitles to `Private
  item` / `Details stay private on Today.`
- Step Detail private projection hides sensitive title and explanation detail.
- Smart Attachment redacted receipt projection uses `Private item` and
  redacted privacy state.

External surfaces:

- External snapshot tests verify user-entered sensitive titles and goal names
  do not appear in serialized JSON, widget display text, lock detail, Live
  Activity title/detail, privacy labels, or accessibility labels.
- Widget projection tests verify stale/missing snapshots surface safe fallback
  and privacy language instead of sensitive details.
- Live Activity state carries stale/privacy labels and does not start without a
  concrete step.

What Ambitions Knows / memory consent:

- You trust tests verify `What Ambitions Knows`, local evidence labels,
  freshness/use/source labels, sensitive-memory approval language, no hidden
  memory creation, and blocked destructive memory deletion.
- Tests verify memory footer copy avoids confidence/black-box/cloud-memory
  language.
- User deletion remains not overclaimed; broad delete/forget/pause controls are
  confirmation-gated.

Receipt / proof visibility:

- Smart Attachment and Today receipt/proof tests verify redacted receipt
  projection, local-device proof labels, and no automatic external mutation
  claim.

Local data boundaries:

- Profile tests verify local-only mode, no live sync claim, and preference
  saving stays on-device.
- Smart Attachment tests verify service behavior does not require network,
  account, calendar, or external candidates.

App Intents / widgets / shortcuts:

- External action and routing tests in the broader repo protect route payloads;
  F24 focused on redacted snapshot/widget/live-activity output.
- No new App Intent, widget, shortcut, notification, or lock-screen claim was
  introduced in F24.

## F24.5 Trigger Review

F24.5 triggers checked:

- external surface leakage risk: not triggered by focused tests;
- memory consent ambiguity: not triggered by You / What Ambitions Knows tests;
- lock-screen/widget exposure risk: not triggered by snapshot/widget/live
  activity privacy tests;
- receipt/proof visibility ambiguity: not triggered by receipt/proof tests;
- local data boundary ambiguity: not triggered by local-only/profile tests.

F24.5 is therefore not run.

## Validation

Focused privacy tests:

```text
xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions
  -destination 'platform=iOS Simulator,name=iPhone 17'
  -only-testing:AmbitionsTests/ExternalSurfaceSnapshotTests
  -only-testing:AmbitionsTests/ExternalWidgetProjectionTests
  -only-testing:AmbitionsTests/ProfileFeatureServiceTests
  -only-testing:AmbitionsTests/TodayViewModelTests
  -only-testing:AmbitionsTests/SmartAttachmentModelsTests
  -only-testing:AmbitionsTests/SmartAttachmentServiceTests
```

Result: PASS, `76` tests, `0` failures.
Log: `output/logs/f24-privacy-tests-20260501-152500.log`.

Build:

- `scripts/build-local.sh`: PASS.
- Log: `output/logs/build-local-20260501-152955.log`.

Not verified:

- full `scripts/test-local.sh`;
- full UI smoke;
- physical-device lock-screen behavior;
- real notification delivery on device;
- App Store privacy nutrition label/legal review.

## Gate Decision

Green.

F24 passed focused privacy/trust/redaction tests, local build passed, and no
unresolved F24.5 trigger was found.

F25 Device / Performance / State Restoration / Edge Case QA is unblocked next.
