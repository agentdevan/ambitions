import XCTest
@testable import Ambitions

final class ExternalSurfaceSnapshotTests: XCTestCase {
    func testSnapshotGenerationSelectsNextActionAndRedactsUserEnteredTitles() throws {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        let now = try XCTUnwrap(formatter.date(from: "2026-04-15T12:00:00Z"))
        let sensitiveStepTitle = "Private Therapy Session"
        let goal = makeGoal(
            goalID: "goal-sensitive",
            goalTitle: "Very Personal Goal",
            stepID: "step-sensitive",
            stepTitle: sensitiveStepTitle,
            dueAt: "2026-04-16T09:00:00Z"
        )
        let builder = ExternalSurfaceSnapshotBuilder()

        let snapshot = builder.makeSnapshot(goals: [goal], now: now)
        let json = try XCTUnwrap(String(data: PersistenceCoding.encode(snapshot), encoding: .utf8))

        XCTAssertEqual(snapshot.schemaVersion, ExternalSurfaceSnapshot.schemaVersion)
        XCTAssertEqual(snapshot.nextAction?.goalID, "goal-sensitive")
        XCTAssertEqual(snapshot.nextAction?.stepID, "step-sensitive")
        XCTAssertEqual(snapshot.nextAction?.display.templateKey, "next_tiny_step")
        XCTAssertEqual(snapshot.nextAction?.display.urgency, .soon)
        XCTAssertFalse(json.contains(sensitiveStepTitle))
        XCTAssertFalse(json.contains("Very Personal Goal"))
    }

    func testSnapshotSerializationRoundTrips() throws {
        let snapshot = ExternalSurfaceSnapshot(
            generatedAt: "2026-04-15T12:00:00Z",
            nextAction: ExternalSurfaceNextAction(
                goalID: "goal-1",
                stepID: "step-1",
                display: ExternalSurfaceDisplayMetadata(
                    templateKey: "next_tiny_step",
                    goalMode: .project,
                    stepState: .planned,
                    urgency: .normal,
                    timing: .deadline
                )
            )
        )

        let data = try PersistenceCoding.encode(snapshot)
        let decoded = try PersistenceCoding.decode(ExternalSurfaceSnapshot.self, from: data)

        XCTAssertEqual(decoded, snapshot)
    }

    func testSnapshotRefreshingDecoratorsRefreshWriterAfterTodayAndGoalsMutations() async throws {
        let writer = RecordingSnapshotWriter()
        let goalsBase = RecordingGoalsService()
        let todayBase = RecordingTodayService()
        let goalsService = SnapshotRefreshingGoalsService(base: goalsBase, snapshotWriter: writer)
        let todayService = SnapshotRefreshingTodayService(base: todayBase, snapshotWriter: writer)

        _ = try await goalsService.createGoal(CreateGoalRequest(title: "Ship export layer"), now: .now)
        _ = try await goalsService.performAction(
            GoalDetailActionRequest(
                target: GoalRouteTarget(goalID: "goal-1", draftID: "draft-1"),
                kind: .complete,
                stepID: nil
            ),
            now: .now
        )
        _ = try await goalsService.submitClarificationAnswer(
            GoalClarificationAnswerRequest(
                target: GoalRouteTarget(goalID: "goal-1", draftID: "draft-1"),
                questionID: "q1",
                field: .successDefinition,
                answer: "Clear scope and ship v1."
            ),
            now: .now
        )
        _ = try await todayService.performAction(
            TodayInlineAction(
                kind: .complete,
                title: "Done",
                systemImage: "checkmark",
                state: .success,
                target: TodayActionTarget(goalID: "goal-1", stepID: "step-1")
            ),
            now: .now
        )

        let refreshCount = await writer.refreshCount
        XCTAssertEqual(refreshCount, 4)
    }
}

