import Foundation
import XCTest
@testable import Ambitions

final class TodayViewModelTests: XCTestCase {
    func testRepositoryBackedServiceUsesNeutralGreetingForBlankName() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTodayService(repositories: repositories)

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        let now = try XCTUnwrap(formatter.date(from: "2026-04-15T13:00:00Z"))
        let experience = try await service.loadTodayExperience(userDisplayName: "   ", now: now)

        XCTAssertEqual(experience.mode, .empty)
        XCTAssertEqual(experience.header.greeting, "Good afternoon")
    }

    func testHandlePublishesTransientMessageAfterActionResponse() async {
        let expectedMessage = TodayInlineMessage(
            title: "Captured",
            body: "Progress was saved.",
            state: .success
        )
        let viewModel = TodayViewModel(state: .loaded(PreviewTodayScenarios.empty))
        let service = RecordingTodayService(experience: PreviewTodayScenarios.empty, actionResponse: TodayActionResponse(message: expectedMessage))

        await viewModel.handle(
            TodayInlineAction(
                kind: .quickLog,
                title: "Quick log",
                systemImage: "plus.bubble",
                state: .success,
                target: TodayActionTarget(goalID: "goal-1", stepID: "step-1")
            ),
            using: service,
            userDisplayName: ""
        )

        XCTAssertEqual(viewModel.transientMessage?.title, expectedMessage.title)
        XCTAssertEqual(viewModel.transientMessage?.body, expectedMessage.body)
        let actionCount = await service.performedActionCount()
        XCTAssertEqual(actionCount, 1)
    }

    func testRefreshFailureMovesStateToFailed() async {
        let viewModel = TodayViewModel()
        await viewModel.refresh(using: FailingTodayService(), userDisplayName: "")

        guard case let .failed(message) = viewModel.state else {
            return XCTFail("Expected Today refresh to end in a failed state.")
        }

        XCTAssertTrue(message.contains("Unable to load Today"))
    }
}

private extension TodayViewModelTests {
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

private actor RecordingTodayService: TodayServicing {
    let experience: TodayExperience
    let actionResponse: TodayActionResponse
    private(set) var performedActions: [TodayInlineAction] = []

    init(experience: TodayExperience, actionResponse: TodayActionResponse) {
        self.experience = experience
        self.actionResponse = actionResponse
    }

    func loadTodayExperience(userDisplayName: String, now: Date) async throws -> TodayExperience {
        _ = userDisplayName
        _ = now
        return experience
    }

    func performAction(_ action: TodayInlineAction, now: Date) async throws -> TodayActionResponse {
        _ = now
        performedActions.append(action)
        return actionResponse
    }

    func performedActionCount() -> Int {
        performedActions.count
    }
}

private struct FailingTodayService: TodayServicing {
    struct Failure: LocalizedError {
        var errorDescription: String? { "Today failed on purpose." }
    }

    func loadTodayExperience(userDisplayName: String, now: Date) async throws -> TodayExperience {
        _ = userDisplayName
        _ = now
        throw Failure()
    }

    func performAction(_ action: TodayInlineAction, now: Date) async throws -> TodayActionResponse {
        _ = action
        _ = now
        throw Failure()
    }
}
