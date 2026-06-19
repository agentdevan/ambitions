import Foundation

struct TodayDayBoundaryRefreshPolicy: Equatable, Sendable {
    func loadedDayStart(for now: Date, calendar: Calendar) -> Date {
        calendar.startOfDay(for: now)
    }

    func shouldRefresh(lastLoadedDayStart: Date?, now: Date, calendar: Calendar) -> Bool {
        guard let lastLoadedDayStart else {
            return true
        }
        return calendar.isDate(lastLoadedDayStart, inSameDayAs: now) == false
    }
}
