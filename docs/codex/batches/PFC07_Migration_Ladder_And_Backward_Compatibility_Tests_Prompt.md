# PFC07 Migration Ladder And Backward Compatibility Tests Prompt
<!-- markdownlint-disable MD013 -->

Status: Complete / Green as focused persistence compatibility proof.
Date: 2026-05-05
Train: PFC01-PFC40 Platform / Framework / Compliance Completion Train
Owner: Persistence

## Purpose

Run the migration and backward-compatibility proof batch after PFC06 mapped the
current persistence source truth. PFC07 must prove the current local-only schema
boundary, legacy import behavior, portable snapshot package behavior, and
explicit no-sync posture with existing or added tests.

PFC07 does not authorize broad schema redesign, destructive data reset behavior,
CloudKit/server/account sync, production migration claims, export/import UI
claims, privacy/legal compliance claims, App Store/TestFlight/release claims, or
physical-device/public accessibility claims.

## Source Truth

Read before execution:

- `docs/audits/pfc06-schema-persistence-source-truth-report.md`
- `docs/codex/batches/PFC06_Schema_And_Persistence_Source_Truth_Prompt.md`
- `docs/canon/DATA_LOCAL_SYNC_EXPORT.md`
- `docs/canon/TRUST_PRIVACY_MEMORY.md`
- `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md`
- `docs/codex/CODEX_QUALITY_SYSTEM_REPAIR_PROTOCOL.md`
- `docs/codex/CODEX_QUALITY_SYSTEM_GATE_MATRIX.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

Inspect or test:

- `Native/Ambitions/Persistence/SwiftDataModels.swift`
- `Native/Ambitions/Persistence/SwiftDataStore.swift`
- `Native/Ambitions/Persistence/SwiftDataRepositories.swift`
- `Native/Ambitions/Persistence/PortableSnapshotContracts.swift`
- `Native/Ambitions/Persistence/PortableSnapshotService.swift`
- `Native/Ambitions/Persistence/LegacyImportService.swift`
- `Native/Ambitions/Persistence/SyncCapabilityContracts.swift`
- `Native/AmbitionsTests/Persistence/PersistenceRepositoryTests.swift`
- `Native/AmbitionsTests/Persistence/PortableSnapshotServiceTests.swift`
- `Native/AmbitionsTests/Persistence/LegacyImportServiceTests.swift`
- `Native/AmbitionsTests/Persistence/SyncCapabilityTests.swift`

## Allowed Files

PFC07 may edit tests only if the existing focused persistence suite does not
prove the current compatibility boundary. This completed pass found sufficient
existing test proof, so it changed docs and train-state files only:

- `docs/codex/batches/PFC07_Migration_Ladder_And_Backward_Compatibility_Tests_Prompt.md`
- `docs/audits/pfc07-migration-ladder-backward-compatibility-tests-report.md`
- `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

## Forbidden Files

- Production persistence schema/source unless a test proves a PFC07-caused
  compatibility failure and the repair is narrow.
- CloudKit, account, sync, network, auth, AI/LDI runtime, workflows, signing,
  entitlements, privacy manifests, project files, lockfiles, dependencies, or
  generated files.
- User-facing export/import/delete-all-memory UI surfaces.

## Required Tasks

1. Confirm whether explicit SwiftData migration plans currently exist.
2. Confirm whether current schema changes are being made by PFC07.
3. Prove repository round-trips for current durable model categories.
4. Prove legacy import mapping for preserved prototype payloads.
5. Prove portable snapshot version rejection, legacy package decoding, malformed
   payload safety, conflict reporting, and disaster-drill restore.
6. Prove sync remains explicit local-only/unavailable.
7. Document which future batches own real migration ladders and destructive
   recovery behavior.

## Required Validation

Run:

- `xcodegen generate`
- focused `xcodebuild` persistence tests:
  - `AmbitionsTests/PersistenceRepositoryTests`
  - `AmbitionsTests/PortableSnapshotServiceTests`
  - `AmbitionsTests/LegacyImportServiceTests`
  - `AmbitionsTests/SyncCapabilityTests`
- `git status --short`
- `git diff --check`
- touched-doc trailing whitespace scan
- `scripts/cqs-privacy-security-claim-scan.sh <touched PFC07 docs> || true`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

## Closeout

Close Green only if focused persistence tests pass and no production schema
change is made. Close accepted Yellow if the focused tests pass but future
production-store migration, physical-device restore, user-facing export/import,
or destructive-action proof remains owned by later PFC batches.
