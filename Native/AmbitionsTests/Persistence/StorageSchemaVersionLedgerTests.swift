import XCTest
@testable import Ambitions

final class StorageSchemaVersionLedgerTests: XCTestCase {
    private let validator = StorageSchemaVersionLedgerValidator()

    func testCurrentLedgerNamesEverySwiftDataRecordAndPortableSnapshotVersion() {
        let ledger = StorageSchemaVersionLedger.current

        XCTAssertEqual(ledger.schemaVersion, storageSchemaVersionLedgerSchemaVersion)
        XCTAssertEqual(validator.validate(ledger), [])
        XCTAssertEqual(ledger.swiftDataEntries.count, StorageSchemaVersionLedgerValidator.requiredSwiftDataTypeNames.count)
        XCTAssertEqual(Set(ledger.swiftDataEntries.map(\.storedTypeName)), StorageSchemaVersionLedgerValidator.requiredSwiftDataTypeNames)
        XCTAssertEqual(
            ledger.portableSnapshotEntries.map(\.currentVersion),
            [PortableSnapshotSchemaVersion.v1.rawValue]
        )
    }

    func testCurrentLedgerIncludesCommandExecutionRecordSchemaType() {
        let ledger = StorageSchemaVersionLedger.current
        let commandEntry = ledger.swiftDataEntries.first(where: { $0.id == "swiftdata.command_execution_record" })

        XCTAssertNotNil(commandEntry)
        XCTAssertEqual(commandEntry?.storedTypeName, "CommandExecutionRecord")
        XCTAssertEqual(commandEntry?.currentVersion, ambitionsCommandExecutionRecordSchemaVersion)
        XCTAssertEqual(commandEntry?.migrationReadiness, .migrationPlanRequired)
        XCTAssertEqual(commandEntry?.rollbackRequirement, .rollbackPlanRequired)
    }

    func testCurrentLedgerBlocksMigrationExecutionUntilFutureMigrationProofExists() {
        let ledger = StorageSchemaVersionLedger.current

        XCTAssertFalse(ledger.migrationExecutionAllowed)
        XCTAssertFalse(ledger.migrationBlockers.isEmpty)
        XCTAssertTrue(ledger.entries.allSatisfy { $0.migrationReadiness != .namedOnly })
        XCTAssertTrue(ledger.entries.allSatisfy { $0.rollbackRequirement != .notExecutable })
    }

    func testValidatorRejectsMalformedLedgerEntries() {
        let duplicate = StorageSchemaVersionEntry(
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
        let ledger = StorageSchemaVersionLedger(
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
        XCTAssertTrue(issues.contains(.migrationExecutionAuthorizedWithoutDryRun("PK07 is ledger-only.")))
    }
}
