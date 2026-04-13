import {
  Ambition,
  AmbitionStatus,
  ActivityEvent,
  ActivityEventKind,
  Goal,
  GoalMilestone,
  GoalStatus,
  MonthlyReviewState,
  Task,
  TaskStatus,
  TimeBlock,
  WeeklyReviewState,
} from "../../domain/models";
import { formatShortDate, getCurrentLocalDateString, startOfMonth, startOfWeek } from "../../utils/date";
import { getGoalIntelligenceSnapshot } from "./goalIntelligence";
import { ActivityFeedItem } from "../history/selectors";
import { ExplanationBlock } from "../explanations/types";

export type GoalPaceTruthState =
  | "on_pace"
  | "slightly_off_pace"
  | "reset_needed"
  | "recovered"
  | "unrealistic";

export type AmbitionRepresentationState =
  | "well_represented"
  | "lightly_represented"
  | "underrepresented";

export interface GoalProgressTruth {
  goalId: string;
  ambitionId: string | null;
  paceState: GoalPaceTruthState;
  paceLabel: string;
  paceSummary: string;
  deadlineSummary: string | null;
  representationSummary: string;
  paceExplanation: ExplanationBlock;
  deadlineExplanation: ExplanationBlock | null;
  representationExplanation: ExplanationBlock;
  recentExecutionMinutes: number;
  currentWeekScheduledMinutes: number;
  currentMonthScheduledMinutes: number;
  activeTaskCount: number;
  crowded: boolean;
  stale: boolean;
}

export interface AmbitionProgressTruth {
  ambitionId: string;
  representationState: AmbitionRepresentationState;
  representationLabel: string;
  representationSummary: string;
  currentWeekScheduledMinutes: number;
  currentMonthScheduledMinutes: number;
  activeGoalCount: number;
  representedGoalCount: number;
  movingGoalCount: number;
  portfolioSummary: string;
  explanation: ExplanationBlock;
}

export interface DirectionPortfolioSnapshot {
  ambitions: AmbitionProgressTruth[];
  underrepresentedAmbitionIds: string[];
  crowdedGoalIds: string[];
  staleGoalIds: string[];
}

function parseDay(dateTime: string) {
  return dateTime.slice(0, 10);
}

function minutesBetween(start: string, end: string) {
  return Math.max(0, Math.round((Date.parse(end) - Date.parse(start)) / 60000));
}

function isWithinRange(date: string, start: string, end: string) {
  return date >= start && date <= end;
}

function endOfMonth(date: string) {
  const base = new Date(`${date}T12:00:00`);
  return new Date(base.getFullYear(), base.getMonth() + 1, 0).toISOString().slice(0, 10);
}

function buildGoalMinuteMaps(goals: Goal[], timeBlocks: TimeBlock[], today: string) {
  const weekStart = startOfWeek(today, 1);
  const monthStart = startOfMonth(today);
  const monthEnd = endOfMonth(today);
  const recentStart = new Date(`${today}T12:00:00`);
  recentStart.setDate(recentStart.getDate() - 13);
  const recentStartDate = recentStart.toISOString().slice(0, 10);
  const weekMinutes = new Map<string, number>();
  const monthMinutes = new Map<string, number>();
  const recentMinutes = new Map<string, number>();

  for (const goal of goals) {
    weekMinutes.set(goal.id, 0);
    monthMinutes.set(goal.id, 0);
    recentMinutes.set(goal.id, 0);
  }

  for (const block of timeBlocks) {
    if (!block.goalId) {
      continue;
    }

    const day = parseDay(block.startsAtDateTime);
    const minutes = minutesBetween(block.startsAtDateTime, block.endsAtDateTime);
    if (isWithinRange(day, weekStart, today)) {
      weekMinutes.set(block.goalId, (weekMinutes.get(block.goalId) ?? 0) + minutes);
    }
    if (isWithinRange(day, monthStart, monthEnd)) {
      monthMinutes.set(block.goalId, (monthMinutes.get(block.goalId) ?? 0) + minutes);
    }
    if (isWithinRange(day, recentStartDate, today)) {
      recentMinutes.set(block.goalId, (recentMinutes.get(block.goalId) ?? 0) + minutes);
    }
  }

  return { weekMinutes, monthMinutes, recentMinutes };
}

