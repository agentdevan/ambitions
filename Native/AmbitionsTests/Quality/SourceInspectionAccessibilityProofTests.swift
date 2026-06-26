@testable import Ambitions
import XCTest

final class SourceInspectionAccessibilityProofTests: XCTestCase {
    func testAccessibilityProofCoversVoiceOverDynamicTypeReduceMotionRedactionAndHiddenBehavior() {
        let proof = SourceInspectionAccessibilityProof.make()

        XCTAssertEqual(proof.validationFailures(), [])
        XCTAssertTrue(proof.renderedProofRequiredForPublicClaim)
        XCTAssertTrue(proof.physicalDeviceProofRequiredForPublicClaim)

        for state in SourceInspectionState.allCases {
            let stateRows = proof.rows.filter { $0.state == state }
            XCTAssertEqual(Set(stateRows.map(\.configuration)), Set(SourceInspectionAccessibilityConfiguration.allCases))
        }
    }

    func testAccessibilityProofDoesNotClaimRenderedOrPublicAccessibilityReadiness() {
        let proof = SourceInspectionAccessibilityProof.make()

        XCTAssertTrue(proof.rows.allSatisfy(\.blocksPublicAccessibilityClaim))
        XCTAssertTrue(
            proof.rows.contains {
                $0.configuration == .semanticStateAnnouncement &&
                    $0.evidenceSummary.localizedCaseInsensitiveContains("source detail")
            }
        )
        XCTAssertTrue(
            proof.rows.contains {
                $0.configuration == .privacyRedaction &&
                    $0.evidenceSummary.localizedCaseInsensitiveContains("redacted")
            }
        )
    }
}
