import XCTest
@testable import Ambitions

final class AppContainerFactoryTests: XCTestCase {
    func testLiveBootstrapDoesNotSeedFreshRepositories() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)

        let repositories = try await AppContainerFactory.prepareRepositories(for: .live, store: store)

        let goals = try await repositories.goals.listGoals()
        let drafts = try await repositories.drafts.listDrafts()
        let evidence = try await repositories.evidence.listEvidence(goalID: nil)
        let feedback = try await repositories.feedback.listEvents(goalID: nil)
        let state = try await repositories.appState.loadState()

        XCTAssertTrue(goals.isEmpty)
        XCTAssertTrue(drafts.isEmpty)
        XCTAssertTrue(evidence.isEmpty)
        XCTAssertTrue(feedback.isEmpty)
        XCTAssertNil(state.lastSeedVersion)
        XCTAssertNil(state.lastSeededAt)
    }

    func testDemoBootstrapSeedsRepositoriesOnlyWhenExplicitlyRequested() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)

        #if DEBUG
        let repositories = try await AppContainerFactory.prepareRepositories(for: .demo, store: store)
        let goals = try await repositories.goals.listGoals()
        let drafts = try await repositories.drafts.listDrafts()
        let evidence = try await repositories.evidence.listEvidence(goalID: nil)
        let feedback = try await repositories.feedback.listEvents(goalID: nil)
        let state = try await repositories.appState.loadState()

        XCTAssertFalse(goals.isEmpty)
        XCTAssertFalse(drafts.isEmpty)
        XCTAssertFalse(evidence.isEmpty)
        XCTAssertFalse(feedback.isEmpty)
        XCTAssertEqual(state.lastSeedVersion, DemoSeedPipeline.seedVersion)
        #else
        _ = store
        throw XCTSkip("Demo bootstrap is only available in DEBUG builds.")
        #endif
    }

    func testLiveBootstrapPreservesExistingPersistedDataWithoutInjectingSeeds() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let goal = try XCTUnwrap(goalFromFixture(id: "clear-timed-self-goal"))

        try await repositories.goals.saveGoals([goal])
        try await repositories.appState.saveState(
            AppStateSnapshot(
                id: AppStateSnapshot.default.id,
                preferredTab: .goals,
                userDisplayName: "Existing User",
                reviewCadenceDays: 3,
                localOnlyModeEnabled: true,
                hasCompletedBootstrap: true,
                lastBootstrapSource: .live,
                lastBootstrapAt: GoalEngineFixtures.fixedNow,
                lastSeedVersion: nil,
                lastSeededAt: nil,
                lastImportSummary: nil,
                lastOpenedGoalID: goal.id,
                goalPriorityOrder: [goal.id]
            )
        )

        let preparedRepositories = try await AppContainerFactory.prepareRepositories(for: .live, store: store)
        let loadedGoals = try await preparedRepositories.goals.listGoals()
        let loadedState = try await preparedRepositories.appState.loadState()

        XCTAssertEqual(loadedGoals.map(\.id), [goal.id])
        XCTAssertEqual(loadedGoals.first?.title, goal.title)
        XCTAssertEqual(loadedState.userDisplayName, "Existing User")
        XCTAssertEqual(loadedState.goalPriorityOrder, [goal.id])
        XCTAssertNil(loadedState.lastSeedVersion)
    }
}

private extension AppContainerFactoryTests {
    func makeRepositories(store: AmbitionsPersistenceStore) -> AppRepositories {
        AppRepositories(
            goals: SwiftDataGoalRepository(store: store),
            drafts: SwiftDataGoalDraftRepository(store: store),
            evidence: SwiftDataProgressEvidenceRepository(store: store),
            feedback: SwiftDataFeedbackEventRepository(store: store),
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
