import XCTest
@testable import Ambitions

final class PlanFeatureServiceTests: XCTestCase {
    func testEmptyRepositoriesReturnOpenRealityModelWeek() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedPlanService(repositories: repositories)

        let dashboard = try await service.loadPlanDashboard(now: fixedDate)

        XCTAssertEqual(dashboard.mode, .empty)
        XCTAssertEqual(dashboard.emptyTitle, "No weekly pressure yet")
        XCTAssertEqual(dashboard.believability.label, "Open")
        XCTAssertEqual(dashboard.primaryAction.kind, .useRoom)
        XCTAssertEqual(dashboard.weekDays.count, 7)
        XCTAssertEqual(dashboard.pressureScrubber.points.count, 7)
        XCTAssertEqual(dashboard.secondaryDestinations.map(\.id), ["plan-habits", "plan-captures", "plan-weekly-review"])
        XCTAssertTrue(dashboard.goalShapingItems.isEmpty)
    }

    func testActiveGoalsProduceElasticWeekAndGoalRelationshipSignals() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals([makeWeekVisibleGoal()])
        let service = RepositoryBackedPlanService(repositories: repositories)

        let dashboard = try await service.loadPlanDashboard(now: fixedDate)

        XCTAssertEqual(dashboard.mode, .active)
        XCTAssertEqual(dashboard.weekDays.count, 7)
        XCTAssertEqual(dashboard.pressureScrubber.points.count, 7)
        XCTAssertFalse(dashboard.goalShapingItems.isEmpty)
        XCTAssertEqual(dashboard.shapingActions.map(\.kind), [.edit, .patch, .protect, .lighten])
        XCTAssertTrue(dashboard.hero.contextPills.contains(where: { $0.title.contains("goals visible") }))
        XCTAssertFalse(dashboard.resilience.lanes.isEmpty)
        XCTAssertNotNil(dashboard.primaryAction.goalTarget)
    }

    func testBlockedDraftsAndOpenCapturesSurfaceRealityPressureTruthfully() async throws {
        let repositories = try await makeRepositories()
        let intake = GoalEngineIntakeService()
        let draftBuild = intake.buildGoalDraft(from: "I want to do something", referenceNow: GoalEngineFixtures.fixedNow)
        let persistedDraft = PersistedGoalDraft(
            id: "draft-plan-pressure",
            createdAt: GoalEngineFixtures.fixedNow,
            updatedAt: GoalEngineFixtures.fixedNow,
            draft: draftBuild.draft,
            classification: nil,
            clarification: nil,
            stagedPlan: nil,
            assumptions: [],
            blockers: [],
            metadata: nil,
            plannedGoalID: nil,
            latestResultKind: .clarificationRequired
        )
        try await repositories.drafts.saveDrafts([persistedDraft])
        try await DefaultCaptureService(repository: repositories.captures).createCapture(
            CreateCaptureRequest(rawText: "Clarify the weekly commitment", sourceType: .todayQuickCapture),
            now: fixedDate
        )
        let service = RepositoryBackedPlanService(repositories: repositories)

        let dashboard = try await service.loadPlanDashboard(now: fixedDate)

        XCTAssertEqual(dashboard.believability.label, "Needs clarity")
        XCTAssertEqual(dashboard.believability.visualState, .warning)
        XCTAssertTrue(dashboard.hero.pressureSummary.contains("captures"))
        XCTAssertTrue(dashboard.hero.trustWhisper.contains("Clarify"))
        XCTAssertEqual(dashboard.primaryAction.kind, .shapeWeek)
    }

    func testHabitLikeGoalsRemainRepresentedUnderPlanSupportLoops() async throws {
        #if DEBUG
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = try await AppContainerFactory.prepareRepositories(for: .demo, store: store)
        let service = RepositoryBackedPlanService(repositories: repositories)

        let dashboard = try await service.loadPlanDashboard(now: fixedDate)

        XCTAssertEqual(dashboard.secondaryDestinations.map(\.id), ["plan-habits", "plan-captures", "plan-weekly-review"])
        XCTAssertTrue(dashboard.secondaryDestinations.contains(where: { $0.id == "plan-habits" && $0.valueLabel != "0" }))
        #else
        throw XCTSkip("Demo bootstrap fixtures are only available in DEBUG builds.")
        #endif
    }

    func testWeeklyReviewDashboardBridgesCarryForwardAndSupportRoutes() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals([makeWeekVisibleGoal()])
        try await DefaultCaptureService(repository: repositories.captures).createCapture(
            CreateCaptureRequest(rawText: "Review the carry-forward tradeoff", sourceType: .todayQuickCapture),
            now: fixedDate
        )
        let service = RepositoryBackedPlanService(repositories: repositories)

        let dashboard = try await service.loadWeeklyReviewDashboard(now: fixedDate)

        XCTAssertEqual(dashboard.hero.eyebrow, "Weekly Review")
        XCTAssertFalse(dashboard.carryForwardItems.isEmpty)
        XCTAssertTrue(dashboard.captureSummary.contains("capture"))
        XCTAssertEqual(dashboard.returnActionTitle, "Return to Plan")
    }

    func testDemoPlanProtectActionRemainsActionable() async throws {
        #if DEBUG
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = try await AppContainerFactory.prepareRepositories(for: .demo, store: store)
        let service = RepositoryBackedPlanService(repositories: repositories)

        let dashboard = try await service.loadPlanDashboard(now: fixedDate)
        let protectAction = try XCTUnwrap(dashboard.shapingActions.first(where: { $0.kind == .protect }))

        XCTAssertTrue(protectAction.goalTarget != nil || protectAction.planRoute != nil)
        #else
        throw XCTSkip("Demo bootstrap fixtures are only available in DEBUG builds.")
        #endif
    }

    func testPlanCalendarAwareActionIsPlanOwnedAndWritesPrivacyLedger() async throws {
        let ledger = InMemoryEventLedgerRepository()
        let repositories = try await makeRepositories(eventLedger: ledger)
        let calendar = RecordingPlanCalendarRealityService()
        let service = RepositoryBackedPlanService(
            repositories: repositories,
            calendarRealityService: calendar
        )

        let dashboard = try await service.makePlanCalendarAware(now: fixedDate)
        let events = try await ledger.fetchRecent(limit: 5)

        let requestedActionNames = await calendar.currentRequestedActionNames()
        XCTAssertEqual(requestedActionNames, ["Make Plan calendar-aware"])
        XCTAssertEqual(dashboard.calendarAwareness.status, .calendarAware)
        XCTAssertTrue(dashboard.calendarAwareness.detail.contains("open window"))
        XCTAssertEqual(events.first?.kind, .calendarContextObserved)
        XCTAssertEqual(events.first?.privacy, .calendarDerived)
        XCTAssertEqual(events.first?.source, .plan)
    }
}

