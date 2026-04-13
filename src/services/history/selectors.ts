import {
  AdaptationProfile,
  ActivityEvent,
  ActivityEventKind,
  Goal,
  GoalMilestone,
  GoalMilestoneStatus,
  Task,
  TaskStatus,
} from "../../domain/models";
import { formatShortDate, getCurrentLocalDateString } from "../../utils/date";
import {
  buildGoalPersonalization,
  buildInsightHighlights,
} from "../personalization/selectors";

export interface ActivityFeedItem extends ActivityEvent {
  derived: boolean;
}

export interface ActivityDateGroup {
  date: string;
  items: ActivityFeedItem[];
}

function createDerivedId(prefix: string, id: string) {
  return `${prefix}:${id}`;
}

function addDays(date: string, amount: number) {
  const base = new Date(`${date}T12:00:00`);
  base.setDate(base.getDate() + amount);
  return base.toISOString().slice(0, 10);
}

function daysBetween(left: string, right: string) {
  const leftMs = Date.parse(`${left}T12:00:00`);
  const rightMs = Date.parse(`${right}T12:00:00`);
  return Math.round((leftMs - rightMs) / 86400000);
}

export function buildActivityFeed(
  events: ActivityEvent[],
  tasks: Task[],
  milestones: GoalMilestone[],
): ActivityFeedItem[] {
  const existingTaskCompletions = new Set(
    events
      .filter((event) => event.kind === ActivityEventKind.TaskCompleted && event.taskId)
      .map((event) => event.taskId as string),
  );
  const existingMilestoneCompletions = new Set(
    events
      .filter((event) => event.kind === ActivityEventKind.MilestoneCompleted && event.milestoneId)
      .map((event) => event.milestoneId as string),
  );

  const derivedTaskCompletions: ActivityFeedItem[] = tasks
    .filter((task) => task.completedAt && !existingTaskCompletions.has(task.id))
    .map((task) => ({
      id: createDerivedId("derived-task-complete", task.id),
      kind: ActivityEventKind.TaskCompleted,
      occurredAt: task.completedAt as string,
      date: (task.completedAt as string).slice(0, 10),
      title: task.title,
      detail: "Completed before the richer history model was in place.",
      outcomeLabel: "Completed",
      goalId: task.goalId,
      milestoneId: task.milestoneId,
      taskId: task.id,
      dailyPlanId: null,
      timeBlockId: null,
      metadata: { source: "derived_completion" },
      ownerUserId: task.ownerUserId,
      remoteId: null,
      syncState: task.syncState,
      version: task.version,
      lastSyncedAt: task.lastSyncedAt,
      createdAt: task.completedAt as string,
      updatedAt: task.completedAt as string,
      derived: true,
    }));

  const derivedMilestones: ActivityFeedItem[] = milestones
    .filter(
      (milestone) =>
        milestone.status === GoalMilestoneStatus.Completed &&
        milestone.completedAt &&
        !existingMilestoneCompletions.has(milestone.id),
    )
    .map((milestone) => ({
      id: createDerivedId("derived-milestone-complete", milestone.id),
      kind: ActivityEventKind.MilestoneCompleted,
      occurredAt: milestone.completedAt as string,
      date: (milestone.completedAt as string).slice(0, 10),
      title: milestone.title,
      detail: "Milestone completion carried forward from the current goal structure.",
      outcomeLabel: "Completed",
      goalId: milestone.goalId,
      milestoneId: milestone.id,
      taskId: null,
      dailyPlanId: null,
      timeBlockId: null,
      metadata: { source: "derived_completion" },
      ownerUserId: milestone.ownerUserId,
      remoteId: null,
      syncState: milestone.syncState,
      version: milestone.version,
      lastSyncedAt: milestone.lastSyncedAt,
      createdAt: milestone.completedAt as string,
      updatedAt: milestone.completedAt as string,
      derived: true,
    }));

  return [...events.map((event) => ({ ...event, derived: false })), ...derivedTaskCompletions, ...derivedMilestones]
    .sort((left, right) => right.occurredAt.localeCompare(left.occurredAt));
}

export function groupActivityByDate(items: ActivityFeedItem[]): ActivityDateGroup[] {
  const groups = new Map<string, ActivityFeedItem[]>();

  items.forEach((item) => {
    const existing = groups.get(item.date) ?? [];
    existing.push(item);
    groups.set(item.date, existing);
  });

  return [...groups.entries()]
    .sort((left, right) => right[0].localeCompare(left[0]))
    .map(([date, groupedItems]) => ({ date, items: groupedItems }));
}

