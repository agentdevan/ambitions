import Foundation
import XCTest
@testable import AmbitionsNativeVisualFoundry

final class TodayVitalityRecoveryTests: XCTestCase {
    private let content = TodayFlagshipCalibrationFixture.preparingForBaby

    func testR13RecoveryKeepsAcceptedTruthAndExactCommands() {
        var state = TodayFlagshipJourneyState.preview(
            content: content,
            phase: .focusedCurrent
        )
        let acceptedTruth = state.acceptedTruth

        XCTAssertTrue(state.interrupt())
        XCTAssertEqual(state.acceptedTruth, acceptedTruth)
        XCTAssertEqual(state.focusAnchor, .interruption)
        XCTAssertTrue(state.openRecoveryReview())
        XCTAssertEqual(state.availableRecoveryChoiceIDs, [
            "recovery.continue-saved-progress",
            "recovery.keep-step"
        ])
        XCTAssertEqual(
            state.lastSavedProgress,
            "I primed the wall and tested the new color."
        )
        XCTAssertFalse(state.hasCommittedMutation)
    }

    func testR13RecoveryDeferralAndDismissalRemainNonMutating() {
        var dismissed = TodayFlagshipJourneyState.preview(
            content: content,
            phase: .recoveryReview
        )
        let acceptedTruth = dismissed.acceptedTruth

        XCTAssertTrue(dismissed.dismissRecovery())
        assertInterruptedWithoutMutation(dismissed, acceptedTruth: acceptedTruth)

        var deferred = TodayFlagshipJourneyState.preview(
            content: content,
            phase: .recoveryReview
        )
        XCTAssertTrue(deferred.leaveForLater())
        assertInterruptedWithoutMutation(deferred, acceptedTruth: acceptedTruth)
    }

    func testR13RecoveryContinuationRestoresSavedProgressWithoutSettlement() {
        var state = TodayFlagshipJourneyState.preview(
            content: content,
            phase: .recoveryReview
        )
        let acceptedTruth = state.acceptedTruth

        XCTAssertTrue(state.continueFromSavedProgress())
        XCTAssertEqual(state.phase, .recoveredContinuation)
        XCTAssertEqual(state.focusAnchor, .recoveredProgress)
        XCTAssertEqual(state.acceptedTruth, acceptedTruth)
        XCTAssertEqual(state.lastSavedProgress, content.recovery.lastSavedProgress)
        XCTAssertFalse(state.hasCommittedMutation)
        XCTAssertFalse(state.receiptIsVisible)
    }

    func testR13RecoverySourceUsesVitalityAnatomyAndExactCommandFocus() throws {
        let source = try source(named: "TodayVitalityRecoveryView.swift")

        XCTAssertTrue(source.contains("TodayVitalityRailNode("))
        XCTAssertTrue(source.contains("kind: .interrupted"))
        XCTAssertTrue(source.contains("TodayVitalityOpenRelief("))
        XCTAssertTrue(source.contains("truthKind: .interrupted"))
        XCTAssertTrue(source.contains("TodayVitalityActionStyle"))
        XCTAssertTrue(source.contains("role: .continuation"))
        XCTAssertTrue(source.contains("role: .secondary"))
        XCTAssertTrue(source.contains("accessibilityFocused"))
        XCTAssertTrue(source.contains("recovery.continue-saved-progress"))
        for identifier in [
            "tfcs-interruption-seam",
            "tfcs-recovery-step-identity",
            "tfcs-recovery-current-truth",
            "tfcs-recovery-progress-field",
            "tfcs-open-recovery",
            "tfcs-recovery-review"
        ] {
            XCTAssertTrue(source.contains(identifier), "Missing \(identifier)")
        }
        XCTAssertFalse(source.contains("TodayFlagshipObjectField"))
        XCTAssertFalse(source.contains("TodayOpenContinuityInterruptedField"))
        XCTAssertFalse(source.contains("Form {"))
        XCTAssertFalse(source.contains("TodayFlagshipDock"))
        XCTAssertFalse(source.contains("checkmark.seal.fill"))
    }

    func testR13RecoveryPresentationPropagatesDynamicTypeAndSelectsAdaptiveDetent() throws {
        let source = try source(named: "TodayFlagshipCalibrationView.swift")

        XCTAssertTrue(source.contains(".dynamicTypeSize(dynamicTypeSize)"))
        XCTAssertTrue(
            source.contains(
                "recoveryDetent = dynamicTypeSize.isAccessibilitySize ? .large : .medium"
            )
        )
        XCTAssertTrue(source.contains(".presentationDetents([.medium, .large]"))
    }

    private func assertInterruptedWithoutMutation(
        _ state: TodayFlagshipJourneyState,
        acceptedTruth: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(state.phase, .interrupted, file: file, line: line)
        XCTAssertEqual(state.focusAnchor, .interruption, file: file, line: line)
        XCTAssertEqual(state.acceptedTruth, acceptedTruth, file: file, line: line)
        XCTAssertFalse(state.hasCommittedMutation, file: file, line: line)
        XCTAssertFalse(state.receiptIsVisible, file: file, line: line)
    }

    private func source(named filename: String) throws -> String {
        let packageRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let url = packageRoot
            .appendingPathComponent("Sources/AmbitionsNativeVisualFoundry")
            .appendingPathComponent(filename)

        guard FileManager.default.fileExists(atPath: url.path) else {
            XCTFail("R13 recovery source is missing")
            return ""
        }
        return try String(contentsOf: url, encoding: .utf8)
    }
}
