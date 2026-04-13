import {
  ActivityEventKind,
  DailyRitualDayLoadRating,
  DailyRitualState,
  Task,
  WeeklyCarryoverPosture,
  WeeklyEmphasis,
  WeeklyIntensity,
  WeeklyReviewState,
  WeeklyReviewSummary,
} from "../../domain/models";
import { addDays, endOfWeek, isDateInRange, startOfWeek } from "../../utils/date";
import { ActivityFeedItem } from "./selectors";
import { ExplanationBlock } from "../explanations/types";

export interface WeeklyReviewDigest {
  weekStartDate: string;
  weekEndDate: string;
  summary: WeeklyReviewSummary;
  reads: string[];
  unfinishedTasks: Task[];
  carryCandidateTasks: Task[];
  explanation: ExplanationBlock;
  carryoverExplanation: ExplanationBlock;
}

export interface WeeklyContinuitySnapshot {
  reviewedWeeks: number;
  shapedWeeks: number;
  averageWeeklyChurn: number;
  averageCarryoverQuality: number;
  shapedWeekDriftDelta: number | null;
  lighterHoldRate: number | null;
  balancedHoldRate: number | null;
  fullerHoldRate: number | null;
}

function average(values: number[]) {
  return values.length > 0
    ? values.reduce((sum, value) => sum + value, 0) / values.length
    : 0;
}

function countKinds(events: ActivityFeedItem[], kinds: ActivityEventKind[]) {
  return events.filter((event) => kinds.includes(event.kind)).length;
}

function nextDayReshapeCount(events: ActivityFeedItem[], date: string) {
  return events.filter(
    (event) =>
      event.date === addDays(date, 1) &&
      [
        ActivityEventKind.TaskDeferred,
        ActivityEventKind.TaskMissed,
        ActivityEventKind.TaskSkipped,
        ActivityEventKind.TaskRescheduled,
        ActivityEventKind.DayRecovered,
      ].includes(event.kind),
  ).length;
}

function carryoverQualityScore(summary: WeeklyReviewSummary) {
  const deliberate = summary.sentToReviewCount + summary.carryForwardCount;
  const vaguePenalty = summary.leftVagueCount;
  const total = deliberate + vaguePenalty;

  if (total === 0) {
    return 0;
  }

  return Math.max(0, Math.min(1, (deliberate - vaguePenalty) / total + 0.5));
}

function holdRate(states: WeeklyReviewState[], intensity: WeeklyIntensity) {
  const filtered = states.filter((state) => state.targetWeekIntensity === intensity && state.summary);
  if (filtered.length === 0) {
    return null;
  }

  return average(filtered.map((state) => (state.summary?.heldSteady ? 1 : 0)));
}

