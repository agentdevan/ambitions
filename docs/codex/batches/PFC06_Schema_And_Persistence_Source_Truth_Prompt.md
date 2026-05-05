# PFC06 Schema And Persistence Source Truth Prompt
<!-- markdownlint-disable MD013 -->

Status: Complete / Green as docs-only persistence source truth.
Date: 2026-05-05
Train: PFC01-PFC40 Platform / Framework / Compliance Completion Train
Owner: Persistence

## Purpose

Run a docs-only persistence source-truth pass that maps the current local schema,
repository ownership, export/import package, sync posture, and migration risk
ledger before any persistence implementation or migration work starts.

This prompt does not authorize production Swift edits. It does not authorize
schema changes, data migration, CloudKit sync, account behavior, export/import
UI claims, privacy/legal claims, release claims, or app-store readiness claims.

## Source Truth

Read before execution:

- `README.md`
- `AGENTS.md`
- `docs/canon/Ambitions_Platform_Legal_And_Framework_Completion_Plan.md`
- `docs/canon/DATA_LOCAL_SYNC_EXPORT.md`
- `docs/canon/TRUST_PRIVACY_MEMORY.md`
- `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md`
- `docs/codex/CODEX_QUALITY_SYSTEM_REPAIR_PROTOCOL.md`
- `docs/codex/CODEX_QUALITY_SYSTEM_GATE_MATRIX.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/BATCH_REGISTRY.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

Inspect-only persistence files:

- `Native/Ambitions/Persistence/SwiftDataModels.swift`
- `Native/Ambitions/Persistence/SwiftDataStore.swift`
- `Native/Ambitions/Persistence/SwiftDataRepositories.swift`
- `Native/Ambitions/Persistence/PersistenceContracts.swift`
- `Native/Ambitions/Persistence/PortableSnapshotContracts.swift`
- `Native/Ambitions/Persistence/PortableSnapshotService.swift`
- `Native/Ambitions/Persistence/LegacyImportService.swift`
- `Native/Ambitions/Persistence/AppPreferencesStore.swift`
- `Native/Ambitions/Persistence/SyncCapabilityContracts.swift`
- `Native/Ambitions/ExternalSnapshots/**`
- `Native/AmbitionsTests/Persistence/**`

## Allowed Files

- `docs/codex/batches/PFC06_Schema_And_Persistence_Source_Truth_Prompt.md`
- `docs/audits/pfc06-schema-persistence-source-truth-report.md`
- `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

## Forbidden Files

- Production Swift source files under `Native/Ambitions/**`.
- Tests under `Native/AmbitionsTests/**`.
- `project.yml`, `Package.swift`, generated projects, workflows, entitlements,
  privacy manifests, lockfiles, signing files, and dependency manifests.
- Any persistence schema or migration implementation file.

## Required Tasks

1. Inventory SwiftData models and their repository owners.
2. Identify local persistence store construction and reset behavior.
3. Identify portable export/import package shape and tested safety behavior.
4. Identify legacy import compatibility ownership.
5. Identify current sync posture and no-claim boundary.
6. Identify sensitive categories and privacy/export/delete posture.
7. Produce a migration risk ledger for PFC07/PFC08/PFC09/PFC12/PFC24/PFC25.
8. Update train state so PFC07 is next only after PFC06 closes Green or accepted
   Yellow.

## Required Validation

Run:

- `git status --short`
- `git diff --check`
- touched-doc trailing whitespace scan
- `scripts/cqs-privacy-security-claim-scan.sh <touched PFC06 docs> || true`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

Do not run build/test unless production Swift, tests, project generation, or
dependency files are changed. PFC06 should not change those files.

## Closeout

Close Green or accepted Yellow only if:

- The schema/source-truth map is evidence-bound to existing files.
- Migration/export/delete/sync/privacy gaps are Yellow-owned by future PFC
  batches.
- No production Swift, schema, workflow, project, dependency, signing, or
  privacy manifest file is changed.
- No unsupported sync, export UI, delete-all-memory UI, legal, release,
  App Store, TestFlight, device, or public accessibility claim is made.
