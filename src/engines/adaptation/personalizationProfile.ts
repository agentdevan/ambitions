import {
  AdaptationPlanningDirectives,
  PersonalizationProfile,
  PersonalizationSignal,
  StrategyStrictness,
  TimeOfDayWindow,
} from "../../domain/models";
import { StrictnessDecision } from "./strictnessPolicy";
import { InterpretedExecutionHistory } from "./historyInterpreter";
import { clamp } from "./shared";

function rate(numerator: number, denominator: number) {
  if (denominator <= 0) {
    return 0;
  }

  return numerator / denominator;
}

function average(values: number[]) {
  if (values.length === 0) {
    return null;
  }

  return values.reduce((sum, value) => sum + value, 0) / values.length;
}

function topWindow(history: InterpretedExecutionHistory): TimeOfDayWindow | null {
  const preferredDeep = history.summary.timeOfDayPatterns
    .filter((pattern) => pattern.preferredForDeepWork && pattern.sampleSize >= 2)
    .sort((left, right) => right.successRate - left.successRate)[0];

  if (preferredDeep) {
    return preferredDeep.window;
  }

  const preferredAny = history.summary.timeOfDayPatterns
    .filter((pattern) => pattern.sampleSize >= 2)
    .sort((left, right) => right.successRate - left.successRate)[0];

  return preferredAny?.window ?? null;
}

function buildSignal(params: {
  key: PersonalizationSignal["key"];
  label: string;
  value: string;
  confidence: number;
  sampleSize: number;
  explanation: string;
}): PersonalizationSignal {
  return {
    ...params,
    confidence: Number(clamp(params.confidence, 0.35, 0.95).toFixed(2)),
  };
}

