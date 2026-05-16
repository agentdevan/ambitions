import XCTest
@testable import Ambitions

final class LivingPlanFreshnessBrokerTests: XCTestCase {
    func testContextInjection() {
        let broker = LivingPlanFreshnessBroker()
        let hint = PlanContextHint(key: "preference", value: "high-tempo")
        
        let updated = broker.withInjectedContext([hint])
        
        XCTAssertEqual(updated.injectedHints.count, 1)
        XCTAssertEqual(updated.injectedHints[0].value, "high-tempo")
    }
    
    func testFreshnessEvaluation() {
        let broker = LivingPlanFreshnessBroker()
        let updated = broker.evaluateFreshness(for: ["g1"], against: 3600)
        XCTAssertEqual(updated.staleGoalIDs, ["g1"])
    }
}
