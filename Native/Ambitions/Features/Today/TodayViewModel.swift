import Foundation
import Observation

@MainActor
@Observable
final class TodayViewModel {
    var state: AsyncViewState<TodayExperience>
    var transientMessage: TodayInlineMessage?

    private var hasLoaded = false

    var stateKey: String {
        switch state {
        case .loading:
            return "loading"
        case let .loaded(experience):
            return "loaded:\(experience.mode.rawValue)"
        case let .failed(message):
            return "failed:\(message)"
        }
    }

    init(
        state: AsyncViewState<TodayExperience> = .loading,
        transientMessage: TodayInlineMessage? = nil
    ) {
        self.state = state
        self.transientMessage = transientMessage
    }

    func activate(using service: any TodayServicing, userDisplayName: String, now: Date = .now) async {
        if hasLoaded {
            await refresh(using: service, userDisplayName: userDisplayName, now: now)
        } else {
            await load(using: service, userDisplayName: userDisplayName, now: now)
        }
    }

    func load(using service: any TodayServicing, userDisplayName: String, now: Date = .now) async {
        guard hasLoaded == false else { return }
        hasLoaded = true
        await refresh(using: service, userDisplayName: userDisplayName, now: now)
    }

    func refresh(using service: any TodayServicing, userDisplayName: String, now: Date = .now) async {
        do {
            state = .loaded(try await service.loadTodayExperience(userDisplayName: userDisplayName, now: now))
        } catch {
            state = .failed("Unable to load Today: \(error.localizedDescription)")
        }
    }

    func handle(_ action: TodayInlineAction, using service: any TodayServicing, userDisplayName: String, now: Date = .now) async {
        do {
            let response = try await service.performAction(action, now: now)
            transientMessage = response.message
            await refresh(using: service, userDisplayName: userDisplayName, now: now)
        } catch {
            transientMessage = TodayInlineMessage(
                title: "Action failed",
                body: error.localizedDescription,
                state: .warning
            )
        }
    }
}
