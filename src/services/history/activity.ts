import {
  ActivityEvent,
  ActivityEventKind,
  DailyRitualCarryDecision,
  DailyRitualOpeningFocus,
  DailyRitualRecoveryMode,
  EntitySyncState,
  ExecutionAuditTrail,
  Goal,
  GoalMilestone,
  GoalStatus,
  Task,
  TimeBlock,
  WeeklyCarryoverPosture,
  WeeklyEmphasis,
  WeeklyIntensity,
} from "../../domain/models";
import { GoalDownstreamChoice, GoalReviewDraft } from "../goals/metadata";
import { formatShortDate } from "../../utils/date";

function createId(prefix: string) {
  return `${prefix}-${Math.random().toString(36).slice(2, 10)}`;
}

function activityBase(occurredAt: string): Pick<
  ActivityEvent,
  "id" | "createdAt" | "updatedAt" | "ownerUserId" | "remoteId" | "syncState" | "version" | "lastSyncedAt" | "occurredAt" | "date"
> {
  return {
    id: createId("activity"),
    occurredAt,
    date: occurredAt.slice(0, 10),
    ownerUserId: null,
    remoteId: null,
    syncState: EntitySyncState.LocalOnly,
    version: 1,
    lastSyncedAt: null,
    createdAt: occurredAt,
    updatedAt: occurredAt,
  };
}

export function buildTaskActionActivityEvent(params: {
  audit: ExecutionAuditTrail;
  task: Task;
  block: TimeBlock | null;
  goal: Goal | null;
  milestone: GoalMilestone | null;
  dailyPlanId: string | null;
}): ActivityEvent {
  const { audit, task, block, goal, milestone, dailyPlanId } = params;
  const base = activityBase(audit.transition.occurredAt);

  const copyByKind: Record<
    ActivityEventKind,
    { outcomeLabel: string; detail: string }
  > = {
    [ActivityEventKind.TaskStarted]: {
      outcomeLabel: "Started",
      detail: "A focused block began on this task.",
    },
    [ActivityEventKind.TaskCompleted]: {
      outcomeLabel: "Completed",
      detail: "Completed inside the active plan.",
    },
    [ActivityEventKind.TaskDeferred]: {
      outcomeLabel: "Deferred",
      detail: audit.explanation,
    },
    [ActivityEventKind.TaskSkipped]: {
      outcomeLabel: "Skipped",
      detail: audit.explanation,
    },
    [ActivityEventKind.TaskMissed]: {
      outcomeLabel: "Missed",
      detail: audit.explanation,
    },
    [ActivityEventKind.TaskRescheduled]: {
      outcomeLabel: "Moved",
      detail: audit.explanation,
    },
    [ActivityEventKind.PlanReviewGenerated]: {
      outcomeLabel: "Updated",
      detail: audit.explanation,
    },
    [ActivityEventKind.PlanReviewAccepted]: {
      outcomeLabel: "Accepted",
      detail: audit.explanation,
    },
    [ActivityEventKind.PlanReviewReverted]: {
      outcomeLabel: "Reverted",
      detail: audit.explanation,
    },
    [ActivityEventKind.GoalStatusChanged]: {
      outcomeLabel: "Changed",
      detail: audit.explanation,
    },
    [ActivityEventKind.GoalUpdated]: {
      outcomeLabel: "Updated",
      detail: audit.explanation,
    },
    [ActivityEventKind.MilestoneCompleted]: {
      outcomeLabel: "Completed",
      detail: audit.explanation,
    },
    [ActivityEventKind.DayOpened]: {
      outcomeLabel: "Opened",
      detail: audit.explanation,
    },
    [ActivityEventKind.DayRecovered]: {
      outcomeLabel: "Reset",
      detail: audit.explanation,
    },
    [ActivityEventKind.DayClosed]: {
      outcomeLabel: "Closed",
      detail: audit.explanation,
    },
    [ActivityEventKind.ReflectionLogged]: {
      outcomeLabel: "Logged",
      detail: audit.explanation,
    },
    [ActivityEventKind.CarryoverReviewed]: {
      outcomeLabel: "Reviewed",
      detail: audit.explanation,
    },
    [ActivityEventKind.WeekReviewed]: {
      outcomeLabel: "Reviewed",
      detail: audit.explanation,
    },
    [ActivityEventKind.NextWeekShaped]: {
      outcomeLabel: "Shaped",
      detail: audit.explanation,
    },
    [ActivityEventKind.WeeklyCarryoverReviewed]: {
      outcomeLabel: "Reviewed",
      detail: audit.explanation,
    },
  };

  const kind =
    audit.event.type === "start"
      ? ActivityEventKind.TaskStarted
      : audit.event.type === "complete"
        ? ActivityEventKind.TaskCompleted
        : audit.event.type === "defer"
          ? ActivityEventKind.TaskDeferred
          : audit.event.type === "skip"
            ? ActivityEventKind.TaskSkipped
            : ActivityEventKind.TaskMissed;

  return {
    ...base,
    kind,
    title: task.title,
    detail: copyByKind[kind].detail,
    outcomeLabel: copyByKind[kind].outcomeLabel,
    goalId: task.goalId,
    milestoneId: task.milestoneId,
    taskId: task.id,
    dailyPlanId,
    timeBlockId: block?.id ?? null,
    metadata: {
      goalTitle: goal?.title ?? null,
      milestoneTitle: milestone?.title ?? null,
      actionType: audit.event.type,
      transitionReason: audit.transition.reason,
      appliedStrategy: audit.appliedStrategy,
    },
  };
}

