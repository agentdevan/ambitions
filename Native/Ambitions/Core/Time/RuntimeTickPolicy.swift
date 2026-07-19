import Foundation

public struct RuntimeTickPolicy: Equatable, Sendable {
    private let timeZoneProvider: TimeZoneProvider
    private let localeIdentifier: String
    private let calendarIdentifier: Calendar.Identifier

    public static let system = RuntimeTickPolicy(calendar: .current)
    public static let utc = RuntimeTickPolicy(
        timeZoneProvider: .utc,
        localeIdentifier: "en_US_POSIX",
        calendarIdentifier: .gregorian
    )

    public init(
        timeZoneProvider: TimeZoneProvider = .current,
        localeIdentifier: String = Locale.current.identifier
    ) {
        self.timeZoneProvider = timeZoneProvider
        self.localeIdentifier = localeIdentifier
        calendarIdentifier = .gregorian
    }

    public init(calendar: Calendar, locale: Locale = .current) {
        timeZoneProvider = TimeZoneProvider(timeZone: calendar.timeZone)
        localeIdentifier = locale.identifier
        calendarIdentifier = calendar.identifier
    }

    private init(
        timeZoneProvider: TimeZoneProvider,
        localeIdentifier: String,
        calendarIdentifier: Calendar.Identifier
    ) {
        self.timeZoneProvider = timeZoneProvider
        self.localeIdentifier = localeIdentifier
        self.calendarIdentifier = calendarIdentifier
    }

    public var calendar: Calendar {
        var calendar = Calendar(identifier: calendarIdentifier)
        calendar.timeZone = timeZoneProvider.timeZone
        return calendar
    }

    private var locale: Locale {
        Locale(identifier: localeIdentifier)
    }

    public func startOfDay(for date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    public func date(byAdding component: Calendar.Component, value: Int, to date: Date) -> Date? {
        calendar.date(byAdding: component, value: value, to: date)
    }

    public func dayDistance(from start: Date, to end: Date) -> Int? {
        calendar.dateComponents([.day], from: start, to: end).day
    }

    public func isSameDay(_ lhs: Date, _ rhs: Date) -> Bool {
        calendar.isDate(lhs, inSameDayAs: rhs)
    }

    private func localizedLabel(for date: Date, template: String) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = locale
        formatter.timeZone = timeZoneProvider.timeZone
        formatter.setLocalizedDateFormatFromTemplate(template)
        return formatter.string(from: date)
    }

    public func shortMonthDayLabel(for date: Date) -> String {
        localizedLabel(for: date, template: "MMM d")
    }

    public func shortWeekdayLabel(for date: Date) -> String {
        localizedLabel(for: date, template: "EEE")
    }

    public func dayOfMonthLabel(for date: Date) -> String {
        localizedLabel(for: date, template: "d")
    }

    public func shortTimeLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = locale
        formatter.timeZone = timeZoneProvider.timeZone
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: date)
    }

    public func parseDateOnly(_ value: String) -> Date? {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = timeZoneProvider.timeZone
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: value)
    }

    public func parseISODate(_ value: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: value) {
            return date
        }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: value)
    }
}
