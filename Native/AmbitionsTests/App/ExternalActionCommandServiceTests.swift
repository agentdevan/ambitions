import XCTest
@testable import Ambitions

@MainActor
final class ExternalActionCommandServiceTests: XCTestCase {
    func testCompleteCommandExecutesThroughTodayService() async throws {
        let today = RecordingExternalActionTodayService()
        let router = RecordingExternalActionRouter()
        let service = makeService(todayService: today, router: router)

        let result = await service.execute(
            ExternalActionCommand(
                kind: .complete,
                target: ExternalActionTarget(goalID: "goal-1", stepID: "step-1"),
                source: .notification
            ),
            now: Date(timeIntervalSince1970: 1_712_779_200)
        )

        XCTAssertEqual(result.outcome, .performed)
        XCTAssertEqual(today.performedActions.map(\.kind), [.complete])
        XCTAssertEqual(today.performedActions.first?.target.goalID, "goal-1")
        XCTAssertEqual(today.performedActions.first?.target.stepID, "step-1")
        XCTAssertEqual(result.pipelineTrace?.taxonomy, .productRuntime)
        XCTAssertEqual(result.pipelineTrace?.commandKind, .completeAction)
        XCTAssertEqual(result.pipelineTrace?.commandValidation.state, .satisfied)
        XCTAssertEqual(result.pipelineTrace?.runtimeMutation.state, .satisfied)
        XCTAssertEqual(result.pipelineTrace?.visibleMutation.state, .satisfied)
        XCTAssertEqual(result.pipelineTrace?.proofReceipt.state, .unavailable)
        XCTAssertEqual(result.pipelineTrace?.shellRouteChange.state, .notApplicable)
        XCTAssertTrue(router.dispatchedRoutes.isEmpty)
    }

    func testSnoozeCommandMapsToDeferThroughTodayService() async {
        let today = RecordingExternalActionTodayService()
        let service = makeService(todayService: today)

        let result = await service.execute(
            ExternalActionCommand(
                kind: .snooze,
                target: ExternalActionTarget(goalID: "goal-1", stepID: "step-1"),
                source: .notification
            ),
            now: .now
        )

        XCTAssertEqual(result.outcome, .performed)
        XCTAssertEqual(today.performedActions.map(\.kind), [.defer])
    }

    func testMissingStepTargetFailsSafelyWithoutMutation() async {
        let today = RecordingExternalActionTodayService()
        let router = RecordingExternalActionRouter()
        let service = makeService(todayService: today, router: router)

        let result = await service.execute(
            ExternalActionCommand(
                kind: .complete,
                target: ExternalActionTarget(goalID: "goal-1"),
                source: .notification
            ),
            now: .now
        )

        XCTAssertEqual(result.outcome, .missingTarget)
        XCTAssertEqual(result.pipelineTrace?.taxonomy, .productRuntime)
        XCTAssertEqual(result.pipelineTrace?.commandValidation.state, .blocked)
        XCTAssertEqual(result.pipelineTrace?.runtimeMutation.state, .blocked)
        XCTAssertEqual(result.pipelineTrace?.visibleMutation.state, .blocked)
        XCTAssertEqual(result.pipelineTrace?.proofReceipt.state, .unavailable)
        XCTAssertEqual(result.pipelineTrace?.fallbackUndo.state, .satisfied)
        XCTAssertTrue(today.performedActions.isEmpty)
        XCTAssertTrue(router.dispatchedRoutes.isEmpty)
    }

    func testOpenCommandsRouteThroughExternalRouter() async {
        let router = RecordingExternalActionRouter()
        let service = makeService(router: router)

        _ = await service.execute(
            ExternalActionCommand(kind: .openToday, source: .widget),
            now: .now
        )
        _ = await service.execute(
            ExternalActionCommand(
                kind: .openGoal,
                target: ExternalActionTarget(goalID: "goal-123"),
                source: .notification
            ),
            now: .now
        )
        _ = await service.execute(
            ExternalActionCommand(kind: .openCaptureComposer, source: .futureExternalPayload),
            now: .now
        )
        _ = await service.execute(
            ExternalActionCommand(kind: .openMemoryLens, source: .widget),
            now: .now
        )

        XCTAssertEqual(router.dispatchedRoutes.map(\.route), [
            .openTab(.today),
            .openGoalDetail(goalID: "goal-123"),
            .openCaptureComposer,
            .presentOverlay(.memoryLens(entrySource: .widget)),
        ])
        XCTAssertEqual(router.dispatchedRoutes.map(\.source), [
            .widgetAction,
            .notificationAction,
            .widgetAction,
            .widgetAction,
        ])
        XCTAssertEqual(router.dispatchedRoutes.count, 4)

        let openToday = await service.execute(
            ExternalActionCommand(kind: .openToday, source: .widget),
            now: .now
        )
        XCTAssertEqual(openToday.pipelineTrace?.taxonomy, .shellNavigationOverlay)
        XCTAssertTrue(openToday.pipelineTrace?.isHonestShellNonRuntime == true)
        XCTAssertEqual(openToday.pipelineTrace?.runtimeMutation.state, .notApplicable)
        XCTAssertEqual(openToday.pipelineTrace?.proofReceipt.state, .notApplicable)
    }

