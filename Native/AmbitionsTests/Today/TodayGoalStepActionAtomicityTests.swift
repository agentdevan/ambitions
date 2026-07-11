import XCTest
@testable import Ambitions

final class TodayGoalStepActionAtomicityTests: XCTestCase {
    func testStaleRevisionBlocksBeforeAuthorityCommit() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("today-stale-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store)
        let created = try await SimpleStepLifecycleService(repositories: repositories)
            .createSimpleStep(title: "Do the current version", now: fixedNow)
        let prepared = try await RepositoryBackedTodayService(repositories: repositories)
            .prepareDurableGoalStepAction(action(.complete, created), now: fixedNow)
        let plan = try XCTUnwrap(TodayGoalStepActionPlan.decode(command: prepared.command))
        try await repositories.goals.saveGoals([copy(plan.updatedGoal, revision: plan.updatedGoal.revision + 1, title: "Changed elsewhere")])
        let events = EventStoreSQLite(databaseURL: root.appendingPathComponent("EventStore.sqlite"))

        let result = await AmbitionsCommandExecutor.test(
            runtimeEvents: events,
            todayActionMaterializer: SwiftDataTodayGoalStepActionMaterializer(store: store)
        ).execute(prepared.command, context: prepared.context)

        XCTAssertEqual(result.status, .blocked)
        XCTAssertNil(result.metadata["runtimeReceiptID"])
        let committedEvents = try await events.fetchEvents(matching: .kind(.domainMutation), limit: nil)
        let staleFeedback = try await repositories.feedback.listEvents(goalID: created.goalID)
        let staleEvidence = try await repositories.evidence.listEvidence(goalID: created.goalID)
        XCTAssertTrue(committedEvents.isEmpty)
        XCTAssertTrue(staleFeedback.isEmpty)
        XCTAssertTrue(staleEvidence.isEmpty)
    }

