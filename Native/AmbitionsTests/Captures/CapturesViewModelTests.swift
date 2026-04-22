import XCTest
@testable import Ambitions

@MainActor
final class CapturesViewModelTests: XCTestCase {
    func testLoadFetchesCapturesAndActiveGoalOptions() async {
        let captureService = MutableCaptureService(captures: [capture(id: "capture-1", rawText: "First")])
        let goalsService = StaticGoalsService(items: [
            goalItem(id: "goal-active", title: "Active goal", renderState: .active),
            goalItem(id: "goal-on-hold", title: "On hold goal", renderState: .onHold)
        ])
        let viewModel = CapturesViewModel()

        await viewModel.load(captureService: captureService, goalsService: goalsService)

        guard case let .loaded(state) = viewModel.state else {
            return XCTFail("Expected loaded captures state.")
        }
        XCTAssertEqual(state.captures.map(\.id), ["capture-1"])
        XCTAssertEqual(state.activeGoalOptions, [
            CaptureGoalOption(id: "goal-active", title: "Active goal", subtitle: "In motion")
        ])
    }

    func testArchiveAndSaveAsSeedCallServiceAndRefresh() async {
        let captureService = MutableCaptureService(captures: [capture(id: "capture-1", rawText: "First")])
        let goalsService = StaticGoalsService(items: [])
        let viewModel = CapturesViewModel()

        await viewModel.archive(id: "capture-1", captureService: captureService, goalsService: goalsService, now: fixedNow)
        var stored = await captureService.capture(id: "capture-1")
        XCTAssertEqual(stored?.status, .archived)
        XCTAssertEqual(viewModel.actionMessage?.title, "Archived")

        await captureService.setCaptures([capture(id: "capture-2", rawText: "Second")])
        await viewModel.saveAsSeed(id: "capture-2", captureService: captureService, goalsService: goalsService, now: fixedNow)
        stored = await captureService.capture(id: "capture-2")
        XCTAssertEqual(stored?.status, .seed)
        XCTAssertEqual(stored?.triage?.destination, .saveAsSeed)
        XCTAssertEqual(viewModel.actionMessage?.title, "Saved as seed")
    }

    func testAttachReturnsGoalRouteTarget() async {
        let captureService = MutableCaptureService(captures: [capture(id: "capture-attach", rawText: "Attach")])
        let goalsService = StaticGoalsService(items: [goalItem(id: "goal-active", title: "Active goal", renderState: .active)])
        let viewModel = CapturesViewModel()

        let target = await viewModel.attachToGoal(
            captureID: "capture-attach",
            goalID: "goal-active",
            captureService: captureService,
            goalsService: goalsService,
            now: fixedNow
        )

        let stored = await captureService.capture(id: "capture-attach")
        XCTAssertEqual(target?.goalID, "goal-active")
        XCTAssertEqual(stored?.status, .goalBound)
        XCTAssertEqual(stored?.linkedGoalID, "goal-active")
        XCTAssertEqual(viewModel.actionMessage?.title, "Attached to goal")
    }

    func testTurnIntoGoalReturnsCreatedGoalRouteTarget() async {
        let captureService = MutableCaptureService(captures: [capture(id: "capture-goal", rawText: "Turn into goal")])
        let goalsService = StaticGoalsService(items: [])
        let viewModel = CapturesViewModel()

        let target = await viewModel.turnIntoGoal(
            captureID: "capture-goal",
            captureService: captureService,
            goalsService: goalsService,
            now: fixedNow
        )

        let stored = await captureService.capture(id: "capture-goal")
        XCTAssertEqual(target?.goalID, "goal-created-capture-goal")
        XCTAssertEqual(stored?.status, .goalBound)
        XCTAssertEqual(stored?.linkedGoalID, "goal-created-capture-goal")
        XCTAssertEqual(viewModel.actionMessage?.title, "Goal created")
    }

    func testFailuresAreSurfacedWithoutChangingDomainRulesInViewModel() async {
        let captureService = MutableCaptureService(captures: [], shouldThrow: true)
        let goalsService = StaticGoalsService(items: [])
        let viewModel = CapturesViewModel()

        let target = await viewModel.turnIntoGoal(
            captureID: "missing",
            captureService: captureService,
            goalsService: goalsService,
            now: fixedNow
        )

        XCTAssertNil(target)
        XCTAssertEqual(viewModel.actionMessage?.title, "Capture action failed")
        XCTAssertTrue(viewModel.actionMessage?.body.contains("Test capture failure") == true)
    }

    private var fixedNow: Date {
        Date(timeIntervalSince1970: 1_712_692_800)
    }
}

private func capture(id: String, rawText: String, status: CaptureStatus = .actionable) -> Capture {
    Capture(
        id: id,
        createdAt: "2026-04-15T10:00:00Z",
        updatedAt: "2026-04-15T10:00:00Z",
        rawText: rawText,
        sourceType: .todayQuickCapture,
        status: status,
        linkedGoalID: nil
    )
}

private func goalItem(id: String, title: String, renderState: GoalRenderState) -> GoalListItem {
    GoalListItem(
        id: id,
        target: GoalRouteTarget(goalID: id, draftID: nil),
        title: title,
        subtitle: "Goal subtitle",
        mode: .project,
        renderState: renderState,
        progressValue: 0.1,
        progressLabel: "1/3 steps complete",
        statusLabel: renderState.title,
        timingLabel: "Flexible",
        nextStepHint: "Next step",
        modeLabel: GoalMode.project.displayTitle,
        supportLabel: nil,
        relevanceScore: 0.5,
        momentumScore: 0.5,
        urgencyScore: 0.5,
        manualPriorityRank: 1,
        updatedAt: "2026-04-15T10:00:00Z"
    )
}

