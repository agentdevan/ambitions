import XCTest
@testable import Ambitions

final class LivingPlanContinuitySyncTests: XCTestCase {
    func testPrivacyWinsPolicy() {
        let sync = LivingPlanContinuitySync(privacyPolicy: .mostRestrictiveWins)
        XCTAssertEqual(sync.privacyPolicy, .mostRestrictiveWins)
    }
    
    func testLocalOnlyRequiresConfirmation() {
        let sync = LivingPlanContinuitySync(privacyPolicy: .localOnly)
        XCTAssertTrue(sync.requiresExplicitConfirmation())
        XCTAssertEqual(sync.generateReceipt().resultState, .needsConfirmation)
    }
    
    func testPendingChangesRequireConfirmation() {
        let change = LivingPlanMutationPermission(
            id: "c1",
            title: "T",
            explanation: "E",
            impactLevel: .level3,
            requiresExplicitConfirmation: true,
            rollbackAvailable: true
        )
        let sync = LivingPlanContinuitySync(pendingChanges: [change])
        XCTAssertTrue(sync.requiresExplicitConfirmation())
    }
}
