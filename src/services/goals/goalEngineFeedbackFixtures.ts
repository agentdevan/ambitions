import { Step, TimingType, createGoalTiming } from "../../domain/models/goalEngine";
import { compileGoal } from "./GoalEngineOrchestrator";
import {
  GoalAdaptivePlanInput,
} from "./goalEngineFeedback";
import { GoalPlannedResult, GoalStarterPlannedResult } from "./goalEngineOrchestration";

function assertPlannedResult(
  result: ReturnType<typeof compileGoal>,
): GoalPlannedResult | GoalStarterPlannedResult {
  if (result.kind !== "planned" && result.kind !== "starter_planned") {
    throw new Error(`Expected a plannable result, received ${result.kind}.`);
  }
  return result;
}

function findFirstStep(result: GoalPlannedResult | GoalStarterPlannedResult): Step {
  const step = result.plan.sections.flatMap((section) => section.steps)[0];
  if (!step) {
    throw new Error("Expected a fixture plan with at least one step.");
  }
  return step;
}

const fixedNow = "2026-04-14T12:00:00.000Z";

export const feedbackFixturePlannedAchievement = assertPlannedResult(
  compileGoal("Submit my conference talk proposal by 2026-05-15", { referenceNow: fixedNow }),
);

export const feedbackFixtureLearning = assertPlannedResult(
  compileGoal("Learn how to mix vocals", { referenceNow: fixedNow }),
);

export const feedbackFixtureDelegatedSupport = assertPlannedResult(
  compileGoal("Help my daughter read better", {
    referenceNow: fixedNow,
    actorName: "Maya",
    supportScope: "supporting",
  }),
);

export const feedbackFixtureExploration = assertPlannedResult(
  compileGoal("Figure out if freelancing is right for me", { referenceNow: fixedNow }),
);

export const feedbackFixtureRecovery = assertPlannedResult(
  compileGoal("Get healthier", { referenceNow: fixedNow, preferredPlanningStrictness: "starter_friendly" }),
);

export const feedbackFixtureTimedAchievementInput: GoalAdaptivePlanInput = {
  currentResult: feedbackFixturePlannedAchievement,
  selectedStep: findFirstStep(feedbackFixturePlannedAchievement),
  feedbackHistory: [
    {
      id: "avoidance-1",
      stepId: findFirstStep(feedbackFixturePlannedAchievement).id,
      occurredAt: fixedNow,
      type: "skipped",
      reasonCode: "avoidance",
      note: "Kept putting it off.",
    },
    {
      id: "avoidance-2",
      stepId: findFirstStep(feedbackFixturePlannedAchievement).id,
      occurredAt: "2026-04-15T12:00:00.000Z",
      type: "skipped",
      reasonCode: "too_hard",
      note: "Still feels like too much.",
    },
    {
      id: "too-big",
      stepId: findFirstStep(feedbackFixturePlannedAchievement).id,
      occurredAt: "2026-04-15T12:05:00.000Z",
      type: "too_big",
      note: null,
    },
  ],
};

export const feedbackFixtureLearningConfusionInput: GoalAdaptivePlanInput = {
  currentResult: feedbackFixtureLearning,
  selectedStep: findFirstStep(feedbackFixtureLearning),
  feedbackHistory: [
    {
      id: "confused-1",
      stepId: findFirstStep(feedbackFixtureLearning).id,
      occurredAt: fixedNow,
      type: "confused",
      confusionType: "unclear_action",
      note: "Not sure what to actually do first.",
    },
    {
      id: "confused-2",
      stepId: findFirstStep(feedbackFixtureLearning).id,
      occurredAt: "2026-04-15T12:00:00.000Z",
      type: "confused",
      confusionType: "missing_evidence",
      note: "I don't know what completion looks like.",
    },
  ],
};

const untimedDelayedStep: Step = {
  ...findFirstStep(feedbackFixtureLearning),
  timing: createGoalTiming({
    tempo: feedbackFixtureLearning.draft.timing.tempo,
    timingType: TimingType.SuggestedNext,
    suggestedNextAt: fixedNow,
    progressReviewCadenceDays: feedbackFixtureLearning.draft.timing.progressReviewCadenceDays,
  }),
};

export const feedbackFixtureUntimedTimingPressureInput: GoalAdaptivePlanInput = {
  currentResult: feedbackFixtureLearning,
  selectedStep: untimedDelayedStep,
  feedbackHistory: [
    {
      id: "delayed-1",
      stepId: untimedDelayedStep.id,
      occurredAt: fixedNow,
      type: "delayed",
      timingAdjustment: "remove_deadline",
      date: null,
      note: "I still want this, just not on a deadline.",
    },
  ],
};

const punitiveSupportStep: Step = {
  ...findFirstStep(feedbackFixtureDelegatedSupport),
  title: "Make Maya finish her reading tonight",
  actionability: {
    ...findFirstStep(feedbackFixtureDelegatedSupport).actionability,
    action: "Make sure Maya completes the reading tonight and stays on track.",
  },
};

export const feedbackFixtureDelegatedToneInput: GoalAdaptivePlanInput = {
  currentResult: feedbackFixtureDelegatedSupport,
  selectedStep: punitiveSupportStep,
  feedbackHistory: [
    {
      id: "tone-edit",
      stepId: punitiveSupportStep.id,
      occurredAt: fixedNow,
      type: "edited",
      rewrittenText: punitiveSupportStep.actionability.action,
      note: "This sounds too controlling.",
    },
  ],
};

const rigidExplorationStep: Step = {
  ...findFirstStep(feedbackFixtureExploration),
  timing: createGoalTiming({
    tempo: feedbackFixtureExploration.draft.timing.tempo,
    timingType: TimingType.TargetBy,
    targetBy: "2026-04-18",
    progressReviewCadenceDays: feedbackFixtureExploration.draft.timing.progressReviewCadenceDays,
  }),
};

export const feedbackFixtureExplorationRigidInput: GoalAdaptivePlanInput = {
  currentResult: feedbackFixtureExploration,
  selectedStep: rigidExplorationStep,
  feedbackHistory: [
    {
      id: "exploration-delay",
      stepId: rigidExplorationStep.id,
      occurredAt: fixedNow,
      type: "delayed",
      timingAdjustment: "later_this_week",
      date: "2026-04-19",
      note: "This feels too structured for something exploratory.",
    },
  ],
};

export const feedbackFixtureRecoveryGentleInput: GoalAdaptivePlanInput = {
  currentResult: feedbackFixtureRecovery,
  selectedStep: findFirstStep(feedbackFixtureRecovery),
  feedbackHistory: [
    {
      id: "recovery-skip",
      stepId: findFirstStep(feedbackFixtureRecovery).id,
      occurredAt: fixedNow,
      type: "skipped",
      reasonCode: "avoidance",
      note: "I was overwhelmed.",
    },
    {
      id: "recovery-too-big",
      stepId: findFirstStep(feedbackFixtureRecovery).id,
      occurredAt: "2026-04-15T12:00:00.000Z",
      type: "too_big",
      note: null,
    },
  ],
};
