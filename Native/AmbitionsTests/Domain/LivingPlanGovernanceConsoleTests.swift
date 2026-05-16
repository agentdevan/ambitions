import XCTest
@testable import Ambitions

final class LivingPlanGovernanceConsoleTests: XCTestCase {
    func testFinalValidationAndHandoff() {
        let console = LivingPlanGovernanceConsole()
        let handoff = console.performFinalValidation()
        
        XCTAssertTrue(handoff.ldiMaturityVerified)
        XCTAssertTrue(handoff.aosQueueReady)
        
        let receipt = console.generateHandoffReceipt(handoff: handoff)
        XCTAssertEqual(receipt.resultState, .completed)
        XCTAssertTrue(receipt.summary.contains("LDI Maturity Train verified and closed"))
    }
}
