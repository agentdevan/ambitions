import Foundation

struct RuntimeNavigationRequest: Sendable, Equatable {
    let destination: AmbitionsCommandDestination

    init(destination: AmbitionsCommandDestination) {
        self.destination = destination
    }

    init?(openDestination command: RuntimeHistoryRepairCommand) {
        let isNavigation: Bool
        switch command.value.typedPayload {
        case let .history(history):
            if case .openDestination = history.action { isNavigation = true } else { isNavigation = false }
        case let .repair(repair):
            isNavigation = repair.action == .openDestination
        default:
            isNavigation = false
        }
        guard isNavigation, let destination = command.value.target.destination else { return nil }
        self.destination = destination
    }
}

struct RuntimeNavigationRoute: Sendable, Equatable {
    let destination: AmbitionsCommandDestination
}

struct RuntimeNavigationRecovery: Sendable, Equatable {
    let kind: RuntimeRecoveryKind
    let reason: RuntimeRecoveryReason
}

enum RuntimeNavigationOutcome: Sendable, Equatable {
    case routed(RuntimeNavigationRoute)
    case unavailable(RuntimeNavigationRecovery)
}

struct RuntimeNavigationClient: Sendable {
    private let route: @Sendable (RuntimeNavigationRequest) async -> RuntimeNavigationOutcome

    init(route: @escaping @Sendable (RuntimeNavigationRequest) async -> RuntimeNavigationOutcome) {
        self.route = route
    }

    func navigate(_ request: RuntimeNavigationRequest) async -> RuntimeNavigationOutcome {
        await route(request)
    }
}
