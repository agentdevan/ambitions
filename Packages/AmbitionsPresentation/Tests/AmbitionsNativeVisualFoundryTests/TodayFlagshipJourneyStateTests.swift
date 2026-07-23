import XCTest
@testable import AmbitionsNativeVisualFoundry

final class TodayFlagshipJourneyStateTests: XCTestCase {
    private let content = TodayFlagshipCalibrationFixture.preparingForBaby

    func testOpeningStartHereIsNonMutatingAndPreservesStableIdentity() {
        var state = TodayFlagshipJourneyState(content: content)
        let acceptedTruth = state.acceptedTruth

        XCTAssertTrue(state.openStartHere())

        XCTAssertEqual(state.phase, .focusedCurrent)
        XCTAssertEqual(state.navigationPath, [.step(id: content.primaryStep.id)])
        XCTAssertEqual(state.acceptedTruth, acceptedTruth)
        XCTAssertNil(state.proposedTruth)
        XCTAssertFalse(state.hasCommittedMutation)
        XCTAssertEqual(state.todayReturnAnchorID, content.returnContract.focusAnchorID)
    }

    func testStillCountsCreatesProposalWithoutReplacingAcceptedTruth() {
        var state = focusedState()
        let acceptedTruth = state.acceptedTruth

        XCTAssertTrue(state.selectStillCounts())

        XCTAssertEqual(state.phase, .reviewingProposal)
        XCTAssertEqual(state.acceptedTruth, acceptedTruth)
        XCTAssertEqual(
            state.proposedTruth,
            content.primaryStep.stillCountsProposal.proposedTruth
        )
        XCTAssertTrue(state.isReviewPresented)
        XCTAssertFalse(state.hasCommittedMutation)
        XCTAssertFalse(state.receiptIsVisible)
    }

    func testCancellingReviewLeavesCanonicalTruthUnchanged() {
        var state = reviewingState()
        let acceptedTruth = state.acceptedTruth

        XCTAssertTrue(state.cancelReview())

        XCTAssertEqual(state.phase, .focusedCurrent)
        XCTAssertEqual(state.acceptedTruth, acceptedTruth)
        XCTAssertNil(state.proposedTruth)
        XCTAssertFalse(state.isReviewPresented)
        XCTAssertFalse(state.hasCommittedMutation)
        XCTAssertEqual(state.navigationPath, [.step(id: content.primaryStep.id)])
    }

    func testCommitShowsSavingBeforeSettlementAndRejectsDuplicateCommit() {
        var state = reviewingState()
        let acceptedTruth = state.acceptedTruth

        XCTAssertTrue(state.beginCommit())
        XCTAssertEqual(state.phase, .savingAcceptedTruth)
        XCTAssertEqual(state.acceptedTruth, acceptedTruth)
        XCTAssertTrue(state.isReviewPresented)
        XCTAssertTrue(state.isCommitInFlight)
        XCTAssertFalse(state.receiptIsVisible)
        XCTAssertFalse(state.beginCommit())
    }

    func testSettlementChangesAcceptedTruthAndRemainsOnFocusedStep() {
        var state = savingState()

        XCTAssertTrue(state.settle())

        XCTAssertEqual(state.phase, .settled)
        XCTAssertEqual(
            state.acceptedTruth,
            content.primaryStep.stillCountsProposal.settledTruth
        )
        XCTAssertNil(state.proposedTruth)
        XCTAssertTrue(state.hasCommittedMutation)
        XCTAssertTrue(state.receiptIsVisible)
        XCTAssertFalse(state.isReviewPresented)
        XCTAssertEqual(state.navigationPath, [.step(id: content.primaryStep.id)])
        XCTAssertEqual(state.focusAnchor, .settledTruth)
    }

    func testHistoryDisclosureRoundTripDoesNotChangeSettledTruth() {
        var state = settledState()
        let settledTruth = state.acceptedTruth

        XCTAssertTrue(state.openHistory())
        XCTAssertTrue(state.isHistoryExpanded)
        XCTAssertEqual(state.phase, .settled)
        XCTAssertEqual(state.acceptedTruth, settledTruth)

        XCTAssertTrue(state.closeHistory())
        XCTAssertFalse(state.isHistoryExpanded)
        XCTAssertEqual(state.phase, .settled)
        XCTAssertEqual(state.acceptedTruth, settledTruth)
        XCTAssertTrue(state.hasCommittedMutation)
    }

