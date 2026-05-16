import AmbitionsDesignSystem
import XCTest

final class RealityMeridianTemporalWindowTests: XCTestCase {
    func testProgressMapsStartMiddleAndEndOfDefaultWindow() {
        let window = RealityMeridianTemporalWindow(dayStartHour: 6, dayEndHour: 22)

        XCTAssertEqual(window.progress(hour: 6, minute: 0), 0.0, accuracy: 0.0001)
        XCTAssertEqual(window.progress(hour: 14, minute: 0), 0.5, accuracy: 0.0001)
        XCTAssertEqual(window.progress(hour: 22, minute: 0), 1.0, accuracy: 0.0001)
    }

    func testProgressClampsOutsideWindow() {
        let window = RealityMeridianTemporalWindow(dayStartHour: 6, dayEndHour: 22)

        XCTAssertEqual(window.progress(hour: 4, minute: 30), 0.0, accuracy: 0.0001)
        XCTAssertEqual(window.progress(hour: 23, minute: 45), 1.0, accuracy: 0.0001)
    }

    func testProgressMapsExactMinutePosition() {
        let window = RealityMeridianTemporalWindow(dayStartHour: 6, dayEndHour: 22)

        XCTAssertEqual(window.progress(hour: 12, minute: 15), 0.390625, accuracy: 0.0001)
    }

    func testInvalidWindowIsNormalizedToAtLeastOneHour() {
        let window = RealityMeridianTemporalWindow(dayStartHour: 22, dayEndHour: 8)

        XCTAssertEqual(window.dayStartHour, 22)
        XCTAssertEqual(window.dayEndHour, 23)
        XCTAssertEqual(window.durationMinutes, 60)
    }

    func testProgressForDateUsesProvidedCalendar() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try XCTUnwrap(TimeZone(secondsFromGMT: 0))
        let date = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 5, day: 15, hour: 14, minute: 0)))
        let window = RealityMeridianTemporalWindow(dayStartHour: 6, dayEndHour: 22)

        XCTAssertEqual(window.progress(for: date, calendar: calendar), 0.5, accuracy: 0.0001)
    }
}
