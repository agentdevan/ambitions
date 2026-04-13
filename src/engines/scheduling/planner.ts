import {
  AdaptationPlanningDirectives,
  DailyPlan,
  DailyPlanStatus,
  EntitySyncState,
  TimeOfDayWindow,
  StrategyStrictness,
  Task,
  TaskDifficulty,
  TaskSchedulingState,
  TaskStatus,
  TimeBlock,
  TimeBlockState,
  TimeBlockType,
  WeeklyCarryoverPosture,
  WeeklyEmphasis,
  WeeklyIntensity,
} from "../../domain/models";
import {
  SchedulingOutput,
  SchedulingRequest,
  SchedulingSignals,
  ScheduledTaskWindow,
  UnscheduledReasonCode,
  UnscheduledTask,
  UsableTimeWindow,
} from "../types";
import { buildCapacityOutput, deriveUsableWindows } from "./capacityCalculator";
import { interpretConstraints } from "./constraintInterpreter";
import { buildIso, timeToMinutes } from "./time";

interface CandidateTask {
  task: Task;
  flexibility: "high" | "medium" | "low";
  splitEligible: boolean;
  workType: string;
  priorityScore: number;
}

function weeklyIntensityModifier(intensity: WeeklyIntensity | null | undefined) {
  if (intensity === WeeklyIntensity.Lighter) {
    return { minuteDelta: -25, taskDelta: -1 };
  }

  if (intensity === WeeklyIntensity.Fuller) {
    return { minuteDelta: 20, taskDelta: 1 };
  }

  return { minuteDelta: 0, taskDelta: 0 };
}

function determineFocusGoalId(tasks: Task[], weekStartDate: string) {
  const scores = new Map<string, number>();

  tasks.forEach((task) => {
    if (!task.goalId) {
      return;
    }

    const score =
      (task.targetDate && task.targetDate >= weekStartDate ? 3 : 0) +
      (task.schedulingState === TaskSchedulingState.Rolled ? 4 : 0) +
      (task.status === TaskStatus.InProgress ? 5 : 0) +
      (task.status === TaskStatus.Ready || task.status === TaskStatus.Scheduled ? 2 : 0);
    scores.set(task.goalId, (scores.get(task.goalId) ?? 0) + score);
  });

  return [...scores.entries()].sort((left, right) => right[1] - left[1])[0]?.[0] ?? null;
}

function bucketForTime(time: string): TimeOfDayWindow {
  const hour = Number(time.slice(0, 2));

  if (hour < 10) return "morning";
  if (hour < 14) return "midday";
  if (hour < 18) return "afternoon";
  return "evening";
}

function directivesForProfile(profile: SchedulingRequest["adaptationProfile"]) {
  return (
    profile?.planningDirectives ?? {
      preferredTaskDurationMin: 10,
      preferredTaskDurationMax: 30,
      dailyTaskSoftCap: 5,
      dailyPlannedMinutesTarget: 120,
      underpackMinutes: 45,
      schedulingConfidenceFloor: 0.5,
      earlyWinBias: true,
      preserveMomentumBias: true,
      preferSmallerEntryTasks: true,
      timeWindowConfidences: [],
      workTypeSchedulingPreferences: [],
      explanation:
        "No adaptation directives are available yet, so scheduling stays protective by default.",
    }
  ) satisfies AdaptationPlanningDirectives;
}

function adaptivePlanningEnabled(preferences: SchedulingRequest["preferences"]) {
  const raw = preferences.metadata.adaptivePlanningEnabled;
  return raw !== false && raw !== "false";
}

function isEntryTask(task: Task) {
  const lower = task.title.toLowerCase();

  return (
    task.estimatedMinutes <= 20 &&
    ["choose", "pick", "set up", "start ", "open ", "minimum"].some((token) =>
      lower.includes(token),
    )
  );
}

