import { GoalDraft, GoalMode, GoalPlan, Step, TimingType } from "../../domain/models/goalEngine";
import {
  GoalOrchestrationResult,
  GoalPlannedResult,
  GoalStarterPlannedResult,
} from "./goalEngineOrchestration";

export type GoalFeedbackEffortLevel = "low" | "medium" | "high";
export type GoalStepSkipReasonCode =
  | "avoidance"
  | "too_hard"
  | "not_now"
  | "forgot"
  | "blocked_external"
  | "not_ready";
export type GoalTimingAdjustment =
  | "later_today"
  | "later_this_week"
  | "someday"
  | "remove_deadline";
export type GoalConfusionType =
  | "unclear_action"
  | "unclear_why"
  | "missing_context"
  | "missing_evidence";

export interface GoalFeedbackEventBase {
  id: string;
  stepId: string;
  occurredAt: string;
  note: string | null;
}

export interface GoalStepCompletedFeedbackEvent extends GoalFeedbackEventBase {
  type: "completed";
  actualDuration: number | null;
  effortLevel: GoalFeedbackEffortLevel;
  confidenceDelta: number | null;
}

export interface GoalStepSkippedFeedbackEvent extends GoalFeedbackEventBase {
  type: "skipped";
  reasonCode: GoalStepSkipReasonCode;
}

export interface GoalStepDelayedFeedbackEvent extends GoalFeedbackEventBase {
  type: "delayed";
  timingAdjustment: GoalTimingAdjustment;
  date: string | null;
}

export interface GoalStepEditedFeedbackEvent extends GoalFeedbackEventBase {
  type: "edited";
  rewrittenText: string;
}

export interface GoalStepConfusedFeedbackEvent extends GoalFeedbackEventBase {
  type: "confused";
  confusionType: GoalConfusionType;
}

export interface GoalStepSimpleFeedbackEvent extends GoalFeedbackEventBase {
  type:
    | "too_big"
    | "too_easy"
    | "not_relevant"
    | "asked_for_smaller_version"
    | "asked_why_this_matters";
}

export type GoalFeedbackEvent =
  | GoalStepCompletedFeedbackEvent
  | GoalStepSkippedFeedbackEvent
  | GoalStepDelayedFeedbackEvent
  | GoalStepEditedFeedbackEvent
  | GoalStepConfusedFeedbackEvent
  | GoalStepSimpleFeedbackEvent;

export interface GoalFeedbackSignalSnapshot {
  avoidanceCount: number;
  tooBigCount: number;
  confusedCount: number;
  notRelevantCount: number;
  delayedCount: number;
  askedWhyCount: number;
  confidenceScore: number;
  confidenceTrend: "improving" | "eroding" | "flat";
  frictionScore: number;
  toneDriftDetected: boolean;
  rigidityDetected: boolean;
}

export type GoalReplanRecommendationKind =
  | "no_change"
  | "revise_step"
  | "shrink_step"
  | "relax_timing"
  | "request_reclarification"
  | "adjust_plan_tone"
  | "suggest_micro_step"
  | "suggest_alternate_path";

export interface WhyStepMattersExplanationHook {
  prompt: string;
  explanation: string;
}

export interface GoalReplanRecommendationBase {
  kind: GoalReplanRecommendationKind;
  stepId: string;
  rationale: string;
  confidence: number;
  signals: GoalFeedbackSignalSnapshot;
}

export interface GoalNoChangeRecommendation extends GoalReplanRecommendationBase {
  kind: "no_change";
}

export interface GoalReviseStepRecommendation extends GoalReplanRecommendationBase {
  kind: "revise_step";
  rewriteHints: string[];
  evidenceAdjustments: string[];
  explanationHook?: WhyStepMattersExplanationHook;
}

export interface GoalShrinkStepRecommendation extends GoalReplanRecommendationBase {
  kind: "shrink_step";
  smallerVersion: string;
  fallbackMicroStep: string;
}

export interface GoalRelaxTimingRecommendation extends GoalReplanRecommendationBase {
  kind: "relax_timing";
  suggestedTimingType: TimingType;
  removeDeadline: boolean;
}

export interface GoalRequestReclarificationRecommendation extends GoalReplanRecommendationBase {
  kind: "request_reclarification";
  questions: string[];
}

export interface GoalAdjustPlanToneRecommendation extends GoalReplanRecommendationBase {
  kind: "adjust_plan_tone";
  toneGuidance: string[];
}

export interface GoalSuggestMicroStepRecommendation extends GoalReplanRecommendationBase {
  kind: "suggest_micro_step";
  microStep: string;
}

export interface GoalSuggestAlternatePathRecommendation extends GoalReplanRecommendationBase {
  kind: "suggest_alternate_path";
  alternatePath: string;
  explanationHook?: WhyStepMattersExplanationHook;
}

export type GoalReplanRecommendation =
  | GoalNoChangeRecommendation
  | GoalReviseStepRecommendation
  | GoalShrinkStepRecommendation
  | GoalRelaxTimingRecommendation
  | GoalRequestReclarificationRecommendation
  | GoalAdjustPlanToneRecommendation
  | GoalSuggestMicroStepRecommendation
  | GoalSuggestAlternatePathRecommendation;

export interface GoalAdaptivePlanAdjustmentPayload {
  goal: GoalDraft;
  plan: GoalPlan;
  selectedStep: Step;
  recommendation: GoalReplanRecommendation;
  explanationHook?: WhyStepMattersExplanationHook;
}

export type AdaptiveGoalPlanResult = GoalPlannedResult | GoalStarterPlannedResult;

export interface GoalAdaptivePlanInput {
  currentResult: AdaptiveGoalPlanResult;
  selectedStep: Step;
  feedbackHistory: GoalFeedbackEvent[];
}

export function hasPlannableResult(
  result: GoalOrchestrationResult,
): result is AdaptiveGoalPlanResult {
  return result.kind === "planned" || result.kind === "starter_planned";
}

export function createWhyThisMattersExplanation(
  draft: GoalDraft,
  step: Step,
): WhyStepMattersExplanationHook {
  return {
    prompt: "Why does this step matter?",
    explanation:
      draft.mode === GoalMode.DelegatedSupport
        ? `${step.title} matters because it supports ${draft.actor.displayName} without taking ownership away from them.`
        : `${step.title} matters because it advances ${draft.title.toLowerCase()} through a step that can be checked and learned from.`,
  };
}
