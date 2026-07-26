import XCTest
@testable import AmbitionsNativeVisualFoundry

final class TodayVitalityReviewTests: XCTestCase {
    func testR13ReviewFixtureKeepsExactCurrentProposedAndConsequenceTruth() {
        let content = TodayFlagshipCalibrationFixture.preparingForBaby
        let proposal = content.primaryStep.stillCountsProposal

        XCTAssertEqual(
            content.primaryStep.currentAcceptedTruth,
            "The corner is cleared and the paint sample is chosen."
        )
        XCTAssertEqual(proposal.proposedTruth, "I primed the wall and tested the new color.")
        XCTAssertEqual(
            proposal.exactConsequence,
            "This Step will leave Start Here and remain visible in Today."
        )
        XCTAssertEqual(proposal.affectedLineage, "Welcome our baby home")
        XCTAssertEqual(
            content.interfaceCopy.historyTrustCue,
            "A history entry will be saved on this device."
        )
    }

    func testR13ReviewSourceUsesOpenVerticalTruthFieldAndNativeActionRoles() throws {
        let source = try reviewSource()

        for required in [
            "struct TodayVitalityReviewView: View",
            "TodayVitalityNode(kind: .current",
            "TodayVitalityNode(kind: .proposed",
            "TodayVitalityNode(kind: .saving",
            "TodayVitalityActionStyle(role: .secondary",
            "TodayVitalityActionStyle(role: .commitment",
            "DisclosureGroup",
            "ProgressView",
            ".safeAreaInset(edge: .bottom",
            "tfcs-review-current-truth",
            "tfcs-proposed-truth",
            "tfcs-review-transition-seam",
            "tfcs-review-consequence",
            "tfcs-review-relationship",
            "tfcs-review-trust-cue",
            "tfcs-review-details",
            "tfcs-saving-posture",
            "tfcs-failed-settlement"
        ] {
            XCTAssertTrue(source.contains(required), "Missing R13 review contract: \(required)")
        }

        XCTAssertTrue(source.contains("state.acceptedTruth"))
        XCTAssertTrue(source.contains("state.proposedTruth"))
        XCTAssertTrue(source.contains("dynamicTypeSize.isAccessibilitySize"))
        XCTAssertTrue(source.contains("accessibilityHidden(true)"))
        XCTAssertTrue(source.contains("Text(content.interfaceCopy.stepTitle)"))
        XCTAssertFalse(source.contains(".glassEffect("))
        XCTAssertFalse(source.contains("TabView"))
        XCTAssertFalse(source.contains("Font.custom"))
        XCTAssertFalse(source.contains("Progress recorded"))
        XCTAssertFalse(source.contains("TodayOpenContinuityTruthComparison"))
        XCTAssertFalse(source.contains("TodayOpenContinuityCommitBar"))
    }

    func testR13ReviewWrapperPreservesGenerationGuardAndDelegatesComposition() throws {
        let wrapper = try foundrySource(named: "TodayFlagshipReviewView.swift")

        XCTAssertTrue(wrapper.contains("TodayVitalityReviewView("))
        XCTAssertTrue(wrapper.contains("let succeeded = await onCommitProposal()"))
        XCTAssertTrue(wrapper.contains("commitGeneration == generation"))
        XCTAssertTrue(wrapper.contains("commitTask?.cancel()"))
        XCTAssertTrue(wrapper.contains("state.resolveCommit(succeeded: succeeded)"))
        XCTAssertTrue(wrapper.contains("state.failCommit()"))
        XCTAssertTrue(wrapper.contains("state.retryFailedCommit()"))
        XCTAssertTrue(wrapper.contains("state.dismissFailedCommit()"))
        XCTAssertTrue(wrapper.contains("UIAccessibility.post"))
    }

    private func reviewSource() throws -> String {
        try foundrySource(named: "TodayVitalityReviewView.swift")
    }

    private func foundrySource(named filename: String) throws -> String {
        let packageRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let url = packageRoot
            .appendingPathComponent("Sources/AmbitionsNativeVisualFoundry")
            .appendingPathComponent(filename)

        guard FileManager.default.fileExists(atPath: url.path) else {
            XCTFail("R13 review source is missing: \(filename)")
            return ""
        }
        return try String(contentsOf: url, encoding: .utf8)
    }
}