function timeWindowConfidence(
  directives: AdaptationPlanningDirectives,
  workType: string,
  startTime: string,
) {
  const bucket = bucketForTime(startTime);
  const specific =
    directives.workTypeSchedulingPreferences.find(
      (preference) => preference.workType === workType && preference.window === bucket,
    )?.confidence ?? null;
  const general =
    directives.timeWindowConfidences.find((window) => window.window === bucket)?.confidence ??
    directives.schedulingConfidenceFloor;

  return specific ?? general;
}

function blockTypeForTask(task: Task) {
  const workType = String(task.metadata.planningWorkType ?? "");

  if (workType === "admin" || workType === "communication") {
    return TimeBlockType.Admin;
  }

  if (task.difficulty === TaskDifficulty.Light) {
    return TimeBlockType.Buffer;
  }

  return TimeBlockType.Focus;
}

function buildCandidates(
  tasks: Task[],
  protectiveMode: boolean,
  directives: AdaptationPlanningDirectives,
  request: SchedulingRequest,
) {
  const weeklyState = request.weeklyReviewState;
  const focusGoalId =
    weeklyState?.weeklyEmphasis === WeeklyEmphasis.PushMeaningfulArea
      ? determineFocusGoalId(tasks, weeklyState.weekStartDate)
      : null;

  return tasks
    .filter((task) =>
      [
        TaskStatus.Ready,
        TaskStatus.Unscheduled,
        TaskStatus.Scheduled,
        TaskStatus.Deferred,
      ].includes(task.status),
    )
    .map((task) => {
      const flexibility = String(task.metadata.planningFlexibility ?? "medium") as
        | "high"
        | "medium"
        | "low";
      const splitEligible =
        task.metadata.planningSplitEligible === true || task.metadata.planningSplitEligible === "true";
      const workType = String(task.metadata.planningWorkType ?? "");
      let priorityScore = 0;

      if (task.schedulingState === TaskSchedulingState.Rolled) priorityScore += 20;
      if (workType === "deep_work") priorityScore += 18;
      if (workType === "routine_action") priorityScore += 8;
      if (task.difficulty === TaskDifficulty.Light) priorityScore += 6;
      if (task.difficulty === TaskDifficulty.Moderate) priorityScore += 7;
      if (task.goalId) priorityScore += 4;
      if (task.targetDate) priorityScore += 4;
      if (protectiveMode && task.estimatedMinutes <= 30) priorityScore += 4;
      if (protectiveMode && task.estimatedMinutes > 50) priorityScore -= 10;
      if (task.estimatedMinutes > directives.preferredTaskDurationMax) priorityScore -= 14;
      if (directives.earlyWinBias && isEntryTask(task)) priorityScore += 10;
      if (directives.preferSmallerEntryTasks && task.estimatedMinutes <= 20) priorityScore += 4;
      if (task.title.toLowerCase().startsWith("review the current signal")) priorityScore -= 10;
      if (task.title.toLowerCase().startsWith("choose the next lower-friction adjustment")) priorityScore -= 6;
      if (weeklyState?.weeklyEmphasis === WeeklyEmphasis.ProtectEssentials) {
        if (task.status === TaskStatus.InProgress) priorityScore += 18;
        if (task.schedulingState === TaskSchedulingState.Rolled) priorityScore += 10;
        if (task.targetDate && task.targetDate <= request.date) priorityScore += 12;
      }
      if (
        weeklyState?.weeklyEmphasis === WeeklyEmphasis.PushMeaningfulArea &&
        focusGoalId &&
        task.goalId === focusGoalId
      ) {
        priorityScore += 22;
      }
      if (
        weeklyState?.carryoverPosture === WeeklyCarryoverPosture.EssentialsOnly &&
        task.schedulingState === TaskSchedulingState.Rolled &&
        task.status !== TaskStatus.InProgress &&
        task.metadata.weeklyCarryoverReviewedAt === undefined
      ) {
        priorityScore -= 16;
      }
      if (
        weeklyState?.carryoverPosture === WeeklyCarryoverPosture.ReviewFirst &&
        task.metadata.weeklyCarryoverDisposition === "review"
      ) {
        priorityScore -= 18;
      }
      if (
        weeklyState?.carryoverPosture === WeeklyCarryoverPosture.Aggressive &&
        task.schedulingState === TaskSchedulingState.Rolled
      ) {
        priorityScore += 8;
      }

      return {
        task,
        flexibility,
        splitEligible,
        workType,
        priorityScore,
      } satisfies CandidateTask;
    })
    .sort((left, right) => {
      if (right.priorityScore !== left.priorityScore) {
        return right.priorityScore - left.priorityScore;
      }

      return left.task.estimatedMinutes - right.task.estimatedMinutes;
    });
}

