import {
  AdaptationProfile,
  CalendarConnectionState,
  DailyPlan,
  Goal,
  MonthlyReviewState,
  ScheduleConstraint,
  ScheduleConstraintType,
  StrategyStrictness,
  Task,
  TaskSchedulingState,
  TaskStatus,
  TimeBlock,
  TimeBlockType,
  UserPreferences,
  WeeklyReviewState,
} from "../../domain/models";
import { buildCapacityOutput, deriveUsableWindows } from "../../engines/scheduling/capacityCalculator";
import { interpretConstraints } from "../../engines/scheduling/constraintInterpreter";
import { deriveWeeklyDefaultsFromMonthlyStrategy } from "../../services/planning/monthlyStrategy";
import { describeMonthlyStrategy } from "../../services/history/monthly";
import { describeWeeklyShape } from "../../services/history/weekly";
import {
  addDays,
  endOfWeek,
  formatShortDate,
  formatTimeRangeLabel,
  formatWeekdayDate,
  startOfWeek,
} from "../../utils/date";

export interface PlanStructureItem {
  id: string;
  title: string;
  detail: string;
  supporting: string;
}

export interface PlanDaySummary {
  date: string;
  label: string;
  fixedCount: number;
  fixedMinutes: number;
  scheduledMinutes: number;
  focusMinutes: number;
  openMinutes: number;
  meaningfulWindowCount: number;
  isTight: boolean;
}

export interface PlanWorkspaceViewModel {
  weekStartDate: string;
  weekEndDate: string;
  weekLabel: string;
  heroTitle: string;
  heroDetail: string;
  pressureLabel: "Balanced" | "Tight" | "Overloaded";
  pressureDetail: string;
  pressureTone: "accent" | "neutral" | "quiet";
  structureSummary: {
    fixedCommitmentCount: number;
    fixedCommitmentMinutes: number;
    flexibleWorkCount: number;
    optionalWorkCount: number;
    carryoverCount: number;
    protectedFocusBlockCount: number;
    protectedFocusMinutes: number;
    underPressureCount: number;
  };
  capacitySummary: {
    totalUsableMinutes: number;
    scheduledWorkMinutes: number;
    openCapacityMinutes: number;
    meaningfulWindowCount: number;
    largestOpenWindowMinutes: number;
    largestOpenWindowLabel: string | null;
    fragmentationLabel: "Protected" | "Mixed" | "Fragmented";
    fragmentationDetail: string;
    weeklyLoadDetail: string;
  };
  carryoverSummary: {
    enteringCount: number;
    unresolvedCount: number;
    protectedCount: number;
    reviewCount: number;
    releasedCount: number;
    detail: string;
  };
  strategySummary: {
    sourceLabel: "Explicit this week" | "Monthly default" | "Planner default";
    weeklyShape: string;
    monthlyInfluence: string | null;
    carryoverLabel: string;
    detail: string;
  };
  structuralReads: string[];
  fixedCommitments: PlanStructureItem[];
  flexibleWork: PlanStructureItem[];
  optionalWork: PlanStructureItem[];
  pressureItems: PlanStructureItem[];
  carryoverItems: PlanStructureItem[];
  protectedFocusItems: PlanStructureItem[];
  days: PlanDaySummary[];
  shouldOpenWeeklyReview: boolean;
}

function isTaskOpen(task: Task) {
  return ![TaskStatus.Completed, TaskStatus.Cancelled].includes(task.status);
}

function clampMinutes(value: number) {
  return Math.max(0, Math.round(value));
}

function countHoursAndMinutes(totalMinutes: number) {
  const hours = Math.floor(totalMinutes / 60);
  const minutes = totalMinutes % 60;

  if (hours <= 0) {
    return `${minutes}m`;
  }

  if (minutes === 0) {
    return `${hours}h`;
  }

  return `${hours}h ${minutes}m`;
}

function getTaskFlexibility(task: Task) {
  return String(task.metadata.planningFlexibility ?? "medium");
}

