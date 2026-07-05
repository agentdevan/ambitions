# AMB-1822 Device Proof Matrix And Simulator Ceiling

Status: Implemented Yellow / Ready For Review for this device-proof matrix packet; no device proof performed
Date: 2026-07-05T16:21:40Z
Branch: `main`
Baseline main SHA: `fce7cb8407db269d6561b8a795241f091e50fbbb`
Commit SHA: artifact commit SHA is recorded in Linear after commit/push
Environment: local Codex macOS workspace at `/Users/devan/Documents/GitHub/ambitions`
Xcode version: Xcode 26.6, build version 17F113
Simulator or device: no physical device was connected or used; simulator tooling proof exists from the current XcodeBuildMCP/simulator preflight repair packet but is not device proof
Exit code(s): listed in Validation Run below
Artifact paths: this manifest and `docs/qa/evidence/2026-07-05-amb-1822-device-proof-matrix-simulator-ceiling/device-proof-matrix.json`
Parent: `AMB-1701` Parent Feature - Device Proof Matrix
Issue: `AMB-1822` Device Proof Leaf - Device matrix and simulator ceiling

## Scope

This packet defines the physical-device proof matrix and evidence capture format
for Ambitions release-sensitive behavior. It also states the simulator/source
proof ceiling: simulator runs, source scans, docs, and old screenshot indexes
may support triage and Yellow review, but they cannot close physical-device
readiness, Visual Green, Release Green, or device-sensitive system-surface
claims.

This is docs/control-plane and QA evidence scaffolding only. It does not change
Swift source, XcodeGen project source, Package.swift, runtime behavior,
rendered UI, privacy behavior, account behavior, R2 behavior, device behavior,
archive/export behavior, upload behavior, or release behavior.

## Device Matrix

The minimum future device proof matrix is:

| Slot | Required device class | Required OS coverage | Required proof posture |
| --- | --- | --- | --- |
| `D1-small` | Small supported iPhone class | Latest supported iOS for that device | Required for viewport density, Dynamic Type pressure, keyboard/safe-area behavior, and object dominance under constrained dimensions. |
| `D2-mainstream` | Mainstream iPhone class | Latest supported iOS | Required for default daily-use behavior, notifications, App Intents, widgets, App Group snapshots, and share/deep-link routes. |
| `D3-pro` | Pro iPhone class | Latest supported iOS | Required for flagship visual review, performance-sensitive flows, camera/mic/biometric/peripheral prompts if in scope, and release screenshots when claimed. |
| `D4-previous-os` | Any supported iPhone class capable of the previous supported iOS, if the app supports that OS | Previous supported iOS | Required when deployment target includes a previous OS. If not available, release packet must record the unsupported gap and owner acceptance. |

If a future release uses a narrower supported-device policy, the release packet
must state that policy, link the product/release approval, and update this
matrix before any device-readiness claim.

## Device-Sensitive Checks

These checks require physical-device evidence before Green or readiness claims:

| Check | Why simulator/source proof is insufficient | Required evidence |
| --- | --- | --- |
| Face ID / passcode / LocalAuthentication | Simulator can mock flows but cannot prove real secure-enclave, passcode, lock-state, or user-consent behavior. | Device model, iOS version, build SHA, procedure, pass/fail, screenshot/video where safe, and limitations. |
| Locked-device widgets and Live Activities | Lock-screen render, privacy redaction, timeline refresh, and stale state are device/lifecycle sensitive. | Locked/unlocked before/after evidence, widget/Live Activity state, redaction result, and attachment references. |
| App Group sharing | Simulator can inspect files, but release-sensitive cross-process, protection-class, and extension lifecycle behavior needs device proof. | App/extension version, shared container evidence, redaction result, and no-private-graph assertion. |
| Share Extension | Extension invocation, memory pressure, cancellation, and handoff differ on device. | Source app, payload type, before/action/after, result receipt, cancellation behavior, and failure behavior. |
| App Intents / Shortcuts / Siri surfaces | Invocation context, permissions, locked-state behavior, and handoff can differ from simulator. | Invocation source, parameters, runtime command/projection route, result, receipt, and privacy boundary. |
| BackgroundTasks | Scheduling, expiration, power/network state, and launch policy are device-controlled. | Registration, trigger method, observed run/expiration, logs, and user-visible result. |
| File protection and locked-state storage | Simulator does not prove hardware-backed file protection under lock. | Protection class, locked-state procedure, access result, error handling, and recovery. |
| Notifications | Delivery timing, permission prompts, notification actions, Focus/lock behavior, and action routing need device proof. | Permission state, sent payload, delivered result, action handling, receipt, and privacy redaction. |
| EventKit / Reminders permissions | Real permission prompts, account state, write failures, and user-denied paths vary by device/account. | Permission state, write attempt, outbox/receipt, cancel/retry behavior, and cleanup. |
| Offline/no-account release behavior | Simulator can support local tests, but release claim needs device install and no-network/no-account walkthrough. | Network state, account state, flow steps, local data proof, and unsupported limits. |
| Accessibility on device | Simulator accessibility can support triage, but release/Visual Green requires device-context proof where claimed. | VoiceOver, Dynamic Type, Reduce Motion, Reduce Transparency, Increase Contrast, accessible actions, and screen evidence. |
| Performance and launch behavior | Simulator performance does not represent device thermal, memory, launch, or scroll behavior. | Device model, OS, build SHA, measurement tool/procedure, threshold, result, and artifacts. |