function findPlacement(
  task: CandidateTask,
  windows: UsableTimeWindow[],
  protectiveMode: boolean,
  directives: AdaptationPlanningDirectives,
  profile: SchedulingRequest["adaptationProfile"],
) {
  return findPlacementWithPreference(task, windows, protectiveMode, null, directives, profile);
}

function findPlacementWithPreference(
  task: CandidateTask,
  windows: UsableTimeWindow[],
  protectiveMode: boolean,
  preferredStartTime: string | null,
  directives: AdaptationPlanningDirectives,
  profile: SchedulingRequest["adaptationProfile"],
) {
  const personalization = profile?.personalization.active ? profile.personalization : null;
  const requiredMinutes =
    protectiveMode && task.task.difficulty === TaskDifficulty.Deep
      ? task.task.estimatedMinutes + 10
      : task.task.estimatedMinutes;
  const preferredStartMinutes = preferredStartTime ? timeToMinutes(preferredStartTime) : null;

  let shortenedWindow: UsableTimeWindow | null = null;

  type PlacementCandidate = {
    window: UsableTimeWindow;
    adjustedStart: number;
    adjustedMinutes: number;
    confidence: number;
  };

  const exactFits: PlacementCandidate[] = [];

  for (const window of windows) {
    const rawStart = timeToMinutes(window.startTime);
    const rawEnd = timeToMinutes(window.endTime);
    const adjustedStart =
      preferredStartMinutes && window.kind === "core" && rawStart < preferredStartMinutes
        ? Math.min(preferredStartMinutes, rawEnd)
        : rawStart;
    const adjustedMinutes = Math.max(0, rawEnd - adjustedStart);

    if (adjustedMinutes >= requiredMinutes) {
      if (task.flexibility === "low" && window.kind === "lunch") {
        continue;
      }

      const windowBucket = bucketForTime(buildIso("1970-01-01", adjustedStart).slice(11, 16));
      if (
        personalization?.lateDayStyle === "avoid_late_heavy" &&
        windowBucket === "evening" &&
        (task.workType === "deep_work" || task.task.estimatedMinutes >= 35)
      ) {
        continue;
      }

      exactFits.push({
        window,
        adjustedStart,
        adjustedMinutes,
        confidence: timeWindowConfidence(
          directives,
          task.workType,
          buildIso("1970-01-01", adjustedStart).slice(11, 16),
        ),
      });
      continue;
    }

    if (!shortenedWindow && task.splitEligible && adjustedMinutes >= Math.max(15, task.task.estimatedMinutes - 15)) {
      shortenedWindow = {
        ...window,
        startTime: buildIso("1970-01-01", adjustedStart).slice(11, 16),
        minutes: adjustedMinutes,
      };
    }
  }

  const bestFit = exactFits.sort((left, right) => {
    if (right.confidence !== left.confidence) {
      return right.confidence - left.confidence;
    }

    return left.adjustedStart - right.adjustedStart;
  })[0];

  if (bestFit) {
    return {
      window: {
        ...bestFit.window,
        startTime: buildIso("1970-01-01", bestFit.adjustedStart).slice(11, 16),
        minutes: bestFit.adjustedMinutes,
      },
      scheduledMinutes: task.task.estimatedMinutes,
      confidence: bestFit.confidence,
      reason:
        bestFit.window.kind === "lunch"
          ? "Placed into the explicit lunch window."
          : "Placed into the most believable open window based on recent execution patterns.",
    };
  }

  if (shortenedWindow) {
    return {
      window: shortenedWindow,
      scheduledMinutes: Math.min(task.task.estimatedMinutes, shortenedWindow.minutes),
      confidence: timeWindowConfidence(directives, task.workType, shortenedWindow.startTime),
      reason: "Shortened to fit the largest realistic window instead of forcing the day to stretch.",
    };
  }

  return null;
}

