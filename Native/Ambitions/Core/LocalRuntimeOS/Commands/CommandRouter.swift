import Foundation

struct CommandRouteDecision: Sendable, Equatable {
    let operation: RuntimeCommandOperation
    let destination: AmbitionsCommandDestination?
}

struct CommandRouter: Sendable {
    func route(_ action: NowAction) -> CommandRouteDecision {
        switch action.kind {
        case .none:
            return CommandRouteDecision(operation: .openDestination, destination: .today)
        case .focus:
            return CommandRouteDecision(operation: .startStepSession, destination: nil)
        case .completeAction:
            return CommandRouteDecision(operation: .completeAction, destination: nil)
        case .openGoal:
            return CommandRouteDecision(operation: .openDestination, destination: .goalDetail)
        case .openTime, .schedule:
            return CommandRouteDecision(operation: .openDestination, destination: .time)
        case .capture:
            return CommandRouteDecision(operation: .openDestination, destination: .capture)
        case .recover:
            return CommandRouteDecision(operation: .recoverAction, destination: nil)
        case .review:
            return CommandRouteDecision(operation: .openDestination, destination: .reviews)
        case .wait:
            return CommandRouteDecision(operation: .markWaiting, destination: nil)
        case .routeCommitment:
            return CommandRouteDecision(operation: .routeCommitment, destination: nil)
        case .explain:
            return CommandRouteDecision(operation: .askWhy, destination: nil)
        }
    }

    func requiresConfirmation(_ command: AmbitionsCommand) -> Bool {
        AmbitionsCommandValidator().validate(command) == .needsConfirmation
    }
}
