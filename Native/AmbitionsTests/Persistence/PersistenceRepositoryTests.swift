import XCTest
@testable import Ambitions

final class PersistenceRepositoryTests: XCTestCase {
    func testGoalRepositoryRoundTripsGoalPlanAndSteps() async throws {
        let repositories = try await makeRepositories()
        let fixture = try XCTUnwrap(GoalEngineFixtures.fixture(id: "clear-timed-self-goal"))
        let goal = try XCTUnwrap(goalFromFixture(fixture))

        try await repositories.goals.saveGoals([goal])
        let loaded = try await repositories.goals.goal(id: goal.id)
        let loadedSteps = try await repositories.goals.listSteps(goalID: goal.id)

        XCTAssertEqual(loaded?.title, goal.title)
        XCTAssertEqual(loaded?.plan?.sections.count, goal.plan?.sections.count)
        XCTAssertEqual(loadedSteps.count, goal.plan?.sections.flatMap(\.steps).count)
    }

    func testDraftRepositoryPreservesStarterAndBlockedState() async throws {
        let repositories = try await makeRepositories()
        let starterFixture = try XCTUnwrap(GoalEngineFixtures.fixture(id: "exploratory-vague-goal"))
        let blockedFixture = try XCTUnwrap(GoalEngineFixtures.fixture(id: "blocked-requiring-clarification"))

        let storedDrafts = [storedDraft(id: "starter", fixture: starterFixture), storedDraft(id: "blocked", fixture: blockedFixture)].compactMap { $0 }
        try await repositories.drafts.saveDrafts(storedDrafts)

        let loaded = try await repositories.drafts.listDrafts()
        XCTAssertEqual(loaded.count, storedDrafts.count)
        XCTAssertTrue(loaded.contains(where: { $0.latestResultKind == .starterPlanned && !$0.assumptions.isEmpty }))
        XCTAssertTrue(loaded.contains(where: { $0.latestResultKind == .clarificationRequired && $0.clarification != nil }))
    }

    func testEvidenceAndFeedbackRepositoriesPersistAdaptiveHistory() async throws {
        let repositories = try await makeRepositories()
        let feedbackFixture = try XCTUnwrap(GoalEngineFixtures.feedbackFixture(id: "achievement-avoidance"))
        let goalID = feedbackFixture.input.currentResult.plan.goalID
        let evidence = ProgressEvidence(
            id: "evidence-1",
            goalID: goalID,
            stepID: feedbackFixture.input.selectedStep.id,
            evidenceKind: .sessionLogged,
            source: .manual,
            capturedAt: GoalEngineFixtures.fixedNow,
            progressDelta: 0.15,
            confidenceDelta: -0.05,
            minutesInvested: 20,
            note: "Repository round-trip"
        )

        try await repositories.evidence.saveEvidence([evidence])
        try await repositories.feedback.saveEvents(feedbackFixture.input.feedbackHistory, goalID: goalID)
        let loadedEvidence = try await repositories.evidence.listEvidence(goalID: goalID)
        let loadedFeedback = try await repositories.feedback.listEvents(goalID: goalID)

        XCTAssertEqual(loadedEvidence.first?.id, evidence.id)
        XCTAssertEqual(loadedFeedback.count, feedbackFixture.input.feedbackHistory.count)
    }

    func testAppStateRepositoryPersistsPreferencesAndBootstrapFields() async throws {
        let repositories = try await makeRepositories()
        var state = try await repositories.appState.loadState()
        state.preferredTab = .goals
        state.userDisplayName = "Storage Test"
        state.appearancePreference = .dark
        state.hasCompletedBootstrap = true
        state.lastBootstrapSource = .live
        state.lastBootstrapAt = GoalEngineFixtures.fixedNow

        try await repositories.appState.saveState(state)
        let loaded = try await repositories.appState.loadState()

        XCTAssertEqual(loaded.preferredTab, .goals)
        XCTAssertEqual(loaded.userDisplayName, "Storage Test")
        XCTAssertEqual(loaded.appearancePreference, .dark)
        XCTAssertEqual(loaded.lastBootstrapSource, .live)
    }
}

private extension PersistenceRepositoryTests {
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

    func goalFromFixture(_ fixture: GoalEngineFixture) -> Goal? {
        switch fixture.result {
        case let .planned(result):
            return Goal(schemaVersion: goalEngineSchemaVersion, id: result.plan.goalID, revision: 1, createdAt: GoalEngineFixtures.fixedNow, updatedAt: GoalEngineFixtures.fixedNow, state: .active, title: result.draft.title, summary: result.draft.summary, mode: result.draft.mode, relationshipKind: result.draft.relationshipKind, actor: result.draft.actor, parentGoalID: result.draft.parentGoalID, childGoalIDs: [], supportGoalIDs: [], tags: result.draft.tags, timing: result.draft.timing, planningStrategy: result.draft.planningStrategy, progressStrategy: result.draft.progressStrategy, plan: result.plan)
        case let .starterPlanned(result):
            return Goal(schemaVersion: goalEngineSchemaVersion, id: result.plan.goalID, revision: 1, createdAt: GoalEngineFixtures.fixedNow, updatedAt: GoalEngineFixtures.fixedNow, state: .active, title: result.draft.title, summary: result.draft.summary, mode: result.draft.mode, relationshipKind: result.draft.relationshipKind, actor: result.draft.actor, parentGoalID: result.draft.parentGoalID, childGoalIDs: [], supportGoalIDs: [], tags: result.draft.tags, timing: result.draft.timing, planningStrategy: result.draft.planningStrategy, progressStrategy: result.draft.progressStrategy, plan: result.plan)
        case .clarificationRequired, .blocked:
            return nil
        }
    }

    func storedDraft(id: String, fixture: GoalEngineFixture) -> PersistedGoalDraft? {
        switch fixture.result {
        case let .starterPlanned(result):
            return PersistedGoalDraft(id: id, createdAt: GoalEngineFixtures.fixedNow, updatedAt: GoalEngineFixtures.fixedNow, draft: result.draft, classification: nil, clarification: result.clarification, stagedPlan: result.plan, assumptions: result.assumptions, blockers: [], metadata: result.metadata, plannedGoalID: result.plan.goalID, latestResultKind: .starterPlanned)
        case let .clarificationRequired(result):
            return PersistedGoalDraft(id: id, createdAt: GoalEngineFixtures.fixedNow, updatedAt: GoalEngineFixtures.fixedNow, draft: result.draft, classification: nil, clarification: result.clarification, stagedPlan: nil, assumptions: result.metadata.reasoning.assumptions, blockers: [], metadata: result.metadata, plannedGoalID: nil, latestResultKind: .clarificationRequired)
        default:
            return nil
        }
    }
}
