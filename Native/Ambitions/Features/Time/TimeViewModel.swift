import Foundation
import Observation

@MainActor
@Observable
final class TimeViewModel {
    var state: AsyncViewState<TimeDashboard>

    private var hasLoaded = false

    var stateKey: String {
        switch state {
        case .loading:
            return "loading"
        case let .loaded(dashboard):
            return "loaded:\(dashboard.mode):\(dashboard.weekDays.count):\(dashboard.goalShapingItems.count):\(dashboard.shapingActions.count)"
        case let .failed(message):
            return "failed:\(message)"
        }
    }

    init(state: AsyncViewState<TimeDashboard> = .loading) {
        self.state = state
    }

    func load(using service: any TimeServicing, now: Date = .now) async {
        guard hasLoaded == false else { return }
        hasLoaded = true
        await refresh(using: service, now: now)
    }

    func refresh(using service: any TimeServicing, now: Date = .now) async {
        do {
            state = .loaded(try await service.loadTimeDashboard(now: now))
        } catch {
            state = .failed("Unable to load Time: \(error.localizedDescription)")
        }
    }

    func makeCalendarAware(using service: any TimeServicing, now: Date = .now) async {
        do {
            state = .loaded(try await service.makeTimeCalendarAware(now: now))
        } catch {
            state = .failed("Unable to make Time calendar-aware: \(error.localizedDescription)")
        }
    }
}
