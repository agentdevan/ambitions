# PFC01 Repo And Build System Inventory Prompt
<!-- markdownlint-disable MD013 -->

Status: Queued Platform / Framework / Compliance batch; generated from the
PFC manifest because the global order selected PFC01 and no standalone prompt
previously existed.

## Batch Identity

- Batch ID: `PFC01`
- Name: Repo And Build System Inventory
- Train: PFC Platform / Framework / Compliance
- Type: Audit/docs
- Owner: Platform / Build

## Purpose

Inventory repo layout, build system, project generation, scripts, workflows,
generated files, dependencies, local setup, and handoff docs. Produce a
repo/build cleanliness scorecard and repair map without changing app code.

## Source Truth

- `README.md`
- `AGENTS.md`
- `docs/native-build-and-release.md`
- `docs/canon/Ambitions_Platform_Legal_And_Framework_Completion_Plan.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`
- `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md`
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

- PFC01 audit report.
- Repo/build inventory.
- Cleanliness scorecard.
- Repair map for PFC02-PFC05.
- Updated registry/context/run-state/global order after validation.

## Validation

- `git status --short`
- `git diff --check`
- touched-doc trailing whitespace scan
- `scripts/validate-dev-tools.sh || true`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

No build/test command is required unless PFC01 changes production code, which it
must not do.

## Green / Yellow / Red

Green: docs-only inventory is complete, no forbidden files touched, validation
is adequate for audit scope, and PFC02 is named as next eligible batch.

Yellow: advisory backlog or missing optional local tools is documented with a
future owner and does not block audit closeout.

Red: production source/config/workflow/dependency edits, unsupported
release/platform claim, unresolved dirty tree, or inability to determine the
build-system source of truth.

## Commit Message

`PFC01: Inventory repo build system`
