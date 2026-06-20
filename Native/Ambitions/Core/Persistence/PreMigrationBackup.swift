import Foundation

let preMigrationBackupSchemaVersion = "pre_migration_backup.native.v1"

enum PreMigrationBackupBlockerKind: String, Sendable, Equatable, Hashable {
    case invariantBlocker = "invariant_blocker"
    case invalidMigrationPlan = "invalid_migration_plan"
    case mutationMissingBackupGate = "mutation_missing_backup_gate"
    case unsupportedSnapshotSchema = "unsupported_snapshot_schema"
    case emptyBackupPackage = "empty_backup_package"
    case migrationExecutionAlreadyAllowed = "migration_execution_already_allowed"
}

struct PreMigrationBackupBlocker: Identifiable, Sendable, Equatable, Hashable {
    let id: String
    let kind: PreMigrationBackupBlockerKind
    let message: String

    init(kind: PreMigrationBackupBlockerKind, id: String, message: String) {
        self.kind = kind
        self.id = "\(kind.rawValue).\(id)"
        self.message = message
    }
}

struct PreMigrationBackupReceipt: Identifiable, Sendable, Equatable {
    let id: String
    let schemaVersion: String
    let createdAt: String
    let sourceLedgerSchemaVersion: String
    let targetLedgerSchemaVersion: String
    let migrationPlanSchemaVersion: String
    let snapshotSchemaVersion: String
    let snapshotExportedAt: String
    let selectedCategories: [PortableExportCategory]
    let backedUpGoalCount: Int
    let backedUpDraftCount: Int
    let backedUpEvidenceCount: Int
    let backedUpFeedbackCount: Int
    let backedUpCaptureCount: Int
    let backedUpTeachingSignalCount: Int
    let backedUpAppStateCount: Int
    let invariantIssueCount: Int
    let invariantBlockerCount: Int
    let migrationPlanEntryCount: Int
    let migrationMutationEntryCount: Int
    let requiredGates: [StorageMigrationPlanGate]
    let backupRestoresGateSatisfied: Bool
    let migrationExecutionAllowed: Bool

    var backedUpItemCount: Int {
        backedUpGoalCount
            + backedUpDraftCount
            + backedUpEvidenceCount
            + backedUpFeedbackCount
            + backedUpCaptureCount
            + backedUpTeachingSignalCount
            + backedUpAppStateCount
    }
}

struct PreMigrationBackupReport: Sendable, Equatable {
    let schemaVersion: String
    let receipt: PreMigrationBackupReceipt?
    let backupPackage: PortableAppSnapshot?
    let blockers: [PreMigrationBackupBlocker]
    let migrationExecutionAllowed: Bool

    var isGreen: Bool {
        receipt?.backupRestoresGateSatisfied == true
            && blockers.isEmpty
            && migrationExecutionAllowed == false
    }

    init(
        schemaVersion: String = preMigrationBackupSchemaVersion,
        receipt: PreMigrationBackupReceipt?,
        backupPackage: PortableAppSnapshot?,
        blockers: [PreMigrationBackupBlocker],
        migrationExecutionAllowed: Bool = false
    ) {
        self.schemaVersion = schemaVersion
        self.receipt = receipt
        self.backupPackage = backupPackage
        self.blockers = blockers.sorted { $0.id < $1.id }
        self.migrationExecutionAllowed = migrationExecutionAllowed
    }
}

struct PreMigrationBackupService: Sendable {
    let snapshotService: any PortableSnapshotServicing
    let invariantReportProvider: @Sendable () async throws -> StorageInvariantReport
    let timestampProvider: @Sendable () -> String
    let idProvider: @Sendable () -> String

    init(
        snapshotService: any PortableSnapshotServicing,
        invariantReportProvider: @escaping @Sendable () async throws -> StorageInvariantReport,
        timestampProvider: @escaping @Sendable () -> String = { DomainTimestamp.string(from: .now) },
        idProvider: @escaping @Sendable () -> String = { UUID().uuidString }
    ) {
        self.snapshotService = snapshotService
        self.invariantReportProvider = invariantReportProvider
        self.timestampProvider = timestampProvider
        self.idProvider = idProvider
    }

    func prepareBackup(
        for plan: StorageMigrationPlan,
        selection: PortableExportSelection = .all
    ) async throws -> PreMigrationBackupReport {
        async let invariantReport = invariantReportProvider()
        async let snapshot = snapshotService.exportSnapshot(selection: selection)

        return makeReport(
            plan: plan,
            selection: selection,
            invariantReport: try await invariantReport,
            snapshot: try await snapshot
        )
    }
}

