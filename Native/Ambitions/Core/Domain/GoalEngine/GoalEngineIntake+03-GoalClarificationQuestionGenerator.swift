import Foundation

struct GoalClarificationQuestionGenerator {
    func generate(from result: ClassificationResult) -> ClarificationSet {
        var questions: [ClarificationQuestion] = []

        for missing in result.missingFields where questions.count < 3 {
            switch missing.field {
            case .goalSubject:
                questions.append(ClarificationQuestion(id: "goal-subject", field: .goalSubject, prompt: "What is the actual goal you want planned?", rationale: "The engine cannot safely decompose a preference-only or placeholder input.", skipSafeDefault: "No starter plan is created until the subject is explicit."))
            case .executorIdentity:
                questions.append(ClarificationQuestion(id: "executor-identity", field: .executorIdentity, prompt: "Who is actually doing the work this plan is for?", rationale: "Delegated plans should not use self-execution language for someone else's work.", skipSafeDefault: "The app waits rather than inventing an executor."))
            case .supportScope:
                questions.append(ClarificationQuestion(id: "support-scope", field: .supportScope, prompt: "Are you supporting them, coaching them, or mostly tracking progress?", rationale: "That choice changes step tone and what counts as progress.", skipSafeDefault: "The starter plan assumes light, non-punitive support."))
            case .successDefinition:
                questions.append(ClarificationQuestion(id: "success-definition", field: .successDefinition, prompt: "What would count as a good first version of this goal?", rationale: "A first success signal sharpens planning without forcing urgency.", skipSafeDefault: "The starter plan stays intentionally broad."))
            case .goalShape:
                questions.append(ClarificationQuestion(id: "goal-shape", field: .goalShape, prompt: "Should this behave more like stabilization or a concrete result?", rationale: "Recovery-style goals can get over-structured too early without that choice.", skipSafeDefault: "The starter plan stays stabilization-oriented."))
            case .timeHorizon:
                questions.append(ClarificationQuestion(id: "time-horizon", field: .timeHorizon, prompt: "Do you want a rough horizon for this, or should the first plan stay untimed?", rationale: "A horizon helps sequencing only if the user actually wants one.", skipSafeDefault: "The starter plan stays untimed."))
            }
        }

        return ClarificationSet(readiness: result.readiness, questions: questions, missingFields: result.missingFields)
    }
}
