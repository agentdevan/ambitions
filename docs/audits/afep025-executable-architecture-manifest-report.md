# AFEP-025 Executable Architecture Manifest Report

Issue: `AMB-419`
Batch: `AFEP-025`
Date: 2026-06-01

## Result

This batch adds a governance-only, machine-readable architecture manifest for AFEP. It is subordinate to `docs/truth/*`, live source, and current proof evidence and does not change runtime behavior.

## What Was Added

- `docs/codex/AFEP_EXECUTABLE_ARCHITECTURE_MANIFEST.json`
- `scripts/afep025_architecture_manifest_validate.py`
- `fixtures/afep025/`

## Governance Boundaries

- Canonical IA remains `Today / Goals / Capture / Time / You`.
- `Plan` is rejected as a top-level destination.
- CloudKit remains optional continuity only and is not a source of truth.
- Core architecture does not require a cloud LLM or hosted personal-data backend.
- Analytics or telemetry SDK introduction is forbidden without explicit approval.
- Local validation is not release proof, device proof, accessibility proof, privacy proof, CI proof, or production proof.

## Artifact Classes

The manifest classifies material as:

- active
- supporting
- deprecated
- archived
- historical
- generated
- local-only
- proof-only

## Provenance Concepts

The manifest treats these as provenance or inspection concepts only:

- `SourceRecord`
- `Receipt`
- `ReplayTrace`
- `You / What Ambitions knows`

## Validation Results

- `python3 scripts/afep025_architecture_manifest_validate.py --self-test` -> passed
- `python3 scripts/afep025_architecture_manifest_validate.py --manifest docs/codex/AFEP_EXECUTABLE_ARCHITECTURE_MANIFEST.json --fixtures fixtures/afep025` -> passed
- `python3 scripts/ambitions-champion-coverage-check.py --batch AFEP-025` -> passed
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AFEP-025 --prompt prompts/batches/AFEP-025.md --batch-type source-changing` -> passed
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AFEP-025 --prompt prompts/batches/AFEP-025.md --changed-from ac1daabcb7034e8caae65f130c5714dc0ac29ab8 --batch-type source-changing` -> passed
- `python3 tools/mcp/ambitions_repo_mcp/server.py --self-test` -> passed
- `git diff --check` -> passed

## Claims Allowed

- Governance and routing are now machine-readable.
- The manifest is deterministic and repo-local.
- The validator catches the required drift cases.

## Claims Not Allowed

- Release proof
- Runtime behavior change
- Production readiness
- Accessibility proof
- Privacy/legal approval
- CI proof
