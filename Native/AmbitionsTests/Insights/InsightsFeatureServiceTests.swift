import Foundation
import XCTest
@testable import Ambitions

final class InsightsFeatureServiceTests: XCTestCase {
    func testDashboardBuildsNarrativePostureAndGoalStatusFromExistingSignals() async throws {
        let repositories = try await makeRepositories()
        let goal = try XCTUnwrap(goalFromFixture(id: "clear-timed-self-goal"))
        let step = try XCTUnwrap(goal.plan?.sections.first?.steps.first)
        try await repositories.goals.saveGoals([goal])

        try await repositories.evidence.saveEvidence([
            ProgressEvidence(
                id: "evidence-complete",
                goalID: goal.id,
                stepID: step.id,
                evidenceKind: .stepCompleted,
                source: .manual,
                capturedAt: isoNow,
                progressDelta: 0.20,
                confidenceDelta: 0.08,
                minutesInvested: 25,
                note: "Completed"
            )
        ])
        try await repositories.feedback.saveEvents([
            .askedForSmallerVersion(
                base: GoalFeedbackEventBase(
                    id: "feedback-adjust",
                    stepID: step.id,
                    occurredAt: isoNow,
                    note: "Needed smaller version"
                )
            )
        ], goalID: goal.id)

        let dashboard = try await RepositoryBackedInsightsService(repositories: repositories).loadInsightsDashboard()

        XCTAssertEqual(dashboard.posture.label, "Adapting")
        XCTAssertFalse(dashboard.changeSummaries.isEmpty)
        XCTAssertFalse(dashboard.goalStatuses.isEmpty)
        XCTAssertEqual(dashboard.goalStatuses.first?.target?.goalID, goal.id)
    }

    func testSparseEvidenceDoesNotOverclaimGoalStatus() async throws {
        let repositories = try await makeRepositories()
        let goal = try XCTUnwrap(goalFromFixture(id: "clear-timed-self-goal"))
        try await repositories.goals.saveGoals([goal])

        let dashboard = try await RepositoryBackedInsightsService(repositories: repositories).loadInsightsDashboard()

        XCTAssertNotEqual(dashboard.goalStatuses.first?.statusLabel, "Believable")
        XCTAssertNotEqual(dashboard.goalStatuses.first?.visualState, .success)
        XCTAssertEqual(dashboard.posture.visualState, .default)
    }

    func testRecentActivitiesSortByActualTimestampInsteadOfLocalizedLabel() async throws {
        let repositories = try await makeRepositories()
        let goal = try XCTUnwrap(goalFromFixture(id: "clear-timed-self-goal"))
        let step = try XCTUnwrap(goal.plan?.sections.first?.steps.first)
        try await repositories.goals.saveGoals([goal])

        try await repositories.evidence.saveEvidence([
            ProgressEvidence(
                id: "evidence-older",
                goalID: goal.id,
                stepID: step.id,
                evidenceKind: .habitQuickLog,
                source: .manual,
                capturedAt: "2026-04-15T12:00:00Z",
                progressDelta: 0.05,
                confidenceDelta: 0.01,
                minutesInvested: 10,
                note: "Older evidence"
            ),
            ProgressEvidence(
                id: "evidence-newest",
                goalID: goal.id,
                stepID: step.id,
                evidenceKind: .stepCompleted,
                source: .manual,
                capturedAt: "2026-04-15T12:55:00Z",
                progressDelta: 0.20,
                confidenceDelta: 0.08,
                minutesInvested: 25,
                note: "Newest evidence"
            )
        ])
        try await repositories.feedback.saveEvents([
            .delayed(
                base: GoalFeedbackEventBase(
                    id: "feedback-middle",
                    stepID: step.id,
                    occurredAt: "2026-04-15T12:30:00Z",
                    note: "Middle feedback"
                ),
                timingAdjustment: .laterToday,
                date: nil
            )
        ], goalID: goal.id)

        let dashboard = try await RepositoryBackedInsightsService(repositories: repositories).loadInsightsDashboard()

        XCTAssertEqual(Array(dashboard.activities.map(\.id).prefix(3)), ["evidence-newest", "feedback-middle", "evidence-older"])
    }
}

private extension InsightsFeatureServiceTests {
    var isoNow: String {
        "2026-04-15T12:55:00Z"
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
