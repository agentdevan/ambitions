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
