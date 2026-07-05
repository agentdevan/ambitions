# AMB-1824 Risk Register Ledger

Status: Implemented Yellow / Ready For Review for this docs/control-plane leaf
Date: 2026-07-05T16:09:45Z
Branch: `main`
Baseline main SHA: `476cf4a22683f39e39509bbb9939d454edefeac2`
Commit SHA: artifact commit SHA is recorded in Linear after commit/push
Environment: local Codex macOS workspace at `/Users/devan/Documents/GitHub/ambitions`
Xcode version: Xcode 26.6, build version 17F113
Simulator or device: simulator preflight and XcodeBuildMCP transport proof were verified before this packet; no app build, app launch, XCTest, focused test, or physical-device procedure is claimed for AMB-1824
Exit code(s): listed in Validation Run below
Artifact paths: this packet and `docs/linear/reconciliation/2026-07-05-amb-1824-risk-register-ledger.json`
Parent: `AMB-1703` Parent Feature - Known-Issue and Risk Register Integration
Issue: `AMB-1824` Risk Register Leaf - P0/P1 architecture risk ledger

## Scope

This leaf converts the current architecture remediation risk families into a
tracked risk ledger with owner issue, current owner status, evidence source,
proof ceiling, and unblocker.

This is docs/control-plane reconciliation only. It does not change Swift source,
XcodeGen project source, Package.swift, runtime behavior, rendered UI, privacy
behavior, Source Atlas behavior, account behavior, R2 behavior, device behavior,
or release behavior.

## Live Inputs

Live repo and tracker state inspected for this packet:

- `git status --short --branch`: clean `main...origin/main`
- Local and remote main SHA: `476cf4a22683f39e39509bbb9939d454edefeac2`
- `mcp__xcodebuildmcp.session_show_defaults`: passed in the current Codex process
- `codex mcp get xcodebuildmcp`: passed; stdio wrapper has no env override
- `scripts/ambitions-xcodebuildmcp-probe.py --json`: passed
- `scripts/ambitions-xcode-sim-health.sh --json --timeout 30s`: passed
- Live Linear `AMB-1824`: `In Progress`
- Live Linear `AMB-1703`: `In Progress`
- Live Linear owner status refreshes for `AMB-1665`, `AMB-1668`, `AMB-1678`,
  `AMB-1679`, `AMB-1681`, `AMB-1682`, `AMB-1683`, `AMB-1685`, `AMB-1687`,
  `AMB-1688`, `AMB-1690`, `AMB-1691`, `AMB-1700`, `AMB-1701`, `AMB-1702`,
  `AMB-1704`, `AMB-1705`, `AMB-1758`, `AMB-1759`, `AMB-1760`, `AMB-1761`,
  `AMB-1762`, `AMB-1794`, `AMB-1801`, `AMB-1821`, `AMB-1822`, `AMB-1823`,
  and `AMB-1825`

Supporting retained repo evidence:

- `docs/audits/architecture-remediation-risk-register.md`
- `docs/linear/reconciliation/2026-07-05-amb-1760-accepted-yellow-follow-up-ledger.md`
- `docs/linear/reconciliation/2026-07-05-amb-1826-pre-scorecard-blocker-inventory.md`
- `docs/linear/reconciliation/2026-07-05-xcodebuildmcp-transport-and-simulator-preflight-repair.md`

## Current Owner Status Snapshot

