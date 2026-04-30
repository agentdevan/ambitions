@testable import Ambitions
import Foundation
import XCTest

final class TodayViewModelTests: XCTestCase {
    func testRepositoryBackedServiceUsesNeutralGreetingForBlankName() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTodayService(repositories: repositories)

        let now = try XCTUnwrap(Calendar.current.date(from: DateComponents(year: 2026, month: 4, day: 15, hour: 13)))
        let experience = try await service.loadTodayExperience(userDisplayName: "   ", now: now)

        XCTAssertEqual(experience.mode, .empty)
        XCTAssertEqual(experience.hero.truth.greeting, "Good afternoon")
    }

    func testRepositoryBackedServiceUsesSharedNextStepSelectorForFocus() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTodayService(repositories: repositories)
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-15T12:00:00Z"))
        let soon = makeGoal(id: "goal-soon", stepID: "step-soon", stepTitle: "Soon shared step", dueAt: "2026-04-16T12:00:00Z")
        let later = makeGoal(id: "goal-later", stepID: "step-later", stepTitle: "Later shared step", dueAt: "2026-05-01T12:00:00Z")
        try await repositories.goals.saveGoals([later, soon])

        let experience = try await service.loadTodayExperience(userDisplayName: "", now: now)
        let expected = PlanningNextStepSelector().bestSelection(goals: [later, soon], now: now)

        XCTAssertEqual(experience.hero.truth.nowTitle, expected?.step.title)
        XCTAssertEqual(experience.support.fixedCommitments.items.first?.id, expected?.step.id)
    }

    func testRepositoryBackedServiceIncludesComputedRitualState() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTodayService(repositories: repositories)
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-21T08:00:00Z"))
        let goal = makeGoal(id: "goal-ritual", stepID: "step-ritual", stepTitle: "Ritual-backed step", dueAt: "2026-04-21T16:00:00Z")
        try await repositories.goals.saveGoals([goal])

        let experience = try await service.loadTodayExperience(userDisplayName: "", now: now)

        XCTAssertEqual(experience.hero.truth.posture, .stable)
        XCTAssertEqual(experience.hero.primaryAction.action.kind, .startFocus)
        XCTAssertEqual(experience.hero.primaryAction.action.target.goalID, "goal-ritual")
        XCTAssertTrue(experience.hero.truth.contextPills.contains(where: { $0.title.contains("1 active goal") }))
        XCTAssertFalse(experience.support.timeAperture.windows.isEmpty)
        XCTAssertNil(experience.support.recoveryBloom)
    }

    func testToday2StableHeroShowsContextLensBestMoveExplanationAndCommands() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTodayService(repositories: repositories)
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-15T12:00:00Z"))
        let goal = makeGoal(
            id: "goal-work",
            stepID: "step-work",
            stepTitle: "Send the client spreadsheet",
            dueAt: "2026-04-15T20:00:00Z",
            domain: .career
        )
        try await repositories.goals.saveGoals([goal])

        let experience = try await service.loadTodayExperience(userDisplayName: "", now: now)

        XCTAssertEqual(experience.execution.hero.kind, .nextAction)
        XCTAssertEqual(experience.execution.activeLens.title, "Work")
        XCTAssertEqual(experience.execution.hero.smallestUsefulNextStep, "Send the client spreadsheet")
        XCTAssertEqual(experience.execution.protectedMustDo.title, "Keep this")
        XCTAssertEqual(experience.execution.bestNextMove.subtitle, "Send the client spreadsheet")
        XCTAssertEqual(experience.execution.bestNextMove.title, "Recommended step")
        XCTAssertEqual(experience.execution.notToday.title, "Not today")
        XCTAssertEqual(experience.execution.recoveryFallback.title, "Fallback")
        XCTAssertEqual(experience.execution.whyThisMatters.title, "Why this matters")
        XCTAssertEqual(experience.execution.actionClosureEntry.value, "Needs a quick check")
        XCTAssertEqual(experience.execution.dayState, .steady)
        XCTAssertEqual(experience.execution.frictionSignal.kind, .friction)
        XCTAssertEqual(experience.execution.supportingPanels.count, 2)
        XCTAssertEqual(experience.execution.todayPlanLayer.title, "Today Plan")
        XCTAssertFalse(experience.execution.todayPlanLayer.items.isEmpty)
        XCTAssertEqual(experience.execution.todayPlanLayer.calendarSourceLabel, "Based on your plan")
        XCTAssertFalse(experience.execution.todayPlanLayer.openWindowLabel.isEmpty)
        XCTAssertNotNil(experience.execution.hero.explanation)
        XCTAssertNotNil(experience.execution.saveTheDayAction)
        XCTAssertTrue(experience.execution.commandMappings.contains { $0.actionKind == .startFocus && $0.commandKind == .startFocus })
        XCTAssertTrue(experience.execution.commandMappings.contains { $0.actionKind == .askWhyThisMatters && $0.commandKind == .askWhy })
    }

    func testTodayD11ScreenContractSnapshotSatisfiesImplementationGate() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTodayService(repositories: repositories)
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-15T12:00:00Z"))
        let goal = makeGoal(
            id: "goal-contract",
            stepID: "step-contract",
            stepTitle: "Protect the launch review",
            dueAt: "2026-04-15T20:00:00Z",
            domain: .career
        )
        try await repositories.goals.saveGoals([goal])

        let experience = try await service.loadTodayExperience(userDisplayName: "", now: now)
        let contract = ScreenContractRegistry.contract(for: .today)
        let issues = ScreenContractValidator.validate(
            snapshot: experience.execution.screenContractSnapshot(),
            against: contract
        )

        XCTAssertTrue(issues.isEmpty, issues.map(\.message).joined(separator: "\n"))
    }

    func testTodayD11OneStepGoalsSurfaceStandaloneCaptureWithoutTasksTab() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTodayService(repositories: repositories)
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-15T12:00:00Z"))
        try await repositories.captures.saveCaptures([
            Capture(
                id: "capture-task",
                createdAt: DomainTimestamp.string(from: now),
                updatedAt: DomainTimestamp.string(from: now),
                rawText: "Book dentist",
                sourceType: .todayQuickCapture,
                status: .actionable,
                linkedGoalID: nil,
                kind: .oneTimeCommitment,
                route: .planSeed,
                triageStatus: .assumedRoute,
                commitmentKind: .oneTime
            )
        ])

        let experience = try await service.loadTodayExperience(userDisplayName: "", now: now)

        XCTAssertEqual(experience.execution.oneStepGoalsPanel.title, "One-Step Goals")
        XCTAssertEqual(experience.execution.oneStepGoalsPanel.value, "1 open")
        XCTAssertEqual(experience.execution.oneStepGoalsPanel.previews.first?.title, "Book dentist")
        XCTAssertEqual(ScreenContractValidator.canonicalTopLevelTabs, ["Today", "Goals", "Capture", "Plan", "You"])
        XCTAssertFalse(ScreenContractValidator.canonicalTopLevelTabs.contains("Tasks"))
    }

    func testToday2RecoveryHeroProtectsHighConsequenceDeadlineAndDefersPassiveWork() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTodayService(repositories: repositories)
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-15T12:00:00Z"))
        let crib = makeGoal(
            id: "goal-crib",
            stepID: "step-crib",
            stepTitle: "Build the baby crib",
            dueAt: "2026-04-15T14:00:00Z",
            domain: .home
        )
        let piano = makeGoal(
            id: "goal-piano",
            stepID: "step-piano",
            stepTitle: "Practice piano",
            dueAt: "2026-06-01T12:00:00Z",
            state: .paused,
            mode: .learning,
            domain: .creativity
        )
        let skipped = EventLedgerEntry(
            id: "ledger-skipped",
            kind: .actionSkipped,
            occurredAt: DomainTimestamp.string(from: now),
            source: .today,
            goalID: crib.id,
            title: "Skipped"
        )
        try await repositories.goals.saveGoals([piano, crib])
        try await repositories.eventLedger.append(skipped)

        let experience = try await service.loadTodayExperience(userDisplayName: "", now: now)

        XCTAssertEqual(experience.execution.hero.kind, .recovery)
        XCTAssertEqual(experience.execution.recoveryFallback.value, "Recovery ready")
        XCTAssertEqual(experience.execution.notToday.value, "Parked")
        XCTAssertEqual(experience.execution.frictionSignal.value, "Needs recovery")
        XCTAssertEqual(experience.execution.saveTheDayAction?.title, "Save the day")
        XCTAssertTrue(experience.execution.deeperSections.flatMap(\.rows).contains { $0.title == "Kept in view" })
        XCTAssertTrue(experience.execution.deeperSections.flatMap(\.rows).contains { $0.title == "Can wait" })
        XCTAssertFalse(experience.execution.supportingPanels.contains { $0.value.localizedCaseInsensitiveContains("piano") })
    }

    func testToday2OutsideLensAndWaitingStaySummarized() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTodayService(repositories: repositories)
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-15T12:00:00Z"))
        let personal = makeGoal(
            id: "goal-personal",
            stepID: "step-personal",
            stepTitle: "Clean personal notes",
            dueAt: "2026-04-30T12:00:00Z",
            domain: .personalGrowth
        )
        let work = makeGoal(
            id: "goal-work",
            stepID: "step-work",
            stepTitle: "Send the client sheet",
            dueAt: "2026-04-15T13:00:00Z",
            domain: .career
        )
        let waiting = Capture(
            id: "capture-waiting",
            createdAt: DomainTimestamp.string(from: now),
            updatedAt: DomainTimestamp.string(from: now),
            rawText: "Waiting on Kaylee",
            sourceType: .todayQuickCapture,
            status: .waiting,
            linkedGoalID: nil,
            kind: .waitingItem,
            route: .waiting,
            triageStatus: .waiting,
            commitmentKind: .waiting,
            contextLensHint: .personal
        )
        try await repositories.goals.saveGoals([personal, work])
        try await repositories.captures.saveCaptures([waiting])

        let experience = try await service.loadTodayExperience(userDisplayName: "", now: now)

        XCTAssertEqual(experience.execution.activeLens.title, "Personal")
        XCTAssertTrue(experience.execution.supportingPanels.contains { $0.kind == .contextLens && $0.value == "1 item" })
        XCTAssertTrue(experience.execution.deeperSections.flatMap(\.rows).contains { $0.kind == .waiting && $0.value.contains("waiting") })
    }

    func testToday2CaptureUrgencyAndPlanGuidanceStayRouteOnly() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTodayService(repositories: repositories)
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-15T12:00:00Z"))
        try await repositories.captures.saveCaptures([
            Capture(id: "capture-1", createdAt: DomainTimestamp.string(from: now), updatedAt: DomainTimestamp.string(from: now), rawText: "Create spreadsheet and send it to Kaylee by EOD Tuesday", sourceType: .todayQuickCapture, status: .actionable, linkedGoalID: nil, kind: .oneTimeCommitment, route: .planSeed, triageStatus: .assumedRoute, commitmentKind: .oneTime, deadlineText: "EOD Tuesday", deadlineKind: .hard, contextLensHint: .work),
            Capture(id: "capture-2", createdAt: DomainTimestamp.string(from: now), updatedAt: DomainTimestamp.string(from: now), rawText: "Book dentist", sourceType: .todayQuickCapture, status: .actionable, linkedGoalID: nil),
        ])

        let experience = try await service.loadTodayExperience(userDisplayName: "", now: now)
        let capturePanel = try XCTUnwrap(experience.execution.supportingPanels.first { $0.kind == .capture })

        XCTAssertNotEqual(capturePanel.value, "No pressure")
        XCTAssertFalse(experience.execution.planRequestsCalendarPermission)
        XCTAssertTrue(experience.execution.commandMappings.contains { $0.actionKind == .openPlan && $0.destination == .plan })
    }

    func testToday2EmptyStateDoesNotBecomeBlankDashboard() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTodayService(repositories: repositories)
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-15T12:00:00Z"))

        let experience = try await service.loadTodayExperience(userDisplayName: "", now: now)

        XCTAssertEqual(experience.mode, .empty)
        XCTAssertEqual(experience.execution.hero.kind, .empty)
        XCTAssertEqual(experience.execution.protectedMustDo.value, "No must-do yet")
        XCTAssertEqual(experience.execution.notToday.value, "Nothing heavy")
        XCTAssertEqual(experience.execution.actionClosureEntry.value, "Needs a quick check")
        XCTAssertNil(experience.execution.saveTheDayAction)
        XCTAssertNotNil(experience.execution.emptyGuidance)
        XCTAssertFalse(experience.execution.supportingPanels.isEmpty)
        XCTAssertFalse(experience.execution.planRequestsCalendarPermission)
    }

    func testRepositoryBackedServiceCanSurfaceSharedResponsibilityRitualThesis() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTodayService(repositories: repositories)
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-20T09:00:00Z"))
        var goal = makeGoal(id: "goal-home", stepID: "step-home", stepTitle: "Home shared step", dueAt: "2026-04-21T16:00:00Z")
        goal = Goal(
            schemaVersion: goal.schemaVersion,
            id: goal.id,
            revision: goal.revision,
            createdAt: goal.createdAt,
            updatedAt: goal.updatedAt,
            state: goal.state,
            title: goal.title,
            summary: goal.summary,
            mode: goal.mode,
            relationshipKind: .support,
            actor: goal.actor,
            parentGoalID: goal.parentGoalID,
            childGoalIDs: goal.childGoalIDs,
            supportGoalIDs: goal.supportGoalIDs,
            tags: goal.tags,
            timing: goal.timing,
            planningStrategy: goal.planningStrategy,
            progressStrategy: goal.progressStrategy,
            plan: goal.plan,
            lifeGraph: LifeGraphContext(
                domains: [LifeDomainAssignment(domain: .home)],
                roles: [LifeRole(kind: .supporting, title: "Partner support")],
                path: nil,
                stages: [],
                prerequisites: [],
                milestones: [],
                sharedLife: SharedLifeContext(
                    participants: [SharedLifeParticipant(id: "partner", displayName: "Alex", relationshipKind: .partner, roleLabel: "Partner")],
                    responsibilities: [SharedResponsibility(id: "groceries", title: "Groceries", kind: .household, participantID: "partner")]
                )
            )
        )
        try await repositories.goals.saveGoals([goal])

        let experience = try await service.loadTodayExperience(userDisplayName: "", now: now)

        XCTAssertTrue(experience.hero.truth.supportingText.localizedCaseInsensitiveContains("shared"))
    }

    func testSharedNextStepSelectorDeprioritizesBlockedDependencyWork() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTodayService(repositories: repositories)
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-15T12:00:00Z"))
        let blocked = makeGoal(
            id: "goal-blocked",
            stepID: "step-blocked",
            stepTitle: "Blocked dependency step",
            dueAt: "2026-04-16T12:00:00Z",
            stepState: .blocked,
            dependencyStepIDs: ["step-prereq"]
        )
        let clean = makeGoal(
            id: "goal-clean",
            stepID: "step-clean",
            stepTitle: "Clean recovery-safe step",
            dueAt: "2026-04-17T12:00:00Z"
        )
        try await repositories.goals.saveGoals([blocked, clean])

        let experience = try await service.loadTodayExperience(userDisplayName: "", now: now)
        let expected = PlanningNextStepSelector().bestSelection(goals: [blocked, clean], now: now)

        XCTAssertEqual(expected?.goal.id, "goal-clean")
        XCTAssertEqual(experience.hero.truth.nowTitle, expected?.step.title)
        XCTAssertEqual(experience.support.fixedCommitments.items.first?.id, expected?.step.id)
        XCTAssertNil(experience.support.recoveryBloom)
        XCTAssertEqual(experience.support.timeAperture.bestUseTitle, "Next 45 minutes")
        XCTAssertFalse(experience.support.timeAperture.windows.isEmpty)
    }

    func testFocusEntryContextSurfacesBoundedFocusScreenlet() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTodayService(repositories: repositories)
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-21T08:00:00Z"))
        let goal = makeGoal(id: "goal-focus", stepID: "step-focus", stepTitle: "Focus-backed step", dueAt: "2026-04-21T16:00:00Z")
        try await repositories.goals.saveGoals([goal])

        let experience = try await service.loadTodayExperience(
            userDisplayName: "",
            now: now,
            entryContext: .focus
        )

        XCTAssertEqual(experience.hero.truth.posture, .stable)
        XCTAssertEqual(experience.hero.primaryAction.action.kind, .complete)
        XCTAssertEqual(experience.support.focusScreenlet?.title, "Focus-backed step")
        XCTAssertEqual(experience.support.focusScreenlet?.primaryAction.kind, .complete)
    }

    @MainActor
    func testHandlePublishesTransientMessageAfterActionResponse() async {
        let expectedMessage = TodayInlineMessage(
            title: "Captured",
            body: "Progress was saved.",
            state: .success
        )
        let viewModel = TodayViewModel(state: .loaded(PreviewTodayScenarios.empty))
        let service = RecordingTodayService(experience: PreviewTodayScenarios.empty, actionResponse: TodayActionResponse(message: expectedMessage))

        await viewModel.handle(
            TodayInlineAction(
                kind: .quickLog,
                title: "Quick log",
                systemImage: "plus.bubble",
                state: .success,
                target: TodayActionTarget(goalID: "goal-1", stepID: "step-1")
            ),
            using: service,
            userDisplayName: ""
        )

        let transientMessage = viewModel.transientMessage
        XCTAssertEqual(transientMessage?.title, expectedMessage.title)
        XCTAssertEqual(transientMessage?.body, expectedMessage.body)
        let actionCount = await service.performedActionCount()
        XCTAssertEqual(actionCount, 1)
    }

    @MainActor
    func testRefreshFailureMovesStateToFailed() async {
        let viewModel = TodayViewModel()
        await viewModel.refresh(using: FailingTodayService(), userDisplayName: "")

        let state = viewModel.state
        guard case let .failed(message) = state else {
            return XCTFail("Expected Today refresh to end in a failed state.")
        }

        XCTAssertTrue(message.contains("Unable to load Today"))
    }
}

