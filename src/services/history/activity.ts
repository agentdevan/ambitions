import {
  ActivityEvent,
  ActivityEventKind,
  EntitySyncState,
  ExecutionAuditTrail,
  Goal,
  GoalMilestone,
  GoalStatus,
  Task,
  TimeBlock,
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
