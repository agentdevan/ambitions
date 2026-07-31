import XCTest
@testable import AmbitionsNativeVisualFoundry

final class CaptureNativeCalibrationJourneyStateTests: XCTestCase {
    private let fixture = CaptureNativeCalibrationFixture.flagship

    func testPresentationPreservesOriginAndHidesOriginChrome() {
        var state = CaptureNativeCalibrationJourneyState()

        XCTAssertTrue(state.originChromeVisible)
        XCTAssertTrue(state.presentCapture())
        XCTAssertTrue(state.isPresented)
        XCTAssertFalse(state.originChromeVisible)
        XCTAssertEqual(state.origin.rootIdentity, "Today")
        XCTAssertEqual(state.origin.initiatingControl, "Capture")
        XCTAssertEqual(state.origin.presentationKind, .globalFullScreenTemporary)
        XCTAssertEqual(state.focusAnchor, .expressionEditor)
    }

    func testPrimaryExpressionRetainsOriginalWordsThroughMeaningAndReview() {
        var state = presentedState(expression: CaptureNativeCalibrationFixture.primaryExpression)

        XCTAssertTrue(state.continueExpression(using: fixture))
        XCTAssertEqual(state.phase, .boundedMeaning)
        XCTAssertEqual(state.expression, CaptureNativeCalibrationFixture.primaryExpression)
        XCTAssertTrue(state.openReview(using: fixture))
        XCTAssertEqual(state.navigationPath, [.review])
        XCTAssertEqual(state.expression, CaptureNativeCalibrationFixture.primaryExpression)

        state.restoreNavigationPath([])
        XCTAssertEqual(state.phase, .boundedMeaning)
        XCTAssertEqual(state.focusAnchor, .boundedMeaningReview)
    }

    func testOnlyAmbiguousFixtureIntroducesOneClarification() {
        var primary = presentedState(expression: CaptureNativeCalibrationFixture.primaryExpression)
        XCTAssertTrue(primary.continueExpression(using: fixture))
        XCTAssertEqual(primary.clarificationCount, 0)

        var ambiguous = presentedState(
            expression: CaptureNativeCalibrationFixture.ambiguousExpression
        )
        XCTAssertTrue(ambiguous.continueExpression(using: fixture))
        XCTAssertEqual(ambiguous.phase, .clarification)
        XCTAssertEqual(ambiguous.clarificationCount, 1)

        XCTAssertTrue(ambiguous.continueExpression(using: fixture))
        XCTAssertEqual(ambiguous.clarificationCount, 1)
    }

    func testClarificationRetainsOriginalAndAnswerThroughReviewAndChange() {
        var state = presentedState(
            expression: CaptureNativeCalibrationFixture.ambiguousExpression
        )
        XCTAssertTrue(state.continueExpression(using: fixture))
        state.updateClarificationResponse(CaptureNativeCalibrationFixture.clarificationAnswer)
        XCTAssertTrue(state.continueClarification(using: fixture))
        XCTAssertTrue(state.openReview(using: fixture))

        state.changeWords()

        XCTAssertEqual(state.phase, .expression)
        XCTAssertEqual(state.expression, CaptureNativeCalibrationFixture.ambiguousExpression)
        XCTAssertEqual(
            state.clarificationResponse,
            CaptureNativeCalibrationFixture.clarificationAnswer
        )
        XCTAssertEqual(state.focusAnchor, .expressionEditor)
    }

    func testOwnerHandoffPreparationPerformsZeroCanonicalMutations() {
        var state = presentedState(expression: CaptureNativeCalibrationFixture.primaryExpression)
        XCTAssertTrue(state.continueExpression(using: fixture))
        XCTAssertTrue(state.openReview(using: fixture))
        let acceptedTruth = state.currentAcceptedTruth
        let chronology = state.timeChronology

        state.recordFixtureOnlyHandoff()

        XCTAssertTrue(state.fixtureHandoffPrepared)
        XCTAssertEqual(state.canonicalMutationCount, 0)
        XCTAssertEqual(state.currentAcceptedTruth, acceptedTruth)
        XCTAssertEqual(state.timeChronology, chronology)
    }