private extension ExternalSurfaceSnapshotTests {
    func makeGoal(
        goalID: String,
        goalTitle: String,
        stepID: String,
        stepTitle: String,
        dueAt: String
    ) -> Goal {
        let actor = GoalActor(actorID: "self", displayName: "Self", ownership: .self, roleLabel: nil, isPrimary: true)
        let timing = GoalTiming(
            tempo: .deadlineBased,
            timingType: .dueAt,
            startsOn: nil,
            dueAt: dueAt,
            targetBy: nil,
            windowStart: nil,
            windowEnd: nil,
            suggestedNextAt: nil,
            repeatEveryDays: nil,
            progressReviewCadenceDays: 7
        )
        let actionability = StepActionability(
            action: "Do it",
            completionDefinition: "Done",
            evidenceOfCompletion: ["Done"],
            fallbackMicroStep: "Start",
            contextRequirements: []
        )
        let step = Step(
            id: stepID,
            sectionID: "section-1",
            title: stepTitle,
            summary: nil,
            type: .actionUnit,
            state: .planned,
            owner: actor,
            timing: timing,
            dependencyStepIDs: [],
            isOptional: false,
            isRepeatable: false,
            evidenceRequired: true,
            successSignals: [],
            actionability: actionability
        )
        let section = PlanSection(
            id: "section-1",
            goalID: goalID,
            title: "Main",
            summary: nil,
            kind: .activeSteps,
            orderIndex: 0,
            steps: [step]
        )
        let plan = GoalPlan(
            id: "plan-1",
            goalID: goalID,
            version: 1,
            generatedAt: "2026-04-15T10:00:00Z",
            summary: "Test plan",
            strategy: PlanningStrategy(
                strategyKind: .sequential,
                allowParallelSteps: false,
                maxActiveSteps: 3,
                preferredSectionOrder: [.overview, .activeSteps, .review],
                defaultStepType: .actionUnit,
                autoGenerateReviewSection: true,
                preferShortSteps: true,
                revisitCadenceDays: 7
            ),
            sections: [section],
            assumptions: [],
            lint: PlanLintResult(goalID: goalID, planVersion: 1, isValid: true, issueCount: 0, issues: [])
        )

        return Goal(
            schemaVersion: goalEngineSchemaVersion,
            id: goalID,
            revision: 1,
            createdAt: "2026-04-15T10:00:00Z",
            updatedAt: "2026-04-15T10:00:00Z",
            state: .active,
            title: goalTitle,
            summary: "Sensitive summary",
            mode: .project,
            relationshipKind: .independent,
            actor: actor,
            parentGoalID: nil,
            childGoalIDs: [],
            supportGoalIDs: [],
            tags: [],
            timing: timing,
            planningStrategy: PlanningStrategy(
                strategyKind: .sequential,
                allowParallelSteps: false,
                maxActiveSteps: 3,
                preferredSectionOrder: [.overview, .activeSteps, .review],
                defaultStepType: .actionUnit,
                autoGenerateReviewSection: true,
                preferShortSteps: true,
                revisitCadenceDays: 7
            ),
            progressStrategy: ProgressStrategy(
                metricKind: .stepCompletion,
                rollupMethod: .ratio,
                targetStepCount: 3,
                targetEvidenceCount: nil,
                targetMinutes: nil,
                supportsUntimedProgress: true,
                countsChildGoals: false,
                countsSupportGoals: false
            ),
            plan: plan
        )
    }
}

private actor RecordingSnapshotWriter: ExternalSurfaceSnapshotWriting {
    private(set) var refreshCount = 0

    func refresh(now: Date) async {
        _ = now
        refreshCount += 1
    }
}

private struct RecordingTodayService: TodayServicing {
    func loadTodayExperience(userDisplayName: String, now: Date) async throws -> TodayExperience {
        _ = userDisplayName
        _ = now
        return PreviewTodayScenarios.empty
    }

    func performAction(_ action: TodayInlineAction, now: Date) async throws -> TodayActionResponse {
        _ = action
        _ = now
        return TodayActionResponse(message: nil)
    }
}

private struct RecordingGoalsService: GoalsServicing {
    func loadOverview() async throws -> GoalsOverview {
        PreviewGoalsScenarios.overview
    }

    func loadDetail(target: GoalRouteTarget) async throws -> GoalDetailPresentation {
        if let scenario = PreviewGoalsScenarios.detailScenarios[target.id] {
            return scenario
        }
        return try XCTUnwrap(PreviewGoalsScenarios.detailScenarios.values.first)
    }

    func createGoal(_ request: CreateGoalRequest, now: Date) async throws -> CreateGoalResponse {
        _ = request
        _ = now
        return CreateGoalResponse(
            target: GoalRouteTarget(goalID: "goal-1", draftID: "draft-1"),
            blueprint: GoalBlueprint(
                title: "Test goal",
                summary: nil,
                mode: .project,
                relationshipKind: .independent,
                actor: GoalActor(actorID: "self", displayName: "Self", ownership: .self, roleLabel: nil, isPrimary: true),
                parentGoalID: nil,
                tags: [],
                pace: .untimed,
                targetDate: nil,
                repeatEveryDays: nil,
                source: .manual
            )
        )
    }

    func performAction(_ request: GoalDetailActionRequest, now: Date) async throws -> GoalDetailActionResponse {
        _ = request
        _ = now
        return GoalDetailActionResponse(message: nil)
    }

    func submitClarificationAnswer(_ request: GoalClarificationAnswerRequest, now: Date) async throws -> GoalDetailActionResponse {
        _ = request
        _ = now
        return GoalDetailActionResponse(message: nil)
    }
}