function consumeWindow(window: UsableTimeWindow, scheduledMinutes: number) {
  const nextStart = timeToMinutes(window.startTime) + scheduledMinutes;
  const remaining = window.minutes - scheduledMinutes;

  if (remaining < 10) {
    return null;
  }

  return {
    ...window,
    startTime: buildIso("1970-01-01", nextStart).slice(11, 16),
    minutes: remaining,
  } satisfies UsableTimeWindow;
}

function unscheduledReasonCode(
  task: CandidateTask,
  windows: UsableTimeWindow[],
  protectiveMode: boolean,
): UnscheduledReasonCode {
  const totalMinutes = windows.reduce((sum, window) => sum + window.minutes, 0);

  if (windows.every((window) => window.minutes < Math.min(task.task.estimatedMinutes, 15))) {
    return "window_too_short";
  }

  if (protectiveMode && task.task.estimatedMinutes > 50) {
    return "protected_from_overload";
  }

  if (totalMinutes >= task.task.estimatedMinutes && windows.length > 2) {
    return "window_too_fragmented";
  }

  if (totalMinutes < task.task.estimatedMinutes) {
    return "insufficient_capacity";
  }

  return "deprioritized_for_realism";
}

function unscheduledReasonText(code: UnscheduledReasonCode, task: Task) {
  switch (code) {
    case "window_too_short":
      return `${task.title} needs a longer uninterrupted window than today leaves open.`;
    case "window_too_fragmented":
      return `${task.title} could fit only by scattering the day, so it was left unscheduled.`;
    case "protected_from_overload":
      return `${task.title} was held back to keep the day executable under protective planning.`;
    case "insufficient_capacity":
      return `There is not enough believable time left for ${task.title.toLowerCase()}.`;
    default:
      return `${task.title} was left out so the plan stays realistic instead of maximally full.`;
  }
}

function buildSignals(params: {
  scheduledMinutes: number;
  totalUsableMinutes: number;
  unscheduledDemandMinutes: number;
  unscheduledTasks: UnscheduledTask[];
  protectiveMode: boolean;
  directives: AdaptationPlanningDirectives;
}) {
  const occupancy =
    params.totalUsableMinutes === 0 ? 1 : params.scheduledMinutes / params.totalUsableMinutes;
  const planPressure: SchedulingSignals["planPressure"] =
    occupancy >= 0.82 ? "high" : occupancy >= 0.58 ? "moderate" : "low";
  const rolloverPressure: SchedulingSignals["rolloverPressure"] =
    params.unscheduledDemandMinutes >= 120
      ? "high"
      : params.unscheduledDemandMinutes >= 45
        ? "moderate"
        : "low";

  return {
    planPressure,
    rolloverPressure,
    schedulingConfidence: Math.max(
      0.45,
      0.92 -
        (params.unscheduledTasks.length * 0.05) -
        (planPressure === "high" ? 0.08 : 0) -
        (params.protectiveMode ? 0.04 : 0),
      params.directives.schedulingConfidenceFloor,
    ),
    unusedCapacityMinutes: Math.max(0, params.totalUsableMinutes - params.scheduledMinutes),
    overloadWarning:
      params.unscheduledDemandMinutes > Math.max(60, params.totalUsableMinutes / 2),
    protectiveMode: params.protectiveMode,
  } satisfies SchedulingSignals;
}

