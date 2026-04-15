import XCTest
@testable import Ambitions

final class TodayFreshGoalVisibilityTests: XCTestCase {
    func testCreatedGoalAppearsInTodayTargetsAndFocus() async throws {
        let repositories = try await makeRepositories()
        let goalsService = RepositoryBackedGoalsService(repositories: repositories)
        let todayService = RepositoryBackedTodayService(repositories: repositories)

        let created = try await goalsService.createGoal(
            CreateGoalRequest(title: "Ship the native create goal flow"),
            now: fixedNow
        )
        let experience = try await todayService.loadTodayExperience(
            userDisplayName: "Sample User",
            now: fixedNow
        )

        guard case .active = experience.mode else {
            return XCTFail("Expected Today to become active once a created goal exists.")
        }
        XCTAssertFalse(experience.dailyTargets.items.isEmpty)
        XCTAssertTrue(experience.dailyTargets.items.contains(where: {
            $0.subtitle == "Ship the native create goal flow" &&
            $0.primaryAction?.target.goalID == created.target.goalID
        }))

        guard case let .planned(focus) = experience.focus else {
            return XCTFail("Expected a planned focus state for a freshly created goal.")
        }

        XCTAssertEqual(focus.subtitle, "Ship the native create goal flow")
        XCTAssertEqual(focus.title, "Define scope")
        XCTAssertTrue(focus.actions.contains(where: {
            $0.kind == .openDetail && $0.target.goalID == created.target.goalID
        }))
    }

    @MainActor
    func testTodayViewModelActivateRefreshesOnReturnToTodayTab() async {
        let first = PreviewTodayScenarios.empty
        let second = PreviewTodayScenarios.starter
        let service = MutableTodayService(experience: first)
        let viewModel = TodayViewModel()

        await viewModel.activate(using: service, userDisplayName: "Sample User", now: fixedNow)

        guard case let .loaded(initialExperience) = viewModel.state else {
            return XCTFail("Expected Today to load on first activation.")
        }
        guard case .empty = initialExperience.mode else {
            return XCTFail("Expected the first activation to use the initial empty scenario.")
        }

        await service.setExperience(second)
        await viewModel.activate(using: service, userDisplayName: "Sample User", now: fixedNow)

        guard case let .loaded(refreshedExperience) = viewModel.state else {
            return XCTFail("Expected Today to refresh when activated again.")
        }
        guard case .active = refreshedExperience.mode else {
            return XCTFail("Expected the second activation to reflect the updated active scenario.")
        }
        guard case let .starter(focus) = refreshedExperience.focus else {
            return XCTFail("Expected refreshed Today focus to use the updated scenario.")
        }
        XCTAssertEqual(focus.title, "Record one rough vocal pass")
    }
}

private extension TodayFreshGoalVisibilityTests {
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
            appState: SwiftDataAppStateRepository(store: store)
        )
    }
}

private actor MutableTodayService: TodayServicing {
    private var experience: TodayExperience

    init(experience: TodayExperience) {
        self.experience = experience
    }

    func setExperience(_ experience: TodayExperience) {
        self.experience = experience
    }

    func loadTodayExperience(userDisplayName: String, now: Date) async throws -> TodayExperience {
        _ = userDisplayName
        _ = now
        return experience
    }

    func performAction(_ action: TodayInlineAction, now: Date) async throws -> TodayActionResponse {
        _ = action
        _ = now
        return TodayActionResponse(message: nil)
    }
}
