import XCTest
@testable import Ambitions

final class SchemaLedgerTests: XCTestCase {
    private let validator = SchemaLedgerValidator()

    func testCurrentLedgerNamesEverySwiftDataRecordAndPortableSnapshotVersion() {
        let ledger = SchemaLedger.current

        XCTAssertEqual(ledger.schemaVersion, schemaLedgerSchemaVersion)
        XCTAssertEqual(validator.validate(ledger), [])
        XCTAssertEqual(ledger.swiftDataEntries.count, SchemaLedgerValidator.requiredSwiftDataTypeNames.count)
        XCTAssertEqual(Set(ledger.swiftDataEntries.map(\.storedTypeName)), SchemaLedgerValidator.requiredSwiftDataTypeNames)
        XCTAssertEqual(
            ledger.portableSnapshotEntries.map(\.currentVersion),
            [PortableSnapshotSchemaVersion.v1.rawValue]
        )
    }

    func testCurrentLedgerIncludesCommandExecutionRecordSchemaType() {
        let ledger = SchemaLedger.current
        let commandEntry = ledger.swiftDataEntries.first(where: { $0.id == "swiftdata.command_execution_record" })

        XCTAssertNotNil(commandEntry)
        XCTAssertEqual(commandEntry?.storedTypeName, "CommandExecutionRecord")
        XCTAssertEqual(commandEntry?.currentVersion, ambitionsCommandExecutionRecordSchemaVersion)
        XCTAssertEqual(commandEntry?.migrationReadiness, .migrationPlanRequired)
        XCTAssertEqual(commandEntry?.rollbackRequirement, .rollbackPlanRequired)
    }

    func testCurrentLedgerIncludesSideEffectLedgerSchemaType() {
        let ledger = SchemaLedger.current
        let sideEffectEntry = ledger.swiftDataEntries.first(where: { $0.id == "swiftdata.side_effect_ledger_record" })

        XCTAssertNotNil(sideEffectEntry)
        XCTAssertEqual(sideEffectEntry?.storedTypeName, "SideEffectLedgerStorageRecord")
        XCTAssertEqual(sideEffectEntry?.currentVersion, sideEffectLedgerSchemaVersion)
    }

    func testCurrentLedgerIncludesEntityRevisionTombstoneSchemaType() {
        let ledger = SchemaLedger.current
        let tombstoneEntry = ledger.swiftDataEntries.first(where: { $0.id == "swiftdata.entity_revision_tombstone_record" })

        XCTAssertNotNil(tombstoneEntry)
        XCTAssertEqual(tombstoneEntry?.storedTypeName, "EntityRevisionTombstoneRecord")
        XCTAssertEqual(tombstoneEntry?.currentVersion, entityRevisionTombstoneSchemaVersion)
        XCTAssertEqual(tombstoneEntry?.migrationReadiness, .migrationPlanRequired)
        XCTAssertEqual(tombstoneEntry?.rollbackRequirement, .rollbackPlanRequired)
    }

    func testCurrentLedgerIncludesReminderRecordSchemaType() {
        let ledger = SchemaLedger.current
        let reminderEntry = ledger.swiftDataEntries.first(where: { $0.id == "swiftdata.reminder_record" })

        XCTAssertNotNil(reminderEntry)
        XCTAssertEqual(reminderEntry?.storedTypeName, "ReminderRecord")
        XCTAssertEqual(reminderEntry?.currentVersion, "reminder_record.swiftdata.v1")
        XCTAssertEqual(reminderEntry?.migrationReadiness, .migrationPlanRequired)
        XCTAssertEqual(reminderEntry?.rollbackRequirement, .rollbackPlanRequired)
    }

    func testCurrentLedgerBlocksMigrationExecutionUntilFutureMigrationProofExists() {
        let ledger = SchemaLedger.current

        XCTAssertFalse(ledger.migrationExecutionAllowed)
        XCTAssertFalse(ledger.migrationBlockers.isEmpty)
        XCTAssertTrue(ledger.entries.allSatisfy { $0.migrationReadiness != .namedOnly })
        XCTAssertTrue(ledger.entries.allSatisfy { $0.rollbackRequirement != .notExecutable })
    }

    func testValidatorRejectsMalformedLedgerEntries() {
        let duplicate = SchemaLedgerEntry(
            id: "swiftdata.goal_record",
            family: .swiftDataRecord,
            owner: "AmbitionsPersistenceStore",
            storedTypeName: "",
            currentVersion: "",
            versionEvidence: "Broken test fixture.",
            migrationReadiness: .namedOnly,
            rollbackRequirement: .notExecutable,
            notes: "Broken test fixture."
        )
        let ledger = SchemaLedger(
            schemaVersion: "storage_schema_version_ledger.native.v0",
            entries: [duplicate, duplicate],
            migrationExecutionAllowed: true
        )

        let issues = validator.validate(ledger)

        XCTAssertTrue(issues.contains(.unsupportedLedgerSchema("storage_schema_version_ledger.native.v0")))
        XCTAssertTrue(issues.contains(.duplicateEntryID("swiftdata.goal_record")))
        XCTAssertTrue(issues.contains(.emptyStoredTypeName("swiftdata.goal_record")))
        XCTAssertTrue(issues.contains(.emptyCurrentVersion("swiftdata.goal_record")))
        XCTAssertTrue(issues.contains(.missingSwiftDataRecord("GoalRecord")))
        XCTAssertTrue(issues.contains(.migrationExecutionAuthorizedWithoutDryRun("SchemaLedger is inventory-only.")))
    }
}
