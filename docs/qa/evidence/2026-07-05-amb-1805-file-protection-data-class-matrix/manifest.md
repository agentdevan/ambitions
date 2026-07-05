# AMB-1805 File Protection Data-Class Matrix

Status: Implemented Yellow
Date: 2026-07-05T20:42:09Z
Branch: `main`
Baseline main SHA: `6df764f0112284cb13d6d1553c9dd2369ac794ad`
Commit SHA: artifact commit SHA is recorded in Linear after commit/push
Environment: local Codex macOS workspace at `/Users/devan/Documents/GitHub/ambitions`
Xcode version: Xcode 26.6, build version 17F113
Simulator or device: simulator health only; no app launch, locked-device procedure, local-auth prompt, file-protection runtime probe, or physical-device procedure was run
Exit code(s): listed in Validation Run below
Artifact paths: this manifest and `docs/qa/evidence/2026-07-05-amb-1805-file-protection-data-class-matrix/file-protection-data-class-matrix.json`
Parent: `AMB-1684` Parent Feature - File Protection and Local Authentication Proof
Issue: `AMB-1805` File Protection Leaf - Data-class protection matrix

## Scope

- Added a PrivacySecurity-owned matrix for private runtime artifacts, public reference cache, App Group snapshots, portable exports, and diagnostics bundles.
- Mapped each data class to runtime/storage privacy class, destinations, surfaces, required file-protection level, local-auth expectation, encrypted-vault expectation, review expectation, redaction boundary, and proof ceiling.
- Added a focused invariant that ties the matrix to `FileProtectionPolicy`, `LocalAuthGate`, `SensitiveSurfacePolicy`, and the concrete `AppGroupSnapshotStore` file-protection constant.

## Evidence

- Source matrix: `Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/DataClassProtectionMatrix.swift`.
- Focused invariant: `Native/AmbitionsTests/LocalRuntimeOS/PrivacySecurity/DataClassProtectionMatrixTests.swift`.
- Existing policy source: `FileProtectionPolicy.swift`, `LocalAuthGate.swift`, `SensitiveSurfacePolicy.swift`, and `AppGroupSnapshotStore.swift`.

## Validation Run

- `xcodegen generate` -> exit 0.
- `scripts/ambitions-xcodegen-needed.sh` -> exit 0; `XCODEGEN_NEEDED=0`.
- `python3 -m json.tool docs/qa/evidence/2026-07-05-amb-1805-file-protection-data-class-matrix/file-protection-data-class-matrix.json` -> exit 0.
- `swiftc -parse Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/DataClassProtectionMatrix.swift Native/AmbitionsTests/LocalRuntimeOS/PrivacySecurity/DataClassProtectionMatrixTests.swift` -> exit 0.
- `git diff --check` -> exit 0.
- `python3 scripts/ambitions-remediation-governance-check.py` -> initial exit 1 for `[source-atlas-growth-adr]` on the new production file; repaired by removing new Source Atlas-specific production scope from this slice.
- `python3 scripts/ambitions-remediation-governance-check.py` -> final exit 0; `GREEN remediation governance guard passed`.
- `python3 scripts/ambitions-quality-gate.py` -> exit 0; `GREEN all strict quality gates passed`.
- `python3 scripts/ambitions-architecture-inventory.py` -> exit 0; `GREEN final-tree parity achieved`.
- `python3 scripts/ambitions-green-standard-audit.py` -> exit 0.
- `python3 scripts/ambitions-vocabulary-drift-scan.py` -> exit 0.
- `python3 scripts/ambitions-local-first-boundary-scan.py` -> exit 0.
- `scripts/no-unsupported-ai-claim-scan.sh Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/DataClassProtectionMatrix.swift Native/AmbitionsTests/LocalRuntimeOS/PrivacySecurity/DataClassProtectionMatrixTests.swift docs/qa/evidence/2026-07-05-amb-1805-file-protection-data-class-matrix/manifest.md docs/qa/evidence/2026-07-05-amb-1805-file-protection-data-class-matrix/file-protection-data-class-matrix.json` -> exit 0 with existing Yellow advisory in `docs/truth/PRODUCT_EXPERIENCE_CANON.md:66`, outside this AMB-1805 diff.
- `scripts/ambitions-xcode-sim-health.sh --json --timeout 20s` -> initial exit 25; `failure_category=xcode_process_active`.
- `scripts/ambitions-xcode-sim-health.sh --repair --kill-active-xcode --json --timeout 20s` -> exit 0; repair cleared blocking Xcode processes.
- `scripts/ambitions-xcode-sim-health.sh --json --timeout 20s` -> final exit 0; simulator health passed for `iPhone 17 Pro Max` (`DD9B9C84-7188-48FA-AA2A-AB5C1D0EE2B6`).

## Validation Ceiling

No XCTest, xcodebuild build, locked-device file-protection procedure, local-auth prompt, runtime file-protection probe, privacy/legal review, or physical-device proof was run under the current no-testing instruction.

## Validation Not Run

- Focused PrivacySecurity/Storage XCTest execution was not run under the current user instruction authorizing issue completion without testing until advised otherwise.
- LocalRuntimeProof was not run because this slice adds a source matrix and invariant only; no command execution behavior, receipt writer, or runtime mutation path changed.
- xcodebuild package resolution, build, build-for-testing, and test were not run.
- Locked-device behavior, local-auth prompt behavior, runtime file-protection attributes, simulator app launch, and physical-device verification were not run.
- Privacy/legal review, release gate, TestFlight validation, App Store validation, and product readiness review were not run.

## Non-Claims

- No physical-device file-protection proof.
- No local-auth prompt proof.
- No locked-device behavior proof.
- No privacy/legal approval claim.
- No App Store/release proof.

## Architecture Closeout

- Final Architecture Tree inspected: yes.
- Canonical owners touched: `Core/LocalRuntimeOS/PrivacySecurity`, focused LocalRuntimeOS privacy tests, and QA evidence.
- Files moved or created: this manifest, paired JSON evidence, `DataClassProtectionMatrix.swift`, and `DataClassProtectionMatrixTests.swift`.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Yellow architecture/proof debt remains: yes. This is source-invariant proof only; Source Atlas-specific production scope remains gated by the Source Atlas ADR allowlist, and locked-device, local-auth prompt, runtime file-protection, privacy/legal, and release proof remain outside this no-testing slice.
- Next repair train if debt remains: continue `AMB-1684` leaves for runtime file-protection and local-auth device proof when testing/device proof is re-enabled.
- Confirmation: no equivalent-folder or alternate-path interpretation was used.
