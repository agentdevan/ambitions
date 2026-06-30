import Foundation

let schemaLedgerSchemaVersion = "storage_schema_version_ledger.native.v1"

enum SchemaLedgerFamily: String, Sendable, Equatable, Hashable, CaseIterable {
    case swiftDataRecord = "swift_data_record"
    case encodedSnapshot = "encoded_snapshot"
    case portableSnapshot = "portable_snapshot"
}

enum MigrationReadiness: String, Sendable, Equatable, Hashable {
    case namedOnly = "named_only"
    case migrationPlanRequired = "migration_plan_required"
    case backupGateRequired = "backup_gate_required"
    case dryRunRequired = "dry_run_required"
}

enum RollbackRequirement: String, Sendable, Equatable, Hashable {
    case notExecutable = "not_executable"
    case rollbackPlanRequired = "rollback_plan_required"
    case restoreSnapshotRequired = "restore_snapshot_required"
}

struct SchemaLedgerEntry: Identifiable, Sendable, Equatable, Hashable {
    let id: String
    let family: SchemaLedgerFamily
    let owner: String
    let storedTypeName: String
    let currentVersion: String
    let versionEvidence: String
    let migrationReadiness: MigrationReadiness
    let rollbackRequirement: RollbackRequirement
    let notes: String

    var blocksMigrationExecution: Bool {
        migrationReadiness != .dryRunRequired || rollbackRequirement != .restoreSnapshotRequired
    }