export function buildPersonalizationProfile(
  history: InterpretedExecutionHistory,
): PersonalizationProfile {
  const sampleSize = history.summary.sampleSize;
  const active = sampleSize >= 6;
  const shortPattern = history.summary.durationPatterns.find((pattern) => pattern.band === "short");
  const mediumPattern = history.summary.durationPatterns.find((pattern) => pattern.band === "medium");
  const longPattern = history.summary.durationPatterns.find((pattern) => pattern.band === "long");
  const completedMinutes = history.records
    .filter((record) => record.outcome === "completed")
    .map((record) => record.actualMinutes ?? record.estimatedMinutes);
  const averageCompletedMinutes = average(completedMinutes) ?? 25;
  const eveningHeavy = history.records.filter(
    (record) =>
      record.timeWindow === "evening" &&
      (record.workType === "deep_work" || record.durationBand === "long"),
  );
  const eveningHeavyDisruptions = eveningHeavy.filter((record) =>
    ["deferred", "missed", "split", "substituted"].includes(record.outcome),
  ).length;
  const shortCompletion = shortPattern?.completionRate ?? 0;
  const mediumCompletion = mediumPattern?.completionRate ?? 0;
  const longCompletion = longPattern?.completionRate ?? 0;
  const bestFocusWindow = topWindow(history);

  const taskSizingStyle =
    !active || averageCompletedMinutes <= 24 || shortCompletion >= Math.max(mediumCompletion + 0.08, 0.68)
      ? "shorter_tasks"
      : longCompletion >= 0.64 && history.summary.carryoverPressureRate <= 0.22
        ? "deeper_blocks"
        : "mixed_tasks";
  const openWindowStyle =
    taskSizingStyle === "shorter_tasks"
      ? "short_bursts"
      : taskSizingStyle === "deeper_blocks"
        ? "deep_windows"
        : averageCompletedMinutes >= 25 && averageCompletedMinutes <= 40
          ? "medium_blocks"
          : "mixed";
  const lateDayDisruptionRate = rate(eveningHeavyDisruptions, eveningHeavy.length);
  const lateDayStyle =
    eveningHeavy.length < 3
      ? "steady"
      : lateDayDisruptionRate >= 0.55
        ? "avoid_late_heavy"
        : lateDayDisruptionRate >= 0.3
          ? "lighter_late"
          : "steady";
  const carryoverStyle =
    history.summary.carryoverPressureRate >= 0.4
      ? "high"
      : history.summary.carryoverPressureRate >= 0.22
        ? "moderate"
        : "low";
  const planStability =
    history.summary.overloadedDayRate >= 0.38 || history.summary.carryoverPressureRate >= 0.38
      ? "volatile"
      : history.summary.overloadedDayRate >= 0.2 || history.summary.carryoverPressureRate >= 0.2
        ? "adjusting"
        : "stable";
  const intensityStyle =
    history.summary.overloadedDayRate >= 0.34 || history.summary.recoveryRelianceRate >= 0.34
      ? "light"
      : longCompletion >= 0.62 && history.summary.recentCompletionRate >= 0.72
        ? "high"
        : "balanced";
  const recoveryStyle =
    history.summary.recoveryRelianceRate >= 0.35
      ? "high"
      : history.summary.recoveryRelianceRate >= 0.18
        ? "moderate"
        : "low";

  const signals: PersonalizationSignal[] = [
    buildSignal({
      key: "task_sizing",
      label: "Task sizing",
      value:
        taskSizingStyle === "shorter_tasks"
          ? "Shorter tasks are landing better."
          : taskSizingStyle === "deeper_blocks"
            ? "Deeper blocks can hold."
            : "A mixed task shape is working.",
      confidence:
        taskSizingStyle === "deeper_blocks" ? longPattern?.confidence ?? 0.45 : shortPattern?.confidence ?? 0.45,
      sampleSize:
        taskSizingStyle === "deeper_blocks" ? longPattern?.sampleSize ?? sampleSize : shortPattern?.sampleSize ?? sampleSize,
      explanation:
        taskSizingStyle === "shorter_tasks"
          ? "Recent completions are clustering in shorter sessions, so planning should keep entry costs low."
          : taskSizingStyle === "deeper_blocks"
            ? "Longer sessions have been holding well enough to allow deeper work when time supports it."
            : "Completion is spread across short and medium work, so planning should stay balanced rather than extreme.",
    }),
    buildSignal({
      key: "open_window_fit",
      label: "Open windows",
      value:
        openWindowStyle === "short_bursts"
          ? "Short open windows are usable."
          : openWindowStyle === "deep_windows"
            ? "Wider windows can carry meaningful work."
            : openWindowStyle === "medium_blocks"
              ? "Medium windows are the cleanest fit."
              : "Window fit is still mixed.",
      confidence:
        openWindowStyle === "deep_windows" ? longPattern?.confidence ?? 0.45 : mediumPattern?.confidence ?? 0.45,
      sampleSize: sampleSize,
      explanation:
        openWindowStyle === "short_bursts"
          ? "Open time should usually turn into smaller useful wins rather than full sessions."
          : openWindowStyle === "deep_windows"
            ? "When enough room exists, longer sessions are realistic and worth protecting."
            : openWindowStyle === "medium_blocks"
              ? "The best fit is usually a deliberate medium session rather than a tiny task or a very deep block."
              : "Open time should stay flexible until a clearer fit emerges.",
    }),
    buildSignal({
      key: "late_day_pattern",
      label: "Late-day pattern",
      value:
        lateDayStyle === "avoid_late_heavy"
          ? "Late heavy work often carries forward."
          : lateDayStyle === "lighter_late"
            ? "Late work lands better when lighter."
            : "Late-day work is reasonably steady.",
      confidence: eveningHeavy.length >= 3 ? 0.72 : 0.4,
      sampleSize: eveningHeavy.length,
      explanation:
        lateDayStyle === "avoid_late_heavy"
          ? "Heavier evening work is being deferred or broken apart too often to keep recommending it."
          : lateDayStyle === "lighter_late"
            ? "The later part of the day should lean toward lighter work and carry less ambition."
            : "There is not enough late-day drag to strongly suppress later recommendations.",
    }),
    buildSignal({
      key: "plan_stability",
      label: "Plan stability",
      value:
        planStability === "stable"
          ? "Plans usually stay fairly steady."
          : planStability === "volatile"
            ? "Plans have been shifting a lot."
            : "Plans need some room to adjust.",
      confidence: 0.68,
      sampleSize: history.daySummaries.length,
      explanation:
        planStability === "stable"
          ? "The planner can be a little more deliberate because recent days are not churning."
          : planStability === "volatile"
            ? "The planner should preserve more slack and avoid overcommitting days that already reshape often."
            : "Recent days are neither fully stable nor highly volatile, so the planner should keep moderate slack.",
    }),
    buildSignal({
      key: "intensity_tolerance",
      label: "Intensity",
      value:
        intensityStyle === "light"
          ? "Lighter pacing is safer right now."
          : intensityStyle === "high"
            ? "A fuller day can still hold."
            : "Balanced intensity is the better fit.",
      confidence: Number(clamp(history.summary.recentCompletionRate, 0.42, 0.84).toFixed(2)),
      sampleSize: sampleSize,
      explanation:
        intensityStyle === "light"
          ? "Recent overload or recovery dependence suggests lighter pacing will preserve follow-through."
          : intensityStyle === "high"
            ? "Recent completion and deeper-block follow-through support a slightly fuller day."
            : "Recent behavior supports moderate intensity, not aggressive filling or heavy underpacking.",
    }),
  ];

  const planningStyle =
    !active
      ? "Adaptation is still learning from a small set of recent work."
      : taskSizingStyle === "shorter_tasks"
        ? "Shorter blocks are working better lately."
        : taskSizingStyle === "deeper_blocks"
          ? "You can hold deeper blocks when they have real room."
          : "A calmer mix of short and medium work fits best lately.";
  const todayApproach =
    !active
      ? "Keep recommendations conservative until more history builds."
      : lateDayStyle === "avoid_late_heavy"
        ? "Later recommendations should stay lighter unless there is unusual room."
        : openWindowStyle === "short_bursts"
          ? "Open time should lean toward quick useful wins."
          : openWindowStyle === "deep_windows"
            ? "Wider windows can be used for more meaningful sessions."
            : "Recommendation shape should stay balanced across short and medium work.";
  const insights =
    !active
      ? "Insights should stay close to simple recent patterns."
      : carryoverStyle === "high"
        ? "Carryover rises quickly after heavier days, so reflection should keep pacing realistic."
        : planStability === "stable"
          ? "Recent plans are staying relatively steady, which supports slightly more deliberate follow-through."
          : "Reflection should note both progress and reshaping without overreacting.";

  return {
    active,
    sampleSize,
    taskSizingStyle,
    openWindowStyle,
    lateDayStyle,
    carryoverStyle,
    planStability,
    intensityStyle,
    recoveryStyle,
    bestFocusWindow,
    signals,
    summary: {
      planningStyle,
      todayApproach,
      insights,
    },
    explanation: [planningStyle, todayApproach, insights].join(" "),
  };
}

