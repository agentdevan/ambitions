import Foundation

struct GoalEngineAdaptationService {
    private let analyzer: GoalEngineFeedbackAnalyzer

    init(analyzer: GoalEngineFeedbackAnalyzer = GoalEngineFeedbackAnalyzer()) {
        self.analyzer = analyzer
    }

    func recommendPlanAdjustment(input: GoalAdaptivePlanInput) -> GoalAdaptivePlanAdjustmentPayload {
        let analysis = analyzer.analyze(input: input)
        let signals = analysis.signals
        let explanationHook = analysis.asksWhyThisMatters
            ? createWhyThisMattersExplanation(draft: input.currentResult.draft, step: input.selectedStep)
            : nil

        let recommendation: GoalReplanRecommendation

        if signals.toneDriftDetected {
            recommendation = .adjustPlanTone(
                stepID: input.selectedStep.id,
                rationale: "The selected step uses controlling language that is not appropriate for a delegated support plan.",
                confidence: confidence(for: signals.frictionScore, bonus: 0.14),
                signals: signals,
                toneGuidance: [
                    "Use collaborative language instead of commands or control language.",
                    "Keep the supported person as the owner of execution.",
                    "Frame progress as observation and support, not compliance.",
                ]
            )
        } else if analysis.waitingOnExternalDependency || analysis.waitingOnDependencyChain {
            recommendation = .suggestAlternatePath(
                stepID: input.selectedStep.id,
                rationale: analysis.waitingOnExternalDependency
                    ? "The current step is waiting on something outside the plan, so recovery should surface the unblock state instead of pretending execution can proceed."
                    : "A prerequisite is still open, so recovery should point back to the unblock path before this step re-enters the queue.",
                confidence: confidence(for: signals.frictionScore, bonus: 0.16),
                signals: signals,
                alternatePath: analysis.waitingOnExternalDependency
                    ? "Wait on the external dependency, then retry this step when the blocker clears."
                    : "Finish the blocking prerequisite before retrying this step.",
                explanationHook: explanationHook
            )
        } else if analysis.needsReadinessRecovery {
            recommendation = .suggestMicroStep(
                stepID: input.selectedStep.id,
                rationale: "The current drift signal says readiness is missing, so recovery should lower the pressure and start with a setup-sized move.",
                confidence: confidence(for: signals.frictionScore, bonus: 0.14),
                signals: signals,
                microStep: "Start with: \(input.selectedStep.actionability.fallbackMicroStep)"
            )
        } else if analysis.repeatedIrrelevance {
            recommendation = .requestReclarification(
                stepID: input.selectedStep.id,
                rationale: "Repeated not-relevant feedback suggests the plan direction is off and should be clarified before more decomposition.",
                confidence: confidence(for: signals.frictionScore, bonus: 0.1),
                signals: signals,
                questions: [
                    "What outcome still matters most here?",
                    "Which part of the current direction feels off or irrelevant?",
                ]
            )
        } else if analysis.shouldSoftenRecoveryApproach {
            recommendation = .suggestMicroStep(
                stepID: input.selectedStep.id,
                rationale: "Recovery friction is rising, so the next action should get gentler rather than pushing the same step harder.",
                confidence: confidence(for: signals.frictionScore, bonus: 0.14),
                signals: signals,
                microStep: input.selectedStep.actionability.fallbackMicroStep
            )
        } else if analysis.repeatedAvoidance || analysis.hasFragilePlan {
            recommendation = .shrinkStep(
                stepID: input.selectedStep.id,
                rationale: analysis.hasFragilePlan
                    ? "Plan fragility is high, so recovery should make the next step smaller before it asks for more follow-through."
                    : "Repeated avoidance combined with size complaints means the step should shrink before the planner asks for more follow-through.",
                confidence: confidence(for: signals.frictionScore, bonus: 0.16),
                signals: signals,
                smallerVersion: input.selectedStep.summary ?? "Reduce \"\(input.selectedStep.title)\" to a single session-sized pass with one visible outcome.",
                fallbackMicroStep: input.selectedStep.actionability.fallbackMicroStep
            )
        } else if analysis.repeatedConfusion {
            recommendation = .reviseStep(
                stepID: input.selectedStep.id,
                rationale: "Repeated confusion means the step needs clearer action language and stronger completion evidence.",
                confidence: confidence(for: signals.frictionScore, bonus: 0.12),
                signals: signals,
                rewriteHints: [
                    "Replace vague language in \"\(input.selectedStep.title)\" with one observable action.",
                    "Name the artifact, note, or evidence that proves the step is complete.",
                    "State the smallest acceptable done state before the next session ends.",
                ],
                evidenceAdjustments: [
                    "Keep at least one visible evidence signal for \"\(input.selectedStep.title)\".",
                    "Use a completion definition as concrete as: \(input.selectedStep.actionability.completionDefinition)",
                ],
                explanationHook: explanationHook
            )
        } else if analysis.timingPressureMismatch || analysis.shouldReduceLearningPressure {
            recommendation = .relaxTiming(
                stepID: input.selectedStep.id,
                rationale: input.currentResult.draft.mode == .exploration
                    ? "Exploration work is getting too rigid and should shift back toward guidance and evidence gathering."
                    : "This step is carrying more timing pressure than the underlying goal contract supports.",
                confidence: confidence(for: signals.frictionScore, bonus: 0.1),
                signals: signals,
                suggestedTimingType: [.learning, .exploration].contains(input.currentResult.draft.mode) ? .suggestedNext : .logWhenDone,
                removeDeadline: true
            )
        } else if input.feedbackHistory.contains(where: { event in
            if case .tooEasy = event, event.stepID == input.selectedStep.id { return true }
            return false
        }) {
            recommendation = .suggestAlternatePath(
                stepID: input.selectedStep.id,
                rationale: "The step may be too easy to generate useful signal, so the next version should take a slightly more informative path.",
                confidence: confidence(for: signals.frictionScore, bonus: 0.04),
                signals: signals,
                alternatePath: input.selectedStep.type == .explorationExperiment
                    ? "Switch from committing to a result to running one low-cost experiment that answers a single question."
                    : "Swap this step for a lower-friction path that still creates visible signal.",
                explanationHook: explanationHook
            )
        } else if analysis.asksWhyThisMatters {
            recommendation = .reviseStep(
                stepID: input.selectedStep.id,
                rationale: "The user asked why this matters, so the next plan version should make the step's relevance explicit.",
                confidence: confidence(for: signals.frictionScore, bonus: 0.06),
                signals: signals,
                rewriteHints: ["Explain how this step connects to the current goal or milestone before asking for execution."],
                evidenceAdjustments: [],
                explanationHook: explanationHook
            )
        } else {
            recommendation = .noChange(
                stepID: input.selectedStep.id,
                rationale: "The feedback does not yet justify changing the step or the surrounding plan.",
                confidence: confidence(for: signals.frictionScore, bonus: -0.05),
                signals: signals
            )
        }

        let surfacedHook: WhyStepMattersExplanationHook?
        switch recommendation {
        case let .reviseStep(_, _, _, _, _, _, hook):
            surfacedHook = hook ?? explanationHook
        case let .suggestAlternatePath(_, _, _, _, _, hook):
            surfacedHook = hook ?? explanationHook
        default:
            surfacedHook = explanationHook
        }

        return GoalAdaptivePlanAdjustmentPayload(
            goal: input.currentResult.draft,
            plan: input.currentResult.plan,
            selectedStep: input.selectedStep,
            recommendation: recommendation,
            explanationHook: surfacedHook
        )
    }

    private func confidence(for score: Double, bonus: Double = 0) -> Double {
        let value = min(0.98, max(0.45, 0.6 + score * 0.12 + bonus))
        return (value * 100).rounded() / 100
    }
}
