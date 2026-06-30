import Foundation

let runtimeDoctorSchemaVersion = "storage_migration_recovery.native.v1"

enum RuntimeDoctorMode: String, Sendable, Equatable, Hashable {
    case normal = "normal"
    case migrationReviewRequired = "migration_review_required"
    case corruptionReviewRequired = "corruption_review_required"
}

enum RuntimeDoctorIssueKind: String, Sendable, Equatable, Hashable {
    case migrationReadinessBlocked = "migration_readiness_blocked"
    case missingPreMigrationBackupReceipt = "missing_pre_migration_backup_receipt"
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
        recoverySignals: [CorruptionQuarantineSignal] = []
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

        let mode: RuntimeDoctorMode
        if quarantineDecision.quarantineRequired {
            mode = .corruptionReviewRequired
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
}
