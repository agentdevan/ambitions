import AmbitionsTimeFoundation
import Foundation
import XCTest

final class TimeFoundationModuleTests: XCTestCase {
    func testUTCPolicyParsesAndAdvancesDatesDeterministically() throws {
        let policy = RuntimeTickPolicy.utc
        let start = try XCTUnwrap(policy.parseISODate("2026-07-10T12:00:00Z"))
        let next = try XCTUnwrap(policy.date(byAdding: .day, value: 1, to: start))
        XCTAssertEqual(policy.dayDistance(from: start, to: next), 1)
    }

    func testFixedSystemClockUsesInjectedTimeZone() {
        let clock = SystemClock(timeZoneProvider: .utc)
        XCTAssertEqual(clock.timeZone.secondsFromGMT(for: clock.now), 0)
        XCTAssertTrue(clock.advancesAutomatically)
    }

    func testDayBoundaryRefreshDetectsTimeZoneChange() throws {
        let policy = TodayDayBoundaryRefreshPolicy()
        let now = try XCTUnwrap(RuntimeTickPolicy.utc.parseISODate("2026-07-10T12:00:00Z"))
        let utc = TimeZone(secondsFromGMT: 0)!
        let west = TimeZone(secondsFromGMT: -7_200)!
        let loaded = policy.loadedClockContext(for: now, calendar: RuntimeTickPolicy.utc.calendar, timeZone: utc)
        XCTAssertFalse(policy.shouldRefresh(lastLoadedClockContext: loaded, now: now, calendar: RuntimeTickPolicy.utc.calendar, timeZone: utc))
        let westPolicy = RuntimeTickPolicy(timeZoneProvider: TimeZoneProvider(timeZone: west))
        XCTAssertTrue(policy.shouldRefresh(lastLoadedClockContext: loaded, now: now, calendar: westPolicy.calendar, timeZone: west))
    }

    func testInjectedNonGregorianCalendarPreservesIdentifierTimeZoneAndFormatting() throws {
        let timeZone = try XCTUnwrap(TimeZone(identifier: "Asia/Bangkok"))
        var calendar = Calendar(identifier: .buddhist)
        calendar.timeZone = timeZone
        let policy = RuntimeTickPolicy(calendar: calendar, locale: Locale(identifier: "th_TH"))
        let date = try XCTUnwrap(RuntimeTickPolicy.utc.parseISODate("2026-07-10T12:00:00Z"))

        let expectedFormatter = DateFormatter()
        expectedFormatter.calendar = calendar
        expectedFormatter.locale = Locale(identifier: "th_TH")
        expectedFormatter.timeZone = timeZone
        expectedFormatter.timeStyle = .short
        expectedFormatter.dateStyle = .none

        XCTAssertEqual(policy.calendar.identifier, .buddhist)
        XCTAssertEqual(policy.calendar.timeZone.identifier, timeZone.identifier)
        XCTAssertEqual(policy.shortTimeLabel(for: date), expectedFormatter.string(from: date))
    }
}
