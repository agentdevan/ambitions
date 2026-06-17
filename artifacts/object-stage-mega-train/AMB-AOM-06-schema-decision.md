# AMB-AOM-06 — Schema Decision

## Objective
- Confirm whether `object-stage` migration needs SwiftData schema changes for Stage/Capture/Motion/trust runtime behavior.

## Inspected files
- `Native/Ambitions/Persistence/SwiftDataModels.swift`
- `Native/Ambitions/Persistence/SwiftDataStore.swift`
- `Native/Ambitions/Persistence/StorageSchemaVersionLedger.swift`
- `Native/Ambitions/Persistence/StorageMigrationPlanScaffold.swift`
- `Native/Ambitions/Persistence/StorageMigrationFoundation.swift`
- `Native/Ambitions/Persistence/StorageMigrationExecutionReadiness.swift`
- `Native/Ambitions/Persistence/StorageMigrationExecutionReadinessTestingTests.swift`
- `Native/Ambitions/Persistence/StorageMigrationPlanScaffoldTests.swift`
- `Native/Ambitions/Persistence/StorageSchemaVersionLedgerTests.swift`
- `Native/Ambitions/Persistence/StorageInvariantChecker.swift`
- `Native/Ambitions/Persistence/StoragePackageBoundaryModelsTests.swift`
- `Native/Ambitions/Persistence/PersistenceContracts.swift`
- `Native/Ambitions/Persistence/SwiftDataRepositories.swift`
- `Native/Ambitions/App/AppContainerFactory.swift`
- `Native/AmbitionsTests/Persistence/StorageMigrationFoundationTests.swift`
- `Native/AmbitionsTests/Persistence/StorageMigrationRecoveryTests.swift`
- `Native/AmbitionsTests/Persistence/PreMigrationBackupTests.swift`
- `Native/AmbitionsTests/Persistence/StorageInvariantCheckerTests.swift`

## Schema decision
- Schema changed: **NO**

## Model inventory reviewed
- SwiftData schema entries in `AmbitionsPersistenceStore.schema`:
  - `GoalRecord`, `GoalDraftRecord`, `GoalPlanRecord`, `PlanSectionRecord`, `StepRecord`, `ProgressEvidenceRecord`, `FeedbackEventRecord`, `CaptureRecord`, `ReminderRecord`, `TeachingSignalRecord`, `EventLedgerRecord`, `CommandExecutionRecord`, `SideEffectLedgerStorageRecord`, `EntityRevisionTombstoneRecord`, `AppStateRecord`, `ActionReceiptHistoryRecordModel`, `RuntimeSnapshotLedgerRecord`, `LifeContextBundleRecord`, `AmbitionGraphOperationalRecordModel`, `AmbitionGraphProofRecordModel`, `AmbitionGraphProjectionRecordModel`
- Ledger entries already track migration versions for each SwiftData model in `StorageSchemaVersionLedger.current`.
  - `goal_record` → `goalEngineSchemaVersion`
  - `goal_draft_record` → `goal_draft_record.swiftdata.v1`
  - `goal_plan_record` → `goal_plan_record.swiftdata.v1`
  - `plan_section_record` → `plan_section_record.swiftdata.v1`
  - `step_record` → `step_record.swiftdata.v1`
  - `progress_evidence_record` → `progress_evidence_record.swiftdata.v1`
  - `feedback_event_record` → `GoalFeedbackEventBase.schemaVersion`
  - `capture_record` → `capture_record.swiftdata.v1`
  - `reminder_record` → `reminder_record.swiftdata.v1`
  - `teaching_signal_record` → `teaching_signal_record.swiftdata.v1`
  - `event_ledger_record` → `eventLedgerSchemaVersion`
  - `runtime_snapshot_ledger_record` → `runtimeSnapshotLedgerSchemaVersion`
  - `action_receipt_history_record` → `action_receipt_history_record.swiftdata.v1`
  - `life_context_bundle_record` → `life_context_bundle_record.swiftdata.v1`
  - `ambition_graph_operational_record` → `ambitionGraphStoreSplitSchemaVersion`
  - `ambition_graph_proof_record` → `ambitionGraphStoreSplitSchemaVersion`
  - `ambition_graph_projection_record` → `ambitionGraphStoreSplitSchemaVersion`
  - `command_execution_record` → `ambitionsCommandExecutionRecordSchemaVersion`
  - `side_effect_ledger_record` → `sideEffectLedgerSchemaVersion`
  - `entity_revision_tombstone_record` → `entityRevisionTombstoneSchemaVersion`
  - `app_state_record` → `app_state_record.swiftdata.v1`
- Portable snapshot schema version: `PortableSnapshotSchemaVersion.v1`

## Why no schema change is required now
- Current `StorageSchemaVersionLedger.current` already expresses migration intent and readiness posture.
- `StorageMigrationPlanScaffold` + `StorageMigrationPlanValidator` already generate no-mutation plans when source/target ledgers match, with all entries blocked via migration gates when mutation occurs.
- Invariant and migration safety gates (pre-migration backup, staged dry-run, restore rollback, user review, boundary gate) are already enforced in:
  - `StorageMigrationFoundation`
  - `StorageMigrationExecutionReadiness`
  - `StorageMigrationRecovery`
- Existing repositories for goals, captures, reminders, event logs, snapshots, and graph/projection records are already wired via `AppContainerFactory` and `AppRepositories`.
- No compile/runtime consumer was found that assumes a missing Stage/Motion/Capture/Trust domain schema column/type in existing SwiftData records.

## Migration safety
- `migration/defaults impact`: none introduced by this decision.
- `Schema migration readiness` if this were to change: requires coordinated updates to:
  - `SwiftDataModels.swift` (new fields or record model)
  - `SwiftDataStore.schema` (include model)
  - `StorageSchemaVersionLedger.current` (new/updated entry + version)
  - migration scaffold/recovery tests for proof-gated execution
- Current state remains safe: `StorageSchemaVersionLedger.current` has `migrationExecutionAllowed == false` and blocks execution until required evidence is present.

## Defaults and tests
- Default behavior unchanged.
- Required batch checks run:
  - `git diff --check` (clean)
  - `python3 scripts/ambitions-local-first-boundary-scan.py` (GREEN)
- Persistence tests not run: no source change touching persistence behavior or migration scaffolding.

## Local-first/privacy boundary
- Boundary scan is green for account/R2/hosted-AI checks in active authority files.

## Rollback and no-op recovery
- Rollback not needed because no files changed in runtime/data layer.
- If future schema changes are later accepted, rollback route should follow existing PK05/PK06 patterns:
  - versioned mutation with backup snapshot + staged dry-run + restore rollback + user review evidence + explicit execution gate.
