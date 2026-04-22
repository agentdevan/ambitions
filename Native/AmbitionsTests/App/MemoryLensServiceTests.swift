import XCTest
@testable import Ambitions

final class MemoryLensServiceTests: XCTestCase {
    func testSearchReturnsGoalAndCaptureMatchesFromShippedRepositories() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let goal = try XCTUnwrap(goalFromFixture(id: "clear-timed-self-goal"))
        try await repositories.goals.saveGoals([goal])
        try await repositories.captures.saveCaptures([
            Capture(
                id: "capture-1",
                createdAt: "2026-04-20T10:00:00Z",
                updatedAt: "2026-04-20T10:00:00Z",
                rawText: "Review conference proposal notes",
                sourceType: nil,
                status: .actionable,
                linkedGoalID: nil
            )
        ])
        let service = DefaultMemoryLensService(repositories: repositories)

        let results = await service.search(query: goal.title, seedIntent: .openGoal)

        XCTAssertFalse(results.isEmpty)
        XCTAssertEqual(results.first?.kind, .goal)
        XCTAssertTrue(results.contains(where: { $0.kind == .goal && $0.title == goal.title }))
    }

    func testSearchPrioritizesWeekForOpenWeekIntent() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let service = DefaultMemoryLensService(repositories: repositories)

        let results = await service.search(query: "", seedIntent: .openWeek)

        XCTAssertEqual(results.first?.kind, .week)
        XCTAssertEqual(results.first?.destination, .tab(.plan))
    }
}

private extension MemoryLensServiceTests {
    func makeRepositories(store: AmbitionsPersistenceStore) -> AppRepositories {
        AppRepositories(
            goals: SwiftDataGoalRepository(store: store),
            drafts: SwiftDataGoalDraftRepository(store: store),
            evidence: SwiftDataProgressEvidenceRepository(store: store),
            feedback: SwiftDataFeedbackEventRepository(store: store),
            captures: SwiftDataCaptureRepository(store: store),
            teaching: SwiftDataGoalTeachingSignalRepository(store: store),
            appState: SwiftDataAppStateRepository(store: store)
        )
    }

    func goalFromFixture(id: String) -> Goal? {
        guard let fixture = GoalEngineFixtures.fixture(id: id) else {
            return nil
        }

        switch fixture.result {
        case let .planned(result):
            return Goal(
                schemaVersion: goalEngineSchemaVersion,
                id: result.plan.goalID,
                revision: 1,
                createdAt: GoalEngineFixtures.fixedNow,
                updatedAt: GoalEngineFixtures.fixedNow,
                state: .active,
                title: result.draft.title,
                summary: result.draft.summary,
                mode: result.draft.mode,
                relationshipKind: result.draft.relationshipKind,
                actor: result.draft.actor,
                parentGoalID: result.draft.parentGoalID,
                childGoalIDs: [],
                supportGoalIDs: [],
                tags: result.draft.tags,
                timing: result.draft.timing,
                planningStrategy: result.draft.planningStrategy,
                progressStrategy: result.draft.progressStrategy,
                plan: result.plan
            )
        case let .starterPlanned(result):
            return Goal(
                schemaVersion: goalEngineSchemaVersion,
                id: result.plan.goalID,
                revision: 1,
                createdAt: GoalEngineFixtures.fixedNow,
                updatedAt: GoalEngineFixtures.fixedNow,
                state: .active,
                title: result.draft.title,
                summary: result.draft.summary,
                mode: result.draft.mode,
                relationshipKind: result.draft.relationshipKind,
                actor: result.draft.actor,
                parentGoalID: result.draft.parentGoalID,
                childGoalIDs: [],
                supportGoalIDs: [],
                tags: result.draft.tags,
                timing: result.draft.timing,
                planningStrategy: result.draft.planningStrategy,
                progressStrategy: result.draft.progressStrategy,
                plan: result.plan
            )
        case .clarificationRequired, .blocked:
            return nil
        }
    }
}
