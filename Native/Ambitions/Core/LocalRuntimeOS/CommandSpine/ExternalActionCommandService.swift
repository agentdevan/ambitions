import Foundation

enum ExternalActionKind: Equatable, Sendable {
    case complete
    case delay
    case snooze
    case askForSmallerStep
    case openGoal
    case openToday
    case openCaptureComposer
    case openMemoryLens
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
    case appIntent
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
        let parsedKind = Self.kind(from: payload.action, values: payload.values)
        self.init(
            kind: Self.notificationSafeKind(parsedKind, values: payload.values),
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
        case "open-capture-composer":
            return .openCaptureComposer
        case "open-memory-lens", "memory-lens":
            return .openMemoryLens
        default:
            return .unsupported(rawAction)
        }
    }

    private static func notificationSafeKind(
        _ kind: ExternalActionKind,
        values: [String: String]
    ) -> ExternalActionKind {
        switch kind {
        case .complete:
            return .openToday
        case .snooze, .delay, .askForSmallerStep:
            return .openToday
        case .openGoal, .openToday, .openCaptureComposer, .openMemoryLens, .unsupported:
            return kind
        }
    }
}

extension ExternalActionCommand {
    var stageActionTaxonomy: StageActionTaxonomy {
        switch kind {
        case .complete, .delay, .snooze, .askForSmallerStep, .unsupported:
            return .productRuntime
        case .openGoal, .openToday, .openCaptureComposer, .openMemoryLens:
            return .shellNavigationOverlay
        }
    }

    var commandKind: AmbitionsCommandKind? {
        switch kind {
        case .complete:
            return .completeAction
        case .delay, .snooze:
            return .delayAction
        case .askForSmallerStep:
            return .splitAction
        case .openGoal, .openToday, .openCaptureComposer, .openMemoryLens:
            return .openDestination
        case .unsupported:
            return nil
        }
    }

    func productRuntimePipelineTrace(
        commandValidation: StageActionPipelineRequirement,
        runtimeMutation: StageActionPipelineRequirement,
        visibleMutation: StageActionPipelineRequirement,
        proofReceipt: StageActionPipelineRequirement,
        accessibility: StageActionPipelineRequirement,
        fallbackUndo: StageActionPipelineRequirement
    ) -> StageActionPipelineTrace {
        StageActionPipelineTrace.productRuntime(
            inventoryID: "external.\(kind.pipelineIDComponent)",
            commandKind: commandKind ?? .completeAction,
            commandValidation: commandValidation,
            runtimeMutation: runtimeMutation,
            visibleMutation: visibleMutation,
            proofReceipt: proofReceipt,
            accessibilityAnnouncement: accessibility,
            fallbackUndo: fallbackUndo,
            scopedFlowIDs: StageActionPipelineInventory.todayStepFlowIDs,
            knownIssueIDs: StageActionPipelineInventory.todayKnownIssueIDs
        )
    }

    func shellPipelineTrace(
        routeState: StageActionPipelineRequirement = .satisfied("External action routed to shell navigation or overlay."),
        fallback: StageActionPipelineRequirement = .satisfied("If the target is absent, the app opens a safe review route.")
    ) -> StageActionPipelineTrace {
        StageActionPipelineTrace.shellNavigationOverlay(
            inventoryID: "external.\(kind.pipelineIDComponent)",
            commandKind: commandKind,
            shellRouteChange: routeState,
            accessibilityAnnouncement: .satisfied("External route preserves an accessible destination label."),
            fallbackUndo: fallback,
            scopedFlowIDs: externalShellScopedFlowIDs,
            knownIssueIDs: externalShellKnownIssueIDs
        )
    }

    private var externalShellScopedFlowIDs: [String] {
        switch kind {
        case .openMemoryLens:
            return StageActionPipelineInventory.shellSearchInspectionFlowIDs
        case .openCaptureComposer:
            return StageActionPipelineInventory.captureSaveFlowIDs
        case .openGoal:
            return ["SCG006-F05", "SCG006-F13"]
        case .openToday:
            return ["SCG006-F07"]
        case .complete, .delay, .snooze, .askForSmallerStep, .unsupported:
            return StageActionPipelineInventory.todayStepFlowIDs
        }
    }

    private var externalShellKnownIssueIDs: [String] {
        switch kind {
        case .openMemoryLens:
            return StageActionPipelineInventory.searchInspectionKnownIssueIDs
        case .openCaptureComposer:
            return StageActionPipelineInventory.captureKnownIssueIDs
        default:
            return StageActionPipelineInventory.todayKnownIssueIDs
        }
    }
}

