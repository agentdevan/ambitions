import XCTest
@testable import Ambitions

final class OpenCapacityEngineTests: XCTestCase {
    func testThresholdsAreDeterministicAfterTransitionBuffer() {
        XCTAssertEqual(window(usableMinutes: 9, buffer: 5).band, .transitionOnly)
        XCTAssertEqual(window(usableMinutes: 24, buffer: 5).band, .lightWindow)
        XCTAssertEqual(window(usableMinutes: 59, buffer: 5).band, .focusedBlock)
        XCTAssertEqual(window(usableMinutes: 60, buffer: 5).band, .deepBlock)
    }

    func testEmptyUnavailableInputDoesNotFabricateOpenCapacity() {
        let projection = OpenCapacityEngine().project(OpenCapacityInput(
            now: base,
            dayStart: base,
            dayEnd: base.addingTimeInterval(8 * 60 * 60),
            calendarPermissionState: .unavailable
        ))

        XCTAssertTrue(projection.windows.isEmpty)
        XCTAssertTrue(projection.visibleWindows.isEmpty)
        XCTAssertEqual(projection.calendarFallback?.kind, .sourceUnavailable)
        XCTAssertTrue(projection.semanticSummary.contains("no open capacity is claimed"))
    }

    func testCalendarDeniedKeepsManualPlanningUsefulWhenManualInputsExist() {
        let manualBoundary = protectedBoundary(id: "manual", startMinute: 60, endMinute: 120)
        let projection = OpenCapacityEngine().project(OpenCapacityInput(
            now: base,
            dayStart: base,
            dayEnd: base.addingTimeInterval(4 * 60 * 60),
            protectedBoundaries: [manualBoundary],
            calendarPermissionState: .denied
        ))

        XCTAssertEqual(projection.calendarFallback?.kind, .calendarUnavailable)
        XCTAssertFalse(projection.visibleWindows.isEmpty)
        XCTAssertTrue(projection.visibleWindows.allSatisfy { $0.derivation.fallbackState?.kind == .calendarUnavailable })
    }

    func testDenseDayReducesToStrongestOpenWindows() {
        let fixedPoints = (0..<6).map { index in
            fixedPoint(id: "fixed-\(index)", startMinute: 45 + index * 105, endMinute: 80 + index * 105)
        }
        let projection = OpenCapacityEngine().project(OpenCapacityInput(
            now: base,
            dayStart: base,
            dayEnd: base.addingTimeInterval(12 * 60 * 60),
            fixedPoints: fixedPoints,
            planningDefaults: LifeShapePlanningDefaults(transitionBufferMinutes: 5),
            stepDurationEstimates: [15, 45],
            calendarPermissionState: .readWrite
        ))

        XCTAssertGreaterThan(projection.windows.count, 4)
        XCTAssertLessThanOrEqual(projection.visibleWindows.count, 3)
        XCTAssertTrue(projection.visibleWindows.allSatisfy { $0.band == .focusedBlock })
    }

    private func window(usableMinutes: Int, buffer: Int) -> OpenCapacityWindow {
        let projection = OpenCapacityEngine().project(OpenCapacityInput(
            now: base,
            dayStart: base,
            dayEnd: base.addingTimeInterval(TimeInterval((usableMinutes + buffer) * 60)),
            planningDefaults: LifeShapePlanningDefaults(transitionBufferMinutes: buffer),
            calendarPermissionState: .readWrite
        ))
        return projection.visibleWindows[0]
    }

    private var base: Date {
        Date(timeIntervalSince1970: 1_800_000_000)
    }

    private func fixedPoint(id: String, startMinute: Int, endMinute: Int, nonNegotiable: Bool = false) -> FixedPoint {
        FixedPoint(
            id: id,
            title: id,
            start: base.addingTimeInterval(TimeInterval(startMinute * 60)),
            end: base.addingTimeInterval(TimeInterval(endMinute * 60)),
            isNonNegotiable: nonNegotiable,
            inputRef: LifeShapeInputRef(id: id, kind: .fixedPoint, label: id)
        )
    }

    private func protectedBoundary(id: String, startMinute: Int, endMinute: Int) -> ProtectedBoundary {
        ProtectedBoundary(
            id: id,
            title: id,
            start: base.addingTimeInterval(TimeInterval(startMinute * 60)),
            end: base.addingTimeInterval(TimeInterval(endMinute * 60)),
            reason: "Manual protected time.",
            inputRef: LifeShapeInputRef(id: id, kind: .protectedBoundary, label: id)
        )
    }
}