export function buildWeeklyReviewDigest(params: {
  date: string;
  weekStartsOn?: number;
  tasks: Task[];
  rituals: DailyRitualState[];
  events: ActivityFeedItem[];
}): WeeklyReviewDigest {
  const weekStartsOn = params.weekStartsOn ?? 1;
  const weekStartDate = startOfWeek(params.date, weekStartsOn);
  const weekEndDate = endOfWeek(params.date, weekStartsOn);
  const weekEvents = params.events.filter((event) => isDateInRange(event.date, weekStartDate, weekEndDate));
  const ritualWeek = params.rituals.filter((ritual) => isDateInRange(ritual.date, weekStartDate, weekEndDate));
  const completedCount = countKinds(weekEvents, [
    ActivityEventKind.TaskCompleted,
    ActivityEventKind.MilestoneCompleted,
  ]);
  const deferredCount = countKinds(weekEvents, [ActivityEventKind.TaskDeferred]);
  const missedCount = countKinds(weekEvents, [
    ActivityEventKind.TaskMissed,
    ActivityEventKind.TaskSkipped,
  ]);
  const reshapedCount = countKinds(weekEvents, [
    ActivityEventKind.TaskDeferred,
    ActivityEventKind.TaskMissed,
    ActivityEventKind.TaskSkipped,
    ActivityEventKind.TaskRescheduled,
    ActivityEventKind.PlanReviewAccepted,
    ActivityEventKind.PlanReviewGenerated,
  ]);
  const daysOpened = ritualWeek.filter((ritual) => ritual.openedAt).length;
  const daysClosed = ritualWeek.filter((ritual) => ritual.closedAt).length;
  const recoveryCount = ritualWeek.reduce(
    (sum, ritual) => sum + ritual.recoveryMoments.length,
    0,
  );
  const carrySummaries = ritualWeek
    .map((ritual) => ritual.carryDecisionSummary)
    .filter((summary): summary is NonNullable<DailyRitualState["carryDecisionSummary"]> => Boolean(summary));
  const carryoverReviewedCount = carrySummaries.length;
  const carryForwardCount = carrySummaries.reduce((sum, summary) => sum + summary.carriedTaskCount, 0);
  const sentToReviewCount = carrySummaries.reduce((sum, summary) => sum + summary.sentToReviewCount, 0);
  const leftVagueCount = carrySummaries.reduce((sum, summary) => sum + summary.deferredDecisionCount, 0);
  const lateWeekDates = [addDays(weekStartDate, 4), addDays(weekStartDate, 5), addDays(weekStartDate, 6)];
  const openedLateWeekCount = ritualWeek.filter(
    (ritual) => ritual.openedAt && lateWeekDates.includes(ritual.date),
  ).length;
  const closedLateWeekCount = ritualWeek.filter(
    (ritual) => ritual.closedAt && lateWeekDates.includes(ritual.date),
  ).length;
  const overloadedCount = ritualWeek.filter(
    (ritual) => ritual.dayLoadRating === DailyRitualDayLoadRating.Overloaded,
  ).length;
  const stableDays = ritualWeek.filter((ritual) => ritual.closedAt);
  const openEndedDays = ritualWeek.filter((ritual) => !ritual.closedAt);
  const nextDayStabilityDelta =
    stableDays.length > 0 || openEndedDays.length > 0
      ? average(stableDays.map((ritual) => nextDayReshapeCount(weekEvents, ritual.date))) -
        average(openEndedDays.map((ritual) => nextDayReshapeCount(weekEvents, ritual.date)))
      : null;
  const churnRate =
    completedCount + reshapedCount > 0 ? reshapedCount / (completedCount + reshapedCount) : 0;
  const heldSteady =
    completedCount >= reshapedCount &&
    (daysClosed >= Math.max(1, Math.floor(Math.max(daysOpened, ritualWeek.length) / 2)) ||
      recoveryCount <= 1);
  const overloaded = overloadedCount >= 2 || reshapedCount > completedCount + 2;
  const weekTasks = params.tasks.filter(
    (task) =>
      (task.targetDate && isDateInRange(task.targetDate, weekStartDate, weekEndDate)) ||
      (task.scheduledDate && isDateInRange(task.scheduledDate, weekStartDate, weekEndDate)),
  );
  const unfinishedTasks = weekTasks.filter((task) => task.status !== "completed" && task.status !== "cancelled");
  const carryCandidateTasks = unfinishedTasks;

  const summary: WeeklyReviewSummary = {
    completedCount,
    reshapedCount,
    deferredCount,
    missedCount,
    daysOpened,
    daysClosed,
    recoveryCount,
    carryoverReviewedCount,
    carryForwardCount,
    sentToReviewCount,
    leftVagueCount,
    openedLateWeekCount,
    closedLateWeekCount,
    nextDayStabilityDelta,
    churnRate: Number(churnRate.toFixed(2)),
    heldSteady,
    overloaded,
  };

  const reads = [
    heldSteady ? "The week held steady." : "The week needed more reshaping than follow-through.",
    openedLateWeekCount > closedLateWeekCount
      ? "The week drifted later in the week."
      : "The week stayed more even across the full span.",
    nextDayStabilityDelta !== null && nextDayStabilityDelta < -0.25
      ? "Closeouts tended to lead into steadier next days."
      : nextDayStabilityDelta !== null && nextDayStabilityDelta > 0.25
        ? "Closeouts happened, but they did not yet reduce next-day drift."
        : "Closeouts and next-day stability were fairly even.",
    sentToReviewCount >= leftVagueCount + carryForwardCount
      ? "Unfinished work was handled deliberately."
      : leftVagueCount > 0
        ? "Some unfinished work was still left vague."
        : "Carryover mostly stayed explicit.",
    overloaded
      ? "The week was fuller than execution reality supported."
      : "The week stayed within a believable load.",
  ];
  const explanation: ExplanationBlock = {
    eyebrow: "Weekly causality",
    headline: heldSteady
      ? "The week mostly held because follow-through kept up with reshaping."
      : "The week drifted because reshaping started to outrun follow-through.",
    supporting: `${completedCount} completions and ${reshapedCount} reshapes defined the week.`,
    because: overloaded
      ? "The load asked for more than the week could absorb cleanly."
      : openedLateWeekCount > closedLateWeekCount
        ? "The back half of the week lost structure faster than it regained it."
        : "The week stayed closer to its original shape.",
    decision: heldSteady
      ? "Carry forward only what still matters."
      : "Use review to reset the next week before carrying more.",
  };
  const carryoverExplanation: ExplanationBlock = {
    eyebrow: "Carryover read",
    headline:
      sentToReviewCount >= leftVagueCount + carryForwardCount
        ? "Unfinished work stayed mostly explicit."
        : leftVagueCount > 0
          ? "Some unfinished work was left vague."
          : "Carryover leaned more toward being pushed forward.",
    supporting: `${carryForwardCount} carried, ${sentToReviewCount} sent back to review, ${leftVagueCount} left undecided.`,
    because:
      carryoverReviewedCount === 0
        ? "The week ended with unfinished work, but it was not routed deliberately yet."
        : "End-of-day carry decisions shaped how much pressure spilled into review.",
    decision:
      sentToReviewCount >= carryForwardCount
        ? "Review first before loading next week."
        : "Prune or review unfinished work before it becomes automatic carryover.",
  };

  return {
    weekStartDate,
    weekEndDate,
    summary,
    reads,
    unfinishedTasks,
    carryCandidateTasks,
    explanation,
    carryoverExplanation,
  };
}

