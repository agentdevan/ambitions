import Foundation

extension DefaultGoalClarificationService {

    func defaultAssumption(
        for field: MissingFieldKey?,
        reason: String
    ) -> GoalClarificationAssumption? {
        switch field {
        case .supportScope:
            return GoalClarificationAssumption(
                id: "assumption-support-scope",
                summary: "Assume a light support role rather than taking over execution.",
                rationale: "This keeps support plans helpful without stripping agency from the real executor.",
                confidence: .medium,
                source: .derivedContract,
                relatedField: .supportScope,
                safeForCompilation: true
            )
        case .successDefinition:
            return GoalClarificationAssumption(
                id: "assumption-success-definition",
                summary: "Assume the first useful version should stay small and demonstrable.",
                rationale: "Starter planning needs a concrete win signal even when the user has not fully defined a finish line.",
                confidence: .medium,
                source: .derivedContract,
                relatedField: .successDefinition,
                safeForCompilation: true
            )
        case .timeHorizon:
            return GoalClarificationAssumption(
                id: "assumption-time-horizon",
                summary: "Keep timing light until the user chooses a clearer horizon.",
                rationale: "The planner should not invent deadline pressure where the user has not asked for it.",
                confidence: .medium,
                source: .derivedContract,
                relatedField: .timeHorizon,
                safeForCompilation: true
            )
        case .goalShape:
            return GoalClarificationAssumption(
                id: "assumption-goal-shape",
                summary: "Assume stabilization and clarity should come before expansion.",
                rationale: "Broad or recovery-style goals are safer when sequenced around stabilization first.",
                confidence: .medium,
                source: .derivedContract,
                relatedField: .goalShape,
                safeForCompilation: true
            )
        case .goalSubject, .executorIdentity, .none:
            return nil
        }
    }


    func questionContract(
        for field: MissingFieldKey?,
        severity: GoalClarificationSeverity,
        blocking: Bool
    ) -> GoalClarificationQuestionContract? {
        switch field {
        case .goalSubject:
            return GoalClarificationQuestionContract(
                id: "question-goal-subject",
                prompt: "What is the actual goal you want planned?",
                rationale: "The engine cannot safely decompose a placeholder or preference-only input.",
                targetField: .goalSubject,
                addressesAmbiguityTypes: [.readiness, .scope],
                severity: severity,
                blocking: blocking,
                skipSafeDefault: "No starter plan is produced until the subject is explicit."
            )
        case .executorIdentity:
            return GoalClarificationQuestionContract(
                id: "question-executor-identity",
                prompt: "Who is actually doing the work this plan is for?",
                rationale: "Delegated plans should not use self-execution language for someone else's work.",
                targetField: .executorIdentity,
                addressesAmbiguityTypes: [.constraintResource],
                severity: severity,
                blocking: blocking,
                skipSafeDefault: "The planner waits rather than inventing an executor."
            )
        case .supportScope:
            return GoalClarificationQuestionContract(
                id: "question-support-scope",
                prompt: "Are you supporting them, coaching them, or mostly tracking progress?",
                rationale: "That choice changes tone, step framing, and what counts as progress.",
                targetField: .supportScope,
                addressesAmbiguityTypes: [.scope, .constraintResource],
                severity: severity,
                blocking: blocking,
                skipSafeDefault: "Starter planning assumes light, non-punitive support."
            )
        case .successDefinition:
            return GoalClarificationQuestionContract(
                id: "question-success-definition",
                prompt: "What would count as a good first version of this goal?",
                rationale: "A first success signal sharpens planning without forcing urgency.",
                targetField: .successDefinition,
                addressesAmbiguityTypes: [.successDefinition, .scope],
                severity: severity,
                blocking: blocking,
                skipSafeDefault: "The starter plan stays intentionally broad."
            )
        case .goalShape:
            return GoalClarificationQuestionContract(
                id: "question-goal-shape",
                prompt: "Should this behave more like stabilization, exploration, or a concrete result?",
                rationale: "Broad goals can be decomposed in materially different ways, so the system should keep the shape explicit.",
                targetField: .goalShape,
                addressesAmbiguityTypes: [.scope, .readiness],
                severity: severity,
                blocking: blocking,
                skipSafeDefault: "The starter plan stays conservative and stabilization-oriented."
            )
        case .timeHorizon:
            return GoalClarificationQuestionContract(
                id: "question-time-horizon",
                prompt: "Do you want a rough horizon for this, or should the first plan stay untimed?",
                rationale: "A horizon helps sequencing only if the user actually wants one.",
                targetField: .timeHorizon,
                addressesAmbiguityTypes: [.timeline],
                severity: severity,
                blocking: blocking,
                skipSafeDefault: "The starter plan stays untimed."
            )
        case .none:
            return nil
        }
    }