private extension TodayViewModelTests {
    func makeRepositories() async throws -> AppRepositories {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        return AppRepositories(
            goals: SwiftDataGoalRepository(store: store),
            drafts: SwiftDataGoalDraftRepository(store: store),
            evidence: SwiftDataProgressEvidenceRepository(store: store),
            feedback: SwiftDataFeedbackEventRepository(store: store),
            captures: SwiftDataCaptureRepository(store: store),
            appState: SwiftDataAppStateRepository(store: store)
        )
    }

    func makeGoal(
        id: String,
        stepID: String,
        stepTitle: String,
        dueAt: String,
        state: GoalLifecycleState = .active,
        mode: GoalMode = .project,
        domain: LifeDomainKey? = nil,
        stepState: StepLifecycleState = .planned,
        dependencyStepIDs: [String] = []
    ) -> Goal {
        let actor = GoalActor(actorID: "self", displayName: "You", ownership: .self, roleLabel: "Primary owner", isPrimary: true)
        let timing = GoalTiming(tempo: .deadlineBased, timingType: .dueAt, startsOn: nil, dueAt: dueAt, targetBy: nil, windowStart: nil, windowEnd: nil, suggestedNextAt: nil, repeatEveryDays: nil, progressReviewCadenceDays: 7)
        let strategy = PlanningStrategy(strategyKind: .sequential, allowParallelSteps: false, maxActiveSteps: 3, preferredSectionOrder: [.activeSteps], defaultStepType: .actionUnit, autoGenerateReviewSection: false, preferShortSteps: true, revisitCadenceDays: 7)
        let progress = ProgressStrategy(metricKind: .stepCompletion, rollupMethod: .ratio, targetStepCount: nil, targetEvidenceCount: nil, targetMinutes: nil, supportsUntimedProgress: true, countsChildGoals: false, countsSupportGoals: false)
        let step = Step(id: stepID, sectionID: "section-\(id)", title: stepTitle, summary: nil, type: .actionUnit, state: stepState, owner: actor, timing: timing, dependencyStepIDs: dependencyStepIDs, isOptional: false, isRepeatable: false, evidenceRequired: true, successSignals: ["Done"], actionability: StepActionability(action: "Do it", completionDefinition: "Done", evidenceOfCompletion: ["Done"], fallbackMicroStep: "Start", contextRequirements: []))
        let plan = GoalPlan(id: "plan-\(id)", goalID: id, version: goalEnginePlanVersion, generatedAt: "2026-04-15T12:00:00Z", summary: nil, strategy: strategy, sections: [PlanSection(id: "section-\(id)", goalID: id, title: "Active", summary: nil, kind: .activeSteps, orderIndex: 0, steps: [step])], assumptions: [], lint: PlanLintResult(goalID: id, planVersion: goalEnginePlanVersion, isValid: true, issueCount: 0, issues: []))
        return Goal(
            schemaVersion: goalEngineSchemaVersion,
            id: id,
            revision: 1,
            createdAt: "2026-04-15T12:00:00Z",
            updatedAt: "2026-04-15T12:00:00Z",
            state: state,
            title: id,
            summary: nil,
            mode: mode,
            relationshipKind: .independent,
            actor: actor,
            parentGoalID: nil,
            childGoalIDs: [],
            supportGoalIDs: [],
            tags: [],
            timing: timing,
            planningStrategy: strategy,
            progressStrategy: progress,
            plan: plan,
            lifeGraph: domain.map { LifeGraphContext(domains: [LifeDomainAssignment(domain: $0)]) }
        )
    }
}

