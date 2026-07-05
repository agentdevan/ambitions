# AMB-1808 App Intent Command Routing Inventory

Status: Implemented Yellow
Date: 2026-07-05T20:10:00Z
Branch: `main`
Baseline main SHA: `f54f2e77f27b945168882074615a62bbb8b68c4f`
Commit SHA: artifact commit SHA is recorded in Linear after commit/push
Environment: local Codex macOS workspace at `/Users/devan/Documents/GitHub/ambitions`
Xcode version: Xcode 26.6, build version 17F113
Simulator or device: simulator health only; no app launch, Siri/Shortcuts invocation, terminated-app invocation, or physical-device procedure was run
Exit code(s): listed in Validation Run below
Artifact paths: this manifest and `docs/qa/evidence/2026-07-05-amb-1808-app-intent-command-routing-inventory/app-intent-command-routing-inventory.json`
Parent: `AMB-1687` Parent Feature - App Intents Testing and Command Routing
Issue: `AMB-1808` App Intents Leaf - Mutating intent command-routing inventory

## Scope

- Inventoried current Ambitions App Intent routes and classified them as `projection_query`, `capture_command`, or `action_command`.
- Added a guard for unsafe or unknown mutating App Intent routes.
- No current unsafe or unknown mutating route was found.

## Evidence

- Source inventory: `Native/Ambitions/Core/LocalRuntimeOS/Commands/AppIntentCommandRoutingInventory.swift`.
- Focused assertions: `Native/AmbitionsTests/App/AppIntentCommandRoutingInventoryTests.swift`.
- Existing bridge source: `Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/AppIntentBridge.swift`.
- Existing command-backed import source: `Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/ExternalCreationImportService.swift`.
- Existing descriptor tests: `Native/AmbitionsTests/App/AppIntentRoutingTests.swift`.

## Validation Run

Completed for this packet:

| Command | Exit code | Result |
| --- | ---: | --- |
| `xcodegen generate` | 0 | Project regenerated. |
| `scripts/ambitions-xcodegen-needed.sh` | 0 | `XCODEGEN_NEEDED=0`; project build inputs unchanged. |
| `python3 -m json.tool docs/qa/evidence/2026-07-05-amb-1808-app-intent-command-routing-inventory/app-intent-command-routing-inventory.json` | 0 | JSON evidence parsed. |
| `swiftc -parse Native/Ambitions/Core/LocalRuntimeOS/Commands/AppIntentCommandRoutingInventory.swift Native/AmbitionsTests/App/AppIntentCommandRoutingInventoryTests.swift` | 0 | Swift parser accepted the inventory and focused assertions; no XCTest execution. |
| `git diff --check` | 0 | Passed after source/evidence edits. |
| `python3 scripts/ambitions-remediation-governance-check.py` | 0 | Passed; `changed_paths=4`, `production_swift_files=1425`, `overHardLineCapFiles=0`. |
| `python3 scripts/ambitions-quality-gate.py` | 0 after evidence-format repair | Strict quality gates passed after this evidence packet included validation run, validation-not-run, branch, commit, environment, Xcode version, exit-code, and artifact-path fields. |
| `python3 scripts/ambitions-architecture-inventory.py` | 0 | Passed; final-tree parity achieved. |
| `python3 scripts/ambitions-green-standard-audit.py` | 0 | Passed; no disallowed architecture-as-UI strings found in active primary UI source. |
| `python3 scripts/ambitions-vocabulary-drift-scan.py` | 0 | Passed; canonical active vocabulary present and ban terms absent. |
| `python3 scripts/ambitions-local-first-boundary-scan.py` | 0 | Passed; local-first/account/R2/hosted-AI boundary checks passed in active authority files. |
| `scripts/no-unsupported-ai-claim-scan.sh ...` | 0 | Advisory Yellow only; hit existing `docs/truth/PRODUCT_EXPERIENCE_CANON.md` wording outside this AMB-1808 diff and was reviewed as non-claim context. |
| `scripts/ambitions-xcode-sim-health.sh --json --timeout 20s` | 25 | Initial simulator preflight failed because active Xcode processes were blocking the check. |
| `scripts/ambitions-xcode-sim-health.sh --repair --kill-active-xcode --json --timeout 20s` | 0 | Repaired by killing active Xcode processes; selected `iPhone 17 Pro Max` simulator `DD9B9C84-7188-48FA-AA2A-AB5C1D0EE2B6` passed. |
| `scripts/ambitions-xcode-sim-health.sh --json --timeout 20s` | 0 | Final non-repair simulator preflight passed. |

## Validation Ceiling

No XCTest, App Intents Testing framework execution, UI test, xcodebuild build, terminated-app invocation, Siri/Shortcuts transcript, or device proof was run under the current no-testing instruction.

## Validation Not Run

- Focused App Intent/command XCTest execution was not run under the current user instruction authorizing issue completion without testing until advised otherwise.
- LocalRuntimeProof was not run because no command execution behavior, receipt writer, or runtime mutation path changed; this slice adds an inventory/guard and evidence packet.
- xcodebuild package resolution, build, build-for-testing, and test were not run.
- App Intents Testing framework execution, Siri/Shortcuts transcript proof, terminated-app invocation, simulator app launch, and physical-device verification were not run.
- Privacy/legal review, release gate, TestFlight validation, App Store validation, and product readiness review were not run.

## Non-Claims

- No terminated-app App Intent invocation proof.
- No Siri or Shortcuts runtime transcript proof.
- No App Store/release proof.
- No privacy/legal approval claim.

## Architecture Closeout

- Final Architecture Tree inspected: yes.
- Canonical owners touched: `Core/LocalRuntimeOS/Commands`, focused app tests, and QA evidence.
- Files moved or created: this manifest, paired JSON evidence, `AppIntentCommandRoutingInventory.swift`, and `AppIntentCommandRoutingInventoryTests.swift`.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Yellow architecture/proof debt remains: yes. Runtime App Intents invocation, App Intents Testing framework proof, and terminated-app/device proof remain outside this no-testing source slice.
- Next repair train if debt remains: continue `AMB-1687` leaves for App Intents runtime invocation and command-route proof when testing/device proof is re-enabled.
- Confirmation: no equivalent-folder or alternate-path interpretation was used.
