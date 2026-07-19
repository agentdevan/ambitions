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
        XCTAssertTrue(snapshot.vacationAwayWindows.isEmpty)
        XCTAssertEqual(snapshot.capacityEstimate.openMinutes, 240)
        XCTAssertEqual(snapshot.capacityEstimate.totalOpenMinutes, 240)
        XCTAssertEqual(snapshot.capacityEstimate.protectedMinutes, 0)
        XCTAssertEqual(snapshot.capacityEstimate.vacationAwayMinutes, 0)
        XCTAssertEqual(snapshot.capacityEstimate.blockedBusyMinutes, 0)
        XCTAssertEqual(snapshot.capacityEstimate.scheduledAmbitionsMinutes, 0)
        XCTAssertEqual(snapshot.capacityEstimate.calendarBusyMinutes, 0)
        XCTAssertTrue(snapshot.capacityEstimate.timeFitProofSummary.contains("Time fit proof"))
        XCTAssertTrue(snapshot.capacityEstimate.deadlineFitProofSummary.contains("No deadline pressure"))
        XCTAssertTrue(snapshot.availability.summary.contains("Time still works without calendar access"))
    }

    func testProtectedTimeReducesOpenCapacity() {
        let now = Date(timeIntervalSince1970: 1_714_000_000)
        let horizon = DateInterval(start: now, end: now.addingTimeInterval(4 * 3_600))
        let protected = RealityWindow(
            id: "protected-1",
            kind: .protected,
            source: .userDefined,
            start: now.addingTimeInterval(3_600),
            end: now.addingTimeInterval(7_200),
            title: "Protected time"
        )

        let snapshot = RealityModelProjector().project(
            input: RealityProjectionInput(
                now: now,
                horizon: horizon,
                protectedWindows: [protected]
            )
        )

        XCTAssertEqual(snapshot.capacityEstimate.protectedMinutes, 60)
        XCTAssertEqual(snapshot.capacityEstimate.openMinutes, 180)
        XCTAssertEqual(snapshot.capacityEstimate.totalOpenMinutes, 180)
        XCTAssertTrue(snapshot.capacityEstimate.summary.contains("protected"))
        XCTAssertTrue(snapshot.conflictSummary.conflictCount == 0)
    }

    func testAwayVacationReducesOpenCapacity() {
        let now = Date(timeIntervalSince1970: 1_714_000_000)
        let horizon = DateInterval(start: now, end: now.addingTimeInterval(4 * 3_600))
        let vacation = RealityWindow(
            id: "vacation-1",
            kind: .vacation,
            source: .userDefined,
            start: now.addingTimeInterval(3_600),
            end: now.addingTimeInterval(7_200),
            title: "Vacation"
        )
        let away = RealityWindow(
            id: "away-1",
            kind: .away,
            source: .userDefined,
            start: now.addingTimeInterval(7_200),
            end: now.addingTimeInterval(10_800),
            title: "Away"
        )

        let snapshot = RealityModelProjector().project(
            input: RealityProjectionInput(
                now: now,
                horizon: horizon,
                vacationAwayWindows: [vacation, away]
            )
        )

        XCTAssertEqual(snapshot.vacationAwayWindows.map(\.kind), [.vacation, .away])
        XCTAssertEqual(snapshot.capacityEstimate.vacationAwayMinutes, 120)
        XCTAssertEqual(snapshot.capacityEstimate.openMinutes, 120)
        XCTAssertEqual(snapshot.capacityEstimate.totalOpenMinutes, 120)
        XCTAssertTrue(snapshot.capacityEstimate.summary.contains("away"))
    }

    func testOverlappingProtectedCalendarAndScheduledWindowsProduceDeterministicConflicts() {
        let now = Date(timeIntervalSince1970: 1_714_000_000)
        let horizon = DateInterval(start: now, end: now.addingTimeInterval(4 * 3_600))
        let protected = RealityWindow(
            id: "protected-1",
            kind: .protected,
            source: .userDefined,
            start: now.addingTimeInterval(3_600),
            end: now.addingTimeInterval(7_200),
            title: "Protected time"
        )
        let calendarBusy = RealityWindow(
            id: "calendar-1",
            kind: .calendarDerivedBusy,
            source: .calendarDerived,
            start: now.addingTimeInterval(5_400),
            end: now.addingTimeInterval(9_000),
            title: "Calendar busy"
        )
        let block = ScheduledAmbitionsBlock(
            id: "scheduled-1",
            title: "Ambitions block",
            start: now.addingTimeInterval(7_200),
            end: now.addingTimeInterval(10_800),
            isUserConfirmed: true
        )

        let snapshot = RealityModelProjector().project(
            input: RealityProjectionInput(
                now: now,
                horizon: horizon,
                protectedWindows: [protected],
                scheduledBlocks: [block],
                calendarBusyWindows: [calendarBusy]
            )
        )

        XCTAssertEqual(snapshot.conflictSummary.conflictCount, 3)
        XCTAssertEqual(snapshot.conflictSummary.affectedWindowIDs, ["calendar-1", "protected-1", "window.scheduled.scheduled-1"])
        XCTAssertEqual(snapshot.conflictSummary.calendarConflictCount, 1)
        XCTAssertEqual(snapshot.conflictSummary.protectedConflictCount, 1)
        XCTAssertTrue(snapshot.conflictSummary.summary.contains("3 windows overlap"))
    }

    func testTimeFitProofSummarizesOpenWindowAndDeadlinePressure() {
        let now = Date(timeIntervalSince1970: 1_714_000_000)
        let horizon = DateInterval(start: now, end: now.addingTimeInterval(4 * 3_600))
        let blocked = RealityWindow(
            id: "blocked-1",
            kind: .blockedBusy,
            source: .userDefined,
            start: now.addingTimeInterval(7_200),
            end: now.addingTimeInterval(10_800),
            title: "Blocked"
        )

        let snapshot = RealityModelProjector().project(
            input: RealityProjectionInput(
                now: now,
                horizon: horizon,
                blockedWindows: [blocked],
                deadlineHints: [now.addingTimeInterval(9_000)],
                minimumWindowMinutes: 15
            )
        )

        XCTAssertTrue(snapshot.openWindowCandidates.first?.fitSummary.contains("minutes open") == true)
        XCTAssertTrue(snapshot.capacityEstimate.timeFitProofSummary.contains("Time fit proof"))
        XCTAssertTrue(snapshot.capacityEstimate.timeFitProofSummary.contains("Deadline pressure:"))
        XCTAssertEqual(snapshot.capacityEstimate.deadlineFitProofSummary, snapshot.deadlinePressure.summary)
        XCTAssertTrue(snapshot.capacityEstimate.deadlineFitProofSummary.contains("open minutes are visible before the next deadline"))
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
            userInitiatedTimeAction: "Find real open windows",
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
