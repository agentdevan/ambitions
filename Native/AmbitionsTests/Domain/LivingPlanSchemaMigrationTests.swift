import XCTest
@testable import Ambitions

final class LivingPlanSchemaMigrationTests: XCTestCase {
    func testMigrationConfirmation() {
        let lowImpact = LivingPlanSchemaMigration(
            fromVersion: 1,
            toVersion: 2,
            migrationImpact: .level2
        )
        XCTAssertFalse(lowImpact.requiresExplicitConfirmation())
        
        let highImpact = LivingPlanSchemaMigration(
            fromVersion: 1,
            toVersion: 2,
            migrationImpact: .level4
        )
        XCTAssertTrue(highImpact.requiresExplicitConfirmation())
    }
    
    func testEncryptedArchiveFlag() {
        let migration = LivingPlanSchemaMigration(
            fromVersion: 1,
            toVersion: 2,
            migrationImpact: .level1,
            isEncryptedArchive: true
        )
        XCTAssertTrue(migration.isEncryptedArchive)
        XCTAssertTrue(migration.generateReceipt().changedFacts[0].summary.contains("Encryption: ON"))
    }
}
