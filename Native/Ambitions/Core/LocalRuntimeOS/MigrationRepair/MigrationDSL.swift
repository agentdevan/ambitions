import Foundation

let migrationDSLSchemaVersion = "migration_repair_dsl.native.v1"

enum MigrationDSL {
    static let schemaVersion = migrationDSLSchemaVersion
    static let requiredMutationGates: Set<MigrationGate> = Set(MigrationGate.allCases)

    static func requiresMutationReview(_ action: MigrationPlanAction) -> Bool {
        action != .noChange
    }
}

enum MigrationPlanAction: String, Sendable, Equatable, Hashable {
    case noChange = "no_change"
    case versionChange = "version_change"
    case newStoredType = "new_stored_type"
    case removedStoredType = "removed_stored_type"
}

enum MigrationGate: String, Sendable, Equatable, Hashable, CaseIterable {
    case storageInvariantCheck = "storage_invariant_check"
    case preMigrationBackup = "pre_migration_backup"
    case stagedDryRun = "staged_dry_run"
    case restoreRollbackPlan = "restore_rollback_plan"
    case userReview = "user_review"
    case releaseClaimBlocked = "release_claim_blocked"
}

struct MigrationPlanEntry: Identifiable, Sendable, Equatable, Hashable {
    let id: String
    let sourceEntryID: String?
    let targetEntryID: String?
    let storedTypeName: String
    let action: MigrationPlanAction
    let fromVersion: String?
    let toVersion: String?
    let requiredGates: Set<MigrationGate>
    let executionAllowed: Bool
    let notes: String

    var isMutation: Bool {
        action != .noChange
    }

    var missingRequiredSafetyGates: Set<MigrationGate> {
        guard isMutation else { return [] }
        return Self.requiredMutationGates.subtracting(requiredGates)
    }

    var blocksExecution: Bool {
        executionAllowed == false || missingRequiredSafetyGates.isEmpty == false
    }

    static let requiredMutationGates: Set<MigrationGate> = MigrationDSL.requiredMutationGates

    init(
        id: String,
        sourceEntryID: String?,
        targetEntryID: String?,
        storedTypeName: String,
        action: MigrationPlanAction,
        fromVersion: String?,
        toVersion: String?,
        requiredGates: Set<MigrationGate>,
        executionAllowed: Bool = false,
        notes: String
    ) {
        self.id = id
        self.sourceEntryID = sourceEntryID
        self.targetEntryID = targetEntryID
        self.storedTypeName = storedTypeName
        self.action = action
        self.fromVersion = fromVersion
        self.toVersion = toVersion
        self.requiredGates = requiredGates
        self.executionAllowed = executionAllowed
        self.notes = notes
    }
}

struct MigrationPlan: Sendable, Equatable {
    let schemaVersion: String
    let sourceLedgerSchemaVersion: String
    let targetLedgerSchemaVersion: String
    let entries: [MigrationPlanEntry]
    let executionAllowed: Bool

    var mutationEntries: [MigrationPlanEntry] {
        entries.filter(\.isMutation)
    }

    var executionBlockers: [MigrationPlanEntry] {
        entries.filter(\.blocksExecution)
    }

    init(
        schemaVersion: String = migrationDSLSchemaVersion,
        sourceLedgerSchemaVersion: String,
        targetLedgerSchemaVersion: String,
        entries: [MigrationPlanEntry],
        executionAllowed: Bool = false
    ) {
        self.schemaVersion = schemaVersion
        self.sourceLedgerSchemaVersion = sourceLedgerSchemaVersion
        self.targetLedgerSchemaVersion = targetLedgerSchemaVersion
        self.entries = entries
        self.executionAllowed = executionAllowed
    }
}

enum MigrationPlanIssue: Sendable, Equatable, Hashable {
    case unsupportedPlanSchema(String)
    case unsupportedSourceLedger(String)
    case unsupportedTargetLedger(String)
    case duplicatePlanEntryID(String)
    case mutationMissingSafetyGate(String, MigrationGate)
    case migrationExecutionAuthorized(String)
}

struct MigrationPlanValidator: Sendable {
    func validate(_ plan: MigrationPlan) -> [MigrationPlanIssue] {
        var issues: [MigrationPlanIssue] = []

        if plan.schemaVersion != migrationDSLSchemaVersion {
            issues.append(.unsupportedPlanSchema(plan.schemaVersion))
        }
        if plan.sourceLedgerSchemaVersion != schemaLedgerSchemaVersion {
            issues.append(.unsupportedSourceLedger(plan.sourceLedgerSchemaVersion))
        }
        if plan.targetLedgerSchemaVersion != schemaLedgerSchemaVersion {
            issues.append(.unsupportedTargetLedger(plan.targetLedgerSchemaVersion))
        }

        let groupedIDs = Dictionary(grouping: plan.entries, by: \.id)
        for duplicateID in groupedIDs.keys.filter({ groupedIDs[$0, default: []].count > 1 }).sorted() {
            issues.append(.duplicatePlanEntryID(duplicateID))
        }

        for entry in plan.mutationEntries {
            for gate in entry.missingRequiredSafetyGates.sorted(by: { $0.rawValue < $1.rawValue }) {
                issues.append(.mutationMissingSafetyGate(entry.id, gate))
            }
            if entry.executionAllowed {
                issues.append(.migrationExecutionAuthorized(entry.id))
            }
        }

        if plan.executionAllowed {
            issues.append(.migrationExecutionAuthorized("plan"))
        }

        return issues
    }
}
