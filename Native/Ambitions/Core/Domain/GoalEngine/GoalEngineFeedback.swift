import Foundation

func createWhyThisMattersExplanation(draft: GoalDraft, step: Step) -> WhyStepMattersExplanationHook {
    if draft.mode == .delegatedSupport {
        return WhyStepMattersExplanationHook(
            prompt: "Why does this step matter?",
            explanation: "\(step.title) matters because it supports \(draft.actor.displayName) without taking ownership away from them."
        )
    }

    return WhyStepMattersExplanationHook(
        prompt: "Why does this step matter?",
        explanation: "\(step.title) matters because it advances \(draft.title.lowercased()) through a step that can be checked and learned from."
    )
}
