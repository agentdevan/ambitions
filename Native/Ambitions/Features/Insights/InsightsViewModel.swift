import Foundation
import Observation

@MainActor
@Observable
final class InsightsViewModel {
    var state: AsyncViewState<InsightsDashboard>

    private var hasLoaded = false

    var stateKey: String {
        switch state {
        case .loading:
            return "loading"
        case let .loaded(dashboard):
            return "loaded:\(dashboard.stats.count):\(dashboard.changeSummaries.count):\(dashboard.goalStatuses.count):\(dashboard.activities.count)"
        case let .failed(message):
            return "failed:\(message)"
        }
    }

    init(state: AsyncViewState<InsightsDashboard> = .loading) {
        self.state = state
    }

    func load(using service: any InsightsServicing) async {
        guard hasLoaded == false else { return }
        hasLoaded = true
        await refresh(using: service)
    }

    func refresh(using service: any InsightsServicing) async {
        do {
            state = .loaded(try await service.loadInsightsDashboard())
        } catch {
            state = .failed("Unable to load Insights: \(error.localizedDescription)")
        }
    }
}