    func testAppAdapterDispatchesRuntimeRouteRequestsThroughExternalRouter() async {
        let runtimeExecutor = StaticRuntimeActionExecutor(
            result: RuntimeActionResult(outcome: .routed, routeRequest: .openToday)
        )
        let router = RecordingExternalActionRouter()
        let service = DefaultExternalActionCommandService(
            runtimeExecutor: runtimeExecutor,
            externalRouter: router
        )

        let result = await service.execute(
            ExternalActionCommand(kind: .openToday, source: .futureExternalPayload),
            now: .now
        )

        XCTAssertEqual(result.outcome, .routed)
        XCTAssertEqual(result.route, .openTab(.today))
        XCTAssertEqual(result.pipelineTrace?.taxonomy, .shellNavigationOverlay)
        XCTAssertTrue(result.pipelineTrace?.isHonestShellNonRuntime == true)
        XCTAssertEqual(router.dispatchedRoutes.map(\.route), [.openTab(.today)])
        XCTAssertEqual(router.dispatchedRoutes.map(\.source), [.widgetAction])
    }

    func testD25AppIntentSourceRoutesAsAppIntentInsteadOfWidgetFallback() async {
        let runtimeExecutor = StaticRuntimeActionExecutor(
            result: RuntimeActionResult(outcome: .routed, routeRequest: .openMemoryLens)
        )
        let router = RecordingExternalActionRouter()
        let service = DefaultExternalActionCommandService(
            runtimeExecutor: runtimeExecutor,
            externalRouter: router
        )

        let result = await service.execute(
            ExternalActionCommand(kind: .openMemoryLens, source: .appIntent),
            now: .now
        )

        XCTAssertEqual(result.outcome, .routed)
        XCTAssertEqual(result.route, .presentOverlay(.memoryLens(entrySource: .appIntent)))
        XCTAssertEqual(router.dispatchedRoutes.map(\.source), [.appIntent])
    }

    func testAppAdapterDoesNotDispatchWhenRuntimePerformsMutation() async {
        let runtimeExecutor = StaticRuntimeActionExecutor(
            result: RuntimeActionResult(outcome: .performed, messageTitle: "Recorded")
        )
        let router = RecordingExternalActionRouter()
        let service = DefaultExternalActionCommandService(
            runtimeExecutor: runtimeExecutor,
            externalRouter: router
        )

        let result = await service.execute(
            ExternalActionCommand(
                kind: .complete,
                target: ExternalActionTarget(goalID: "goal-1", stepID: "step-1"),
                source: .notification
            ),
            now: .now
        )

        XCTAssertEqual(result.outcome, .performed)
        XCTAssertEqual(result.messageTitle, "Recorded")
        XCTAssertNil(result.route)
        XCTAssertEqual(result.pipelineTrace?.taxonomy, .productRuntime)
        XCTAssertEqual(result.pipelineTrace?.runtimeMutation.state, .satisfied)
        XCTAssertEqual(result.pipelineTrace?.proofReceipt.state, .unavailable)
        XCTAssertTrue(router.dispatchedRoutes.isEmpty)
    }

    func testCS06RuntimeFailedOutcomeStaysTechnicalAndDoesNotDispatchRoute() async {
        let runtimeExecutor = StaticRuntimeActionExecutor(
            result: RuntimeActionResult(outcome: .failed, messageTitle: "Action could not complete")
        )
        let router = RecordingExternalActionRouter()
        let service = DefaultExternalActionCommandService(
            runtimeExecutor: runtimeExecutor,
            externalRouter: router
        )

        let result = await service.execute(
            ExternalActionCommand(
                kind: .complete,
                target: ExternalActionTarget(goalID: "goal-1", stepID: "step-1"),
                source: .notification
            ),
            now: .now
        )

        XCTAssertEqual(result.outcome, .failed)
        XCTAssertEqual(result.messageTitle, "Action could not complete")
        XCTAssertNil(result.route)
        XCTAssertEqual(result.pipelineTrace?.taxonomy, .productRuntime)
        XCTAssertEqual(result.pipelineTrace?.runtimeMutation.state, .blocked)
        XCTAssertTrue(router.dispatchedRoutes.isEmpty)
    }

