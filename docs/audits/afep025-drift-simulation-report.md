# AFEP-025 Drift Simulation Report

Issue: `AMB-419`
Batch: `AFEP-025`
Date: 2026-06-01

## Result

The drift simulation fixtures demonstrate that the manifest validator rejects the approved failure modes instead of silently accepting them.

## Simulated Drift Fixtures

- `fixtures/afep025/top-level-plan.json`
- `fixtures/afep025/required-core-llm.json`
- `fixtures/afep025/hosted-backend-launch.json`
- Forbidden drift fixture: `fixtures/afep025/analytics-sdk.json`
- `fixtures/afep025/cloudkit-source-of-truth.json`
- `fixtures/afep025/release-claim-without-proof.json`
- `fixtures/afep025/privacy-boundary-drift.json`

## Simulation Outcome

Each fixture fails for the intended reason and keeps the manifest subordinate to the active truth files and current proof evidence.

## Validation Results

- `python3 scripts/afep025_architecture_manifest_validate.py --manifest docs/codex/AFEP_EXECUTABLE_ARCHITECTURE_MANIFEST.json --fixtures fixtures/afep025` -> passed
- `python3 scripts/ambitions-unsupported-claim-scan.py docs/audits/afep025-executable-architecture-manifest-report.md docs/audits/afep025-architecture-validator-report.md docs/audits/afep025-drift-simulation-report.md docs/audits/afep025-rollback-to-narrative-governance.md` -> passed
- `bash scripts/codex-forbidden-claim-scan.sh docs/audits/afep025-executable-architecture-manifest-report.md docs/audits/afep025-architecture-validator-report.md docs/audits/afep025-drift-simulation-report.md docs/audits/afep025-rollback-to-narrative-governance.md` -> passed

## Boundary

This is a governance drift simulation only. It does not establish runtime proof or release proof.
