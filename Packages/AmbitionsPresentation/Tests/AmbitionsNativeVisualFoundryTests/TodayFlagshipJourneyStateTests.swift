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

    func testFullDayFromInitialTodayIsNonMutatingAndKeepsDepthWhenOpeningPrimaryStep() {
        var state = TodayFlagshipJourneyState(content: content)
        let acceptedTruth = state.acceptedTruth

        XCTAssertTrue(state.openFullDay())
        XCTAssertEqual(state.navigationPath, [.fullDay(origin: .todayInitial)])
        XCTAssertEqual(state.phase, .todayInitial)
        XCTAssertEqual(state.acceptedTruth, acceptedTruth)
        XCTAssertNil(state.proposedTruth)
        XCTAssertFalse(state.hasCommittedMutation)
        XCTAssertFalse(state.receiptIsVisible)

        XCTAssertTrue(state.openStepFromFullDay(id: content.primaryStep.id))
        XCTAssertEqual(
            state.navigationPath,
            [
                .fullDay(origin: .todayInitial),
                .step(id: content.primaryStep.id)
            ]
        )
        XCTAssertEqual(state.phase, .focusedCurrent)
        XCTAssertEqual(state.acceptedTruth, acceptedTruth)

        state.reconcileNavigationPath([.fullDay(origin: .todayInitial)])
        XCTAssertEqual(state.phase, .todayInitial)
        XCTAssertEqual(state.focusAnchor, .fullDayStep)
        XCTAssertEqual(state.acceptedTruth, acceptedTruth)

        state.reconcileNavigationPath([])
        XCTAssertEqual(state.phase, .todayInitial)
        XCTAssertEqual(state.focusAnchor, .fullDayAction)
        XCTAssertEqual(state.acceptedTruth, acceptedTruth)
    }

    func testReturnedFullDayKeepsSettledTruthReadOnlyAndRestoresReturnedOrigin() {
        var state = TodayFlagshipJourneyState.preview(
            content: content,
            phase: .todayReturned
        )
        let settledTruth = state.acceptedTruth

        XCTAssertTrue(state.openFullDay())
        XCTAssertEqual(state.navigationPath, [.fullDay(origin: .todayReturned)])
        XCTAssertEqual(state.phase, .todayReturned)
        XCTAssertEqual(state.acceptedTruth, settledTruth)
        XCTAssertTrue(state.hasCommittedMutation)
        XCTAssertTrue(state.receiptIsVisible)
        XCTAssertEqual(
            content.nowAnchorObjectID(for: .todayReturned),
            content.revealedStartHereStep.id
        )

        XCTAssertFalse(state.openStepFromFullDay(id: content.primaryStep.id))
        XCTAssertFalse(state.openStepFromFullDay(id: content.revealedStartHereStep.id))
        XCTAssertEqual(state.navigationPath, [.fullDay(origin: .todayReturned)])
        XCTAssertEqual(state.phase, .todayReturned)
        XCTAssertEqual(state.acceptedTruth, settledTruth)

        state.reconcileNavigationPath([])
        XCTAssertEqual(state.phase, .todayReturned)
        XCTAssertEqual(state.focusAnchor, .fullDayAction)
        XCTAssertEqual(state.acceptedTruth, settledTruth)
        XCTAssertTrue(state.hasCommittedMutation)
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

    func testRejectedCommitLeavesSavingWithAcceptedTruthAndRecovery() {
        var state = savingState()
        let acceptedTruth = state.acceptedTruth
        let proposedTruth = state.proposedTruth

        XCTAssertTrue(state.resolveCommit(succeeded: false))

        XCTAssertEqual(state.phase, .failedSettlement)
        XCTAssertEqual(state.acceptedTruth, acceptedTruth)
        XCTAssertEqual(state.proposedTruth, proposedTruth)
        XCTAssertFalse(state.isCommitInFlight)
        XCTAssertTrue(state.isReviewPresented)
        XCTAssertFalse(state.hasCommittedMutation)
        XCTAssertFalse(state.receiptIsVisible)
        XCTAssertEqual(state.focusAnchor, .failedSettlement)

        XCTAssertTrue(state.retryFailedCommit())
        XCTAssertEqual(state.phase, .savingAcceptedTruth)
        XCTAssertEqual(state.acceptedTruth, acceptedTruth)
        XCTAssertEqual(state.proposedTruth, proposedTruth)
        XCTAssertTrue(state.isCommitInFlight)
    }

    func testDismissingFailedCommitReturnsToFocusedAcceptedTruth() {
        var state = savingState()
        let acceptedTruth = state.acceptedTruth
        XCTAssertTrue(state.resolveCommit(succeeded: false))

        XCTAssertTrue(state.dismissFailedCommit())

        XCTAssertEqual(state.phase, .focusedCurrent)
        XCTAssertEqual(state.acceptedTruth, acceptedTruth)
        XCTAssertNil(state.proposedTruth)
        XCTAssertFalse(state.isReviewPresented)
        XCTAssertFalse(state.hasCommittedMutation)
        XCTAssertEqual(state.focusAnchor, .focusedIdentity)
    }

    func testSuccessfulCommitResolutionStillSettlesExactTruth() {
        var state = savingState()

        XCTAssertTrue(state.resolveCommit(succeeded: true))

        XCTAssertEqual(state.phase, .settled)
        XCTAssertEqual(
            state.acceptedTruth,
            content.primaryStep.stillCountsProposal.settledTruth
        )
        XCTAssertNil(state.proposedTruth)
        XCTAssertTrue(state.hasCommittedMutation)
        XCTAssertEqual(state.focusAnchor, .settledTruth)
    }

    func testSupportingRoutesArePhaseBoundAndRestoreSemanticFocus() {
        var focused = focusedState()

        XCTAssertTrue(focused.openSupportingRoute(.goalDetail))
        XCTAssertEqual(focused.supportingRoute, .goalDetail)
        XCTAssertEqual(focused.focusAnchor, .goalDetail)
        XCTAssertFalse(focused.openSupportingRoute(.consequenceDetails))

        XCTAssertTrue(focused.closeSupportingRoute())
        XCTAssertNil(focused.supportingRoute)
        XCTAssertEqual(focused.focusAnchor, .focusedIdentity)

        var reviewing = reviewingState()
        XCTAssertTrue(reviewing.openSupportingRoute(.consequenceDetails))
        XCTAssertEqual(reviewing.focusAnchor, .consequenceDetails)
        XCTAssertTrue(reviewing.closeSupportingRoute())
        XCTAssertEqual(reviewing.focusAnchor, .reviewCurrentTruth)

        var settled = settledState()
        XCTAssertTrue(settled.openSupportingRoute(.historyEntry))
        XCTAssertEqual(settled.focusAnchor, .historyEntry)
        XCTAssertTrue(settled.closeSupportingRoute())
        XCTAssertEqual(settled.focusAnchor, .settledTruth)
    }

    func testTimeTransferIsNotAProductJourneyRoute() {
        XCTAssertFalse(
            TodayFlagshipSupportingRoute.allCases.map(\.rawValue).contains("time-transfer")
        )
    }

    func testUndoRouteRequiresExactSourceBackedEligibility() {
        var standard = TodayFlagshipJourneyState.preview(content: content, phase: .settled)
        XCTAssertFalse(standard.openSupportingRoute(.undoReview))
        XCTAssertNil(standard.supportingRoute)

        let undoContent = content.undoAvailableEvaluation
        var eligible = TodayFlagshipJourneyState.preview(content: undoContent, phase: .settled)
        XCTAssertTrue(eligible.openSupportingRoute(.undoReview))
        XCTAssertEqual(eligible.supportingRoute, .undoReview)
        XCTAssertEqual(eligible.focusAnchor, .undoReview)
        XCTAssertTrue(eligible.closeSupportingRoute())
        XCTAssertEqual(eligible.focusAnchor, .settledTruth)
    }

    func testB02TruthFlowDeclaresSpatialComparisonAndPersistentSavingSemantics() throws {
        let sourceRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Sources/AmbitionsNativeVisualFoundry")
        let truthFlowSource = try String(
            contentsOf: sourceRoot.appendingPathComponent("TodayOpenContinuityTruthFlow.swift"),
            encoding: .utf8
        )
        let reviewSource = try String(
            contentsOf: sourceRoot.appendingPathComponent("TodayFlagshipReviewView.swift"),
            encoding: .utf8
        )

        for declaration in [
            "struct TodayOpenContinuityTruthComparison: View",
            "struct TodayOpenContinuityCommitBar: View",
            "struct TodayOpenContinuitySavingSeam: View"
        ] {
            XCTAssertTrue(truthFlowSource.contains(declaration), "Missing \(declaration)")
        }

        for identifier in [
            "tfcs-review-current-truth",
            "tfcs-proposed-truth",
            "tfcs-review-transition-seam",
            "tfcs-saving-posture",
            "tfcs-commit-still-counts"
        ] {
            XCTAssertTrue(
                truthFlowSource.contains(identifier),
                "Truth flow is missing \(identifier)"
            )
        }

        XCTAssertTrue(
            truthFlowSource.contains("@Environment(\\.accessibilityDifferentiateWithoutColor)")
        )
        XCTAssertTrue(truthFlowSource.contains("@Environment(\\.accessibilityReduceMotion)"))
        XCTAssertTrue(truthFlowSource.contains("dynamicTypeSize.isAccessibilitySize"))
        XCTAssertTrue(truthFlowSource.contains("ProgressView"))
        XCTAssertFalse(truthFlowSource.contains("Progress recorded"))
        XCTAssertFalse(truthFlowSource.contains(".glassEffect("))

        XCTAssertTrue(reviewSource.contains("TodayOpenContinuityTruthComparison"))
        XCTAssertTrue(reviewSource.contains("TodayOpenContinuityCommitBar"))
        XCTAssertTrue(reviewSource.contains(".safeAreaInset(edge: .bottom"))
        XCTAssertTrue(reviewSource.contains("DisclosureGroup"))
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

    func testB02SettlementAndReturnDeclareTruthLeadingContinuityWithoutCeremony() throws {
        let sourceRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Sources/AmbitionsNativeVisualFoundry")
        let truthFlowSource = try String(
            contentsOf: sourceRoot.appendingPathComponent("TodayOpenContinuityTruthFlow.swift"),
            encoding: .utf8
        )
        let rootSource = try String(
            contentsOf: sourceRoot.appendingPathComponent("TodayOpenContinuityRoot.swift"),
            encoding: .utf8
        )

        for declaration in [
            "struct TodayOpenContinuitySettlementView: View",
            "struct TodayOpenContinuitySettledTruth: View",
            "struct TodayOpenContinuityReturnBar: View"
        ] {
            XCTAssertTrue(truthFlowSource.contains(declaration), "Missing \(declaration)")
        }

        let settlementOrder = try [
            "tfcs-settlement-identity",
            "tfcs-settled-truth",
            "tfcs-settlement-parent-pursuit",
            "tfcs-recorded-acknowledgment",
            "tfcs-view-history",
            "tfcs-return-to-today"
        ].map { marker in
            try XCTUnwrap(truthFlowSource.range(of: marker)?.lowerBound)
        }
        for pair in zip(settlementOrder, settlementOrder.dropFirst()) {
            XCTAssertLessThan(pair.0, pair.1)
        }

        XCTAssertTrue(truthFlowSource.contains("TodayOpenContinuitySpine(\n                kind: .settled"))
        XCTAssertTrue(truthFlowSource.contains("DisclosureGroup("))
        XCTAssertTrue(truthFlowSource.contains("GeometryReader { viewport in"))
        XCTAssertTrue(truthFlowSource.contains("Spacer(minLength: 28)"))
        XCTAssertTrue(truthFlowSource.contains("minHeight: viewport.size.height"))
        XCTAssertFalse(truthFlowSource.contains("VStack(alignment: .leading, spacing: 28)"))
        XCTAssertTrue(truthFlowSource.contains(".fill(palette.currentTruthPlane)"))
        XCTAssertFalse(truthFlowSource.contains(".fill(palette.settledTruthPlane)"))
        XCTAssertTrue(truthFlowSource.contains("content.receipt.receiptSummary"))
        XCTAssertFalse(truthFlowSource.contains("content.interfaceCopy.historyTrustCue"))
        XCTAssertFalse(truthFlowSource.contains("checkmark.seal.fill"))
        XCTAssertFalse(truthFlowSource.localizedCaseInsensitiveContains("confetti"))
        XCTAssertFalse(truthFlowSource.localizedCaseInsensitiveContains("success badge"))

        let startHereOffset = try XCTUnwrap(
            rootSource.range(of: "TodayOpenContinuityStartHere(")?.lowerBound
        )
        let returnedOffset = try XCTUnwrap(
            rootSource.range(of: "returnedContinuity")?.lowerBound
        )
        XCTAssertLessThan(startHereOffset, returnedOffset)
        XCTAssertTrue(rootSource.contains("tfcs-returned-settled-step"))
        XCTAssertTrue(rootSource.contains("content.returnContract.focusAnchorID"))
        XCTAssertFalse(rootSource.localizedCaseInsensitiveContains("reward"))
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

    func testLeaveForLaterPreservesInterruptedTruthAndRestoresInterruptionFocus() {
        var state = recoveryReviewState()
        let acceptedTruth = state.acceptedTruth
        let navigationPath = state.navigationPath

        XCTAssertTrue(state.leaveForLater())

        XCTAssertEqual(state.phase, .interrupted)
        XCTAssertEqual(state.acceptedTruth, acceptedTruth)
        XCTAssertEqual(state.navigationPath, navigationPath)
        XCTAssertEqual(state.lastSavedProgress, content.recovery.lastSavedProgress)
        XCTAssertEqual(state.focusAnchor, .interruption)
        XCTAssertFalse(state.hasCommittedMutation)
        XCTAssertFalse(state.receiptIsVisible)
        XCTAssertFalse(state.isRecoveryPresented)
    }

    func testRecoveryCommandsRejectUnsupportedPhasesWithoutChangingTruth() {
        var state = focusedState()
        let before = state

        XCTAssertFalse(state.continueFromSavedProgress())
        XCTAssertFalse(state.leaveForLater())
        XCTAssertEqual(state, before)
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
