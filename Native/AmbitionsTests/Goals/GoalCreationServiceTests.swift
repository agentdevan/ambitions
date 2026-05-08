import XCTest
@testable import Ambitions

final class GoalCreationServiceTests: XCTestCase {
    func testD16HabitModeDisplaysAsRitualForGoalSurfaces() {
        XCTAssertEqual(GoalMode.habit.displayTitle, "Ritual")
        XCTAssertFalse(AppTab.allCases.map(\.title).contains("Habits"))
    }

    func testPlannerIsDeterministicForSameInput() {
        let planner = DeterministicGoalPlanner()

        let first = planner.plan(for: "Learn SwiftUI layout")
        let second = planner.plan(for: "Learn SwiftUI layout")

        XCTAssertEqual(first, second)
        XCTAssertEqual(first.steps.count, 3)
    }

    func testServiceCreatesCanonicalGoalEnginePlansForExampleGoals() async throws {
        let examples = [
            "Learn how to mix vocals",
            "Submit my conference talk proposal by 2026-05-15",
            "Keep my stretching routine going weekly",
            "Launch my business",
            "Plan a freelance pivot"
        ]
        let orchestrator = GoalEngineOrchestrator()

        let repositories = try await makeRepositories()
        let service = RepositoryBackedGoalsService(repositories: repositories)

        for title in examples {
            let expected = orchestrator.compileGoal(
                title,
                context: GoalEngineOrchestrationContext(referenceNow: DomainTimestamp.string(from: fixedNow))
            )
            let expectedMode: GoalMode
            let expectedKind: GoalOrchestrationResultKind
            switch expected {
            case let .planned(result):
                expectedMode = result.draft.mode
                expectedKind = .planned
            case let .starterPlanned(result):
                expectedMode = result.draft.mode
                expectedKind = .starterPlanned
            case .clarificationRequired, .blocked:
                XCTFail("Example should produce a persisted goal: \(title)")
                continue
            }

            let response = try await service.createGoal(CreateGoalRequest(title: title), now: fixedNow)
            let goalID = try XCTUnwrap(response.target.goalID)
            let fetchedGoal = try await repositories.goals.goal(id: goalID)
            let goal = try XCTUnwrap(fetchedGoal)
            let draftID = try XCTUnwrap(response.target.draftID)
            let fetchedDraft = try await repositories.drafts.draft(id: draftID)
            let draft = try XCTUnwrap(fetchedDraft)
            let steps = try await repositories.goals.listSteps(goalID: goal.id)

            XCTAssertEqual(response.blueprint.title, title)
            XCTAssertEqual(response.blueprint.mode, expectedMode)
            XCTAssertEqual(response.resultKind, expectedKind)
            XCTAssertNotNil(response.planningEvaluation)
            XCTAssertEqual(response.unitOfWorkReceipt?.writeScope, .localSwiftDataSingleContext)
            XCTAssertEqual(response.unitOfWorkReceipt?.rollbackBehavior, AppUnitOfWorkReceipt.rollbackOnThrownError)
            XCTAssertEqual(response.unitOfWorkReceipt?.sideEffectPolicy, AppUnitOfWorkReceipt.noExternalSideEffects)
            XCTAssertEqual(response.unitOfWorkReceipt?.didCommitChanges, true)
            XCTAssertEqual(goal.title, title)
            XCTAssertEqual(goal.mode, expectedMode)
            XCTAssertGreaterThanOrEqual(goal.plan?.sections.count ?? 0, 2)
            XCTAssertNotEqual(goal.plan?.sections.first?.title, "Initial micro-plan")
            XCTAssertFalse(steps.isEmpty)
            XCTAssertEqual(Set(steps.map(\.title)).count, steps.count)
            XCTAssertEqual(draft.plannedGoalID, goal.id)
            XCTAssertEqual(draft.latestResultKind, expectedKind)
            XCTAssertEqual(draft.stagedPlan?.evaluation, response.planningEvaluation)
            XCTAssertNotNil(draft.metadata?.understanding)
            XCTAssertEqual(draft.metadata?.understanding.mode.goalMode, expectedMode)
        }
    }

    func testCreatedGoalAppearsInGoalsOverviewWithInitialNextStep() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedGoalsService(repositories: repositories)

        _ = try await service.createGoal(
            CreateGoalRequest(title: "Ship the native create goal flow"),
            now: fixedNow
        )

