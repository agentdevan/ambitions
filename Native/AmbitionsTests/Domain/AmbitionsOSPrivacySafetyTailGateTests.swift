import XCTest
@testable import Ambitions

final class AmbitionsOSPrivacySafetyTailGateTests: XCTestCase {
    func testEvaluatePrivacyWhenFullyProven() {
        let gate = AmbitionsOSPrivacySafetyTailGate()
        let proof = AmbitionsOSPrivacySafetyTailGateProof(
            localOnlyProcessingProven: true,
            sensitiveDataRedactionProven: true,
            noHiddenTelemetryProven: true
        )
        
        let receipt = gate.evaluatePrivacy(proof: proof)
        
        XCTAssertEqual(receipt.resultState, .completed)
        XCTAssertEqual(receipt.safetyState, .normal)
    }
    
    func testEvaluatePrivacyWhenNotFullyProven() {
        let gate = AmbitionsOSPrivacySafetyTailGate()
        let proof = AmbitionsOSPrivacySafetyTailGateProof(
            localOnlyProcessingProven: true,
            sensitiveDataRedactionProven: false, // Redaction missing
            noHiddenTelemetryProven: true
        )
        
        let receipt = gate.evaluatePrivacy(proof: proof)
        
        XCTAssertEqual(receipt.resultState, .needsConfirmation)
        XCTAssertEqual(receipt.safetyState, .confirmationRequired)
    }
}
