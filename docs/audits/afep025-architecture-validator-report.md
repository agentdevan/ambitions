# AFEP-025 Architecture Validator Report

Issue: `AMB-419`
Batch: `AFEP-025`
Date: 2026-06-01

## Result

The AFEP-025 validator checks the executable architecture manifest and explicit drift fixtures without elevating the manifest above `docs/truth/*`, live source, or current proof evidence.

## Validator Contract

- Default manifest path: `docs/codex/AFEP_EXECUTABLE_ARCHITECTURE_MANIFEST.json`
- Default fixture directory: `fixtures/afep025/`
- Standard library only
- Deterministic, repo-relative validation
- Explicit pass and fail fixture handling

## Drift Cases Covered

- top-level `Plan` reintroduction
- required cloud or core LLM dependency
- hosted backend launch requirement is forbidden
- analytics or telemetry SDK without explicit approval is forbidden
- CloudKit treated as source of truth
- release or readiness claims without proof
- privacy boundary drift

## Validation Results

- `python3 scripts/afep025_architecture_manifest_validate.py --self-test` -> passed
- `python3 scripts/afep025_architecture_manifest_validate.py --manifest docs/codex/AFEP_EXECUTABLE_ARCHITECTURE_MANIFEST.json --fixtures fixtures/afep025` -> passed
- `python3 scripts/ambitions-unsupported-claim-scan.py docs/audits/afep025-executable-architecture-manifest-report.md docs/audits/afep025-architecture-validator-report.md docs/audits/afep025-drift-simulation-report.md docs/audits/afep025-rollback-to-narrative-governance.md` -> passed
- `bash scripts/codex-forbidden-claim-scan.sh docs/audits/afep025-executable-architecture-manifest-report.md docs/audits/afep025-architecture-validator-report.md docs/audits/afep025-drift-simulation-report.md docs/audits/afep025-rollback-to-narrative-governance.md` -> passed

## Boundary

The validator is governance tooling only. It is not proof of runtime behavior, release readiness, device readiness, accessibility readiness, privacy/legal approval, or production readiness.
