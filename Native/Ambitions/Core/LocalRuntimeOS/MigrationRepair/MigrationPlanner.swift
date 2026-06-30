import Foundation

struct MigrationPlanner: Sendable {
    func plan(
        from sourceLedger: SchemaLedger,
        to targetLedger: SchemaLedger
    ) -> MigrationPlan {
        let sourceByID = Dictionary(uniqueKeysWithValues: sourceLedger.entries.map { ($0.id, $0) })
        let targetByID = Dictionary(uniqueKeysWithValues: targetLedger.entries.map { ($0.id, $0) })
        let allIDs = Set(sourceByID.keys).union(targetByID.keys).sorted()

        let entries = allIDs.map { id -> MigrationPlanEntry in
            switch (sourceByID[id], targetByID[id]) {
            case let (source?, target?):
                return entryForExistingType(source: source, target: target)
            case let (nil, target?):
                return MigrationPlanEntry(
                    id: "migration.new.\(target.id)",
                    sourceEntryID: nil,
                    targetEntryID: target.id,
                    storedTypeName: target.storedTypeName,
                    action: .newStoredType,
                    fromVersion: nil,
                    toVersion: target.currentVersion,
                    requiredGates: MigrationPlanEntry.requiredMutationGates,
                    notes: "New stored type must be reviewed, backed up, dry-run, and rollback-planned before execution."
                )
            case let (source?, nil):
                return MigrationPlanEntry(
                    id: "migration.removed.\(source.id)",
                    sourceEntryID: source.id,
                    targetEntryID: nil,
                    storedTypeName: source.storedTypeName,
                    action: .removedStoredType,
                    fromVersion: source.currentVersion,
                    toVersion: nil,
                    requiredGates: MigrationPlanEntry.requiredMutationGates,
                    notes: "Removed stored type must preserve restore rollback and user-review proof before execution."
                )
            case (nil, nil):
                preconditionFailure("Union of source and target ids produced an empty migration entry.")
            }
        }

        return MigrationPlan(
            sourceLedgerSchemaVersion: sourceLedger.schemaVersion,
            targetLedgerSchemaVersion: targetLedger.schemaVersion,
            entries: entries
        )
    }

    private func entryForExistingType(
        source: SchemaLedgerEntry,
        target: SchemaLedgerEntry
    ) -> MigrationPlanEntry {
        if source.currentVersion == target.currentVersion {
            return MigrationPlanEntry(
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

        return MigrationPlanEntry(
            id: "migration.version_change.\(target.id)",
            sourceEntryID: source.id,
            targetEntryID: target.id,
            storedTypeName: target.storedTypeName,
            action: .versionChange,
            fromVersion: source.currentVersion,
            toVersion: target.currentVersion,
            requiredGates: MigrationPlanEntry.requiredMutationGates,
            notes: "Version change is planned only as a blocked migration repair entry until safety gates prove backup, dry run, rollback, and user review."
        )
    }
}
