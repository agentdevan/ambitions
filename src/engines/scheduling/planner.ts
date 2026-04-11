import {
  DailyPlan,
  DailyPlanStatus,
  EntitySyncState,
  StrategyStrictness,
  Task,
  TaskDifficulty,
  TaskSchedulingState,
  TaskStatus,
  TimeBlock,
  TimeBlockState,
  TimeBlockType,
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
  priorityScore: number;
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

function buildCandidates(tasks: Task[], protectiveMode: boolean) {
  return tasks
    .filter((task) => ![TaskStatus.Completed, TaskStatus.Cancelled].includes(task.status))
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
      if (task.title.toLowerCase().startsWith("review the current signal")) priorityScore -= 10;
      if (task.title.toLowerCase().startsWith("choose the next lower-friction adjustment")) priorityScore -= 6;

      return {
        task,
        flexibility,
        splitEligible,
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

function findPlacement(task: CandidateTask, windows: UsableTimeWindow[], protectiveMode: boolean) {
  return findPlacementWithPreference(task, windows, protectiveMode, null);
}

function findPlacementWithPreference(
  task: CandidateTask,
  windows: UsableTimeWindow[],
  protectiveMode: boolean,
  preferredStartTime: string | null,
) {
  const requiredMinutes =
    protectiveMode && task.task.difficulty === TaskDifficulty.Deep
      ? task.task.estimatedMinutes + 10
      : task.task.estimatedMinutes;
  const preferredStartMinutes = preferredStartTime ? timeToMinutes(preferredStartTime) : null;

  let shortenedWindow: UsableTimeWindow | null = null;

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

      return {
        window: {
          ...window,
          startTime: buildIso("1970-01-01", adjustedStart).slice(11, 16),
          minutes: adjustedMinutes,
        },
        scheduledMinutes: task.task.estimatedMinutes,
        reason:
          window.kind === "lunch"
            ? "Placed into the explicit lunch window."
            : "Placed into the first believable open window without crowding the day.",
      };
    }

    if (!shortenedWindow && task.splitEligible && adjustedMinutes >= Math.max(15, task.task.estimatedMinutes - 15)) {
      shortenedWindow = {
        ...window,
        startTime: buildIso("1970-01-01", adjustedStart).slice(11, 16),
        minutes: adjustedMinutes,
      };
    }
  }

  if (shortenedWindow) {
    return {
      window: shortenedWindow,
      scheduledMinutes: Math.min(task.task.estimatedMinutes, shortenedWindow.minutes),
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
    ),
    unusedCapacityMinutes: Math.max(0, params.totalUsableMinutes - params.scheduledMinutes),
    overloadWarning:
      params.unscheduledDemandMinutes > Math.max(60, params.totalUsableMinutes / 2),
    protectiveMode: params.protectiveMode,
  } satisfies SchedulingSignals;
}

function buildPlan(request: SchedulingRequest, scheduledTasks: ScheduledTaskWindow[], signals: SchedulingSignals) {
  const existing = request.existingPlan;
  const timestamp = new Date().toISOString();

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
        ? `Protect ${scheduledTasks[0].title.toLowerCase()} first, then stop before the day gets crowded.`
        : "Keep the day light and preserve only the work that clearly fits."),
    planningNotes: signals.overloadWarning
      ? "Demand exceeds believable capacity, so only the most executable subset was scheduled."
      : "The day is intentionally underpacked to preserve follow-through.",
    totalPlannedMinutes: scheduledTasks.reduce((sum, task) => sum + task.durationMinutes, 0),
    totalCommittedMinutes: scheduledTasks.reduce((sum, task) => sum + task.durationMinutes, 0),
    adaptationProfileId: request.adaptationProfile?.id ?? null,
    metadata: {
      planPressure: signals.planPressure,
      rolloverPressure: signals.rolloverPressure,
      schedulingConfidence: Number(signals.schedulingConfidence.toFixed(2)),
      unusedCapacityMinutes: signals.unusedCapacityMinutes,
      overloadWarning: signals.overloadWarning,
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
  const strictness = request.adaptationProfile?.strategy.strictness ?? StrategyStrictness.Protective;
  const interpretedConstraints = interpretConstraints({
    date: request.date,
    constraints: request.constraints,
    preferences: request.preferences,
    adaptationProfile: request.adaptationProfile,
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
    request.adaptationProfile?.friction.preferredStartWindow ??
    request.preferences.dailyPlanningTime ??
    null;
  const focusBudget = request.adaptationProfile?.capacity.focusBudgetMinutes
    ? request.adaptationProfile.capacity.focusBudgetMinutes + 30
    : request.preferences.defaultFocusSessionMinutes * 3;
  const reservedCapacity = protectiveMode
    ? Math.max(45, Math.round(capacity.capacitySummary.totalUsableMinutes * 0.25))
    : Math.max(20, Math.round(capacity.capacitySummary.totalUsableMinutes * 0.12));
  const scheduledMinuteCap = Math.max(
    60,
    Math.min(capacity.capacitySummary.totalUsableMinutes - reservedCapacity, focusBudget),
  );
  const scheduledTaskCap = protectiveMode ? 5 : 7;

  for (const candidate of buildCandidates(request.tasks, protectiveMode)) {
    const minutesAlreadyScheduled = scheduledTasks.reduce((sum, task) => sum + task.durationMinutes, 0);

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
      confidence: Math.min(0.94, placement.window.confidence + (candidate.priorityScore / 200)),
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
  });
  const dailyPlan = buildPlan(request, scheduledTasks, signals);

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
