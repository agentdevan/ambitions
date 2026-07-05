# AMB-1794 Validation Command Matrix

Status: Implemented Yellow / Ready For Review for this control-plane leaf
Date: 2026-07-05T15:43:05Z
Branch: `main`
Baseline main SHA: `bf71b2592fc4e6e50709cc7cec1f0ba30466a7ec`
Commit SHA: artifact commit SHA is recorded in Linear after commit/push
Environment: local Codex macOS workspace at `/Users/devan/Documents/GitHub/ambitions`
macOS version: 26.5.1, build 25F80
Xcode version: Xcode 26.6, build version 17F113
Simulator or device: simulator preflight passed for `iPhone 17 Pro Max` / `0F5F5AC4-4303-47C8-9BDC-EB5F57A0F79E`; no app build, app launch, XCTest, or device procedure is claimed for this packet
Exit code(s): listed in Validation Run below
Artifact paths: this packet and `docs/linear/reconciliation/2026-07-05-amb-1794-validation-command-matrix.json`
Project: Ambitions Linear Workflow Control Plane (`5f760f13-affc-4a9d-ac04-36af0b2c17a8`)
Issue: `AMB-1794` Validation Command Matrix

## Scope

This packet creates the canonical validation command matrix for governance and
remediation closeouts. Every future closeout that uses this matrix must classify
the touched scope, list the commands required by that scope, and record each
command as:

- `run` with command, exit code, result, and artifact/log path when applicable
- `not_run` with the current reason and proof ceiling
- `not_applicable` with the scope reason

The matrix is a control-plane artifact. It does not change Swift source,
XcodeGen project source, Package.swift, runtime behavior, rendered UI, privacy
behavior, account behavior, R2 behavior, device behavior, or release behavior.

## Live Inputs Inspected

