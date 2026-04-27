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
        XCTAssertEqual(dashboard.treaty.title, "This week's agreement")
        XCTAssertEqual(dashboard.capacityEnvelope.label, "Light")
        XCTAssertFalse(dashboard.calendarBoundary.writeBoundary.lowercased().contains("sync"))
        XCTAssertFalse(dashboard.recoveryEntry.detail.contains("Reality Reflow"))
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
        XCTAssertEqual(dashboard.treaty.title, "This week's agreement")
        XCTAssertFalse(dashboard.treaty.summary.contains("Kernel"))
        XCTAssertTrue(["Light", "Steady", "Tight", "Overloaded", "Fragile"].contains(dashboard.capacityEnvelope.label))
        XCTAssertFalse(dashboard.opportunityWindows.windows.isEmpty)
        XCTAssertLessThanOrEqual(dashboard.opportunityWindows.windows.count, 4)
        XCTAssertFalse(dashboard.timelineStrip.items.isEmpty)
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
        _ = try await DefaultCaptureService(repository: repositories.captures).createCapture(
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
        _ = try await DefaultCaptureService(repository: repositories.captures).createCapture(
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

    func testCalendarDeniedProducesManualFallbackWithoutFakeClaims() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedPlanService(
            repositories: repositories,
            calendarRealityService: FixedPermissionCalendarRealityService(permission: .denied)
        )

        let dashboard = try await service.loadPlanDashboard(now: fixedDate)

        XCTAssertEqual(dashboard.calendarAwareness.status, .denied)
        XCTAssertFalse(dashboard.calendarBoundary.canRequestCalendarRead)
        XCTAssertTrue(dashboard.calendarBoundary.manualFallback.contains("Manual planning still works"))
        XCTAssertTrue(dashboard.calendarBoundary.writeBoundary.contains("never silently writes"))
        XCTAssertFalse(dashboard.calendarBoundary.detail.lowercased().contains("sync"))
        XCTAssertFalse(dashboard.calendarBoundary.detail.lowercased().contains("export"))
    }

    func testPlanLifecycleRailDistinguishesCarriedAndOutsideGoalStates() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals([
            makeWeekVisibleGoal(id: "goal-active", title: "Active carried goal"),
            makeWeekVisibleGoal(id: "goal-future", title: "Future goal", state: .draft),
            makeWeekVisibleGoal(id: "goal-completed", title: "Completed goal", state: .completed),
            makeWeekVisibleGoal(id: "goal-cancelled", title: "Cancelled goal", state: .archived, stepState: .cancelled),
            makeWeekVisibleGoal(id: "goal-parked", title: "Parked goal", state: .paused),
            makeWeekVisibleGoal(id: "goal-blocked", title: "Blocked goal", stepState: .blocked),
            makeWeekVisibleGoal(id: "goal-waiting", title: "Waiting goal", mode: .delegatedSupport, relationshipKind: .delegated)
        ])
        let service = RepositoryBackedPlanService(repositories: repositories)

        let dashboard = try await service.loadPlanDashboard(now: fixedDate)
        let counts = Dictionary(uniqueKeysWithValues: dashboard.lifecycleRail.segments.map { ($0.lifecycleState, $0.count) })

        XCTAssertGreaterThanOrEqual(counts[.active, default: 0], 1)
        XCTAssertGreaterThanOrEqual(counts[.future, default: 0], 1)
        XCTAssertEqual(counts[.completed], 1)
        XCTAssertEqual(counts[.cancelledDropped], 1)
        XCTAssertEqual(counts[.parked], 1)
        XCTAssertEqual(counts[.blocked], 1)
        XCTAssertEqual(counts[.waiting], 1)
        XCTAssertEqual(dashboard.lifecycleRail.segments.map(\.lifecycleState), [.previous, .active, .future, .waiting, .blocked, .parked, .protected, .completed, .cancelledDropped])
    }

    func testPlanTimelineIncludesActiveFutureAndPreviousWithoutFakeCertainty() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals([
            makeWeekVisibleGoal(id: "goal-active", title: "Active carried goal"),
            makeWeekVisibleGoal(id: "goal-future", title: "Future goal", state: .draft),
            makeWeekVisibleGoal(id: "goal-previous", title: "Previous goal", state: .archived, stepState: .completed)
        ])
        let service = RepositoryBackedPlanService(repositories: repositories)

        let dashboard = try await service.loadPlanDashboard(now: fixedDate)

        XCTAssertTrue(dashboard.timelineStrip.items.contains(where: { $0.kind == .active }))
        XCTAssertTrue(dashboard.timelineStrip.items.contains(where: { $0.kind == .future }))
        XCTAssertTrue(dashboard.timelineStrip.items.contains(where: { $0.kind == .previous }))
        XCTAssertFalse(dashboard.timelineStrip.items.map(\.detail).joined(separator: " ").contains("%"))
    }

    func testCapacityEnvelopeUsesQualitativeStates() async throws {
        let lightRepositories = try await makeRepositories()
        let lightDashboard = try await RepositoryBackedPlanService(repositories: lightRepositories).loadPlanDashboard(now: fixedDate)
        XCTAssertEqual(lightDashboard.capacityEnvelope.label, "Light")

        let steadyRepositories = try await makeRepositories()
        try await steadyRepositories.goals.saveGoals([makeWeekVisibleGoal()])
        let steadyDashboard = try await RepositoryBackedPlanService(repositories: steadyRepositories).loadPlanDashboard(now: fixedDate)
        XCTAssertTrue(["Steady", "Tight"].contains(steadyDashboard.capacityEnvelope.label))

        let tightRepositories = try await makeRepositories()
        try await tightRepositories.goals.saveGoals([
            makeWeekVisibleGoal(id: "tight-1", title: "Tight one"),
            makeWeekVisibleGoal(id: "tight-2", title: "Tight two"),
            makeWeekVisibleGoal(id: "tight-3", title: "Tight three")
        ])
        let tightDashboard = try await RepositoryBackedPlanService(repositories: tightRepositories).loadPlanDashboard(now: fixedDate)
        XCTAssertTrue(["Tight", "Overloaded"].contains(tightDashboard.capacityEnvelope.label))

        let overloadedRepositories = try await makeRepositories()
        try await overloadedRepositories.goals.saveGoals((0..<6).map { makeWeekVisibleGoal(id: "overloaded-\($0)", title: "Overloaded \($0)") })
        let overloadedDashboard = try await RepositoryBackedPlanService(repositories: overloadedRepositories).loadPlanDashboard(now: fixedDate)
        XCTAssertEqual(overloadedDashboard.capacityEnvelope.label, "Overloaded")
    }

    func testDecisionDebtConflictCourtAndRecoveryAreSuggestionOnly() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals([
            makeWeekVisibleGoal(id: "goal-proof-thin", title: "Proof thin goal"),
            makeWeekVisibleGoal(id: "goal-blocked", title: "Blocked goal", stepState: .blocked)
        ])
        _ = try await DefaultCaptureService(repository: repositories.captures).createCapture(
            CreateCaptureRequest(rawText: "Waiting on partner response", sourceType: .todayQuickCapture),
            now: fixedDate
        )
        let service = RepositoryBackedPlanService(repositories: repositories)

        let dashboard = try await service.loadPlanDashboard(now: fixedDate)

        XCTAssertFalse(dashboard.decisionDebt.items.isEmpty)
        XCTAssertFalse(dashboard.conflictCourt.conflicts.isEmpty)
        XCTAssertFalse(dashboard.recoveryEntry.suggestions.isEmpty)
        XCTAssertTrue(dashboard.recoveryEntry.boundary.contains("No schedule changes"))
        XCTAssertTrue(dashboard.conflictCourt.subtitle.contains("not alarms") || dashboard.conflictCourt.conflicts.isEmpty)
    }

    func testRealityReflowNoReflowNeededProducesCalmStillBelievableState() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals([makeWeekVisibleGoal()])
        let service = RepositoryBackedPlanService(repositories: repositories)

        let dashboard = try await service.loadPlanDashboard(now: fixedDate)

        XCTAssertEqual(dashboard.realityReflow.reasonKind, .stillBelievable)
        XCTAssertEqual(dashboard.realityReflow.title, "Plan is still believable")
        XCTAssertTrue(dashboard.realityReflow.suggestions.contains(where: { $0.kind == .keepPlanUnchanged }))
        XCTAssertTrue(dashboard.realityReflow.noChangeCopy.contains("Nothing changed"))
    }

    func testOverloadedPlanProducesRealityReflowRecommendationWithoutMutation() async throws {
        let repositories = try await makeRepositories()
        let goals = (0..<6).map { makeWeekVisibleGoal(id: "reflow-overload-\($0)", title: "Reflow overload \($0)") }
        try await repositories.goals.saveGoals(goals)
        let before = try await repositories.goals.listGoals()
        let service = RepositoryBackedPlanService(repositories: repositories)

        let dashboard = try await service.loadPlanDashboard(now: fixedDate)
        let after = try await repositories.goals.listGoals()

        XCTAssertEqual(dashboard.realityReflow.reasonKind, .overloadedPlan)
        XCTAssertTrue(dashboard.realityReflow.suggestions.contains(where: { $0.kind == .protectOneItem }))
        XCTAssertTrue(dashboard.realityReflow.suggestions.contains(where: { $0.kind == .shrinkAction }))
        XCTAssertTrue(dashboard.realityReflow.suggestions.contains(where: { $0.kind == .moveLocalActionLater }))
        XCTAssertEqual(before, after)
    }

    func testNoRecoveryMarginSuggestsSmallAdjustmentsBeforeBroadChanges() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals((0..<6).map { makeWeekVisibleGoal(id: "margin-\($0)", title: "Margin \($0)") })
        let service = RepositoryBackedPlanService(repositories: repositories)

        let dashboard = try await service.loadPlanDashboard(now: fixedDate)
        let orderedKinds = dashboard.recoveryGradient.options.map(\.kind)

        XCTAssertEqual(Array(orderedKinds.prefix(4)), [.protectOneItem, .shrinkAction, .splitAction, .moveLocalActionLater])
        XCTAssertTrue(dashboard.realityReflow.suggestions.first?.boundary.confirmationRequirement == .notRequired)
        XCTAssertFalse(dashboard.realityReflow.suggestions.first?.detail.lowercased().contains("reschedule") ?? true)
    }

    func testBlockedAndWaitingPlanSurfacesAppropriateRealityReasons() async throws {
        let blockedRepositories = try await makeRepositories()
        try await blockedRepositories.goals.saveGoals([makeWeekVisibleGoal(id: "blocked-reflow", title: "Blocked reflow", stepState: .blocked)])
        let blockedDashboard = try await RepositoryBackedPlanService(repositories: blockedRepositories).loadPlanDashboard(now: fixedDate)

        XCTAssertEqual(blockedDashboard.realityReflow.reasonKind, .blockedGoal)
        XCTAssertTrue(blockedDashboard.realityReflow.suggestions.contains(where: { $0.kind == .markWaiting }))

        let waitingRepositories = try await makeRepositories()
        try await waitingRepositories.captures.saveCaptures([makeWaitingCapture()])
        let waitingDashboard = try await RepositoryBackedPlanService(repositories: waitingRepositories).loadPlanDashboard(now: fixedDate)

        XCTAssertEqual(waitingDashboard.realityReflow.reasonKind, .waitingOnPersonOrResource)
        XCTAssertTrue(waitingDashboard.realityReflow.suggestions.contains(where: { $0.kind == .markWaiting }))
    }

    func testCalendarDeniedStillProducesManualRecoveryOptions() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals([makeWeekVisibleGoal()])
        let service = RepositoryBackedPlanService(
            repositories: repositories,
            calendarRealityService: FixedPermissionCalendarRealityService(permission: .denied)
        )

        let dashboard = try await service.loadPlanDashboard(now: fixedDate)

        XCTAssertEqual(dashboard.calendarAwareness.status, .denied)
        XCTAssertTrue(dashboard.calendarBoundary.manualFallback.contains("Manual planning still works"))
        XCTAssertTrue(dashboard.realityReflow.suggestions.contains(where: { $0.kind == .protectOneItem || $0.kind == .keepPlanUnchanged }))
        XCTAssertTrue(dashboard.reflowReceiptPreview.whatWouldNotChange.contains(where: { $0.contains("Calendar blocks are not written") }))
    }

    func testBroadReflowAndCalendarImpactingChangesRequireConfirmation() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals((0..<6).map { makeWeekVisibleGoal(id: "confirm-\($0)", title: "Confirm \($0)") })
        let service = RepositoryBackedPlanService(repositories: repositories)

        let dashboard = try await service.loadPlanDashboard(now: fixedDate)

        let moveLater = try XCTUnwrap(dashboard.realityReflow.suggestions.first(where: { $0.kind == .moveLocalActionLater }))
        let drop = try XCTUnwrap(dashboard.realityReflow.suggestions.first(where: { $0.kind == .dropOptionalWork }))
        let confirm = try XCTUnwrap(dashboard.realityReflow.suggestions.first(where: { $0.kind == .askForConfirmation }))

        XCTAssertEqual(moveLater.boundary.confirmationRequirement, .requiredForBroadReflow)
        XCTAssertEqual(drop.boundary.confirmationRequirement, .requiredForDestructiveChange)
        XCTAssertNotEqual(confirm.boundary.confirmationRequirement, .notRequired)
        XCTAssertTrue(dashboard.calendarBoundary.writeBoundary.contains("never silently writes"))
    }

    func testReceiptPreviewIncludesWouldChangeAndWouldNotChange() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals((0..<6).map { makeWeekVisibleGoal(id: "receipt-\($0)", title: "Receipt \($0)") })
        let service = RepositoryBackedPlanService(repositories: repositories)

        let dashboard = try await service.loadPlanDashboard(now: fixedDate)

        XCTAssertFalse(dashboard.reflowReceiptPreview.whatChanged.isEmpty)
        XCTAssertFalse(dashboard.reflowReceiptPreview.whatWouldNotChange.isEmpty)
        XCTAssertTrue(dashboard.reflowReceiptPreview.whatWouldNotChange.contains(where: { $0.contains("not silently rescheduled") }))
        XCTAssertTrue(dashboard.reflowReceiptPreview.confirmationRequired.contains("Safe local") || dashboard.reflowReceiptPreview.confirmationRequired.contains("confirmation"))
        XCTAssertFalse(dashboard.reflowReceiptPreview.safeFailureFallback.isEmpty)
    }

    func testSaveTheDayReturnsProtectedAdjustmentAndExplanation() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals((0..<6).map { makeWeekVisibleGoal(id: "save-\($0)", title: "Save \($0)") })
        let service = RepositoryBackedPlanService(repositories: repositories)

        let dashboard = try await service.loadPlanDashboard(now: fixedDate)

        XCTAssertFalse(dashboard.saveTheDay.protectedItem.isEmpty)
        XCTAssertFalse(dashboard.saveTheDay.adjustment.isEmpty)
        XCTAssertFalse(dashboard.saveTheDay.recoveryExplanation.isEmpty)
        XCTAssertTrue(dashboard.saveTheDay.boundary.contains("No silent rescheduling"))
    }

    func testReflowCopyAvoidsFakeFutureSystemClaims() async throws {
        let repositories = try await makeRepositories()
        try await repositories.goals.saveGoals((0..<6).map { makeWeekVisibleGoal(id: "copy-\($0)", title: "Copy \($0)") })
        let dashboard = try await RepositoryBackedPlanService(repositories: repositories).loadPlanDashboard(now: fixedDate)

        let copy = [
            dashboard.realityReflow.title,
            dashboard.realityReflow.detail,
            dashboard.saveTheDay.boundary,
            dashboard.reflowReceiptPreview.detail,
            dashboard.reflowReceiptPreview.safeFailureFallback
        ].joined(separator: " ").lowercased()

        XCTAssertFalse(copy.contains("automatically"))
        XCTAssertFalse(copy.contains("will sync"))
        XCTAssertFalse(copy.contains("exported"))
        XCTAssertFalse(copy.contains("calendar written"))
    }

    func testTopLevelIARemainsCanonicalFiveTabShell() {
        XCTAssertEqual(AppTab.allCases.map(\.title), ["Today", "Goals", "Capture", "Plan", "You"])
        XCTAssertFalse(AppTab.allCases.map(\.title).contains("Captures"))
        XCTAssertFalse(AppTab.allCases.map(\.title).contains("Insights"))
        XCTAssertFalse(AppTab.allCases.map(\.title).contains("Profile"))
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

    func makeWeekVisibleGoal(
        id: String = "goal-plan-visible",
        title: String = "Submit conference proposal",
        state: GoalLifecycleState = .active,
        mode: GoalMode = .achievement,
        relationshipKind: GoalRelationshipKind = .independent,
        stepState: StepLifecycleState = .planned
    ) -> Goal {
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
            id: "step-\(id)",
            sectionID: "section-\(id)",
            title: "Draft and submit the proposal",
            summary: "Finish the visible draft and send it before the deadline.",
            type: .actionUnit,
            state: stepState,
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
            id: "plan-\(id)",
            goalID: id,
            version: goalEnginePlanVersion,
            generatedAt: GoalEngineFixtures.fixedNow,
            summary: "Conference proposal work is explicitly carried by this week.",
            strategy: strategy,
            sections: [
                PlanSection(
                    id: "section-\(id)",
                    goalID: id,
                    title: "Active",
                    summary: nil,
                    kind: .activeSteps,
                    orderIndex: 0,
                    steps: [step]
                )
            ],
            assumptions: [],
            lint: PlanLintResult(
                goalID: id,
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
            id: id,
            revision: 1,
            createdAt: GoalEngineFixtures.fixedNow,
            updatedAt: GoalEngineFixtures.fixedNow,
            state: state,
            title: title,
            summary: nil,
            mode: mode,
            relationshipKind: relationshipKind,
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

    func makeWaitingCapture() -> Capture {
        Capture(
            id: "capture-waiting-reflow",
            createdAt: GoalEngineFixtures.fixedNow,
            updatedAt: GoalEngineFixtures.fixedNow,
            rawText: "Waiting on partner response",
            sourceType: .todayQuickCapture,
            status: .waiting,
            linkedGoalID: nil,
            kind: .waitingItem,
            route: .waiting,
            triageStatus: .waiting,
            waitingMetadata: CaptureWaitingMetadata(blockedBy: "Partner response", waitingOn: "Partner")
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

private struct FixedPermissionCalendarRealityService: CalendarRealityServicing {
    let permission: CalendarPermissionState

    func calendarPermissionState() async -> CalendarPermissionState {
        permission
    }

    func requestCalendarReadAccessFromPlan(actionName: String) async -> CalendarPermissionState {
        _ = actionName
        return permission
    }

    func requestCalendarWriteAccessForConfirmedBlock(intent: ScheduledBlockWriteIntent) async -> CalendarPermissionState {
        _ = intent
        return permission
    }

    func fetchDerivedBusyWindows(for range: DateInterval) async -> [RealityWindow] {
        _ = range
        return []
    }

    func findOpenWindows(request: CalendarRealityReadRequest) async -> CalendarRealityReadResult {
        CalendarRealityReadResult(
            permissionState: permission,
            derivedBusyWindows: [],
            calendarContext: CalendarDerivedContext(
                permissionState: permission,
                observedRangeStart: request.horizon.start,
                observedRangeEnd: request.horizon.end,
                derivedBusyWindowCount: 0,
                userInitiatedPlanAction: request.userInitiatedPlanAction,
                explanation: "Calendar permission unavailable."
            ),
            openWindowCandidates: []
        )
    }
}