private actor MutableCaptureService: CaptureServicing {
    private var captures: [String: Capture]
    private let shouldThrow: Bool

    init(captures: [Capture], shouldThrow: Bool = false) {
        self.captures = Dictionary(uniqueKeysWithValues: captures.map { ($0.id, $0) })
        self.shouldThrow = shouldThrow
    }

    func setCaptures(_ captures: [Capture]) {
        self.captures = Dictionary(uniqueKeysWithValues: captures.map { ($0.id, $0) })
    }

    func capture(id: String) -> Capture? {
        captures[id]
    }

    func createCapture(_ request: CreateCaptureRequest, now: Date) async throws -> Capture {
        _ = request
        _ = now
        throw TestCaptureError.failure
    }

    func listCaptures() async throws -> [Capture] {
        captures.values.sorted { $0.updatedAt > $1.updatedAt }
    }

    func updateCaptureState(_ request: CaptureStateUpdateRequest, now: Date) async throws -> Capture? {
        if shouldThrow { throw TestCaptureError.failure }
        guard let existing = captures[request.id] else { return nil }
        let updated = Capture(
            id: existing.id,
            createdAt: existing.createdAt,
            updatedAt: DomainTimestamp.string(from: now),
            rawText: existing.rawText,
            sourceType: existing.sourceType,
            status: request.status,
            linkedGoalID: existing.linkedGoalID,
            triage: request.triage,
            revisitAfter: request.revisitAfter
        )
        captures[request.id] = updated
        return updated
    }

    func attachCaptureToGoal(_ request: AttachCaptureToGoalRequest, now: Date) async throws -> CaptureGoalBinding? {
        guard let updated = try await updateLinkedCapture(id: request.captureID, goalID: request.goalID, now: now) else {
            return nil
        }
        return CaptureGoalBinding(capture: updated, target: GoalRouteTarget(goalID: request.goalID, draftID: nil))
    }

    func turnCaptureIntoGoal(_ request: TurnCaptureIntoGoalRequest, now: Date) async throws -> CaptureGoalBinding? {
        if shouldThrow { throw TestCaptureError.failure }
        let goalID = "goal-created-\(request.captureID)"
        guard let updated = try await updateLinkedCapture(id: request.captureID, goalID: goalID, now: now) else {
            return nil
        }
        return CaptureGoalBinding(capture: updated, target: GoalRouteTarget(goalID: goalID, draftID: "draft-created-\(request.captureID)"))
    }

    func markCaptureProcessed(id: String, now: Date) async throws -> Capture? {
        try await updateCaptureState(CaptureStateUpdateRequest(id: id, status: .goalBound), now: now)
    }

    func markCaptureArchived(id: String, now: Date) async throws -> Capture? {
        try await updateCaptureState(CaptureStateUpdateRequest(id: id, status: .archived), now: now)
    }

    private func updateLinkedCapture(id: String, goalID: String, now: Date) async throws -> Capture? {
        guard let existing = captures[id] else { return nil }
        let updated = Capture(
            id: existing.id,
            createdAt: existing.createdAt,
            updatedAt: DomainTimestamp.string(from: now),
            rawText: existing.rawText,
            sourceType: existing.sourceType,
            status: .goalBound,
            linkedGoalID: goalID,
            triage: existing.triage,
            revisitAfter: existing.revisitAfter
        )
        captures[id] = updated
        return updated
    }
}

private actor StaticGoalsService: GoalsServicing {
    let items: [GoalListItem]

    init(items: [GoalListItem]) {
        self.items = items
    }

    func loadOverview() async throws -> GoalsOverview {
        GoalsOverview(
            hero: GoalsBoardHeroState(
                eyebrow: "Direction Board",
                title: "Goals",
                subtitle: "Test goals",
                dominantTruth: "Test goals",
                pressureSummary: "Test goals",
                contextPills: [],
                attentionPills: []
            ),
            heroPrimaryAction: GoalsBoardPrimaryAction(
                kind: .createGoal,
                title: "Create goal",
                subtitle: "Create goal",
                systemImage: "plus.circle",
                target: nil,
                state: .selected
            ),
            bands: [],
            horizonLadder: GoalsHorizonLadderState(title: "Horizon ladder", subtitle: "Test goals", rungs: []),
            weekPressureSummary: GoalsWeekPressureSummary(
                title: "Calm",
                subtitle: "Calm",
                leadingMetric: "0 active",
                trailingMetric: "0 stretching thin",
                pill: GoalsHeroPillState(title: "Calm", icon: "leaf", state: .success)
            ),
            lowerPriority: GoalsLowerPriorityState(title: "Lower priority", subtitle: "Test goals", disclosureTitle: "Show quieter goals", cards: []),
            items: items,
            isSeeded: false,
            emptyTitle: "No goals",
            emptyMessage: "No goals"
        )
    }

    func loadDetail(target: GoalRouteTarget) async throws -> GoalDetailPresentation {
        _ = target
        fatalError("Not needed for CapturesViewModelTests")
    }

    func createGoal(_ request: CreateGoalRequest, now: Date) async throws -> CreateGoalResponse {
        _ = request
        _ = now
        fatalError("Not needed for CapturesViewModelTests")
    }

    func performAction(_ request: GoalDetailActionRequest, now: Date) async throws -> GoalDetailActionResponse {
        _ = request
        _ = now
        fatalError("Not needed for CapturesViewModelTests")
    }

    func submitClarificationAnswer(_ request: GoalClarificationAnswerRequest, now: Date) async throws -> GoalDetailActionResponse {
        _ = request
        _ = now
        fatalError("Not needed for CapturesViewModelTests")
    }
}

private enum TestCaptureError: LocalizedError {
    case failure

    var errorDescription: String? {
        "Test capture failure"
    }
}
