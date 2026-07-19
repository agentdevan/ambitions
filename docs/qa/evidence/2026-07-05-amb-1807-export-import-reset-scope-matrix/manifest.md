# AMB-1807 Export Import Reset Scope Matrix

Status: Implemented Yellow
Date: 2026-07-05T20:20:43Z
Branch: `main`
Baseline main SHA: `9de167657f1198627836630f4dd29a15bc962d05`
Commit SHA: artifact commit SHA is recorded in Linear after commit/push
Environment: local Codex macOS workspace at `/Users/devan/Documents/GitHub/ambitions`
Xcode version: Xcode 26.6, build version 17F113
Simulator or device: simulator health only; no app launch, import execution, reset execution, restore execution, or physical-device procedure was run
Exit code(s): listed in Validation Run below
Artifact paths: this manifest and `docs/qa/evidence/2026-07-05-amb-1807-export-import-reset-scope-matrix/export-import-reset-scope-matrix.json`
Parent: `AMB-1686` Parent Feature - Export/Import/Reset Data Scope
Issue: `AMB-1807` Export Import Reset Leaf - Data-scope and reset semantics audit

## Scope

- Added a source-backed export/import/reset data-scope matrix under `Core/LocalRuntimeOS/Repair`.
- Covered the six current portable export categories: goals and plans, captures, proof, receipts, memory, and settings.
- Recorded explicit exclusions for raw calendar events, cloud/account data, and rendered widget or Live Activity state.
- Added a focused invariant that ties the matrix back to `PortableExportCategory`, `PortableExportManifest`, and current import/reset mode semantics.

## Evidence

- Source matrix: `Native/Ambitions/Core/LocalRuntimeOS/Repair/ExportImportResetDataScopeMatrix.swift`.
- Focused invariant: `Native/AmbitionsTests/LocalRuntimeOS/Repair/ExportImportResetDataScopeMatrixTests.swift`.
- Source export contracts: `Native/Ambitions/Core/LocalRuntimeOS/Repair/PortableSnapshotContracts.swift`.
- Source import/reset contracts: `Native/Ambitions/Core/LocalRuntimeOS/Repair/PortableSnapshotServiceOperations.swift`.
- Dry-run reset review source: `Native/Ambitions/Core/LocalRuntimeOS/Repair/DryRunMigration.swift`.

## Validation Run

Completed for this packet:

| Command | Exit code | Result |
| --- | ---: | --- |
| `xcodegen generate` | 0 | Project regenerated. |
| `scripts/ambitions-xcodegen-needed.sh` | 0 | `XCODEGEN_NEEDED=0`; project build inputs unchanged. |
| `python3 -m json.tool docs/qa/evidence/2026-07-05-amb-1807-export-import-reset-scope-matrix/export-import-reset-scope-matrix.json` | 0 | JSON evidence parsed. |
| `swiftc -parse Native/Ambitions/Core/LocalRuntimeOS/Repair/ExportImportResetDataScopeMatrix.swift Native/AmbitionsTests/LocalRuntimeOS/Repair/ExportImportResetDataScopeMatrixTests.swift` | 0 | Swift parser accepted the matrix and focused assertions; no XCTest execution. |
| `git diff --check` | 0 | Passed after source/evidence edits. |
| `python3 scripts/ambitions-remediation-governance-check.py` | 0 | Passed; `changed_paths=4`, `production_swift_files=1426`, `overHardLineCapFiles=0`. |
| `python3 scripts/ambitions-quality-gate.py` | 1 | Initial strict quality gate found one hosted-backend boundary phrase in the new matrix text. |
| `python3 scripts/ambitions-quality-gate.py` | 0 | Passed after removing the hosted-backend boundary phrase from source/evidence. |
| `python3 scripts/ambitions-architecture-inventory.py` | 0 | Passed; final-tree parity achieved. |
| `python3 scripts/ambitions-green-standard-audit.py` | 0 | Passed; no disallowed architecture-as-UI strings found in active primary UI source. |
| `python3 scripts/ambitions-vocabulary-drift-scan.py` | 0 | Passed; canonical active vocabulary present and ban terms absent. |
| `python3 scripts/ambitions-local-first-boundary-scan.py` | 0 | Passed; local-first/account/R2/hosted-AI boundary checks passed in active authority files. |
| `scripts/no-unsupported-ai-claim-scan.sh ...` | 0 | Advisory Yellow only; hit existing `docs/truth/PRODUCT_EXPERIENCE_CANON.md` wording outside this AMB-1807 diff and was reviewed as non-claim context. |
| `scripts/ambitions-xcode-sim-health.sh --json --timeout 20s` | 25 | Initial simulator preflight failed because active Xcode processes were blocking the check. |
| `scripts/ambitions-xcode-sim-health.sh --repair --kill-active-xcode --json --timeout 20s` | 0 | Repaired by killing active Xcode processes; selected `iPhone 17 Pro Max` simulator `DD9B9C84-7188-48FA-AA2A-AB5C1D0EE2B6` passed. |
| `scripts/ambitions-xcode-sim-health.sh --json --timeout 20s` | 0 | Final non-repair simulator preflight passed. |

## Validation Ceiling

No XCTest, import execution, reset execution, restore execution, xcodebuild build, simulator app launch, or device proof was run under the current no-testing instruction.

## Validation Not Run

- Focused export/import/reset XCTest execution was not run under the current user instruction authorizing issue completion without testing until advised otherwise.
- LocalRuntimeProof was not run because this slice adds a source matrix and invariant only; no command execution behavior, receipt writer, or runtime mutation path changed.
- xcodebuild package resolution, build, build-for-testing, and test were not run.
- Import execution, reset execution, restore execution, destructive migration procedure, simulator app launch, and physical-device verification were not run.
- Privacy/legal review, release gate, TestFlight validation, App Store validation, and product readiness review were not run.

## Non-Claims

- No destructive migration or restore readiness proof.
- No data-loss-proof import claim.
- No privacy/legal approval claim.
- No device proof.
- No App Store/release proof.

## Architecture Closeout

- Final Architecture Tree inspected: yes.
- Canonical owners touched: `Core/LocalRuntimeOS/Repair`, focused LocalRuntimeOS repair tests, and QA evidence.
- Files moved or created: this manifest, paired JSON evidence, `ExportImportResetDataScopeMatrix.swift`, and `ExportImportResetDataScopeMatrixTests.swift`.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Yellow architecture/proof debt remains: yes. This is source-invariant proof only; destructive restore/reset, import execution, device, privacy/legal, and release proof remain outside this no-testing slice.
- Next repair train if debt remains: continue `AMB-1686` leaves for executable import/reset/restore scenarios when testing or device proof is re-enabled.
- Confirmation: no equivalent-folder or alternate-path interpretation was used.
