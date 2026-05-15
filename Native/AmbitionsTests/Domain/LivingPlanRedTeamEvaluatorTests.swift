import XCTest
@testable import Ambitions

final class LivingPlanRedTeamEvaluatorTests: XCTestCase {
    func testEvaluateFindsIssues() {
        let evaluator = LivingPlanRedTeamEvaluator()
        let issues = evaluator.evaluate(goalIDs: ["goal-1"])
        
        XCTAssertEqual(issues.count, 1)
        XCTAssertEqual(issues.first?.goalID, "goal-1")
        XCTAssertEqual(issues.first?.impactLevel, .medium)
        
        let receipt = evaluator.generateReceipt(for: issues)
        XCTAssertEqual(receipt.resultState, .needsConfirmation)
        XCTAssertEqual(receipt.safetyState, .confirmationRequired)
    }
    
    func testEvaluateReturnsNoOpForNoGoals() {
        let evaluator = LivingPlanRedTeamEvaluator()
        let issues = evaluator.evaluate(goalIDs: [])
        
        XCTAssertTrue(issues.isEmpty)
        
        let receipt = evaluator.generateReceipt(for: issues)
        XCTAssertEqual(receipt.resultState, .noOp)
        XCTAssertEqual(receipt.safetyState, .normal)
    }
}