export function summarizeWeeklyContinuity(states: WeeklyReviewState[]) {
  const reviewedWeeks = states.filter((state) => state.reviewedAt).length;
  const shapedWeeks = states.filter((state) => state.nextWeekShapedAt).length;
  const summarizedStates = states.filter((state) => state.summary);
  const averageWeeklyChurn = average(
    summarizedStates.map((state) => state.summary?.churnRate ?? 0),
  );
  const averageCarryoverQuality = average(
    summarizedStates.map((state) => carryoverQualityScore(state.summary!)),
  );

  const shapedPairs = summarizedStates
    .filter((state) => state.nextWeekShapedAt)
    .map((state) => {
      const nextWeek = states.find((candidate) => candidate.weekStartDate === addDays(state.weekStartDate, 7));
      return {
        shaped: state,
        nextWeek,
      };
    })
    .filter((pair) => pair.nextWeek?.summary);
  const unshapedNextWeeks = summarizedStates.filter(
    (state) =>
      !states.some(
        (candidate) => candidate.nextWeekShapedAt && addDays(candidate.weekStartDate, 7) === state.weekStartDate,
      ),
  );
  const shapedWeekDriftDelta =
    shapedPairs.length > 0 || unshapedNextWeeks.length > 0
      ? average(shapedPairs.map((pair) => pair.nextWeek?.summary?.churnRate ?? 0)) -
        average(unshapedNextWeeks.map((state) => state.summary?.churnRate ?? 0))
      : null;

  return {
    reviewedWeeks,
    shapedWeeks,
    averageWeeklyChurn,
    averageCarryoverQuality,
    shapedWeekDriftDelta,
    lighterHoldRate: holdRate(states, WeeklyIntensity.Lighter),
    balancedHoldRate: holdRate(states, WeeklyIntensity.Balanced),
    fullerHoldRate: holdRate(states, WeeklyIntensity.Fuller),
  } satisfies WeeklyContinuitySnapshot;
}

export function describeWeeklyShape(params: {
  intensity: WeeklyIntensity | null;
  emphasis: WeeklyEmphasis | null;
  carryoverPosture: WeeklyCarryoverPosture | null;
}) {
  const intensity =
    params.intensity === WeeklyIntensity.Lighter
      ? "lighter"
      : params.intensity === WeeklyIntensity.Fuller
        ? "fuller"
        : "balanced";
  const emphasis =
    params.emphasis === WeeklyEmphasis.ProtectEssentials
      ? "protect essentials"
      : params.emphasis === WeeklyEmphasis.PushMeaningfulArea
        ? "push one meaningful area"
        : "steady progress";
  const carryover =
    params.carryoverPosture === WeeklyCarryoverPosture.EssentialsOnly
      ? "carry only essentials"
      : params.carryoverPosture === WeeklyCarryoverPosture.Aggressive
        ? "carry more forward"
        : "review unfinished work first";

  return `${intensity} week, ${emphasis}, ${carryover}`;
}
