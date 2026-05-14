import Foundation

protocol GoalClarificationAnalyzing: Sendable {
    func analyze(
        classification: ClassificationResult,
        context: GoalEngineOrchestrationContextSnapshot
    ) -> GoalClarificationAnalysis
}

struct DefaultGoalClarificationService: GoalClarificationAnalyzing {
    func analyze(
        classification: ClassificationResult,
        context: GoalEngineOrchestrationContextSnapshot
    ) -> GoalClarificationAnalysis {
        let candidates = interpretationCandidates(for: classification)
        let missingContext = missingContextItems(for: classification)
        let ambiguities = ambiguitySignals(
            for: classification,
            context: context,
            candidates: candidates,
            missingContext: missingContext
        )
        let assumptions = assumptions(
            for: classification,
            candidates: candidates,
            missingContext: missingContext,
            ambiguities: ambiguities
        )
        let questions = questions(
            for: classification,
            candidates: candidates,
            missingContext: missingContext,
            ambiguities: ambiguities
        )
        let decision = clarificationDecision(
            missingContext: missingContext,
            ambiguities: ambiguities
        )

        return GoalClarificationAnalysis(
            candidateInterpretations: candidates,
            ambiguities: ambiguities,
            missingContext: missingContext,
            assumptions: assumptions,
            questions: questions,
            decision: decision,
            reasoning: GoalClarificationReasoningMetadata(
                signalNotes: reasoningNotes(
                    classification: classification,
                    candidates: candidates,
                    missingContext: missingContext,
                    ambiguities: ambiguities
                ),
                inference: [
                    "mode": classification.mode.metadata,
                    "tempo": classification.tempo.metadata,
                    "relationshipKind": classification.relationshipKind.metadata,
                    "executionOwnership": classification.executionOwnership.metadata,
                    "userRole": classification.userRole.metadata,
                    "strictDeadlinesAppropriate": classification.strictDeadlinesAppropriate.metadata,
                    "planningStrategyID": classification.planningStrategyID.metadata,
                    "progressStrategyID": classification.progressStrategyID.metadata,
                ],
                auditTags: auditTags(
                    classification: classification,
                    candidates: candidates,
                    missingContext: missingContext,
                    ambiguities: ambiguities,
                    decision: decision
                )
            )
        )
    }
}

private extension DefaultGoalClarificationService {
    func interpretationCandidates(for classification: ClassificationResult) -> [GoalInterpretationCandidate] {
        let lower = classification.normalizedInput.lowercased()
        let primaryID = "candidate-primary"
        let primary = GoalInterpretationCandidate(
            id: primaryID,
            summary: primarySummary(for: classification),
            modeHint: classification.mode.value,
            domainHints: classification.draft.lifeGraph?.domains.map(\.domain) ?? [],
            confidence: classification.mode.metadata.label.recommendationConfidence,
            supportingSignals: [
                classification.mode.metadata.reason,
                classification.tempo.metadata.reason
            ]
        )

        var candidates = [primary]

        if lower.contains("launch my business") || lower.contains("business") || lower.contains("freelance") || lower.contains("pivot") {
            candidates.append(
                GoalInterpretationCandidate(
                    id: "candidate-exploration",
                    summary: "Treat the goal as exploratory work to clarify which concrete business path is actually viable.",
                    modeHint: .exploration,
                    domainHints: domainHints(preferred: .career, classification: classification),
                    confidence: .medium,
                    supportingSignals: [
                        "Business and pivot language often mixes concrete delivery with exploratory decision-making."
                    ]
                )
            )
        }

        if lower.contains("healthier") || lower.contains("feel better") || lower.contains("recover") {
            candidates.append(
                GoalInterpretationCandidate(
                    id: "candidate-outcome",
                    summary: "Treat the goal as a concrete health outcome rather than open-ended stabilization work.",
                    modeHint: .achievement,
                    domainHints: domainHints(preferred: .health, classification: classification),
                    confidence: .medium,
                    supportingSignals: [
                        "Broad health language can describe either stabilization or a concrete target."
                    ]
                )
            )
        }

        return stableCandidates(candidates)
    }

