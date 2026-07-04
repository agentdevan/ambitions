import Foundation

let runtimeDoctorSchemaVersion = "storage_migration_recovery.native.v1"

enum RuntimeDoctorMode: String, Sendable, Equatable, Hashable {
    case normal = "normal"
    case migrationReviewRequired = "migration_review_required"
    case replayRepairRequired = "replay_repair_required"
    case corruptionReviewRequired = "corruption_review_required"
}

enum RuntimeDoctorIssueKind: String, Sendable, Equatable, Hashable {
    case migrationReadinessBlocked = "migration_readiness_blocked"
    case missingPreMigrationBackupReceipt = "missing_pre_migration_backup_receipt"
    case commandRecordMissingRuntimeEvent = "command_record_missing_runtime_event"
    case runtimeEventMissingCommandRecord = "runtime_event_missing_command_record"
    case corruptStoreSignal = "corrupt_store_signal"
    case destructiveResetNotAuthorized = "destructive_reset_not_authorized"
}

struct RuntimeDoctorIssue: Identifiable, Sendable, Equatable, Hashable {
    let id: String
    let kind: RuntimeDoctorIssueKind
    let message: String
}

struct RuntimeDoctorReceipt: Identifiable, Sendable, Equatable, Hashable {
    let id: String
    let schemaVersion: String
    let createdAt: String
    let mode: RuntimeDoctorMode
    let sourceLedgerSchemaVersion: String
    let targetLedgerSchemaVersion: String
    let migrationPlanSchemaVersion: String
    let preMigrationBackupReceiptID: String?
    let sourceRecordID: String
    let receiptID: String
    let replayTraceID: String
    let inspectionSurfaceTitle: String
    let inspectionSummary: String
    let migrationExecutionAllowed: Bool
    let destructiveResetAllowed: Bool
}

struct RuntimeDoctorAssessment: Sendable, Equatable {
    let schemaVersion: String
    let mode: RuntimeDoctorMode
    let receipt: RuntimeDoctorReceipt
    let issues: [RuntimeDoctorIssue]

    var canOpenRecoveryMode: Bool {
        mode != .normal
    }

    var canExecuteMigration: Bool {
        issues.isEmpty
            && mode == .normal
            && receipt.migrationExecutionAllowed
            && receipt.destructiveResetAllowed == false
    }
}

struct RuntimeDoctor: Sendable {
    let timestampProvider: @Sendable () -> String
    let idProvider: @Sendable () -> String
    let corruptionQuarantine: CorruptionQuarantine

    init(
        timestampProvider: @escaping @Sendable () -> String = { DomainTimestamp.string(from: .now) },
        idProvider: @escaping @Sendable () -> String = { UUID().uuidString },
        corruptionQuarantine: CorruptionQuarantine? = nil
    ) {
        self.timestampProvider = timestampProvider
        self.idProvider = idProvider
        self.corruptionQuarantine = corruptionQuarantine ?? CorruptionQuarantine(
            timestampProvider: timestampProvider,
            idProvider: idProvider
        )
    }

