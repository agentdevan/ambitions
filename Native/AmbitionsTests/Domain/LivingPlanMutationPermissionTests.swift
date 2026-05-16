import XCTest
@testable import Ambitions

final class LivingPlanMutationPermissionTests: XCTestCase {
    func testImpactLevels() {
        XCTAssertEqual(LivingPlanMutationImpactLevel.level0.rawValue, 0)
        XCTAssertEqual(LivingPlanMutationImpactLevel.level5.rawValue, 5)
    }
    
    func testPermissionInitialization() {
        let permission = LivingPlanMutationPermission(
            id: "perm-1",
            title: "Allow Reflow",
            explanation: "Source Atlas update requires plan recompile.",
            impactLevel: .level4,
            requiresExplicitConfirmation: true,
            rollbackAvailable: true
        )
        
        XCTAssertTrue(permission.requiresExplicitConfirmation)
        XCTAssertEqual(permission.impactLevel, .level4)
    }
}
