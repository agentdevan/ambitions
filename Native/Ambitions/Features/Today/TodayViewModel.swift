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

    func activate(
        using service: any TodayServicing,
        userDisplayName: String,
        now: Date = .now,
        entryContext: TodayEntryContext = .standard
    ) async {
        if hasLoaded {
            await refresh(using: service, userDisplayName: userDisplayName, now: now, entryContext: entryContext)
        } else {
            await load(using: service, userDisplayName: userDisplayName, now: now, entryContext: entryContext)
        }
    }

    func load(
        using service: any TodayServicing,
        userDisplayName: String,
        now: Date = .now,
        entryContext: TodayEntryContext = .standard
    ) async {
        guard hasLoaded == false else { return }
        hasLoaded = true
        await refresh(using: service, userDisplayName: userDisplayName, now: now, entryContext: entryContext)
    }

    func refresh(
        using service: any TodayServicing,
        userDisplayName: String,
        now: Date = .now,
        entryContext: TodayEntryContext = .standard
    ) async {
        do {
            state = .loaded(try await service.loadTodayExperience(userDisplayName: userDisplayName, now: now, entryContext: entryContext))
        } catch {
            state = .failed("Unable to load Today: \(error.localizedDescription)")
        }
    }

    func handle(
        _ action: TodayInlineAction,
        using service: any TodayServicing,
        userDisplayName: String,
        now: Date = .now,
        entryContext: TodayEntryContext = .standard
    ) async {
        do {
            let response = try await service.performAction(action, now: now)
            transientMessage = response.message
            await refresh(using: service, userDisplayName: userDisplayName, now: now, entryContext: entryContext)
        } catch {
            transientMessage = TodayInlineMessage(
                title: "Action could not finish",
                body: error.localizedDescription,
                state: .warning
            )
        }
    }

    func confirmActionClosure(
        _ closure: TodayActionClosureSheetState,
        outcome: TodayActionClosureOutcomeState,
        using service: any TodayServicing,
        userDisplayName: String,
        now: Date = .now,
        entryContext: TodayEntryContext = .standard
    ) async {
        do {
            let response = try await service.recordActionClosure(closure, outcome: outcome, now: now)
            transientMessage = response.message
            await refresh(using: service, userDisplayName: userDisplayName, now: now, entryContext: entryContext)
        } catch {
            transientMessage = TodayInlineMessage(
                title: "Closure could not be saved",
                body: error.localizedDescription,
                state: .warning
            )
        }
    }
}
