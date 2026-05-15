import XCTest
@testable import Ambitions

final class AmbitionsOSExperienceTailGateTests: XCTestCase {
    func testEvaluateExperienceWhenFullyProven() {
        let gate = AmbitionsOSExperienceTailGate()
        let proof = AmbitionsOSExperienceTailGateProof(
            cognitiveLoadProven: true,
            noDashboardProven: true,
            signatureLanguageProven: true
        )
        
        let receipt = gate.evaluateExperience(proof: proof)
        
        XCTAssertEqual(receipt.resultState, .completed)
        XCTAssertEqual(receipt.safetyState, .normal)
    }
    
    func testEvaluateExperienceWhenNotFullyProven() {
        let gate = AmbitionsOSExperienceTailGate()
        let proof = AmbitionsOSExperienceTailGateProof(
            cognitiveLoadProven: true,
            noDashboardProven: false, // Dashboard proven missing
            signatureLanguageProven: true
        )
        
        let receipt = gate.evaluateExperience(proof: proof)
        
        XCTAssertEqual(receipt.resultState, .needsConfirmation)
        XCTAssertEqual(receipt.safetyState, .confirmationRequired)
    }
}
