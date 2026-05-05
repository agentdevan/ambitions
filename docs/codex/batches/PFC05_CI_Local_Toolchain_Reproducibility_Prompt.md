# PFC05 CI / Local Toolchain Reproducibility Prompt
<!-- markdownlint-disable MD013 -->

Status: Queued Platform / Framework / Compliance batch; generated from the
PFC manifest because the global order selected PFC05 and no standalone prompt
previously existed.

## Batch Identity

- Batch ID: `PFC05`
- Name: CI / Local Toolchain Reproducibility
- Train: PFC Platform / Framework / Compliance
- Type: Implementation/docs
- Owner: Build / CI

## Purpose

Make local validation order more reproducible and evidence-producing without
changing GitHub Actions, project generation, dependencies, signing, or app code.
PFC05 may add or update local scripts and docs only.

## Source Truth

- `README.md`
- `AGENTS.md`
- `scripts/validate-dev-tools.sh`
- `scripts/build-local.sh`
- `scripts/test-local.sh`
- `scripts/run-doc-qa.sh`
- `scripts/batch-train-gate-check.sh`
- `.github/workflows/ios-validate.yml`
- `docs/codex/MAC_CODEX_5_5_TOOLCHAIN_SETUP.md`
- `docs/canon/Ambitions_3_0_Local_Toolchain_Readiness_Matrix.md`
- `docs/audits/pfc01-repo-build-system-inventory-report.md`
- `docs/audits/pfc04-dependency-supply-chain-policy-report.md`
- `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md`
- `docs/codex/CODEX_QUALITY_SYSTEM_REPAIR_PROTOCOL.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

## Allowed Files

- `scripts/ci-local-parity.sh`
- `docs/audits/**`
- `docs/codex/**`
- `docs/canon/Ambitions_3_0_Local_Toolchain_Readiness_Matrix.md`
- `.codex/reports/**`

## Forbidden Files

- `Native/**`
- `Sources/**`
- `AppUI/**`
- `.github/workflows/**`
- `project.yml`
- `Package.swift`
- `Brewfile`
- `Brewfile.optional-later`
- lockfiles
- signing, entitlement, provisioning, dependency, generated build, and Xcode
  project files

## Required Deliverables

- Local CI parity wrapper or documented equivalent.
- Toolchain setup/runbook update.
- PFC05 audit report with validation evidence.
- Updated registry/context/run-state/global order after validation.

## Validation

- `git status --short`
- `git diff --check`
- touched-doc trailing whitespace scan
- `bash -n scripts/ci-local-parity.sh`
- `RUN_DOC_QA=0 RUN_GATE=0 scripts/ci-local-parity.sh`
- `scripts/validate-dev-tools.sh || true`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

Run `scripts/build-local.sh` only if the batch changes build behavior. PFC05's
parity wrapper may keep native build/test lanes opt-in to avoid turning known UI
smoke debt into a false hard stop.

## Green / Yellow / Red

Green: local reproducibility script/docs are complete, safe by default, validated
for syntax and non-mutating dry run, and no forbidden files are touched.

Yellow: optional tools, unpinned CI/Homebrew versions, doc-QA advisory backlog,
or opt-in build/test lanes remain documented with owner and repair path.

Red: workflow/project/dependency/signing/app source edits, generated output
staged, wrapper deletes or mutates production files unexpectedly, or validation
cannot establish script safety.

## Commit Message

`PFC05: Add local CI parity wrapper`
