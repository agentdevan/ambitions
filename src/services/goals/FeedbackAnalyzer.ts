import { GoalMode, GoalTiming, Step, TimingType } from "../../domain/models/goalEngine";
import {
  GoalAdaptivePlanInput,
  GoalFeedbackEvent,
  GoalFeedbackSignalSnapshot,
} from "./goalEngineFeedback";

export interface FeedbackAnalysis {
  signals: GoalFeedbackSignalSnapshot;
  repeatedAvoidance: boolean;
  repeatedConfusion: boolean;
  repeatedIrrelevance: boolean;
  wantsSmallerVersion: boolean;
  asksWhyThisMatters: boolean;
  timingPressureMismatch: boolean;
  shouldReduceLearningPressure: boolean;
  shouldSoftenRecoveryApproach: boolean;
}

function clamp(value: number, min: number, max: number): number {
  return Math.min(max, Math.max(min, value));
}

function stepContainsPunitiveLanguage(step: Step): boolean {
  const combined = `${step.title} ${step.summary ?? ""} ${step.actionability.action}`.toLowerCase();
  return /\b(make sure|make them|ensure|must|should|force|discipline|keep them on track)\b/.test(combined);
}

function timingFeelsRigid(timing: GoalTiming): boolean {
  return timing.timingType === TimingType.DueAt || timing.timingType === TimingType.TargetBy;
}

export class FeedbackAnalyzer {
  analyze(input: GoalAdaptivePlanInput): FeedbackAnalysis {
    const stepEvents = input.feedbackHistory.filter((event) => event.stepId === input.selectedStep.id);
    const avoidanceCount = stepEvents.filter(
      (event) =>
        event.type === "skipped" &&
        ["avoidance", "too_hard", "not_now"].includes(event.reasonCode),
    ).length;
    const tooBigCount = stepEvents.filter(
      (event) => event.type === "too_big" || event.type === "asked_for_smaller_version",
    ).length;
    const confusedCount = stepEvents.filter((event) => event.type === "confused").length;
    const notRelevantCount = stepEvents.filter((event) => event.type === "not_relevant").length;
    const delayedCount = stepEvents.filter((event) => event.type === "delayed").length;
    const askedWhyCount = stepEvents.filter((event) => event.type === "asked_why_this_matters").length;
    const confidenceScore = stepEvents.reduce((score, event) => {
      if (event.type === "completed") {
        return score + (event.confidenceDelta ?? 0);
      }
      if (event.type === "confused" || event.type === "not_relevant") {
        return score - 0.25;
      }
      if (event.type === "skipped") {
        return score - 0.15;
      }
      return score;
    }, 0);
    const frictionScore = clamp(
      avoidanceCount * 0.3 + tooBigCount * 0.35 + confusedCount * 0.28 + delayedCount * 0.14,
      0,
      3,
    );
    const toneDriftDetected =
      input.currentResult.draft.mode === GoalMode.DelegatedSupport &&
      stepContainsPunitiveLanguage(input.selectedStep);
    const rigidityDetected =
      timingFeelsRigid(input.selectedStep.timing) &&
      [GoalMode.Learning, GoalMode.Exploration].includes(input.currentResult.draft.mode);

    return {
      signals: {
        avoidanceCount,
        tooBigCount,
        confusedCount,
        notRelevantCount,
        delayedCount,
        askedWhyCount,
        confidenceScore: Number(confidenceScore.toFixed(2)),
        confidenceTrend:
          confidenceScore > 0.35 ? "improving" : confidenceScore < -0.35 ? "eroding" : "flat",
        frictionScore: Number(frictionScore.toFixed(2)),
        toneDriftDetected,
        rigidityDetected,
      },
      repeatedAvoidance: avoidanceCount >= 2 && tooBigCount >= 1,
      repeatedConfusion: confusedCount >= 2,
      repeatedIrrelevance: notRelevantCount >= 2,
      wantsSmallerVersion: tooBigCount >= 1,
      asksWhyThisMatters: askedWhyCount >= 1,
      timingPressureMismatch:
        delayedCount >= 1 &&
        input.currentResult.draft.timing.tempo === "untimed" &&
        input.selectedStep.timing.timingType !== TimingType.LogWhenDone,
      shouldReduceLearningPressure:
        [GoalMode.Learning, GoalMode.Exploration].includes(input.currentResult.draft.mode) &&
        (rigidityDetected || delayedCount >= 1 || confusedCount >= 1),
      shouldSoftenRecoveryApproach:
        input.currentResult.draft.mode === GoalMode.Recovery &&
        (frozenByFriction(frictionScore) || tooBigCount >= 1 || avoidanceCount >= 1),
    };
  }
}

function frozenByFriction(score: number): boolean {
  return score >= 0.7;
}
