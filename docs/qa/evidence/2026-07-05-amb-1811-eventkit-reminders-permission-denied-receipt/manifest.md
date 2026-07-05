# AMB-1811 EventKit Reminders Permission-Denied Receipt Path

Status: Implemented Yellow / Ready For Review for this permission-denied receipt leaf
Date: 2026-07-05T19:37:34Z
Branch: `main`
Baseline main SHA: `8bff3c6f53adb4c581520c515459ec29fa4bb58b`
Commit SHA: artifact commit SHA is recorded in Linear after commit/push
Environment: local Codex macOS workspace at `/Users/devan/Documents/GitHub/ambitions`
Xcode version: Xcode 26.6, build version 17F113
Simulator or device: no simulator app run, EventKit permission prompt, Reminders app write, or physical-device procedure was run
Exit code(s): listed in Validation Run below
Artifact paths: this manifest and `docs/qa/evidence/2026-07-05-amb-1811-eventkit-reminders-permission-denied-receipt/permission-denied-receipt-path.json`
Parent: `AMB-1690` Parent Feature - EventKit / Reminders Outbox
Issue: `AMB-1811` EventKit Reminders Leaf - Permission-denied receipt path

## Scope

This packet proves the current source path for a Reminders permission-denied
write request:

- the write is blocked before `EventKitStoreClient.saveReminder`;
- the denial is recorded through `EventKitOutbox.recordCalendarResult`;
- the durable `SideEffectLedgerRecord` remains local/inspection-safe with
  `status == failed_safely`, `externalEffect == false`, and local-only receipt
  metadata;
- no direct external mutation authority is added or promoted.

This leaf does not change production runtime behavior because the permission
denied receipt path already exists in the canonical EventKit outbox route.

## Source-Backed Path

| Step | Source evidence | AMB-1811 result |
| --- | --- | --- |
| Permission denied | `Native/Ambitions/Core/Permissions/CalendarReminders/EventKitIntegrationService+02-EventKitIntegrationService.swift` checks `requestAuthorizationIfNeeded(for: .reminders)` and enters the denied branch before payload creation or save. | No EventKit reminder save is attempted. |
| Local receipt attempt | The denied branch calls `recordCalendarSideEffect` with `status: .blocked`, `boundary: .externalEffect`, `requiresConfirmation: true`, and `externalEffect: false`. | The attempted write is local-only evidence, not an external write. |
| Result receipt | The denied branch calls `recordCalendarResult(SideEffectAttemptResult(state: .permissionDenied, ...))`. | `SideEffectOutbox.recordResult` maps permission denied to `failed_safely` and stores the receipt-linked ledger row. |
| Inspection-safe ledger | `Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/SideEffectOutbox.swift` writes `SideEffectReceipt` and an updated `SideEffectLedgerRecord`; `SideEffectLedgerModels.swift` normalizes local-only, blocked, degraded, and receipt fields. | Trust/inspection layers can read the local side-effect ledger without needing EventKit or private external data. |
| Direct mutation guard | `Native/AmbitionsTests/App/EventKitIntegrationServiceTests.swift` now asserts the denied reminder path records the receipt and leaves the reminder save count at zero. | Permission-denied Reminders writes do not cross the EventKit save boundary in the focused path. |

## Current Test Coverage Added Or Tightened

- `Native/AmbitionsTests/App/EventKitIntegrationTestDoubles.swift` now counts
  reminder save attempts.
- `Native/AmbitionsTests/App/EventKitIntegrationServiceTests.swift`
  `testCreateReminderFailsWhenAuthorizationDenied` now asserts:
  - `currentSaveReminderCount() == 0`;
  - `lastReminderPayload == nil`;
  - the side-effect ledger result remains `.failedSafely`;
  - the row has `externalEffect == false` and `localOnly == true`;
  - the denied degraded fact is preserved.

## Validation Run

Completed for this packet:

| Command | Exit code | Result |
| --- | ---: | --- |
| `xcodebuild -version` | 0 | Confirmed Xcode 26.6, build version 17F113. |
| `python3 -m json.tool docs/qa/evidence/2026-07-05-amb-1811-eventkit-reminders-permission-denied-receipt/permission-denied-receipt-path.json` | 0 | JSON evidence parsed. |
| `git diff --check` | 0 | Passed after packet/test edits. |
| `python3 scripts/ambitions-unsupported-claim-scan.py Native/AmbitionsTests/App/EventKitIntegrationServiceTests.swift Native/AmbitionsTests/App/EventKitIntegrationTestDoubles.swift docs/qa/evidence/2026-07-05-amb-1811-eventkit-reminders-permission-denied-receipt/manifest.md docs/qa/evidence/2026-07-05-amb-1811-eventkit-reminders-permission-denied-receipt/permission-denied-receipt-path.json` | 0 | Unsupported completion/readiness claim scan passed. |
| `swiftc -parse Native/AmbitionsTests/App/EventKitIntegrationServiceTests.swift Native/AmbitionsTests/App/EventKitIntegrationTestDoubles.swift` | 0 | Swift parser accepted the focused test/test-double edits; no XCTest execution. |
| `python3 scripts/ambitions-remediation-governance-check.py` | 0 | Passed; `changed_paths=4`, `production_swift_files=1423`, `overHardLineCapFiles=0`. |
| `python3 scripts/ambitions-quality-gate.py` | 0 | Passed; strict quality gates Green. |
| `xcodegen generate` | 0 | Project regenerated; no project source truth change was introduced. |
| `python3 scripts/ambitions-green-standard-audit.py` | 0 | Passed; no disallowed architecture-as-UI strings found in active primary UI source. |
| `python3 scripts/ambitions-vocabulary-drift-scan.py` | 0 | Passed; canonical active vocabulary present and ban terms absent. |
| `python3 scripts/ambitions-local-first-boundary-scan.py` | 0 | Passed; local-first/account/R2/hosted-AI boundary checks passed in active authority files. |
| `python3 scripts/ambitions-architecture-inventory.py` | 0 | Passed; final-tree parity achieved. |
| `scripts/ambitions-xcode-sim-health.sh --json --timeout 20s` | 25 | Initial simulator preflight failed because active Xcode processes were blocking the check. |
| `scripts/ambitions-xcode-sim-health.sh --json --timeout 20s --repair --kill-active-xcode` | 0 | Repaired by killing active Xcode processes; selected `iPhone 17 Pro Max` simulator `DD9B9C84-7188-48FA-AA2A-AB5C1D0EE2B6` passed. |

## Validation Not Run

- Focused ExternalWrites/EventKit tests, LocalRuntimeProof, xcodebuild package
  resolution, xcodebuild build, xcodebuild test, build-for-testing, UI tests,
  simulator app launch, EventKit permission prompt, Reminders app write,
  physical-device procedure, privacy/legal review, release gate, and App Store
  validation were not run for AMB-1811 under the current user instruction
  authorizing issue completion without testing until advised otherwise.

## Non-Claims

- No device EventKit or Reminders proof.
- No real permission prompt proof.
- No real Reminders app write proof.
- No retry/cancellation proof.
- No calendar/reminders production readiness.
- No privacy/legal, TestFlight, App Store, Release Green, or product-completion
  claim.
- `AMB-1690` remains In Progress because retry/cancellation, local inspection UI,
  device behavior, and broader parent acceptance remain outside this leaf.

## Architecture Closeout

- Final Architecture Tree inspected: yes.
- Canonical owners touched: `Core/LocalRuntimeOS/ExternalWrites`,
  `Core/Permissions/CalendarReminders`, `Native/AmbitionsTests`, and QA
  evidence.
- Files moved or created: this manifest and a paired JSON evidence file.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Yellow architecture/proof debt remains: yes. The focused source path is
  source/test covered, but device EventKit/Reminders behavior and parent
  retry/cancellation/inspection UI proof remain open.
- Next repair train if debt remains: continue `AMB-1690` leaves for
  retry/cancellation, local inspection UI, and device/system-surface proof.
- Confirmation: no equivalent-folder or alternate-path interpretation was used.

## Rollback

Revert this evidence folder and the focused test/test-double assertions. Move
`AMB-1811` back to `Ready For Codex` or `Needs Repair` if the denied Reminders
path no longer records a local failed-safe receipt before EventKit save.
