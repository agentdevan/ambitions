# AMB-1691 Xcode Test Plans Parent Closeout

Status: Implemented Yellow parent closeout
Date: 2026-07-06T03:22:00Z
Branch: `main`
Baseline main SHA: `58248dd65aea813c9f01acca8a61c1fb86d5a2a4`
Environment: local Codex macOS workspace at `/Users/devan/Documents/GitHub/ambitions`
Xcode version: Xcode 26.6, build version 17F113
Simulator or device: no simulator app launch, XCTest, UI test, screenshot,
accessibility, performance, archive, upload, or physical-device procedure is
claimed.
Project: Architecture Simplification + Flagship Readiness Remediation (`59c3917f-f662-4ca3-b412-b532613f3a7a`)
Issue: `AMB-1691` Parent Feature - Xcode Test Plans
Artifact paths: this packet and `docs/linear/reconciliation/2026-07-06-amb-1691-xcode-test-plans-parent.json`

## Scope

This packet closes the parent-level Xcode test-plan configuration scope as
Implemented Yellow under the current instruction to skip build proof until
advised otherwise.

Implemented source/configuration evidence:

- `Native/TestPlans/Smoke.xctestplan`
- `Native/TestPlans/Runtime.xctestplan`
- `Native/TestPlans/Accessibility.xctestplan`
- `Native/TestPlans/Screenshots.xctestplan`
- `Native/TestPlans/ReleaseCandidate.xctestplan`
- `project.yml`
- `.github/workflows/ambitions-xcode-test-plans.yml`
- `docs/qa/test-plans/amb-1691-xcode-test-plan-suite.md`

## Acceptance Mapping

| AMB-1691 requirement | Current source status | Proof ceiling |
| --- | --- | --- |
| Add `Smoke.xctestplan`. | Already installed by AMB-1812 and retained. | Static/project configuration only. |
| Add `Runtime.xctestplan`. | Added with focused LocalRuntimeOS, privacy/storage, Source influence receipt, and runtime replay selectors. | XCTest execution skipped. |
| Add `Accessibility.xctestplan`. | Added with automated accessibility nutrition and flagship-surface state selectors. | Accessibility proof, manual VoiceOver, Dynamic Type, and device proof skipped. |
| Add `Screenshots.xctestplan`. | Added with deterministic screenshot UI lane selector. | Screenshot capture and rendered review skipped. |
| Add `ReleaseCandidate.xctestplan`. | Added as an aggregate unit/UI plan with coverage enabled. | Build, XCTest, CI Green, and release proof skipped. |
| Wire plans into CI. | Added `.github/workflows/ambitions-xcode-test-plans.yml` manual-dispatch route that maps each plan to a named scheme, runs build-for-testing, runs the selected test plan, and uploads Xcode artifacts. | Workflow not executed in this closeout. |
| Document when each plan runs. | Added `docs/qa/test-plans/amb-1691-xcode-test-plan-suite.md`. | Documentation only; no proof upgrade. |

## Validation Run

Completed for this parent packet:

| Command | Exit code | Result |
| --- | ---: | --- |
| `for f in Native/TestPlans/Smoke.xctestplan Native/TestPlans/Runtime.xctestplan Native/TestPlans/Accessibility.xctestplan Native/TestPlans/Screenshots.xctestplan Native/TestPlans/ReleaseCandidate.xctestplan; do python3 -m json.tool "$f" >/dev/null \|\| exit 1; done` | 0 | Every test-plan JSON file parsed. |
| `python3 -m json.tool docs/linear/reconciliation/2026-07-06-amb-1691-xcode-test-plans-parent.json` | 0 | This packet JSON parsed. |
| `xcodegen generate --spec project.yml` | 0 | Regenerated the Xcode project from `project.yml`. |
| `xcodegen dump --type parsed-json` selector audit | 0 | Confirmed every named test-plan scheme points at the expected plan with `defaultPlan == true`. |
| Generated scheme inspection | 0 | Confirmed the five generated `.xcscheme` files contain a `<TestPlans>` reference. |
| `actionlint .github/workflows/ambitions-xcode-test-plans.yml` | 0 | Workflow syntax passed local actionlint. |
| `python3 scripts/ambitions-remediation-governance-check.py --json` | 0 | Passed; `valid=true`, `findingCount=0`, `changedPathCount=9`. |
| `python3 scripts/ambitions-quality-gate.py` | 0 | Passed; all strict quality gates passed. |
| `python3 scripts/ambitions-accepted-yellow-misuse-audit.py --json` | 0 | Passed; `invalidAcceptedYellowIssues=[]`. |
| `python3 scripts/ambitions-architecture-inventory.py` | 0 | Passed; final-tree parity achieved. |
| `python3 scripts/ambitions-green-standard-audit.py` | 0 | Passed. |
| `python3 scripts/ambitions-vocabulary-drift-scan.py` | 0 | Passed. |
| `python3 scripts/ambitions-local-first-boundary-scan.py` | 0 | Passed. |
| `python3 scripts/ambitions-unsupported-claim-scan.py ...` | 0 | Passed for the test-plan suite doc, this packet, and paired JSON. |
| `git diff --check` | 0 | Passed. |

## Validation Not Run

Build proof is intentionally skipped under the current user instruction.

Not run:

- xcodebuild build
- xcodebuild build-for-testing
- XCTest
- UI tests
- manual-dispatch GitHub Actions run
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

## Architecture Closeout

- Final Architecture Tree inspected: yes.
- Canonical owners touched: `Quality`/test-plan and CI configuration only.
- Files moved or created:
  - `Native/TestPlans/Runtime.xctestplan`
  - `Native/TestPlans/Accessibility.xctestplan`
  - `Native/TestPlans/Screenshots.xctestplan`
  - `Native/TestPlans/ReleaseCandidate.xctestplan`
  - `.github/workflows/ambitions-xcode-test-plans.yml`
  - `docs/qa/test-plans/amb-1691-xcode-test-plan-suite.md`
  - `docs/linear/reconciliation/2026-07-06-amb-1691-xcode-test-plans-parent.md`
  - `docs/linear/reconciliation/2026-07-06-amb-1691-xcode-test-plans-parent.json`
- Source files edited: none.
- Project source edited: `project.yml`.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- New `+02`, `+03`, or `+04` split files added: none.
- New broad `Models.swift` files added: none.
- New runtime, mutation, persistence, projection-materialization, receipt,
  replay, side-effect, migration, repair, privacy, sync, diagnostics, or Source
  Atlas authority added: none.
- Yellow architecture/proof debt remains: yes, because build, XCTest, CI
  execution, screenshot, accessibility/device, performance, and release proof
  are intentionally skipped.
- Next repair train if debt remains: execute the relevant plan workflow or
  local plan runner when build proof is re-enabled.
- Confirmation: no equivalent-folder or alternate-path interpretation was used.

## Rollback

Revert this packet, the new test plans, the manual CI workflow, and the named
scheme additions in `project.yml`. Keep `Smoke.xctestplan` only if AMB-1812
remains accepted.
