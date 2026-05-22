import Foundation

let storageSchemaVersionLedgerSchemaVersion = "storage_schema_version_ledger.native.v1"

enum StorageSchemaFamily: String, Sendable, Equatable, Hashable, CaseIterable {
    case swiftDataRecord = "swift_data_record"
    case encodedSnapshot = "encoded_snapshot"
    case portableSnapshot = "portable_snapshot"
}

enum StorageMigrationReadiness: String, Sendable, Equatable, Hashable {
    case namedOnly = "named_only"
    case migrationPlanRequired = "migration_plan_required"
    case backupGateRequired = "backup_gate_required"
    case dryRunRequired = "dry_run_required"
}

enum StorageRollbackRequirement: String, Sendable, Equatable, Hashable {
    case notExecutable = "not_executable"
    case rollbackPlanRequired = "rollback_plan_required"
    case restoreSnapshotRequired = "restore_snapshot_required"
}

struct StorageSchemaVersionEntry: Identifiable, Sendable, Equatable, Hashable {
    let id: String
    let family: StorageSchemaFamily
    let owner: String
    let storedTypeName: String
    let currentVersion: String
    let versionEvidence: String
    let migrationReadiness: StorageMigrationReadiness
    let rollbackRequirement: StorageRollbackRequirement
    let notes: String

    var blocksMigrationExecution: Bool {
        migrationReadiness != .dryRunRequired || rollbackRequirement != .restoreSnapshotRequired
    }

    init(
        id: String,
        family: StorageSchemaFamily,
        owner: String,
        storedTypeName: String,
        currentVersion: String,
        versionEvidence: String,
        migrationReadiness: StorageMigrationReadiness,
        rollbackRequirement: StorageRollbackRequirement,
        notes: String
    ) {
        self.id = id
        self.family = family
        self.owner = owner
        self.storedTypeName = storedTypeName
        self.currentVersion = currentVersion
        self.versionEvidence = versionEvidence
        self.migrationReadiness = migrationReadiness
        self.rollbackRequirement = rollbackRequirement
        self.notes = notes
    }
}

struct StorageSchemaVersionLedger: Sendable, Equatable {
    let schemaVersion: String
    let entries: [StorageSchemaVersionEntry]
    let migrationExecutionAllowed: Bool

    var swiftDataEntries: [StorageSchemaVersionEntry] {
        entries.filter { $0.family == .swiftDataRecord }
    }

    var portableSnapshotEntries: [StorageSchemaVersionEntry] {
        entries.filter { $0.family == .portableSnapshot }
    }

    var migrationBlockers: [StorageSchemaVersionEntry] {
        entries.filter(\.blocksMigrationExecution)
    }

    init(
        schemaVersion: String = storageSchemaVersionLedgerSchemaVersion,
        entries: [StorageSchemaVersionEntry],
        migrationExecutionAllowed: Bool = false
    ) {
        self.schemaVersion = schemaVersion
        self.entries = entries
        self.migrationExecutionAllowed = migrationExecutionAllowed
    }

