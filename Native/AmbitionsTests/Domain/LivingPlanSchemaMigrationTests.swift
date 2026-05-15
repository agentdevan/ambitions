import XCTest
@testable import Ambitions

final class LivingPlanSchemaMigrationTests: XCTestCase {
    func testMigrationRequiresConfirmationIfHighImpact() {
        let migration = LivingPlanSchemaMigration(
            fromVersion: 1,
            toVersion: 2,
            migrationImpact: .high
        )
        
        XCTAssertTrue(migration.requiresExplicitConfirmation())
        
        let receipt = migration.generateReceipt()
        XCTAssertEqual(receipt.resultState, .needsConfirmation)
        XCTAssertEqual(receipt.safetyState, .confirmationRequired)
        XCTAssertEqual(receipt.undoAvailability, .requiresConfirmation)
    }
    
    func testMigrationDoesNotRequireConfirmationIfLowImpact() {
        let migration = LivingPlanSchemaMigration(
            fromVersion: 2,
            toVersion: 3,
            migrationImpact: .low
        )
        
        XCTAssertFalse(migration.requiresExplicitConfirmation())
        
        let receipt = migration.generateReceipt()
        XCTAssertEqual(receipt.resultState, .completed)
        XCTAssertEqual(receipt.safetyState, .normal)
        XCTAssertEqual(receipt.undoAvailability, .requiresConfirmation)
    }
}