        let overview = try await service.loadOverview()
        let createdItem = try XCTUnwrap(overview.items.first(where: { $0.title == "Ship the native create goal flow" }))

        XCTAssertTrue([GoalRenderState.active, .starter].contains(createdItem.renderState))
        XCTAssertFalse(createdItem.nextStepHint.isEmpty)
        XCTAssertEqual(createdItem.statusLabel, createdItem.renderState.title)
        XCTAssertEqual(createdItem.target.goalID?.hasPrefix("goal-"), true)
        XCTAssertEqual(createdItem.target.draftID?.hasPrefix("draft-"), true)
    }

    func testCreateGoalPersistsClarificationAsDraftOnly() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedGoalsService(repositories: repositories)

        let response = try await service.createGoal(
            CreateGoalRequest(title: "I don't know where to start"),
            now: fixedNow
        )

        XCTAssertEqual(response.resultKind, .clarificationRequired)
        XCTAssertNil(response.target.goalID)

        let draftID = try XCTUnwrap(response.target.draftID)
        let maybeStoredDraft = try await repositories.drafts.draft(id: draftID)
        let storedDraft = try XCTUnwrap(maybeStoredDraft)
        let goals = try await repositories.goals.listGoals()

        XCTAssertEqual(response.unitOfWorkReceipt?.writeScope, .localSwiftDataSingleContext)
        XCTAssertEqual(response.unitOfWorkReceipt?.didCommitChanges, true)
        XCTAssertEqual(storedDraft.latestResultKind, .clarificationRequired)
        XCTAssertNil(storedDraft.plannedGoalID)
        XCTAssertEqual(storedDraft.clarification?.analysis.decision, .mustClarifyBeforeCompile)
        XCTAssertEqual(storedDraft.metadata?.understanding.readiness.decision, .mustClarifyBeforeCompile)
        XCTAssertTrue(goals.isEmpty)
    }

    func testPreviewExposesClarificationStateForAmbiguousGoalSetup() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedGoalsService(repositories: repositories)

        let preview = try await service.previewCreateGoal(
            CreateGoalPreviewRequest(
                title: "I don't know where to start",
                entrySource: .goalsCreate
            ),
            now: fixedNow
        )

        XCTAssertEqual(preview.resultKind, .clarificationRequired)
        XCTAssertEqual(preview.renderState, .clarification)
        XCTAssertNotNil(preview.clarification)
        XCTAssertTrue(preview.pathStages.isEmpty)
    }

    func testPreviewAddsDeadlineGuidanceForFragileDeadline() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedGoalsService(repositories: repositories)

        let preview = try await service.previewCreateGoal(
            CreateGoalPreviewRequest(
                title: "Submit my conference talk proposal by 2024-04-10",
                entrySource: .goalsCreate
            ),
            now: fixedNow
        )

        XCTAssertNotNil(preview.feasibility)
        XCTAssertNotNil(preview.deadlineGuidance)
        XCTAssertFalse(preview.paceOptions.isEmpty)
    }

    func testServiceCreatesConservativeLifeGraphOnlyForClearSignals() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedGoalsService(repositories: repositories)

        let careerResponse = try await service.createGoal(
            CreateGoalRequest(title: "Become an astronaut"),
            now: fixedNow
        )
        let vagueResponse = try await service.createGoal(
            CreateGoalRequest(title: "Do better"),
            now: fixedNow
        )

        let careerGoalID = try XCTUnwrap(careerResponse.target.goalID)
        let vagueDraftID = try XCTUnwrap(vagueResponse.target.draftID)
        let storedCareerGoal = try await repositories.goals.goal(id: careerGoalID)
        let storedVagueDraft = try await repositories.drafts.draft(id: vagueDraftID)
        let careerGoal = try XCTUnwrap(storedCareerGoal)
        let vagueDraft = try XCTUnwrap(storedVagueDraft)

        XCTAssertEqual(careerGoal.lifeGraph?.domains.map(\.domain), [.career])
        XCTAssertEqual(careerGoal.lifeGraph?.path?.kind, .careerTrack)
        XCTAssertEqual(careerGoal.lifeGraph?.stages.map(\.id), ["foundation", "qualification", "application"])
        XCTAssertEqual(careerGoal.lifeGraph?.prerequisites.map(\.id), ["qualification-needs-foundation", "application-needs-experience"])
        XCTAssertNil(vagueDraft.draft.lifeGraph)
    }

    func testServiceKeepsGenericCareerSignalsConservative() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedGoalsService(repositories: repositories)

        let response = try await service.createGoal(
            CreateGoalRequest(title: "Get a better job"),
            now: fixedNow
        )

        let goalID = try XCTUnwrap(response.target.goalID)
        let storedGoal = try await repositories.goals.goal(id: goalID)
        let goal = try XCTUnwrap(storedGoal)

        XCTAssertEqual(goal.lifeGraph?.path?.kind, .careerTrack)
        XCTAssertTrue(goal.lifeGraph?.stages.isEmpty ?? true)
        XCTAssertTrue(goal.lifeGraph?.prerequisites.isEmpty ?? true)
    }

    func testServiceAddsMinimalEducationStagesOnlyForExplicitPrograms() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedGoalsService(repositories: repositories)

        let response = try await service.createGoal(
            CreateGoalRequest(title: "Finish my certification"),
            now: fixedNow
        )

        let goalID = try XCTUnwrap(response.target.goalID)
        let storedGoal = try await repositories.goals.goal(id: goalID)
        let goal = try XCTUnwrap(storedGoal)

        XCTAssertEqual(goal.lifeGraph?.domains.map(\.domain), [.education])
        XCTAssertEqual(goal.lifeGraph?.stages.map(\.id), ["preparation", "coursework", "completion"])
        XCTAssertEqual(goal.lifeGraph?.prerequisites.map(\.id), ["coursework-needs-prep", "completion-needs-coursework"])
    }

    func testServiceRejectsEmptyTitle() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedGoalsService(repositories: repositories)

        await XCTAssertThrowsErrorAsync(try await service.createGoal(CreateGoalRequest(title: "   "), now: fixedNow)) { error in
            XCTAssertEqual((error as? LocalizedError)?.errorDescription, "A goal title is required before a native plan can be created.")
        }
    }

    func testAtomicGoalCreationRollsBackGoalWhenDraftWriteFailsBeforeSave() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(
            store: store,
            unitOfWork: SwiftDataGoalCreationUnitOfWork(
                store: store,
                failureInjection: .afterGoalWriteBeforeDraftWrite
            )
        )
        let service = RepositoryBackedGoalsService(repositories: repositories)

        await XCTAssertThrowsErrorAsync(
            try await service.createGoal(
                CreateGoalRequest(title: "Launch a rollback-safe experiment"),
                now: fixedNow
            )
        ) { error in
            XCTAssertEqual(error as? GoalCreationUnitOfWorkProbeError, .afterGoalWriteBeforeDraftWrite)
        }

        let goals = try await repositories.goals.listGoals()
        let drafts = try await repositories.drafts.listDrafts()
        let steps = try await repositories.goals.listActionableSteps()

        XCTAssertTrue(goals.isEmpty)
        XCTAssertTrue(drafts.isEmpty)
        XCTAssertTrue(steps.isEmpty)
    }

    func testClarificationMaterializationPersistsGoalAndDraftThroughUnitOfWork() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedGoalsService(repositories: repositories)

        let createResponse = try await service.createGoal(
            CreateGoalRequest(title: "Do better"),
            now: fixedNow
        )
        let draftID = try XCTUnwrap(createResponse.target.draftID)
        let originalDraftResult = try await repositories.drafts.draft(id: draftID)
        let originalDraft = try XCTUnwrap(originalDraftResult)
        let question = try XCTUnwrap(originalDraft.clarification?.questions.first)

        let response = try await service.submitClarificationAnswer(
            GoalClarificationAnswerRequest(
                target: GoalRouteTarget(draftID: draftID),
                questionID: question.id,
                field: question.field,
                answer: "Improve my weekly study consistency for the certification."
            ),
            now: fixedNow.addingTimeInterval(60)
        )

        let updatedDraftResult = try await repositories.drafts.draft(id: draftID)
        let updatedDraft = try XCTUnwrap(updatedDraftResult)
        let goalID = try XCTUnwrap(updatedDraft.plannedGoalID)
        let goalResult = try await repositories.goals.goal(id: goalID)
        let goal = try XCTUnwrap(goalResult)

        XCTAssertEqual(response.unitOfWorkReceipt?.writeScope, .localSwiftDataSingleContext)
        XCTAssertEqual(response.unitOfWorkReceipt?.didCommitChanges, true)
        XCTAssertEqual(response.unitOfWorkReceipt?.rollbackBehavior, AppUnitOfWorkReceipt.rollbackOnThrownError)
        XCTAssertEqual(response.unitOfWorkReceipt?.sideEffectPolicy, AppUnitOfWorkReceipt.noExternalSideEffects)
        XCTAssertTrue([.planned, .starterPlanned].contains(updatedDraft.latestResultKind))
        XCTAssertEqual(goal.id, goalID)
        XCTAssertFalse(goal.plan?.sections.isEmpty ?? true)
    }

    func testAtomicClarificationMaterializationRollsBackGoalAndKeepsOriginalDraftWhenGoalWriteFailsBeforeSave() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let setupRepositories = makeRepositories(
            store: store,
            unitOfWork: SwiftDataGoalCreationUnitOfWork(store: store)
        )
        let setupService = RepositoryBackedGoalsService(repositories: setupRepositories)

        let createResponse = try await setupService.createGoal(
            CreateGoalRequest(title: "Do better"),
            now: fixedNow
        )
        let draftID = try XCTUnwrap(createResponse.target.draftID)
        let originalDraftResult = try await setupRepositories.drafts.draft(id: draftID)
        let originalDraft = try XCTUnwrap(originalDraftResult)
        let question = try XCTUnwrap(originalDraft.clarification?.questions.first)
        let originalGoals = try await setupRepositories.goals.listGoals()
        let originalSteps = try await setupRepositories.goals.listActionableSteps()

        let failingRepositories = makeRepositories(
            store: store,
            unitOfWork: SwiftDataGoalCreationUnitOfWork(
                store: store,
                failureInjection: .afterGoalWriteBeforeDraftWrite
            )
        )
        let failingService = RepositoryBackedGoalsService(repositories: failingRepositories)

        await XCTAssertThrowsErrorAsync(
            try await failingService.submitClarificationAnswer(
                GoalClarificationAnswerRequest(
                    target: GoalRouteTarget(draftID: draftID),
                    questionID: question.id,
                    field: question.field,
                    answer: "Improve my weekly study consistency for the certification."
                ),
                now: fixedNow.addingTimeInterval(60)
            )
        ) { error in
            XCTAssertEqual(error as? GoalCreationUnitOfWorkProbeError, .afterGoalWriteBeforeDraftWrite)
        }

        let goals = try await failingRepositories.goals.listGoals()
        let storedDraftResult = try await failingRepositories.drafts.draft(id: draftID)
        let storedDraft = try XCTUnwrap(storedDraftResult)
        let steps = try await failingRepositories.goals.listActionableSteps()

        XCTAssertEqual(goals, originalGoals)
        XCTAssertEqual(steps, originalSteps)
        XCTAssertEqual(storedDraft.latestResultKind, originalDraft.latestResultKind)
        XCTAssertEqual(storedDraft.plannedGoalID, originalDraft.plannedGoalID)
        XCTAssertEqual(storedDraft.metadata?.context.clarifiedFields, originalDraft.metadata?.context.clarifiedFields)
    }
}