function getTaskWorkType(task: Task) {
  return String(task.metadata.planningWorkType ?? "");
}

function isOptionalTask(task: Task) {
  const flexibility = getTaskFlexibility(task);
  const workType = getTaskWorkType(task);

  return (
    flexibility === "high" ||
    workType === "admin" ||
    workType === "communication" ||
    workType === "routine_action"
  );
}

function isTaskInWeek(task: Task, weekStartDate: string, weekEndDate: string) {
  return (
    (task.targetDate !== null && task.targetDate >= weekStartDate && task.targetDate <= weekEndDate) ||
    (task.scheduledDate !== null &&
      task.scheduledDate >= weekStartDate &&
      task.scheduledDate <= weekEndDate) ||
    String(task.metadata.weeklyCarryoverWeekStart ?? "") === weekStartDate
  );
}

function overlapsDateRange(startsAt: string, endsAt: string, date: string) {
  const dayStart = Date.parse(`${date}T00:00:00.000Z`);
  const dayEnd = Date.parse(`${date}T23:59:59.999Z`);
  const itemStart = Date.parse(startsAt);
  const itemEnd = Date.parse(endsAt);

  return itemStart <= dayEnd && itemEnd >= dayStart;
}

function minutesWithinDateRange(startsAt: string, endsAt: string, date: string) {
  const dayStart = Date.parse(`${date}T00:00:00.000Z`);
  const dayEnd = Date.parse(`${date}T23:59:59.999Z`);
  const itemStart = Date.parse(startsAt);
  const itemEnd = Date.parse(endsAt);
  const overlapStart = Math.max(dayStart, itemStart);
  const overlapEnd = Math.min(dayEnd, itemEnd);

  if (overlapEnd <= overlapStart) {
    return 0;
  }

  return clampMinutes((overlapEnd - overlapStart) / 60000);
}

function summarizeTask(task: Task) {
  const workType = getTaskWorkType(task);
  const parts = [
    task.estimatedMinutes ? `${task.estimatedMinutes} min` : null,
    workType === "deep_work"
      ? "Deep work"
      : workType === "research"
        ? "Research"
        : workType === "communication"
          ? "Communication"
          : workType === "admin"
            ? "Admin"
            : workType === "routine_action"
              ? "Routine"
              : null,
    task.targetDate ? `Target ${formatShortDate(task.targetDate)}` : null,
  ].filter((value): value is string => Boolean(value));

  return parts.join(" • ");
}

function summarizeConstraint(constraint: ScheduleConstraint) {
  const date = constraint.startsAt.slice(0, 10);

  if (constraint.isAllDay) {
    return `${formatWeekdayDate(date)} • All day`;
  }

  return `${formatWeekdayDate(date)} • ${formatTimeRangeLabel(
    constraint.startsAt.slice(11, 16),
    constraint.endsAt.slice(11, 16),
    { compact: true },
  )}`;
}

