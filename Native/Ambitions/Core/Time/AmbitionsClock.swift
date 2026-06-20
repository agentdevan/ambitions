import Foundation

protocol AmbitionsClock: Sendable {
    var now: Date { get }
    var calendar: Calendar { get }
    var timeZone: TimeZone { get }
    var advancesAutomatically: Bool { get }
}

struct TestClock: AmbitionsClock, Equatable {
    let now: Date
    let calendar: Calendar
    let timeZone: TimeZone
    let advancesAutomatically: Bool = false

    init(
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

    func advanced(by interval: TimeInterval) -> TestClock {
        TestClock(now: now.addingTimeInterval(interval), calendar: calendar, timeZone: timeZone)
    }
}

enum AmbitionsClockFactory {
    static func clock(
        for source: AppSession.BootstrapSource,
        environment: [String: String] = ProcessInfo.processInfo.environment
    ) -> any AmbitionsClock {
        #if DEBUG
        if let override = PreviewClock.environmentOverride(environment) {
            return override
        }
        if source == .preview {
            return PreviewClock.default
        }
        #endif
        return SystemClock()
    }
}
