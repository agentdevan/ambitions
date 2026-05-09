import Foundation

struct SnapshotRefreshingTodayService: TodayServicing {
    let base: any TodayServicing
    let snapshotWriter: any ExternalSurfaceSnapshotWriting

    func loadTodayExperience(userDisplayName: String, now: Date, entryContext: TodayEntryContext) async throws -> TodayExperience {
        try await base.loadTodayExperience(userDisplayName: userDisplayName, now: now, entryContext: entryContext)
    }

    func performAction(_ action: TodayInlineAction, now: Date) async throws -> TodayActionResponse {
        let response = try await base.performAction(action, now: now)
        await snapshotWriter.refresh(now: now)
        return response
    }
}

struct SnapshotRefreshingGoalsService: GoalsServicing, GoalCreationPreparing {
    let base: any GoalsServicing
    let snapshotWriter: any ExternalSurfaceSnapshotWriting

    func loadOverview() async throws -> GoalsOverview {
        try await base.loadOverview()
    }

    func loadDetail(target: GoalRouteTarget) async throws -> GoalDetailPresentation {
        try await base.loadDetail(target: target)
    }

    func previewCreateGoal(_ request: CreateGoalPreviewRequest, now: Date) async throws -> CreateGoalPreviewState {
        try await base.previewCreateGoal(request, now: now)
    }

    func createGoal(_ request: CreateGoalRequest, now: Date) async throws -> CreateGoalResponse {
        let response = try await base.createGoal(request, now: now)
        await snapshotWriter.refresh(now: now)
        return response
    }

    func prepareGoalCreation(_ request: CreateGoalRequest, now: Date) async throws -> PreparedGoalCreation {
        guard let base = base as? any GoalCreationPreparing else {
            throw GoalsFeatureError.notActionable
        }
        return try await base.prepareGoalCreation(request, now: now)
    }

    func didCommitPreparedGoalCreation(now: Date) async {
        await snapshotWriter.refresh(now: now)
        if let base = base as? any GoalCreationPreparing {
            await base.didCommitPreparedGoalCreation(now: now)
        }
    }

    func performAction(_ request: GoalDetailActionRequest, now: Date) async throws -> GoalDetailActionResponse {
        let response = try await base.performAction(request, now: now)
        await snapshotWriter.refresh(now: now)
        return response
    }

    func submitClarificationAnswer(_ request: GoalClarificationAnswerRequest, now: Date) async throws -> GoalDetailActionResponse {
        let response = try await base.submitClarificationAnswer(request, now: now)
        await snapshotWriter.refresh(now: now)
        return response
    }

    func submitExplainabilityCorrection(_ request: GoalExplainabilityCorrectionRequest, now: Date) async throws -> GoalDetailActionResponse {
        let response = try await base.submitExplainabilityCorrection(request, now: now)
        await snapshotWriter.refresh(now: now)
        return response
    }
}