    func testUnsupportedCommandFailsSafelyWithoutMutation() async {
        let today = RecordingExternalActionTodayService()
        let router = RecordingExternalActionRouter()
        let service = makeService(todayService: today, router: router)

        let result = await service.execute(
            ExternalActionCommand(
                kind: .unsupported("future-command"),
                target: ExternalActionTarget(goalID: "goal-1", stepID: "step-1"),
                source: .futureExternalPayload
            ),
            now: .now
        )

        XCTAssertEqual(result.outcome, .unsupported)
        XCTAssertEqual(result.pipelineTrace?.taxonomy, .productRuntime)
        XCTAssertEqual(result.pipelineTrace?.commandValidation.state, .blocked)
        XCTAssertEqual(result.pipelineTrace?.runtimeMutation.state, .blocked)
        XCTAssertTrue(today.performedActions.isEmpty)
        XCTAssertTrue(router.dispatchedRoutes.isEmpty)
    }

    func testWidgetPayloadFallsBackToCanonicalActionValueWhenActionIdentifierIsGeneric() async {
        let today = RecordingExternalActionTodayService()
        let service = makeService(todayService: today)
        let payload = AppWidgetRoutingPayload(
            action: "noop",
            values: ExternalSurfaceActionPayload.commandPayload(
                action: .complete,
                surface: .goalDetail,
                goalID: "goal-1",
                stepID: "step-1",
                tab: "goals"
            )
        )

        let result = await service.execute(
            ExternalActionCommand(widgetPayload: payload),
            now: .now
        )

        XCTAssertEqual(result.outcome, .performed)
        XCTAssertEqual(today.performedActions.map(\.kind), [.complete])
        XCTAssertEqual(today.performedActions.first?.target.goalID, "goal-1")
        XCTAssertEqual(today.performedActions.first?.target.stepID, "step-1")
    }

    func testPFC20NotificationMutationPayloadRoutesInsteadOfMutating() async {
        let today = RecordingExternalActionTodayService()
        let router = RecordingExternalActionRouter()
        let service = makeService(todayService: today, router: router)
        let completePayload = AppNotificationRoutingPayload(
            action: "complete",
            values: [
                "goalID": "goal-1",
                "stepID": "step-1",
                "origin": "notification"
            ]
        )
        let snoozePayload = AppNotificationRoutingPayload(
            action: "snooze",
            values: [
                "goalID": "goal-1",
                "stepID": "step-1",
                "origin": "notification"
            ]
        )

        let completeResult = await service.execute(
            ExternalActionCommand(notificationPayload: completePayload),
            now: .now
        )
        let snoozeResult = await service.execute(
            ExternalActionCommand(notificationPayload: snoozePayload),
            now: .now
        )

        XCTAssertEqual(completeResult.outcome, .routed)
        XCTAssertEqual(snoozeResult.outcome, .routed)
        XCTAssertTrue(today.performedActions.isEmpty)
        XCTAssertEqual(router.dispatchedRoutes.map(\.route), [
            .openTab(.today),
            .openTab(.today),
        ])
        XCTAssertEqual(router.dispatchedRoutes.map(\.source), [
            .notificationAction,
            .notificationAction,
        ])
    }
}

@MainActor
private extension ExternalActionCommandServiceTests {
    func makeService(
        todayService: RecordingExternalActionTodayService? = nil,
        goalsService: RecordingExternalActionGoalsService = RecordingExternalActionGoalsService(),
        captureService: RecordingExternalActionCaptureService = RecordingExternalActionCaptureService(),
        router: RecordingExternalActionRouter? = nil
    ) -> DefaultExternalActionCommandService {
        let todayService = todayService ?? RecordingExternalActionTodayService()
        let router = router ?? RecordingExternalActionRouter()
        return DefaultExternalActionCommandService(
            todayService: todayService,
            goalsService: goalsService,
            captureService: captureService,
            externalRouter: router
        )
    }
}

@MainActor
private final class RecordingExternalActionTodayService: TodayServicing {
    private(set) var performedActions: [TodayInlineAction] = []

    func loadTodayExperience(userDisplayName: String, now: Date, entryContext: TodayEntryContext) async throws -> TodayExperience {
        _ = userDisplayName
        _ = now
        _ = entryContext
        return PreviewTodayScenarios.empty
    }

    func performAction(_ action: TodayInlineAction, now: Date) async throws -> TodayActionResponse {
        _ = now
        performedActions.append(action)
        return TodayActionResponse(message: nil)
    }
}

private struct RecordingExternalActionGoalsService: GoalsServicing {
    func loadOverview() async throws -> GoalsOverview { PreviewGoalsScenarios.overview }

    func loadDetail(target: GoalRouteTarget) async throws -> GoalDetailPresentation {
        _ = target
        return PreviewGoalsScenarios.detailScenarios.values.first!
    }

