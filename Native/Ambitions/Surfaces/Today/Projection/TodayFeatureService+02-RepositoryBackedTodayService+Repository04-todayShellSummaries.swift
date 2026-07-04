import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedTodayService {
    func todayShellSummaries(
        goals: [Goal],
        draftsByGoalID: [String: PersistedGoalDraft],
        actionableSteps: [Step],
        now: Date
    ) async throws -> [TodayActionTarget: GoalShellSummaryState] {
        guard let goalIntelligenceService else { return [:] }

        var targets: [TodayActionTarget] = []
        var requests: [RuntimeGoalIntelligenceRequest] = []
        targets.reserveCapacity(actionableSteps.prefix(3).count + 2)
        requests.reserveCapacity(actionableSteps.prefix(3).count + 2)

        for step in actionableSteps.prefix(3) {
            guard let goal = goals.first(where: { $0.plan?.sections.flatMap(\.steps).contains(where: { $0.id == step.id }) == true }) else {
                continue
            }
            let draft = draftsByGoalID[goal.id]
            let target = TodayActionTarget(goalID: goal.id, stepID: step.id, draftID: draft?.id)
            targets.append(target)
            requests.append(
                RuntimeGoalIntelligenceRequest(
                    target: GoalRouteTarget(goalID: goal.id, draftID: draft?.id),
                    primaryStepID: step.id,
                    includeWhyNow: true
                )
            )
        }

        if let milestoneGoal = goals.sorted(by: { timingSortKey(for: $0.timing) < timingSortKey(for: $1.timing) }).first {
            let draft = draftsByGoalID[milestoneGoal.id]
            let target = TodayActionTarget(goalID: milestoneGoal.id, draftID: draft?.id)
            targets.append(target)
            requests.append(
                RuntimeGoalIntelligenceRequest(
                    target: GoalRouteTarget(goalID: milestoneGoal.id, draftID: draft?.id),
                    primaryStepID: actionableSteps.first(where: { step in
                        milestoneGoal.plan?.sections.flatMap(\.steps).contains(where: { $0.id == step.id }) == true
                    })?.id ?? shellPrimaryStepID(goal: milestoneGoal, draft: draft),
                    includeWhyNow: true
                )
            )
        }

        let contexts = try await goalIntelligenceService.loadContexts(requests, now: now)
        let projector = GoalShellSummaryProjector()
        return Dictionary(uniqueKeysWithValues: zip(targets, contexts).compactMap { target, context in
            guard let context else { return nil }
            return (target, projector.makeState(from: context))
        })
    }

    func shellPrimaryStepID(goal: Goal?, draft: PersistedGoalDraft?) -> String? {
        let steps = (goal?.plan ?? draft?.stagedPlan)?.sections.flatMap(\.steps) ?? []
        return steps.first(where: { $0.state != .completed && $0.state != .cancelled })?.id ?? steps.first?.id
    }

}
