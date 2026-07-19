import Foundation

struct CommandRouteDecision: Sendable, Equatable {
    let kind: AmbitionsCommandKind
    let destination: AmbitionsCommandDestination?
}

struct CommandRouter: Sendable {
    func route(_ action: NowAction) -> CommandRouteDecision {
        switch action.kind {
        case .none:
            return CommandRouteDecision(kind: .openDestination, destination: .today)
        case .focus:
            return CommandRouteDecision(kind: .startStepSession, destination: nil)
        case .completeAction:
            return CommandRouteDecision(kind: .completeAction, destination: nil)
        case .openGoal:
            return CommandRouteDecision(kind: .openDestination, destination: .goalDetail)
        case .openTime, .schedule:
            return CommandRouteDecision(kind: .openDestination, destination: .time)
        case .capture:
            return CommandRouteDecision(kind: .openDestination, destination: .capture)
        case .recover:
            return CommandRouteDecision(kind: .recoverAction, destination: nil)
        case .review:
            return CommandRouteDecision(kind: .openDestination, destination: .reviews)
        case .wait:
            return CommandRouteDecision(kind: .markWaiting, destination: nil)
        case .routeCommitment:
            return CommandRouteDecision(kind: .routeCommitment, destination: nil)
        case .explain:
            return CommandRouteDecision(kind: .askWhy, destination: nil)
        }
    }

    func requiresConfirmation(_ command: AmbitionsCommand) -> Bool {
        AmbitionsCommandValidator().validate(command) == .needsConfirmation
    }
}