    func createGoal(_ request: CreateGoalRequest, now: Date) async throws -> CreateGoalResponse {
        _ = request
        _ = now
        return CreateGoalResponse(
            target: GoalRouteTarget(goalID: "goal-created"),
            blueprint: GoalBlueprint(title: request.title, mode: request.mode ?? .project)
        )
    }

    func performAction(_ request: GoalDetailActionRequest, now: Date) async throws -> GoalDetailActionResponse {
        _ = request
        _ = now
        return GoalDetailActionResponse(message: nil)
    }

    func submitClarificationAnswer(_ request: GoalClarificationAnswerRequest, now: Date) async throws -> GoalDetailActionResponse {
        _ = request
        _ = now
        return GoalDetailActionResponse(message: nil)
    }
}

private struct RecordingExternalActionCaptureService: CaptureServicing {
    func createCapture(_ request: CreateCaptureRequest, now: Date) async throws -> Capture {
        Capture(
            id: "capture-created",
            createdAt: DomainTimestamp.string(from: now),
            updatedAt: DomainTimestamp.string(from: now),
            rawText: request.rawText,
            sourceType: request.sourceType,
            status: .actionable,
            linkedGoalID: request.linkedGoalID
        )
    }

    func listCaptures() async throws -> [Capture] { [] }
    func updateCaptureState(_ request: CaptureStateUpdateRequest, now: Date) async throws -> Capture? {
        _ = request
        _ = now
        return nil
    }
    func updateCaptureRoute(_ request: CaptureRouteUpdateRequest, now: Date) async throws -> Capture? {
        _ = request
        _ = now
        return nil
    }
    func markAsOneTimeCommitment(id: String, deadlineText: String?, contextLensHint: NowContextLens?, now: Date) async throws -> Capture? {
        _ = id
        _ = deadlineText
        _ = contextLensHint
        _ = now
        return nil
    }
    func markAsDeadlineTask(id: String, deadlineText: String, contextLensHint: NowContextLens?, now: Date) async throws -> Capture? {
        _ = id
        _ = deadlineText
        _ = contextLensHint
        _ = now
        return nil
    }
    func markAsGoalSeed(id: String, now: Date) async throws -> Capture? {
        _ = id
        _ = now
        return nil
    }
    func markAsGoalSupportingTask(id: String, goalID: String?, now: Date) async throws -> Capture? {
        _ = id
        _ = goalID
        _ = now
        return nil
    }
    func markAsDeliverableSeed(id: String, deliverableHint: String?, now: Date) async throws -> Capture? {
        _ = id
        _ = deliverableHint
        _ = now
        return nil
    }
    func markAsWaiting(id: String, waitingMetadata: CaptureWaitingMetadata?, now: Date) async throws -> Capture? {
        _ = id
        _ = waitingMetadata
        _ = now
        return nil
    }
    func markAsOptionalSomeday(id: String, now: Date) async throws -> Capture? {
        _ = id
        _ = now
        return nil
    }
    func routeToTimeSeed(id: String, now: Date) async throws -> Capture? {
        _ = id
        _ = now
        return nil
    }
    func attachCaptureToGoal(_ request: AttachCaptureToGoalRequest, now: Date) async throws -> CaptureGoalBinding? {
        _ = request
        _ = now
        return nil
    }
    func turnCaptureIntoGoal(_ request: TurnCaptureIntoGoalRequest, now: Date) async throws -> CaptureGoalBinding? {
        _ = request
        _ = now
        return nil
    }
    func markCaptureProcessed(id: String, now: Date) async throws -> Capture? {
        _ = id
        _ = now
        return nil
    }
    func markCaptureArchived(id: String, now: Date) async throws -> Capture? {
        _ = id
        _ = now
        return nil
    }
}

@MainActor
private final class StaticRuntimeActionExecutor: RuntimeActionCommandExecuting {
    let result: RuntimeActionResult

    init(result: RuntimeActionResult) {
        self.result = result
    }

    func execute(_ command: ExternalActionCommand, now: Date) async -> RuntimeActionResult {
        _ = command
        _ = now
        return result
    }
}

@MainActor
private final class RecordingExternalActionRouter: AppExternalRouting {
    private(set) var dispatchedRoutes: [(route: AppExternalRoute, source: AppExternalRouteSource)] = []

    func handleDeepLink(_ url: URL) {
        _ = url
    }

    func handleNotificationPayload(_ payload: AppNotificationRoutingPayload) {
        _ = payload
    }

    func handleWidgetPayload(_ payload: AppWidgetRoutingPayload) {
        _ = payload
    }

    func dispatch(_ route: AppExternalRoute, source: AppExternalRouteSource) {
        dispatchedRoutes.append((route, source))
    }
}