function buildPlan(
  request: SchedulingRequest,
  scheduledTasks: ScheduledTaskWindow[],
  signals: SchedulingSignals,
  directives: AdaptationPlanningDirectives,
) {
  const effectiveProfile =
    adaptivePlanningEnabled(request.preferences) ? request.adaptationProfile : null;
  const existing = request.existingPlan;
  const timestamp = new Date().toISOString();
  const regression = effectiveProfile?.regression;
  const weeklyState = request.weeklyReviewState;
  const weeklyEmphasisNote =
    weeklyState?.weeklyEmphasis === WeeklyEmphasis.ProtectEssentials
      ? "This week is protecting essentials first."
      : weeklyState?.weeklyEmphasis === WeeklyEmphasis.PushMeaningfulArea
        ? "This week is concentrating pressure into one meaningful area."
        : weeklyState?.weeklyEmphasis === WeeklyEmphasis.SteadyProgress
          ? "This week is aiming for steady progress over sharp swings."
          : null;

  return {
    id: existing?.id ?? `generated-plan-${request.date}`,
    ownerUserId: existing?.ownerUserId ?? null,
    remoteId: existing?.remoteId ?? null,
    syncState: existing?.syncState ?? EntitySyncState.LocalOnly,
    version: existing?.version ?? 1,
    lastSyncedAt: existing?.lastSyncedAt ?? null,
    createdAt: existing?.createdAt ?? timestamp,
    updatedAt: timestamp,
    date: request.date,
    status: DailyPlanStatus.Ready,
    focus:
      existing?.focus ??
      (scheduledTasks[0]
        ? directives.earlyWinBias
          ? `Start with ${scheduledTasks[0].title.toLowerCase()} and let the rest of the day stay earned.`
          : `Protect ${scheduledTasks[0].title.toLowerCase()} first, then stop before the day gets crowded.`
        : "Keep the day light and preserve only the work that clearly fits."),
    planningNotes:
      regression?.isRegressing
        ? "Recent execution has softened, so the plan is intentionally lighter to preserve momentum."
        : signals.overloadWarning
          ? "Demand exceeds believable capacity, so only the most executable subset was scheduled."
          : weeklyEmphasisNote ?? "The day is intentionally underpacked to preserve follow-through.",
    totalPlannedMinutes: scheduledTasks.reduce((sum, task) => sum + task.durationMinutes, 0),
    totalCommittedMinutes: scheduledTasks.reduce((sum, task) => sum + task.durationMinutes, 0),
    adaptationProfileId: effectiveProfile?.id ?? null,
    metadata: {
      planPressure: signals.planPressure,
      rolloverPressure: signals.rolloverPressure,
      schedulingConfidence: Number(signals.schedulingConfidence.toFixed(2)),
      unusedCapacityMinutes: signals.unusedCapacityMinutes,
      overloadWarning: signals.overloadWarning,
      adaptationDirectiveExplanation: directives.explanation,
      regressionSeverity: regression?.severity ?? "none",
    },
  } satisfies DailyPlan;
}

function buildBlocks(
  request: SchedulingRequest,
  dailyPlanId: string,
  scheduledTasks: ScheduledTaskWindow[],
) {
  const timestamp = new Date().toISOString();

  return scheduledTasks.map((scheduledTask, index) => {
    const task = request.tasks.find((entry) => entry.id === scheduledTask.taskId);

    return {
      id: `scheduled-block-${request.date}-${index + 1}`,
      ownerUserId: null,
      remoteId: null,
      syncState: EntitySyncState.LocalOnly,
      version: 1,
      lastSyncedAt: null,
      createdAt: timestamp,
      updatedAt: timestamp,
      dailyPlanId,
      taskId: scheduledTask.taskId,
      goalId: scheduledTask.goalId,
      title: scheduledTask.title,
      type: task ? blockTypeForTask(task) : TimeBlockType.Focus,
      state: TimeBlockState.Scheduled,
      startsAt: scheduledTask.startsAtTime,
      endsAt: scheduledTask.endsAtTime,
      startsAtDateTime: scheduledTask.startsAt,
      endsAtDateTime: scheduledTask.endsAt,
      note: scheduledTask.reason,
      energyLabel: task?.difficulty ?? TaskDifficulty.Moderate,
      sourceConstraintId: null,
      metadata: {
        windowId: scheduledTask.windowId,
        confidence: Number(scheduledTask.confidence.toFixed(2)),
      },
    } satisfies TimeBlock;
  });
}

