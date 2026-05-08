import XCTest
@testable import Ambitions

final class RealityIntegrationAdaptersTests: XCTestCase {
    func testLedgerEntryForCalendarContextIsCalendarDerivedAndLocalOnly() {
        let now = Date(timeIntervalSince1970: 1_714_000_000)
        let snapshot = RealityModelProjector().project(
            input: RealityProjectionInput(
                now: now,
                horizon: DateInterval(start: now, end: now.addingTimeInterval(3_600)),
                calendarContext: CalendarDerivedContext(
                    permissionState: .denied,
                    explanation: "No calendar data was read."
                )
            )
        )

        let entry = RealityIntegrationAdapter.calendarContextObservedEntry(
            snapshot: snapshot,
            occurredAt: now,
            actionName: "Make Time calendar-aware"
        )

        XCTAssertEqual(entry.kind, .calendarContextObserved)
        XCTAssertEqual(entry.source, .plan)
        XCTAssertEqual(entry.privacy, .calendarDerived)
        XCTAssertTrue(entry.localOnly)
        XCTAssertNil(entry.payload["rawEventTitle"])
    }

    func testCalendarAwareExplanationMarksCalendarDerivedEvidence() {
        let now = Date(timeIntervalSince1970: 1_714_000_000)
        let context = CalendarDerivedContext(permissionState: .readWrite, explanation: "Derived busy time was used locally.")
        let snapshot = RealityModelProjector().project(
            input: RealityProjectionInput(
                now: now,
                horizon: DateInterval(start: now, end: now.addingTimeInterval(3_600)),
                calendarContext: context
            )
        )

        let explanation = RealityIntegrationAdapter.calendarAwareExplanation(snapshot: snapshot, ledgerEntryID: "ledger-1")

        XCTAssertTrue(explanation.containsCalendarDerivedEvidence)
        XCTAssertEqual(explanation.privacy, .calendarDerived)
        XCTAssertEqual(explanation.relations.eventLedgerEntryIDs, ["ledger-1"])
    }

    func testNowPressureAdapterUsesRealityCapacityWithoutCalendarPermissionDependency() {
        let now = Date(timeIntervalSince1970: 1_714_000_000)
        let projector = RealityModelProjector()
        let snapshot = projector.project(
            input: RealityProjectionInput(now: now, horizon: DateInterval(start: now, end: now.addingTimeInterval(3_600)))
        )

        let pressure = projector.nowPressureSummary(from: snapshot)

        XCTAssertEqual(pressure.level, snapshot.capacityEstimate.capacityLevel)
        XCTAssertTrue(pressure.summary.contains("baseline"))
    }
}