    func missingContextItems(for classification: ClassificationResult) -> [GoalMissingContextItem] {
        classification.missingFields.map { field in
            GoalMissingContextItem(
                id: "missing-\(field.field.rawValue)",
                field: field.field,
                label: missingContextLabel(for: field.field),
                reason: field.reason,
                severity: field.blocksPlanning ? .blocking : .important,
                blocksCompilation: field.blocksPlanning
            )
        }
    }

    func ambiguitySignals(
        for classification: ClassificationResult,
        context: GoalEngineOrchestrationContextSnapshot,
        candidates: [GoalInterpretationCandidate],
        missingContext: [GoalMissingContextItem]
    ) -> [GoalAmbiguitySignal] {
        let lower = classification.normalizedInput.lowercased()
        var signals: [GoalAmbiguitySignal] = []

        if candidates.count > 1 {
            signals.append(
                GoalAmbiguitySignal(
                    id: "ambiguity-multi-interpretation",
                    type: classification.draft.lifeGraph?.domains.isEmpty == false ? .scope : .domain,
                    summary: "Multiple plausible interpretations are still in play.",
                    detail: "The current intake can support more than one structural reading of the goal, so Ambitions preserves those readings instead of collapsing them.",
                    severity: .important,
                    relatedField: .goalShape,
                    candidateIDs: candidates.map(\.id)
                )
            )
        }

        if lower.contains("this summer") && classification.tempo.value == .targetWindow {
            signals.append(
                GoalAmbiguitySignal(
                    id: "ambiguity-timeline-window",
                    type: .timeline,
                    summary: "The timing is a window rather than a hard boundary.",
                    detail: "A seasonal window helps sequencing but still leaves room for interpretation around pace and deadline strictness.",
                    severity: .important,
                    relatedField: .timeHorizon,
                    candidateIDs: [candidates.first?.id].compactMap { $0 }
                )
            )
        }

        if classification.missingFields.contains(where: { $0.field == .executorIdentity || $0.field == .supportScope }) {
            signals.append(
                GoalAmbiguitySignal(
                    id: "ambiguity-ownership-constraints",
                    type: .constraintResource,
                    summary: "The execution boundary is not fully defined yet.",
                    detail: "Support and delegated goals need clearer ownership and support scope before the planner can safely choose language, effort shape, and evidence rules.",
                    severity: missingContext.contains(where: \.blocksCompilation) ? .blocking : .important,
                    relatedField: classification.missingFields.contains(where: { $0.field == .executorIdentity }) ? .executorIdentity : .supportScope,
                    candidateIDs: [candidates.first?.id].compactMap { $0 }
                )
            )
        }

        if classification.missingFields.contains(where: { $0.field == .successDefinition }) {
            signals.append(
                GoalAmbiguitySignal(
                    id: "ambiguity-success-definition",
                    type: .successDefinition,
                    summary: "The success condition is still underspecified.",
                    detail: "The planner can produce a starter path, but the win condition is still ambiguous enough that the result should stay provisional.",
                    severity: .important,
                    relatedField: .successDefinition,
                    candidateIDs: [candidates.first?.id].compactMap { $0 }
                )
            )
        }

        if lower.contains("i don't know where to start") || lower.contains("dont know where to start") {
            signals.append(
                GoalAmbiguitySignal(
                    id: "ambiguity-readiness-subject",
                    type: .readiness,
                    summary: "The user needs help starting, but the real goal subject is not yet explicit.",
                    detail: "Starter planning is only safe once the goal subject is concrete enough to decompose.",
                    severity: .blocking,
                    relatedField: .goalSubject,
                    candidateIDs: []
                )
            )
        }

        if context.supportScope == nil && classification.userRole.value == .plannerSupporter && classification.executionOwnership.value != .child {
            signals.append(
                GoalAmbiguitySignal(
                    id: "ambiguity-support-scope",
                    type: .scope,
                    summary: "The support relationship is still broad.",
                    detail: "Support, coaching, and tracking create different step shapes and should stay structurally distinct.",
                    severity: .important,
                    relatedField: .supportScope,
                    candidateIDs: [candidates.first?.id].compactMap { $0 }
                )
            )
        }

        return stableSignals(signals)
    }

