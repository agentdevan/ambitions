import Foundation
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
        XCTAssertFalse(review.accessibilityValue.localizedCaseInsensitiveContains(["in", "box"].joined()))
        XCTAssertFalse(review.accessibilityValue.localizedCaseInsensitiveContains(["AI", "confidence"].joined(separator: " ")))
        XCTAssertFalse(review.accessibilityValue.localizedCaseInsensitiveContains(["sco", "re"].joined()))
        XCTAssertNotEqual(review.placementStateTitle, "Held for Review")
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
        XCTAssertFalse(review.accessibilityValue.localizedCaseInsensitiveContains(["activity", "feed"].joined(separator: " ")))
        XCTAssertFalse(review.accessibilityValue.localizedCaseInsensitiveContains(["notification", "feed"].joined(separator: " ")))
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
        XCTAssertFalse(correction.accessibilityValue.localizedCaseInsensitiveContains(["AI", "confidence"].joined(separator: " ")))
        XCTAssertFalse(correction.accessibilityValue.localizedCaseInsensitiveContains(["confidence", "percentage"].joined(separator: " ")))
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
        XCTAssertFalse(incubator.accessibilityValue.localizedCaseInsensitiveContains(["AI", "confidence"].joined(separator: " ")))
    }

    func testAMB577CaptureObjectStagePrimitiveReplacesCardsPanelsAndBuckets() throws {
        let contract = CaptureObjectStagePrimitiveContract.current
        let root = repoRoot()
        let screenSource = try String(
            contentsOf: root.appendingPathComponent("Native/Ambitions/Features/Capture/CaptureScreen.swift"),
            encoding: .utf8
        )
        let routeSource = try String(
            contentsOf: root.appendingPathComponent("Native/Ambitions/Features/Capture/CaptureDraftRoutePreviewCard.swift"),
            encoding: .utf8
        )
        let composerSource = try String(
            contentsOf: root.appendingPathComponent("Native/Ambitions/Features/Capture/CaptureAtmosphereComposer.swift"),
            encoding: .utf8
        )

        XCTAssertEqual(contract.primitiveID, "capture-route-ribbon")
        XCTAssertEqual(contract.ownerSurface, "Global Capture")
        XCTAssertEqual(contract.productObject, "Atmosphere Composer")
        XCTAssertEqual(contract.stageName, "Capture Object Stage")
        XCTAssertEqual(contract.screenshotIdentifier, "CaptureObjectStage")
        XCTAssertTrue(contract.keepsCaptureGlobalAction)
        XCTAssertTrue(contract.sourceRouteOrder.contains("placement review"))
        XCTAssertTrue(contract.sourceRouteOrder.contains("continuity lines"))
        XCTAssertTrue(contract.replacesStructures.contains("capture item cards"))
        XCTAssertTrue(contract.replacesStructures.contains("category-like capture buckets"))
        XCTAssertTrue(contract.forbiddenRootPatterns.contains("message-first shell"))
        XCTAssertTrue(contract.accessibilityFallbacks.contains { $0.contains("Dynamic Type") })
        XCTAssertTrue(contract.accessibilityFallbacks.contains { $0.contains("Differentiate Without Color") })
        XCTAssertTrue(screenSource.contains("CaptureStageGroup"))
        XCTAssertTrue(screenSource.contains("CaptureDepthDisclosureStage"))
        XCTAssertTrue(screenSource.contains("Continuity lines"))
        XCTAssertTrue(screenSource.contains("orderedCaptures"))
        XCTAssertTrue(screenSource.contains("captureStageLine"))
        XCTAssertFalse(screenSource.contains("AppCard("))
        XCTAssertFalse(screenSource.contains("StateDrivenMaterialPanel("))
        XCTAssertFalse(screenSource.contains("CaptureGroup"))
        XCTAssertFalse(screenSource.contains("groupedCaptures"))
        XCTAssertFalse(screenSource.contains("captureCard("))
        XCTAssertTrue(routeSource.contains("struct CaptureRouteStagePrimitive"))
        XCTAssertTrue(routeSource.contains("CaptureStageGroup"))
        XCTAssertFalse(routeSource.contains("CaptureDraftRoutePreviewCard"))
        XCTAssertFalse(routeSource.contains("StateDrivenMaterialPanel("))
        XCTAssertFalse(routeSource.contains("RoundedRectangle("))
        XCTAssertTrue(composerSource.contains("CaptureStageGroup(state: livingState"))
        XCTAssertFalse(composerSource.contains("StateDrivenMaterialPanel(context: .capture"))
    }

    func testAMB967CaptureAndCreateGoalStayObjectNativeWithoutSyntheticIssueDriftCopy() throws {
        let root = repoRoot()
        let shellSource = try String(
            contentsOf: root.appendingPathComponent("Native/Ambitions/App/AppShellView.swift"),
            encoding: .utf8
        )
        let composerSource = try String(
            contentsOf: root.appendingPathComponent("Native/Ambitions/Features/Capture/CaptureAtmosphereComposer.swift"),
            encoding: .utf8
        )
        let routePreviewSource = try String(
            contentsOf: root.appendingPathComponent("Native/Ambitions/Features/Capture/CaptureDraftRoutePreviewCard.swift"),
            encoding: .utf8
        )
        let createGoalSource = try String(
            contentsOf: root.appendingPathComponent("Native/Ambitions/Features/Goals/CreateGoalScreen.swift"),
            encoding: .utf8
        )

        XCTAssertTrue(shellSource.contains("activatedRouteReveal"))
        XCTAssertTrue(shellSource.contains("shell.activated-capture.route-reveal"))
        XCTAssertTrue(shellSource.contains("Needs a Place"))
        XCTAssertTrue(shellSource.contains("Ready to Place"))
        XCTAssertTrue(shellSource.contains("Grow into Goal"))
        XCTAssertTrue(shellSource.contains("Held for Review"))
        XCTAssertTrue(shellSource.contains("Local receipt. No cloud route."))
        XCTAssertTrue(createGoalSource.contains("Let Ambitions shape it"))
        XCTAssertTrue(createGoalSource.contains("local save, and the receipt path"))
        XCTAssertFalse(createGoalSource.contains(["Auto", "detect"].joined(separator: "-")))
        XCTAssertFalse(shellSource.contains(["Classifying", "locally"].joined(separator: " ")))
        XCTAssertFalse(shellSource.contains(["Detected", "locally"].joined(separator: " ")))
        XCTAssertFalse(shellSource.contains(["No", "cloud", "classifier"].joined(separator: " ")))
        XCTAssertFalse(composerSource.contains("Review before saving"))
        XCTAssertFalse(routePreviewSource.contains(["Input", "policies"].joined(separator: " ")))
        XCTAssertFalse(routePreviewSource.contains("Thinks"))
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

    private func repoRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
