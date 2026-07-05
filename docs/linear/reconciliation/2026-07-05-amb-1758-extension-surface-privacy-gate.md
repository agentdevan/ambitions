# AMB-1758 Extension Surface Privacy Gate

Status: Implemented Yellow / Ready For Review
Date: 2026-07-05T14:28:31Z
Baseline main SHA: `645c1ba26cb5fc23ebe7df51ecbc586fe2fbb5c6`
Project: Architecture Simplification + Flagship Readiness Remediation (`59c3917f-f662-4ca3-b412-b532613f3a7a`)
Issue: `AMB-1758` Extension Surface Privacy Gate

## Scope

This slice repairs the source/runtime privacy gate for widgets, App Group
external snapshots, App Intent/share/deep-link reopening metadata, and widget
placeholder routing.

It also repairs the repo XcodeBuildMCP preflight probe so local agents can prove
the configured `ambitions-ios` transport without hanging on a fragile stdout
reader.

This packet does not claim device proof, rendered widget proof, rendered
safe-failure UI proof, accessibility conformance, privacy/legal approval,
TestFlight readiness, App Store readiness, release Green, or total external
surface Green.

## Source Changes

- `Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/PrivacyExternalBoundaryGate.swift`
  - Repaired the external snapshot privacy projection check.
  - The privacy projection's `redactionRequiredEventIDs` must now be a subset
    of the widget projection's `redactedEventIDs`.
  - This blocks the unsafe case where privacy requires redaction but the widget
    projection omits the redacted event ID.
- `Native/Ambitions/Projection/ExternalSnapshots/ExternalSurfaceSnapshotWriter.swift`
  - Applied the same repaired subset direction before writing the App Group
    snapshot record.
  - A mismatch fails safely and records the external snapshot side-effect as
    `failed_safely` instead of writing an App Group payload.
- `Native/Ambitions/Projection/ExternalSnapshots/ExternalSurfaceActionPayloads.swift`
  - Replaced external root reopening titles with the actual top-level surface
    names: `Today`, `Goals`, `Time`, and `You`.
  - This avoids exposing internal/product-object names as external root
    reopening labels.
- `Native/AmbitionsWidgetExtension/NextStepWidget.swift`
  - Repaired the placeholder Capture action from `.tab` with tab `capture` to
    `.captureComposer` with no tab.
  - This keeps Capture as the global composer/action layer, not a root tab.
- Tests were updated to encode the expected source behavior:
  - External snapshot writer fails closed when a widget projection omits a
    privacy-required redaction ID.
  - Privacy external boundary gate denies widget/privacy projection mismatch.
  - External root records use `Today`, `Goals`, `Time`, and `You`.
  - Snapshot ambient Capture action is `.captureComposer`, not a tab.
- `scripts/ambitions-xcodebuildmcp-probe.py`
  - Repaired the local repo MCP probe to use a binary stdout/stderr reader with
    persistent buffers.
  - Supports the pinned `xcodebuildmcp@2.6.2` newline-delimited JSON transport
    and framed MCP output if a future transport changes.

## AMB-ISSUE-2009 Mapping

`docs/qa/KNOWN_ISSUES.md` still maps `AMB-ISSUE-2009` to Widgets / App Intents
/ Deep links with status `Runtime source-gate repaired / external-surface proof
pending`.

This slice strengthens the runtime source gate by fixing the redaction mismatch
direction and Capture route shape. It does not clear the remaining
`AMB-ISSUE-2009` proof ceiling for rendered safe-failure UI, stale-target
handling, parser safety, widget/App Intent runtime proof, or device proof.

## Evidence

Commands completed before the standing no-test authorization:

| Command | Result |
| --- | --- |
| `git diff --check` | Passed. |
| `python3 -m py_compile scripts/ambitions-xcodebuildmcp-probe.py` | Passed. |
| `python3 scripts/ambitions-remediation-governance-check.py` | Passed. `changed_paths=9`, `production_swift_files=1421`, `overHardLineCapFiles=0`, `broadModelsFiles=0`. |
| `python3 scripts/ambitions-quality-gate.py` | Passed. `changed_paths=9`; all strict quality gates passed. |
| `python3 scripts/ambitions-accepted-yellow-misuse-audit.py` | Passed. `checkedAcceptedYellowIssues=19`, `invalidAcceptedYellowIssues=0`. |
| `python3 scripts/ambitions-unsupported-claim-scan.py docs/linear/reconciliation/2026-07-05-amb-1758-extension-surface-privacy-gate.md scripts/ambitions-xcodebuildmcp-probe.py Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/PrivacyExternalBoundaryGate.swift Native/Ambitions/Projection/ExternalSnapshots/ExternalSurfaceSnapshotWriter.swift Native/Ambitions/Projection/ExternalSnapshots/ExternalSurfaceActionPayloads.swift Native/AmbitionsWidgetExtension/NextStepWidget.swift` | Passed. |
| `scripts/ambitions-xcodebuildmcp-probe.py --json --timeout 60` | Passed. `ok=true`; profile `ambitions-ios`; scheme `Ambitions`; simulator `iPhone 17 Pro Max`; UDID `0F5F5AC4-4303-47C8-9BDC-EB5F57A0F79E`. |
| `scripts/ambitions-xcode-sim-health.sh --json --timeout 60s` | Passed after direct CoreSimulator transport reset. Selected `iPhone 17 Pro Max` is booted; booted simulator count is `1`; Ambitions app PID count is `0`; Xcode blocker count is `0`. |

XcodeBuildMCP focused XCTest was started after the simulator repair, but the
client timed out while `xcodebuild build-for-testing` continued compiling. After
the user authorized full issue completion without testing, the active Xcode
build/test process tree was terminated and no further XCTest was run.

## Claim Boundary

Implemented Yellow for AMB-1758 source/runtime behavior:

- no new private graph egress path is introduced;
- App Group snapshot export now requires widget redaction coverage for every
  privacy-required event ID;
- mismatch fails closed before App Group write;
- external reopening root titles no longer use internal product-object names;
- Capture no longer appears as a widget placeholder tab action;
- local MCP/simulator preflight can prove the configured simulator/tooling path.

Not claimed:

- XCTest pass;
- rendered widget or Live Activity proof;
- rendered safe-failure UI proof;
- device proof;
- accessibility proof;
- privacy/legal approval;
- release readiness;
- final M14 Green;
- total system-surface Green.

## Architecture Closeout

- Final Architecture Tree inspected: yes.
- Canonical owners touched:
  - `Core/LocalRuntimeOS/PrivacySecurity`
  - `Projection/ExternalSnapshots`
  - Widget extension external snapshot presentation
  - test sources for the same scoped contracts
  - repo validation tooling
- Files moved or created:
  - created `docs/linear/reconciliation/2026-07-05-amb-1758-extension-surface-privacy-gate.md`
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- New `+02`, `+03`, or `+04` split files added: none.
- New broad `Models.swift` files added: none.
- New runtime, persistence, projection, receipt, replay, side-effect,
  migration, repair, privacy, sync, diagnostics, or Source Atlas authority
  outside `Core/LocalRuntimeOS/`: none.
- Yellow architecture/proof debt remains: yes. Rendered/device/executable test
  proof remains deferred under the user-authorized no-test policy.
- Next repair train if debt remains: close the remaining M14 `Needs Repair`
  leaves and later run executable/widget/device proof when testing is re-enabled.
- Confirmation: no equivalent-folder or alternate-path interpretation was used.

## Rollback

Revert this packet and the source/test/tooling changes from the same commit.
Move `AMB-1758` back to `Needs Repair` if the redaction coverage invariant or
Capture composer routing behavior is not preserved.
