import XCTest
@testable import Ambitions

final class GoalsOverviewBoardTests: XCTestCase {
    func testOverviewUsesRecoverPrimaryActionWhenAtRiskGoalExists() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedGoalsService(repositories: repositories)
        let liveGoal = makeGoal(
            id: "goal-live-direction",
            title: "Ship the native create goal flow",
            dueInDays: 18
        )
        let blocked = makeClarificationDraft(
            id: "draft-clarify-start",
            title: "I don't know where to start"
        )

        try await repositories.goals.saveGoals([liveGoal])
        try await repositories.drafts.saveDrafts([blocked])
        try await savePriorityOrder([liveGoal.id, blocked.id], repositories: repositories)

        let overview = try await service.loadOverview()

        XCTAssertEqual(overview.heroPrimaryAction.kind, .recoverGoal)
        XCTAssertEqual(overview.heroPrimaryAction.target, GoalRouteTarget(draftID: blocked.id))
        XCTAssertTrue(overview.bands.contains(where: { $0.kind == .activeDirection && $0.cards.isEmpty == false }))
        XCTAssertTrue(
            overview.bands
                .first(where: { $0.kind == .pressure })?
                .cards
                .contains(where: { $0.target == GoalRouteTarget(draftID: blocked.id) && $0.posture == .atRisk }) == true
        )
    }

    func testOverviewGroupsCrowdedAndStalledGoalsUsingExistingSignals() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedGoalsService(repositories: repositories)
        let active = makeGoal(
            id: "goal-live-proposal",
            title: "Submit my conference talk proposal",
            dueInDays: 12
        )
        let stalled = makeGoal(
            id: "goal-stalled-learning",
            title: "Learn how to mix vocals",
            dueInDays: 45
        )
        let crowded = makeGoal(
            id: "goal-crowded-certification",
            title: "Finish my certification",
            dueInDays: 12
        )

        try await repositories.goals.saveGoals([active, stalled, crowded])
        try await savePriorityOrder([active.id, stalled.id, crowded.id], repositories: repositories)

        let overview = try await service.loadOverview()
        let boardCards = overview.bands.flatMap(\.cards)

        XCTAssertTrue(boardCards.contains(where: { $0.posture == .stalled }))
        XCTAssertTrue(boardCards.contains(where: { $0.target == GoalRouteTarget(goalID: crowded.id, draftID: nil) && $0.posture == .crowded }))
        XCTAssertEqual(
            overview.bands.first(where: { $0.kind == .pressure })?.cards.first(where: { $0.target == GoalRouteTarget(goalID: crowded.id, draftID: nil) })?.posture,
            .crowded
        )
    }

    func testOverviewBuildsHorizonLadderFallbackFromPlanSectionsWhenPathGraphIsThin() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedGoalsService(repositories: repositories)
        let goal = makeGoal(
            id: "goal-horizon-ladder",
            title: "Ship the native create goal flow",
            dueInDays: 20
        )

        try await repositories.goals.saveGoals([goal])
        try await savePriorityOrder([goal.id], repositories: repositories)

        let overview = try await service.loadOverview()
        let rung = try XCTUnwrap(overview.horizonLadder.rungs.first)

        XCTAssertFalse(rung.summary.isEmpty)
        XCTAssertFalse(rung.highlight.isEmpty)
        XCTAssertFalse(rung.milestoneLabel.isEmpty)
        XCTAssertTrue(rung.milestoneLabel.contains("steps") || rung.milestoneLabel.contains("milestones"))
    }
}

