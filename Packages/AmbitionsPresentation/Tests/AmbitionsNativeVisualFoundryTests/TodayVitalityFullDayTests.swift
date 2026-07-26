import XCTest
@testable import AmbitionsNativeVisualFoundry

final class TodayVitalityFullDayTests: XCTestCase {
    func testR13FullDayFixtureProvidesExactSixEntryChronologyWithoutChangingRootOverview() {
        let content = TodayFlagshipCalibrationFixture.preparingForBaby

        XCTAssertEqual(content.supporting.fullDay.entries.map(\.canonicalObjectID), [
            "event.deep-work",
            "step.nursery-ready-for-crib",
            "step.send-launch-brief",
            "lane.open-afternoon",
            "event.family-time",
            "lane.open-after-family"
        ])
        XCTAssertEqual(content.supporting.fullDay.entries.map(\.timeLabel), [
            "9:00 AM",
            "Now · 10:30 AM",
            "2:00 PM",
            "3:30 PM",
            "5:30 PM",
            "Open after 6:30 PM"
        ])
        XCTAssertEqual(
            Set(content.supporting.fullDay.entries.map(\.canonicalObjectID)).count,
            6
        )
        XCTAssertEqual(content.timeline.map(\.canonicalObjectID), [
            "step.send-launch-brief",
            "event.family-time",
            "lane.open-after-family"
        ])
    }

    func testR13FullDayUsesOriginSpecificNowAndUniqueReturnedProjection() {
        let content = TodayFlagshipCalibrationFixture.preparingForBaby

        XCTAssertEqual(
            content.nowAnchorObjectID(for: .todayInitial),
            content.primaryStep.id
        )
        XCTAssertEqual(
            content.nowAnchorObjectID(for: .todayReturned),
            content.revealedStartHereStep.id
        )

        let returned = todayVitalityFullDayObjects(
            content: content,
            origin: .todayReturned,
            acceptedTruth: content.primaryStep.stillCountsProposal.settledTruth
        )
        XCTAssertEqual(
            returned.filter { $0.canonicalObjectID == content.primaryStep.id }.count,
            1
        )
        XCTAssertEqual(
            returned.filter { $0.canonicalObjectID == content.revealedStartHereStep.id }.count,
            1
        )
        XCTAssertEqual(
            returned.first { $0.canonicalObjectID == content.primaryStep.id }?.acceptedState,
            content.primaryStep.stillCountsProposal.settledTruth
        )
    }

    func testR13FullDaySourceIsRailFirstReadOnlyTodayDepth() throws {
        let source = try foundrySource(named: "TodayVitalityFullDayView.swift")
        let wrapper = try foundrySource(named: "TodayFlagshipCalibrationView.swift")

        for required in [
            "struct TodayVitalityFullDayView: View",
            "VStack(alignment: .leading, spacing: 0)",
            "TodayVitalityRailNode(",
            "TodayVitalityFunctionalChrome(",
            "TodayVitalityActionStyle(",
            "ScrollViewReader",
            "contentTitle",
            "Spacer(minLength: 0)",
            ".containerRelativeFrame(.vertical, alignment: .top)",
            "isPastResolved",
            "state.openStepFromFullDay(id:",
            "tfcs-full-day-timeline",
            "tfcs-scroll-to-now"
        ] {
            XCTAssertTrue(source.contains(required), "Missing R13 Full Day contract: \(required)")
        }
        XCTAssertTrue(wrapper.contains("TodayVitalityFullDayView("))
        XCTAssertTrue(source.contains("font(TodayVitalityTypographyRole.objectIdentity.font)"))
        XCTAssertTrue(source.contains("accessibilityIdentifier(\"r13-full-day-title\")"))
        XCTAssertTrue(source.contains("if isPastResolved(item) { return .settled }"))
        XCTAssertFalse(source.contains(".todayFlagshipInlineNavigationTitle()"))

        for prohibited in [
            "DatePicker", "Grid {", ".onMove", "Open in Time",
            "TodayFlagshipDock(", "TodayVitalityRootCrown(",
            "LinearGradient", ".blur(", "runtimeAdapter"
        ] {
            XCTAssertFalse(source.contains(prohibited), "Prohibited Full Day source: \(prohibited)")
        }
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
            XCTFail("R13 Full Day source is missing: \(filename)")
            return ""
        }
        return try String(contentsOf: url, encoding: .utf8)
    }
}
