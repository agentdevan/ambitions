import Foundation
import Observation

@MainActor
@Observable
final class PlanViewModel {
    var state: AsyncViewState<PlanDashboard>

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

    init(state: AsyncViewState<PlanDashboard> = .loading) {
        self.state = state
    }

    func load(using service: any PlanServicing, now: Date = .now) async {
        guard hasLoaded == false else { return }
        hasLoaded = true
        await refresh(using: service, now: now)
    }

    func refresh(using service: any PlanServicing, now: Date = .now) async {
        do {
            state = .loaded(try await service.loadPlanDashboard(now: now))
        } catch {
            state = .failed("Unable to load Plan: \(error.localizedDescription)")
        }
    }
}
