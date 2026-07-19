import Foundation

#if DEBUG
public struct PreviewClock: AmbitionsClock, Equatable {
    public static let environmentKey = "AMBITIONS_PREVIEW_CLOCK_ISO"
    public static let defaultNow = Date(timeIntervalSince1970: 1_776_254_400)
    public static let utcTimeZone = TimeZoneProvider.utc.timeZone

    public let now: Date
    public let calendar: Calendar
    public let timeZone: TimeZone
    public let advancesAutomatically: Bool = false

    public init(
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

    public static var `default`: PreviewClock {
        PreviewClock()
    }

    public static var utcCalendar: Calendar {
        RuntimeTickPolicy(timeZoneProvider: .utc).calendar
    }

    public static func environmentOverride(_ environment: [String: String] = ProcessInfo.processInfo.environment) -> PreviewClock? {
        guard let value = environment[environmentKey]?.trimmingCharacters(in: .whitespacesAndNewlines),
              value.isEmpty == false,
              let date = RuntimeTickPolicy.utc.parseISODate(value) else {
            return nil
        }
        return PreviewClock(now: date)
    }
}
#endif
