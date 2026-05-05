# PFC03 Dead Code / Prompt Artifact / Naming Smell Audit Prompt
<!-- markdownlint-disable MD013 -->

Status: Queued Platform / Framework / Compliance batch; generated from the
PFC manifest because the global order selected PFC03 and no standalone prompt
previously existed.

## Batch Identity

- Batch ID: `PFC03`
- Name: Dead Code / Prompt Artifact / Naming Smell Audit
- Train: PFC Platform / Framework / Compliance
- Type: Audit/repair planning
- Owner: Maintainability

## Purpose

Identify likely dead files, prompt-built residue, stale names, duplicate model
risk, placeholder copy, and unexplained folders. PFC03 creates a cleanup queue
and ownership map only; it does not delete, rename, or rewrite source files.

## Source Truth

- `README.md`
- `AGENTS.md`
- `docs/canon/Ambitions_Codex_Quality_System.md`
- `docs/codex/CODEX_QUALITY_SYSTEM_GATE_MATRIX.md`
- `docs/codex/CODEX_QUALITY_SYSTEM_REPAIR_PROTOCOL.md`
- `docs/codex/CODEX_QUALITY_SYSTEM_SCRIPT_MAP.md`
- `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md`
- `docs/audits/pfc01-repo-build-system-inventory-report.md`
- `docs/audits/pfc02-architecture-boundary-module-map-report.md`
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

- PFC03 audit report.
- Prompt-artifact and naming-smell classification table.
- Cleanup queue with owners and proof required before deletion/rename.
- Explicit separation of legitimate placeholders/stubs from user-facing or
  release-handoff risk.
- Updated registry/context/run-state/global order after validation.

## Validation

- `git status --short`
- `git diff --check`
- touched-doc trailing whitespace scan
- `scripts/cqs-prompt-built-smell-scan.sh Native || true`
- `scripts/cqs-prompt-built-smell-scan.sh Sources || true`
- `scripts/cqs-product-drift-scan.sh Native || true`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

No build/test command is required unless PFC03 changes production code, which it
must not do.

## Green / Yellow / Red

Green: docs-only audit is complete, no forbidden files touched, findings are
classified, and no source deletion/rename is attempted without owner proof.

Yellow: legitimate stubs/placeholders, stale copy, compatibility naming, or
prompt-smell scan hits remain but are classified with owner and repair path.

Red: production source/config edits, deletion or rename without owner proof,
unsupported release/legal/security claim, or unresolved evidence that a finding
is user-facing dangerous and cannot be bounded in docs.

## Commit Message

`PFC03: Audit prompt artifacts naming smells`