private extension PlanFeatureServiceTests {
    var fixedDate: Date {
        ISO8601DateFormatter().date(from: GoalEngineFixtures.fixedNow) ?? Date(timeIntervalSince1970: 1_712_692_800)
    }

    func makeRepositories(eventLedger: (any EventLedgerRepository)? = nil) async throws -> AppRepositories {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        return AppRepositories(
            goals: SwiftDataGoalRepository(store: store),
            drafts: SwiftDataGoalDraftRepository(store: store),
            evidence: SwiftDataProgressEvidenceRepository(store: store),
            feedback: SwiftDataFeedbackEventRepository(store: store),
            captures: SwiftDataCaptureRepository(store: store),
            eventLedger: eventLedger ?? InMemoryEventLedgerRepository(),
            appState: SwiftDataAppStateRepository(store: store)
        )
    }

    func makeWeekVisibleGoal() -> Goal {
        let actor = GoalActor(
            actorID: "self",
            displayName: "You",
            ownership: .self,
            roleLabel: "Primary owner",
            isPrimary: true
        )
        let timing = GoalTiming(
            tempo: .deadlineBased,
            timingType: .dueAt,
            startsOn: nil,
            dueAt: "2026-04-17T12:00:00Z",
            targetBy: nil,
            windowStart: nil,
            windowEnd: nil,
            suggestedNextAt: nil,
            repeatEveryDays: nil,
            progressReviewCadenceDays: 7
        )
        let strategy = PlanningStrategy(
            strategyKind: .adaptive,
            allowParallelSteps: true,
            maxActiveSteps: 3,
            preferredSectionOrder: [.activeSteps],
            defaultStepType: .actionUnit,
            autoGenerateReviewSection: true,
            preferShortSteps: true,
            revisitCadenceDays: 7
        )
        let progress = ProgressStrategy(
            metricKind: .stepCompletion,
            rollupMethod: .ratio,
            targetStepCount: nil,
            targetEvidenceCount: nil,
            targetMinutes: nil,
            supportsUntimedProgress: true,
            countsChildGoals: false,
            countsSupportGoals: false
        )
        let step = Step(
            id: "step-plan-visible",
            sectionID: "section-plan-visible",
            title: "Draft and submit the proposal",
            summary: "Finish the visible draft and send it before the deadline.",
            type: .actionUnit,
            state: .planned,
            owner: actor,
            timing: timing,
            dependencyStepIDs: [],
            isOptional: false,
            isRepeatable: false,
            evidenceRequired: true,
            successSignals: ["Proposal submitted"],
            actionability: StepActionability(
                action: "Draft and submit the proposal",
                completionDefinition: "The proposal is submitted.",
                evidenceOfCompletion: ["Submission confirmation"],
                fallbackMicroStep: "Open the draft and write the next paragraph.",
                contextRequirements: []
            )
        )
        let plan = GoalPlan(
            id: "plan-visible",
            goalID: "goal-plan-visible",
            version: goalEnginePlanVersion,
            generatedAt: GoalEngineFixtures.fixedNow,
            summary: "Conference proposal work is explicitly carried by this week.",
            strategy: strategy,
            sections: [
                PlanSection(
                    id: "section-plan-visible",
                    goalID: "goal-plan-visible",
                    title: "Active",
                    summary: nil,
                    kind: .activeSteps,
                    orderIndex: 0,
                    steps: [step]
                )
            ],
            assumptions: [],
            lint: PlanLintResult(
                goalID: "goal-plan-visible",
                planVersion: goalEnginePlanVersion,
                isValid: true,
                issueCount: 0,
                issues: []
            ),
            evaluation: PlanningEvaluation(
                feasibilityScore: 0.84,
                feasibilityLevel: .comfortable,
                recommendationConfidence: .high,
                pressureLevel: .low,
                fragilityLevel: .low,
                effortPosture: .steady,
                reasons: ["The visible step fits cleanly inside the current week."]
            )
        )
        return Goal(
            schemaVersion: goalEngineSchemaVersion,
            id: "goal-plan-visible",
            revision: 1,
            createdAt: GoalEngineFixtures.fixedNow,
            updatedAt: GoalEngineFixtures.fixedNow,
            state: .active,
            title: "Submit conference proposal",
            summary: nil,
            mode: .achievement,
            relationshipKind: .independent,
            actor: actor,
            parentGoalID: nil,
            childGoalIDs: [],
            supportGoalIDs: [],
            tags: [],
            timing: timing,
            planningStrategy: strategy,
            progressStrategy: progress,
            plan: plan
        )
    }
}