    func assess(
        plan: MigrationPlan,
        readiness: RepairPlan,
        preMigrationBackup: PreMigrationBackupReceipt?,
        recoverySignals: [CorruptionQuarantineSignal] = [],
        commandRecords: [AmbitionsCommandExecutionRecord] = [],
        runtimeEvents: [RuntimeEventEnvelope] = []
    ) -> RuntimeDoctorAssessment {
        var issues: [RuntimeDoctorIssue] = []
        let quarantineDecision = corruptionQuarantine.evaluate(signals: recoverySignals)

        if plan.mutationEntries.isEmpty == false && readiness.canRequestMigrationExecution == false {
            issues.append(
                RuntimeDoctorIssue(
                    id: "migration_readiness_blocked",
                    kind: .migrationReadinessBlocked,
                    message: "Migration execution remains blocked until readiness gates are Green."
                )
            )
        }

        if plan.mutationEntries.isEmpty == false && preMigrationBackup == nil {
            issues.append(
                RuntimeDoctorIssue(
                    id: "missing_pre_migration_backup_receipt",
                    kind: .missingPreMigrationBackupReceipt,
                    message: "A pre-migration backup Receipt is required before any storage mutation can execute."
                )
            )
        }

        for signal in quarantineDecision.signals {
            issues.append(
                RuntimeDoctorIssue(
                    id: "corrupt_store_signal.\(signal.id)",
                    kind: .corruptStoreSignal,
                    message: signal.message
                )
            )
        }

        if quarantineDecision.quarantineRequired {
            issues.append(
                RuntimeDoctorIssue(
                    id: "destructive_reset_not_authorized",
                    kind: .destructiveResetNotAuthorized,
                    message: "Corrupt-store recovery opens review mode first; destructive reset requires explicit user action after backup/export review."
                )
            )
        }

        issues += commandEventReplayIssues(
            commandRecords: commandRecords,
            runtimeEvents: runtimeEvents
        )

        let mode: RuntimeDoctorMode
        if quarantineDecision.quarantineRequired {
            mode = .corruptionReviewRequired
        } else if issues.contains(where: { issue in
            issue.kind == .commandRecordMissingRuntimeEvent ||
                issue.kind == .runtimeEventMissingCommandRecord
        }) {
            mode = .replayRepairRequired
        } else if issues.isEmpty {
            mode = .normal
        } else {
            mode = .migrationReviewRequired
        }

        let receiptID = idProvider()
        let receipt = RuntimeDoctorReceipt(
            id: receiptID,
            schemaVersion: runtimeDoctorSchemaVersion,
            createdAt: timestampProvider(),
            mode: mode,
            sourceLedgerSchemaVersion: plan.sourceLedgerSchemaVersion,
            targetLedgerSchemaVersion: plan.targetLedgerSchemaVersion,
            migrationPlanSchemaVersion: plan.schemaVersion,
            preMigrationBackupReceiptID: preMigrationBackup?.id,
            sourceRecordID: "SourceRecord.storage-recovery.\(receiptID)",
            receiptID: "Receipt.storage-recovery.\(receiptID)",
            replayTraceID: "ReplayTrace.storage-recovery.\(receiptID)",
            inspectionSurfaceTitle: "Search Ambitions",
            inspectionSummary: "You / Search Ambitions can inspect this storage migration source, receipt, and reason before any recovery action.",
            migrationExecutionAllowed: false,
            destructiveResetAllowed: false
        )

        return RuntimeDoctorAssessment(
            schemaVersion: runtimeDoctorSchemaVersion,
            mode: mode,
            receipt: receipt,
            issues: issues.sorted { $0.id < $1.id }
        )
    }

    func diagnoseLocalDrift(
        snapshot: RuntimeDoctorHealthSnapshot
    ) -> RuntimeDoctorRepairAssessment {
        RuntimeDoctorRepairOperator(
            timestampProvider: timestampProvider,
            idProvider: idProvider
        ).diagnose(snapshot: snapshot)
    }

    private func commandEventReplayIssues(
        commandRecords: [AmbitionsCommandExecutionRecord],
        runtimeEvents: [RuntimeEventEnvelope]
    ) -> [RuntimeDoctorIssue] {
        let runtimeCommandEvents = runtimeEvents.compactMap { envelope -> (commandID: String, eventID: String)? in
            guard case .commandExecution = envelope.event.payload,
                  let commandID = envelope.event.commandID
            else { return nil }
            return (commandID, envelope.id)
        }
        let runtimeCommandIDs = Set(runtimeCommandEvents.map(\.commandID))
        let commandRecordIDs = Set(commandRecords.map(\.commandID))
        var issues: [RuntimeDoctorIssue] = []

        for record in commandRecords.sorted(by: { $0.commandID < $1.commandID })
            where runtimeCommandIDs.contains(record.commandID) == false {
            let fingerprint = LocalRuntimeDiagnosticsRedactor.fingerprint(record.commandID)
            issues.append(
                RuntimeDoctorIssue(
                    id: "command_record_missing_runtime_event.\(fingerprint)",
                    kind: .commandRecordMissingRuntimeEvent,
                    message: "Command execution record has no runtime event replay authority; replay must pause for repair before mutation."
                )
            )
        }

        for event in runtimeCommandEvents.sorted(by: { $0.eventID < $1.eventID })
            where commandRecordIDs.contains(event.commandID) == false {
            let fingerprint = LocalRuntimeDiagnosticsRedactor.fingerprint(event.eventID)
            issues.append(
                RuntimeDoctorIssue(
                    id: "runtime_event_missing_command_record.\(fingerprint)",
                    kind: .runtimeEventMissingCommandRecord,
                    message: "Runtime command event is replayable canonical truth but lacks a materialized command execution receipt."
                )
            )
        }

        return issues
    }
}
