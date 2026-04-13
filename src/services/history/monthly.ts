import {
  ActivityEventKind,
  DailyRitualDayLoadRating,
  DailyRitualState,
  Goal,
  GoalStatus,
  MonthlyCarryoverStance,
  MonthlyEmphasis,
  MonthlyPosture,
  MonthlyPressureLevel,
  MonthlyReviewState,
  MonthlyReviewSummary,
  Task,
  WeeklyReviewState,
} from "../../domain/models";
import { endOfMonth, formatMonthLabel, isDateInRange, startOfMonth } from "../../utils/date";
import { ActivityFeedItem } from "./selectors";

export interface MonthlyReviewDigest {
  monthStartDate: string;
  monthEndDate: string;
  summary: MonthlyReviewSummary;
  reads: string[];
  headline: string;
  goalCoverage: MonthlyReviewState["goalCoverage"];
  underrepresentedGoals: Goal[];
  dragGoals: Goal[];
}

function countKinds(events: ActivityFeedItem[], kinds: ActivityEventKind[]) {
  return events.filter((event) => kinds.includes(event.kind)).length;
}

function average(values: number[]) {
  return values.length > 0 ? values.reduce((sum, value) => sum + value, 0) / values.length : 0;
}

export function buildMonthlyReviewDigest(params: {
  date: string;
  goals: Goal[];
  tasks: Task[];
  rituals: DailyRitualState[];
  weeklyReviews: WeeklyReviewState[];
  events: ActivityFeedItem[];
}): MonthlyReviewDigest {
  const monthStartDate = startOfMonth(params.date);
  const monthEndDate = endOfMonth(params.date);
  const monthEvents = params.events.filter((event) =>
    isDateInRange(event.date, monthStartDate, monthEndDate),
  );
  const monthRituals = params.rituals.filter((ritual) =>
    isDateInRange(ritual.date, monthStartDate, monthEndDate),
  );
  const monthWeeks = params.weeklyReviews.filter((review) =>
    review.weekStartDate >= monthStartDate && review.weekStartDate <= monthEndDate,
  );
  const activeGoals = params.goals.filter((goal) => goal.status === GoalStatus.Active);
  const monthTasks = params.tasks.filter(
    (task) =>
      (task.targetDate && isDateInRange(task.targetDate, monthStartDate, monthEndDate)) ||
      (task.scheduledDate && isDateInRange(task.scheduledDate, monthStartDate, monthEndDate)) ||
      (task.completedAt && isDateInRange(task.completedAt.slice(0, 10), monthStartDate, monthEndDate)),
  );

  const completedCount = countKinds(monthEvents, [
    ActivityEventKind.TaskCompleted,
    ActivityEventKind.MilestoneCompleted,
  ]);
  const deferredCount = countKinds(monthEvents, [ActivityEventKind.TaskDeferred]);
  const missedCount = countKinds(monthEvents, [ActivityEventKind.TaskMissed, ActivityEventKind.TaskSkipped]);
  const reshapedCount = countKinds(monthEvents, [
    ActivityEventKind.TaskDeferred,
    ActivityEventKind.TaskMissed,
    ActivityEventKind.TaskSkipped,
    ActivityEventKind.TaskRescheduled,
    ActivityEventKind.PlanReviewAccepted,
    ActivityEventKind.PlanReviewGenerated,
  ]);
  const daysOpened = monthRituals.filter((ritual) => ritual.openedAt).length;
  const daysClosed = monthRituals.filter((ritual) => ritual.closedAt).length;
  const recoveryCount = monthRituals.reduce((sum, ritual) => sum + ritual.recoveryMoments.length, 0);
  const carrySummaries = monthRituals
    .map((ritual) => ritual.carryDecisionSummary)
    .filter((summary): summary is NonNullable<DailyRitualState["carryDecisionSummary"]> => Boolean(summary));
  const carryoverReviewedCount = carrySummaries.length;
  const carryForwardCount = carrySummaries.reduce((sum, summary) => sum + summary.carriedTaskCount, 0);
  const sentToReviewCount = carrySummaries.reduce((sum, summary) => sum + summary.sentToReviewCount, 0);
  const leftVagueCount = carrySummaries.reduce((sum, summary) => sum + summary.deferredDecisionCount, 0);
  const reviewedWeeks = monthWeeks.filter((review) => review.reviewedAt).length;
  const shapedWeeks = monthWeeks.filter((review) => review.nextWeekShapedAt).length;
  const overloadedDays = monthRituals.filter(
    (ritual) => ritual.dayLoadRating === DailyRitualDayLoadRating.Overloaded,
  ).length;
  const churnRate = completedCount + reshapedCount > 0 ? reshapedCount / (completedCount + reshapedCount) : 0;
  const heldSteady =
    reviewedWeeks >= Math.max(1, Math.floor(monthWeeks.length / 2)) &&
    daysClosed >= Math.max(1, Math.floor(Math.max(1, daysOpened) * 0.6));
  const overloaded = overloadedDays >= 3 || reshapedCount > completedCount + 4;

  const goalCoverage = activeGoals.map((goal) => {
    const goalEvents = monthEvents.filter((event) => event.goalId === goal.id);
    const goalTasks = monthTasks.filter((task) => task.goalId === goal.id);
    const executionCount = goalEvents.filter((event) =>
      [
        ActivityEventKind.TaskStarted,
        ActivityEventKind.TaskCompleted,
        ActivityEventKind.TaskRescheduled,
      ].includes(event.kind),
    ).length;
    const completionCount = goalEvents.filter((event) =>
      [ActivityEventKind.TaskCompleted, ActivityEventKind.MilestoneCompleted].includes(event.kind),
    ).length;
    const carryoverCount = goalTasks.filter((task) =>
      ["deferred", "missed", "skipped", "split", "substituted", "unscheduled"].includes(task.status),
    ).length;
    const churnCount = goalEvents.filter((event) =>
      [
        ActivityEventKind.TaskDeferred,
        ActivityEventKind.TaskMissed,
        ActivityEventKind.TaskSkipped,
        ActivityEventKind.TaskRescheduled,
      ].includes(event.kind),
    ).length;
    const represented = executionCount + completionCount > 0;
    const underrepresented = !represented || completionCount === 0;
    const dragSignal = carryoverCount > 1 || churnCount > completionCount + 1;

    return {
      goalId: goal.id,
      goalTitle: goal.title,
      executionCount,
      completionCount,
      carryoverCount,
      churnCount,
      represented,
      underrepresented,
      dragSignal,
    };
  });

  const underrepresentedGoals = activeGoals.filter((goal) =>
    goalCoverage.some((coverage) => coverage.goalId === goal.id && coverage.underrepresented),
  );
  const dragGoals = activeGoals.filter((goal) =>
    goalCoverage.some((coverage) => coverage.goalId === goal.id && coverage.dragSignal),
  );

  const summary: MonthlyReviewSummary = {
    completedCount,
    reshapedCount,
    deferredCount,
    missedCount,
    reviewedWeeks,
    shapedWeeks,
    daysOpened,
    daysClosed,
    recoveryCount,
    carryoverReviewedCount,
    carryForwardCount,
    sentToReviewCount,
    leftVagueCount,
    churnRate: Number(churnRate.toFixed(2)),
    heldSteady,
    overloaded,
    goalCoverageCount: goalCoverage.filter((goal) => goal.represented).length,
    underrepresentedGoalCount: goalCoverage.filter((goal) => goal.underrepresented).length,
    dragGoalCount: goalCoverage.filter((goal) => goal.dragSignal).length,
  };

  const reads = [
    heldSteady
      ? "This month held steady in some areas and drifted in others."
      : "This month needed more reshaping than stable follow-through.",
    summary.goalCoverageCount > 0
      ? `${summary.goalCoverageCount} goals received real execution.`
      : "Active goals stayed more aspirational than represented.",
    summary.underrepresentedGoalCount > 0
      ? `${summary.underrepresentedGoalCount} active goals stayed underrepresented.`
      : "Active goals were represented more evenly this month.",
    sentToReviewCount >= carryForwardCount + leftVagueCount
      ? "Carryover stayed explicit."
      : leftVagueCount > 0
        ? "Some unfinished pressure stayed vague."
        : "Carryover leaned toward being pushed forward.",
    overloaded
      ? "This month was fuller than execution reality supported."
      : "The month stayed within a believable load.",
  ];

  const headline =
    summary.goalCoverageCount === 0
      ? `${formatMonthLabel(monthStartDate)} stayed mostly aspirational.`
      : summary.underrepresentedGoalCount > 0
        ? `${formatMonthLabel(monthStartDate)} moved some priorities while leaving others mostly in name only.`
        : `${formatMonthLabel(monthStartDate)} kept stated priorities visible in actual execution.`;

  return {
    monthStartDate,
    monthEndDate,
    summary,
    reads,
    headline,
    goalCoverage,
    underrepresentedGoals,
    dragGoals,
  };
}

