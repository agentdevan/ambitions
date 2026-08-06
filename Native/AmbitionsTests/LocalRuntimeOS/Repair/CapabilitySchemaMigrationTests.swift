import XCTest
@testable import Ambitions

final class CapabilitySchemaMigrationTests: XCTestCase {
    func testEmptyMigrationCreatesOnlyTheAdditiveCapabilityBoundary() {
        let result = CapabilitySchemaMigration().migrate(nil)

        XCTAssertEqual(result.disposition, .initializedEmpty)
        XCTAssertTrue(result.isSafeForUse)
        XCTAssertEqual(result.snapshot, .empty)
        XCTAssertNil(result.backup)
    }

    func testUnknownSchemaIsQuarantinedWithoutInferringHistoricalContent() {
        let legacy = CapabilityStoreSnapshot(
            schema: CapabilityStoreSchema(version: "capability_store.native.v0"),
            records: [
                CapabilityRecord(
                    id: CapabilityID("capability-legacy"),
                    createdAt: "2026-08-01T00:00:00Z",
                    updatedAt: "2026-08-01T00:00:00Z",
                    name: "Legacy",
                    meaning: "Existing user-owned content.",
                    creationKind: .manual
                )
            ]
        )

        let result = CapabilitySchemaMigration().migrate(legacy)

        XCTAssertEqual(result.disposition, .quarantined)
        XCTAssertFalse(result.isSafeForUse)
        XCTAssertEqual(result.snapshot.records, legacy.records)
        XCTAssertEqual(result.snapshot.quarantines.count, 1)
        XCTAssertEqual(result.backup?.snapshot, legacy)
    }
}
