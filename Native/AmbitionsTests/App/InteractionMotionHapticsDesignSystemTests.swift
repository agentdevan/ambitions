import AmbitionsDesignSystem
import XCTest

final class InteractionMotionHapticsDesignSystemTests: XCTestCase {
    func testSI12InteractionTokensCoverMeaningfulMotionPurposes() {
        XCTAssertEqual(Set(AmbitionInteractionPurpose.allCases), [
            .orientation,
            .confirmation,
            .uncertaintyReduction
        ])

        let purposes = Set(AmbitionInteractionToken.allCases.map(\.purpose))
        XCTAssertEqual(purposes, Set(AmbitionInteractionPurpose.allCases))
    }

    func testSI12InteractionTokensExposeReduceMotionEquivalents() {
        for token in AmbitionInteractionToken.allCases {
            XCTAssertFalse(token.title.isEmpty)
            XCTAssertFalse(token.reduceMotionEquivalent.isEmpty)
            XCTAssertFalse(token.accessibilitySummary.isEmpty)
            XCTAssertTrue(token.accessibilitySummary.localizedCaseInsensitiveContains("Reduce Motion"))
        }
    }

    func testSI12HapticsRemainOptionalAndUserInitiated() {
        let hapticTokens = AmbitionInteractionToken.allCases.filter(\.allowsAutomaticHaptics)

        XCTAssertEqual(Set(hapticTokens), [
            .routeOrientation,
            .selectionConfirm,
            .proofConfirm,
            .correctionNeeded
        ])

        for token in AmbitionInteractionToken.allCases where token.purpose != .confirmation {
            if token.allowsAutomaticHaptics {
                XCTAssertTrue(
                    token.hapticPolicy.intent == .routeChange ||
                    token.hapticPolicy.intent == .correction
                )
            }
        }
    }

    func testSI12LDIHookStatesStayVisualWithoutRuntimeClaims() {
        let ldiVisualTokens: Set<AmbitionInteractionToken> = [
            .correctionNeeded,
            .sourceCheck,
            .reviewRequired,
            .privacyBoundary,
            .unsafeRedirect,
            .recompilePending,
            .localOnlySettle
        ]

        XCTAssertTrue(ldiVisualTokens.isSubset(of: Set(AmbitionInteractionToken.allCases)))

        let combined = ldiVisualTokens
            .map { "\($0.title) \($0.reduceMotionEquivalent)" }
            .joined(separator: " ")

        XCTAssertFalse(combined.localizedCaseInsensitiveContains("cloud synced"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("server"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("production AI"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("automatic commitment"))
    }
}
