import XCTest
@testable import Ambitions

final class LivingPlanContinuitySyncTests: XCTestCase {
    func testContinuitySyncRequiresConfirmation() {
        let permission = LivingPlanMutationPermission(
            id: "perm-1",
            title: "Update",
            explanation: "Updates.",
            impactLevel: .medium,
            requiresExplicitConfirmation: true,
            rollbackAvailable: true
        )
        
        let sync = LivingPlanContinuitySync(
            pendingChanges: [permission],
            isSyncRequired: true
        )
        
        XCTAssertTrue(sync.requiresExplicitConfirmation())
        
        let receipt = sync.generateReceipt()
        XCTAssertEqual(receipt.resultState, .needsConfirmation)
        XCTAssertEqual(receipt.safetyState, .confirmationRequired)
    }
    
    func testContinuitySyncDoesNotRequireConfirmationIfEmpty() {
        let sync = LivingPlanContinuitySync(
            pendingChanges: [],
            isSyncRequired: false
        )
        
        XCTAssertFalse(sync.requiresExplicitConfirmation())
        
        let receipt = sync.generateReceipt()
        XCTAssertEqual(receipt.resultState, .noOp)
        XCTAssertEqual(receipt.safetyState, .normal)
    }
}
