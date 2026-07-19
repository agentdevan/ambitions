import AmbitionsDesignSystem
import Foundation

extension TodayFocusState {
    var shellSummary: GoalShellSummaryState? {
        switch self {
        case let .planned(state):
            return state.shellSummary
        case let .starter(state):
            return state.shellSummary
        case .clarification, .blocked, .empty:
            return nil
        }
    }

    var primaryActionsForRecovery: [TodayInlineAction] {
        switch self {
        case let .planned(state):
            return state.actions
        case let .starter(state):
            return state.actions
        case let .clarification(state):
            return state.actions
        case let .blocked(state):
            return state.actions
        case let .empty(state):
            return state.actions
        }
    }
}