    init(
        id: String,
        family: SchemaLedgerFamily,
        owner: String,
        storedTypeName: String,
        currentVersion: String,
        versionEvidence: String,
        migrationReadiness: MigrationReadiness,
        rollbackRequirement: RollbackRequirement,
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

struct SchemaLedger: Sendable, Equatable {
    let schemaVersion: String
    let entries: [SchemaLedgerEntry]
    let migrationExecutionAllowed: Bool

    var swiftDataEntries: [SchemaLedgerEntry] {
        entries.filter { $0.family == .swiftDataRecord }
    }

    var portableSnapshotEntries: [SchemaLedgerEntry] {
        entries.filter { $0.family == .portableSnapshot }
    }

    var migrationBlockers: [SchemaLedgerEntry] {
        entries.filter(\.blocksMigrationExecution)
    }

    init(
        schemaVersion: String = schemaLedgerSchemaVersion,
        entries: [SchemaLedgerEntry],
        migrationExecutionAllowed: Bool = false
    ) {
        self.schemaVersion = schemaVersion
        self.entries = entries
        self.migrationExecutionAllowed = migrationExecutionAllowed
    }

    static let current = SchemaLedger(entries: [
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
            notes: "Section ordering for stored goal plans; Plan remains a persistence bridge."
        ),
        .swiftData(
            id: "swiftdata.step_record",
            storedTypeName: "StepRecord",
            currentVersion: "step_record.swiftdata.v1",
            versionEvidence: "Current SwiftData model in AmbitionsPersistenceStore.schema.",
            notes: "Stored actions inside goal paths or Time-owned planning continuity."
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
            id: "swiftdata.reminder_record",
            storedTypeName: "ReminderRecord",
            currentVersion: "reminder_record.swiftdata.v1",
            versionEvidence: "Current SwiftData model in AmbitionsPersistenceStore.schema.",
            notes: "Reminder trigger objects and local SourceRecord/Receipt/ReplayTrace wiring."
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
            id: "swiftdata.runtime_snapshot_ledger_record",
            storedTypeName: "RuntimeSnapshotLedgerRecord",
            currentVersion: runtimeSnapshotLedgerSchemaVersion,
            versionEvidence: "RuntimeSnapshotLedgerRecord.schemaVersion persists RuntimeSnapshotLedgerEnvelope.schemaVersion.",
            notes: "Versioned runtime input envelopes, provenance hashes, replay validation anchors, and conservative AFEP privacy/export defaults."
        ),
        .swiftData(
            id: "swiftdata.life_context_bundle_record",
            storedTypeName: "LifeContextBundleRecord",
            currentVersion: "life_context_bundle_record.swiftdata.v1",
            versionEvidence: "Current SwiftData model in AmbitionsPersistenceStore.schema.",
            notes: "Local life-context bundle snapshot with profile, pathways, opportunities, historical facts, and source controls."
        ),
        .swiftData(
            id: "swiftdata.ambition_graph_operational_record",
            storedTypeName: "AmbitionGraphOperationalRecordModel",
            currentVersion: ambitionGraphStoreSplitSchemaVersion,
            versionEvidence: "Current SwiftData model in AmbitionsPersistenceStore.schema.",
            notes: "Surface-local operational graph materialization with queryable privacy, object, receipt, and replay seams."
        ),
        .swiftData(
            id: "swiftdata.ambition_graph_proof_record",
            storedTypeName: "AmbitionGraphProofRecordModel",
            currentVersion: ambitionGraphStoreSplitSchemaVersion,
            versionEvidence: "Current SwiftData model in AmbitionsPersistenceStore.schema.",
            notes: "Append-only proof versions with supersession metadata and local provenance columns."
        ),
        .swiftData(
            id: "swiftdata.ambition_graph_projection_record",
            storedTypeName: "AmbitionGraphProjectionRecordModel",
            currentVersion: ambitionGraphStoreSplitSchemaVersion,
            versionEvidence: "Current SwiftData model in AmbitionsPersistenceStore.schema.",
            notes: "Deterministic Today/Goals/Capture/Time/You projection materializations with checksum and invalidation reason columns."
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
            notes: "Deterministic local revision-tombstone markers with lineage, lifecycle, and redacted export views for conflict recovery and replacement ordering."
        ),
        .swiftData(
            id: "swiftdata.app_state_record",
            storedTypeName: "AppStateRecord",
            currentVersion: "app_state_record.swiftdata.v1",
            versionEvidence: "Current SwiftData model in AmbitionsPersistenceStore.schema.",
            notes: "Local app state and user preference snapshot."
        ),
        SchemaLedgerEntry(
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

    static let seededHistoricalV0 = SchemaLedger(entries: current.entries.map { entry in
        switch entry.family {
        case .swiftDataRecord:
            return SchemaLedgerEntry(
                id: entry.id,
                family: entry.family,
                owner: entry.owner,
                storedTypeName: entry.storedTypeName,
                currentVersion: "\(entry.storedTypeName).seeded-history.v0",
                versionEvidence: "Seeded historical store fixture for migration matrix coverage.",
                migrationReadiness: .backupGateRequired,
                rollbackRequirement: .restoreSnapshotRequired,
                notes: "Historical fixture only. Upgrade requires SourceRecord, Receipt, ReplayTrace, backup, dry-run, rollback, and user review proof before execution."
            )
        case .encodedSnapshot, .portableSnapshot:
            return entry
        }
    })
}

enum SchemaLedgerIssue: Sendable, Equatable, Hashable {
    case unsupportedLedgerSchema(String)
    case duplicateEntryID(String)
    case emptyStoredTypeName(String)
    case emptyCurrentVersion(String)
    case missingSwiftDataRecord(String)
    case migrationExecutionAuthorizedWithoutDryRun(String)
}

struct SchemaLedgerValidator: Sendable {
    static let requiredSwiftDataTypeNames: Set<String> = [
        "GoalRecord",
        "GoalDraftRecord",
        "GoalPlanRecord",
        "PlanSectionRecord",
        "StepRecord",
        "ProgressEvidenceRecord",
        "FeedbackEventRecord",
        "CaptureRecord",
        "ReminderRecord",
        "CommandExecutionRecord",
        "TeachingSignalRecord",
        "EventLedgerRecord",
        "ActionReceiptHistoryRecordModel",
        "SideEffectLedgerStorageRecord",
        "EntityRevisionTombstoneRecord",
        "AppStateRecord",
        "RuntimeSnapshotLedgerRecord",
        "LifeContextBundleRecord",
        "AmbitionGraphOperationalRecordModel",
        "AmbitionGraphProofRecordModel",
        "AmbitionGraphProjectionRecordModel",
    ]

    func validate(_ ledger: SchemaLedger) -> [SchemaLedgerIssue] {
        var issues: [SchemaLedgerIssue] = []

        if ledger.schemaVersion != schemaLedgerSchemaVersion {
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
            issues.append(.migrationExecutionAuthorizedWithoutDryRun("SchemaLedger is inventory-only."))
        }

        return issues
    }
}

private extension SchemaLedgerEntry {
    static func swiftData(
        id: String,
        storedTypeName: String,
        currentVersion: String,
        versionEvidence: String,
        notes: String
    ) -> SchemaLedgerEntry {
        SchemaLedgerEntry(
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
