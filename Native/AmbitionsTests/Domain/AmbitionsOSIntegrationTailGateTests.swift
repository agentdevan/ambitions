import XCTest
@testable import Ambitions

final class AmbitionsOSIntegrationTailGateTests: XCTestCase {
    func testEvaluateIntegrationWhenFullyProven() {
        let gate = AmbitionsOSIntegrationTailGate()
        let proof = AmbitionsOSIntegrationTailGateProof(
            uiIntegrationProven: true,
            dataIntegrationProven: true,
            noSprawlProven: true
        )
        
        let receipt = gate.evaluateIntegration(proof: proof)
        
        XCTAssertEqual(receipt.resultState, .completed)
        XCTAssertEqual(receipt.safetyState, .normal)
    }
    
    func testEvaluateIntegrationWhenNotFullyProven() {
        let gate = AmbitionsOSIntegrationTailGate()
        let proof = AmbitionsOSIntegrationTailGateProof(
            uiIntegrationProven: true,
            dataIntegrationProven: false, // Data integration missing
            noSprawlProven: true
        )
        
        let receipt = gate.evaluateIntegration(proof: proof)
        
        XCTAssertEqual(receipt.resultState, .needsConfirmation)
        XCTAssertEqual(receipt.safetyState, .confirmationRequired)
    }
}