private extension ExternalActionKind {
    var pipelineIDComponent: String {
        switch self {
        case .complete:
            return "complete"
        case .delay:
            return "delay"
        case .snooze:
            return "snooze"
        case .askForSmallerStep:
            return "ask-for-smaller-step"
        case .openGoal:
            return "open-goal"
        case .openToday:
            return "open-today"
        case .openCaptureComposer:
            return "open-capture-composer"
        case .openMemoryLens:
            return "open-memory-lens"
        case let .unsupported(raw):
            return "unsupported-\(raw)"
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
    let pipelineTrace: StageActionPipelineTrace?

    init(
        outcome: ExternalActionOutcome,
        route: AppExternalRoute? = nil,
        messageTitle: String? = nil,
        pipelineTrace: StageActionPipelineTrace? = nil
    ) {
        self.outcome = outcome
        self.route = route
        self.messageTitle = messageTitle
        self.pipelineTrace = pipelineTrace
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
        let pipelineTrace = result.pipelineTrace ?? fallbackPipelineTrace(for: command, result: result)
        guard let routeRequest = result.routeRequest else {
            return ExternalActionResult(
                outcome: result.outcome,
                messageTitle: result.messageTitle,
                pipelineTrace: pipelineTrace
            )
        }
        return route(
            appRoute(for: routeRequest, source: command.source),
            source: command.source,
            pipelineTrace: pipelineTrace
        )
    }

    private func fallbackPipelineTrace(
        for command: ExternalActionCommand,
        result: RuntimeActionResult
    ) -> StageActionPipelineTrace {
        if result.routeRequest != nil || command.stageActionTaxonomy == .shellNavigationOverlay {
            return command.shellPipelineTrace()
        }

        switch result.outcome {
        case .performed:
            return command.productRuntimePipelineTrace(
                commandValidation: .satisfied("Runtime executor accepted the external action."),
                runtimeMutation: .satisfied("Runtime executor reported performed."),
                visibleMutation: .satisfied("Runtime executor returned a performed result to the app boundary."),
                proofReceipt: .unavailable("Injected runtime executor did not provide typed proof or receipt IDs."),
                accessibility: .satisfied("Runtime result preserves a user-facing message boundary."),
                fallbackUndo: .satisfied("Failure keeps previous state; undo is provided only by scoped mutation handlers.")
            )
        case .missingTarget:
            return command.productRuntimePipelineTrace(
                commandValidation: .blocked("Runtime executor reported a missing target."),
                runtimeMutation: .blocked("No runtime mutation is claimed without the target."),
                visibleMutation: .blocked("No visible product mutation is claimed."),
                proofReceipt: .unavailable("No proof or receipt is created for a blocked action."),
                accessibility: .satisfied("Missing target preserves a safe unavailable state."),
                fallbackUndo: .satisfied("The previous state remains unchanged.")
            )
        case .unsupported, .failed:
            return command.productRuntimePipelineTrace(
                commandValidation: .blocked("Runtime executor rejected the external action."),
                runtimeMutation: .blocked("No runtime mutation is claimed."),
                visibleMutation: .blocked("No visible product mutation is claimed."),
                proofReceipt: .unavailable("No proof or receipt is created for rejected action."),
                accessibility: .satisfied("Rejected action preserves a safe unavailable state."),
                fallbackUndo: .satisfied("The previous state remains unchanged.")
            )
        case .routed:
            return command.shellPipelineTrace()
        }
    }

    private func route(
        _ route: AppExternalRoute,
        source: ExternalActionSource,
        pipelineTrace: StageActionPipelineTrace?
    ) -> ExternalActionResult {
        externalRouter.dispatch(route, source: routeSource(for: source))
        return ExternalActionResult(outcome: .routed, route: route, pipelineTrace: pipelineTrace)
    }

    private func routeSource(for source: ExternalActionSource) -> AppExternalRouteSource {
        switch source {
        case .deepLink:
            return .deepLink
        case .notification:
            return .notificationAction
        case .appIntent:
            return .appIntent
        case .widget, .futureExternalPayload:
            return .widgetAction
        }
    }

    private func appRoute(for request: RuntimeRouteRequest, source: ExternalActionSource) -> AppExternalRoute {
        switch request {
        case .openToday:
            return .openTab(.today)
        case let .openGoalDetail(goalID):
            return .openGoalDetail(goalID: goalID)
        case .openCaptureComposer:
            return .openCaptureComposer
        case .openMemoryLens:
            return .presentOverlay(.memoryLens(entrySource: entrySource(for: source)))
        case let .presentOverlay(overlay):
            return .presentOverlay(overlay)
        }
    }

    private func entrySource(for source: ExternalActionSource) -> ShellCommandEntrySource {
        switch source {
        case .deepLink: .deepLink
        case .notification: .notification
        case .widget: .widget
        case .appIntent: .appIntent
        case .futureExternalPayload: .external
        }
    }
}