export function buildGoalStatusActivityEvent(params: {
  goal: Goal;
  nextStatus: GoalStatus;
  occurredAt: string;
}): ActivityEvent {
  const { goal, nextStatus, occurredAt } = params;

  return {
    ...activityBase(occurredAt),
    kind: ActivityEventKind.GoalStatusChanged,
    title: goal.title,
    detail: `Goal status changed to ${nextStatus.replaceAll("_", " ")}.`,
    outcomeLabel:
      nextStatus === GoalStatus.Completed
        ? "Completed"
        : nextStatus === GoalStatus.Paused
          ? "Paused"
          : nextStatus === GoalStatus.Archived
            ? "Archived"
            : "Active",
    goalId: goal.id,
    milestoneId: null,
    taskId: null,
    dailyPlanId: null,
    timeBlockId: null,
    metadata: {
      nextStatus,
    },
  };
}

export function buildGoalUpdatedActivityEvent(params: {
  goal: Goal;
  changedFields: string[];
  occurredAt: string;
  choice: GoalDownstreamChoice;
}): ActivityEvent {
  const { goal, changedFields, occurredAt, choice } = params;
  const fieldLabel = changedFields.slice(0, 3).join(", ").replaceAll("_", " ");

  return {
    ...activityBase(occurredAt),
    kind: ActivityEventKind.GoalUpdated,
    title: goal.title,
    detail:
      changedFields.length > 0
        ? `Updated ${fieldLabel}${changedFields.length > 3 ? ", and more" : ""}.`
        : "The goal definition changed.",
    outcomeLabel: choice === "keep" ? "Edited" : "Needs review",
    goalId: goal.id,
    milestoneId: null,
    taskId: null,
    dailyPlanId: null,
    timeBlockId: null,
    metadata: {
      changedFields,
      downstreamChoice: choice,
    },
  };
}

export function buildPlanReviewGeneratedActivityEvent(params: {
  goal: Goal;
  reviewDraft: GoalReviewDraft;
  occurredAt: string;
}): ActivityEvent {
  const { goal, reviewDraft, occurredAt } = params;

  return {
    ...activityBase(occurredAt),
    kind: ActivityEventKind.PlanReviewGenerated,
    title: goal.title,
    detail: reviewDraft.summary,
    outcomeLabel: "Review ready",
    goalId: goal.id,
    milestoneId: null,
    taskId: null,
    dailyPlanId: null,
    timeBlockId: null,
    metadata: {
      mode: reviewDraft.mode,
      affectedTaskCount: reviewDraft.impactSummary.affectedTaskCount,
      affectedMilestoneCount: reviewDraft.impactSummary.affectedMilestoneCount,
    },
  };
}

