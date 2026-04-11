import { StrategyStrictness } from "../../../domain/models";
import { PlanningMode, PlanningPolicy } from "../../../domain/models/planningBrain";

export function buildPlanningPolicy(mode: PlanningMode = PlanningMode.Protective): PlanningPolicy {
  if (mode === PlanningMode.Balanced) {
    return {
      mode,
      strictness: StrategyStrictness.Balanced,
      dailyTaskSoftCap: 5,
      maxTasksPerMilestone: 4,
      preferredTaskDurationMax: 45,
      earlyWinBias: true,
      shorterWhenUncertain: false,
      reduceVolumeUnderUncertainty: false,
      prefersSmallerEntryTasks: false,
    };
  }

  return {
    mode: PlanningMode.Protective,
    strictness: StrategyStrictness.Protective,
    dailyTaskSoftCap: 3,
    maxTasksPerMilestone: 3,
    preferredTaskDurationMax: 30,
    earlyWinBias: true,
    shorterWhenUncertain: true,
    reduceVolumeUnderUncertainty: true,
    prefersSmallerEntryTasks: true,
  };
}
