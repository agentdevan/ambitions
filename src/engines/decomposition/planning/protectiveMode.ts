import { AdaptationProfile, StrategyStrictness } from "../../../domain/models";
import { PlanningMode, PlanningPolicy } from "../../../domain/models/planningBrain";

export function buildPlanningPolicy(
  mode: PlanningMode = PlanningMode.Protective,
  adaptationProfile: AdaptationProfile | null = null,
): PlanningPolicy {
  const directives = adaptationProfile?.planningDirectives ?? null;

  if (mode === PlanningMode.Balanced) {
    return {
      mode,
      strictness: StrategyStrictness.Balanced,
      dailyTaskSoftCap: directives?.dailyTaskSoftCap ?? 5,
      maxTasksPerMilestone: 4,
      preferredTaskDurationMax: directives?.preferredTaskDurationMax ?? 45,
      earlyWinBias: directives?.earlyWinBias ?? true,
      shorterWhenUncertain: false,
      reduceVolumeUnderUncertainty: false,
      prefersSmallerEntryTasks: directives?.preferSmallerEntryTasks ?? false,
    };
  }

  return {
    mode: PlanningMode.Protective,
    strictness: StrategyStrictness.Protective,
    dailyTaskSoftCap: directives?.dailyTaskSoftCap ?? 3,
    maxTasksPerMilestone: 3,
    preferredTaskDurationMax: directives?.preferredTaskDurationMax ?? 30,
    earlyWinBias: directives?.earlyWinBias ?? true,
    shorterWhenUncertain: true,
    reduceVolumeUnderUncertainty: true,
    prefersSmallerEntryTasks: directives?.preferSmallerEntryTasks ?? true,
  };
}
