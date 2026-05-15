import XCTest
@testable import Ambitions

final class LivingPlanMutationPermissionTests: XCTestCase {
    func testMutationPermissionInitialization() {
        let permission = LivingPlanMutationPermission(
            id: "perm-1",
            title: "Update Goal",
            explanation: "Updates the goal based on new evidence.",
            impactLevel: .medium,
            requiresExplicitConfirmation: true,
            rollbackAvailable: true,
            affectedGoalIDs: ["goal-1"]
        )
        
        XCTAssertEqual(permission.id, "perm-1")
        XCTAssertEqual(permission.title, "Update Goal")
        XCTAssertEqual(permission.explanation, "Updates the goal based on new evidence.")
        XCTAssertEqual(permission.impactLevel, .medium)
        XCTAssertTrue(permission.requiresExplicitConfirmation)
        XCTAssertTrue(permission.rollbackAvailable)
        XCTAssertEqual(permission.affectedGoalIDs, ["goal-1"])
    }
}