export function applyPersonalizationToDirectives(params: {
  directives: AdaptationPlanningDirectives;
  personalization: PersonalizationProfile;
  strictness: StrategyStrictness;
}): AdaptationPlanningDirectives {
  const { directives, personalization, strictness } = params;

  if (!personalization.active) {
    return directives;
  }

  let preferredTaskDurationMax = directives.preferredTaskDurationMax;
  let dailyTaskSoftCap = directives.dailyTaskSoftCap;
  let dailyPlannedMinutesTarget = directives.dailyPlannedMinutesTarget;
  let underpackMinutes = directives.underpackMinutes;

  if (personalization.taskSizingStyle === "shorter_tasks") {
    preferredTaskDurationMax = Math.min(preferredTaskDurationMax, 30);
    dailyTaskSoftCap += 1;
    dailyPlannedMinutesTarget -= 10;
    underpackMinutes += 10;
  } else if (personalization.taskSizingStyle === "deeper_blocks") {
    preferredTaskDurationMax = Math.max(preferredTaskDurationMax, 40);
    dailyTaskSoftCap = Math.max(3, dailyTaskSoftCap - 1);
    dailyPlannedMinutesTarget += 10;
  }

  if (personalization.planStability === "volatile" || personalization.carryoverStyle === "high") {
    dailyTaskSoftCap = Math.max(3, dailyTaskSoftCap - 1);
    dailyPlannedMinutesTarget -= 15;
    underpackMinutes += 15;
  } else if (personalization.planStability === "stable" && personalization.intensityStyle === "high") {
    dailyPlannedMinutesTarget += 10;
    underpackMinutes = Math.max(20, underpackMinutes - 5);
  }

  if (personalization.intensityStyle === "light") {
    dailyPlannedMinutesTarget -= 10;
    underpackMinutes += 10;
  }

  const explanationParts = [
    directives.explanation,
    personalization.summary.planningStyle,
  ];

  if (personalization.lateDayStyle !== "steady") {
    explanationParts.push("Later heavier work is being treated more cautiously.");
  }

  return {
    ...directives,
    preferredTaskDurationMax,
    dailyTaskSoftCap,
    dailyPlannedMinutesTarget,
    underpackMinutes,
    preferSmallerEntryTasks:
      directives.preferSmallerEntryTasks || personalization.taskSizingStyle === "shorter_tasks",
    preserveMomentumBias:
      directives.preserveMomentumBias || personalization.carryoverStyle !== "low",
    explanation: explanationParts.join(" "),
  };
}

export function personalizeStrictnessDecision(params: {
  decision: StrictnessDecision;
  personalization: PersonalizationProfile;
}): StrictnessDecision {
  return {
    ...params.decision,
    directives: applyPersonalizationToDirectives({
      directives: params.decision.directives,
      personalization: params.personalization,
      strictness: params.decision.strictness,
    }),
  };
}
