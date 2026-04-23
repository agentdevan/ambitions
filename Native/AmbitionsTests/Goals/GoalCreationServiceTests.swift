import XCTest
@testable import Ambitions

final class GoalCreationServiceTests: XCTestCase {
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
}

private extension GoalCreationServiceTests {
    var fixedNow: Date {
        Date(timeIntervalSince1970: 1_712_692_800)
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