| Issue | Current Linear status | Role in this ledger |
| --- | --- | --- |
| `AMB-1665` | Accepted Yellow | Runtime authority map residual risk owner. |
| `AMB-1668` | Accepted Yellow | External adapter mutation enforcement residual risk owner. |
| `AMB-1678` | In Progress | Design system single-authority / UI framework reinvention owner. |
| `AMB-1679` | In Progress | ExperienceKernel package boundary owner. |
| `AMB-1681` | In Progress | Package boundary decision record owner. |
| `AMB-1682` | Spec Ready | Source Atlas influence receipt owner. |
| `AMB-1683` | In Progress | Privacy manifest and App Store disclosure audit owner. |
| `AMB-1685` | In Progress | App Group snapshot safety owner. |
| `AMB-1687` | In Progress | App Intents command routing owner. |
| `AMB-1688` | In Progress | Widget and Live Activity projection safety owner. |
| `AMB-1690` | In Progress | EventKit / Reminders outbox owner. |
| `AMB-1691` | Spec Ready | Xcode test plan / test architecture owner. |
| `AMB-1700` | In Progress | Release Candidate gate owner. |
| `AMB-1701` | In Progress | Device proof matrix owner. |
| `AMB-1702` | Ready For Review | Truth status normalization parent. |
| `AMB-1703` | In Progress | Risk register parent. |
| `AMB-1704` | Ready For Review | Architecture doctrine rewrite parent. |
| `AMB-1705` | Needs Repair | Final architecture closeout and scorecard rerun gate. |
| `AMB-1758` | Ready For Review | Extension surface privacy gate. |
| `AMB-1759` | Ready For Review | Architecture repo path normalization. |
| `AMB-1760` | Ready For Review | Accepted Yellow follow-up ledger. |
| `AMB-1761` | Ready For Review | Validation command inheritance. |
| `AMB-1762` | Ready For Review | Release non-claim gate. |
| `AMB-1794` | Ready For Review | Validation command matrix. |
| `AMB-1801` | Ready For Review | ExperienceKernel live import and boundary decision. |
| `AMB-1821` | Ready For Codex | RC checklist non-claim packet leaf. |
| `AMB-1822` | Ready For Codex | Device matrix and simulator ceiling leaf. |
| `AMB-1823` | Ready For Review | Truth status leaf. |
| `AMB-1824` | In Progress | This risk ledger leaf. |
| `AMB-1825` | Ready For Review | Doctrine rewrite leaf. |

## Risk Ledger