    func testIntermediateFailureRollsBackAllDerivedWritesAndReplayRepairsOnce() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store)
        let created = try await SimpleStepLifecycleService(repositories: repositories)
            .createSimpleStep(title: "Commit atomically", now: fixedNow)
        let prepared = try await RepositoryBackedTodayService(repositories: repositories)
            .prepareDurableGoalStepAction(action(.complete, created), now: fixedNow)
        let plan = try XCTUnwrap(TodayGoalStepActionPlan.decode(command: prepared.command))
        let before = try await repositories.goals.goal(id: created.goalID)

        do {
            try await SwiftDataTodayGoalStepActionMaterializer(store: store, failurePoint: .afterEvidence).materialize(plan)
            XCTFail("Expected injected transaction failure")
        } catch TodayGoalStepActionStorageError.injectedFailure(.afterEvidence) {}

        let rolledBackGoal = try await repositories.goals.goal(id: created.goalID)
        let rolledBackFeedback = try await repositories.feedback.listEvents(goalID: created.goalID)
        let rolledBackEvidence = try await repositories.evidence.listEvidence(goalID: created.goalID)
        XCTAssertEqual(rolledBackGoal, before)
        XCTAssertTrue(rolledBackFeedback.isEmpty)
        XCTAssertTrue(rolledBackEvidence.isEmpty)

        let materializer = SwiftDataTodayGoalStepActionMaterializer(store: store)
        try await materializer.materialize(plan)
        try await materializer.materialize(plan)
        let repairedFeedback = try await repositories.feedback.listEvents(goalID: created.goalID)
        let repairedEvidence = try await repositories.evidence.listEvidence(goalID: created.goalID)
        let repairedSteps = try await repositories.goals.listSteps(goalID: created.goalID)
        XCTAssertEqual(repairedFeedback.count, 1)
        XCTAssertEqual(repairedEvidence.count, 1)
        XCTAssertEqual(repairedSteps.first?.state, .completed)
    }

    func testRecurringCompletionPreservesStepAndAdvancesCadence() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store)
        let created = try await SimpleStepLifecycleService(repositories: repositories)
            .createSimpleStep(title: "Daily reset", now: fixedNow)
        let loadedGoal = try await repositories.goals.goal(id: created.goalID)
        let original = try XCTUnwrap(loadedGoal)
        let ritual = makeRecurring(original, stepID: created.stepID)
        try await repositories.goals.saveGoals([ritual])
        let prepared = try await RepositoryBackedTodayService(repositories: repositories)
            .prepareDurableGoalStepAction(action(.complete, created), now: fixedNow)

        XCTAssertEqual(prepared.command.privacy, .privateUserText)
        let plan = try XCTUnwrap(TodayGoalStepActionPlan.decode(command: prepared.command))
        try await SwiftDataTodayGoalStepActionMaterializer(store: store).materialize(plan)

        let loadedSteps = try await repositories.goals.listSteps(goalID: created.goalID)
        let step = try XCTUnwrap(loadedSteps.first)
        let evidence = try await repositories.evidence.listEvidence(goalID: created.goalID)
        XCTAssertEqual(step.state, .planned)
        XCTAssertTrue(step.isRepeatable)
        XCTAssertNotEqual(step.timing.suggestedNextAt, ritual.plan?.sections.flatMap(\.steps).first?.timing.suggestedNextAt)
        XCTAssertEqual(evidence.map(\.evidenceKind), [.ritualCompletion])
    }

    private var fixedNow: Date { Date(timeIntervalSince1970: 1_777_113_600) }

    private func action(_ kind: TodayActionKind, _ created: SimpleStepLifecycleResult) -> TodayInlineAction {
        TodayInlineAction(kind: kind, title: kind.rawValue, systemImage: "circle", state: .selected, target: TodayActionTarget(goalID: created.goalID, stepID: created.stepID))
    }

    private func makeRepositories(_ store: AmbitionsPersistenceStore) -> AppRepositories {
        AppRepositories(
            goals: SwiftDataGoalRepository(store: store), drafts: SwiftDataGoalDraftRepository(store: store),
            evidence: SwiftDataProgressEvidenceRepository(store: store), feedback: SwiftDataFeedbackEventRepository(store: store),
            captures: SwiftDataCaptureRepository(store: store), appState: SwiftDataAppStateRepository(store: store)
        )
    }

    private func copy(_ goal: Goal, revision: Int, title: String) -> Goal {
        Goal(
            schemaVersion: goal.schemaVersion, id: goal.id, revision: revision, createdAt: goal.createdAt,
            updatedAt: goal.updatedAt, state: goal.state, title: title, summary: goal.summary, mode: goal.mode,
            relationshipKind: goal.relationshipKind, actor: goal.actor, parentGoalID: goal.parentGoalID,
            childGoalIDs: goal.childGoalIDs, supportGoalIDs: goal.supportGoalIDs, tags: goal.tags,
            timing: goal.timing, planningStrategy: goal.planningStrategy, progressStrategy: goal.progressStrategy,
            plan: goal.plan, lifeGraph: goal.lifeGraph
        )
    }

    private func makeRecurring(_ goal: Goal, stepID: String) -> Goal {
        let sections = goal.plan?.sections.map { section in
            PlanSection(
                id: section.id, goalID: section.goalID, title: section.title, summary: section.summary,
                kind: section.kind, orderIndex: section.orderIndex,
                steps: section.steps.map { step in
                    guard step.id == stepID else { return step }
                    return Step(
                        id: step.id, sectionID: step.sectionID, title: step.title, summary: step.summary,
                        type: .recurringRoutine, state: .planned, owner: step.owner,
                        timing: GoalTiming(
                            tempo: .ongoing, timingType: .repeatWithinWindow,
                            startsOn: step.timing.startsOn, dueAt: nil, targetBy: nil,
                            windowStart: step.timing.windowStart, windowEnd: step.timing.windowEnd,
                            suggestedNextAt: step.timing.suggestedNextAt, repeatEveryDays: 1,
                            progressReviewCadenceDays: step.timing.progressReviewCadenceDays
                        ),
                        dependencyStepIDs: step.dependencyStepIDs, isOptional: step.isOptional, isRepeatable: true,
                        evidenceRequired: step.evidenceRequired, successSignals: step.successSignals, actionability: step.actionability
                    )
                }
            )
        }
        let plan = goal.plan.map { GoalPlan(id: $0.id, goalID: $0.goalID, version: $0.version, generatedAt: $0.generatedAt, summary: $0.summary, strategy: $0.strategy, sections: sections ?? $0.sections, assumptions: $0.assumptions, lint: $0.lint) }
        return Goal(
            schemaVersion: goal.schemaVersion, id: goal.id, revision: goal.revision + 1, createdAt: goal.createdAt,
            updatedAt: goal.updatedAt, state: goal.state, title: goal.title, summary: goal.summary, mode: .habit,
            relationshipKind: goal.relationshipKind, actor: goal.actor, parentGoalID: goal.parentGoalID,
            childGoalIDs: goal.childGoalIDs, supportGoalIDs: goal.supportGoalIDs, tags: goal.tags,
            timing: goal.timing, planningStrategy: goal.planningStrategy, progressStrategy: goal.progressStrategy,
            plan: plan, lifeGraph: goal.lifeGraph
        )
    }
}
