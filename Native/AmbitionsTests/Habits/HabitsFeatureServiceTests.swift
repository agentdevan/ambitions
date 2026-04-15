import XCTest
@testable import Ambitions

final class HabitsFeatureServiceTests: XCTestCase {
    func testLoadDashboardFromEmptyRepositoriesShowsEmptyMode() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedHabitsService(repositories: repositories)

        let dashboard = try await service.loadDashboard(now: .now)

        XCTAssertEqual(dashboard.mode, .empty)
        XCTAssertEqual(dashboard.emptyTitle, "No habits are live yet")
    }

    func testQuickLogAddsEvidenceAndShowsPartialStatus() async throws {
        #if DEBUG
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = try await AppContainerFactory.prepareRepositories(for: .demo, store: store)
        let service = RepositoryBackedHabitsService(repositories: repositories)
        let goal = try XCTUnwrap((try await repositories.goals.listHabitGoals()).first)
        let step = try XCTUnwrap(HabitGoalSemantics.preferredStep(in: goal))
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let now = try XCTUnwrap(formatter.date(from: GoalEngineFixtures.fixedNow))

        _ = try await service.performAction(
            HabitActionRequest(
                kind: .quickLog,
                target: HabitActionTarget(goalID: goal.id, stepID: step.id)
            ),
            now: now
        )

        let evidence = try await repositories.evidence.listEvidence(goalID: goal.id)
        let dashboard = try await service.loadDashboard(now: now)
        let loggedHabit = try XCTUnwrap((dashboard.habits + dashboard.recoveryHabits).first(where: { $0.id == goal.id }))

        XCTAssertTrue(evidence.contains(where: { $0.evidenceKind == .habitQuickLog && $0.stepID == step.id }))
        XCTAssertEqual(loggedHabit.status, .partial)
        #else
        throw XCTSkip("Demo bootstrap fixtures are only available in DEBUG builds.")
        #endif
    }
}

private extension HabitsFeatureServiceTests {
    func makeRepositories() async throws -> AppRepositories {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        return AppRepositories(
            goals: SwiftDataGoalRepository(store: store),
            drafts: SwiftDataGoalDraftRepository(store: store),
            evidence: SwiftDataProgressEvidenceRepository(store: store),
            feedback: SwiftDataFeedbackEventRepository(store: store),
            appState: SwiftDataAppStateRepository(store: store)
        )
    }
}
