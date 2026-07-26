import XCTest
@testable import AmbitionsNativeVisualFoundry

final class TodayVitalityRootTests: XCTestCase {
    func testR13RootFixtureUsesExactEnglishObjectTruthAndContinuationCopy() {
        let fixture = TodayFlagshipCalibrationFixture.preparingForBaby
        let step = fixture.primaryStep

        XCTAssertEqual(fixture.interfaceCopy.localeIdentifier, "en-US")
        XCTAssertEqual(step.primaryActionTitle, "Continue")
        XCTAssertEqual(
            step.startHereSummary,
            "Moves the nursery forward while family time stays protected."
        )
        XCTAssertEqual(
            "\(step.temporalContext.exactTime) · \(step.temporalContext.relationship)",
            "Available now · before 2:00 PM handoff"
        )
    }

    func testR13InitialOverviewIsExactlyFixedProtectedAndOpenInDayOrder() {
        let fixture = TodayFlagshipCalibrationFixture.preparingForBaby
        let overview = todayOverviewObjects(
            content: fixture,
            visibleStartHereID: fixture.primaryStep.id
        )

        XCTAssertEqual(overview.map(\.canonicalObjectID), [
            "step.send-launch-brief",
            "event.family-time",
            "lane.open-after-family"
        ])
        XCTAssertEqual(overview.map(\.timeLabel), [
            "2:00 PM",
            "5:30 PM",
            "Open after 6:30 PM"
        ])
        XCTAssertEqual(overview.map(\.objectTitle), [
            "Send the launch brief",
            "Family time",
            "Open time"
        ])
        XCTAssertEqual(overview.map(\.relationship), [
            "Fixed work handoff",
            "No work · Protected",
            "Room for what matters"
        ])
        XCTAssertEqual(overview.map(\.role), [.fixed, .protected, .openLane])
        XCTAssertFalse(overview.contains { $0.canonicalObjectID == fixture.primaryStep.id })
    }

    func testR13OverviewBudgetSurvivesQuietDenseAndVeryDenseFixtures() {
        let fixture = TodayFlagshipCalibrationFixture.preparingForBaby
        let variants = [
            fixture.quietToday,
            fixture.denseToday,
            fixture.veryDenseToday
        ]

        for variant in variants {
            let overview = todayOverviewObjects(
                content: variant,
                visibleStartHereID: variant.primaryStep.id
            )
            XCTAssertLessThanOrEqual(overview.count, 3)
            XCTAssertEqual(Set(overview.map(\.canonicalObjectID)).count, overview.count)
        }
    }

    func testR13ReturnedProjectionShowsReadOnlyRevealedStartHereAndSettledStepOnce() {
        let fixture = TodayFlagshipCalibrationFixture.preparingForBaby
        let returnedTimeline = todayReturnedOverviewObjects(content: fixture)
        let visibleIDs = [fixture.revealedStartHereStep.id]
            + returnedTimeline.map(\.canonicalObjectID)

        XCTAssertEqual(
            visibleIDs.filter { $0 == fixture.revealedStartHereStep.id }.count,
            1
        )
        XCTAssertEqual(
            visibleIDs.filter { $0 == fixture.primaryStep.id }.count,
            1
        )
        XCTAssertEqual(returnedTimeline.first?.canonicalObjectID, fixture.primaryStep.id)
        XCTAssertEqual(returnedTimeline.first?.role, .ordinary)
        XCTAssertEqual(returnedTimeline.dropFirst().map(\.canonicalObjectID), [
            "event.family-time",
            "lane.open-after-family"
        ])
    }

    func testR13RootSourceUsesOneOpenRailAndNoPerimeterCardAnatomy() throws {
        let rootSource = try foundrySource(named: "TodayVitalityRootView.swift")
        let timelineSource = try foundrySource(named: "TodayVitalityTimelineView.swift")
        let wrapperSource = try foundrySource(named: "TodayFlagshipCalibrationView.swift")

        XCTAssertTrue(rootSource.contains("TodayVitalityRailNode("))
        XCTAssertTrue(rootSource.contains("TodayVitalityActionStyle"))
        XCTAssertTrue(rootSource.contains("showsAction: state.phase != .todayReturned"))
        XCTAssertTrue(rootSource.contains("frame(minHeight: 48)"))
        XCTAssertFalse(rootSource.contains("TodayOpenContinuitySpine("))
        XCTAssertFalse(rootSource.contains("UnevenRoundedRectangle("))
        XCTAssertFalse(rootSource.contains("frame(maxHeight: .infinity"))

        XCTAssertTrue(timelineSource.contains("TodayVitalityNode("))
        XCTAssertTrue(timelineSource.contains("tfcs-timeline"))
        XCTAssertFalse(timelineSource.contains("tfcs-later-today"))
        XCTAssertTrue(timelineSource.contains("tfcs-view-full-day"))
        XCTAssertTrue(timelineSource.contains("isReturnedSettledStepFocused"))
        XCTAssertTrue(timelineSource.contains("row.accessibilityFocused($isReturnedSettledStepFocused)"))
        XCTAssertFalse(timelineSource.contains("TodayOpenContinuitySpine("))
        XCTAssertTrue(wrapperSource.contains("TodayVitalityRootView("))
    }

    private func foundrySource(named filename: String) throws -> String {
        let packageRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        return try String(
            contentsOf: packageRoot
                .appendingPathComponent("Sources/AmbitionsNativeVisualFoundry")
                .appendingPathComponent(filename),
            encoding: .utf8
        )
    }
}
