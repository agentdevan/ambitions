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

    func testServiceCreatesGoalAndThreeStepsForExampleGoals() async throws {
        let examples: [(title: String, expectedMode: GoalMode)] = [
            ("Learn SwiftUI layout", .learning),
            ("Research local climbing gyms", .exploration),
            ("Keep the apartment clean", .maintenance),
            ("Ship the native goal intake", .project),
            ("Plan a freelance pivot", .project)
        ]

        let repositories = try await makeRepositories()
        let service = RepositoryBackedGoalsService(repositories: repositories)

        for example in examples {
            let response = try await service.createGoal(CreateGoalRequest(title: example.title), now: fixedNow)
            let goal = try await XCTUnwrap(repositories.goals.goal(id: try XCTUnwrap(response.target.goalID)))
            let draft = try await XCTUnwrap(repositories.drafts.draft(id: try XCTUnwrap(response.target.draftID)))
            let steps = try await repositories.goals.listSteps(goalID: goal.id)

            XCTAssertEqual(response.blueprint.title, example.title)
            XCTAssertEqual(response.blueprint.mode, example.expectedMode)
            XCTAssertEqual(goal.title, example.title)
            XCTAssertEqual(goal.mode, example.expectedMode)
            XCTAssertEqual(goal.plan?.sections.count, 1)
            XCTAssertEqual(goal.plan?.sections.first?.title, "Initial micro-plan")
            XCTAssertEqual(steps.count, 3)
            XCTAssertEqual(steps.map(\.title).count, 3)
            XCTAssertEqual(Set(steps.map(\.title)).count, 3)
            XCTAssertEqual(draft.plannedGoalID, goal.id)
            XCTAssertEqual(draft.latestResultKind, .planned)
            XCTAssertEqual(draft.stagedPlan?.sections.first?.steps.count, 3)
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

        XCTAssertEqual(createdItem.renderState, .active)
        XCTAssertEqual(createdItem.nextStepHint, "Define scope")
        XCTAssertEqual(createdItem.statusLabel, "In motion")
        XCTAssertEqual(createdItem.target.goalID?.hasPrefix("goal-"), true)
        XCTAssertEqual(createdItem.target.draftID?.hasPrefix("draft-"), true)
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
