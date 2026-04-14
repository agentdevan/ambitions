import { GoalMode, Step, TimingType } from "../../domain/models/goalEngine";
import { FeedbackAnalyzer } from "./FeedbackAnalyzer";
import {
  GoalAdaptivePlanAdjustmentPayload,
  GoalAdaptivePlanInput,
  GoalAdjustPlanToneRecommendation,
  GoalNoChangeRecommendation,
  GoalRelaxTimingRecommendation,
  GoalReplanRecommendation,
  GoalRequestReclarificationRecommendation,
  GoalReviseStepRecommendation,
  GoalShrinkStepRecommendation,
  GoalSuggestAlternatePathRecommendation,
  GoalSuggestMicroStepRecommendation,
  createWhyThisMattersExplanation,
} from "./goalEngineFeedback";

function confidenceFor(score: number, bonus = 0): number {
  return Number(Math.min(0.98, Math.max(0.45, 0.6 + score * 0.12 + bonus)).toFixed(2));
}

function buildSmallerVersion(step: Step): { smallerVersion: string; fallbackMicroStep: string } {
  return {
    smallerVersion:
      step.summary ??
      `Reduce "${step.title}" to a single session-sized pass with one visible outcome.`,
    fallbackMicroStep: step.actionability.fallbackMicroStep,
  };
}

function supportiveToneGuidance(): string[] {
  return [
    "Use collaborative language instead of commands or control language.",
    "Keep the supported person as the owner of execution.",
    "Frame progress as observation and support, not compliance.",
  ];
}

function reviseHints(step: Step): string[] {
  return [
    `Replace vague language in "${step.title}" with one observable action.`,
    "Name the artifact, note, or evidence that proves the step is complete.",
    "State the smallest acceptable done state before the next session ends.",
  ];
}

function evidenceAdjustments(step: Step): string[] {
  return [
    `Keep at least one visible evidence signal for "${step.title}".`,
    `Use a completion definition as concrete as: ${step.actionability.completionDefinition}`,
  ];
}

function buildAlternatePath(step: Step): string {
  return step.type === "exploration_experiment"
    ? "Switch from committing to a result to running one low-cost experiment that answers a single question."
    : "Swap this step for a lower-friction path that still creates visible signal.";
}

export class AdaptationService {
  private readonly analyzer: FeedbackAnalyzer;

  constructor(analyzer: FeedbackAnalyzer = new FeedbackAnalyzer()) {
    this.analyzer = analyzer;
  }