export function buildPlanReviewAcceptedActivityEvents(params: {
  goal: Goal;
  reviewDraft: GoalReviewDraft;
  existingTasks: Task[];
  nextTasks: Task[];
  existingMilestones: GoalMilestone[];
  nextMilestones: GoalMilestone[];
  occurredAt: string;
}): ActivityEvent[] {
  const {
    goal,
    reviewDraft,
    existingTasks,
    nextTasks,
    existingMilestones,
    nextMilestones,
    occurredAt,
  } = params;
  const events: ActivityEvent[] = [];
  const existingTaskMap = new Map(existingTasks.map((task) => [task.id, task]));
  const existingMilestoneMap = new Map(existingMilestones.map((milestone) => [milestone.id, milestone]));

  const movedTasks = nextTasks.filter((task) => {
    const previous = existingTaskMap.get(task.id);
    return previous && previous.targetDate !== task.targetDate && task.targetDate;
  });
  const archivedTasks = nextTasks.filter((task) => task.status === "cancelled");
  const updatedMilestones = nextMilestones.filter((milestone) => {
    const previous = existingMilestoneMap.get(milestone.id);
    return (
      previous &&
      (previous.targetDate !== milestone.targetDate || previous.title !== milestone.title)
    );
  });

  events.push({
    ...activityBase(occurredAt),
    kind: ActivityEventKind.PlanReviewAccepted,
    title: goal.title,
    detail: `${reviewDraft.impactSummary.affectedTaskCount} task changes and ${reviewDraft.impactSummary.affectedMilestoneCount} milestone changes were accepted.`,
    outcomeLabel: "Accepted",
    goalId: goal.id,
    milestoneId: null,
    taskId: null,
    dailyPlanId: null,
    timeBlockId: null,
    metadata: {
      mode: reviewDraft.mode,
      movedTaskCount: movedTasks.length,
      removedTaskCount: archivedTasks.length,
      updatedMilestoneCount: updatedMilestones.length,
    },
  });

  movedTasks.forEach((task) => {
    const previous = existingTaskMap.get(task.id);
    if (!previous?.targetDate || !task.targetDate) {
      return;
    }

    events.push({
      ...activityBase(occurredAt),
      kind: ActivityEventKind.TaskRescheduled,
      title: task.title,
      detail: `Moved from ${formatShortDate(previous.targetDate)} to ${formatShortDate(task.targetDate)} during the accepted review.`,
      outcomeLabel: "Moved",
      goalId: task.goalId,
      milestoneId: task.milestoneId,
      taskId: task.id,
      dailyPlanId: null,
      timeBlockId: null,
      metadata: {
        previousTargetDate: previous.targetDate,
        nextTargetDate: task.targetDate,
      },
    });
  });

  return events;
}

export function buildPlanReviewRevertedActivityEvent(params: {
  goal: Goal;
  occurredAt: string;
}): ActivityEvent {
  const { goal, occurredAt } = params;

  return {
    ...activityBase(occurredAt),
    kind: ActivityEventKind.PlanReviewReverted,
    title: goal.title,
    detail: "The last accepted regeneration was rolled back.",
    outcomeLabel: "Reverted",
    goalId: goal.id,
    milestoneId: null,
    taskId: null,
    dailyPlanId: null,
    timeBlockId: null,
    metadata: {},
  };
}

export function buildDayOpenedActivityEvent(params: {
  date: string;
  occurredAt: string;
  openingFocus: DailyRitualOpeningFocus | null;
}) {
  const { date, occurredAt, openingFocus } = params;

  return {
    ...activityBase(occurredAt),
    kind: ActivityEventKind.DayOpened,
    title: `Opened ${date}`,
    detail:
      openingFocus === DailyRitualOpeningFocus.ProtectEssentials
        ? "Opened with a narrower day in mind."
        : openingFocus === DailyRitualOpeningFocus.MeaningfulProgress
          ? "Opened with one meaningful move as the anchor."
          : openingFocus === DailyRitualOpeningFocus.KeepItLight
            ? "Opened with a lighter day in mind."
            : "Opened the day intentionally.",
    outcomeLabel: "Opened",
    goalId: null,
    milestoneId: null,
    taskId: null,
    dailyPlanId: null,
    timeBlockId: null,
    metadata: {
      date,
      openingFocus,
    },
  } satisfies ActivityEvent;
}

export function buildDayRecoveredActivityEvent(params: {
  date: string;
  occurredAt: string;
  recoveryMode: DailyRitualRecoveryMode;
  summary: string;
  changedTaskCount: number;
  changedBlockCount: number;
}) {
  const { date, occurredAt, recoveryMode, summary, changedTaskCount, changedBlockCount } = params;

  return {
    ...activityBase(occurredAt),
    kind: ActivityEventKind.DayRecovered,
    title: `Recovered ${date}`,
    detail: summary,
    outcomeLabel: "Recovered",
    goalId: null,
    milestoneId: null,
    taskId: null,
    dailyPlanId: null,
    timeBlockId: null,
    metadata: {
      date,
      recoveryMode,
      changedTaskCount,
      changedBlockCount,
    },
  } satisfies ActivityEvent;
}

export function buildDayClosedActivityEvent(params: {
  date: string;
  occurredAt: string;
  completedCount: number;
  unfinishedCount: number;
}) {
  const { date, occurredAt, completedCount, unfinishedCount } = params;

  return {
    ...activityBase(occurredAt),
    kind: ActivityEventKind.DayClosed,
    title: `Closed ${date}`,
    detail: `${completedCount} completed, ${unfinishedCount} left for a deliberate next step.`,
    outcomeLabel: "Closed",
    goalId: null,
    milestoneId: null,
    taskId: null,
    dailyPlanId: null,
    timeBlockId: null,
    metadata: {
      date,
      completedCount,
      unfinishedCount,
    },
  } satisfies ActivityEvent;
}

