import XCTest
@testable import Ambitions

final class RealityModelsTests: XCTestCase {
    func testRealitySnapshotBaselineWorksWithoutCalendarPermission() {
        let now = Date(timeIntervalSince1970: 1_714_000_000)
        let horizon = DateInterval(start: now, end: now.addingTimeInterval(4 * 3_600))

        let snapshot = RealityModelProjector().project(
            input: RealityProjectionInput(now: now, horizon: horizon)
        )

        XCTAssertEqual(snapshot.schemaVersion, realityModelSchemaVersion)
        XCTAssertNil(snapshot.calendarContext)
        XCTAssertEqual(snapshot.privacy, .standard)
        XCTAssertTrue(snapshot.localOnly)
        XCTAssertFalse(snapshot.openWindowCandidates.isEmpty)
        XCTAssertEqual(snapshot.capacityEstimate.totalOpenMinutes, 240)
        XCTAssertTrue(snapshot.availability.summary.contains("Plan still works without calendar access"))
    }

    func testCalendarDerivedWindowsRemainLocalOnlyAndPrivacyMarked() {
        let now = Date(timeIntervalSince1970: 1_714_000_000)
        let horizon = DateInterval(start: now, end: now.addingTimeInterval(4 * 3_600))
        let busy = RealityWindow(
            id: "busy-1",
            kind: .calendarDerivedBusy,
            source: .calendarDerived,
            start: now.addingTimeInterval(3_600),
            end: now.addingTimeInterval(7_200),
            title: "Calendar busy time"
        )
        let context = CalendarDerivedContext(
            permissionState: .readWrite,
            observedRangeStart: horizon.start,
            observedRangeEnd: horizon.end,
            derivedBusyWindowCount: 1,
            userInitiatedPlanAction: "Find real open windows",
            explanation: "Calendar-derived busy time stayed local."
        )

        let snapshot = RealityModelProjector().project(
            input: RealityProjectionInput(
                now: now,
                horizon: horizon,
                calendarBusyWindows: [busy],
                calendarContext: context
            )
        )

        XCTAssertEqual(snapshot.privacy, .calendarDerived)
        XCTAssertEqual(snapshot.windows.first(where: { $0.id == "busy-1" })?.privacy, .calendarDerived)
        XCTAssertTrue(snapshot.windows.first(where: { $0.id == "busy-1" })?.localOnly == true)
        XCTAssertEqual(snapshot.openWindowCandidates.count, 2)
        XCTAssertTrue(snapshot.openWindowCandidates.allSatisfy(\.isCalendarDerived))
    }
}
