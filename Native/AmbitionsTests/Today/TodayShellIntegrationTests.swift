import XCTest
@testable import Ambitions

final class TodayShellIntegrationTests: XCTestCase {
    func testTodayHeroAndSupportShareCompactRuntimeBackedShellSummaryWithoutChangingActionPosture() async throws {
        let directRepositories = try await makeRepositories()
        let runtimeRepositories = try await makeRepositories()

        let directGoalsService = RepositoryBackedGoalsService(repositories: directRepositories)
        let runtimeGoalsService = RepositoryBackedGoalsService(repositories: runtimeRepositories)

        _ = try await directGoalsService.createGoal(
            CreateGoalRequest(title: "Submit my conference talk proposal by 2026-05-15"),
            now: fixedNow
        )
        let runtimeCreated = try await runtimeGoalsService.createGoal(
            CreateGoalRequest(title: "Submit my conference talk proposal by 2026-05-15"),
            now: fixedNow
        )

        let directToday = RepositoryBackedTodayService(repositories: directRepositories)
        let runtimeIntelligence = RepositoryBackedRuntimeGoalIntelligenceService(repositories: runtimeRepositories)
        let runtimeToday = RepositoryBackedTodayService(
            repositories: runtimeRepositories,
            goalIntelligenceService: runtimeIntelligence
        )

        let directExperience = try await directToday.loadTodayExperience(
            userDisplayName: "Sample User",
            now: fixedNow
        )
        let runtimeExperience = try await runtimeToday.loadTodayExperience(
            userDisplayName: "Sample User",
            now: fixedNow
        )

        XCTAssertEqual(runtimeExperience.support.fixedCommitments.items.map(\.title), directExperience.support.fixedCommitments.items.map(\.title))
        XCTAssertEqual(runtimeExperience.support.fixedCommitments.items.map(\.label), directExperience.support.fixedCommitments.items.map(\.label))

        let targetSummary = try XCTUnwrap(runtimeExperience.hero.truth.shellSummary)
        XCTAssertTrue(targetSummary.indicators.contains(where: { $0.kind == .freshness }))

        let focusSummary = try XCTUnwrap(runtimeExperience.hero.truth.shellSummary)
        XCTAssertEqual(
            runtimeExperience.hero.primaryAction.supportingActions.map(\.kind),
            directExperience.hero.primaryAction.supportingActions.map(\.kind)
        )
        XCTAssertTrue(([runtimeExperience.hero.primaryAction.action] + runtimeExperience.hero.primaryAction.supportingActions).contains(where: { $0.kind == .openDetail }))
        XCTAssertEqual(focusSummary, targetSummary)

        let goalID = try XCTUnwrap(runtimeCreated.target.goalID)
        let storedGoal = try await runtimeRepositories.goals.goal(id: goalID)
        let goal = try XCTUnwrap(storedGoal)
        let step = try XCTUnwrap(goal.plan?.sections.first?.steps.first)
        let runtimeContext = try await runtimeIntelligence.loadContext(
            RuntimeGoalIntelligenceRequest(
                target: runtimeCreated.target,
                primaryStepID: step.id,
                includeWhyNow: true
            ),
            now: fixedNow
        )
        let expectedSummary = GoalShellSummaryProjector().makeState(from: try XCTUnwrap(runtimeContext))

        XCTAssertEqual(targetSummary, expectedSummary)
        XCTAssertEqual(focusSummary, expectedSummary)
    }
}

private extension TodayShellIntegrationTests {
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
}