export function buildReflectionLoggedActivityEvent(params: {
  date: string;
  occurredAt: string;
  dayLoad: string | null;
  energy: string | null;
  clarity: string | null;
}) {
  const { date, occurredAt, dayLoad, energy, clarity } = params;

  return {
    ...activityBase(occurredAt),
    kind: ActivityEventKind.ReflectionLogged,
    title: `Reflected on ${date}`,
    detail: "Logged a quick read on load, energy, and clarity.",
    outcomeLabel: "Reflected",
    goalId: null,
    milestoneId: null,
    taskId: null,
    dailyPlanId: null,
    timeBlockId: null,
    metadata: {
      date,
      dayLoad,
      energy,
      clarity,
    },
  } satisfies ActivityEvent;
}

export function buildCarryoverReviewedActivityEvent(params: {
  date: string;
  occurredAt: string;
  decision: DailyRitualCarryDecision;
  unfinishedCount: number;
}) {
  const { date, occurredAt, decision, unfinishedCount } = params;

  return {
    ...activityBase(occurredAt),
    kind: ActivityEventKind.CarryoverReviewed,
    title: `Reviewed carryover for ${date}`,
    detail:
      decision === DailyRitualCarryDecision.CarryForward
        ? "Unfinished work was carried forward."
        : decision === DailyRitualCarryDecision.SendToReview
          ? "Unfinished work was sent back for review."
          : "Carryover was left undecided for now.",
    outcomeLabel: "Carryover",
    goalId: null,
    milestoneId: null,
    taskId: null,
    dailyPlanId: null,
    timeBlockId: null,
    metadata: {
      date,
      decision,
      unfinishedCount,
    },
  } satisfies ActivityEvent;
}

export function buildWeekReviewedActivityEvent(params: {
  weekStartDate: string;
  weekEndDate: string;
  occurredAt: string;
  completedCount: number;
  reshapedCount: number;
  heldSteady: boolean;
}) {
  const { weekStartDate, weekEndDate, occurredAt, completedCount, reshapedCount, heldSteady } =
    params;

  return {
    ...activityBase(occurredAt),
    kind: ActivityEventKind.WeekReviewed,
    title: `Reviewed ${formatShortDate(weekStartDate)} - ${formatShortDate(weekEndDate)}`,
    detail: heldSteady
      ? `${completedCount} completed and ${reshapedCount} reshaped. The week mostly held.`
      : `${completedCount} completed and ${reshapedCount} reshaped. The week needed more adjustment than follow-through.`,
    outcomeLabel: "Reviewed",
    goalId: null,
    milestoneId: null,
    taskId: null,
    dailyPlanId: null,
    timeBlockId: null,
    metadata: {
      weekStartDate,
      weekEndDate,
      completedCount,
      reshapedCount,
      heldSteady,
    },
  } satisfies ActivityEvent;
}

export function buildNextWeekShapedActivityEvent(params: {
  weekStartDate: string;
  occurredAt: string;
  intensity: WeeklyIntensity;
  emphasis: WeeklyEmphasis;
  carryoverPosture: WeeklyCarryoverPosture;
}) {
  const { weekStartDate, occurredAt, intensity, emphasis, carryoverPosture } = params;

  return {
    ...activityBase(occurredAt),
    kind: ActivityEventKind.NextWeekShaped,
    title: `Shaped week of ${formatShortDate(weekStartDate)}`,
    detail: `Set the week to ${intensity.replaceAll("_", " ")} pressure with ${emphasis.replaceAll("_", " ")} as the emphasis.`,
    outcomeLabel: "Shaped",
    goalId: null,
    milestoneId: null,
    taskId: null,
    dailyPlanId: null,
    timeBlockId: null,
    metadata: {
      weekStartDate,
      intensity,
      emphasis,
      carryoverPosture,
    },
  } satisfies ActivityEvent;
}

export function buildWeeklyCarryoverReviewedActivityEvent(params: {
  weekStartDate: string;
  occurredAt: string;
  carryCount: number;
  reviewCount: number;
  releasedCount: number;
}) {
  const { weekStartDate, occurredAt, carryCount, reviewCount, releasedCount } = params;

  return {
    ...activityBase(occurredAt),
    kind: ActivityEventKind.WeeklyCarryoverReviewed,
    title: `Reviewed weekly carryover for ${formatShortDate(weekStartDate)}`,
    detail: `${carryCount} carried, ${reviewCount} sent to review, ${releasedCount} released.`,
    outcomeLabel: "Carryover",
    goalId: null,
    milestoneId: null,
    taskId: null,
    dailyPlanId: null,
    timeBlockId: null,
    metadata: {
      weekStartDate,
      carryCount,
      reviewCount,
      releasedCount,
    },
  } satisfies ActivityEvent;
}
