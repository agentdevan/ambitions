import Foundation

protocol AmbitionsClock: Sendable {
    var now: Date { get }
    var calendar: Calendar { get }
    var timeZone: TimeZone { get }
    var advancesAutomatically: Bool { get }
}

struct SystemClock: AmbitionsClock {
    var now: Date { Date() }
    var timeZone: TimeZone { TimeZone.current }
    var advancesAutomatically: Bool { true }

    var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return calendar
    }
}

struct PreviewClock: AmbitionsClock, Equatable {
    static let environmentKey = "AMBITIONS_PREVIEW_CLOCK_ISO"
    static let defaultNow = Date(timeIntervalSince1970: 1_776_254_400)
    static let utcTimeZone = TimeZone(secondsFromGMT: 0)!

    let now: Date
    let calendar: Calendar
    let timeZone: TimeZone
    let advancesAutomatically: Bool = false

    init(
        now: Date = Self.defaultNow,
        calendar: Calendar = Self.utcCalendar,
        timeZone: TimeZone = Self.utcTimeZone
    ) {
        self.now = now
        var adjustedCalendar = calendar
        adjustedCalendar.timeZone = timeZone
        self.calendar = adjustedCalendar
        self.timeZone = timeZone
    }

    static var `default`: PreviewClock {
        PreviewClock()
    }

    static var utcCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = utcTimeZone
        return calendar
    }

    static func environmentOverride(_ environment: [String: String] = ProcessInfo.processInfo.environment) -> PreviewClock? {
        guard let value = environment[environmentKey]?.trimmingCharacters(in: .whitespacesAndNewlines),
              value.isEmpty == false,
              let date = parseISODate(value) else {
            return nil
        }
        return PreviewClock(now: date)
    }

    private static func parseISODate(_ value: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: value) {
            return date
        }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: value)
    }
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
