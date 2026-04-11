import {
  AdaptationWorkType,
  DurationRefinementRule,
  Task,
  TaskStatus,
} from "../../domain/models";
import { clamp, roundToFive, workTypeForTask } from "./shared";

function average(values: number[]) {
  if (values.length === 0) {
    return 0;
  }

  return values.reduce((sum, value) => sum + value, 0) / values.length;
}

export function buildDurationRefinementRules(tasks: Task[]): DurationRefinementRule[] {
  const completedTasks = tasks.filter(
    (task) => task.status === TaskStatus.Completed && task.actualMinutes !== null,
  );
  const workTypes: AdaptationWorkType[] = [
    "admin",
    "research",
    "communication",
    "deep_work",
    "routine_action",
    "unknown",
  ];

  return workTypes
    .map((workType) => {
      const items = completedTasks.filter((task) => workTypeForTask(task) === workType);

      if (items.length < 2) {
        return null;
      }

      const averageEstimatedMinutes = average(items.map((task) => task.estimatedMinutes));
      const averageActualMinutes = average(
        items.map((task) => task.actualMinutes ?? task.estimatedMinutes),
      );
      const rawMultiplier = averageActualMinutes / Math.max(1, averageEstimatedMinutes);
      const multiplier = clamp(rawMultiplier, 0.85, 1.2);
      const suggestedAdjustmentMinutes = clamp(
        roundToFive((multiplier - 1) * averageEstimatedMinutes),
        -10,
        10,
      );
      const confidence = clamp(0.45 + items.length * 0.1, 0.45, 0.85);

      if (Math.abs(suggestedAdjustmentMinutes) < 5) {
        return null;
      }

      return {
        workType,
        sampleSize: items.length,
        averageEstimatedMinutes: roundToFive(averageEstimatedMinutes),
        averageActualMinutes: roundToFive(averageActualMinutes),
        multiplier: Number(multiplier.toFixed(2)),
        suggestedAdjustmentMinutes,
        confidence: Number(confidence.toFixed(2)),
        explanation:
          suggestedAdjustmentMinutes > 0
            ? `${workType} tasks have been taking longer than estimated, so future durations should stay slightly larger.`
            : `${workType} tasks have been finishing faster than estimated, so future durations can be trimmed slightly without getting aggressive.`,
      } satisfies DurationRefinementRule;
    })
    .filter((rule): rule is DurationRefinementRule => rule !== null);
}

export function refinementForWorkType(
  rules: DurationRefinementRule[],
  workType: AdaptationWorkType,
) {
  return rules.find((rule) => rule.workType === workType) ?? null;
}
