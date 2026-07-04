import Foundation

enum TemporalMath {
    static var utc: TimeZone {
        TimeZone(secondsFromGMT: 0) ?? .current
    }

    static func calendar(timeZone: TimeZone = TemporalMath.utc) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return calendar
    }

    static func date(from value: String) -> Date? {
        DomainTimestamp.date(from: value) ?? ISO8601DateFormatter().date(from: value)
    }

    static func string(from date: Date) -> String {
        DomainTimestamp.string(from: date)
    }

    static func startOfDay(for date: Date, timeZone: TimeZone = TemporalMath.utc) -> Date {
        calendar(timeZone: timeZone).startOfDay(for: date)
    }

    static func endOfDay(for date: Date, timeZone: TimeZone = TemporalMath.utc) -> Date {
        calendar(timeZone: timeZone).date(byAdding: .day, value: 1, to: startOfDay(for: date, timeZone: timeZone)) ?? date
    }

    static func addDays(_ days: Int, to date: Date, timeZone: TimeZone = TemporalMath.utc) -> Date {
        calendar(timeZone: timeZone).date(byAdding: .day, value: days, to: date) ?? date.addingTimeInterval(TimeInterval(days * 24 * 60 * 60))
    }

    static func end(start: Date, durationMinutes: Int, timeZone: TimeZone = TemporalMath.utc) -> Date {
        calendar(timeZone: timeZone).date(byAdding: .minute, value: max(durationMinutes, 1), to: start) ??
            start.addingTimeInterval(TimeInterval(max(durationMinutes, 1) * 60))
    }

    static func durationMinutes(start: Date, end: Date) -> Int {
        max(0, Int((end.timeIntervalSince(start) / 60.0).rounded(.toNearestOrAwayFromZero)))
    }

    static func intersects(start: Date, end: Date, otherStart: Date, otherEnd: Date) -> Bool {
        start < otherEnd && otherStart < end
    }

    static func overlapMinutes(start: Date, end: Date, otherStart: Date, otherEnd: Date) -> Int {
        guard intersects(start: start, end: end, otherStart: otherStart, otherEnd: otherEnd) else { return 0 }
        return durationMinutes(start: max(start, otherStart), end: min(end, otherEnd))
    }

    static func window(start: Date, end: Date) -> ProtectedStepPlacementWindow? {
        ProtectedStepPlacementWindow(start: start, end: end)
    }

    static func window(start: Date, durationMinutes: Int, timeZone: TimeZone = TemporalMath.utc) -> ProtectedStepPlacementWindow? {
        ProtectedStepPlacementWindow(start: start, end: end(start: start, durationMinutes: durationMinutes, timeZone: timeZone))
    }

    static func occurrences(
        startingAt firstOccurrence: Date,
        cadenceDays: Int,
        from lowerBound: Date,
        limit rawLimit: Int,
        timeZone: TimeZone = TemporalMath.utc
    ) -> [Date] {
        let limit = max(0, rawLimit)
        guard limit > 0 else { return [] }

        let cadence = max(1, cadenceDays)
        var cursor = firstOccurrence
        while cursor < lowerBound {
            let next = addDays(cadence, to: cursor, timeZone: timeZone)
            guard next > cursor else { break }
            cursor = next
        }

        var result: [Date] = []
        while result.count < limit {
            result.append(cursor)
            let next = addDays(cadence, to: cursor, timeZone: timeZone)
            guard next > cursor else { break }
            cursor = next
        }
        return result
    }
}
