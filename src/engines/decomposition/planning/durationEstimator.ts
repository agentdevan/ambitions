import { AdaptationProfile, DomainKey, TaskDifficulty } from "../../../domain/models";
import {
  GoalPlanningAnalysis,
  PlanningPolicy,
  PlanningWorkType,
} from "../../../domain/models/planningBrain";
import { clamp, roundToFive } from "./date";
import { DurationEstimate } from "./types";
import { refinementForWorkType } from "../../adaptation/durationRefinement";

const baseMinutesByWorkType: Record<PlanningWorkType, number> = {
  [PlanningWorkType.Admin]: 10,
  [PlanningWorkType.Research]: 20,
  [PlanningWorkType.Communication]: 15,
  [PlanningWorkType.DeepWork]: 35,
  [PlanningWorkType.RoutineAction]: 15,
};

const domainAdjustmentByWorkType: Partial<
  Record<DomainKey, Partial<Record<PlanningWorkType, number>>>
> = {
  [DomainKey.Credit]: {
    [PlanningWorkType.Research]: 5,
    [PlanningWorkType.Admin]: 5,
  },
  [DomainKey.Finance]: {
    [PlanningWorkType.Research]: 5,
  },
  [DomainKey.Career]: {
    [PlanningWorkType.DeepWork]: 5,
    [PlanningWorkType.Communication]: 5,
  },
  [DomainKey.SkillBuilding]: {
    [PlanningWorkType.DeepWork]: 5,
  },
};

export function estimateTaskDuration(params: {
  domainKey: DomainKey;
  workType: PlanningWorkType;
  novelty: "low" | "medium" | "high";
  analysis: GoalPlanningAnalysis;
  policy: PlanningPolicy;
  adaptationProfile?: AdaptationProfile | null;
}): DurationEstimate {
  const reasons: string[] = [];
  let minutes = baseMinutesByWorkType[params.workType];

  reasons.push(`Base duration from work type: ${params.workType}.`);

  const domainAdjustment = domainAdjustmentByWorkType[params.domainKey]?.[params.workType] ?? 0;
  if (domainAdjustment !== 0) {
    minutes += domainAdjustment;
    reasons.push(`Adjusted for ${params.domainKey} task overhead.`);
  }

  if (params.novelty === "high") {
    minutes += 10;
    reasons.push("Novel work gets extra setup time.");
  } else if (params.novelty === "medium") {
    minutes += 5;
    reasons.push("Moderate novelty adds a small buffer.");
  } else {
    reasons.push("Low novelty keeps the estimate tighter.");
  }

  if (params.policy.shorterWhenUncertain && params.novelty === "high") {
    minutes -= 5;
    reasons.push("Protective mode trims the session to keep the first step executable.");
  }

  if (
    params.analysis.classification.complexity === "high" &&
    params.workType === PlanningWorkType.DeepWork
  ) {
    minutes += 5;
    reasons.push("High-complexity deep work gets a small extension.");
  }

  const refinement = refinementForWorkType(
    params.adaptationProfile?.durationRefinements ?? [],
    String(params.workType) as Parameters<typeof refinementForWorkType>[1],
  );

  if (refinement && refinement.confidence >= 0.55) {
    minutes += refinement.suggestedAdjustmentMinutes;
    reasons.push(refinement.explanation);
  }

  minutes = clamp(roundToFive(minutes), 5, params.policy.preferredTaskDurationMax);

  const difficulty =
    minutes > 30 || params.workType === PlanningWorkType.DeepWork
      ? TaskDifficulty.Deep
      : minutes > 15
        ? TaskDifficulty.Moderate
        : TaskDifficulty.Light;

  const effortPoints =
    difficulty === TaskDifficulty.Light
      ? 1
      : difficulty === TaskDifficulty.Moderate
        ? 2
        : 3;

  return {
    minutes,
    difficulty,
    effortPoints,
    reasons,
  };
}
