import {
  AdaptationPlanningDirectives,
  ExecutionHistorySummary,
  RegressionState,
  ReplanningStyle,
  StrategyStrictness,
} from "../../domain/models";
import { clamp } from "./shared";

export interface StrictnessDecision {
  strictness: StrategyStrictness;
  replanningStyle: ReplanningStyle;
  progressionScore: number;
  balancedReadiness: number;
  directives: AdaptationPlanningDirectives;
}

function windowConfidence(
  summary: ExecutionHistorySummary,
): AdaptationPlanningDirectives["timeWindowConfidences"] {
  return summary.timeOfDayPatterns.map((pattern) => ({
    window: pattern.window,
    confidence: Number(
      clamp(pattern.successRate + (pattern.sampleSize >= 2 ? 0.05 : -0.05), 0.35, 0.9).toFixed(2),
    ),
    explanation: pattern.explanation,
  }));
}

function workTypePreferences(
  summary: ExecutionHistorySummary,
) {
  return summary.timeOfDayPatterns.flatMap((pattern) => {
    const preferences = [];

    if (pattern.preferredForAdmin) {
      preferences.push({
        workType: "admin" as const,
        window: pattern.window,
        confidence: 0.75,
        explanation: `${pattern.window} admin work has been following through reliably.`,
      });
    }

    if (pattern.preferredForDeepWork) {
      preferences.push({
        workType: "deep_work" as const,
        window: pattern.window,
        confidence: 0.72,
        explanation: `${pattern.window} deep work has been performing better than average.`,
      });
    }

    return preferences;
  });
}

export function determineStrictness(
  summary: ExecutionHistorySummary,
  regression: RegressionState,
): StrictnessDecision {
  const mediumLongConfidence = summary.durationPatterns
    .filter((pattern) => pattern.band !== "short")
    .reduce((sum, pattern) => sum + pattern.confidence, 0) / 2;
  const balancedReadiness = clamp(
    summary.recentCompletionRate * 0.42 +
      mediumLongConfidence * 0.2 +
      summary.entryTaskLiftRate * 0.14 +
      (1 - summary.recoveryRelianceRate) * 0.12 +
      (1 - summary.overloadedDayRate) * 0.12,
    0,
    1,
  );
  const progressionScore = clamp(
    balancedReadiness -
      (regression.severity === "active" ? 0.25 : regression.severity === "watch" ? 0.1 : 0),
    0,
    1,
  );
  const strictness =
    regression.isRegressing || balancedReadiness < 0.68
      ? StrategyStrictness.Protective
      : StrategyStrictness.Balanced;
  const directives: AdaptationPlanningDirectives =
    strictness === StrategyStrictness.Balanced
      ? {
          preferredTaskDurationMin: 15,
          preferredTaskDurationMax: 40,
          dailyTaskSoftCap: regression.severity === "watch" ? 5 : 6,
          dailyPlannedMinutesTarget: regression.severity === "watch" ? 130 : 155,
          underpackMinutes: regression.severity === "watch" ? 35 : 25,
          schedulingConfidenceFloor: 0.58,
          earlyWinBias: true,
          preserveMomentumBias: true,
          preferSmallerEntryTasks: true,
          timeWindowConfidences: windowConfidence(summary),
          workTypeSchedulingPreferences: workTypePreferences(summary),
          explanation:
            "Balanced behavior has been earned through recent consistency, so the system can allow slightly fuller days and slightly larger tasks.",
        }
      : {
          preferredTaskDurationMin: 10,
          preferredTaskDurationMax:
            summary.durationPatterns.find((pattern) => pattern.band === "long")?.completionRate ?? 0 < 0.5
              ? 30
              : 35,
          dailyTaskSoftCap: regression.severity === "active" ? 4 : 5,
          dailyPlannedMinutesTarget: regression.severity === "active" ? 95 : 115,
          underpackMinutes: regression.severity === "active" ? 55 : 45,
          schedulingConfidenceFloor: 0.5,
          earlyWinBias: true,
          preserveMomentumBias: true,
          preferSmallerEntryTasks: true,
          timeWindowConfidences: windowConfidence(summary),
          workTypeSchedulingPreferences: workTypePreferences(summary),
          explanation:
            regression.isRegressing
              ? "Recent execution has softened, so the system should protect momentum with lighter days and smaller tasks."
              : "Protective mode remains the default until balanced behavior is earned through stable execution.",
        };

  return {
    strictness,
    replanningStyle:
      strictness === StrategyStrictness.Balanced && regression.severity === "none"
        ? ReplanningStyle.Direct
        : ReplanningStyle.Guided,
    progressionScore: Number(progressionScore.toFixed(2)),
    balancedReadiness: Number(balancedReadiness.toFixed(2)),
    directives,
  };
}
