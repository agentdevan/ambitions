import {
  AdaptationProfile,
  CapacityLoad,
  EntitySyncState,
  ExecutionHistorySummary,
  PersonalizationProfile,
  RegressionState,
  ReplanningStyle,
  StrategyStrictness,
  UserPreferences,
} from "../../domain/models";
import { preferredWindowStart, roundToFive } from "./shared";
import { StrictnessDecision } from "./strictnessPolicy";

function preferredStartWindow(summary: ExecutionHistorySummary, fallback: string) {
  const preferred = [...summary.timeOfDayPatterns]
    .filter((pattern) => pattern.sampleSize >= 2)
    .sort((left, right) => right.successRate - left.successRate)[0];

  return preferred ? preferredWindowStart(preferred.window) : fallback;
}

function commonBlockers(summary: ExecutionHistorySummary) {
  const blockers = new Set<string>();

  for (const friction of summary.taskTypeFriction) {
    for (const marker of friction.markers) {
      if (marker === "large_sessions_break") blockers.add("large sessions break down");
      if (marker === "startup_friction") blockers.add("task startup friction");
      if (marker === "needs_smaller_recovery") blockers.add("repeated need for smaller recovery");
      if (marker === "underestimated_duration") blockers.add("durations skew optimistic");
    }
  }

  if (blockers.size === 0) {
    blockers.add("over-scoping");
  }

  return [...blockers].slice(0, 4);
}

function recentWinPattern(summary: ExecutionHistorySummary) {
  if (summary.entryTaskLiftRate >= 0.6) {
    return "Early entry-task wins are improving the odds of completing more than one task in the day.";
  }

  const eveningAdmin = summary.timeOfDayPatterns.find(
    (pattern) => pattern.window === "evening" && pattern.preferredForAdmin,
  );

  if (eveningAdmin) {
    return "Short evening admin tasks have been completing reliably enough to use them as clean follow-through blocks.";
  }

  if (summary.missedStartCollapseRate >= 0.3) {
    return "The first planned task still matters disproportionately, so the day should open with something easy to start.";
  }

  return "Execution is responding best to smaller, concrete steps rather than broad sessions.";
}

function mentalLoad(summary: ExecutionHistorySummary, regression: RegressionState) {
  if (regression.severity === "active" || summary.overloadedDayRate >= 0.34) {
    return CapacityLoad.Strained;
  }

  if (summary.recentCompletionRate >= 0.78 && summary.carryoverPressureRate <= 0.18) {
    return CapacityLoad.Low;
  }

  return CapacityLoad.Balanced;
}

function defaultPersonalization(): PersonalizationProfile {
  return {
    active: false,
    sampleSize: 0,
    taskSizingStyle: "mixed_tasks",
    openWindowStyle: "mixed",
    lateDayStyle: "steady",
    carryoverStyle: "moderate",
    planStability: "adjusting",
    intensityStyle: "balanced",
    recoveryStyle: "moderate",
    bestFocusWindow: null,
    signals: [],
    summary: {
      planningStyle: "Adaptation will tighten once there is enough real history.",
      todayApproach: "Recommendations stay conservative while recent patterns are still shallow.",
      insights: "Reflection stays close to simple recent activity until history deepens.",
    },
    explanation:
      "Adaptation will tighten once there is enough real history.",
  };
}

export function createDefaultProfile(date: string, preferences: UserPreferences): AdaptationProfile {
  const timestamp = new Date().toISOString();

  return {
    id: `adaptation-${date}`,
    ownerUserId: null,
    remoteId: null,
    syncState: EntitySyncState.LocalOnly,
    version: 1,
    lastSyncedAt: null,
    createdAt: timestamp,
    updatedAt: timestamp,
    effectiveDate: date,
    source: "observed",
    capacity: {
      mentalLoad: CapacityLoad.Balanced,
      focusBudgetMinutes: preferences.defaultFocusSessionMinutes * 2,
      meetingLoadMinutes: 0,
      recoveryBudgetMinutes: preferences.defaultBreakMinutes + 20,
    },
    completion: {
      consistencyScore: 0.5,
      rolloverRate: 0.2,
      averageTaskCompletionMinutes: null,
    },
    friction: {
      switchingPenaltyMinutes: 10,
      preferredStartWindow: preferences.dailyPlanningTime ?? "08:30",
      commonBlockers: ["over-scoping"],
    },
    momentum: {
      currentStreakDays: 0,
      recentWinPattern: "Protect the first believable win before asking for more.",
      confidenceScore: 0.5,
    },
    strategy: {
      strictness: StrategyStrictness.Protective,
      replanningStyle: ReplanningStyle.Guided,
      progressionScore: 0.3,
      balancedReadiness: 0.3,
    },
    history: {
      sampleSize: 0,
      recentWindowSize: 0,
      recentCompletionRate: 0,
      baselineCompletionRate: 0,
      averageCompletedMinutes: null,
      averageCompletedDurationBand: null,
      carryoverPressureRate: 0,
      recoveryRelianceRate: 0,
      splitRecoverySuccessRate: null,
      substituteRecoverySuccessRate: null,
      missedStartCollapseRate: 0,
      entryTaskLiftRate: 0,
      overloadedDayRate: 0,
      domainPatterns: [],
      timeOfDayPatterns: [],
      durationPatterns: [],
      taskTypeFriction: [],
    },
    regression: {
      severity: "none",
      isRegressing: false,
      triggers: [],
      explanation:
        "No regression signal yet because there is not enough execution history.",
    },
    personalization: defaultPersonalization(),
    durationRefinements: [],
    planningDirectives: {
      preferredTaskDurationMin: 10,
      preferredTaskDurationMax: 30,
      dailyTaskSoftCap: 4,
      dailyPlannedMinutesTarget: preferences.defaultFocusSessionMinutes * 2,
      underpackMinutes: 45,
      schedulingConfidenceFloor: 0.5,
      earlyWinBias: true,
      preserveMomentumBias: true,
      preferSmallerEntryTasks: true,
      timeWindowConfidences: [],
      workTypeSchedulingPreferences: [],
      explanation:
        "Protective mode is the starting point until execution history earns a fuller plan.",
    },
    metadata: {
      createdFrom: "default_profile",
    },
  };
}

