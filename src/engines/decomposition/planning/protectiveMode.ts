import { AdaptationProfile, StrategyStrictness } from "../../../domain/models";
import { PlanningMode, PlanningPolicy } from "../../../domain/models/planningBrain";

export function buildPlanningPolicy(
  mode: PlanningMode = PlanningMode.Protective,
  adaptationProfile: AdaptationProfile | null = null,
): PlanningPolicy {
  const directives = adaptationProfile?.planningDirectives ?? null;

  if (mode === PlanningMode.Aggressive) {
    return {
      mode,
      strictness: StrategyStrictness.Flexible,
      dailyTaskSoftCap: Math.max(5, directives?.dailyTaskSoftCap ?? 5),
      maxTasksPerMilestone: 5,
      preferredTaskDurationMax: Math.max(50, directives?.preferredTaskDurationMax ?? 50),
      earlyWinBias: true,
      shorterWhenUncertain: false,
      reduceVolumeUnderUncertainty: false,
      prefersSmallerEntryTasks: false,
    };
  }

  if (mode === PlanningMode.Balanced) {
    return {
      mode,
      strictness: StrategyStrictness.Balanced,
      dailyTaskSoftCap: Math.max(4, directives?.dailyTaskSoftCap ?? 4),
      maxTasksPerMilestone: 4,
      preferredTaskDurationMax: Math.max(40, directives?.preferredTaskDurationMax ?? 40),
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
