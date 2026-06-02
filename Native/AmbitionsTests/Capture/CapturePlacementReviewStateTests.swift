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
            route: .timeSeed,
            kind: .oneTimeCommitment,
            privacy: .standard
        )

        let review = capture.placementReviewState

        XCTAssertEqual(review.placementStateTitle, "Ready to Place")
        XCTAssertEqual(review.destinationLabel, "Task / Time")
        XCTAssertEqual(review.objectTypeLabel, "One-time commitment")
        XCTAssertEqual(review.privacyLabel, "Stored on this device")
        XCTAssertTrue(review.consequenceLabel.localizedCaseInsensitiveContains("after you choose Task"))
        XCTAssertTrue(review.consequenceLabel.localizedCaseInsensitiveContains("Time work"))
        XCTAssertTrue(review.confirmationLabel.localizedCaseInsensitiveContains("Today, Goals, or Time"))
        XCTAssertTrue(review.accessibilityValue.localizedCaseInsensitiveContains("Time"))
        XCTAssertFalse(review.accessibilityValue.localizedCaseInsensitiveContains("Plan"))
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

    func testCorrectionReviewNamesUserOwnedOptionsWithoutHiddenLearning() {
        let capture = makeCapture(status: .actionable, route: .goalSeed)

        let correction = capture.correctionReviewState

        XCTAssertEqual(correction.title, "Correction options")
        XCTAssertTrue(correction.routeCorrectionLabel.localizedCaseInsensitiveContains("Place somewhere else"))
        XCTAssertTrue(correction.notGoalLabel.localizedCaseInsensitiveContains("Not a goal"))
        XCTAssertTrue(correction.notNowLabel.localizedCaseInsensitiveContains("Review later"))
        XCTAssertTrue(correction.receiptLabel.localizedCaseInsensitiveContains("reviewable"))
        XCTAssertTrue(correction.learningBoundaryLabel.localizedCaseInsensitiveContains("no hidden memory"))
        XCTAssertFalse(correction.accessibilityValue.localizedCaseInsensitiveContains("AI confidence"))
        XCTAssertFalse(correction.accessibilityValue.localizedCaseInsensitiveContains("confidence percentage"))
        XCTAssertFalse(correction.accessibilityValue.localizedCaseInsensitiveContains("fully automated"))
    }

    func testGoalSeedIncubatorRequiresExplicitPromotionBeforeGoalCreation() {
        let capture = makeCapture(
            status: .needsTriage,
            route: .captureInbox,
            privacy: .privateUserText
        )

        let incubator = capture.goalSeedIncubatorState

        XCTAssertEqual(incubator.title, "Goal Seed Incubator")
        XCTAssertTrue(incubator.whyGoalLabel.localizedCaseInsensitiveContains("not promoted yet"))
        XCTAssertTrue(incubator.startingPositionProofLabel.localizedCaseInsensitiveContains("Capture"))
        XCTAssertTrue(incubator.firstMilestoneAnchorLabel.localizedCaseInsensitiveContains("first bounded milestone"))
        XCTAssertTrue(incubator.firstStepLabel.localizedCaseInsensitiveContains("review the seed setup"))
        XCTAssertTrue(incubator.proofSourceSeedLabel.localizedCaseInsensitiveContains("stay attached"))
        XCTAssertTrue(incubator.promotionConfirmationLabel.localizedCaseInsensitiveContains("no Goal is created"))
        XCTAssertFalse(incubator.accessibilityValue.localizedCaseInsensitiveContains("automatically"))
        XCTAssertFalse(incubator.accessibilityValue.localizedCaseInsensitiveContains("project wizard"))
        XCTAssertFalse(incubator.accessibilityValue.localizedCaseInsensitiveContains("AI confidence"))
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
