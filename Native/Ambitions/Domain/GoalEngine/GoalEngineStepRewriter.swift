import Foundation

private let vagueStepPatterns: [String] = [
    #"\bwork on\b"#,
    #"\bimprove\b"#,
    #"\bfocus on\b"#,
    #"\bcontinue\b"#,
    #"\bmake progress on\b"#,
    #"\bhandle\b"#,
    #"\bdeal with\b"#,
]

struct GoalEngineStepRewriter {
    func rewrite(step: Step, goal: GoalDraft) -> Step {
        guard isVague(step: step) else { return step }

        let subject = normalizedSubject(for: goal).lowercased()
        let verb = preferredVerb(for: step.type, mode: goal.mode)

        let title = containsVaguePhrase(step.title) ? "\(verb) one concrete \(subject) session" : step.title
        let action = containsVaguePhrase(step.actionability.action)
            ? "\(verb) one bounded action for \(subject) and stop when the result can be shown or logged."
            : step.actionability.action
        let completionDefinition = containsVaguePhrase(step.actionability.completionDefinition)
            ? "Finish a single session-sized unit that can be marked done without carrying unfinished sub-parts."
            : step.actionability.completionDefinition
        let fallbackMicroStep = containsVaguePhrase(step.actionability.fallbackMicroStep)
            ? "Spend five focused minutes on the smallest visible piece of \(subject)."
            : step.actionability.fallbackMicroStep
        let evidenceOfCompletion = step.actionability.evidenceOfCompletion.isEmpty
            ? ["A short note, log entry, or artifact shows exactly what was completed."]
            : step.actionability.evidenceOfCompletion
        let successSignals = step.successSignals.isEmpty
            ? ["The completed action can be shown, logged, or described in one sentence."]
            : step.successSignals

        return Step(
            id: step.id,
            sectionID: step.sectionID,
            title: title,
            summary: step.summary,
            type: step.type,
            state: step.state,
            owner: step.owner,
            timing: step.timing,
            dependencyStepIDs: step.dependencyStepIDs,
            isOptional: step.isOptional,
            isRepeatable: step.isRepeatable,
            evidenceRequired: step.evidenceRequired,
            successSignals: successSignals,
            actionability: StepActionability(
                action: action,
                completionDefinition: completionDefinition,
                evidenceOfCompletion: evidenceOfCompletion,
                fallbackMicroStep: fallbackMicroStep,
                contextRequirements: step.actionability.contextRequirements
            )
        )
    }

    func isVague(step: Step) -> Bool {
        containsVaguePhrase(step.title)
            || containsVaguePhrase(step.summary)
            || containsVaguePhrase(step.actionability.action)
            || containsVaguePhrase(step.actionability.completionDefinition)
            || containsVaguePhrase(step.actionability.fallbackMicroStep)
    }

    private func containsVaguePhrase(_ value: String?) -> Bool {
        guard let value, !value.isEmpty else { return false }
        return vagueStepPatterns.contains { pattern in
            value.range(of: pattern, options: .regularExpression) != nil
        }
    }

    private func normalizedSubject(for goal: GoalDraft) -> String {
        let subject = goal.summary ?? goal.title
        return subject.hasSuffix(".") ? String(subject.dropLast()) : subject
    }

    private func preferredVerb(for stepType: StepType, mode: GoalMode) -> String {
        switch stepType {
        case .recurringRoutine:
            return "Complete"
        case .learningCheckpoint:
            return "Demonstrate"
        case .explorationExperiment:
            return "Run"
        case .supportAction:
            return mode == .delegatedSupport ? "Offer" : "Complete"
        case .observationPrompt:
            return "Log"
        case .resource:
            return "Assemble"
        case .reflectionPrompt:
            return "Write"
        case .actionUnit:
            return "Complete"
        }
    }
}