    func testEmptyCancelDismissesAndRestoresOriginFocus() {
        var state = CaptureNativeCalibrationJourneyState()
        XCTAssertTrue(state.presentCapture())

        XCTAssertEqual(state.requestCancel(), .dismissedEmpty)
        XCTAssertFalse(state.isPresented)
        XCTAssertTrue(state.originChromeVisible)
        XCTAssertEqual(state.focusAnchor, .originCaptureTrigger)
    }

    func testNonemptyCancelRequiresDecisionAndKeepEditingRetainsDraft() {
        var state = presentedState(expression: CaptureNativeCalibrationFixture.primaryExpression)

        XCTAssertEqual(state.requestCancel(), .confirmationRequired)
        XCTAssertTrue(state.isCloseConfirmationPresented)

        state.keepEditing()

        XCTAssertTrue(state.isPresented)
        XCTAssertFalse(state.isCloseConfirmationPresented)
        XCTAssertEqual(state.expression, CaptureNativeCalibrationFixture.primaryExpression)
        XCTAssertEqual(state.phase, .expression)
        XCTAssertEqual(state.focusAnchor, .expressionEditor)
    }

    func testDiscardAndCloseCreatesNoMutationAndRestoresOriginFocus() {
        var state = presentedState(expression: CaptureNativeCalibrationFixture.primaryExpression)
        XCTAssertEqual(state.requestCancel(), .confirmationRequired)

        state.discardAndClose()

        XCTAssertFalse(state.isPresented)
        XCTAssertEqual(state.canonicalMutationCount, 0)
        XCTAssertEqual(state.focusAnchor, .originCaptureTrigger)
        XCTAssertEqual(
            state.lastDismissedContext?.expression,
            CaptureNativeCalibrationFixture.primaryExpression
        )
    }

    func testRecoveryRetainsAllInSessionMeaningAndContinuesReview() {
        var state = presentedState(
            expression: CaptureNativeCalibrationFixture.ambiguousExpression
        )
        XCTAssertTrue(state.continueExpression(using: fixture))
        state.updateClarificationResponse(CaptureNativeCalibrationFixture.clarificationAnswer)
        XCTAssertTrue(state.continueClarification(using: fixture))

        state.showRecovery()

        XCTAssertEqual(state.phase, .recovery)
        XCTAssertEqual(state.expression, CaptureNativeCalibrationFixture.ambiguousExpression)
        XCTAssertEqual(
            state.clarificationResponse,
            CaptureNativeCalibrationFixture.clarificationAnswer
        )
        XCTAssertTrue(state.continueFromRecovery(using: fixture))
        XCTAssertEqual(state.navigationPath, [.review])
    }

    func testGlobalDismissalRecordsReviewContextAndRestoresExactOrigin() {
        var state = presentedState(expression: CaptureNativeCalibrationFixture.primaryExpression)
        XCTAssertTrue(state.continueExpression(using: fixture))
        XCTAssertTrue(state.openReview(using: fixture))
        XCTAssertEqual(state.requestCancel(), .confirmationRequired)

        state.discardAndClose()

        XCTAssertEqual(state.lastDismissedContext?.phase, .boundedMeaning)
        XCTAssertEqual(state.lastDismissedContext?.route, .review)
        XCTAssertEqual(state.focusAnchor, .originCaptureTrigger)
        XCTAssertEqual(state.canonicalMutationCount, 0)
    }

    private func presentedState(expression: String) -> CaptureNativeCalibrationJourneyState {
        var state = CaptureNativeCalibrationJourneyState()
        XCTAssertTrue(state.presentCapture(expression: expression))
        return state
    }
}
