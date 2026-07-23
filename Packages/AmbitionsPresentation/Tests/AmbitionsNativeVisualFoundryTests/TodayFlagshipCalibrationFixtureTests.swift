import XCTest
@testable import AmbitionsNativeVisualFoundry

final class TodayFlagshipCalibrationFixtureTests: XCTestCase {
    func testFixtureFamilyKeepsDeterministicIdentityAndBootstrapNarrative() {
        let fixture = TodayFlagshipCalibrationFixture.preparingForBaby

        XCTAssertEqual(fixture.familyID, "today-flagship/preparing-for-baby/still-counts/v1")
        XCTAssertEqual(fixture.presentContext.dateISO8601, "2026-07-23")
        XCTAssertEqual(fixture.presentContext.relationship, "Thursday · Home before dinner")
        XCTAssertEqual(fixture.primaryStep.id, "step.nursery-ready-for-crib")
        XCTAssertEqual(fixture.primaryStep.parentPursuitID, "goal.welcome-baby-home")
        XCTAssertEqual(fixture.primaryStep.parentPursuitTitle, "Welcome our baby home")
        XCTAssertEqual(fixture.revealedStartHereStep.id, "step.send-launch-brief")
        XCTAssertNotEqual(fixture.primaryStep.id, fixture.revealedStartHereStep.id)
        XCTAssertTrue(fixture.isSynthetic)
    }

    func testFixtureSeparatesCurrentProposedAndSettledTruth() {
        let step = TodayFlagshipCalibrationFixture.preparingForBaby.primaryStep

        XCTAssertEqual(
            step.currentAcceptedTruth,
            "The home corner is clear and the paint sample is ready."
        )
        XCTAssertEqual(
            step.stillCountsProposal.proposedTruth,
            "Record the cleared corner and paint sample as meaningful progress."
        )
        XCTAssertEqual(
            step.stillCountsProposal.settledTruth,
            "The cleared corner and paint sample count as progress toward the nursery."
        )
        XCTAssertNotEqual(step.currentAcceptedTruth, step.stillCountsProposal.proposedTruth)
        XCTAssertNotEqual(step.currentAcceptedTruth, step.stillCountsProposal.settledTruth)
        XCTAssertEqual(step.stillCountsProposal.outcomeTitle, "Still counts")
    }

    func testFixtureRetainsLineageConsequenceTimeProofAndReceiptHistoryCapability() {
        let fixture = TodayFlagshipCalibrationFixture.preparingForBaby
        let step = fixture.primaryStep

        XCTAssertFalse(step.whyItFitsNow.isEmpty)
        XCTAssertFalse(step.materialConsequence.isEmpty)
        XCTAssertEqual(step.temporalContext.exactTime, "4:30 PM")
        XCTAssertEqual(step.temporalContext.owner, "Time")
        XCTAssertTrue(step.stillCountsProposal.createsProof)
        XCTAssertTrue(step.stillCountsProposal.createsReceipt)
        XCTAssertTrue(step.stillCountsProposal.appearsInHistory)
        XCTAssertFalse(step.stillCountsProposal.inverseAvailable)
        XCTAssertEqual(fixture.receipt.id, "receipt.step.nursery-ready-for-crib.still-counts")
        XCTAssertEqual(fixture.receipt.historyID, "history.step.nursery-ready-for-crib")
    }

    func testSupportingTimelineIsObjectLedAndPreservesProtectedReality() {
        let timeline = TodayFlagshipCalibrationFixture.preparingForBaby.timeline

        XCTAssertEqual(timeline.map(\.id), [
            "timeline.nursery-paint-sample",
            "timeline.work-launch-brief",
            "timeline.family-prenatal-walk"
        ])
        XCTAssertEqual(timeline.first?.objectTitle, "Paint the nursery sample")
        XCTAssertEqual(timeline.first?.timeLabel, "10:30 AM")
        XCTAssertTrue(timeline.contains(where: { $0.isProtected }))
        XCTAssertTrue(timeline.contains(where: { $0.isFixed }))
    }

    func testReturnAndRecoveryContractsUseStableObjectScopedAnchors() {
        let fixture = TodayFlagshipCalibrationFixture.preparingForBaby

        XCTAssertEqual(fixture.returnContract.settledStepID, fixture.primaryStep.id)
        XCTAssertEqual(fixture.returnContract.newStartHereStepID, fixture.revealedStartHereStep.id)
        XCTAssertEqual(
            fixture.returnContract.focusAnchorID,
            "today.settled.step.nursery-ready-for-crib"
        )
        XCTAssertEqual(fixture.recovery.stepID, fixture.primaryStep.id)
        XCTAssertEqual(
            fixture.recovery.lastSavedProgress,
            "Cleared the crib corner and kept the paint sample decision."
        )
        XCTAssertEqual(fixture.recovery.availableChoices.map(\.id), [
            "recovery.continue-saved-progress",
            "recovery.keep-step"
        ])
    }

    func testFixtureProvidesLongLocalizationAndDenseTodayStressWithoutNewPolicy() {
        let fixture = TodayFlagshipCalibrationFixture.preparingForBaby

        XCTAssertEqual(fixture.longContent.familyID, fixture.familyID)
        XCTAssertGreaterThan(
            fixture.longContent.primaryStep.title.count,
            fixture.primaryStep.title.count
        )
        XCTAssertEqual(fixture.denseToday.familyID, fixture.familyID)
        XCTAssertGreaterThan(fixture.denseToday.timeline.count, fixture.timeline.count)
        XCTAssertTrue(fixture.denseToday.timeline.filter(\.isProtected).count >= 2)
        XCTAssertTrue(fixture.denseToday.timeline.contains(where: \.isFixed))
    }

    func testNavigationOrderRemainsLockedAcrossOrdinaryAndAdaptiveChrome() {
        XCTAssertEqual(
            TodayFlagshipNavigationCommand.roots.map(\.title),
            ["Today", "Goals", "Time", "You"]
        )
        XCTAssertEqual(
            TodayFlagshipNavigationCommand.globalActions.map(\.title),
            ["Search", "Capture"]
        )
        XCTAssertTrue(TodayFlagshipNavigationCommand.today.isSelectedRoot)
        XCTAssertEqual(
            TodayFlagshipNavigationCommand.roots.filter(\.isSelectedRoot),
            [.today]
        )
    }
}
