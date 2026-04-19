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
        XCTAssertTrue(router.dispatchedRoutes.isEmpty)
    }

    func testSnoozeCommandMapsToDelayThroughTodayService() async {
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
        XCTAssertEqual(today.performedActions.map(\.kind), [.delay])
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
            ExternalActionCommand(kind: .openCapturesInbox, source: .futureExternalPayload),
            now: .now
        )

        XCTAssertEqual(router.dispatchedRoutes.map(\.route), [
            .openTab(.today),
            .openGoalDetail(goalID: "goal-123"),
            .openCapturesInbox,
        ])
        XCTAssertEqual(router.dispatchedRoutes.map(\.source), [
            .widgetAction,
            .notificationAction,
            .widgetAction,
        ])
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
        XCTAssertEqual(router.dispatchedRoutes.map(\.route), [.openTab(.today)])
        XCTAssertEqual(router.dispatchedRoutes.map(\.source), [.widgetAction])
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

    func loadTodayExperience(userDisplayName: String, now: Date) async throws -> TodayExperience {
        _ = userDisplayName
        _ = now
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