private actor RecordingTodayService: TodayServicing {
    let experience: TodayExperience
    let actionResponse: TodayActionResponse
    private(set) var performedActions: [TodayInlineAction] = []

    init(experience: TodayExperience, actionResponse: TodayActionResponse) {
        self.experience = experience
        self.actionResponse = actionResponse
    }

    func loadTodayExperience(userDisplayName: String, now: Date, entryContext: TodayEntryContext) async throws -> TodayExperience {
        _ = userDisplayName
        _ = now
        _ = entryContext
        return experience
    }

    func performAction(_ action: TodayInlineAction, now: Date) async throws -> TodayActionResponse {
        _ = now
        performedActions.append(action)
        return actionResponse
    }

    func performedActionCount() -> Int {
        performedActions.count
    }
}

private struct FailingTodayService: TodayServicing {
    struct Failure: LocalizedError {
        var errorDescription: String? {
            "Today failed on purpose."
        }
    }

    func loadTodayExperience(userDisplayName: String, now: Date, entryContext: TodayEntryContext) async throws -> TodayExperience {
        _ = userDisplayName
        _ = now
        _ = entryContext
        throw Failure()
    }

    func performAction(_ action: TodayInlineAction, now: Date) async throws -> TodayActionResponse {
        _ = action
        _ = now
        throw Failure()
    }
}
