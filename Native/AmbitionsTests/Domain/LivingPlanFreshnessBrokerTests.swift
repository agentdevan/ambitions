import XCTest
@testable import Ambitions

final class LivingPlanFreshnessBrokerTests: XCTestCase {
    func testEvaluateFreshnessIdentifiesNewStaleGoals() {
        let broker = LivingPlanFreshnessBroker()
        let result = broker.evaluateFreshness(for: ["goal-1"], against: 3600)
        
        XCTAssertEqual(result.staleGoalIDs, ["goal-1"])
        
        let receipt = broker.generateReceipt(for: ["goal-1"])
        XCTAssertEqual(receipt.resultState, .needsConfirmation)
        XCTAssertEqual(receipt.safetyState, .confirmationRequired)
    }
    
    func testEvaluateFreshnessReturnsNoOpWhenNoNewStaleGoals() {
        let broker = LivingPlanFreshnessBroker(staleGoalIDs: ["goal-1"])
        let result = broker.evaluateFreshness(for: ["goal-1"], against: 3600)
        
        XCTAssertEqual(result.staleGoalIDs, ["goal-1"])
        
        let receipt = broker.generateReceipt(for: [])
        XCTAssertEqual(receipt.resultState, .noOp)
        XCTAssertEqual(receipt.safetyState, .normal)
    }
}