export function updateAdaptationProfile(params: {
  date: string;
  preferences: UserPreferences;
  priorProfile: AdaptationProfile | null;
  history: ExecutionHistorySummary;
  personalization: PersonalizationProfile;
  streakDays: number;
  regression: RegressionState;
  strictness: StrictnessDecision;
  durationRefinements: AdaptationProfile["durationRefinements"];
}): AdaptationProfile {
  const base = params.priorProfile ?? createDefaultProfile(params.date, params.preferences);
  const timestamp = new Date().toISOString();
  const focusBudgetMinutes = Math.max(
    75,
    Math.min(
      params.strictness.directives.dailyPlannedMinutesTarget,
      (params.history.averageCompletedMinutes ?? params.preferences.defaultFocusSessionMinutes) *
        (params.strictness.strictness === StrategyStrictness.Balanced ? 3 : 2),
    ),
  );
  const switchingPenaltyMinutes = Math.max(
    5,
    Math.min(
      20,
      8 +
        params.history.taskTypeFriction.filter((entry) => entry.frictionScore >= 0.45).length * 3,
    ),
  );
  const rolloverRate = Number(
    (
      (params.history.carryoverPressureRate + params.history.recoveryRelianceRate) /
      2
    ).toFixed(2),
  );
  const momentumConfidence = Math.max(
    0.35,
    Math.min(
      0.88,
      params.history.recentCompletionRate * 0.55 +
        params.history.entryTaskLiftRate * 0.15 +
        (1 - params.history.missedStartCollapseRate) * 0.2 +
        (params.strictness.strictness === StrategyStrictness.Balanced ? 0.08 : 0),
    ),
  );

  return {
    ...base,
    updatedAt: timestamp,
    effectiveDate: params.date,
    source: "observed",
    capacity: {
      mentalLoad: mentalLoad(params.history, params.regression),
      focusBudgetMinutes: roundToFive(focusBudgetMinutes),
      meetingLoadMinutes: base.capacity.meetingLoadMinutes,
      recoveryBudgetMinutes: Math.max(
        20,
        roundToFive(
          params.preferences.defaultBreakMinutes +
            params.strictness.directives.underpackMinutes / 2,
        ),
      ),
    },
    completion: {
      consistencyScore: params.history.recentCompletionRate,
      rolloverRate,
      averageTaskCompletionMinutes: params.history.averageCompletedMinutes,
    },
    friction: {
      switchingPenaltyMinutes,
      preferredStartWindow: preferredStartWindow(
        params.history,
        params.preferences.dailyPlanningTime ?? base.friction.preferredStartWindow,
      ),
      commonBlockers: commonBlockers(params.history),
    },
    momentum: {
      currentStreakDays: params.streakDays,
      recentWinPattern: recentWinPattern(params.history),
      confidenceScore: Number(momentumConfidence.toFixed(2)),
    },
    strategy: {
      strictness: params.strictness.strictness,
      replanningStyle: params.strictness.replanningStyle,
      progressionScore: params.strictness.progressionScore,
      balancedReadiness: params.strictness.balancedReadiness,
    },
    history: params.history,
    regression: params.regression,
    personalization: params.personalization,
    durationRefinements: params.durationRefinements,
    planningDirectives: params.strictness.directives,
    metadata: {
      ...base.metadata,
      lastExplainedAt: timestamp,
      planningDirectiveExplanation: params.strictness.directives.explanation,
      regressionExplanation: params.regression.explanation,
      personalizationExplanation: params.personalization.explanation,
    },
  };
}