    func testReturnProjectsSettledStepAndNewTruthfulStartHereWithContinuityFocus() {
        var state = settledState()

        XCTAssertTrue(state.returnToToday())

        XCTAssertEqual(state.phase, .todayReturned)
        XCTAssertTrue(state.navigationPath.isEmpty)
        XCTAssertFalse(state.primaryStepIsStartHereEligible)
        XCTAssertEqual(state.visibleStartHereStepID, content.revealedStartHereStep.id)
        XCTAssertTrue(state.settledStepRemainsVisible)
        XCTAssertEqual(state.focusAnchor, .returnedSettledStep)
        XCTAssertEqual(state.todayReturnAnchorID, content.returnContract.focusAnchorID)
    }

    func testInterruptedJourneyPreservesIdentityAcceptedTruthAndLastSavedProgress() {
        var state = focusedState()
        let acceptedTruth = state.acceptedTruth

        XCTAssertTrue(state.interrupt())

        XCTAssertEqual(state.phase, .interrupted)
        XCTAssertEqual(state.acceptedTruth, acceptedTruth)
        XCTAssertEqual(state.navigationPath, [.step(id: content.primaryStep.id)])
        XCTAssertEqual(state.lastSavedProgress, content.recovery.lastSavedProgress)
        XCTAssertFalse(state.hasCommittedMutation)
        XCTAssertEqual(state.focusAnchor, .interruption)
    }

    func testRecoveryReviewFiltersChoicesAndDismissalPreservesStep() {
        var state = interruptedState()
        let acceptedTruth = state.acceptedTruth

        XCTAssertTrue(state.openRecoveryReview())
        XCTAssertEqual(state.phase, .recoveryReview)
        XCTAssertTrue(state.isRecoveryPresented)
        XCTAssertEqual(state.availableRecoveryChoiceIDs, [
            "recovery.continue-saved-progress",
            "recovery.keep-step"
        ])

        XCTAssertTrue(state.dismissRecovery())
        XCTAssertEqual(state.phase, .interrupted)
        XCTAssertEqual(state.acceptedTruth, acceptedTruth)
        XCTAssertEqual(state.navigationPath, [.step(id: content.primaryStep.id)])
        XCTAssertFalse(state.hasCommittedMutation)
    }

    func testRecoveryContinuationResumesSavedProgressWithoutInventingSettlement() {
        var state = recoveryReviewState()
        let acceptedTruth = state.acceptedTruth

        XCTAssertTrue(state.continueFromSavedProgress())

        XCTAssertEqual(state.phase, .recoveredContinuation)
        XCTAssertEqual(state.acceptedTruth, acceptedTruth)
        XCTAssertEqual(state.lastSavedProgress, content.recovery.lastSavedProgress)
        XCTAssertFalse(state.receiptIsVisible)
        XCTAssertFalse(state.hasCommittedMutation)
        XCTAssertFalse(state.isRecoveryPresented)
        XCTAssertEqual(state.focusAnchor, .recoveredProgress)
    }

    private func focusedState() -> TodayFlagshipJourneyState {
        var state = TodayFlagshipJourneyState(content: content)
        XCTAssertTrue(state.openStartHere())
        return state
    }

    private func reviewingState() -> TodayFlagshipJourneyState {
        var state = focusedState()
        XCTAssertTrue(state.selectStillCounts())
        return state
    }

    private func savingState() -> TodayFlagshipJourneyState {
        var state = reviewingState()
        XCTAssertTrue(state.beginCommit())
        return state
    }

    private func settledState() -> TodayFlagshipJourneyState {
        var state = savingState()
        XCTAssertTrue(state.settle())
        return state
    }

    private func interruptedState() -> TodayFlagshipJourneyState {
        var state = focusedState()
        XCTAssertTrue(state.interrupt())
        return state
    }

    private func recoveryReviewState() -> TodayFlagshipJourneyState {
        var state = interruptedState()
        XCTAssertTrue(state.openRecoveryReview())
        return state
    }
}
