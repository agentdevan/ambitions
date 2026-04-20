import XCTest
@testable import Ambitions

final class TodayShellIntegrationTests: XCTestCase {
    func testTodayCardsShareCompactRuntimeBackedShellSummaryWithoutChangingActionPosture() async throws {
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

        XCTAssertEqual(runtimeExperience.dailyTargets.items.map(\.title), directExperience.dailyTargets.items.map(\.title))
        XCTAssertEqual(runtimeExperience.dailyTargets.items.map(\.timingLabel), directExperience.dailyTargets.items.map(\.timingLabel))
        XCTAssertEqual(runtimeExperience.dailyTargets.items.map(\.statusLabel), directExperience.dailyTargets.items.map(\.statusLabel))

        let runtimeTarget = try XCTUnwrap(runtimeExperience.dailyTargets.items.first)
        let targetSummary = try XCTUnwrap(runtimeTarget.shellSummary)
        XCTAssertTrue(targetSummary.indicators.contains(where: { $0.kind == .freshness }))

        let focus = try unwrapPlannedFocus(runtimeExperience.focus)
        let focusSummary = try XCTUnwrap(focus.shellSummary)
        XCTAssertEqual(focus.actions.map(\.kind), try unwrapPlannedFocus(directExperience.focus).actions.map(\.kind))
        XCTAssertTrue(focus.actions.contains(where: { $0.kind == .openDetail }))
        XCTAssertNotNil(focus.energyLabel)
        XCTAssertEqual(focusSummary, targetSummary)

        let milestoneSummary = try XCTUnwrap(runtimeExperience.milestone.shellSummary)
        XCTAssertFalse(milestoneSummary.pathSummary.isEmpty)
        XCTAssertEqual(runtimeExperience.milestone.action?.kind, .openDetail)

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

    func unwrapPlannedFocus(_ focus: TodayFocusState) throws -> TodayFocusPlannedState {
        switch focus {
        case let .planned(state):
            return state
        case let .starter(state):
            throw XCTSkip("Expected planned focus, found starter focus for \(state.title).")
        case .clarification, .blocked, .empty:
            XCTFail("Expected planned focus.")
            throw NSError(domain: "TodayShellIntegrationTests", code: 1)
        }
    }
}
