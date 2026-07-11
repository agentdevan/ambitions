import Foundation

protocol TodayDurableGoalStepActionPreparing: Sendable {
    func prepareDurableGoalStepAction(_ action: TodayInlineAction, now: Date) async throws -> PreparedTodayGoalStepAction
}

extension RepositoryBackedTodayService: TodayDurableGoalStepActionPreparing {
    func prepareDurableGoalStepAction(
        _ action: TodayInlineAction,
        now: Date
    ) async throws -> PreparedTodayGoalStepAction {
        guard Self.durableGoalStepActionKinds.contains(action.kind),
              let goalID = action.target.goalID,
              let stepID = action.target.stepID else {
            throw TodayDurableActionError.unavailable
        }
        guard let goal = try await repositories.goals.goal(id: goalID),
              let step = goal.plan?.sections.flatMap(\.steps).first(where: { $0.id == stepID }) else {
            throw TodayDurableActionError.unavailable
        }
        let history = try await repositories.feedback.listEvents(goalID: goalID)
        let drafts = try await repositories.drafts.listDrafts()
        let draft = drafts.first(where: { $0.plannedGoalID == goalID })
        let decision = rescheduleDecision(for: action.kind, goal: goal, step: step, history: history, now: now)
        let adjustment = adjustmentPayload(draft: draft, goal: goal, step: step, history: history)
        let contextualSmallerSummary = adjustment.flatMap { smallerSummary(from: $0.recommendation, step: step) }
            ?? decision?.smallerStep?.summary
        let context = decision.map {
            TodayGoalStepActionContext(
                timingAdjustment: $0.timingAdjustment,
                suggestedTime: $0.suggestedTime,
                recoverySummary: $0.recoverySummary,
                smallerStepSummary: contextualSmallerSummary,
                rationale: $0.rationale,
                indicatesDeferral: $0.deferRecommendation.indicatesDeferral
            )
        }
        return try await TodayGoalStepActionPlanner(repositories: repositories).prepare(
            TodayGoalStepActionRequest(
                kind: action.kind.rawValue,
                title: action.title,
                goalID: goalID,
                stepID: stepID,
                context: context
            ),
            now: now
        )
    }

    static let durableGoalStepActionKinds: Set<TodayActionKind> = [
        .complete, .defer, .reschedule, .markNotRelevant, .split, .askForHelp,
    ]
}

enum TodayDurableActionError: Error { case unavailable, needsRecovery }
