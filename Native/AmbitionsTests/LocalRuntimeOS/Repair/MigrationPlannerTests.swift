import XCTest
@testable import Ambitions

final class MigrationPlannerTests: XCTestCase {
    private let planner = MigrationPlanner()
    private let validator = MigrationPlanValidator()

    func testCurrentLedgerPlansNoStorageMutationAndAllowsNoExecution() {
        let plan = planner.plan(
            from: SchemaLedger.current,
            to: SchemaLedger.current
        )

        XCTAssertEqual(plan.schemaVersion, migrationDSLSchemaVersion)
        XCTAssertEqual(validator.validate(plan), [])
        XCTAssertTrue(plan.mutationEntries.isEmpty)
        XCTAssertFalse(plan.executionAllowed)
        XCTAssertEqual(plan.entries.count, SchemaLedger.current.entries.count)
        XCTAssertTrue(plan.entries.allSatisfy { $0.action == .noChange })
    }

    func testVersionChangeCreatesBlockedSafetyGatedPlanEntry() throws {
        let target = SchemaLedger(
            entries: SchemaLedger.current.entries.map { entry in
                guard entry.id == "swiftdata.goal_record" else { return entry }
                return SchemaLedgerEntry(
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

        let plan = planner.plan(from: .current, to: target)
        let mutation = try XCTUnwrap(plan.mutationEntries.first)

        XCTAssertEqual(mutation.action, .versionChange)
        XCTAssertEqual(mutation.fromVersion, goalEngineSchemaVersion)
        XCTAssertEqual(mutation.toVersion, "goal_engine.native.v2")
        XCTAssertEqual(mutation.requiredGates, MigrationPlanEntry.requiredMutationGates)
        XCTAssertFalse(mutation.executionAllowed)
        XCTAssertTrue(mutation.blocksExecution)
        XCTAssertEqual(validator.validate(plan), [])
    }

    func testAddedAndRemovedStoredTypesRequireSameBlockedSafetyGates() {
        let targetLedger = SchemaLedger(
            entries: SchemaLedger.current.entries.filter { $0.id != "swiftdata.goal_record" } + [
                SchemaLedgerEntry(
                    id: "swiftdata.test_future_record",
                    family: .swiftDataRecord,
                    owner: "Repair test fixture",
                    storedTypeName: "TestFutureRecord",
                    currentVersion: "test_future_record.swiftdata.v1",
                    versionEvidence: "Test future stored type.",
                    migrationReadiness: .migrationPlanRequired,
                    rollbackRequirement: .rollbackPlanRequired,
                    notes: "Test-only future stored type."
                )
            ]
        )

        let plan = planner.plan(from: .current, to: targetLedger)
        let mutationIDs = Set(plan.mutationEntries.map(\.id))

        XCTAssertTrue(mutationIDs.contains("migration.removed.swiftdata.goal_record"))
        XCTAssertTrue(mutationIDs.contains("migration.new.swiftdata.test_future_record"))
        XCTAssertTrue(plan.mutationEntries.allSatisfy { $0.requiredGates == MigrationPlanEntry.requiredMutationGates })
        XCTAssertTrue(plan.mutationEntries.allSatisfy { $0.executionAllowed == false })
        XCTAssertEqual(validator.validate(plan), [])
    }

    func testValidatorRejectsExecutableOrUnderGatedMutationPlan() {
        let unsafeEntry = MigrationPlanEntry(
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
        let plan = MigrationPlan(
            schemaVersion: "repair_dsl.native.v0",
            sourceLedgerSchemaVersion: "storage_schema_version_ledger.native.v0",
            targetLedgerSchemaVersion: "storage_schema_version_ledger.native.v0",
            entries: [unsafeEntry, unsafeEntry],
            executionAllowed: true
        )

        let issues = validator.validate(plan)

        XCTAssertTrue(issues.contains(.unsupportedPlanSchema("repair_dsl.native.v0")))
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