private extension GoalsOverviewBoardTests {
    var now: Date {
        Date()
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

    func savePriorityOrder(_ ids: [String], repositories: AppRepositories) async throws {
        var state = try await repositories.appState.loadState()
        state.goalPriorityOrder = ids
        try await repositories.appState.saveState(state)
    }

    func makeGoal(id: String, title: String, dueInDays: Int) -> Goal {
        let actor = GoalActor(actorID: "self", displayName: "You", ownership: .self, roleLabel: "Primary owner", isPrimary: true)
        let timing = GoalTiming(
            tempo: .deadlineBased,
            timingType: .dueAt,
            startsOn: nil,
            dueAt: isoDate(daysFromNow: dueInDays),
            targetBy: nil,
            windowStart: nil,
            windowEnd: nil,
            suggestedNextAt: nil,
            repeatEveryDays: nil,
            progressReviewCadenceDays: 7
        )
        let strategy = PlanningStrategy(
            strategyKind: .sequential,
            allowParallelSteps: false,
            maxActiveSteps: 3,
            preferredSectionOrder: [.activeSteps],
            defaultStepType: .actionUnit,
            autoGenerateReviewSection: false,
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
            title: "Do the next visible move",
            summary: nil,
            type: .actionUnit,
            state: .planned,
            owner: actor,
            timing: timing,
            dependencyStepIDs: [],
            isOptional: false,
            isRepeatable: false,
            evidenceRequired: true,
            successSignals: ["Done"],
            actionability: StepActionability(
                action: "Do it",
                completionDefinition: "Done",
                evidenceOfCompletion: ["Done"],
                fallbackMicroStep: "Start",
                contextRequirements: []
            )
        )
        let plan = GoalPlan(
            id: "plan-\(id)",
            goalID: id,
            version: goalEnginePlanVersion,
            generatedAt: isoDate(daysFromNow: -1),
            summary: nil,
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
            lint: PlanLintResult(goalID: id, planVersion: goalEnginePlanVersion, isValid: true, issueCount: 0, issues: [])
        )

        return Goal(
            schemaVersion: goalEngineSchemaVersion,
            id: id,
            revision: 1,
            createdAt: isoDate(daysFromNow: -2),
            updatedAt: isoDate(daysFromNow: -1),
            state: .active,
            title: title,
            summary: nil,
            mode: .project,
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

    func makeClarificationDraft(id: String, title: String) -> PersistedGoalDraft {
        let actor = GoalActor(actorID: "self", displayName: "You", ownership: .self, roleLabel: "Primary owner", isPrimary: true)
        let draft = GoalDraft(
            schemaVersion: goalEngineSchemaVersion,
            source: .manual,
            title: title,
            summary: nil,
            mode: .project,
            relationshipKind: .independent,
            actor: actor,
            parentGoalID: nil,
            tags: [],
            timing: GoalTiming(
                tempo: .untimed,
                timingType: .logWhenDone,
                startsOn: nil,
                dueAt: nil,
                targetBy: nil,
                windowStart: nil,
                windowEnd: nil,
                suggestedNextAt: nil,
                repeatEveryDays: nil,
                progressReviewCadenceDays: 7
            ),
            planningStrategy: PlanningStrategy(
                strategyKind: .adaptive,
                allowParallelSteps: true,
                maxActiveSteps: 3,
                preferredSectionOrder: [.overview, .activeSteps],
                defaultStepType: .actionUnit,
                autoGenerateReviewSection: true,
                preferShortSteps: true,
                revisitCadenceDays: 7
            ),
            progressStrategy: ProgressStrategy(
                metricKind: .stepCompletion,
                rollupMethod: .ratio,
                targetStepCount: nil,
                targetEvidenceCount: nil,
                targetMinutes: nil,
                supportsUntimedProgress: true,
                countsChildGoals: false,
                countsSupportGoals: false
            )
        )

        return PersistedGoalDraft(
            id: id,
            createdAt: isoDate(daysFromNow: -1),
            updatedAt: isoDate(daysFromNow: -1),
            draft: draft,
            classification: nil,
            clarification: nil,
            stagedPlan: nil,
            assumptions: [],
            blockers: [],
            metadata: nil,
            plannedGoalID: nil,
            latestResultKind: .clarificationRequired
        )
    }

    func isoDate(daysFromNow: Int) -> String {
        let date = Calendar.current.date(byAdding: .day, value: daysFromNow, to: now) ?? now
        return ISO8601DateFormatter().string(from: date)
    }
}
