import Foundation

let storageMigrationPlanScaffoldSchemaVersion = "storage_migration_plan_scaffold.native.v1"

enum StorageMigrationPlanAction: String, Sendable, Equatable, Hashable {
    case noChange = "no_change"
    case versionChange = "version_change"
    case newStoredType = "new_stored_type"
    case removedStoredType = "removed_stored_type"
}

enum StorageMigrationPlanGate: String, Sendable, Equatable, Hashable, CaseIterable {
    case storageInvariantCheck = "storage_invariant_check"
    case preMigrationBackup = "pre_migration_backup"
    case stagedDryRun = "staged_dry_run"
    case restoreRollbackPlan = "restore_rollback_plan"
    case userReview = "user_review"
    case releaseClaimBlocked = "release_claim_blocked"
}

struct StorageMigrationPlanEntry: Identifiable, Sendable, Equatable, Hashable {
    let id: String
    let sourceEntryID: String?
    let targetEntryID: String?
    let storedTypeName: String
    let action: StorageMigrationPlanAction
    let fromVersion: String?
    let toVersion: String?
    let requiredGates: Set<StorageMigrationPlanGate>
    let executionAllowed: Bool
    let notes: String

    var isMutation: Bool {
        action != .noChange
    }

    var missingRequiredSafetyGates: Set<StorageMigrationPlanGate> {
        guard isMutation else { return [] }
        return Self.requiredMutationGates.subtracting(requiredGates)
    }

    var blocksExecution: Bool {
        executionAllowed == false || missingRequiredSafetyGates.isEmpty == false
    }

    static let requiredMutationGates: Set<StorageMigrationPlanGate> = Set(StorageMigrationPlanGate.allCases)

    init(
        id: String,
        sourceEntryID: String?,
        targetEntryID: String?,
        storedTypeName: String,
        action: StorageMigrationPlanAction,
        fromVersion: String?,
        toVersion: String?,
        requiredGates: Set<StorageMigrationPlanGate>,
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

struct StorageMigrationPlan: Sendable, Equatable {
    let schemaVersion: String
    let sourceLedgerSchemaVersion: String
    let targetLedgerSchemaVersion: String
    let entries: [StorageMigrationPlanEntry]
    let executionAllowed: Bool

    var mutationEntries: [StorageMigrationPlanEntry] {
        entries.filter(\.isMutation)
    }

    var executionBlockers: [StorageMigrationPlanEntry] {
        entries.filter(\.blocksExecution)
    }

    init(
        schemaVersion: String = storageMigrationPlanScaffoldSchemaVersion,
        sourceLedgerSchemaVersion: String,
        targetLedgerSchemaVersion: String,
        entries: [StorageMigrationPlanEntry],
        executionAllowed: Bool = false
    ) {
        self.schemaVersion = schemaVersion
        self.sourceLedgerSchemaVersion = sourceLedgerSchemaVersion
        self.targetLedgerSchemaVersion = targetLedgerSchemaVersion
        self.entries = entries
        self.executionAllowed = executionAllowed
    }
}

struct StorageMigrationPlanScaffold: Sendable {
    func plan(
        from sourceLedger: StorageSchemaVersionLedger,
        to targetLedger: StorageSchemaVersionLedger
    ) -> StorageMigrationPlan {
        let sourceByID = Dictionary(uniqueKeysWithValues: sourceLedger.entries.map { ($0.id, $0) })
        let targetByID = Dictionary(uniqueKeysWithValues: targetLedger.entries.map { ($0.id, $0) })
        let allIDs = Set(sourceByID.keys).union(targetByID.keys).sorted()

        let entries = allIDs.map { id -> StorageMigrationPlanEntry in
            switch (sourceByID[id], targetByID[id]) {
            case let (source?, target?):
                return entryForExistingType(source: source, target: target)
            case let (nil, target?):
                return StorageMigrationPlanEntry(
                    id: "migration.new.\(target.id)",
                    sourceEntryID: nil,
                    targetEntryID: target.id,
                    storedTypeName: target.storedTypeName,
                    action: .newStoredType,
                    fromVersion: nil,
                    toVersion: target.currentVersion,
                    requiredGates: StorageMigrationPlanEntry.requiredMutationGates,
                    notes: "New stored type must be reviewed, backed up, dry-run, and rollback-planned before execution."
                )
            case let (source?, nil):
                return StorageMigrationPlanEntry(
                    id: "migration.removed.\(source.id)",
                    sourceEntryID: source.id,
                    targetEntryID: nil,
                    storedTypeName: source.storedTypeName,
                    action: .removedStoredType,
                    fromVersion: source.currentVersion,
                    toVersion: nil,
                    requiredGates: StorageMigrationPlanEntry.requiredMutationGates,
                    notes: "Removed stored type must preserve restore rollback and user-review proof before execution."
                )
            case (nil, nil):
                preconditionFailure("Union of source and target ids produced an empty migration entry.")
            }
        }

        return StorageMigrationPlan(
            sourceLedgerSchemaVersion: sourceLedger.schemaVersion,
            targetLedgerSchemaVersion: targetLedger.schemaVersion,
            entries: entries
        )
    }

    private func entryForExistingType(
        source: StorageSchemaVersionEntry,
        target: StorageSchemaVersionEntry
    ) -> StorageMigrationPlanEntry {
        if source.currentVersion == target.currentVersion {
            return StorageMigrationPlanEntry(
                id: "migration.no_change.\(target.id)",
                sourceEntryID: source.id,
                targetEntryID: target.id,
                storedTypeName: target.storedTypeName,
                action: .noChange,
                fromVersion: source.currentVersion,
                toVersion: target.currentVersion,
                requiredGates: [],
                notes: "No migration is planned because source and target versions match."
            )
        }

        return StorageMigrationPlanEntry(
            id: "migration.version_change.\(target.id)",
            sourceEntryID: source.id,
            targetEntryID: target.id,
            storedTypeName: target.storedTypeName,
            action: .versionChange,
            fromVersion: source.currentVersion,
            toVersion: target.currentVersion,
            requiredGates: StorageMigrationPlanEntry.requiredMutationGates,
            notes: "Version change is planned only as a blocked scaffold until later PK gates prove backup, dry run, and rollback."
        )
    }
}

enum StorageMigrationPlanIssue: Sendable, Equatable, Hashable {
    case unsupportedPlanSchema(String)
    case unsupportedSourceLedger(String)
    case unsupportedTargetLedger(String)
    case duplicatePlanEntryID(String)
    case mutationMissingSafetyGate(String, StorageMigrationPlanGate)
    case migrationExecutionAuthorized(String)
}

struct StorageMigrationPlanValidator: Sendable {
    func validate(_ plan: StorageMigrationPlan) -> [StorageMigrationPlanIssue] {
        var issues: [StorageMigrationPlanIssue] = []

        if plan.schemaVersion != storageMigrationPlanScaffoldSchemaVersion {
            issues.append(.unsupportedPlanSchema(plan.schemaVersion))
        }
        if plan.sourceLedgerSchemaVersion != storageSchemaVersionLedgerSchemaVersion {
            issues.append(.unsupportedSourceLedger(plan.sourceLedgerSchemaVersion))
        }
        if plan.targetLedgerSchemaVersion != storageSchemaVersionLedgerSchemaVersion {
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