function buildTaskMinuteMap(tasks: Task[]) {
  const completedMinutes = new Map<string, number>();
  for (const task of tasks) {
    if (!task.goalId || task.status !== TaskStatus.Completed) {
      continue;
    }

    completedMinutes.set(
      task.goalId,
      (completedMinutes.get(task.goalId) ?? 0) + (task.actualMinutes ?? task.estimatedMinutes),
    );
  }
  return completedMinutes;
}

function countRecentEvents(feed: ActivityFeedItem[], goalId: string, kinds: ActivityEventKind[]) {
  return feed.filter((event) => event.goalId === goalId && kinds.includes(event.kind)).length;
}

export function buildGoalProgressTruth(params: {
  goal: Goal;
  ambition: Ambition | null;
  milestones: GoalMilestone[];
  tasks: Task[];
  timeBlocks: TimeBlock[];
  activityFeed: ActivityFeedItem[];
  currentWeekReview: WeeklyReviewState | null;
  currentMonthReview: MonthlyReviewState | null;
  today?: string;
}): GoalProgressTruth {
  const today = params.today ?? getCurrentLocalDateString();
  const intelligence = getGoalIntelligenceSnapshot(params.goal);
  const desiredWeeklyMinutes =
    intelligence?.feasibility.weeklyDemandMinutes ?? params.goal.desiredWeeklyMinutes ?? 120;
  const minuteMaps = buildGoalMinuteMaps([params.goal], params.timeBlocks, today);
  const completedMinutes = buildTaskMinuteMap(params.tasks);
  const currentWeekScheduledMinutes = minuteMaps.weekMinutes.get(params.goal.id) ?? 0;
  const currentMonthScheduledMinutes = minuteMaps.monthMinutes.get(params.goal.id) ?? 0;
  const recentExecutionMinutes =
    (minuteMaps.recentMinutes.get(params.goal.id) ?? 0) + (completedMinutes.get(params.goal.id) ?? 0);
  const completedEvents = countRecentEvents(params.activityFeed, params.goal.id, [
    ActivityEventKind.TaskCompleted,
    ActivityEventKind.MilestoneCompleted,
  ]);
  const reshapedEvents = countRecentEvents(params.activityFeed, params.goal.id, [
    ActivityEventKind.TaskDeferred,
    ActivityEventKind.TaskMissed,
    ActivityEventKind.TaskSkipped,
    ActivityEventKind.TaskRescheduled,
    ActivityEventKind.PlanReviewAccepted,
    ActivityEventKind.PlanReviewGenerated,
  ]);
  const activeTaskCount = params.tasks.filter((task) =>
    [TaskStatus.Ready, TaskStatus.Scheduled, TaskStatus.InProgress].includes(task.status),
  ).length;
  const lastEventDate = params.activityFeed.find((event) => event.goalId === params.goal.id)?.date ?? null;
  const stale =
    currentWeekScheduledMinutes === 0 &&
    recentExecutionMinutes < 45 &&
    (!!lastEventDate ? Math.abs(Date.parse(`${today}T12:00:00`) - Date.parse(`${lastEventDate}T12:00:00`)) / 86400000 > 9 : true);
  const crowded = activeTaskCount >= 7 && currentWeekScheduledMinutes < desiredWeeklyMinutes * 0.6;
  const weekRatio = currentWeekScheduledMinutes / Math.max(desiredWeeklyMinutes, 60);
  const monthlyReduce = params.currentMonthReview?.reduceGoalIds.includes(params.goal.id) ?? false;
  const monthlyPause = params.currentMonthReview?.pauseGoalIds.includes(params.goal.id) ?? false;
  const weeklyReviewTaskIds = new Set([
    ...(params.currentWeekReview?.carryoverTaskIds ?? []),
    ...(params.currentWeekReview?.reviewTaskIds ?? []),
  ]);
  const weeklyReviewPressure = params.tasks.filter((task) => weeklyReviewTaskIds.has(task.id)).length;

  let paceState: GoalPaceTruthState;
  if (intelligence?.feasibility.status === "unrealistic") {
    paceState = "unrealistic";
  } else if (
    intelligence?.feasibility.status === "tight" &&
    weekRatio < 0.45 &&
    (reshapedEvents >= completedEvents || stale)
  ) {
    paceState = "reset_needed";
  } else if (
    completedEvents >= Math.max(2, reshapedEvents) &&
    currentWeekScheduledMinutes >= desiredWeeklyMinutes * 0.7 &&
    reshapedEvents > 0
  ) {
    paceState = "recovered";
  } else if (weekRatio >= 0.85 && !monthlyReduce && !monthlyPause) {
    paceState = "on_pace";
  } else if (weekRatio >= 0.45 || completedEvents > 0 || recentExecutionMinutes >= 90) {
    paceState = "slightly_off_pace";
  } else {
    paceState = "reset_needed";
  }

  const paceCopy: Record<GoalPaceTruthState, { label: string; summary: string }> = {
    on_pace: {
      label: "On pace",
      summary: "This goal is getting enough room to stay believable.",
    },
    slightly_off_pace: {
      label: "Slightly off pace",
      summary: "This goal is still moving, but it is not getting enough room.",
    },
    reset_needed: {
      label: "Reset needed",
      summary:
        weeklyReviewPressure > 0
          ? "The direction still holds, but weekly carryover says the pace may need a reset."
          : "The direction still holds, but the pace may need a reset.",
    },
    recovered: {
      label: "Recovered",
      summary: "This goal recovered after a tighter stretch.",
    },
    unrealistic: {
      label: "No longer realistic",
      summary: "This goal is no longer realistic under the current timeline.",
    },
  };

  const ambitionLabel = params.ambition ? ` for ${params.ambition.title}` : "";
  const deadlineSummary = intelligence?.feasibility.revisedDeadlineSuggestion
    ? `A later target would be more believable: ${formatShortDate(
        intelligence.feasibility.revisedDeadlineSuggestion,
      )}.`
    : intelligence?.feasibility.detail ?? null;
  const weeklyHoursLabel = `${Math.max(0, Math.round(currentWeekScheduledMinutes / 60))} hr`;
  const desiredHoursLabel = `${Math.max(1, Math.round(desiredWeeklyMinutes / 60))} hr`;
  const paceExplanation: ExplanationBlock = {
    eyebrow: "Why this read",
    headline:
      paceState === "on_pace"
        ? "This still fits without forcing the week."
        : paceState === "slightly_off_pace"
          ? "The goal is still moving, but the week is lighter than the pace assumes."
          : paceState === "reset_needed"
            ? "The direction still holds, but the pace needs a reset."
            : paceState === "recovered"
              ? "Recent movement has pulled the goal back into a believable lane."
              : "The current timeline no longer matches the room or recent movement.",
    supporting: `${weeklyHoursLabel} are visible this week against a ${desiredHoursLabel} pace.`,
    because:
      paceState === "recovered"
        ? `Recent completions are now outpacing reshaping (${completedEvents} to ${reshapedEvents}).`
        : paceState === "on_pace"
          ? "Current-week time and recent execution are both supporting the target."
          : stale
            ? "Recent movement has gone quiet, so the current pace is being carried more by intention than execution."
            : crowded
              ? "There is too much active work for the amount of room this goal currently has."
              : weeklyReviewPressure > 0
                ? "Carryover and review pressure are eating into the pace this goal needs."
                : "Recent execution and current-week room are running below the pace the goal assumes.",
    decision:
      paceState === "on_pace" || paceState === "recovered"
        ? "Keep the current shape unless the week tightens."
        : paceState === "slightly_off_pace"
          ? "Give it more current-week room or accept a slightly slower pace."
          : paceState === "reset_needed"
            ? "Reset the weekly shape before adding more scope."
            : "Change the date, scope, or pace mode.",
  };
  const deadlineExplanation: ExplanationBlock | null = intelligence
    ? {
        eyebrow: "Deadline read",
        headline:
          intelligence.feasibility.status === "feasible"
            ? "The deadline still holds."
            : intelligence.feasibility.status === "tight"
              ? "The deadline can still hold, but only with a tighter week."
              : "The deadline does not hold under the current conditions.",
        supporting: intelligence.feasibility.summary,
        because: intelligence.feasibility.detail,
        decision: intelligence.feasibility.revisedDeadlineSuggestion
          ? `A later target like ${formatShortDate(intelligence.feasibility.revisedDeadlineSuggestion)} would be more believable.`
          : intelligence.feasibility.lighterScopeSuggestion ?? intelligence.feasibility.highestLeverageStep,
      }
    : null;
  const representationExplanation: ExplanationBlock = {
    eyebrow: "Week representation",
    headline:
      currentWeekScheduledMinutes >= desiredWeeklyMinutes * 0.75
        ? "This goal has real room in the current week."
        : currentWeekScheduledMinutes >= desiredWeeklyMinutes * 0.35
          ? "This goal is visible in the week, but lightly."
          : "This goal is still more named than represented this week.",
    supporting: `${weeklyHoursLabel} are currently placed this week.`,
    because:
      currentWeekScheduledMinutes >= desiredWeeklyMinutes * 0.75
        ? "The weekly plan is giving this goal enough room to stay believable."
        : crowded
          ? "Other active work is competing for the same room."
          : "The current week is not yet giving this goal the room its pace assumes.",
    decision:
      currentWeekScheduledMinutes >= desiredWeeklyMinutes * 0.75
        ? "Protect the existing time."
        : "Add room in the week or accept that this goal will move more slowly.",
  };

  return {
    goalId: params.goal.id,
    ambitionId: params.goal.ambitionId,
    paceState,
    paceLabel: paceCopy[paceState].label,
    paceSummary:
      paceState === "slightly_off_pace"
        ? `${paceCopy[paceState].summary}${ambitionLabel}`
        : paceCopy[paceState].summary,
    deadlineSummary,
    representationSummary:
      currentWeekScheduledMinutes >= desiredWeeklyMinutes * 0.75
        ? "This goal is represented in the current week."
        : currentWeekScheduledMinutes >= desiredWeeklyMinutes * 0.35
          ? "This goal is visible in the week, but lightly."
          : "This goal is active in name more than in the current week.",
    paceExplanation,
    deadlineExplanation,
    representationExplanation,
    recentExecutionMinutes,
    currentWeekScheduledMinutes,
    currentMonthScheduledMinutes,
    activeTaskCount,
    crowded,
    stale,
  };
}