private extension PreMigrationBackupService {
    func makeReport(
        plan: StorageMigrationPlan,
        selection: PortableExportSelection,
        invariantReport: StorageInvariantReport,
        snapshot: PortableAppSnapshot
    ) -> PreMigrationBackupReport {
        let blockers = blockersFor(plan: plan, invariantReport: invariantReport, snapshot: snapshot)
        guard blockers.isEmpty else {
            return PreMigrationBackupReport(
                receipt: nil,
                backupPackage: snapshot,
                blockers: blockers
            )
        }

        return PreMigrationBackupReport(
            receipt: PreMigrationBackupReceipt(
                id: idProvider(),
                schemaVersion: preMigrationBackupSchemaVersion,
                createdAt: timestampProvider(),
                sourceLedgerSchemaVersion: plan.sourceLedgerSchemaVersion,
                targetLedgerSchemaVersion: plan.targetLedgerSchemaVersion,
                migrationPlanSchemaVersion: plan.schemaVersion,
                snapshotSchemaVersion: snapshot.metadata.schemaVersion.rawValue,
                snapshotExportedAt: snapshot.metadata.exportedAt,
                selectedCategories: PortableExportCategory.allCases
                    .filter { selection.includes($0) }
                    .sorted { $0.rawValue < $1.rawValue },
                backedUpGoalCount: snapshot.goals.count,
                backedUpDraftCount: snapshot.drafts.count,
                backedUpEvidenceCount: snapshot.evidence.count,
                backedUpFeedbackCount: snapshot.feedback.count,
                backedUpCaptureCount: snapshot.captures.count,
                backedUpTeachingSignalCount: snapshot.teachingSignals.count,
                backedUpAppStateCount: snapshot.appState == .default ? 0 : 1,
                invariantIssueCount: invariantReport.issueCount,
                invariantBlockerCount: invariantReport.blockerCount,
                migrationPlanEntryCount: plan.entries.count,
                migrationMutationEntryCount: plan.mutationEntries.count,
                requiredGates: StorageMigrationPlanGate.allCases.sorted { $0.rawValue < $1.rawValue },
                backupRestoresGateSatisfied: true,
                migrationExecutionAllowed: false
            ),
            backupPackage: snapshot,
            blockers: []
        )
    }

    func blockersFor(
        plan: StorageMigrationPlan,
        invariantReport: StorageInvariantReport,
        snapshot: PortableAppSnapshot
    ) -> [PreMigrationBackupBlocker] {
        var blockers: [PreMigrationBackupBlocker] = []

        blockers += invariantReport.issues
            .filter { $0.severity == .blocker }
            .map {
                PreMigrationBackupBlocker(
                    kind: .invariantBlocker,
                    id: $0.id,
                    message: "Storage invariant blocker must be resolved before this backup can satisfy a migration gate: \($0.message)"
                )
            }

        blockers += StorageMigrationPlanValidator().validate(plan).map {
            PreMigrationBackupBlocker(
                kind: .invalidMigrationPlan,
                id: "\($0)",
                message: "Migration plan validation must be Green before backup can satisfy a migration gate."
            )
        }

        if plan.executionAllowed || plan.entries.contains(where: \.executionAllowed) {
            blockers.append(
                PreMigrationBackupBlocker(
                    kind: .migrationExecutionAlreadyAllowed,
                    id: "plan",
                    message: "PK11 can prepare a backup gate receipt but must not authorize migration execution."
                )
            )
        }

        for entry in plan.mutationEntries where entry.requiredGates.contains(.preMigrationBackup) == false {
            blockers.append(
                PreMigrationBackupBlocker(
                    kind: .mutationMissingBackupGate,
                    id: entry.id,
                    message: "Mutation entry \(entry.id) is missing the pre-migration backup gate."
                )
            )
        }

        if snapshot.metadata.schemaVersion != .v1 {
            blockers.append(
                PreMigrationBackupBlocker(
                    kind: .unsupportedSnapshotSchema,
                    id: snapshot.metadata.schemaVersion.rawValue,
                    message: "Only portable snapshot v1 can satisfy the current pre-migration backup gate."
                )
            )
        }

        if snapshot.goals.isEmpty
            && snapshot.drafts.isEmpty
            && snapshot.evidence.isEmpty
            && snapshot.feedback.isEmpty
            && snapshot.captures.isEmpty
            && snapshot.teachingSignals.isEmpty
            && snapshot.appState == .default {
            blockers.append(
                PreMigrationBackupBlocker(
                    kind: .emptyBackupPackage,
                    id: "portable_snapshot",
                    message: "An empty package is inspectable, but it cannot satisfy a pre-migration backup gate."
                )
            )
        }

        return blockers
    }
}