- `AGENTS.md`
- `docs/truth/README.md`
- `docs/truth/CODEX_START_HERE.md`
- `docs/truth/PRIVATE_LIFE_ORCHESTRATION_TRUTH.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_ACCEPTANCE_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `.agents/skills/ambitions-source-truth-authority/SKILL.md`
- `.agents/skills/ambitions-architecture-tree-enforcement/SKILL.md`
- `.agents/skills/ambitions-ios-quality-gate/SKILL.md`
- `.agents/skills/ambitions-release-proof-honesty/SKILL.md`
- Live Linear state for `AMB-1794`

## Command Matrix

### 1. Docs, Governance, and Linear Control Plane

Use when changed files are docs/control-plane artifacts, issue packets,
reconciliation ledgers, tracker comments, or truth-adjacent governance material.

Required commands:

```bash
git diff --check
python3 -m json.tool <changed-json-file>
python3 scripts/ambitions-unsupported-claim-scan.py <changed-files>
python3 scripts/ambitions-release-non-claim-gate.py
python3 scripts/ambitions-accepted-yellow-misuse-audit.py
python3 scripts/ambitions-remediation-governance-check.py
```

Conditional commands:

```bash
python3 scripts/ambitions-architecture-path-normalization-check.py
python3 scripts/product-experience-gate-index-check.py
```

Condition notes:

- Run the architecture path normalization check when the packet discusses
  architecture owners, Final Architecture Tree paths, or architecture closeout.
- Run the product-experience gate index check when product-experience scenario
  gates or gate YAML are touched.
- If the packet is release-facing, the release non-claim gate is required.

Claim ceiling:

- A docs/control-plane packet may be Green for the exact docs/governance claim
  only when required static checks pass and no unsupported claim is present.
- It cannot claim build success, test success, device proof, accessibility
  proof, privacy/legal approval, Visual Green, Release Green, TestFlight
  readiness, App Store readiness, account readiness, R2 readiness, or product
  completion.

### 2. Architecture Remediation and Cleanup

Use when changed files affect architecture ownership, final-tree reconciliation,
deletion/quarantine, old owner removal, suffix/file-size discipline, or
remediation closeout.

Required commands:

```bash
python3 scripts/ambitions-remediation-governance-check.py
python3 scripts/ambitions-accepted-yellow-misuse-audit.py
python3 scripts/ambitions-architecture-path-normalization-check.py
python3 scripts/ambitions-architecture-inventory.py
python3 scripts/ambitions-unsupported-claim-scan.py <changed-files>
git diff --check
```

Conditional commands:

```bash
xcodegen generate
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -resolvePackageDependencies
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "<simulator>" build CODE_SIGNING_ALLOWED=NO
./scripts/build-local.sh
```

Condition notes:

- If production Swift, `project.yml`, package configuration, source ownership,
  or compile-sensitive imports are touched, build proof is required for Source
  Green.
- If current instruction prevents build/test execution, record each build/test
  command as `not_run` and cap the implementation claim at Yellow or Ready For
  Review unless another current proof artifact covers the exact claim.

Claim ceiling:

- Architecture inventory and remediation governance output are source parity
  and drift evidence only.
- They do not prove app-wide runtime behavior, rendered product quality,
  accessibility, privacy/legal approval, device readiness, release readiness, or
  final architecture Green unless the exact required source/build/test/review
  evidence is also current.

### 3. Production Swift Source

Use when changed files include production Swift, Swift package configuration,
XcodeGen project source, entitlements, Info.plist, app resources used by source,
or scripts that directly affect build/test execution.

Required commands:

```bash
xcodegen generate
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -resolvePackageDependencies
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "<simulator>" build CODE_SIGNING_ALLOWED=NO
./scripts/ambitions-xcode-sim-health.sh --json --timeout 30s
python3 scripts/ambitions-remediation-governance-check.py
git diff --check
```

Focused proof commands:

```bash
./scripts/ambitions-xcode-build-for-testing.sh --batch <BATCH>
./scripts/ambitions-xcode-test-focused.sh --batch <BATCH> --test <TEST_ID>
./scripts/ambitions-xcode-validate.sh --batch <BATCH> --lane build-for-testing
```

Claim ceiling:

- Source Green requires current compile/build evidence and focused proof
  appropriate to the touched source.
- If XCTest, build-for-testing, or focused tests are not run, state the not-run
  reason and do not claim test pass, build-for-testing pass, device proof,
  Interaction Green, Visual Green, Release Green, or final product completion.

### 4. LocalRuntimeOS, Mutation, Storage, Projection, Receipt, Replay

Use when changed files affect runtime mutations, command routing, persistence,
event journal, projections, storage, external writes, privacy boundary,
continuity, Source Atlas runtime, repair, diagnostics, search, inspection,
proof ledger, receipts, undo, replay, or LocalRuntimeOS closeout.

Required commands:

```bash
python3 scripts/ambitions-local-runtime-proof.py --json
python3 scripts/ambitions-runtime-direct-write-audit.py --json
python3 scripts/ambitions-legacy-runtime-production-use-guard.py --json
python3 scripts/ambitions-remediation-governance-check.py
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "<simulator>" build CODE_SIGNING_ALLOWED=NO
./scripts/ambitions-xcode-test-focused.sh --batch <BATCH> --test <RUNTIME_TEST_ID>
git diff --check
```

Claim ceiling:

- LocalRuntimeOS proof is source/runtime-gate proof only.
- No LocalRuntimeOS completion, M02 Green, all-mutation enforcement, external
  system-surface Green, privacy/legal approval, device readiness, or Release
  Green may be claimed without current focused runtime tests and the exact
  supporting evidence for that claim.
- If executable runtime tests are not run, required source/runtime remediation
  cannot close Green.

### 5. SwiftUI, Rendered UI, Accessibility, Motion, Widgets, Live Activities

Use when changed files affect SwiftUI, UIKit interop, design system, shell,
safe areas, keyboard behavior, accessibility, visual quality, widgets, Live
Activities, App Intents, notifications, or rendered product behavior.

Required commands and procedures:

```bash
./scripts/ambitions-xcode-sim-health.sh --json --timeout 30s
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "<simulator>" build CODE_SIGNING_ALLOWED=NO
./scripts/ambitions-xcode-test-focused.sh --batch <BATCH> --test <UI_OR_ACCESSIBILITY_TEST_ID>
```

Required manual or artifact proof:

- screenshot or explicit not-run reason
- VoiceOver proof notes or explicit not-run reason
- Dynamic Type proof notes or explicit not-run reason
- Reduce Motion proof notes or explicit not-run reason
- Reduce Transparency or contrast proof notes when relevant, or explicit
  not-run reason
- safe-area and keyboard proof notes when relevant, or explicit not-run reason

Claim ceiling:

- Codex may prepare Source Green, Interaction Green, or Ready for Visual Review
  when current evidence supports those exact claims.
- Codex may not self-certify Visual Green or Release Green.
- Screenshot paths, source strings, or audit rows are not visual proof by
  themselves.

### 6. External System Surfaces and Side Effects

Use when changed files affect notifications, EventKit, Reminders, App Intents,
widgets, share extensions, Live Activities, external write adapters, outbox
behavior, permissions, or system lifecycle behavior.

Required commands and procedures:

```bash
python3 scripts/ambitions-local-runtime-proof.py --json
python3 scripts/ambitions-runtime-direct-write-audit.py --json
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "<simulator>" build CODE_SIGNING_ALLOWED=NO
./scripts/ambitions-xcode-test-focused.sh --batch <BATCH> --test <SYSTEM_SURFACE_TEST_ID>
```

Required additional proof:

- permission prompt behavior when relevant
- denied/cancelled permission path when relevant
- terminated-app or extension lifecycle proof when claimed
- local commit before external attempt proof when claimed
- receipt/outbox/result recording proof when claimed

Claim ceiling:

- Local source or adapter proof does not prove physical-device lifecycle,
  permission behavior, widget, Live Activity, notification, App Intent,
  EventKit, Reminders, share extension, or release readiness unless that exact
  procedure is current and linked.

### 7. Account, R2, Source Atlas, Privacy, Network, Logs

Use when changed files affect Ambitions Account, Sign in with Apple, Google
Sign-In, entitlement, R2, Source Atlas, network requests, caches, manifests,
logs, redaction, privacy boundaries, local-first behavior, or no-account
offline claims.

Required commands:

```bash
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/ambitions-unsupported-claim-scan.py <changed-files>
python3 scripts/ambitions-release-non-claim-gate.py
python3 scripts/ambitions-remediation-governance-check.py
git diff --check
```

Conditional proof:

- account/auth flow test evidence when account behavior is claimed
- R2 request-shape review proving no private user context is sent
- public-pack manifest/hash verification evidence when pack verification is
  claimed
- offline fallback proof when offline behavior is claimed
- privacy manifest review and legal/privacy owner approval when release-facing

Claim ceiling:

- Product truth requires account and R2/public reference posture, but product
  truth is not release proof.
- No account readiness, R2 readiness, privacy/legal approval, production
  Source Atlas readiness, offline no-account validation, TestFlight readiness,
  App Store readiness, or Release Green may be claimed without current proof.

### 8. Release Candidate, TestFlight, App Store, Device Readiness

Use when a packet or issue claims release candidate status, device readiness,
TestFlight readiness, App Store readiness, archive/export/upload readiness,
public accessibility conformance, performance readiness, privacy/legal
approval, or Release Green.

Required commands and procedures:

```bash
xcodegen generate
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -resolvePackageDependencies
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "<simulator>" build CODE_SIGNING_ALLOWED=NO
./scripts/build-local.sh
python3 scripts/ambitions-release-non-claim-gate.py
```

Required release artifacts:

- branch and commit SHA
- date/time and environment
- Xcode and simulator/device details
- exact command or manual procedure
- exit code and result
- `.xcresult`, log, archive, export, upload, screenshot, recording, checklist,
  approval, or other artifact path when applicable
- skipped checks and unsupported claims
- rollback plan
- owner approval where required

Claim ceiling:

- Codex may not self-certify Release Green.
- Release Green requires current Source Green, Runtime Green, Interaction
  Green, Visual Green from independent review, current device proof,
  accessibility proof, rollback proof, umbrella closeout evidence, and required
  approvals.

### 9. Tracker Mutation and Closeout

Use before moving a Linear issue, creating a closeout comment, updating a
project status, or claiming a blocker is resolved.

Required procedure:

- fetch live Linear state for the issue immediately before mutation
- inspect current repo status and current diff
- link current artifact paths and commit SHA
- list validation run and validation not run
- list claims supported and claims not supported
- move to `Ready For Review` only when the issue's scoped artifact or
  implementation exists and the proof ceiling is explicit
- do not move a parent to Green/Done while required blockers or proof gaps
  remain

Claim ceiling:

- Linear status is tracker state. It is not source, runtime, device,
  accessibility, privacy/legal, release, or product-completion proof.

## Current User Instruction Handling

The current user instruction authorizes issue completion without testing until
advised otherwise. Under this matrix, that instruction may be recorded as the
not-run reason for XCTest, xcodebuild test, build-for-testing, focused test, UI
test, manual device, or release procedures when a scoped issue can still produce
honest docs/control-plane value.

That instruction does not create test proof. It does not permit unsupported
claims. If a required source/runtime/release acceptance depends on executable
tests, build evidence, device evidence, owner review, or approval, the closeout
must record the missing proof and the resulting Yellow, Ready For Review, Red,
Blocked, or narrower status ceiling.

## Closeout Contract

Every closeout using this matrix must include:

- touched scope category
- baseline SHA and final SHA
- files changed
- validation run with exact commands, exit codes, and result
- validation not run with reason
- proof artifacts
- supported claims
- unsupported claims
- known risks
- next follow-up for every Yellow/Red gap
- rollback plan

Source trains must also include Final Architecture Tree inspected, canonical
owners touched, non-canonical owners touched, files moved or created,
old/non-canonical paths removed, compatibility shims left behind, architecture
debt, next repair train if debt remains, and confirmation that no equivalent
folder/path interpretation was used.

## Non-Claims

- This matrix does not prove that any listed command passes.
- This matrix does not prove build success, test success, build-for-testing
  success, focused test success, simulator runtime success, physical-device
  success, visual quality, accessibility conformance, privacy/legal approval,
  account readiness, R2 readiness, CI proof, TestFlight readiness, App Store
  readiness, Release Green, or final architecture Green.
- This matrix does not close `AMB-1705`; it provides the validation-command
  owner needed before remaining blockers can be honestly reconciled.

## Validation Run

Completed for this docs/control-plane packet:

| Command | Exit code | Result |
| --- | ---: | --- |
| `./scripts/ambitions-xcode-sim-health.sh --json --timeout 30s` | 0 | Passed before packet creation; configured simulator is booted and no active Ambitions app process or Xcode blocker was reported. |
| `./scripts/ambitions-xcode-sim-health.sh --json --timeout 30s` | 0 | Passed after packet creation; `status=passed`, simulator `iPhone 17 Pro Max`, UDID `0F5F5AC4-4303-47C8-9BDC-EB5F57A0F79E`, `booted_simulator_count=1`, `ambitions_app_pid_count=0`, `xcode_process_count=0`. |
| `xcodebuild -version` | 0 | Reported Xcode 26.6, build version 17F113. |
| `sw_vers` | 0 | Reported macOS 26.5.1, build 25F80. |
| `git diff --check` | 0 | Passed after packet creation. |
| `python3 -m json.tool docs/linear/reconciliation/2026-07-05-amb-1794-validation-command-matrix.json` | 0 | Passed after packet creation. |
| `python3 scripts/ambitions-release-non-claim-gate.py` | 0 | Passed after adding exact release metadata labels to the JSON packet; `release_facing_packets_checked=2`. |
| `python3 scripts/ambitions-accepted-yellow-misuse-audit.py` | 0 | Passed after packet creation; `checkedAcceptedYellowIssues=19`, `invalidAcceptedYellowIssues=0`. |
| `python3 scripts/ambitions-architecture-path-normalization-check.py` | 0 | Passed after packet creation; `architecture_packets_checked=15`. |
| `python3 scripts/ambitions-unsupported-claim-scan.py docs/linear/reconciliation/2026-07-05-amb-1794-validation-command-matrix.md docs/linear/reconciliation/2026-07-05-amb-1794-validation-command-matrix.json` | 0 | Passed after packet creation. |
| `python3 scripts/ambitions-remediation-governance-check.py` | 0 | Passed after packet creation; `changed_paths=2`, `production_swift_files=1421`, `overHardLineCapFiles=0`. |

## Validation Not Run

- XCTest, xcodebuild build, build-for-testing, focused test, UI test, app
  launch, manual device, accessibility walkthrough, performance profiling,
  privacy/legal review, account/R2 production proof, TestFlight, App Store,
  archive export, and upload procedures were not run for this docs/control-plane
  packet under the user's standing instruction authorizing issue completion
  without testing until advised otherwise.
- The listed matrix commands are requirements for future scoped closeouts, not
  proof that those future commands pass.

## Private Life Orchestration Relationship

Private Life Orchestration preserved: this control-plane leaf protects the Proof
and Learning side of Ambitions' Intent -> Context -> Path -> Time Fit -> Reflow
-> Action -> Proof -> Learning loop by making validation ownership explicit and
by preventing no-proof work from becoming fake Green. It does not alter user
data, the private life graph, runtime mutation behavior, or product surfaces.

## Architecture Closeout

- Final Architecture Tree inspected: yes.
- Canonical owners touched: none in Swift source; docs/control-plane evidence
  only under `docs/linear/reconciliation/`.
- Non-canonical owners touched: none.
- Files moved or created: two reconciliation artifacts.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Architecture debt: `AMB-1705` remains blocked until remaining blocker issues
  and required proof gates are reconciled.
- Next repair train if debt remains: continue with the next live `AMB-1705`
  blocker after `AMB-1794`.
- No equivalent folder/path interpretation was used.

## Rollback

Revert this packet and the paired JSON matrix, then move `AMB-1794` back from
Ready For Review if the validation command ownership contract is no longer
preserved.
