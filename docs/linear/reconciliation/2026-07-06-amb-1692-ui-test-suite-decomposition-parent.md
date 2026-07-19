# AMB-1692 UI Test Suite Decomposition Parent

Status: Implemented Yellow / Accepted Yellow candidate

Date: 2026-07-06
Branch: `main`
Baseline main SHA: `d1876be23d7b00df57813b3046080e27c9114714`
Commit SHA: pending local packet commit; final commit SHA is recorded in Linear
after commit and push
Environment: local Codex macOS workspace at `/Users/devan/Documents/GitHub/ambitions`
Xcode version: Xcode 26.6, build version 17F113
Simulator or device: no simulator app launch, XCTest, UI test, screenshot,
accessibility, performance, archive, upload, or physical-device procedure is
claimed.
Project: Architecture Simplification + Flagship Readiness Remediation (`59c3917f-f662-4ca3-b412-b532613f3a7a`)
Issue: `AMB-1692` Parent Feature - UI Test Suite Decomposition
Artifact paths: this packet and `docs/linear/reconciliation/2026-07-06-amb-1692-ui-test-suite-decomposition-parent.json`

## Scope

This packet covers the source/config portion of the UI test suite decomposition
parent. Build, XCTest execution, simulator proof, screenshot proof, and device
proof were intentionally skipped per current user instruction.

## Implementation

The previous catch-all UI test file was removed:

- `Native/AmbitionsUITests/AmbitionsUITests.swift` deleted.

Its test methods were moved into scenario-owned XCTest classes:

- `Native/AmbitionsUITests/BootstrapShellUITests.swift`
- `Native/AmbitionsUITests/CaptureComposerUITests.swift`
- `Native/AmbitionsUITests/GoalsSurfaceUITests.swift`
- `Native/AmbitionsUITests/TodaySurfaceUITests.swift`
- `Native/AmbitionsUITests/TimeSurfaceUITests.swift`
- `Native/AmbitionsUITests/YouSurfaceUITests.swift`

Shared UI test utilities were extracted into semantic support files:

- `Native/AmbitionsUITests/AmbitionsUITestCase.swift`
- `Native/AmbitionsUITests/AmbitionsCaptureUITestSupport.swift`
- `Native/AmbitionsUITests/AmbitionsGoalsUITestSupport.swift`
- `Native/AmbitionsUITests/AmbitionsScreenshotUITestSupport.swift`
- `Native/AmbitionsUITests/AmbitionsScrollingUITestSupport.swift`
- `Native/AmbitionsUITests/AmbitionsShellUITestSupport.swift`
- `Native/AmbitionsUITests/AmbitionsTimeUITestSupport.swift`
- `Native/AmbitionsUITests/AmbitionsTodayUITestSupport.swift`
- `Native/AmbitionsUITests/AmbitionsYouUITestSupport.swift`

No compatibility shim was left behind.

## Evidence

Static evidence produced in this slice:

- Old monolith test count from git: 61 methods.
- New UI test target test count: 68 methods, including 7 pre-existing methods
  in already separate UI test files.
- Missing old monolith test methods after split: none.
- UI test Swift files over 600 lines after split: none.
- Largest new UI test file: `Native/AmbitionsUITests/TimeSurfaceUITests.swift`
  at 571 lines.
- Remediation governance support over-cap count dropped from 41 to 40; the old
  3,215-line `Native/AmbitionsUITests/AmbitionsUITests.swift` no longer appears
  in the support largest-file queue.
- `xcodegen generate --spec project.yml` completed from the split source tree.

## Validation Run

| Command | Exit code | Result |
| --- | ---: | --- |
| `python3 - <<'PY' ... old/new UI test method parity ... PY` | 0 | Old monolith methods preserved; no missing moved tests. |
| `python3 - <<'PY' ... Native/AmbitionsUITests line-cap check ... PY` | 0 | No UI test Swift file exceeds 600 lines. |
| `xcodegen generate --spec project.yml` | 0 | Regenerated the Xcode project from the split source tree. |
| `xcrun swiftc -parse ... Native/AmbitionsUITests/*.swift` | 0 | UI test Swift files parsed. |
| `python3 scripts/ambitions-remediation-governance-check.py --json` | 0 | Passed; `valid=true`, `findingCount=0`, `changedPathCount=18`. |
| `python3 scripts/ambitions-quality-gate.py` | 0 | Passed after this metadata repair. |
| `python3 scripts/ambitions-accepted-yellow-misuse-audit.py --json` | 0 | Passed; `invalidAcceptedYellowIssues=[]`. |
| `python3 scripts/ambitions-architecture-inventory.py` | 0 | Passed; final-tree parity achieved. |
| `python3 scripts/ambitions-vocabulary-drift-scan.py` | 0 | Passed. |
| `python3 scripts/ambitions-local-first-boundary-scan.py` | 0 | Passed. |
| `python3 scripts/ambitions-green-standard-audit.py` | 0 | Passed. |
| `python3 scripts/ambitions-unsupported-claim-scan.py ...` | 0 | Passed for this packet and paired JSON. |
| `scripts/release-claim-safety-scan.sh ...` | 0 | Passed. |
| `git diff --check` | 0 | Passed. |

## Validation Not Run

Build proof is intentionally skipped under the current user instruction.

Not run:

- xcodebuild build
- xcodebuild build-for-testing
- XCTest
- UI tests
- GitHub Actions workflow execution
- simulator app launch
- deterministic screenshot capture
- manual VoiceOver, Dynamic Type, Reduce Motion, or accessibility device proof
- performance measurement
- archive, TestFlight, App Store upload, or physical-device procedure

## Non-Claims

- No Implemented Green claim.
- No CI Green claim.
- No test pass claim.
- No screenshot proof.
- No rendered UI proof.
- No accessibility conformance claim.
- No performance readiness claim.
- No device proof.
- No release readiness.
- No TestFlight or App Store readiness.
- No privacy/legal approval.

## Proof Ceiling

This is not Implemented Green because build/XCTest execution, simulator launch,
and device proof were skipped by instruction. The source decomposition,
coverage-preservation parity check, XcodeGen generation, and static governance
checks support Accepted Yellow for AMB-1692.

## Architecture Closeout

- Final Architecture Tree inspected: yes.
- Canonical owners touched: `Native/AmbitionsUITests` test support only.
- Files moved or created: listed above.
- Old/non-canonical paths removed: `Native/AmbitionsUITests/AmbitionsUITests.swift`.
- Compatibility shims left behind: none.
- Yellow architecture debt remains: runtime execution proof is missing because
  build proof is currently skipped.
- Next repair train if debt remains: run the configured UI test plan and attach
  XCTest/simulator evidence when build proof is allowed.
- Confirmation: no equivalent-folder/path interpretation was used.