| Risk ID | Severity | Risk | Evidence source | Owner issue(s) and status | Current ledger status | Proof ceiling | Unblocker / next work |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `P0-01` | P0 | Legacy runtime, persistence, adapter, and direct-write authority can be mistaken for Green when current proof is only map/guard/source-slice proof. | ARR-001, ARR-002, ARR-003, ARR-008; AMB-1760 residual-risk ledger. | `AMB-1665` Accepted Yellow; `AMB-1668` Accepted Yellow. | Open residual risk; tracked by this ledger but not burned down. | No M02 Green, LocalRuntimeOS completion, all-mutation enforcement, device proof, or release proof. | Current runtime/source gates plus re-enabled focused tests/device proof before any Green; final reconciliation remains blocked by `AMB-1705`. |
| `P0-02` | P0 | Architecture theater and fake-Green drift: docs, scorecards, or packet language can imply remediation completion without executable/current evidence. | ARR-005, ARR-006; `docs/truth/CODEX_START_HERE.md`; AMB-1760; AMB-1826 blocker inventory. | `AMB-1705` Needs Repair; `AMB-1760` Ready For Review; `AMB-1794` Ready For Review; `AMB-1702` Ready For Review; `AMB-1704` Ready For Review. | Open until `AMB-1705` rerun closes with explicit Green/Yellow/Red by evidence. | Docs/control-plane Green only for exact packet discipline; no final architecture, source, release, or product Green. | `AMB-1705` must rerun scorecard after accepted risks, validation inheritance, non-claim gates, and blocker inventory are reconciled. |
| `P0-03` | P0 | Wrong-owner edits and path drift can reintroduce legacy `Features/` compatibility debt, Motion/Capture tab drift, generic projection/lens authority, or non-canonical architecture ownership. | ARR-004, ARR-010; AGENTS final-tree law; AMB-1759 path-normalization packet. | `AMB-1759` Ready For Review; `AMB-1761` Ready For Review; `AMB-1704` Ready For Review. | Tracked / review-ready for current docs-control-plane packet; still open as source discipline until gates run on future source edits. | No source architecture Green or owner permanence claim from docs alone. | Continue enforcing path normalization, Final Architecture Tree inspection, and remediation governance on every source train. |
| `P0-04` | P0 | Source Atlas scope creep can turn public/reference/freshness infrastructure into private intelligence, private graph egress, or production R2/release claims. | ARR-012; AMB-1760 Source Atlas rows; `docs/truth/IMPLEMENTATION_TRUTH.md`; `docs/truth/PRIVATE_LIFE_ORCHESTRATION_TRUTH.md`. | `AMB-1682` Spec Ready; `AMB-1725` through `AMB-1728` Accepted Yellow in AMB-1760; `AMB-1762` Ready For Review. | Open. | No Source Atlas private planning Green, production R2 Green, privacy/legal approval, device proof, TestFlight, App Store, or release readiness. | Decompose/execute `AMB-1682`; retain ADR allowlist and boundary audit before any Source Atlas scope growth. |
| `P1-01` | P1 | UI framework reinvention and design-system duplication can hide native SwiftUI leverage behind custom shell/stage/design abstractions. | ARR-005; AGENTS doctrine: no platform reinvention when SwiftUI owns it; AMB-1825 doctrine patch. | `AMB-1678` In Progress; `AMB-1679` In Progress; `AMB-1801` Ready For Review; `AMB-1704` Ready For Review. | Open / partially control-plane mitigated. | No Visual Green, accessibility Green, SwiftUI leverage Green, or package-boundary Green from doctrine alone. | Continue `AMB-1678` and `AMB-1679`; use `AMB-1801` boundary decision and source/build proof when testing is re-enabled. |
| `P1-02` | P1 | Release proof gap: architecture and docs packets can be mistaken for TestFlight/App Store readiness without RC artifacts, device matrix, screenshots, accessibility, privacy/legal, archive, or upload proof. | AMB-1762 release non-claim gate; AMB-1794 validation matrix; AMB-1826 blocker inventory. | `AMB-1700` In Progress; `AMB-1821` Ready For Codex; `AMB-1701` In Progress; `AMB-1822` Ready For Codex; `AMB-1762` Ready For Review; `AMB-1794` Ready For Review. | Open. | No Release Green, TestFlight readiness, App Store readiness, archive/upload, device readiness, build success, or test success. | Execute `AMB-1821` and `AMB-1822`; keep release non-claim gate required on release-facing packets. |
| `P1-03` | P1 | Privacy metadata drift: local-first philosophy can diverge from manifest/disclosure reality, extension snapshots, App Group payloads, Source Atlas references, and account/R2 behavior. | ARR-009, ARR-012; AMB-1758 extension privacy gate; AMB-1760 privacy/source rows. | `AMB-1683` In Progress; `AMB-1685` In Progress; `AMB-1758` Ready For Review; `AMB-1682` Spec Ready. | Open / partially review-ready for extension gate. | No privacy/legal approval, App Store privacy disclosure approval, device proof, production account proof, or R2 readiness. | Continue `AMB-1683` and `AMB-1685`; pair privacy manifests with current code inventory and device/system-surface proof before release claims. |
| `P1-04` | P1 | System-surface regressions: widgets, App Intents, Live Activities, EventKit/Reminders, notifications, and extensions can bypass runtime command/projection/privacy laws under lifecycle/device conditions. | ARR-009; AMB-1760 external-adapter residual rows; device-proof blocker inventory. | `AMB-1687` In Progress; `AMB-1688` In Progress; `AMB-1690` In Progress; `AMB-1668` Accepted Yellow; `AMB-1701` In Progress; `AMB-1822` Ready For Codex. | Open. | No system-surface Green, device Green, locked-device proof, extension lifecycle proof, notification proof, or EventKit/Reminders device proof. | Execute system-surface parents and `AMB-1822`; rerun device matrix and focused source tests when testing/device proof are permitted. |
| `P2-01` | P2 | UI test monolith and implicit target selection can make validation ad hoc and non-repeatable. | ARR-007; AMB-1794 validation matrix. | `AMB-1691` Spec Ready; `AMB-1794` Ready For Review. | Open. | No test architecture Green, CI Green, XCTest pass, UI test pass, or release-validation completeness. | Decompose and execute `AMB-1691` test-plan leaves; wire smoke/runtime/accessibility/screenshots/RC plans when testing is re-enabled. |
| `P2-02` | P2 | Package fragmentation and platform-floor drift can turn modularization into cleanup theater or stale package authority. | ARR-011; AMB-1801 boundary decision packet. | `AMB-1681` In Progress; `AMB-1679` In Progress; `AMB-1801` Ready For Review. | Open / partially review-ready for ExperienceKernel boundary. | No package-boundary Green, build success, source import Green, or release proof from docs alone. | Continue `AMB-1681` and parent `AMB-1679`; require build/import proof before package-boundary Green. |

## Parent Feature Coverage

`AMB-1703` required P0, P1, and P2 risk coverage. This packet covers:

- P0: legacy authority, architecture theater, wrong-owner edits, Source Atlas creep.
- P1: UI framework reinvention, release proof gap, privacy metadata drift,
  system-surface regressions.
- P2: UI test monolith, package fragmentation.

Each risk is linked to this parent through `AMB-1824` and to specific owner
issues in the ledger above. The risk register is now materially actionable, but
the underlying risks remain open where their owner issues are Accepted Yellow,
Spec Ready, In Progress, Ready For Codex, Ready For Review, or Needs Repair.

## Validation Run

Completed for this docs/control-plane packet:

| Command | Exit code | Result |
| --- | ---: | --- |
| `git diff --check` | 0 | Passed after packet creation. |
| `python3 -m json.tool docs/linear/reconciliation/2026-07-05-amb-1824-risk-register-ledger.json` | 0 | Passed after packet creation. |
| `python3 scripts/ambitions-release-non-claim-gate.py` | 0 | Passed after packet creation; `release_facing_packets_checked=2`. |
| `python3 scripts/ambitions-accepted-yellow-misuse-audit.py` | 0 | Passed after packet creation; `checkedAcceptedYellowIssues=19`, `invalidAcceptedYellowIssues=0`. |
| `python3 scripts/ambitions-architecture-path-normalization-check.py` | 0 | Passed after packet creation; `architecture_packets_checked=21`. |
| `python3 scripts/ambitions-unsupported-claim-scan.py docs/linear/reconciliation/2026-07-05-amb-1824-risk-register-ledger.md docs/linear/reconciliation/2026-07-05-amb-1824-risk-register-ledger.json docs/linear/reconciliation/2026-07-05-xcodebuildmcp-transport-and-simulator-preflight-repair.md` | 0 | Passed after packet creation. |
| `python3 scripts/ambitions-remediation-governance-check.py` | 0 | Passed after packet creation; `changed_paths=2`, `production_swift_files=1421`, `overHardLineCapFiles=0`. |

## Validation Not Run

- XCTest, xcodebuild build, xcodebuild test, build-for-testing, focused tests,
  UI tests, app launch, manual device, accessibility walkthrough, performance
  profiling, privacy/legal review, account/R2 production proof, TestFlight,
  App Store, archive export, and upload procedures were not run for this
  docs/control-plane packet under the current user instruction authorizing
  issue completion without testing until advised otherwise.

## Non-Claims

- This packet does not burn down the risks. It creates the tracked risk ledger
  and current status map.
- No final architecture Green, M02 Green, LocalRuntimeOS completion,
  all-mutation enforcement, source architecture Green, build success, test
  success, device proof, Visual Green, accessibility Green, privacy/legal
  approval, account readiness, R2 readiness, Release Green, TestFlight
  readiness, App Store readiness, or product completion is claimed.
- Accepted Yellow remains Yellow and cannot close required remediation scope
  that still needs source changes, runtime enforcement, executable tests, device
  proof, privacy/legal approval, or release proof.
- This packet does not close `AMB-1705`.

## Private Life Orchestration Relationship

Private Life Orchestration preserved: this ledger protects the Proof and
Learning side of Ambitions' Intent -> Context -> Path -> Time Fit -> Reflow ->
Action -> Proof -> Learning loop by keeping architecture risk ownership,
status, proof ceilings, and unblockers explicit. It does not alter user data,
the private life graph, runtime mutation behavior, or product surfaces.

## Architecture Closeout

- Final Architecture Tree inspected: yes.
- Canonical owners touched: none in Swift source; docs/control-plane evidence
  only.
- Files moved or created: this reconciliation packet and a paired JSON ledger.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Yellow architecture/proof debt remains: yes. Every risk row above has a proof
  ceiling and several owner issues remain Accepted Yellow, Spec Ready, In
  Progress, Ready For Codex, Ready For Review, or Needs Repair.
- Next repair train if debt remains: execute `AMB-1821`, `AMB-1822`, and the
  still-open parent/leaf owners, then rerun `AMB-1705`.
- Confirmation: no equivalent-folder or alternate-path interpretation was used.

## Rollback

Revert this packet and the paired JSON ledger. Move `AMB-1824` back to
`Needs Repair` or `Ready For Codex` if the P0/P1/P2 risk rows, owner statuses,
proof ceilings, or unblockers are not preserved.
