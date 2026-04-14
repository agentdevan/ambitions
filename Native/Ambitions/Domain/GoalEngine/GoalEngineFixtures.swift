import Foundation

struct GoalEngineFixture: Sendable {
    let id: String
    let input: String
    let context: GoalEngineOrchestrationContext
    let result: GoalOrchestrationResult
}

enum GoalEngineFixtures {
    static let fixedNow = "2026-04-14T12:00:00Z"

    static let orchestrationFixtures: [GoalEngineFixture] = [
        run(id: "clear-timed-self-goal", input: "Submit my conference talk proposal by 2026-05-15", context: GoalEngineOrchestrationContext(sourceScreen: "goal_composer", sourceFlow: "manual_entry", referenceNow: fixedNow)),
        run(id: "untimed-learning-goal", input: "Learn how to mix vocals", context: GoalEngineOrchestrationContext(sourceScreen: "goal_composer", referenceNow: fixedNow)),
        run(id: "exploratory-vague-goal", input: "Launch my business", context: GoalEngineOrchestrationContext(preferredPlanningStrictness: .starterFriendly, referenceNow: fixedNow)),
        run(id: "delegated-child-support-goal", input: "Help my daughter read better", context: GoalEngineOrchestrationContext(actorName: "Maya", goalOwnerRole: "Supported learner", supportScope: .supporting, referenceNow: fixedNow)),
        run(id: "blocked-requiring-clarification", input: "Break this down for someone else", context: GoalEngineOrchestrationContext(referenceNow: fixedNow)),
        run(id: "contradictory-input", input: "I want to launch my business this summer, but I don't want deadlines", context: GoalEngineOrchestrationContext(referenceNow: fixedNow)),
        run(id: "dont-know-where-to-start", input: "I don't know where to start", context: GoalEngineOrchestrationContext(referenceNow: fixedNow)),
        run(id: "target-window-goal", input: "Launch my portfolio this summer", context: GoalEngineOrchestrationContext(referenceNow: fixedNow))
    ]

    static func fixture(id: String) -> GoalEngineFixture? {
        orchestrationFixtures.first(where: { $0.id == id })
    }

    private static func run(id: String, input: String, context: GoalEngineOrchestrationContext) -> GoalEngineFixture {
        GoalEngineFixture(id: id, input: input, context: context, result: compileGoal(input, context: context))
    }
}
