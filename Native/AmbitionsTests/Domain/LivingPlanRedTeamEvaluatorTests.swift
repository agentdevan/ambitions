import XCTest
@testable import Ambitions

final class LivingPlanRedTeamEvaluatorTests: XCTestCase {
    func testDashboardStateCalculation() {
        let evaluator = LivingPlanRedTeamEvaluator()
        let issues = [
            LivingPlanRedTeamIssue(goalID: "g1", title: "T", summary: "S", impactLevel: .level3)
        ]
        
        let dashboard = evaluator.generateDashboardState(
            recompileCount: 2,
            syncState: "Synced",
            issues: issues
        )
        
        XCTAssertEqual(dashboard.redTeamIssueCount, 1)
        XCTAssertEqual(dashboard.recompileNeededCount, 2)
        XCTAssertEqual(dashboard.syncState, "Synced")
        // Trust = 1.0 - (1 * 0.1) - (2 * 0.05) = 0.8
        XCTAssertEqual(dashboard.trustIndicator, 0.8)
    }
}
