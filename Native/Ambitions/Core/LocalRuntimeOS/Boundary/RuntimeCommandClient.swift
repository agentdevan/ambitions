import Foundation

enum RuntimeProjectionRequest: Sendable, Equatable {
    case today
    case goals
    case time
    case you
    case search
    case widget
    case appIntent
    case receipt
    case privacy

    var projectionID: ProjectionID {
        switch self {
        case .today: .today
        case .goals: .goals
        case .time: .time
        case .you: .you
        case .search: .search
        case .widget: .widget
        case .appIntent: .appIntent
        case .receipt: .receipt
        case .privacy: .privacy
        }
    }
}

struct RuntimeProjectionSnapshot: Sendable, Equatable {
    let projectionID: String
    let payload: Data
    let eventSequence: Int64
    let payloadChecksum: String
    let materializedAt: String
}

enum RuntimeProjectionClientError: Error, Sendable, Equatable {
    case projectionUnavailable(RuntimeProjectionRequest)
}

struct RuntimeCommandClient: Sendable {
    let execute: @Sendable (
        _ command: AmbitionsCommand,
        _ context: CommandExecutionContext
    ) async -> AmbitionsCommandExecutionResult

    let projection: @Sendable (
        _ request: RuntimeProjectionRequest
    ) async throws -> RuntimeProjectionSnapshot

    init(
        execute: @escaping @Sendable (
            _ command: AmbitionsCommand,
            _ context: CommandExecutionContext
        ) async -> AmbitionsCommandExecutionResult,
        projection: @escaping @Sendable (
            _ request: RuntimeProjectionRequest
        ) async throws -> RuntimeProjectionSnapshot
    ) {
        self.execute = execute
        self.projection = projection
    }
}

extension RuntimeCommandClient: CommandExecuting {
    func validate(_ command: AmbitionsCommand) -> AmbitionsCommandValidationState {
        command.validationState
    }

    func execute(
        _ command: AmbitionsCommand,
        context: CommandExecutionContext
    ) async -> AmbitionsCommandExecutionResult {
        await execute(command, context)
    }
}
