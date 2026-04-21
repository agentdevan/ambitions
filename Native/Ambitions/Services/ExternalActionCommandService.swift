import Foundation

enum ExternalActionKind: Equatable, Sendable {
    case complete
    case delay
    case snooze
    case askForSmallerStep
    case openGoal
    case openToday
    case openCapturesInbox
    case unsupported(String)
}

struct ExternalActionTarget: Equatable, Sendable {
    let goalID: String?
    let stepID: String?
    let draftID: String?

    init(goalID: String? = nil, stepID: String? = nil, draftID: String? = nil) {
        self.goalID = goalID
        self.stepID = stepID
        self.draftID = draftID
    }
}

enum ExternalActionSource: Equatable, Sendable {
    case deepLink
    case notification
    case widget
    case futureExternalPayload
}

struct ExternalActionCommand: Equatable, Sendable {
    let kind: ExternalActionKind
    let target: ExternalActionTarget
    let source: ExternalActionSource
    let values: [String: String]

    init(
        kind: ExternalActionKind,
        target: ExternalActionTarget = ExternalActionTarget(),
        source: ExternalActionSource,
        values: [String: String] = [:]
    ) {
        self.kind = kind
        self.target = target
        self.source = source
        self.values = values
    }

    init(notificationPayload payload: AppNotificationRoutingPayload) {
        self.init(
            kind: Self.kind(from: payload.action, values: payload.values),
            target: ExternalActionTarget(
                goalID: payload.values["goalID"],
                stepID: payload.values["stepID"],
                draftID: payload.values["draftID"]
            ),
            source: .notification,
            values: payload.values
        )
    }

    init(widgetPayload payload: AppWidgetRoutingPayload) {
        self.init(
            kind: Self.kind(from: payload.action, values: payload.values),
            target: ExternalActionTarget(
                goalID: payload.values["goalID"],
                stepID: payload.values["stepID"],
                draftID: payload.values["draftID"]
            ),
            source: .widget,
            values: payload.values
        )
    }

    private static func kind(from rawAction: String, values: [String: String] = [:]) -> ExternalActionKind {
        let normalized = rawAction.lowercased()
        let fallback = values[ExternalSurfaceActionPayload.Key.action]?.lowercased()
        let command = normalized == "noop" || normalized.isEmpty ? fallback ?? normalized : normalized

        switch command {
        case "complete":
            return .complete
        case "delay":
            return .delay
        case "snooze":
            return .snooze
        case "ask-for-smaller-step", "smaller-step":
            return .askForSmallerStep
        case "open":
            return .openGoal
        case "open-today":
            return .openToday
        case "open-captures-inbox":
            return .openCapturesInbox
        default:
            return .unsupported(rawAction)
        }
    }
}

enum ExternalActionOutcome: Equatable, Sendable {
    case performed
    case routed
    case missingTarget
    case unsupported
    case failed
}

struct ExternalActionResult: Equatable, Sendable {
    let outcome: ExternalActionOutcome
    let route: AppExternalRoute?
    let messageTitle: String?

    init(outcome: ExternalActionOutcome, route: AppExternalRoute? = nil, messageTitle: String? = nil) {
        self.outcome = outcome
        self.route = route
        self.messageTitle = messageTitle
    }
}

@MainActor
protocol ExternalActionCommandExecuting: AnyObject {
    func execute(_ command: ExternalActionCommand, now: Date) async -> ExternalActionResult
}

@MainActor
final class DefaultExternalActionCommandService: ExternalActionCommandExecuting {
    private let runtimeExecutor: any RuntimeActionCommandExecuting
    private let externalRouter: any AppExternalRouting

    init(
        runtimeExecutor: any RuntimeActionCommandExecuting,
        externalRouter: any AppExternalRouting
    ) {
        self.runtimeExecutor = runtimeExecutor
        self.externalRouter = externalRouter
    }

    init(
        todayService: any TodayServicing,
        goalsService: any GoalsServicing,
        captureService: any CaptureServicing,
        externalRouter: any AppExternalRouting
    ) {
        _ = goalsService
        _ = captureService
        self.runtimeExecutor = DefaultRuntimeActionCommandExecutor(todayService: todayService)
        self.externalRouter = externalRouter
    }

    func execute(_ command: ExternalActionCommand, now: Date) async -> ExternalActionResult {
        let result = await runtimeExecutor.execute(command, now: now)
        guard let routeRequest = result.routeRequest else {
            return ExternalActionResult(
                outcome: result.outcome,
                messageTitle: result.messageTitle
            )
        }
        return route(appRoute(for: routeRequest), source: command.source)
    }

    private func route(_ route: AppExternalRoute, source: ExternalActionSource) -> ExternalActionResult {
        externalRouter.dispatch(route, source: routeSource(for: source))
        return ExternalActionResult(outcome: .routed, route: route)
    }

    private func routeSource(for source: ExternalActionSource) -> AppExternalRouteSource {
        switch source {
        case .deepLink:
            return .deepLink
        case .notification:
            return .notificationAction
        case .widget, .futureExternalPayload:
            return .widgetAction
        }
    }

    private func appRoute(for request: RuntimeRouteRequest) -> AppExternalRoute {
        switch request {
        case .openToday:
            return .openTab(.today)
        case let .openGoalDetail(goalID):
            return .openGoalDetail(goalID: goalID)
        case .openCapturesInbox:
            return .openPlanRoute(.capturesInbox)
        }
    }
}
