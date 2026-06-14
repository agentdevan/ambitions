import Foundation

let storageMigrationRecoverySchemaVersion = "storage_migration_recovery.native.v1"

enum StorageRecoveryMode: String, Sendable, Equatable, Hashable {
    case normal = "normal"
    case migrationReviewRequired = "migration_review_required"
    case corruptionReviewRequired = "corruption_review_required"
}

enum StorageRecoverySignalKind: String, Sendable, Equatable, Hashable {
    case corruptStoreOpenFailed = "corrupt_store_open_failed"
    case decodeFailure = "decode_failure"
    case invariantBlocker = "invariant_blocker"
}

struct StorageRecoverySignal: Identifiable, Sendable, Equatable, Hashable {
    let id: String
    let kind: StorageRecoverySignalKind
    let message: String
}

enum StorageRecoveryIssueKind: String, Sendable, Equatable, Hashable {
    case migrationReadinessBlocked = "migration_readiness_blocked"
    case missingPreMigrationBackupReceipt = "missing_pre_migration_backup_receipt"
    case corruptStoreSignal = "corrupt_store_signal"
    case destructiveResetNotAuthorized = "destructive_reset_not_authorized"
}

struct StorageRecoveryIssue: Identifiable, Sendable, Equatable, Hashable {
    let id: String
    let kind: StorageRecoveryIssueKind
    let message: String
}

struct StorageRecoveryReceipt: Identifiable, Sendable, Equatable, Hashable {
    let id: String
    let schemaVersion: String
    let createdAt: String
    let mode: StorageRecoveryMode
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

struct StorageRecoveryAssessment: Sendable, Equatable {
    let schemaVersion: String
    let mode: StorageRecoveryMode
    let receipt: StorageRecoveryReceipt
    let issues: [StorageRecoveryIssue]

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

struct StorageMigrationRecoveryCoordinator: Sendable {
    let timestampProvider: @Sendable () -> String
    let idProvider: @Sendable () -> String

    init(
        timestampProvider: @escaping @Sendable () -> String = { DomainTimestamp.string(from: .now) },
        idProvider: @escaping @Sendable () -> String = { UUID().uuidString }
    ) {
        self.timestampProvider = timestampProvider
        self.idProvider = idProvider
    }

    func assess(
        plan: StorageMigrationPlan,
        readiness: StorageMigrationExecutionReadiness,
        preMigrationBackup: PreMigrationBackupReceipt?,
        recoverySignals: [StorageRecoverySignal] = []
    ) -> StorageRecoveryAssessment {
        var issues: [StorageRecoveryIssue] = []

        if plan.mutationEntries.isEmpty == false && readiness.canRequestMigrationExecution == false {
            issues.append(
                StorageRecoveryIssue(
                    id: "migration_readiness_blocked",
                    kind: .migrationReadinessBlocked,
                    message: "Migration execution remains blocked until readiness gates are Green."
                )
            )
        }

        if plan.mutationEntries.isEmpty == false && preMigrationBackup == nil {
            issues.append(
                StorageRecoveryIssue(
                    id: "missing_pre_migration_backup_receipt",
                    kind: .missingPreMigrationBackupReceipt,
                    message: "A pre-migration backup Receipt is required before any storage mutation can execute."
                )
            )
        }

        for signal in recoverySignals {
            issues.append(
                StorageRecoveryIssue(
                    id: "corrupt_store_signal.\(signal.id)",
                    kind: .corruptStoreSignal,
                    message: signal.message
                )
            )
        }

        if recoverySignals.isEmpty == false {
            issues.append(
                StorageRecoveryIssue(
                    id: "destructive_reset_not_authorized",
                    kind: .destructiveResetNotAuthorized,
                    message: "Corrupt-store recovery opens review mode first; destructive reset requires explicit user action after backup/export review."
                )
            )
        }

        let mode: StorageRecoveryMode
        if recoverySignals.isEmpty == false {
            mode = .corruptionReviewRequired
        } else if issues.isEmpty {
            mode = .normal
        } else {
            mode = .migrationReviewRequired
        }

        let receiptID = idProvider()
        let receipt = StorageRecoveryReceipt(
            id: receiptID,
            schemaVersion: storageMigrationRecoverySchemaVersion,
            createdAt: timestampProvider(),
            mode: mode,
            sourceLedgerSchemaVersion: plan.sourceLedgerSchemaVersion,
            targetLedgerSchemaVersion: plan.targetLedgerSchemaVersion,
            migrationPlanSchemaVersion: plan.schemaVersion,
            preMigrationBackupReceiptID: preMigrationBackup?.id,
            sourceRecordID: "SourceRecord.storage-recovery.\(receiptID)",
            receiptID: "Receipt.storage-recovery.\(receiptID)",
            replayTraceID: "ReplayTrace.storage-recovery.\(receiptID)",
            inspectionSurfaceTitle: "What Ambitions knows",
            inspectionSummary: "You / What Ambitions knows can inspect this storage migration source, receipt, and reason before any recovery action.",
            migrationExecutionAllowed: false,
            destructiveResetAllowed: false
        )

        return StorageRecoveryAssessment(
            schemaVersion: storageMigrationRecoverySchemaVersion,
            mode: mode,
            receipt: receipt,
            issues: issues.sorted { $0.id < $1.id }
        )
    }
}
