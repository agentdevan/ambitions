import XCTest
@testable import Ambitions

final class LivingPlanGovernanceConsoleTests: XCTestCase {
    func testScanForMaintenanceReturnsActions() {
        let console = LivingPlanGovernanceConsole()
        let actions = console.scanForMaintenance()
        
        XCTAssertFalse(actions.isEmpty)
        XCTAssertEqual(actions.first?.actionType, "reconcile_receipts")
    }
    
    func testGenerateReceiptRequiresConfirmation() {
        let console = LivingPlanGovernanceConsole()
        let action = LivingPlanGovernanceAction(actionType: "test", description: "test desc", requiresConfirmation: true)
        let receipt = console.generateReceipt(for: action)
        
        XCTAssertEqual(receipt.resultState, .needsConfirmation)
        XCTAssertEqual(receipt.safetyState, .confirmationRequired)
        XCTAssertEqual(receipt.undoAvailability, .requiresConfirmation)
    }
}
