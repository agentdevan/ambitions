import XCTest
@testable import Ambitions

final class AmbitionsOSCloseoutTailGateTests: XCTestCase {
    func testEvaluateCloseoutWhenFullyProven() {
        let gate = AmbitionsOSCloseoutTailGate()
        let proof = AmbitionsOSCloseoutTailGateProof(
            finalReviewProven: true,
            legacyDependenciesRetiredProven: true,
            completeSignoffProven: true
        )
        
        let receipt = gate.evaluateCloseout(proof: proof)
        
        XCTAssertEqual(receipt.resultState, .completed)
        XCTAssertEqual(receipt.safetyState, .normal)
    }
    
    func testEvaluateCloseoutWhenNotFullyProven() {
        let gate = AmbitionsOSCloseoutTailGate()
        let proof = AmbitionsOSCloseoutTailGateProof(
            finalReviewProven: true,
            legacyDependenciesRetiredProven: false, // Legacy dependencies proven missing
            completeSignoffProven: true
        )
        
        let receipt = gate.evaluateCloseout(proof: proof)
        
        XCTAssertEqual(receipt.resultState, .needsConfirmation)
        XCTAssertEqual(receipt.safetyState, .confirmationRequired)
    }
}