export function summarizeGoalProgress(params: {
  goal: Goal;
  milestones: GoalMilestone[];
  tasks: Task[];
  events: ActivityFeedItem[];
  profile?: AdaptationProfile | null;
  adaptiveEnabled?: boolean;
}) {
  const { goal, milestones, tasks, events, profile = null, adaptiveEnabled = true } = params;
  const completedTasks = tasks.filter((task) => task.status === TaskStatus.Completed).length;
  const activeTasks = tasks.filter((task) =>
    [TaskStatus.Ready, TaskStatus.Scheduled, TaskStatus.InProgress].includes(task.status),
  ).length;
  const carryTasks = tasks.filter((task) =>
    [
      TaskStatus.Deferred,
      TaskStatus.Missed,
      TaskStatus.Skipped,
      TaskStatus.Split,
      TaskStatus.Substituted,
      TaskStatus.Unscheduled,
    ].includes(task.status),
  ).length;
  const completedMilestones = milestones.filter(
    (milestone) => milestone.status === GoalMilestoneStatus.Completed,
  ).length;
  const recentEvents = events.filter((event) => event.goalId === goal.id).slice(0, 8);
  const recentWeekEvents = events.filter(
    (event) => event.goalId === goal.id && daysBetween(getCurrentLocalDateString(), event.date) <= 6,
  );
  const completionEvents = recentWeekEvents.filter(
    (event) =>
      event.kind === ActivityEventKind.TaskCompleted ||
      event.kind === ActivityEventKind.MilestoneCompleted,
  ).length;
  const recoveryEvents = recentWeekEvents.filter((event) =>
    [
      ActivityEventKind.TaskDeferred,
      ActivityEventKind.TaskMissed,
      ActivityEventKind.TaskSkipped,
      ActivityEventKind.TaskRescheduled,
    ].includes(event.kind),
  ).length;

  const reflection =
    completionEvents === 0 && recoveryEvents === 0
      ? "This goal has been quiet recently."
      : completionEvents >= recoveryEvents + 2
        ? "This goal has moved steadily this week."
        : recoveryEvents > completionEvents
          ? "This goal has seen more reshaping than completion lately."
          : "This goal is still moving, with a mix of progress and reshaping.";
  const personalization = buildGoalPersonalization({
    goal,
    tasks,
    profile,
    adaptiveEnabled,
  });

  return {
    completedTasks,
    activeTasks,
    carryTasks,
    completedMilestones,
    milestoneCount: milestones.length,
    taskCount: tasks.length,
    recentEvents,
    reflection:
      recoveryEvents > completionEvents && personalization.nextMove
        ? `${reflection} ${personalization.nextMove}`
        : reflection,
    momentumStyle: personalization.momentumStyle,
    nextMove: personalization.nextMove,
  };
}

export function buildMomentumSeries(events: ActivityFeedItem[], days = 7) {
  const today = getCurrentLocalDateString();
  return Array.from({ length: days }, (_, index) => {
    const date = addDays(today, index - (days - 1));
    const dayEvents = events.filter((event) => event.date === date);

    return {
      date,
      completed: dayEvents.filter(
        (event) =>
          event.kind === ActivityEventKind.TaskCompleted ||
          event.kind === ActivityEventKind.MilestoneCompleted,
      ).length,
      reshaped: dayEvents.filter((event) =>
        [
          ActivityEventKind.TaskDeferred,
          ActivityEventKind.TaskMissed,
          ActivityEventKind.TaskSkipped,
          ActivityEventKind.TaskRescheduled,
          ActivityEventKind.PlanReviewAccepted,
          ActivityEventKind.PlanReviewGenerated,
        ].includes(event.kind),
      ).length,
    };
  });
}

export function summarizeInsights(params: {
  goals: Goal[];
  tasks: Task[];
  milestones: GoalMilestone[];
  events: ActivityFeedItem[];
  profile?: AdaptationProfile | null;
  adaptiveEnabled?: boolean;
}) {
  const { goals, tasks, milestones, events, profile = null, adaptiveEnabled = true } = params;
  const momentum = buildMomentumSeries(events, 7);
  const completedThisWeek = momentum.reduce((sum, day) => sum + day.completed, 0);
  const reshapedThisWeek = momentum.reduce((sum, day) => sum + day.reshaped, 0);
  const activeGoalIds = new Set(goals.filter((goal) => goal.status === "active").map((goal) => goal.id));
  const movingGoalCount = new Set(
    events
      .filter((event) => event.goalId && activeGoalIds.has(event.goalId))
      .map((event) => event.goalId as string),
  ).size;
  const completedTasks = tasks.filter((task) => task.status === TaskStatus.Completed).length;
  const completedMilestones = milestones.filter(
    (milestone) => milestone.status === GoalMilestoneStatus.Completed,
  ).length;
  const planChangeCount = events.filter((event) =>
    [
      ActivityEventKind.PlanReviewAccepted,
      ActivityEventKind.PlanReviewGenerated,
      ActivityEventKind.PlanReviewReverted,
      ActivityEventKind.GoalUpdated,
    ].includes(event.kind),
  ).length;

  const momentumCopy =
    completedThisWeek === 0 && reshapedThisWeek === 0
      ? "History is still shallow, so reflection is starting from a small signal set."
      : completedThisWeek > reshapedThisWeek
        ? "Recent movement came more from finishing work than from reshaping it."
        : reshapedThisWeek > completedThisWeek
          ? "Recent movement leaned more toward adjustments and carryover."
          : "Recent movement stayed balanced between finishing and adjusting work.";

  const planCopy =
    planChangeCount === 0
      ? "The plan stayed mostly stable."
      : planChangeCount <= 2
        ? "The plan changed, but without constant churn."
        : "The plan has been adjusted several times recently.";
  const personalizedHighlights = buildInsightHighlights(profile, adaptiveEnabled);

  return {
    momentum,
    completedThisWeek,
    reshapedThisWeek,
    movingGoalCount,
    completedTasks,
    completedMilestones,
    planChangeCount,
    momentumCopy,
    planCopy,
    personalizedHighlights,
  };
}

export function formatTargetDateChange(previousDate: string | null, nextDate: string | null) {
  if (!previousDate && nextDate) {
    return `Moved onto ${formatShortDate(nextDate)}.`;
  }

  if (previousDate && nextDate) {
    return `Moved from ${formatShortDate(previousDate)} to ${formatShortDate(nextDate)}.`;
  }

  if (previousDate && !nextDate) {
    return `Removed from ${formatShortDate(previousDate)} without a new date yet.`;
  }

  return "Timing changed.";
}
