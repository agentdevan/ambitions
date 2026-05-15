import XCTest
@testable import Ambitions

final class AmbitionsOSRuntimeTailGateTests: XCTestCase {
    func testEvaluateObligationsWhenFullyProven() {
        let gate = AmbitionsOSRuntimeTailGate()
        let proof = AmbitionsOSRuntimeTailGateProof(
            runtimeProven: true,
            privacyProven: true,
            evaluationProven: true,
            experienceProven: true
        )
        
        let receipt = gate.evaluateObligations(proof: proof)
        
        XCTAssertEqual(receipt.resultState, .completed)
        XCTAssertEqual(receipt.safetyState, .normal)
    }
    
    func testEvaluateObligationsWhenNotFullyProven() {
        let gate = AmbitionsOSRuntimeTailGate()
        let proof = AmbitionsOSRuntimeTailGateProof(
            runtimeProven: true,
            privacyProven: false, // Privacy missing
            evaluationProven: true,
            experienceProven: true
        )
        
        let receipt = gate.evaluateObligations(proof: proof)
        
        XCTAssertEqual(receipt.resultState, .needsConfirmation)
        XCTAssertEqual(receipt.safetyState, .confirmationRequired)
    }
}