    static let current = StorageSchemaVersionLedger(entries: [
        .swiftData(
            id: "swiftdata.goal_record",
            storedTypeName: "GoalRecord",
            currentVersion: goalEngineSchemaVersion,
            versionEvidence: "GoalRecord.schemaVersion persists Goal.schemaVersion.",
            notes: "Primary persisted Goal snapshot and denormalized routing fields."
        ),
        .swiftData(
            id: "swiftdata.goal_draft_record",
            storedTypeName: "GoalDraftRecord",
            currentVersion: "goal_draft_record.swiftdata.v1",
            versionEvidence: "Current SwiftData model in AmbitionsPersistenceStore.schema.",
            notes: "Capture-to-goal draft holding area; no migration execution path is authorized."
        ),
        .swiftData(
            id: "swiftdata.goal_plan_record",
            storedTypeName: "GoalPlanRecord",
            currentVersion: "goal_plan_record.swiftdata.v1",
            versionEvidence: "Current SwiftData model in AmbitionsPersistenceStore.schema.",
            notes: "Stored generated plan snapshot and plan-level assumptions."
        ),
        .swiftData(
            id: "swiftdata.plan_section_record",
            storedTypeName: "PlanSectionRecord",
            currentVersion: "plan_section_record.swiftdata.v1",
            versionEvidence: "Current SwiftData model in AmbitionsPersistenceStore.schema.",
            notes: "Section ordering for stored goal plans; Plan remains a compatibility seam."
        ),
        .swiftData(
            id: "swiftdata.step_record",
            storedTypeName: "StepRecord",
            currentVersion: "step_record.swiftdata.v1",
            versionEvidence: "Current SwiftData model in AmbitionsPersistenceStore.schema.",
            notes: "Stored actions inside goal paths or Time-owned compatibility planning."
        ),
        .swiftData(
            id: "swiftdata.progress_evidence_record",
            storedTypeName: "ProgressEvidenceRecord",
            currentVersion: "progress_evidence_record.swiftdata.v1",
            versionEvidence: "Current SwiftData model in AmbitionsPersistenceStore.schema.",
            notes: "Proof and progress evidence persisted locally."
        ),
        .swiftData(
            id: "swiftdata.feedback_event_record",
            storedTypeName: "FeedbackEventRecord",
            currentVersion: GoalFeedbackEventBase.schemaVersion,
            versionEvidence: "Stored payloads use GoalFeedbackEventBase.schemaVersion.",
            notes: "User feedback and closure events stored as encoded payloads."
        ),
        .swiftData(
            id: "swiftdata.capture_record",
            storedTypeName: "CaptureRecord",
            currentVersion: "capture_record.swiftdata.v1",
            versionEvidence: "Current SwiftData model in AmbitionsPersistenceStore.schema.",
            notes: "Raw Capture records and placement links persisted locally."
        ),
        .swiftData(
            id: "swiftdata.teaching_signal_record",
            storedTypeName: "TeachingSignalRecord",
            currentVersion: "teaching_signal_record.swiftdata.v1",
            versionEvidence: "Current SwiftData model in AmbitionsPersistenceStore.schema.",
            notes: "User-reviewed teaching signals; no hidden learning is authorized."
        ),
        .swiftData(
            id: "swiftdata.event_ledger_record",
            storedTypeName: "EventLedgerRecord",
            currentVersion: eventLedgerSchemaVersion,
            versionEvidence: "EventLedgerRecord.schemaVersion persists EventLedgerEntry.schemaVersion.",
            notes: "Receipt/trust history event ledger persisted locally."
        ),
        .swiftData(
            id: "swiftdata.action_receipt_history_record",
            storedTypeName: "ActionReceiptHistoryRecordModel",
            currentVersion: "action_receipt_history_record.swiftdata.v1",
            versionEvidence: "ActionReceiptHistoryRecord.snapshot schema derives from actionClosureReceiptSchemaVersion and metadata columns.",
            notes: "Receipt history records persisted locally for deterministic local history search and recovery."
        ),
        .swiftData(
            id: "swiftdata.life_context_bundle_record",
            storedTypeName: "LifeContextBundleRecord",
            currentVersion: "life_context_bundle_record.swiftdata.v1",
            versionEvidence: "Current SwiftData model in AmbitionsPersistenceStore.schema.",
            notes: "Local life-context bundle snapshot with profile, pathways, opportunities, historical facts, and source controls."
        ),
        .swiftData(
            id: "swiftdata.command_execution_record",
            storedTypeName: "CommandExecutionRecord",
            currentVersion: ambitionsCommandExecutionRecordSchemaVersion,
            versionEvidence: "AmbitionsCommandExecutionRecord.schemaVersion persists durable command execution result and metadata.",
            notes: "Durable command execution attempts and results for local-only replay/reconciliation."
        ),
        .swiftData(
            id: "swiftdata.side_effect_ledger_record",
            storedTypeName: "SideEffectLedgerStorageRecord",
            currentVersion: sideEffectLedgerSchemaVersion,
            versionEvidence: "SideEffectLedgerStorageRecord.schemaVersion persists SideEffectLedgerRecord.schemaVersion and snapshot metadata.",
            notes: "Local-only side-effect policy decision and result ledger for external-effect, confirmation, blocked, and local-only attempts."
        ),
        .swiftData(
            id: "swiftdata.entity_revision_tombstone_record",
            storedTypeName: "EntityRevisionTombstoneRecord",
            currentVersion: entityRevisionTombstoneSchemaVersion,
            versionEvidence: "EntityRevisionTombstoneRecord.schemaVersion persists EntityRevisionTombstone.schemaVersion.",
            notes: "Deterministic local revision-tombstone markers for conflict recovery and replacement ordering."
        ),
        .swiftData(
            id: "swiftdata.app_state_record",
            storedTypeName: "AppStateRecord",
            currentVersion: "app_state_record.swiftdata.v1",
            versionEvidence: "Current SwiftData model in AmbitionsPersistenceStore.schema.",
            notes: "Local app state and user preference snapshot."
        ),
        StorageSchemaVersionEntry(
            id: "portable_snapshot.app_snapshot",
            family: .portableSnapshot,
            owner: "PortableSnapshotService",
            storedTypeName: "PortableAppSnapshot",
            currentVersion: PortableSnapshotSchemaVersion.v1.rawValue,
            versionEvidence: "PortableSnapshotService exports and imports only .v1.",
            migrationReadiness: .migrationPlanRequired,
            rollbackRequirement: .restoreSnapshotRequired,
            notes: "Portable local export/import package; not cloud sync or migration proof."
        )
    ])
}

