import Foundation

extension DefaultGoalClarificationService {
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
}