    func assumptions(
        for classification: ClassificationResult,
        candidates: [GoalInterpretationCandidate],
        missingContext: [GoalMissingContextItem],
        ambiguities: [GoalAmbiguitySignal]
    ) -> [GoalClarificationAssumption] {
        var assumptions: [GoalClarificationAssumption] = []

        for item in missingContext where item.blocksCompilation == false {
            if let assumption = defaultAssumption(for: item.field, reason: item.reason) {
                assumptions.append(assumption)
            }
        }

        if candidates.count > 1,
           let primary = candidates.first,
           ambiguities.contains(where: { $0.id == "ambiguity-multi-interpretation" }) {
            assumptions.append(
                GoalClarificationAssumption(
                    id: "assumption-primary-interpretation",
                    summary: "Use the current primary interpretation as starter scaffolding while keeping alternate interpretations visible.",
                    rationale: "Ambitions preserves multiple readings structurally, but starter planning can still use the leading interpretation when no blocking ambiguity remains.",
                    confidence: .medium,
                    source: .derivedContract,
                    relatedField: primary.modeHint == .exploration ? .goalShape : .successDefinition,
                    safeForCompilation: true
                )
            )
        }

        return stableAssumptions(assumptions)
    }

    func questions(
        for classification: ClassificationResult,
        candidates: [GoalInterpretationCandidate],
        missingContext: [GoalMissingContextItem],
        ambiguities: [GoalAmbiguitySignal]
    ) -> [GoalClarificationQuestionContract] {
        var questions = missingContext.compactMap { item in
            questionContract(
                for: item.field,
                severity: item.severity,
                blocking: item.blocksCompilation
            )
        }

        if candidates.count > 1 {
            questions.append(
                GoalClarificationQuestionContract(
                    id: "question-interpretation-shape",
                    prompt: "Should this be treated as a concrete project to execute now, or as exploration to clarify the right path first?",
                    rationale: "Multiple plausible interpretations are active, and the system should ask which shape the user actually means before later path work pretends certainty.",
                    targetField: .goalShape,
                    addressesAmbiguityTypes: [.scope],
                    severity: .important,
                    blocking: false,
                    skipSafeDefault: "Starter planning can stay provisional while keeping alternate interpretations explicit."
                )
            )
        }

        if classification.missingFields.contains(where: { $0.field == .goalSubject }) == false,
           classification.draft.lifeGraph?.domains.isEmpty ?? true,
           classification.mode.value == .achievement,
           classification.normalizedInput.lowercased().contains("better") {
            questions.append(
                GoalClarificationQuestionContract(
                    id: "question-domain-anchor",
                    prompt: "What area of life is this goal mainly about right now?",
                    rationale: "A broad improvement goal can point at more than one domain, so the domain anchor should stay explicit for later understanding work.",
                    targetField: .goalSubject,
                    addressesAmbiguityTypes: [.domain],
                    severity: .important,
                    blocking: false,
                    skipSafeDefault: "The starter plan stays conservative until the domain anchor is clearer."
                )
            )
        }

        return stableQuestions(questions)
    }

    func clarificationDecision(
        missingContext: [GoalMissingContextItem],
        ambiguities: [GoalAmbiguitySignal]
    ) -> GoalClarificationDecision {
        let hasBlockingMissingContext = missingContext.contains(where: \.blocksCompilation)
        let hasBlockingAmbiguity = ambiguities.contains(where: { $0.severity.blocksCompilation })
        return (hasBlockingMissingContext || hasBlockingAmbiguity) ? .mustClarifyBeforeCompile : .safeToProceedWithAssumptions
    }

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

private extension ClassificationConfidence {
    var recommendationConfidence: RecommendationConfidence {
        switch self {
        case .low:
            return .low
        case .medium:
            return .medium
        case .high:
            return .high
        }
    }
}