## Evidence Capture Format

Every future device proof row must include:

- `device_proof_id`
- `issue_or_gate`
- `device_slot`
- `device_model`
- `device_identifier_redacted`
- `iOS_version`
- `build_commit_sha`
- `branch`
- `build_source`
- `bundle_id`
- `install_method`
- `date_time`
- `operator`
- `procedure`
- `preconditions`
- `steps`
- `expected_result`
- `actual_result`
- `artifacts`
- `logs`
- `privacy_notes`
- `accessibility_notes`
- `known_limitations`
- `pass_fail`
- `owner_approval`

Do not store private user data, personal calendar/reminder data, account
tokens, device UDIDs, phone numbers, email addresses, payment identifiers, or
private life graph content in device proof packets.

## Simulator Ceiling

Simulator proof may support:

- local build and test triage;
- source/runtime unit test evidence;
- interaction smoke checks;
- screenshot framing triage;
- initial accessibility review;
- XcodeBuildMCP and simulator tooling health.

Simulator proof may not claim:

- physical-device readiness;
- locked-device widget or notification Green;
- real Face ID/passcode behavior;
- real file-protection behavior;
- extension lifecycle Green;
- background task reliability;
- real EventKit/Reminders account permission behavior;
- device performance readiness;
- Visual Green;
- Release Green;
- TestFlight readiness;
- App Store readiness.

## Links To Release Gate

This packet is an input to:

- `AMB-1701` Device Proof Matrix
- `AMB-1821` RC checklist non-claim packet
- `AMB-1700` Release Candidate Gate
- `AMB-1705` final architecture closeout gate

No release packet may treat simulator/source-only proof as satisfying the
device rows above.

## Validation Run

Completed for this device-proof matrix packet:

| Command | Exit code | Result |
| --- | ---: | --- |
| `git diff --check` | 0 | Passed after packet creation. |
| `python3 -m json.tool docs/qa/evidence/2026-07-05-amb-1822-device-proof-matrix-simulator-ceiling/device-proof-matrix.json` | 0 | Passed after packet creation. |
| `python3 scripts/ambitions-release-non-claim-gate.py docs/qa/evidence/2026-07-05-amb-1822-device-proof-matrix-simulator-ceiling/manifest.md docs/qa/evidence/2026-07-05-amb-1822-device-proof-matrix-simulator-ceiling/device-proof-matrix.json` | 0 | Passed after packet creation; `release_facing_packets_checked=2`. |
| `python3 scripts/ambitions-accepted-yellow-misuse-audit.py` | 0 | Passed after packet creation; `checkedAcceptedYellowIssues=19`, `invalidAcceptedYellowIssues=0`. |
| `python3 scripts/ambitions-unsupported-claim-scan.py docs/qa/evidence/2026-07-05-amb-1822-device-proof-matrix-simulator-ceiling/manifest.md docs/qa/evidence/2026-07-05-amb-1822-device-proof-matrix-simulator-ceiling/device-proof-matrix.json` | 0 | Passed after packet creation. |
| `python3 scripts/ambitions-remediation-governance-check.py` | 0 | Passed after packet creation; `changed_paths=2`, `production_swift_files=1421`, `overHardLineCapFiles=0`. |

## Validation Not Run

- No physical-device procedure, app install, app launch, locked-device flow,
  widget/Live Activity run, Share Extension run, App Intent run, BackgroundTask
  run, notification delivery/action, EventKit/Reminders permission/write,
  file-protection check, accessibility walkthrough, performance profiling,
  xcodebuild build/test, archive, App Store validation, TestFlight upload, or
  release approval was run for AMB-1822 under the current user instruction
  authorizing issue completion without testing until advised otherwise.

## Non-Claims

- No physical-device proof.
- No Visual Green.
- No Release Green.
- No device readiness, TestFlight readiness, App Store readiness, accessibility
  conformance, performance readiness, privacy/legal approval, system-surface
  Green, build success, test success, archive success, upload readiness, or
  product completion.
- This packet defines the matrix and simulator ceiling only. It does not satisfy
  any physical-device row.
- `AMB-1701` remains In Progress until device evidence is captured or explicitly
  owner-accepted as a release blocker.
- `AMB-1705` remains Needs Repair.

## Proof-Claim Labels Used

- Device-proof claim: not verified; no physical-device procedure was run.
- Release-proof claim: not verified; no release procedure was run.
- Accessibility-proof claim: not verified; no accessibility walkthrough was run.
- Performance-proof claim: not verified; no performance profiling was run.
- Privacy-proof claim: not verified; no privacy/legal approval or device privacy
  procedure was run.

## Architecture Closeout

- Final Architecture Tree inspected: yes.
- Canonical owners touched: none in Swift source; QA evidence only.
- Files moved or created: this manifest and a paired JSON matrix.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Yellow architecture/proof debt remains: yes. Device proof is not performed.
- Next repair train if debt remains: run real device proof rows under `AMB-1701`
  or retain them as explicit release blockers in `AMB-1700`.
- Confirmation: no equivalent-folder or alternate-path interpretation was used.

## Rollback

Revert this evidence folder. Move `AMB-1822` back to `Ready For Codex` or
`Needs Repair` if the matrix no longer blocks unsupported simulator/source-only
device claims.
