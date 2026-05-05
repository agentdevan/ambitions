# PFC08 Corruption Recovery Backup Restore Plan Prompt
<!-- markdownlint-disable MD013 -->

Status: Complete / Green as docs-only recovery plan and evidence boundary.
Date: 2026-05-05
Train: PFC01-PFC40 Platform / Framework / Compliance Completion Train
Owner: Persistence / Reliability

## Purpose

Define Ambitions' current corruption, backup, restore, and user-visible recovery
boundary after PFC06/PFC07 established local persistence and compatibility proof.

PFC08 is a docs/reliability batch. It does not implement product UI, change
schema, alter destructive store reset behavior, add CloudKit/account sync, add
backup automation, or claim release/legal/App Store/TestFlight/device readiness.

## Source Truth

Read before execution:

- `docs/audits/pfc06-schema-persistence-source-truth-report.md`
- `docs/audits/pfc07-migration-ladder-backward-compatibility-tests-report.md`
- `docs/canon/DATA_LOCAL_SYNC_EXPORT.md`
- `docs/canon/TRUST_PRIVACY_MEMORY.md`
- `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md`
- `docs/codex/CODEX_QUALITY_SYSTEM_REPAIR_PROTOCOL.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

Inspect-only files:

- `Native/Ambitions/Persistence/SwiftDataStore.swift`
- `Native/Ambitions/Persistence/PortableSnapshotContracts.swift`
- `Native/Ambitions/Persistence/PortableSnapshotService.swift`
- `Native/Ambitions/Persistence/LegacyImportService.swift`
- `Native/Ambitions/Persistence/SyncCapabilityContracts.swift`
- `Native/AmbitionsTests/Persistence/PortableSnapshotServiceTests.swift`
- `Native/AmbitionsTests/Persistence/PersistenceRepositoryTests.swift`
- `Native/Ambitions/Features/Profile/**`

## Allowed Files

- `docs/codex/batches/PFC08_Corruption_Recovery_Backup_Restore_Plan_Prompt.md`
- `docs/audits/pfc08-corruption-recovery-backup-restore-plan-report.md`
- `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

## Forbidden Files

- Production Swift, tests, schema, migrations, workflows, project files,
  generated files, signing, entitlements, privacy manifests, dependency files,
  CloudKit/account/sync runtime, AI/LDI runtime, and user-facing recovery UI.

## Required Tasks

1. Inventory current recovery evidence.
2. Separate technical store reset from user-facing delete-all-memory.
3. Define corruption and recovery scenarios.
4. Define safe user-facing copy patterns without shame, fake success, or fake
   sync/backup claims.
5. Define future owner batches for export/import UI, destructive confirmation,
   production-store migration proof, App Group/external-surface recovery, and
   real-device backup validation.
6. Record stop conditions for future implementation.

## Required Validation

Run:

- `git status --short`
- `git diff --check`
- touched-doc trailing whitespace scan
- `scripts/cqs-privacy-security-claim-scan.sh <touched PFC08 docs> || true`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

Focused persistence tests may be referenced from PFC07. Re-run only if PFC08
changes production Swift, tests, schema, project generation, or recovery code.

## Closeout

Close Green only if recovery boundaries are explicit, no unsupported backup/sync
claim is made, destructive behavior remains confirmation-gated for future
implementation, and no production code or schema changes are made.
