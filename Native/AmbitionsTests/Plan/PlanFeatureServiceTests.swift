import XCTest
@testable import Ambitions

final class PlanFeatureServiceTests: XCTestCase {
    func testEmptyRepositoriesReturnTruthfulEmptyPlan() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedPlanService(repositories: repositories)

        let dashboard = try await service.loadPlanDashboard(now: fixedDate)

        XCTAssertEqual(dashboard.mode, .empty)
        XCTAssertEqual(dashboard.emptyTitle, "No weekly plan pressure yet")
        XCTAssertTrue(dashboard.focusItems.isEmpty)
        XCTAssertTrue(dashboard.metrics.contains(where: { $0.id == "plan-routines" && $0.value == "0" }))
    }

    func testActiveGoalsProduceWeeklyFocusRows() async throws {
        let repositories = try await makeRepositories()
        let goalsService = RepositoryBackedGoalsService(repositories: repositories)
        _ = try await goalsService.createGoal(
            CreateGoalRequest(title: "Submit my conference talk proposal by 2026-05-15"),
            now: fixedDate
        )
        let service = RepositoryBackedPlanService(repositories: repositories)

        let dashboard = try await service.loadPlanDashboard(now: fixedDate)

        XCTAssertEqual(dashboard.mode, .active)
        XCTAssertFalse(dashboard.focusItems.isEmpty)
        XCTAssertTrue(dashboard.focusItems.allSatisfy { $0.target?.goalID != nil })
        XCTAssertTrue(dashboard.metrics.contains(where: { $0.id == "plan-week-work" && $0.value != "0" }))
    }

    func testBlockedDraftsAndOpenCapturesSurfacePlanningPressure() async throws {
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
        try await DefaultCaptureService(repository: repositories.captures).createCapture(
            CreateCaptureRequest(rawText: "Clarify the weekly commitment", sourceType: .todayQuickCapture),
            now: fixedDate
        )
        let service = RepositoryBackedPlanService(repositories: repositories)

        let dashboard = try await service.loadPlanDashboard(now: fixedDate)

        XCTAssertEqual(dashboard.posture.visualState, .warning)
        XCTAssertTrue(dashboard.pressureItems.contains(where: { $0.id == "plan-pressure-captures" && $0.valueLabel == "1" }))
        XCTAssertTrue(dashboard.pressureItems.contains(where: { $0.id == "plan-pressure-clarity" && $0.valueLabel != "0" }))
        XCTAssertTrue(dashboard.metrics.contains(where: { $0.id == "plan-pressure" && $0.value != "0" }))
    }

    func testHabitLikeGoalsRemainRepresentedUnderPlan() async throws {
        #if DEBUG
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = try await AppContainerFactory.prepareRepositories(for: .demo, store: store)
        let service = RepositoryBackedPlanService(repositories: repositories)

        let dashboard = try await service.loadPlanDashboard(now: fixedDate)

        XCTAssertTrue(dashboard.metrics.contains(where: { $0.id == "plan-routines" && $0.value != "0" }))
        XCTAssertEqual(dashboard.secondaryDestinations.map(\.id), ["plan-habits"])
        #else
        throw XCTSkip("Demo bootstrap fixtures are only available in DEBUG builds.")
        #endif
    }
}

private extension PlanFeatureServiceTests {
    var fixedDate: Date {
        ISO8601DateFormatter().date(from: GoalEngineFixtures.fixedNow) ?? Date(timeIntervalSince1970: 1_712_692_800)
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
