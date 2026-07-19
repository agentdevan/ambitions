import Foundation

public protocol AmbitionsClock: Sendable {
    var now: Date { get }
    var calendar: Calendar { get }
    var timeZone: TimeZone { get }
    var advancesAutomatically: Bool { get }
}

#if DEBUG
public struct TestClock: AmbitionsClock, Equatable {
    public let now: Date
    public let calendar: Calendar
    public let timeZone: TimeZone
    public let advancesAutomatically: Bool = false

    public init(
        now: Date,
        calendar: Calendar = PreviewClock.utcCalendar,
        timeZone: TimeZone = PreviewClock.utcTimeZone
    ) {
        self.now = now
        var adjustedCalendar = calendar
        adjustedCalendar.timeZone = timeZone
        self.calendar = adjustedCalendar
        self.timeZone = timeZone
    }

    public func advanced(by interval: TimeInterval) -> TestClock {
        TestClock(now: now.addingTimeInterval(interval), calendar: calendar, timeZone: timeZone)
    }
}
#endif
