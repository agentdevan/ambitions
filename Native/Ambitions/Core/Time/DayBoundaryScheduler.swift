import Foundation

struct DayBoundaryScheduler: Equatable, Sendable {
    struct LoadedClockContext: Equatable, Sendable {
        let dayStart: Date
        let timeZoneIdentifier: String
        let secondsFromGMT: Int
    }

    func loadedDayStart(for now: Date, calendar: Calendar) -> Date {
        calendar.startOfDay(for: now)
    }

    func loadedClockContext(for now: Date, calendar: Calendar, timeZone: TimeZone) -> LoadedClockContext {
        LoadedClockContext(
            dayStart: loadedDayStart(for: now, calendar: calendar),
            timeZoneIdentifier: timeZone.identifier,
            secondsFromGMT: timeZone.secondsFromGMT(for: now)
        )
    }

    func shouldRefresh(lastLoadedDayStart: Date?, now: Date, calendar: Calendar) -> Bool {
        guard let lastLoadedDayStart else {
            return true
        }
        return calendar.isDate(lastLoadedDayStart, inSameDayAs: now) == false
    }

    func shouldRefresh(lastLoadedClockContext: LoadedClockContext?, now: Date, calendar: Calendar, timeZone: TimeZone) -> Bool {
        guard let lastLoadedClockContext else {
            return true
        }
        return loadedClockContext(for: now, calendar: calendar, timeZone: timeZone) != lastLoadedClockContext
    }
}
