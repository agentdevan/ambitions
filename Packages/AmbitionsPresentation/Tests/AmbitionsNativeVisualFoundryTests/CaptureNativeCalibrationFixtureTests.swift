import XCTest
@testable import AmbitionsNativeVisualFoundry

final class CaptureNativeCalibrationFixtureTests: XCTestCase {
    private let fixture = CaptureNativeCalibrationFixture.flagship

    func testFixtureIdentityAndPrimaryExpressionAreDeterministic() {
        XCTAssertEqual(
            CaptureNativeCalibrationFixture.fixtureID,
            "capture-flagship/bounded-adaptive-meaning-passage/v1"
        )
        XCTAssertEqual(
            CaptureNativeCalibrationFixture.primaryExpression,
            "I need to prepare questions for tomorrow’s dentist appointment."
        )
    }

    func testPrimaryExpressionProducesOnlyTheBoundedProposal() {
        XCTAssertEqual(
            fixture.interpretation(for: CaptureNativeCalibrationFixture.primaryExpression),
            .proposed(fixture.proposal)
        )
        XCTAssertEqual(
            fixture.proposal.identity,
            "Prepare questions for the dentist appointment"
        )
        XCTAssertEqual(fixture.proposal.destination, "Goals")
        XCTAssertEqual(fixture.proposal.currentState, "Nothing has changed.")
        XCTAssertEqual(
            fixture.proposal.relatedTruth,
            "Tomorrow · 9:30 AM"
        )
    }

    func testAmbiguousExpressionRequiresExactlyTheTargetedQuestion() {
        XCTAssertEqual(
            fixture.interpretation(for: CaptureNativeCalibrationFixture.ambiguousExpression),
            .clarification(question: "What do you want to prepare?")
        )
    }

    func testClarifiedAnswerResolvesToTheSameBoundedProposal() {
        XCTAssertEqual(
            fixture.proposal(
                for: CaptureNativeCalibrationFixture.ambiguousExpression,
                clarification: CaptureNativeCalibrationFixture.clarificationAnswer
            ),
            fixture.proposal
        )
    }

    func testUnsupportedExpressionDoesNotCreateAProposal() {
        XCTAssertEqual(fixture.interpretation(for: "Plan everything"), .unsupported)
        XCTAssertNil(fixture.proposal(for: "Plan everything", clarification: ""))
    }

    func testFixtureCopyContainsNoExcludedCapabilityLanguage() {
        let renderedFixtureText = [
            fixture.proposal.identity,
            fixture.proposal.destination,
            fixture.proposal.relatedIdentity,
            fixture.proposal.relatedTruth,
            fixture.proposal.currentState,
            fixture.proposal.consequence,
            fixture.proposal.primaryAction
        ].joined(separator: " ").lowercased()
        let excludedTerms = [
            "dictation", "microphone", "attachment", "receipt", "undo",
            "settlement", "routing calibration", "confidence"
        ]

        for term in excludedTerms {
            XCTAssertFalse(renderedFixtureText.contains(term), "Unexpected fixture term: \(term)")
        }
    }
}
