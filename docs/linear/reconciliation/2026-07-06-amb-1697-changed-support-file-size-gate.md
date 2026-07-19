# AMB-1697 Changed Support File-Size Gate

Status: Implemented Yellow / parent remains In Progress

Date: 2026-07-06
Branch: `main`
Baseline main SHA: `e4d5f241d2c7a5c12ad7134e26e82e571084ce37`
Commit SHA: pending local packet commit; final commit SHA is recorded in Linear
after commit and push
Environment: local Codex macOS workspace at `/Users/devan/Documents/GitHub/ambitions`
Xcode version: Xcode 26.6, build version 17F113
Simulator or device: no simulator app launch, XCTest, UI test, screenshot,
accessibility, performance, archive, upload, or physical-device procedure is
claimed.
Project: Architecture Simplification + Flagship Readiness Remediation (`59c3917f-f662-4ca3-b412-b532613f3a7a`)
Issue: `AMB-1697` Parent Feature - File-Size Gate and Cleanup Queue
Artifact paths: this packet and `docs/linear/reconciliation/2026-07-06-amb-1697-changed-support-file-size-gate.json`

## Scope

This slice adds the changed-file fail threshold for oversized Swift support
files. It does not claim the AMB-1697 parent is complete.

## Implementation

Changed:

- `scripts/ambitions-quality-gate.py`

The quality gate now scans Swift support files from:

- `Native/AmbitionsTests/`
- `Native/AmbitionsUITests/`
- `Native/Ambitions/PreviewSupport/`
- `Sources/Previews/`

If one of those files is changed and exceeds 600 lines, the strict quality gate
emits a `support-file-size` finding and fails. Existing oversized support files
remain visible in the remediation governance queue, but they cannot be touched
without either reducing them below the cap or deliberately failing the gate.

The existing PR review workflow already runs:

- `python3 scripts/ambitions-quality-gate.py`

So this is a CI-enforced changed-file fail rule, not only a local report.

## Evidence

- `python3 scripts/ambitions-quality-gate.py` now reports
  `support_swift_files=489`.
- Direct helper validation produced exactly one finding for the known oversized
  `Native/AmbitionsTests/You/YouFeatureServiceTests.swift` file at 2,485 lines.
- The same helper validation produced no finding for the under-cap
  `Native/AmbitionsUITests/TimeSurfaceUITests.swift` file at 571 lines.
- The same helper validation confirmed `PreviewSupport` files are included in
  the support scan.
- `python3 scripts/ambitions-quality-gate.py --json` returned `{}` for the
  current diff.

## Validation Run

| Command | Exit code | Result |
| --- | ---: | --- |
| `python3 -m py_compile scripts/ambitions-quality-gate.py` | 0 | Script compiled. |
| `python3 scripts/ambitions-quality-gate.py --self-test` | 0 | Existing self-test passed. |
| Direct `check_changed_support_file_sizes` helper validation | 0 | One oversized touched support file was rejected; one under-cap UI test file was allowed; PreviewSupport inclusion was confirmed. |
| `python3 scripts/ambitions-quality-gate.py` | 0 | Passed; `production_swift_files=1425`, `support_swift_files=489`, `changed_paths=1`. |
| `python3 scripts/ambitions-quality-gate.py --json` | 0 | Passed with `{}` findings for the current diff. |
| `python3 scripts/ambitions-remediation-governance-check.py --json` | 0 | Passed; `valid=true`, `findingCount=0`, `supportOverHardLineCapFiles=40`. |
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
- screenshot capture
- accessibility device proof
- performance measurement
- archive, TestFlight, App Store upload, or physical-device procedure

## Non-Claims

- No Implemented Green claim.
- No AMB-1697 parent closeout.
- No repo-wide file-size cleanup Green.
- No full support/test backlog cleanup.
- No build success claim.
- No XCTest pass claim.
- No CI run claim.
- No release readiness.
- No TestFlight or App Store readiness.

## Remaining AMB-1697 Debt

AMB-1697 remains In Progress for:

- existing oversized support/test files in the remediation queue
- near-cap production file reductions
- trend/monthly reporting
- additional focused splits with executable proof when build/test proof is
  allowed

## Architecture Closeout

- Final Architecture Tree inspected: yes.
- Canonical owners touched: `scripts/` quality gate only.
- Files moved or created: this packet and paired JSON.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Yellow architecture debt remains: yes; the existing file-size backlog remains
  open.
- Next repair train if debt remains: continue AMB-1697 by splitting the next
  oversized support/test file or reducing the nearest production file before it
  crosses the hard cap.
- Confirmation: no equivalent-folder or alternate-path interpretation was used.
