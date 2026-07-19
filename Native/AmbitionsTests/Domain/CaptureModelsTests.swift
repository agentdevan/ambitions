import XCTest
@testable import Ambitions

final class CaptureModelsTests: XCTestCase {
    func testProofAndConstraintRoutesMapToDeliverableSeedDestination() {
        XCTAssertEqual(CaptureRoute.proofItem.triageDestination, .deliverableSeed)
        XCTAssertEqual(CaptureRoute.constraintItem.triageDestination, .deliverableSeed)
    }

    func testCaptureRouteTitlesAndCompatibilityRoutesAreStable() {
        XCTAssertEqual(CaptureRoute.proofItem.title, "Proof")
        XCTAssertEqual(CaptureRoute.constraintItem.title, "Constraint")
        XCTAssertEqual(CaptureRoute.proofItem.rawValue, "proof_item")
        XCTAssertEqual(CaptureRoute.constraintItem.rawValue, "constraint_item")
    }

    func testCaptureRouteAvoidsAiCopyAndSupportsManualDecision() {
        let route = CaptureRoute.proofItem
        XCTAssertFalse(route.title.localizedCaseInsensitiveContains("AI"))
        XCTAssertEqual(route.triageDestination, .deliverableSeed)

        let kind = CaptureKind.deliverableSeed
        XCTAssertEqual(kind.title, "Deliverable seed")
        XCTAssertEqual(kind.rawValue, "deliverable_seed")
    }

    func testBackgroundFactRouteMarkersStayCalmAndTyped() {
        XCTAssertEqual(CaptureBackgroundFactRoute.needsPlace.title, "Needs a Place")
        XCTAssertEqual(CaptureBackgroundFactRoute.needsReview.title, "Needs Review")
        XCTAssertTrue(CaptureBackgroundFactRoute.needsPlace.explanation.contains("owning surface"))
        XCTAssertTrue(CaptureBackgroundFactRoute.needsReview.explanation.contains("checked before runtime use"))
    }

    func testStagedInputLibraryProjectsDeterministicKindsAndPolicies() {
        let projections = CaptureStagedInputProjection.supported(sourceSurface: "Capture")

        XCTAssertEqual(projections.map(\.kind.title), ["Text", "Voice", "Image", "Share", "Proof", "Context"])
        XCTAssertEqual(projections.count, 6)
        XCTAssertEqual(projections.first?.provenanceLabel, "Typed in Capture")
        XCTAssertEqual(projections.first?.privacyLabel, "Stored on this device")
        XCTAssertEqual(projections.first?.routeCandidates.map(\.title), ["Step", "Goal", "Needs a Place"])
        XCTAssertTrue(projections.first?.accessibilityReviewSummary.localizedCaseInsensitiveContains("local-first") == true)
        XCTAssertTrue(projections.last?.routeCandidateSummary.contains("Review later") == true)
        XCTAssertTrue(projections.allSatisfy { $0.visibleCopy.localizedCaseInsensitiveContains("AI confidence") == false })
    }
}
