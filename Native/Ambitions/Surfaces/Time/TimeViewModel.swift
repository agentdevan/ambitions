import Foundation
import Observation

@MainActor
@Observable
final class TimeViewModel {
    var state: AsyncViewState<TimeSurfaceState>

    private var hasLoaded = false
    private let dayBoundaryScheduler = DayBoundaryScheduler()
    private(set) var lastLoadedDayStart: Date?

    var stateKey: String {
        switch state {
        case .loading:
            return "loading"
        case let .loaded(timeState):
            return "loaded:\(timeState.mode):\(timeState.weekDays.count):\(timeState.goalShapingItems.count):\(timeState.shapingActions.count)"
        case let .failed(message):
            return "failed:\(message)"
        }
    }

    var accessibilitySummary: String {
        switch state {
        case .loading:
            return "Time. LifeShape Field is loading."
        case let .loaded(timeState):
            return TimeAccessibility.rootSummary(for: timeState)
        case let .failed(message):
            return "Time. LifeShape Field failed. \(message)"
        }
    }

    init(state: AsyncViewState<TimeSurfaceState> = .loading) {
        self.state = state
    }

    func load(using service: any TimeServicing, now: Date, calendar: Calendar) async {
        guard hasLoaded == false else { return }
        hasLoaded = true
        await refresh(using: service, now: now, calendar: calendar)
    }

    func refresh(using service: any TimeServicing, now: Date, calendar: Calendar) async {
        do {
            state = .loaded(try await service.loadTimeSurfaceState(now: now))
            lastLoadedDayStart = dayBoundaryScheduler.loadedDayStart(for: now, calendar: calendar)
        } catch {
            state = .failed("Unable to load Time: \(error.localizedDescription)")
        }
    }

    func makeCalendarAware(using service: any TimeServicing, now: Date, calendar: Calendar) async {
        do {
            state = .loaded(try await service.makeTimeCalendarAware(now: now))
            lastLoadedDayStart = dayBoundaryScheduler.loadedDayStart(for: now, calendar: calendar)
        } catch {
            state = .failed("Unable to make Time calendar-aware: \(error.localizedDescription)")
        }
    }

    func shouldRefreshForDayBoundary(now: Date, calendar: Calendar) -> Bool {
        dayBoundaryScheduler.shouldRefresh(lastLoadedDayStart: lastLoadedDayStart, now: now, calendar: calendar)
    }
}
