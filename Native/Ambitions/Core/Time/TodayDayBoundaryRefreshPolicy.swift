import Foundation

public struct TodayDayBoundaryRefreshPolicy: Equatable, Sendable {
    public typealias LoadedClockContext = DayBoundaryScheduler.LoadedClockContext

    private let scheduler = DayBoundaryScheduler()

    public init() {}

    public func loadedDayStart(for now: Date, calendar: Calendar) -> Date {
        scheduler.loadedDayStart(for: now, calendar: calendar)
    }

    public func loadedClockContext(for now: Date, calendar: Calendar, timeZone: TimeZone) -> LoadedClockContext {
        scheduler.loadedClockContext(for: now, calendar: calendar, timeZone: timeZone)
    }

    public func shouldRefresh(lastLoadedDayStart: Date?, now: Date, calendar: Calendar) -> Bool {
        scheduler.shouldRefresh(lastLoadedDayStart: lastLoadedDayStart, now: now, calendar: calendar)
    }

    public func shouldRefresh(lastLoadedClockContext: LoadedClockContext?, now: Date, calendar: Calendar, timeZone: TimeZone) -> Bool {
        scheduler.shouldRefresh(lastLoadedClockContext: lastLoadedClockContext, now: now, calendar: calendar, timeZone: timeZone)
    }
}
