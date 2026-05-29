# PFC08 Corruption Recovery Backup Restore Plan Prompt

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches, stale_or_unknown_active_status
> Prior recommended actions: Expedite, Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-12077061, AMB28-same_source_file_targeted_by_multiple_active_batches-20949965, AMB28-same_source_file_targeted_by_multiple_active_batches-22647572, AMB28-same_source_file_targeted_by_multiple_active_batches-62616890, AMB28-same_source_file_targeted_by_multiple_active_batches-62818670, AMB28-same_source_file_targeted_by_multiple_active_batches-65376188, AMB28-same_source_file_targeted_by_multiple_active_batches-67521408, AMB28-same_source_file_targeted_by_multiple_active_batches-73720386, AMB28-same_source_file_targeted_by_multiple_active_batches-80144227, AMB28-same_source_file_targeted_by_multiple_active_batches-91043473, AMB28-same_surface_multiple_active_batches-13212827, AMB28-stale_or_unknown_active_status-59363950

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, status-expedite
> Dispositions: clarify-status-before-use, merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
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

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
