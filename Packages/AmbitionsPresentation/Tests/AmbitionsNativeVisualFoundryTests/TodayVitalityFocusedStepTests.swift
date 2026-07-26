import XCTest
@testable import AmbitionsNativeVisualFoundry

final class TodayVitalityFocusedStepTests: XCTestCase {
    func testR13FocusedFixtureKeepsExactObjectTruthAndOnlyExecutableOutcome() {
        let content = TodayFlagshipCalibrationFixture.preparingForBaby
        let step = content.primaryStep

        XCTAssertEqual(step.id, "step.nursery-ready-for-crib")
        XCTAssertEqual(step.parentPursuitID, "goal.welcome-baby-home")
        XCTAssertEqual(step.parentPursuitTitle, "Welcome our baby home")
        XCTAssertEqual(
            step.currentAcceptedTruth,
            "The corner is cleared and the paint sample is chosen."
        )
        XCTAssertEqual(
            step.startHereSummary,
            "Moves the nursery forward while family time stays protected."
        )
        XCTAssertEqual(
            "\(step.temporalContext.exactTime) · \(step.temporalContext.relationship)",
            "Available now · before 2:00 PM handoff"
        )
        XCTAssertEqual(step.stillCountsProposal.outcomeTitle, "Still counts")
    }

    func testR13FocusedSourceUsesVitalityDepthWithoutRootChromeOrCardAnatomy() throws {
        let source = try focusedSource()

        XCTAssertTrue(source.contains("TodayVitalityRailNode("))
        XCTAssertTrue(source.contains("TodayVitalityActionStyle"))
        XCTAssertTrue(source.contains("TodayVitalityFocusedOutcome"))
        XCTAssertTrue(source.contains("tfcs-focused-current-truth"))
        XCTAssertTrue(source.contains("tfcs-select-still-counts"))
        XCTAssertFalse(source.contains("TodayFlagshipDock("))
        XCTAssertFalse(source.contains("TodayVitalityRootCrown("))
        XCTAssertFalse(source.contains("UnevenRoundedRectangle("))
        XCTAssertFalse(source.contains("Form {"))
    }

    func testR13FocusedAccessibilityMovesTheActionIntoNaturalScrollOrder() throws {
        let source = try focusedSource()

        XCTAssertTrue(source.contains("dynamicTypeSize.isAccessibilitySize"))
        XCTAssertTrue(source.contains("if usesFlowingReviewAction"))
        XCTAssertTrue(source.contains("if usesFlowingReviewAction == false"))
        XCTAssertTrue(source.contains(".padding(.bottom, 36)"))
        XCTAssertTrue(source.contains("accessibilityIdentifier(\"r13-focused-flowing-action\")"))
    }

    private func focusedSource() throws -> String {
        let packageRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let url = packageRoot
            .appendingPathComponent("Sources/AmbitionsNativeVisualFoundry")
            .appendingPathComponent("TodayVitalityFocusedStepView.swift")

        guard FileManager.default.fileExists(atPath: url.path) else {
            XCTFail("R13 focused Step source is missing")
            return ""
        }
        return try String(contentsOf: url, encoding: .utf8)
    }
}
