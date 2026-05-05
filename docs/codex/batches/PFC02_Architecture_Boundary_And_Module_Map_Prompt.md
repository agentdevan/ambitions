# PFC02 Architecture Boundary And Module Map Prompt
<!-- markdownlint-disable MD013 -->

Status: Queued Platform / Framework / Compliance batch; generated from the
PFC manifest because the global order selected PFC02 and no standalone prompt
previously existed.

## Batch Identity

- Batch ID: `PFC02`
- Name: Architecture Boundary And Module Map
- Train: PFC Platform / Framework / Compliance
- Type: Docs/audit
- Owner: Architecture

## Purpose

Map feature, domain, service, shared package, test, preview, app, extension,
runtime, persistence, and integration boundaries. Identify boundary risks,
large-file risks, and extraction queues without changing app code.

## Source Truth

- `README.md`
- `AGENTS.md`
- `docs/canon/Ambitions_Beyond_3_0_Maintainability_Extraction_Plan.md`
- `docs/audits/me12-maintainability-handoff-report.md`
- `docs/audits/pfc01-repo-build-system-inventory-report.md`
- `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md`
- `docs/codex/CODEX_QUALITY_SYSTEM_GATE_MATRIX.md`
- `docs/codex/CODEX_QUALITY_SYSTEM_REPAIR_PROTOCOL.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

## Allowed Files

- `docs/audits/**`
- `docs/codex/**`
- `.codex/reports/**`

## Forbidden Files

- `Native/**`
- `Sources/**`
- `AppUI/**`
- `.github/workflows/**`
- `project.yml`
- `Package.swift`
- lockfiles
- signing, entitlement, provisioning, workflow, dependency, generated build, and
  Xcode project files

## Required Deliverables

- PFC02 architecture boundary audit report.
- Module/ownership map.
- Boundary risk table.
- Extraction and repair queue for PFC03/PFC05/FCP/AOS owner batches.
- Updated registry/context/run-state/global order after validation.

## Validation

- `git status --short`
- `git diff --check`
- touched-doc trailing whitespace scan
- `scripts/cqs-architecture-boundary-scan.sh Native/Ambitions Sources AppUI/Sources Native/AmbitionsTests || true`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

No build/test command is required unless PFC02 changes production code, which it
must not do.

## Green / Yellow / Red

Green: docs-only boundary map is complete, no forbidden files touched, boundary
risks are owned, and PFC03 is named as next eligible batch.

Yellow: existing large files, known boundary advisories, or generated/prompt
artifact risks are documented with future owners.

Red: production source/config edits, route/raw-value change, dependency/workflow
change, or unresolved architecture contradiction requiring code changes in this
batch.

## Commit Message

`PFC02: Map architecture boundaries`
