import XCTest
@testable import Ambitions

final class AmbitionsOSEvaluationTailGateTests: XCTestCase {
    func testEvaluateCoverageWhenFullyProven() {
        let gate = AmbitionsOSEvaluationTailGate()
        let proof = AmbitionsOSEvaluationTailGateProof(
            goldenScenariosProven: true,
            fixtureCoverageProven: true,
            privacyPerformanceProven: true
        )
        
        let receipt = gate.evaluateCoverage(proof: proof)
        
        XCTAssertEqual(receipt.resultState, .completed)
        XCTAssertEqual(receipt.safetyState, .normal)
    }
    
    func testEvaluateCoverageWhenNotFullyProven() {
        let gate = AmbitionsOSEvaluationTailGate()
        let proof = AmbitionsOSEvaluationTailGateProof(
            goldenScenariosProven: true,
            fixtureCoverageProven: false, // Fixture coverage missing
            privacyPerformanceProven: true
        )
        
        let receipt = gate.evaluateCoverage(proof: proof)
        
        XCTAssertEqual(receipt.resultState, .needsConfirmation)
        XCTAssertEqual(receipt.safetyState, .confirmationRequired)
    }
}
