import XCTest
@testable import Ambitions

final class StorageMigrationPlanScaffoldTests: XCTestCase {
    private let scaffold = StorageMigrationPlanScaffold()
    private let validator = StorageMigrationPlanValidator()

    func testCurrentLedgerPlansNoStorageMutationAndAllowsNoExecution() {
        let plan = scaffold.plan(
            from: StorageSchemaVersionLedger.current,
            to: StorageSchemaVersionLedger.current
        )

        XCTAssertEqual(plan.schemaVersion, storageMigrationPlanScaffoldSchemaVersion)
        XCTAssertEqual(validator.validate(plan), [])
        XCTAssertTrue(plan.mutationEntries.isEmpty)
        XCTAssertFalse(plan.executionAllowed)
        XCTAssertEqual(plan.entries.count, StorageSchemaVersionLedger.current.entries.count)
        XCTAssertTrue(plan.entries.allSatisfy { $0.action == .noChange })
    }

    func testVersionChangeCreatesBlockedSafetyGatedPlanEntry() throws {
        let target = StorageSchemaVersionLedger(
            entries: StorageSchemaVersionLedger.current.entries.map { entry in
                guard entry.id == "swiftdata.goal_record" else { return entry }
                return StorageSchemaVersionEntry(
                    id: entry.id,
                    family: entry.family,
                    owner: entry.owner,
                    storedTypeName: entry.storedTypeName,
                    currentVersion: "goal_engine.native.v2",
                    versionEvidence: "Test target version.",
                    migrationReadiness: .migrationPlanRequired,
                    rollbackRequirement: .rollbackPlanRequired,
                    notes: entry.notes
                )
            }
        )

        let plan = scaffold.plan(from: .current, to: target)
        let mutation = try XCTUnwrap(plan.mutationEntries.first)

        XCTAssertEqual(mutation.action, .versionChange)
        XCTAssertEqual(mutation.fromVersion, goalEngineSchemaVersion)
        XCTAssertEqual(mutation.toVersion, "goal_engine.native.v2")
        XCTAssertEqual(mutation.requiredGates, StorageMigrationPlanEntry.requiredMutationGates)
        XCTAssertFalse(mutation.executionAllowed)
        XCTAssertTrue(mutation.blocksExecution)
        XCTAssertEqual(validator.validate(plan), [])
    }

    func testAddedAndRemovedStoredTypesRequireSameBlockedSafetyGates() {
        let targetLedger = StorageSchemaVersionLedger(
            entries: StorageSchemaVersionLedger.current.entries.filter { $0.id != "swiftdata.goal_record" } + [
                StorageSchemaVersionEntry(
                    id: "swiftdata.test_future_record",
                    family: .swiftDataRecord,
                    owner: "PK08 test fixture",
                    storedTypeName: "TestFutureRecord",
                    currentVersion: "test_future_record.swiftdata.v1",
                    versionEvidence: "Test future stored type.",
                    migrationReadiness: .migrationPlanRequired,
                    rollbackRequirement: .rollbackPlanRequired,
                    notes: "Test-only future stored type."
                )
            ]
        )

        let plan = scaffold.plan(from: .current, to: targetLedger)
        let mutationIDs = Set(plan.mutationEntries.map(\.id))

        XCTAssertTrue(mutationIDs.contains("migration.removed.swiftdata.goal_record"))
        XCTAssertTrue(mutationIDs.contains("migration.new.swiftdata.test_future_record"))
        XCTAssertTrue(plan.mutationEntries.allSatisfy { $0.requiredGates == StorageMigrationPlanEntry.requiredMutationGates })
        XCTAssertTrue(plan.mutationEntries.allSatisfy { $0.executionAllowed == false })
        XCTAssertEqual(validator.validate(plan), [])
    }

    func testValidatorRejectsExecutableOrUnderGatedMutationPlan() {
        let unsafeEntry = StorageMigrationPlanEntry(
            id: "migration.version_change.swiftdata.goal_record",
            sourceEntryID: "swiftdata.goal_record",
            targetEntryID: "swiftdata.goal_record",
            storedTypeName: "GoalRecord",
            action: .versionChange,
            fromVersion: goalEngineSchemaVersion,
            toVersion: "goal_engine.native.v2",
            requiredGates: [.userReview],
            executionAllowed: true,
            notes: "Unsafe test fixture."
        )
        let plan = StorageMigrationPlan(
            schemaVersion: "storage_migration_plan_scaffold.native.v0",
            sourceLedgerSchemaVersion: "storage_schema_version_ledger.native.v0",
            targetLedgerSchemaVersion: "storage_schema_version_ledger.native.v0",
            entries: [unsafeEntry, unsafeEntry],
            executionAllowed: true
        )

        let issues = validator.validate(plan)

        XCTAssertTrue(issues.contains(.unsupportedPlanSchema("storage_migration_plan_scaffold.native.v0")))
        XCTAssertTrue(issues.contains(.unsupportedSourceLedger("storage_schema_version_ledger.native.v0")))
        XCTAssertTrue(issues.contains(.unsupportedTargetLedger("storage_schema_version_ledger.native.v0")))
        XCTAssertTrue(issues.contains(.duplicatePlanEntryID("migration.version_change.swiftdata.goal_record")))
        XCTAssertTrue(issues.contains(.migrationExecutionAuthorized("migration.version_change.swiftdata.goal_record")))
        XCTAssertTrue(issues.contains(.migrationExecutionAuthorized("plan")))
        XCTAssertTrue(issues.contains(.mutationMissingSafetyGate("migration.version_change.swiftdata.goal_record", .preMigrationBackup)))
        XCTAssertTrue(issues.contains(.mutationMissingSafetyGate("migration.version_change.swiftdata.goal_record", .stagedDryRun)))
        XCTAssertTrue(issues.contains(.mutationMissingSafetyGate("migration.version_change.swiftdata.goal_record", .restoreRollbackPlan)))
    }
}