export function buildAmbitionProgressTruth(params: {
  ambition: Ambition;
  goals: Goal[];
  goalTruthById: Map<string, GoalProgressTruth>;
}): AmbitionProgressTruth {
  const activeGoals = params.goals.filter((goal) => goal.status === GoalStatus.Active);
  const truths = activeGoals
    .map((goal) => params.goalTruthById.get(goal.id))
    .filter((truth): truth is GoalProgressTruth => Boolean(truth));
  const currentWeekScheduledMinutes = truths.reduce(
    (sum, truth) => sum + truth.currentWeekScheduledMinutes,
    0,
  );
  const currentMonthScheduledMinutes = truths.reduce(
    (sum, truth) => sum + truth.currentMonthScheduledMinutes,
    0,
  );
  const representedGoalCount = truths.filter((truth) => truth.currentWeekScheduledMinutes >= 45).length;
  const movingGoalCount = truths.filter((truth) =>
    ["on_pace", "recovered", "slightly_off_pace"].includes(truth.paceState),
  ).length;

  let representationState: AmbitionRepresentationState;
  if (activeGoals.length === 0) {
    representationState = "lightly_represented";
  } else if (
    representedGoalCount === 0 ||
    currentWeekScheduledMinutes < Math.max(60, activeGoals.length * 45)
  ) {
    representationState = "underrepresented";
  } else if (representedGoalCount < activeGoals.length || currentWeekScheduledMinutes < activeGoals.length * 90) {
    representationState = "lightly_represented";
  } else {
    representationState = "well_represented";
  }

  const representationCopy: Record<
    AmbitionRepresentationState,
    { label: string; summary: string }
  > = {
    well_represented: {
      label: "Represented",
      summary: "This ambition is clearly being served in the current week.",
    },
    lightly_represented: {
      label: "Light representation",
      summary: "This ambition is present, but it is getting less room than its active goals suggest.",
    },
    underrepresented: {
      label: "Underrepresented",
      summary: "This ambition is underrepresented in your time.",
    },
  };

  const portfolioSummary =
    activeGoals.length === 0
      ? "This direction exists, but it does not have active goals under it yet."
      : movingGoalCount === 0
      ? "The direction is named, but it is not yet moving through current goals."
      : movingGoalCount === activeGoals.length
      ? "The active goals under this direction are still moving."
      : "Part of this direction is moving, but part of it has gone quiet.";
  const explanation: ExplanationBlock = {
    eyebrow: "Direction read",
    headline:
      representationState === "well_represented"
        ? "This direction is showing up in the current week."
        : representationState === "lightly_represented"
          ? "This direction is present, but not fully supported by the week."
          : "This direction is underrepresented in the current week.",
    supporting: `${representedGoalCount} of ${activeGoals.length} active goals are currently visible in time.`,
    because:
      representationState === "well_represented"
        ? "Enough current-week time is mapped onto the goals under this direction."
        : movingGoalCount === 0
          ? "The goals under this direction are active on paper, but not moving in real time."
          : "The current week is favoring other work more than this direction.",
    decision:
      representationState === "well_represented"
        ? "Keep the direction visible and protect the existing room."
        : "Rebalance the week if this direction is still meant to matter now.",
  };

  return {
    ambitionId: params.ambition.id,
    representationState,
    representationLabel: representationCopy[representationState].label,
    representationSummary: representationCopy[representationState].summary,
    currentWeekScheduledMinutes,
    currentMonthScheduledMinutes,
    activeGoalCount: activeGoals.length,
    representedGoalCount,
    movingGoalCount,
    portfolioSummary,
    explanation,
  };
}

export function buildDirectionPortfolioSnapshot(params: {
  ambitions: Ambition[];
  goals: Goal[];
  goalTruths: GoalProgressTruth[];
}): DirectionPortfolioSnapshot {
  const goalTruthById = new Map(params.goalTruths.map((truth) => [truth.goalId, truth]));
  const ambitions = params.ambitions
    .filter((ambition) => ambition.status !== AmbitionStatus.Archived && ambition.isVisible)
    .map((ambition) =>
      buildAmbitionProgressTruth({
        ambition,
        goals: params.goals.filter((goal) => goal.ambitionId === ambition.id),
        goalTruthById,
      }),
    )
    .sort((left, right) => left.ambitionId.localeCompare(right.ambitionId));

  return {
    ambitions,
    underrepresentedAmbitionIds: ambitions
      .filter((ambition) => ambition.representationState === "underrepresented")
      .map((ambition) => ambition.ambitionId),
    crowdedGoalIds: params.goalTruths.filter((truth) => truth.crowded).map((truth) => truth.goalId),
    staleGoalIds: params.goalTruths.filter((truth) => truth.stale).map((truth) => truth.goalId),
  };
}