enum StorageSchemaVersionLedgerIssue: Sendable, Equatable, Hashable {
    case unsupportedLedgerSchema(String)
    case duplicateEntryID(String)
    case emptyStoredTypeName(String)
    case emptyCurrentVersion(String)
    case missingSwiftDataRecord(String)
    case migrationExecutionAuthorizedWithoutDryRun(String)
}

struct StorageSchemaVersionLedgerValidator: Sendable {
    static let requiredSwiftDataTypeNames: Set<String> = [
        "GoalRecord",
        "GoalDraftRecord",
        "GoalPlanRecord",
        "PlanSectionRecord",
        "StepRecord",
        "ProgressEvidenceRecord",
        "FeedbackEventRecord",
        "CaptureRecord",
        "CommandExecutionRecord",
        "TeachingSignalRecord",
        "EventLedgerRecord",
        "ActionReceiptHistoryRecordModel",
        "SideEffectLedgerStorageRecord",
        "EntityRevisionTombstoneRecord",
        "AppStateRecord",
        "LifeContextBundleRecord",
    ]

    func validate(_ ledger: StorageSchemaVersionLedger) -> [StorageSchemaVersionLedgerIssue] {
        var issues: [StorageSchemaVersionLedgerIssue] = []

        if ledger.schemaVersion != storageSchemaVersionLedgerSchemaVersion {
            issues.append(.unsupportedLedgerSchema(ledger.schemaVersion))
        }

        let groupedIDs = Dictionary(grouping: ledger.entries, by: \.id)
        for duplicateID in groupedIDs.keys.filter({ groupedIDs[$0, default: []].count > 1 }).sorted() {
            issues.append(.duplicateEntryID(duplicateID))
        }

        for entry in ledger.entries {
            if entry.storedTypeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                issues.append(.emptyStoredTypeName(entry.id))
            }
            if entry.currentVersion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                issues.append(.emptyCurrentVersion(entry.id))
            }
        }

        let presentSwiftDataTypes = Set(ledger.swiftDataEntries.map(\.storedTypeName))
        for requiredName in Self.requiredSwiftDataTypeNames.subtracting(presentSwiftDataTypes).sorted() {
            issues.append(.missingSwiftDataRecord(requiredName))
        }

        if ledger.migrationExecutionAllowed && ledger.migrationBlockers.isEmpty == false {
            issues.append(.migrationExecutionAuthorizedWithoutDryRun("PK07 is ledger-only."))
        }

        return issues
    }
}

private extension StorageSchemaVersionEntry {
    static func swiftData(
        id: String,
        storedTypeName: String,
        currentVersion: String,
        versionEvidence: String,
        notes: String
    ) -> StorageSchemaVersionEntry {
        StorageSchemaVersionEntry(
            id: id,
            family: .swiftDataRecord,
            owner: "AmbitionsPersistenceStore",
            storedTypeName: storedTypeName,
            currentVersion: currentVersion,
            versionEvidence: versionEvidence,
            migrationReadiness: .migrationPlanRequired,
            rollbackRequirement: .rollbackPlanRequired,
            notes: notes
        )
    }
}