export function buildPlanWorkspaceViewModel(params: {
  date: string;
  goals: Goal[];
  preferences: UserPreferences | null;
  adaptationProfile: AdaptationProfile | null;
  dailyPlans: DailyPlan[];
  timeBlocks: TimeBlock[];
  tasks: Task[];
  weekScheduleConstraints: ScheduleConstraint[];
  currentWeekReview: WeeklyReviewState | null;
  currentMonthReview: MonthlyReviewState | null;
  calendarConnectionState: CalendarConnectionState | null;
}) {
  if (!params.preferences) {
    return null;
  }

  const weekStartDate = startOfWeek(params.date, params.preferences.weekStartsOn ?? 1);
  const weekEndDate = endOfWeek(params.date, params.preferences.weekStartsOn ?? 1);
  const weekDates = Array.from({ length: 7 }, (_, index) => addDays(weekStartDate, index));
  const weekPlanIds = new Set(
    params.dailyPlans
      .filter((plan) => plan.date >= weekStartDate && plan.date <= weekEndDate)
      .map((plan) => plan.id),
  );
  const weekBlocks = params.timeBlocks.filter((block) => weekPlanIds.has(block.dailyPlanId));
  const weekTasks = params.tasks.filter((task) => isTaskInWeek(task, weekStartDate, weekEndDate));
  const openWeekTasks = weekTasks.filter(isTaskOpen);
  const carryoverTaskIds = new Set(params.currentWeekReview?.carryoverTaskIds ?? []);
  const reviewTaskIds = new Set(params.currentWeekReview?.reviewTaskIds ?? []);
  const releasedTaskIds = new Set(params.currentWeekReview?.releasedTaskIds ?? []);
  const scheduledTaskIds = new Set(weekBlocks.map((block) => block.taskId).filter(Boolean));
  const monthlyDefaults = deriveWeeklyDefaultsFromMonthlyStrategy(params.currentMonthReview);
  const effectiveIntensity =
    params.currentWeekReview?.targetWeekIntensity ?? monthlyDefaults?.targetWeekIntensity ?? null;
  const effectiveEmphasis =
    params.currentWeekReview?.weeklyEmphasis ?? monthlyDefaults?.weeklyEmphasis ?? null;
  const effectiveCarryover =
    params.currentWeekReview?.carryoverPosture ?? monthlyDefaults?.carryoverPosture ?? null;
  const weeklyShape = describeWeeklyShape({
    intensity: effectiveIntensity,
    emphasis: effectiveEmphasis,
    carryoverPosture: effectiveCarryover,
  });
  const monthlyInfluence = params.currentMonthReview
    ? describeMonthlyStrategy({
        posture: params.currentMonthReview.monthPosture,
        emphasis: params.currentMonthReview.monthlyEmphasis,
        pressureLevel: params.currentMonthReview.pressureLevel,
        carryoverStance: params.currentMonthReview.carryoverStance,
      })
    : null;
  const sourceLabel = params.currentWeekReview?.targetWeekIntensity ||
    params.currentWeekReview?.weeklyEmphasis ||
    params.currentWeekReview?.carryoverPosture
    ? "Explicit this week"
    : monthlyDefaults
      ? "Monthly default"
      : "Planner default";
  const fixedCommitments = params.weekScheduleConstraints
    .filter(
      (constraint) =>
        overlapsDateRange(constraint.startsAt, constraint.endsAt, weekStartDate) ||
        overlapsDateRange(constraint.startsAt, constraint.endsAt, weekEndDate) ||
        (constraint.startsAt.slice(0, 10) >= weekStartDate && constraint.startsAt.slice(0, 10) <= weekEndDate),
    )
    .filter((constraint) => constraint.type !== ScheduleConstraintType.Preference)
    .filter((constraint) => constraint.source === "calendar" || constraint.source === "manual");

  const fixedCommitmentMinutes = weekDates.reduce(
    (sum, date) =>
      sum +
      fixedCommitments.reduce(
        (daySum, constraint) => daySum + minutesWithinDateRange(constraint.startsAt, constraint.endsAt, date),
        0,
      ),
    0,
  );

  const flexibleTasks = openWeekTasks.filter((task) => !isOptionalTask(task));
  const optionalTasks = openWeekTasks.filter(isOptionalTask);
  const pressureTasks = openWeekTasks.filter((task) => {
    if (reviewTaskIds.has(task.id)) {
      return true;
    }

    if ([TaskSchedulingState.Rolled, TaskSchedulingState.Blocked].includes(task.schedulingState)) {
      return true;
    }

    if ([TaskStatus.Deferred, TaskStatus.Missed, TaskStatus.Skipped].includes(task.status)) {
      return true;
    }

    return (
      task.targetDate !== null &&
      task.targetDate <= weekEndDate &&
      !scheduledTaskIds.has(task.id) &&
      task.status !== TaskStatus.InProgress
    );
  });
  const carryoverTasks = openWeekTasks.filter((task) => carryoverTaskIds.has(task.id));
  const carryoverProtectedTasks = carryoverTasks.filter(
    (task) => scheduledTaskIds.has(task.id) || task.status === TaskStatus.InProgress,
  );
  const carryoverReviewTasks = openWeekTasks.filter((task) => reviewTaskIds.has(task.id));

  const strictness = params.adaptationProfile?.strategy.strictness ?? StrategyStrictness.Protective;
  const days = weekDates.map((date) => {
    const dayConstraints = params.weekScheduleConstraints.filter((constraint) =>
      overlapsDateRange(constraint.startsAt, constraint.endsAt, date),
    );
    const dayInterpretedConstraints = interpretConstraints({
      date,
      constraints: dayConstraints,
      preferences: params.preferences!,
      adaptationProfile: params.adaptationProfile,
    });
    const usableWindows = deriveUsableWindows(dayInterpretedConstraints, strictness);
    const capacity = buildCapacityOutput({
      interpretedConstraints: dayInterpretedConstraints,
      usableWindows,
      preferences: params.preferences!,
      strictness,
    });
    const dayBlocks = weekBlocks.filter((block) => block.startsAtDateTime.slice(0, 10) === date);
    const fixedMinutes = fixedCommitments.reduce(
      (sum, constraint) => sum + minutesWithinDateRange(constraint.startsAt, constraint.endsAt, date),
      0,
    );
    const scheduledMinutes = dayBlocks.reduce(
      (sum, block) => sum + clampMinutes((Date.parse(block.endsAtDateTime) - Date.parse(block.startsAtDateTime)) / 60000),
      0,
    );
    const focusMinutes = dayBlocks
      .filter((block) => block.type === TimeBlockType.Focus)
      .reduce(
        (sum, block) => sum + clampMinutes((Date.parse(block.endsAtDateTime) - Date.parse(block.startsAtDateTime)) / 60000),
        0,
      );
    const meaningfulWindows = usableWindows.filter((window) => window.minutes >= 40);

    return {
      date,
      label: formatWeekdayDate(date),
      fixedCount: dayConstraints.filter(
        (constraint) =>
          (constraint.source === "calendar" || constraint.source === "manual") &&
          constraint.type !== ScheduleConstraintType.Preference,
      ).length,
      fixedMinutes,
      scheduledMinutes,
      focusMinutes,
      openMinutes: Math.max(0, capacity.capacitySummary.totalUsableMinutes - scheduledMinutes),
      meaningfulWindowCount: meaningfulWindows.length,
      isTight:
        meaningfulWindows.length === 0 ||
        Math.max(0, capacity.capacitySummary.totalUsableMinutes - scheduledMinutes) < 45,
    } satisfies PlanDaySummary;
  });

  const protectedFocusBlocks = weekBlocks.filter((block) => block.type === TimeBlockType.Focus);
  const protectedFocusMinutes = protectedFocusBlocks.reduce(
    (sum, block) => sum + clampMinutes((Date.parse(block.endsAtDateTime) - Date.parse(block.startsAtDateTime)) / 60000),
    0,
  );
  const scheduledWorkMinutes = weekBlocks.reduce(
    (sum, block) => sum + clampMinutes((Date.parse(block.endsAtDateTime) - Date.parse(block.startsAtDateTime)) / 60000),
    0,
  );
  const totalUsableMinutes = days.reduce((sum, day) => sum + day.openMinutes + day.scheduledMinutes, 0);
  const openCapacityMinutes = days.reduce((sum, day) => sum + day.openMinutes, 0);
  const meaningfulWindowCount = days.reduce((sum, day) => sum + day.meaningfulWindowCount, 0);
  const largestOpenWindow = Math.max(
    0,
    ...days.map((day) => {
      const dayConstraints = params.weekScheduleConstraints.filter((constraint) =>
        overlapsDateRange(constraint.startsAt, constraint.endsAt, day.date),
      );
      const dayInterpretedConstraints = interpretConstraints({
        date: day.date,
        constraints: dayConstraints,
        preferences: params.preferences!,
        adaptationProfile: params.adaptationProfile,
      });
      return Math.max(
        0,
        ...deriveUsableWindows(dayInterpretedConstraints, strictness).map((window) => window.minutes),
      );
    }),
  );
  const unscheduledFlexibleMinutes = flexibleTasks
    .filter((task) => !scheduledTaskIds.has(task.id) && task.status !== TaskStatus.InProgress)
    .reduce((sum, task) => sum + task.estimatedMinutes, 0);
  const optionalDemandMinutes = optionalTasks
    .filter((task) => !scheduledTaskIds.has(task.id))
    .reduce((sum, task) => sum + task.estimatedMinutes, 0);

  const pressureLabel =
    openCapacityMinutes < unscheduledFlexibleMinutes || pressureTasks.length >= 4
      ? "Overloaded"
      : openCapacityMinutes < unscheduledFlexibleMinutes + 90 || days.filter((day) => day.isTight).length >= 3
        ? "Tight"
        : "Balanced";
  const pressureTone =
    pressureLabel === "Overloaded"
      ? "quiet"
      : pressureLabel === "Tight"
        ? "neutral"
        : "accent";
  const pressureDetail =
    pressureLabel === "Overloaded"
      ? "The week is asking for more than the remaining room can support."
      : pressureLabel === "Tight"
        ? "There is still room, but only if the week stays selective."
        : "The week still has enough room to stay believable.";
  const fragmentationLabel =
    meaningfulWindowCount <= 2
      ? "Fragmented"
      : protectedFocusBlocks.length >= 3 && largestOpenWindow >= 90
        ? "Protected"
        : "Mixed";
  const fragmentationDetail =
    fragmentationLabel === "Fragmented"
      ? "Focus time is mostly broken into short windows."
      : fragmentationLabel === "Protected"
        ? "There are real stretches of protected focus space in the week."
        : "The week has some protected depth, but several days are still chopped up.";

  const structuralReads = [
    fixedCommitments.length > 0
      ? `${fixedCommitments.length} fixed commitments are anchoring the week.`
      : params.calendarConnectionState?.permissionState === "granted"
        ? "The week is still light on fixed commitments."
        : "Calendar context is still limited, so fixed commitments may be understated.",
    protectedFocusBlocks.length >= 3
      ? `${protectedFocusBlocks.length} focus blocks are protected in the week.`
      : "Protected focus time is still thin for the amount of work in view.",
    carryoverTasks.length > 0
      ? `${carryoverTasks.length} items entered the week as carryover, with ${carryoverReviewTasks.length} still review-gated.`
      : "No carryover is actively pressuring the week right now.",
    optionalDemandMinutes > 0
      ? `${countHoursAndMinutes(optionalDemandMinutes)} of stretch work is visible but should stay negotiable.`
      : "Optional work is not crowding the week.",
  ];

  return {
    weekStartDate,
    weekEndDate,
    weekLabel: `${formatShortDate(weekStartDate)} - ${formatShortDate(weekEndDate)}`,
    heroTitle:
      pressureLabel === "Overloaded"
        ? "This week is heavier than it looks."
        : pressureLabel === "Tight"
          ? "This week has shape, but not much slack."
          : "This week still looks believable.",
    heroDetail: `${weeklyShape}. ${pressureDetail}`,
    pressureLabel,
    pressureDetail,
    pressureTone,
    structureSummary: {
      fixedCommitmentCount: fixedCommitments.length,
      fixedCommitmentMinutes,
      flexibleWorkCount: flexibleTasks.length,
      optionalWorkCount: optionalTasks.length,
      carryoverCount: carryoverTasks.length,
      protectedFocusBlockCount: protectedFocusBlocks.length,
      protectedFocusMinutes,
      underPressureCount: pressureTasks.length,
    },
    capacitySummary: {
      totalUsableMinutes,
      scheduledWorkMinutes,
      openCapacityMinutes,
      meaningfulWindowCount,
      largestOpenWindowMinutes: largestOpenWindow,
      largestOpenWindowLabel:
      largestOpenWindow > 0 ? `${countHoursAndMinutes(largestOpenWindow)} in the clearest window` : null,
      fragmentationLabel,
      fragmentationDetail,
      weeklyLoadDetail: `${countHoursAndMinutes(scheduledWorkMinutes)} of work is placed inside ${countHoursAndMinutes(totalUsableMinutes)} of usable room.`,
    },
    carryoverSummary: {
      enteringCount: carryoverTasks.length,
      unresolvedCount: carryoverTasks.length,
      protectedCount: carryoverProtectedTasks.length,
      reviewCount: carryoverReviewTasks.length,
      releasedCount: releasedTaskIds.size,
      detail:
        carryoverTasks.length > 0
          ? `${carryoverProtectedTasks.length} pieces are already protected. ${carryoverReviewTasks.length} should go back through review before they quietly expand.`
          : "Nothing is being silently dragged forward right now.",
    },
    strategySummary: {
      sourceLabel,
      weeklyShape,
      monthlyInfluence,
      carryoverLabel:
        effectiveCarryover === null
          ? "Default carryover posture"
          : effectiveCarryover.replaceAll("_", " "),
      detail:
        sourceLabel === "Explicit this week"
          ? "Weekly shaping is directly steering what the planner protects."
          : sourceLabel === "Monthly default"
            ? "Monthly strategy is filling the weekly defaults until you override them."
            : "The planner is staying in its default protective posture.",
    },
    structuralReads,
    fixedCommitments: fixedCommitments.slice(0, 4).map((constraint) => ({
      id: constraint.id,
      title: constraint.title,
      detail: summarizeConstraint(constraint),
      supporting: constraint.location ?? "Fixed commitment",
    })),
    flexibleWork: flexibleTasks.slice(0, 4).map((task) => ({
      id: task.id,
      title: task.title,
      detail: summarizeTask(task),
      supporting: scheduledTaskIds.has(task.id) ? "Placed in the week" : "Still needs placement",
    })),
    optionalWork: optionalTasks.slice(0, 4).map((task) => ({
      id: task.id,
      title: task.title,
      detail: summarizeTask(task),
      supporting: scheduledTaskIds.has(task.id) ? "Taking room this week" : "Keep negotiable",
    })),
    pressureItems: pressureTasks.slice(0, 4).map((task) => ({
      id: task.id,
      title: task.title,
      detail: summarizeTask(task),
      supporting: reviewTaskIds.has(task.id)
        ? "Marked for review"
        : task.schedulingState === TaskSchedulingState.Rolled
          ? "Rolled forward"
          : "Likely to slip without a cleaner decision",
    })),
    carryoverItems: carryoverTasks.slice(0, 4).map((task) => ({
      id: task.id,
      title: task.title,
      detail: summarizeTask(task),
      supporting: carryoverReviewTasks.some((candidate) => candidate.id === task.id)
        ? "Review before carrying again"
        : carryoverProtectedTasks.some((candidate) => candidate.id === task.id)
          ? "Protected in the week"
          : "Still unresolved",
    })),
    protectedFocusItems: protectedFocusBlocks.slice(0, 4).map((block) => ({
      id: block.id,
      title: block.title,
      detail: `${formatWeekdayDate(block.startsAtDateTime.slice(0, 10))} • ${formatTimeRangeLabel(
        block.startsAt,
        block.endsAt,
        { compact: true },
      )}`,
      supporting: block.note ?? "Protected focus block",
    })),
    days,
    shouldOpenWeeklyReview:
      !params.currentWeekReview?.reviewedAt || !params.currentWeekReview?.nextWeekShapedAt,
  } satisfies PlanWorkspaceViewModel;
}
