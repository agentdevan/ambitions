import Foundation

#if DEBUG
struct PreviewClock: AmbitionsClock, Equatable {
    static let environmentKey = "AMBITIONS_PREVIEW_CLOCK_ISO"
    static let defaultNow = Date(timeIntervalSince1970: 1_776_254_400)
    static let utcTimeZone = TimeZoneProvider.utc.timeZone

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
        RuntimeTickPolicy(timeZoneProvider: .utc).calendar
    }

    static func environmentOverride(_ environment: [String: String] = ProcessInfo.processInfo.environment) -> PreviewClock? {
        guard let value = environment[environmentKey]?.trimmingCharacters(in: .whitespacesAndNewlines),
              value.isEmpty == false,
              let date = RuntimeTickPolicy.utc.parseISODate(value) else {
            return nil
        }
        return PreviewClock(now: date)
    }
}
#endif
