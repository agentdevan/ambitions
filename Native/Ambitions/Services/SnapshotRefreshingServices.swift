import Foundation

struct SnapshotRefreshingTodayService: TodayServicing {
    let base: any TodayServicing
    let snapshotWriter: any ExternalSurfaceSnapshotWriting

    func loadTodayExperience(userDisplayName: String, now: Date) async throws -> TodayExperience {
        try await base.loadTodayExperience(userDisplayName: userDisplayName, now: now)
    }

    func performAction(_ action: TodayInlineAction, now: Date) async throws -> TodayActionResponse {
        let response = try await base.performAction(action, now: now)
        await snapshotWriter.refresh(now: now)
        return response
    }
}

struct SnapshotRefreshingGoalsService: GoalsServicing {
    let base: any GoalsServicing
    let snapshotWriter: any ExternalSurfaceSnapshotWriting

    func loadOverview() async throws -> GoalsOverview {
        try await base.loadOverview()
    }

    func loadDetail(target: GoalRouteTarget) async throws -> GoalDetailPresentation {
        try await base.loadDetail(target: target)
    }

    func createGoal(_ request: CreateGoalRequest, now: Date) async throws -> CreateGoalResponse {
        let response = try await base.createGoal(request, now: now)
        await snapshotWriter.refresh(now: now)
        return response
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
