import Foundation

struct RuntimeTickPolicy: Equatable, Sendable {
    let timeZoneProvider: TimeZoneProvider
    let localeIdentifier: String

    static let system = RuntimeTickPolicy()
    static let utc = RuntimeTickPolicy(timeZoneProvider: .utc, localeIdentifier: "en_US_POSIX")

    init(
        timeZoneProvider: TimeZoneProvider = .current,
        localeIdentifier: String = Locale.current.identifier
    ) {
        self.timeZoneProvider = timeZoneProvider
        self.localeIdentifier = localeIdentifier
    }

    init(calendar: Calendar, locale: Locale = .current) {
        self.init(timeZoneProvider: TimeZoneProvider(timeZone: calendar.timeZone), localeIdentifier: locale.identifier)
    }

    var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZoneProvider.timeZone
        return calendar
    }

    var locale: Locale {
        Locale(identifier: localeIdentifier)
    }

    func startOfDay(for date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    func date(byAdding component: Calendar.Component, value: Int, to date: Date) -> Date? {
        calendar.date(byAdding: component, value: value, to: date)
    }

    func dayDistance(from start: Date, to end: Date) -> Int? {
        calendar.dateComponents([.day], from: start, to: end).day
    }

    func isSameDay(_ lhs: Date, _ rhs: Date) -> Bool {
        calendar.isDate(lhs, inSameDayAs: rhs)
    }

    func localizedLabel(for date: Date, template: String) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = locale
        formatter.timeZone = timeZoneProvider.timeZone
        formatter.setLocalizedDateFormatFromTemplate(template)
        return formatter.string(from: date)
    }

    func shortMonthDayLabel(for date: Date) -> String {
        localizedLabel(for: date, template: "MMM d")
    }

    func shortWeekdayLabel(for date: Date) -> String {
        localizedLabel(for: date, template: "EEE")
    }

    func dayOfMonthLabel(for date: Date) -> String {
        localizedLabel(for: date, template: "d")
    }

    func shortTimeLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = locale
        formatter.timeZone = timeZoneProvider.timeZone
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: date)
    }

    func parseDateOnly(_ value: String) -> Date? {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = timeZoneProvider.timeZone
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: value)
    }

    func parseISODate(_ value: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: value) {
            return date
        }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: value)
    }
}
