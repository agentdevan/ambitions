import Foundation
import Observation

@MainActor
@Observable
final class HabitsViewModel {
    var state: AsyncViewState<HabitsDashboard>
    var inlineMessage: HabitInlineMessage?

    private var hasLoaded = false

    var stateKey: String {
        switch state {
        case .loading:
            return "loading"
        case let .loaded(dashboard):
            return "loaded:\(dashboard.mode):\(dashboard.habits.count):\(dashboard.recoveryHabits.count)"
        case let .failed(message):
            return "failed:\(message)"
        }
    }

    init(
        state: AsyncViewState<HabitsDashboard> = .loading,
        inlineMessage: HabitInlineMessage? = nil
    ) {
        self.state = state
        self.inlineMessage = inlineMessage
    }

    func load(using service: any HabitsServicing, now: Date = .now) async {
        guard hasLoaded == false else { return }
        hasLoaded = true
        await refresh(using: service, now: now)
    }

    func refresh(using service: any HabitsServicing, now: Date = .now) async {
        do {
            state = .loaded(try await service.loadDashboard(now: now))
        } catch {
            state = .failed("Unable to load Habits: \(error.localizedDescription)")
        }
    }

    func perform(_ action: HabitActionState, using service: any HabitsServicing, now: Date = .now) async {
        do {
            let response = try await service.performAction(
                HabitActionRequest(kind: action.kind, target: action.target),
                now: now
            )
            inlineMessage = response.message
            await refresh(using: service, now: now)
        } catch {
            inlineMessage = HabitInlineMessage(
                title: "Habit action failed",
                body: error.localizedDescription,
                state: .warning
            )
        }
    }
}