export function buildDailySchedule(request: SchedulingRequest): SchedulingOutput {
  const effectiveProfile =
    adaptivePlanningEnabled(request.preferences) ? request.adaptationProfile : null;
  const strictness = effectiveProfile?.strategy.strictness ?? StrategyStrictness.Protective;
  const directives = directivesForProfile(effectiveProfile);
  const interpretedConstraints = interpretConstraints({
    date: request.date,
    constraints: request.constraints,
    preferences: request.preferences,
    adaptationProfile: effectiveProfile,
  });
  const rawUsableWindows = deriveUsableWindows(interpretedConstraints, strictness);
  const capacity = buildCapacityOutput({
    interpretedConstraints,
    usableWindows: rawUsableWindows,
    preferences: request.preferences,
    strictness,
  });
  const protectiveMode = strictness === StrategyStrictness.Protective;
  const scheduledTasks: ScheduledTaskWindow[] = [];
  const unscheduledTasks: UnscheduledTask[] = [];
  const windows = rawUsableWindows.map((window) => ({ ...window }));
  const preferredStartTime =
    effectiveProfile?.friction.preferredStartWindow ??
    request.preferences.dailyPlanningTime ??
    null;
  const personalization =
    effectiveProfile?.personalization.active ? effectiveProfile.personalization : null;
  const focusBudget = effectiveProfile?.capacity.focusBudgetMinutes
    ? effectiveProfile.capacity.focusBudgetMinutes + 30
    : request.preferences.defaultFocusSessionMinutes * 3;
  const reservedCapacity = Math.max(
    directives.underpackMinutes,
    Math.round(
      capacity.capacitySummary.totalUsableMinutes * (protectiveMode ? 0.22 : 0.12),
    ),
  );
  const scheduledMinuteCap = Math.max(
    60,
    Math.min(
      capacity.capacitySummary.totalUsableMinutes - reservedCapacity,
      Math.min(
        focusBudget,
        directives.dailyPlannedMinutesTarget +
          weeklyIntensityModifier(request.weeklyReviewState?.targetWeekIntensity).minuteDelta +
          (personalization?.intensityStyle === "high" ? 10 : personalization?.intensityStyle === "light" ? -10 : 0),
      ),
    ),
  );
  const scheduledTaskCap = Math.max(
    2,
    directives.dailyTaskSoftCap + weeklyIntensityModifier(request.weeklyReviewState?.targetWeekIntensity).taskDelta,
  );

  for (const candidate of buildCandidates(request.tasks, protectiveMode, directives, request)) {
    const minutesAlreadyScheduled = scheduledTasks.reduce((sum, task) => sum + task.durationMinutes, 0);

    if (candidate.task.estimatedMinutes > directives.preferredTaskDurationMax + (protectiveMode ? 0 : 5)) {
      unscheduledTasks.push({
        taskId: candidate.task.id,
        goalId: candidate.task.goalId,
        title: candidate.task.title,
        estimatedMinutes: candidate.task.estimatedMinutes,
        reasonCode: "protected_from_overload",
        reason: `${candidate.task.title} was held back because recent execution supports smaller task sizes right now.`,
      });
      continue;
    }

    if (
      scheduledTasks.length >= scheduledTaskCap ||
      minutesAlreadyScheduled + Math.min(candidate.task.estimatedMinutes, 20) > scheduledMinuteCap
    ) {
      unscheduledTasks.push({
        taskId: candidate.task.id,
        goalId: candidate.task.goalId,
        title: candidate.task.title,
        estimatedMinutes: candidate.task.estimatedMinutes,
        reasonCode: protectiveMode ? "protected_from_overload" : "deprioritized_for_realism",
        reason: protectiveMode
          ? `${candidate.task.title} was held out so the day keeps real slack instead of filling every open minute.`
          : `${candidate.task.title} was left for another day so this plan stays believable.`,
      });
      continue;
    }

    const placement = findPlacementWithPreference(
      candidate,
      windows,
      protectiveMode,
      preferredStartTime,
      directives,
      effectiveProfile,
    );

    if (!placement) {
      const reasonCode = unscheduledReasonCode(candidate, windows, protectiveMode);
      unscheduledTasks.push({
        taskId: candidate.task.id,
        goalId: candidate.task.goalId,
        title: candidate.task.title,
        estimatedMinutes: candidate.task.estimatedMinutes,
        reasonCode,
        reason: unscheduledReasonText(reasonCode, candidate.task),
      });
      continue;
    }

    const startsAtMinutes = timeToMinutes(placement.window.startTime);
    const endsAtMinutes = startsAtMinutes + placement.scheduledMinutes;

    scheduledTasks.push({
      taskId: candidate.task.id,
      goalId: candidate.task.goalId,
      title: candidate.task.title,
      startsAt: buildIso(request.date, startsAtMinutes),
      endsAt: buildIso(request.date, endsAtMinutes),
      startsAtTime: buildIso(request.date, startsAtMinutes).slice(11, 16),
      endsAtTime: buildIso(request.date, endsAtMinutes).slice(11, 16),
      durationMinutes: placement.scheduledMinutes,
      windowId: placement.window.id,
      confidence: Math.min(
        0.94,
        placement.window.confidence + (candidate.priorityScore / 200) + placement.confidence * 0.1,
      ),
      reason: placement.reason,
    });

    const nextWindow = consumeWindow(placement.window, placement.scheduledMinutes);
    const windowIndex = windows.findIndex((window) => window.id === placement.window.id);

    if (windowIndex >= 0) {
      if (nextWindow) {
        windows[windowIndex] = nextWindow;
      } else {
        windows.splice(windowIndex, 1);
      }
    }
  }

  const scheduledMinutes = scheduledTasks.reduce((sum, task) => sum + task.durationMinutes, 0);
  const unscheduledDemandMinutes = unscheduledTasks.reduce((sum, task) => sum + task.estimatedMinutes, 0);

  capacity.capacitySummary.scheduledMinutes = scheduledMinutes;
  capacity.capacitySummary.unscheduledDemandMinutes = unscheduledDemandMinutes;
  capacity.capacitySummary.unusedCapacityMinutes = Math.max(
    0,
    capacity.capacitySummary.totalUsableMinutes - scheduledMinutes,
  );
  capacity.capacitySummary.overloadMinutes = Math.max(
    0,
    unscheduledDemandMinutes - capacity.capacitySummary.unusedCapacityMinutes,
  );

  const signals = buildSignals({
    scheduledMinutes,
    totalUsableMinutes: capacity.capacitySummary.totalUsableMinutes,
    unscheduledDemandMinutes,
    unscheduledTasks,
    protectiveMode,
    directives,
  });
  const dailyPlan = buildPlan(request, scheduledTasks, signals, directives);

  return {
    dailyPlan,
    timeBlocks: buildBlocks(request, dailyPlan.id, scheduledTasks),
    scheduledTasks,
    unscheduledTasks,
    capacitySummary: capacity.capacitySummary,
    interpretedConstraints,
    usableWindows: rawUsableWindows.map((window) => ({
      ...window,
      start: buildIso(request.date, timeToMinutes(window.startTime)),
      end: buildIso(request.date, timeToMinutes(window.endTime)),
    })),
    signals,
    context: {
      strictness,
      workdayLabel:
        interpretedConstraints.find((constraint) => constraint.kind === "work")?.title ?? null,
      usableWindowCount: rawUsableWindows.length,
      hardConstraintCount: interpretedConstraints.filter(
        (constraint) => constraint.disposition === "hard_constraint",
      ).length,
      softConstraintCount: interpretedConstraints.filter(
        (constraint) => constraint.disposition === "soft_constraint",
      ).length,
      warnings: signals.overloadWarning
        ? ["Demand exceeds believable capacity, so some tasks were intentionally left unscheduled."]
        : [],
    },
  };
}
