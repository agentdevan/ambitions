import Foundation
import Observation

@MainActor
@Observable
final class TimeRitualsViewModel {
    var state: AsyncViewState<TimeRitualsDashboard>
    var inlineMessage: TimeRitualInlineMessage?
    var mutationProof: TimeRitualsMutationProof?

    private var hasLoaded = false

    var stateKey: String {
        switch state {
        case .loading:
            return "loading"
        case let .loaded(dashboard):
            return "loaded:\(dashboard.mode):\(dashboard.rituals.count):\(dashboard.recoveryRituals.count)"
        case let .failed(message):
            return "failed:\(message)"
        }
    }

    var accessibilitySummary: String {
        TimeRitualsAccessibility.summary(for: state, inlineMessage: inlineMessage)
    }

    init(
        state: AsyncViewState<TimeRitualsDashboard> = .loading,
        inlineMessage: TimeRitualInlineMessage? = nil
    ) {
        self.state = state
        self.inlineMessage = inlineMessage
    }

    func load(using service: any TimeRitualsServicing, now: Date) async {
        guard hasLoaded == false else { return }
        hasLoaded = true
        await refresh(using: service, now: now)
    }

    func refresh(using service: any TimeRitualsServicing, now: Date) async {
        do {
            state = .loaded(try await service.loadDashboard(now: now))
        } catch {
            state = .failed("Unable to load Rituals: \(error.localizedDescription)")
        }
    }

    func perform(_ action: TimeRitualActionState, using service: any TimeRitualsServicing, now: Date) async {
        do {
            let response = try await service.performAction(
                TimeRitualActionRequest(kind: action.kind, target: action.target),
                now: now
            )
            inlineMessage = response.message
            await refresh(using: service, now: now)
            mutationProof = TimeRitualsMutationProof(action: action, response: response)
        } catch {
            inlineMessage = TimeRitualInlineMessage(
                title: "Ritual action could not finish",
                body: error.localizedDescription,
                state: .warning
            )
            mutationProof = TimeRitualsMutationProof.failed(action: action, message: error.localizedDescription)
        }
    }

    func recordStageRouteMutation(action: TimeRitualActionState) {
        mutationProof = TimeRitualsMutationProof.route(action: action)
    }

    func recordStageRouteMutation(label: String, routeID: String) {
        mutationProof = TimeRitualsMutationProof.route(label: label, routeID: routeID)
    }
}
