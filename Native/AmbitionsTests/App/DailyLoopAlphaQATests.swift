import XCTest
@testable import Ambitions

final class DailyLoopAlphaQATests: XCTestCase {
    func testPhaseAActivationAndTrustCopyAvoidsFutureEngineClaims() {
        let copy = activationCopy().joined(separator: " ")

        XCTAssertTrue(copy.contains("one real thing"))
        XCTAssertTrue(copy.contains("Capture is the singular intake"))
        XCTAssertTrue(copy.contains("Export and sync are not required to begin"))
        XCTAssertFalse(copy.contains("Life Graph"))
        XCTAssertFalse(copy.contains("Action Closure"))
        XCTAssertFalse(copy.contains("Believability Kernel"))
        XCTAssertFalse(copy.contains("Trust Ledger"))
        XCTAssertTrue(copy.contains("must not claim a live sync or export flow"))
        XCTAssertFalse(copy.localizedCaseInsensitiveContains("fully synced"))
    }

    func testDailyLoopEmptyAndReturnPathsRouteToOneRealAction() {
        let today = DegradedStateOrchestrator.todayEmpty()
        let capture = DegradedStateOrchestrator.capturesEmpty()
        let returnPath = ActivationContract.promise(for: .firstReturnPath)

        XCTAssertEqual(today.title, "Today is waiting for one real thing")
        XCTAssertEqual(today.primaryAction.routingHint, .createGoal)
        XCTAssertEqual(today.secondaryAction?.routingHint, .quickCapture)
        XCTAssertEqual(capture.title, "Capture messy life here")
        XCTAssertEqual(capture.primaryAction.routingHint, .quickCapture)
        XCTAssertEqual(ActivationSurface.capture.title, "Capture")
        XCTAssertEqual(returnPath.primaryRoutingHint, .today)
        XCTAssertFalse(today.explanation.localizedCaseInsensitiveContains("sync"))
        XCTAssertFalse(capture.explanation.localizedCaseInsensitiveContains("export"))
    }

    func testTodayDailyContractStaysOneHeroLimitedSupportAndPlanOwnedCalendar() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTodayService(repositories: repositories)
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-15T12:00:00Z"))
        try await repositories.goals.saveGoals([
            makeGoal(
                id: "goal-alpha",
                stepID: "step-alpha",
                stepTitle: "Send the client spreadsheet",
                dueAt: "2026-04-15T20:00:00Z",
                domain: .career
            )
        ])

        let experience = try await service.loadTodayExperience(userDisplayName: "", now: now)

        XCTAssertEqual(experience.execution.hero.kind, .nextAction)
        XCTAssertEqual(experience.execution.protectedMustDo.title, "Keep this")
        XCTAssertEqual(experience.execution.recommendedStep.subtitle, "Send the client spreadsheet")
        XCTAssertEqual(experience.execution.notToday.title, "Not today")
        XCTAssertEqual(experience.execution.recoveryFallback.title, "Fallback")
        XCTAssertEqual(experience.execution.whyThisMatters.title, "Why this matters")
        XCTAssertLessThanOrEqual(experience.execution.supportingPanels.count, 2)
        XCTAssertFalse(experience.execution.planRequestsCalendarPermission)
        XCTAssertTrue(experience.execution.commandMappings.contains { $0.actionKind == .openPlan && $0.destination == .plan })
    }

    func testSaveTheDayRecoveryPathStaysNonPunitiveAndRouteOnly() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTodayService(repositories: repositories)
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-15T12:00:00Z"))
        let goal = makeGoal(
            id: "goal-recovery",
            stepID: "step-recovery",
            stepTitle: "Send the late proposal",
            dueAt: "2026-04-15T13:00:00Z",
            domain: .career
        )
        let passiveGoal = makeGoal(
            id: "goal-passive",
            stepID: "step-passive",
            stepTitle: "Practice a long-term skill",
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
            goalID: goal.id,
            title: "Skipped"
        )
        try await repositories.goals.saveGoals([passiveGoal, goal])
        try await repositories.eventLedger.append(skipped)

        let experience = try await service.loadTodayExperience(userDisplayName: "", now: now)
        let recoveryCopy = [
            experience.execution.hero.title,
            experience.execution.hero.subtitle,
            experience.execution.recoveryFallback.value,
            experience.execution.saveTheDayAction?.title ?? ""
        ].joined(separator: " ")

        XCTAssertEqual(experience.execution.hero.kind, .recovery)
        XCTAssertEqual(experience.execution.saveTheDayAction?.title, "Save the day")
        XCTAssertFalse(experience.execution.planRequestsCalendarPermission)
        XCTAssertFalse(recoveryCopy.localizedCaseInsensitiveContains("guilt"))
        XCTAssertFalse(recoveryCopy.localizedCaseInsensitiveContains("punish"))
        XCTAssertFalse(recoveryCopy.localizedCaseInsensitiveContains("automatically rescheduled"))
    }
}