    func reasoningNotes(
        classification: ClassificationResult,
        candidates: [GoalInterpretationCandidate],
        missingContext: [GoalMissingContextItem],
        ambiguities: [GoalAmbiguitySignal]
    ) -> [String] {
        var notes: [String] = []

        if candidates.count > 1 {
            notes.append("Multiple plausible interpretations were preserved structurally.")
        }
        if missingContext.contains(where: \.blocksCompilation) {
            notes.append("At least one missing context item is compile-blocking.")
        }
        if ambiguities.contains(where: { $0.type == .timeline }) {
            notes.append("Timeline ambiguity remains explicit and should not be collapsed into fake deadline certainty.")
        }
        if classification.draft.lifeGraph == nil {
            notes.append("Life-graph hints are still conservative, so domain interpretation remains narrow.")
        }

        return notes
    }


    func auditTags(
        classification: ClassificationResult,
        candidates: [GoalInterpretationCandidate],
        missingContext: [GoalMissingContextItem],
        ambiguities: [GoalAmbiguitySignal],
        decision: GoalClarificationDecision
    ) -> [String] {
        var tags = [
            "batch22_clarification",
            "decision:\(decision.rawValue)",
            "mode:\(classification.mode.value.rawValue)",
            "tempo:\(classification.tempo.value.rawValue)"
        ]

        if candidates.count > 1 {
            tags.append("multi_interpretation")
        }
        if missingContext.contains(where: \.blocksCompilation) {
            tags.append("blocking_missing_context")
        }
        tags.append(contentsOf: ambiguities.map { "ambiguity:\($0.type.rawValue)" })
        return stableStrings(tags)
    }


    func primarySummary(for classification: ClassificationResult) -> String {
        switch classification.mode.value {
        case .achievement:
            return "Treat the goal as a concrete outcome that should eventually compile into an execution path."
        case .project:
            return "Treat the goal as a multi-step project with structured sequencing."
        case .habit:
            return "Treat the goal as a repeatable ritual rather than a one-time deliverable."
        case .learning:
            return "Treat the goal as a learning path with checkpoints and evidence of understanding."
        case .exploration:
            return "Treat the goal as exploratory work that should narrow uncertainty before heavy execution."
        case .maintenance:
            return "Treat the goal as ongoing maintenance with consistency over hard completion."
        case .recovery:
            return "Treat the goal as recovery or stabilization work that should avoid over-structuring too early."
        case .delegatedSupport:
            return "Treat the goal as support work around someone else's execution."
        }
    }


    func domainHints(preferred: LifeDomainKey, classification: ClassificationResult) -> [LifeDomainKey] {
        let existing = classification.draft.lifeGraph?.domains.map(\.domain) ?? []
        return stableDomains([preferred] + existing)
    }


    func missingContextLabel(for field: MissingFieldKey) -> String {
        switch field {
        case .goalSubject:
            return "Goal subject"
        case .goalShape:
            return "Goal shape"
        case .executorIdentity:
            return "Executor identity"
        case .supportScope:
            return "Support scope"
        case .successDefinition:
            return "Success definition"
        case .timeHorizon:
            return "Time horizon"
        }
    }


    func stableCandidates(_ values: [GoalInterpretationCandidate]) -> [GoalInterpretationCandidate] {
        var seen: Set<String> = []
        var result: [GoalInterpretationCandidate] = []
        for value in values where seen.insert(value.summary).inserted {
            result.append(value)
        }
        return result
    }


    func stableSignals(_ values: [GoalAmbiguitySignal]) -> [GoalAmbiguitySignal] {
        var seen: Set<String> = []
        var result: [GoalAmbiguitySignal] = []
        for value in values where seen.insert(value.id).inserted {
            result.append(value)
        }
        return result
    }


    func stableAssumptions(_ values: [GoalClarificationAssumption]) -> [GoalClarificationAssumption] {
        var seen: Set<String> = []
        var result: [GoalClarificationAssumption] = []
        for value in values where seen.insert(value.id).inserted {
            result.append(value)
        }
        return result
    }


    func stableQuestions(_ values: [GoalClarificationQuestionContract]) -> [GoalClarificationQuestionContract] {
        var seen: Set<String> = []
        var result: [GoalClarificationQuestionContract] = []
        for value in values where seen.insert(value.id).inserted {
            result.append(value)
        }
        return result
    }


    func stableDomains(_ values: [LifeDomainKey]) -> [LifeDomainKey] {
        var seen: Set<LifeDomainKey> = []
        var result: [LifeDomainKey] = []
        for value in values where seen.insert(value).inserted {
            result.append(value)
        }
        return result
    }


    func stableStrings(_ values: [String]) -> [String] {
        var seen: Set<String> = []
        var result: [String] = []
        for value in values where seen.insert(value).inserted {
            result.append(value)
        }
        return result
    }
}