  recommendPlanAdjustment(input: GoalAdaptivePlanInput): GoalAdaptivePlanAdjustmentPayload {
    const analysis = this.analyzer.analyze(input);
    const { signals } = analysis;
    const explanationHook = analysis.asksWhyThisMatters
      ? createWhyThisMattersExplanation(input.currentResult.draft, input.selectedStep)
      : undefined;

    let recommendation: GoalReplanRecommendation;

    // Delegated goals should never drift into punitive or controlling language.
    if (signals.toneDriftDetected) {
      const toneRecommendation: GoalAdjustPlanToneRecommendation = {
        kind: "adjust_plan_tone",
        stepId: input.selectedStep.id,
        rationale:
          "The selected step uses controlling language that is not appropriate for a delegated support plan.",
        confidence: confidenceFor(signals.frictionScore, 0.14),
        signals,
        toneGuidance: supportiveToneGuidance(),
      };
      recommendation = toneRecommendation;
    } else if (analysis.repeatedIrrelevance) {
      const reclarify: GoalRequestReclarificationRecommendation = {
        kind: "request_reclarification",
        stepId: input.selectedStep.id,
        rationale:
          "Repeated not-relevant feedback suggests the plan direction is off and should be clarified before more decomposition.",
        confidence: confidenceFor(signals.frictionScore, 0.1),
        signals,
        questions: [
          "What outcome still matters most here?",
          "Which part of the current direction feels off or irrelevant?",
        ],
      };
      recommendation = reclarify;
    } else if (analysis.repeatedAvoidance) {
      const smaller = buildSmallerVersion(input.selectedStep);
      const shrink: GoalShrinkStepRecommendation = {
        kind: "shrink_step",
        stepId: input.selectedStep.id,
        rationale:
          "Repeated avoidance combined with size complaints means the step should shrink before the planner asks for more follow-through.",
        confidence: confidenceFor(signals.frictionScore, 0.16),
        signals,
        smallerVersion: smaller.smallerVersion,
        fallbackMicroStep: smaller.fallbackMicroStep,
      };
      recommendation = shrink;
    } else if (analysis.repeatedConfusion) {
      const revise: GoalReviseStepRecommendation = {
        kind: "revise_step",
        stepId: input.selectedStep.id,
        rationale:
          "Repeated confusion means the step needs clearer action language and stronger completion evidence.",
        confidence: confidenceFor(signals.frictionScore, 0.12),
        signals,
        rewriteHints: reviseHints(input.selectedStep),
        evidenceAdjustments: evidenceAdjustments(input.selectedStep),
        explanationHook,
      };
      recommendation = revise;
    } else if (analysis.timingPressureMismatch || analysis.shouldReduceLearningPressure) {
      const relaxTiming: GoalRelaxTimingRecommendation = {
        kind: "relax_timing",
        stepId: input.selectedStep.id,
        rationale:
          input.currentResult.draft.mode === GoalMode.Exploration
            ? "Exploration work is getting too rigid and should shift back toward guidance and evidence gathering."
            : "This step is carrying more timing pressure than the underlying goal contract supports.",
        confidence: confidenceFor(signals.frictionScore, 0.1),
        signals,
        suggestedTimingType:
          input.currentResult.draft.mode === GoalMode.Learning ||
          input.currentResult.draft.mode === GoalMode.Exploration
            ? TimingType.SuggestedNext
            : TimingType.LogWhenDone,
        removeDeadline: true,
      };
      recommendation = relaxTiming;
    } else if (analysis.shouldSoftenRecoveryApproach) {
      const microStep: GoalSuggestMicroStepRecommendation = {
        kind: "suggest_micro_step",
        stepId: input.selectedStep.id,
        rationale:
          "Recovery friction is rising, so the next action should get gentler rather than pushing the same step harder.",
        confidence: confidenceFor(signals.frictionScore, 0.14),
        signals,
        microStep: input.selectedStep.actionability.fallbackMicroStep,
      };
      recommendation = microStep;
    } else if (input.feedbackHistory.some((event) => event.stepId === input.selectedStep.id && event.type === "too_easy")) {
      const alternate: GoalSuggestAlternatePathRecommendation = {
        kind: "suggest_alternate_path",
        stepId: input.selectedStep.id,
        rationale:
          "The step may be too easy to generate useful signal, so the next version should take a slightly more informative path.",
        confidence: confidenceFor(signals.frictionScore, 0.04),
        signals,
        alternatePath: buildAlternatePath(input.selectedStep),
        explanationHook,
      };
      recommendation = alternate;
    } else if (analysis.asksWhyThisMatters) {
      const revise: GoalReviseStepRecommendation = {
        kind: "revise_step",
        stepId: input.selectedStep.id,
        rationale:
          "The user asked why this matters, so the next plan version should make the step's relevance explicit.",
        confidence: confidenceFor(signals.frictionScore, 0.06),
        signals,
        rewriteHints: ["Explain how this step connects to the current goal or milestone before asking for execution."],
        evidenceAdjustments: [],
        explanationHook,
      };
      recommendation = revise;
    } else {
      const noChange: GoalNoChangeRecommendation = {
        kind: "no_change",
        stepId: input.selectedStep.id,
        rationale: "The feedback does not yet justify changing the step or the surrounding plan.",
        confidence: confidenceFor(signals.frictionScore, -0.05),
        signals,
      };
      recommendation = noChange;
    }

    return {
      goal: input.currentResult.draft,
      plan: input.currentResult.plan,
      selectedStep: input.selectedStep,
      recommendation,
      explanationHook:
        "explanationHook" in recommendation ? recommendation.explanationHook : explanationHook,
    };
  }
}