export function describeMonthlyStrategy(params: {
  posture: MonthlyPosture | null;
  emphasis: MonthlyEmphasis | null;
  pressureLevel: MonthlyPressureLevel | null;
  carryoverStance: MonthlyCarryoverStance | null;
}) {
  const posture =
    params.posture === MonthlyPosture.BuildMomentum
      ? "build momentum"
      : params.posture === MonthlyPosture.PushOutput
        ? "push output"
        : "stabilize";
  const emphasis =
    params.emphasis === MonthlyEmphasis.DeepenPriorityArea
      ? "deepen one priority area"
      : params.emphasis === MonthlyEmphasis.RebalanceNeglectedAreas
        ? "rebalance neglected areas"
        : "protect essentials";
  const pressure =
    params.pressureLevel === MonthlyPressureLevel.Lighter
      ? "lighter"
      : params.pressureLevel === MonthlyPressureLevel.Fuller
        ? "fuller"
        : "balanced";
  const carryover =
    params.carryoverStance === MonthlyCarryoverStance.PruneAggressively
      ? "prune aggressively"
      : params.carryoverStance === MonthlyCarryoverStance.TolerateMoreCarryover
        ? "tolerate more carryover"
        : "review before carrying";

  return `${posture}, ${emphasis}, ${pressure} pressure, ${carryover}`;
}

export function summarizeMonthlyContinuity(states: MonthlyReviewState[]) {
  const reviewedMonths = states.filter((state) => state.reviewedAt).length;
  const shapedMonths = states.filter((state) => state.strategySetAt).length;
  const summarized = states.filter((state) => state.summary);

  return {
    reviewedMonths,
    shapedMonths,
    averageMonthlyChurn: average(summarized.map((state) => state.summary?.churnRate ?? 0)),
    averageGoalCoverage: average(summarized.map((state) => state.summary?.goalCoverageCount ?? 0)),
    averageUnderrepresentation: average(
      summarized.map((state) => state.summary?.underrepresentedGoalCount ?? 0),
    ),
  };
}