private extension GoalCreationServiceTests {
    var fixedNow: Date {
        Date(timeIntervalSince1970: 1_712_692_800)
    }

    func makeRepositories() async throws -> AppRepositories {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        return makeRepositories(
            store: store,
            unitOfWork: SwiftDataGoalCreationUnitOfWork(store: store)
        )
    }

    func makeRepositories(
        store: AmbitionsPersistenceStore,
        unitOfWork: SwiftDataGoalCreationUnitOfWork
    ) -> AppRepositories {
        return AppRepositories(
            goals: SwiftDataGoalRepository(store: store),
            drafts: SwiftDataGoalDraftRepository(store: store),
            evidence: SwiftDataProgressEvidenceRepository(store: store),
            feedback: SwiftDataFeedbackEventRepository(store: store),
            captures: SwiftDataCaptureRepository(store: store),
            goalCreationUnitOfWork: unitOfWork,
            appState: SwiftDataAppStateRepository(store: store)
        )
    }

    func XCTAssertThrowsErrorAsync<T>(
        _ expression: @autoclosure () async throws -> T,
        _ errorHandler: (Error) -> Void
    ) async {
        do {
            _ = try await expression()
            XCTFail("Expected error to be thrown.")
        } catch {
            errorHandler(error)
        }
    }
}
