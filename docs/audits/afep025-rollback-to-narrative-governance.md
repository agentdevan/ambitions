# AFEP-025 Rollback to Narrative Governance

Issue: `AMB-419`
Batch: `AFEP-025`
Date: 2026-06-01

## Rollback Goal

Return to narrative governance if the AFEP-025 validator or fixture set becomes unstable, noisy, or unnecessary.

## Exact Removal Steps

1. Remove `docs/codex/AFEP_EXECUTABLE_ARCHITECTURE_MANIFEST.json`.
2. Remove `scripts/afep025_architecture_manifest_validate.py`.
3. Remove `fixtures/afep025/`.
4. Remove the AFEP-025 audit reports:
   - `docs/audits/afep025-executable-architecture-manifest-report.md`
   - `docs/audits/afep025-architecture-validator-report.md`
   - `docs/audits/afep025-drift-simulation-report.md`
   - `docs/audits/afep025-rollback-to-narrative-governance.md`
5. Re-run claim scans and `git diff --check`.

## Narrative Governance Path

Keep `docs/truth/*`, `AGENTS.md`, `README.md`, `docs/README.md`, `project.yml`, and `Package.swift` as the active authority chain.

## Boundary

This fallback restores human-readable governance. It does not remove or alter runtime code, and it does not claim release readiness.
