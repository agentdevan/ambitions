import XCTest
@testable import Ambitions

final class AmbitionsOSHandoffTailGateTests: XCTestCase {
    func testEvaluateHandoffWhenFullyProven() {
        let gate = AmbitionsOSHandoffTailGate()
        let proof = AmbitionsOSHandoffTailGateProof(
            sourceAtlasDependenciesProven: true,
            intelligenceDataControlProven: true,
            crossTrainGatesProven: true
        )
        
        let receipt = gate.evaluateHandoff(proof: proof)
        
        XCTAssertEqual(receipt.resultState, .completed)
        XCTAssertEqual(receipt.safetyState, .normal)
    }
    
    func testEvaluateHandoffWhenNotFullyProven() {
        let gate = AmbitionsOSHandoffTailGate()
        let proof = AmbitionsOSHandoffTailGateProof(
            sourceAtlasDependenciesProven: true,
            intelligenceDataControlProven: false, // Control proven missing
            crossTrainGatesProven: true
        )
        
        let receipt = gate.evaluateHandoff(proof: proof)
        
        XCTAssertEqual(receipt.resultState, .needsConfirmation)
        XCTAssertEqual(receipt.safetyState, .confirmationRequired)
    }
}