private extension DailyLoopAlphaQATests {
    func activationCopy() -> [String] {
        var copy = [
            ActivationContract.firstTenMinutesPromise,
            ActivationContract.orientationTitle,
            ActivationContract.orientationSubtitle,
            ActivationContract.startTitle,
            ActivationContract.startSubtitle,
            ActivationContract.trustMessage.title,
            ActivationContract.trustMessage.explanation
        ]

        copy.append(contentsOf: ActivationContract.trustMessage.rows.flatMap { [$0.title, $0.detail] })
        copy.append(contentsOf: ActivationContract.onboardingSurfaceRows.flatMap { [$0.title, $0.detail] })
        copy.append(contentsOf: ActivationMomentKind.allCases.flatMap {
            let promise = ActivationContract.promise(for: $0)
            return [promise.title, promise.explanation, promise.primaryActionTitle ?? ""]
        })
        copy.append(contentsOf: ActivationSurface.allCases.flatMap {
            let rule = ActivationContract.emptyStateRule(for: $0)
            return [rule.title, rule.explanation, rule.primaryAction.title, rule.secondaryAction?.title ?? ""]
        })
        return copy
    }

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
        domain: LifeDomainKey
    ) -> Goal {
        let actor = GoalActor(actorID: "self", displayName: "You", ownership: .self, roleLabel: "Primary owner", isPrimary: true)
        let timing = GoalTiming(tempo: .deadlineBased, timingType: .dueAt, startsOn: nil, dueAt: dueAt, targetBy: nil, windowStart: nil, windowEnd: nil, suggestedNextAt: nil, repeatEveryDays: nil, progressReviewCadenceDays: 7)
        let strategy = PlanningStrategy(strategyKind: .sequential, allowParallelSteps: false, maxActiveSteps: 3, preferredSectionOrder: [.activeSteps], defaultStepType: .actionUnit, autoGenerateReviewSection: false, preferShortSteps: true, revisitCadenceDays: 7)
        let progress = ProgressStrategy(metricKind: .stepCompletion, rollupMethod: .ratio, targetStepCount: nil, targetEvidenceCount: nil, targetMinutes: nil, supportsUntimedProgress: true, countsChildGoals: false, countsSupportGoals: false)
        let step = Step(id: stepID, sectionID: "section-\(id)", title: stepTitle, summary: nil, type: .actionUnit, state: .planned, owner: actor, timing: timing, dependencyStepIDs: [], isOptional: false, isRepeatable: false, evidenceRequired: true, successSignals: ["Done"], actionability: StepActionability(action: "Do it", completionDefinition: "Done", evidenceOfCompletion: ["Done"], fallbackMicroStep: "Start", contextRequirements: []))
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
            lifeGraph: LifeGraphContext(domains: [LifeDomainAssignment(domain: domain)])
        )
    }
}
