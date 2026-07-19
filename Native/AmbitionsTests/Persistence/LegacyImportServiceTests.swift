import XCTest
@testable import Ambitions

final class LegacyImportServiceTests: XCTestCase {
    func testImportMapsLearningGoalIntoUntimedLearningDraftAndGoal() async throws {
        let repositories = try await makeRepositories()
        let service = LegacyImportService(goals: repositories.goals, drafts: repositories.drafts, appState: repositories.appState)

        let snapshot = LegacyPrototypeSnapshot(
            goals: [
                LegacyGoalRecord(
                    id: "legacy-learning",
                    createdAt: GoalEngineFixtures.fixedNow,
                    updatedAt: GoalEngineFixtures.fixedNow,
                    title: "Learn conversational Spanish",
                    summary: "Prototype goal",
                    goalType: .outcome,
                    goalStatus: .active,
                    parentGoalID: nil,
                    startDate: "2026-04-14",
                    targetDate: nil,
                    tags: ["learning"],
                    metadata: ["executionOwnership": "self"]
                )
            ],
            tasks: [
                LegacyTaskRecord(id: "legacy-task-1", goalID: "legacy-learning", parentTaskID: nil, title: "Complete the first conversation drill", summary: nil, status: .ready, targetDate: nil, scheduledDate: nil, earliestStartAt: "2026-04-16T18:00:00Z", latestFinishAt: nil, completedAt: nil, isRecurringTemplate: false)
            ],
            milestones: [],
            appState: nil
        )

        let report = try await service.importSnapshot(snapshot)
        let importedGoal = try await repositories.goals.goal(id: "legacy-learning")
        let importedDraft = try await repositories.drafts.draft(id: "imported-draft-legacy-learning")

        XCTAssertEqual(report.summary.importedGoalCount, 1)
        XCTAssertEqual(importedGoal?.mode, .learning)
        XCTAssertEqual(importedGoal?.timing.tempo, .untimed)
        XCTAssertEqual(importedDraft?.draft.mode, .learning)
    }

    func testImportMapsSupportOwnershipAndParentRelationship() async throws {
        let repositories = try await makeRepositories()
        let service = LegacyImportService(goals: repositories.goals, drafts: repositories.drafts, appState: repositories.appState)

        let snapshot = LegacyPrototypeSnapshot(
            goals: [
                LegacyGoalRecord(
                    id: "legacy-support",
                    createdAt: GoalEngineFixtures.fixedNow,
                    updatedAt: GoalEngineFixtures.fixedNow,
                    title: "Support Maya's science project",
                    summary: "Prototype support goal",
                    goalType: .project,
                    goalStatus: .active,
                    parentGoalID: "family-learning",
                    startDate: "2026-04-14",
                    targetDate: nil,
                    tags: ["support"],
                    metadata: [
                        "executionOwnership": ExecutionOwnership.child.rawValue,
                        "actorDisplayName": "Maya"
                    ]
                )
            ],
            tasks: [
                LegacyTaskRecord(id: "legacy-support-task", goalID: "legacy-support", parentTaskID: nil, title: "Ask Maya what still feels unclear", summary: nil, status: .scheduled, targetDate: "2026-04-20", scheduledDate: "2026-04-18", earliestStartAt: nil, latestFinishAt: nil, completedAt: nil, isRecurringTemplate: false)
            ],
            milestones: [
                LegacyMilestoneRecord(id: "legacy-support-milestone", goalID: "legacy-support", title: "Choose the experiment angle", summary: nil, targetDate: "2026-04-22", completedAt: nil)
            ],
            appState: nil
        )

        _ = try await service.importSnapshot(snapshot)
        let importedGoal = try await repositories.goals.goal(id: "legacy-support")

        XCTAssertEqual(importedGoal?.mode, .delegatedSupport)
        XCTAssertEqual(importedGoal?.relationshipKind, .support)
        XCTAssertEqual(importedGoal?.actor.displayName, "Maya")
        XCTAssertEqual(importedGoal?.actor.ownership, .child)
        XCTAssertEqual(importedGoal?.plan?.sections.first?.title, "Milestones")
    }
}

private extension LegacyImportServiceTests {
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
