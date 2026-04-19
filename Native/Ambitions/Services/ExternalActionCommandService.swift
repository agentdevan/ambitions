import AmbitionsDesignSystem
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
    private let todayService: any TodayServicing
    private let goalsService: any GoalsServicing
    private let captureService: any CaptureServicing
    private let externalRouter: any AppExternalRouting

    init(
        todayService: any TodayServicing,
        goalsService: any GoalsServicing,
        captureService: any CaptureServicing,
        externalRouter: any AppExternalRouting
    ) {
        self.todayService = todayService
        self.goalsService = goalsService
        self.captureService = captureService
        self.externalRouter = externalRouter
    }

    func execute(_ command: ExternalActionCommand, now: Date) async -> ExternalActionResult {
        switch command.kind {
        case .complete:
            return await performTodayCommand(.complete, command: command, now: now)
        case .delay, .snooze:
            return await performTodayCommand(.delay, command: command, now: now)
        case .askForSmallerStep:
            return await performTodayCommand(.askForSmallerStep, command: command, now: now)
        case .openGoal:
            guard let goalID = command.target.goalID, goalID.isEmpty == false else {
                return ExternalActionResult(outcome: .missingTarget)
            }
            return route(.openGoalDetail(goalID: goalID), source: command.source)
        case .openToday:
            return route(.openTab(.today), source: command.source)
        case .openCapturesInbox:
            return route(.openCapturesInbox, source: command.source)
        case .unsupported:
            return ExternalActionResult(outcome: .unsupported)
        }
    }

    private func performTodayCommand(
        _ kind: TodayActionKind,
        command: ExternalActionCommand,
        now: Date
    ) async -> ExternalActionResult {
        guard let goalID = command.target.goalID,
              let stepID = command.target.stepID,
              goalID.isEmpty == false,
              stepID.isEmpty == false else {
            return ExternalActionResult(outcome: .missingTarget)
        }

        do {
            let response = try await todayService.performAction(
                TodayInlineAction(
                    kind: kind,
                    title: title(for: kind),
                    systemImage: systemImage(for: kind),
                    state: visualState(for: kind),
                    target: TodayActionTarget(
                        goalID: goalID,
                        stepID: stepID,
                        draftID: command.target.draftID
                    )
                ),
                now: now
            )
            return ExternalActionResult(outcome: .performed, messageTitle: response.message?.title)
        } catch {
            return ExternalActionResult(outcome: .failed)
        }
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

    private func title(for kind: TodayActionKind) -> String {
        switch kind {
        case .complete:
            return "Complete"
        case .delay:
            return "Snooze"
        case .askForSmallerStep:
            return "Smaller step"
        default:
            return "External action"
        }
    }

    private func systemImage(for kind: TodayActionKind) -> String {
        switch kind {
        case .complete:
            return "checkmark"
        case .delay:
            return "clock.badge"
        case .askForSmallerStep:
            return "scissors"
        default:
            return "arrow.right.circle"
        }
    }

    private func visualState(for kind: TodayActionKind) -> AmbitionVisualState {
        switch kind {
        case .complete:
            return .success
        case .delay, .askForSmallerStep:
            return .selected
        default:
            return .default
        }
    }
}