private actor RecordingPlanCalendarRealityService: CalendarRealityServicing {
    private(set) var requestedActionNames: [String] = []

    func calendarPermissionState() async -> CalendarPermissionState {
        .notDetermined
    }

    func requestCalendarReadAccessFromPlan(actionName: String) async -> CalendarPermissionState {
        requestedActionNames.append(actionName)
        return .readWrite
    }

    func requestCalendarWriteAccessForConfirmedBlock(intent: ScheduledBlockWriteIntent) async -> CalendarPermissionState {
        _ = intent
        return .readWrite
    }

    func fetchDerivedBusyWindows(for range: DateInterval) async -> [RealityWindow] {
        [
            RealityWindow(
                id: "calendar-busy",
                kind: .calendarDerivedBusy,
                source: .calendarDerived,
                start: range.start.addingTimeInterval(3_600),
                end: range.start.addingTimeInterval(5_400),
                title: "Calendar busy time"
            )
        ]
    }

    func findOpenWindows(request: CalendarRealityReadRequest) async -> CalendarRealityReadResult {
        let permission = await requestCalendarReadAccessFromPlan(actionName: request.userInitiatedPlanAction)
        let busy = await fetchDerivedBusyWindows(for: request.horizon)
        let context = CalendarDerivedContext(
            permissionState: permission,
            observedRangeStart: request.horizon.start,
            observedRangeEnd: request.horizon.end,
            derivedBusyWindowCount: busy.count,
            userInitiatedPlanAction: request.userInitiatedPlanAction,
            explanation: "Plan used derived busy time locally."
        )
        let snapshot = RealityModelProjector().project(
            input: RealityProjectionInput(
                now: request.horizon.start,
                horizon: request.horizon,
                calendarBusyWindows: busy,
                calendarContext: context
            )
        )
        return CalendarRealityReadResult(
            permissionState: permission,
            derivedBusyWindows: busy,
            calendarContext: context,
            openWindowCandidates: snapshot.openWindowCandidates
        )
    }

    func currentRequestedActionNames() -> [String] {
        requestedActionNames
    }
}
