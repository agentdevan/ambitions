import Foundation

struct TodayDayBoundaryRefreshPolicy: Equatable, Sendable {
    typealias LoadedClockContext = DayBoundaryScheduler.LoadedClockContext

    private let scheduler = DayBoundaryScheduler()

    func loadedDayStart(for now: Date, calendar: Calendar) -> Date {
        scheduler.loadedDayStart(for: now, calendar: calendar)
    }

    func loadedClockContext(for now: Date, calendar: Calendar, timeZone: TimeZone) -> LoadedClockContext {
        scheduler.loadedClockContext(for: now, calendar: calendar, timeZone: timeZone)
    }

    func shouldRefresh(lastLoadedDayStart: Date?, now: Date, calendar: Calendar) -> Bool {
        scheduler.shouldRefresh(lastLoadedDayStart: lastLoadedDayStart, now: now, calendar: calendar)
    }

    func shouldRefresh(lastLoadedClockContext: LoadedClockContext?, now: Date, calendar: Calendar, timeZone: TimeZone) -> Bool {
        scheduler.shouldRefresh(lastLoadedClockContext: lastLoadedClockContext, now: now, calendar: calendar, timeZone: timeZone)
    }
}
