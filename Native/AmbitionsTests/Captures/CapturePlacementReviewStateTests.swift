import XCTest
@testable import Ambitions

final class CapturePlacementReviewStateTests: XCTestCase {
    func testNeedsPlaceReviewKeepsCaptureCorrectableAndUserOwned() {
        let capture = makeCapture(
            status: .needsTriage,
            route: .captureInbox,
            privacy: .privateUserText
        )

        let review = capture.placementReviewState

        XCTAssertEqual(review.placementStateTitle, "Needs a Place")
        XCTAssertEqual(review.destinationLabel, "Needs a Place")
        XCTAssertEqual(review.privacyLabel, "Private detail hidden")
        XCTAssertTrue(review.consequenceLabel.localizedCaseInsensitiveContains("correctable"))
        XCTAssertTrue(review.confirmationLabel.localizedCaseInsensitiveContains("you choose"))
        XCTAssertFalse(review.accessibilityValue.localizedCaseInsensitiveContains("inbox"))
        XCTAssertFalse(review.accessibilityValue.localizedCaseInsensitiveContains("AI confidence"))
        XCTAssertFalse(review.accessibilityValue.localizedCaseInsensitiveContains("score"))
    }

    func testReadyToPlaceReviewNamesDestinationAndConsequenceBeforeChange() {
        let capture = makeCapture(
            status: .actionable,
            route: .planSeed,
            kind: .oneTimeCommitment,
            privacy: .standard
        )

        let review = capture.placementReviewState

        XCTAssertEqual(review.placementStateTitle, "Ready to Place")
        XCTAssertEqual(review.destinationLabel, "Task / Plan")
        XCTAssertEqual(review.objectTypeLabel, "One-time commitment")
        XCTAssertEqual(review.privacyLabel, "Stored on this device")
        XCTAssertTrue(review.consequenceLabel.localizedCaseInsensitiveContains("after you choose Task"))
        XCTAssertTrue(review.confirmationLabel.localizedCaseInsensitiveContains("Today, Goals, or Plan"))
    }

    func testArchiveReviewRemainsAConsequenceNotAFeed() {
        let capture = makeCapture(status: .archived, route: .archive)

        let review = capture.placementReviewState

        XCTAssertEqual(review.placementStateTitle, "Archived")
        XCTAssertEqual(review.destinationLabel, "Archive")
        XCTAssertEqual(review.confirmationLabel, "No active placement changes are available.")
        XCTAssertTrue(review.archiveLabel.localizedCaseInsensitiveContains("out of active review"))
        XCTAssertFalse(review.accessibilityValue.localizedCaseInsensitiveContains("activity feed"))
        XCTAssertFalse(review.accessibilityValue.localizedCaseInsensitiveContains("notification feed"))
    }

    private func makeCapture(
        status: CaptureStatus,
        route: CaptureRoute,
        kind: CaptureKind = .raw,
        privacy: EventLedgerPrivacyClassification = .privateUserText
    ) -> Capture {
        Capture(
            id: "capture-\(status.rawValue)-\(route.rawValue)",
            createdAt: "2026-05-04T12:00:00Z",
            updatedAt: "2026-05-04T12:00:00Z",
            rawText: "Find a place for this",
            sourceType: .todayQuickCapture,
            status: status,
            linkedGoalID: nil,
            kind: kind,
            route: route,
            privacy: privacy
        )
    }
}
