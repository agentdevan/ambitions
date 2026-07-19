import XCTest
@testable import Ambitions

final class AppShellSensoryFeedbackPolicyTests: XCTestCase {
    func testShellFeedbackPolicyDefinesSharedIntentSet() {
        XCTAssertEqual(
            Set(AppShellSensoryFeedbackIntent.allCases),
            [.surfaceSelection, .headerAction, .captureActivation, .overlayDismissal]
        )
    }

    func testReduceMotionDisablesShellFeedbackEmission() {
        XCTAssertTrue(AppShellSensoryFeedbackPolicy.shouldEmitFeedback(reduceMotionEnabled: false))
        XCTAssertFalse(AppShellSensoryFeedbackPolicy.shouldEmitFeedback(reduceMotionEnabled: true))
    }

    func testFeedbackIntentsHaveAccessibleDescriptions() {
        for intent in AppShellSensoryFeedbackIntent.allCases {
            XCTAssertFalse(intent.accessibilityDescription.isEmpty)
        }
    }
}
