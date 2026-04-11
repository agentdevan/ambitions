import {
  Goal,
  GoalMilestone,
  GoalMilestoneStatus,
  Task,
  TaskDifficulty,
  TaskSchedulingState,
  TaskStatus,
} from "../../domain/models";
import { appServices } from "../../bootstrap/runtime/appServices";
import {
  GoalEditImpactPreview,
  GoalReviewDraft,
  GoalReviewMode,
  GoalRollbackSnapshot,
  hasUserAdjustedMetadata,
  markTaskAsUserAdjusted,
} from "./metadata";
import { buildGoalReviewDraft } from "./planReviewCoordinator";

function createId(prefix: string) {
  return `${prefix}-${Math.random().toString(36).slice(2, 10)}`;
}

function nowIso() {
  return new Date().toISOString();
}

function addHours(iso: string, hours: number) {
  return new Date(Date.parse(iso) + hours * 3600000).toISOString();
}

export async function prepareGoalReview(params: {
  goal: Goal;
  mode: GoalReviewMode;
  existingMilestones: GoalMilestone[];
  existingTasks: Task[];
  userPreferences: NonNullable<Awaited<ReturnType<typeof appServices.repositories.preferences.getUserPreferences>>>;
  adaptationProfile: Awaited<ReturnType<typeof appServices.repositories.adaptation.getLatestProfile>>;
  impact: GoalEditImpactPreview | null;
}) {
  const decomposition = await appServices.engines.decomposition.decompose({
    goal: params.goal,
    milestones: params.existingMilestones,
    existingTasks: params.existingTasks,
    preferences: params.userPreferences,
    adaptationProfile: params.adaptationProfile,
    referenceDate: params.goal.startDate ?? undefined,
  });

  const generatedMilestones = decomposition.payload.milestones.map((milestone, index) => ({
    ...milestone,
    goalId: params.goal.id,
    id: `${params.goal.id}-milestone-review-${index + 1}`,
    sortOrder: index + 1,
  }));
  const milestoneIdMap = new Map(
    decomposition.payload.milestones.map((milestone, index) => [
      milestone.id,
      generatedMilestones[index].id,
    ]),
  );
  const generatedTasks = decomposition.payload.tasks.map((task, index) => ({
    ...task,
    goalId: params.goal.id,
    milestoneId: task.milestoneId ? milestoneIdMap.get(task.milestoneId) ?? task.milestoneId : null,
    id: `${params.goal.id}-task-review-${index + 1}`,
  }));

  return buildGoalReviewDraft({
    goal: params.goal,
    mode: params.mode,
    existingMilestones: params.existingMilestones,
    existingTasks: params.existingTasks,
    generatedMilestones,
    generatedTasks,
    impact: params.impact,
  });
}

export function materializeAcceptedReview(params: {
  goal: Goal;
  reviewDraft: GoalReviewDraft;
  existingMilestones: GoalMilestone[];
  existingTasks: Task[];
}) {
  const milestoneMap = new Map(params.existingMilestones.map((milestone) => [milestone.id, milestone]));
  const taskMap = new Map(params.existingTasks.map((task) => [task.id, task]));
  const timestamp = nowIso();
  const nextMilestones: GoalMilestone[] = [];
  const nextTasks: Task[] = [];
  const acceptedMilestoneIds = new Set<string>();
  const acceptedTaskIds = new Set<string>();
  const createdMilestoneIds: string[] = [];
  const createdTaskIds: string[] = [];

  for (const draft of params.reviewDraft.milestones) {
    const existing = draft.sourceMilestoneId ? milestoneMap.get(draft.sourceMilestoneId) ?? null : null;
    const next: GoalMilestone = {
      ...(existing ?? {
        id: draft.id,
        ownerUserId: params.goal.ownerUserId,
        remoteId: null,
        syncState: params.goal.syncState,
        version: 1,
        lastSyncedAt: null,
        createdAt: timestamp,
        updatedAt: timestamp,
        goalId: params.goal.id,
        title: draft.title,
        summary: draft.summary,
        status: GoalMilestoneStatus.Pending,
        targetDate: draft.targetDate,
        completedAt: null,
        sortOrder: draft.sortOrder,
        estimatedMinutes: draft.estimatedMinutes,
        metadata: {},
      }),
      id: existing?.id ?? draft.id,
      goalId: params.goal.id,
      title: draft.title,
      summary: draft.summary,
      targetDate: draft.targetDate,
      sortOrder: draft.sortOrder,
      estimatedMinutes: draft.estimatedMinutes,
      updatedAt: timestamp,
      version: existing ? existing.version + 1 : 1,
      metadata: {
        ...(existing?.metadata ?? {}),
        planningContinuityKey: draft.continuityKey,
        phase11ManualOrder: draft.sortOrder,
        phase11Preserved: draft.protected,
      },
    };

    nextMilestones.push(next);
    acceptedMilestoneIds.add(next.id);
    if (!existing) {
      createdMilestoneIds.push(next.id);
    }
  }

  for (const draft of params.reviewDraft.tasks.filter((task) => !task.removed)) {
    const existing = draft.sourceTaskId ? taskMap.get(draft.sourceTaskId) ?? null : null;
    const nextBase: Task =
      existing ??
      ({
        id: draft.id,
        ownerUserId: params.goal.ownerUserId,
        remoteId: null,
        syncState: params.goal.syncState,
        version: 1,
        lastSyncedAt: null,
        createdAt: timestamp,
        updatedAt: timestamp,
        goalId: params.goal.id,
        milestoneId: draft.milestoneId,
        parentTaskId: null,
        title: draft.title,
        summary: draft.summary,
        status: TaskStatus.Ready,
        schedulingState: TaskSchedulingState.Unscheduled,
        difficulty: TaskDifficulty.Light,
        estimatedMinutes: draft.estimatedMinutes,
        actualMinutes: null,
        effortPoints: 1,
        targetDate: draft.targetDate,
        scheduledDate: null,
        earliestStartAt: null,
        latestFinishAt: null,
        completedAt: null,
        isRecurringTemplate: false,
        tags: [params.goal.domainKey],
        metadata: {},
      } as Task);
    const nextTask: Task = {
      ...nextBase,
      id: existing?.id ?? draft.id,
      goalId: params.goal.id,
      milestoneId: draft.milestoneId,
      title: draft.title,
      summary: draft.summary,
      targetDate: draft.targetDate,
      estimatedMinutes: draft.estimatedMinutes,
      updatedAt: timestamp,
      version: existing ? existing.version + 1 : 1,
      metadata: {
        ...nextBase.metadata,
        planningContinuityKey: draft.continuityKey,
        phase11ManualOrder: draft.order,
      },
    };

    nextTasks.push(draft.userAdjusted ? markTaskAsUserAdjusted(nextTask) : nextTask);
    acceptedTaskIds.add(nextTask.id);
    if (!existing) {
      createdTaskIds.push(nextTask.id);
    }
  }

  const archivedMilestones = params.existingMilestones
    .filter((milestone) => !acceptedMilestoneIds.has(milestone.id))
    .map((milestone) => ({
      ...milestone,
      status: hasUserAdjustedMetadata(milestone) ? milestone.status : GoalMilestoneStatus.Archived,
      updatedAt: timestamp,
      version: milestone.version + 1,
    }));
  const cancelledTasks = params.existingTasks
    .filter((task) => !acceptedTaskIds.has(task.id))
    .map((task) => ({
      ...task,
      status: hasUserAdjustedMetadata(task) ? task.status : TaskStatus.Cancelled,
      schedulingState:
        hasUserAdjustedMetadata(task) || task.status === TaskStatus.InProgress
          ? task.schedulingState
          : TaskSchedulingState.Unscheduled,
      scheduledDate:
        hasUserAdjustedMetadata(task) || task.status === TaskStatus.InProgress
          ? task.scheduledDate
          : null,
      earliestStartAt:
        hasUserAdjustedMetadata(task) || task.status === TaskStatus.InProgress
          ? task.earliestStartAt
          : null,
      latestFinishAt:
        hasUserAdjustedMetadata(task) || task.status === TaskStatus.InProgress
          ? task.latestFinishAt
          : null,
      updatedAt: timestamp,
      version: task.version + 1,
    }));

  const rollbackSnapshot: GoalRollbackSnapshot = {
    id: createId("rollback"),
    createdAt: timestamp,
    expiresAt: addHours(timestamp, 24),
    mode: params.reviewDraft.mode,
    summary:
      params.reviewDraft.mode === "full_regeneration"
        ? "Full regeneration can be undone for a short time."
        : "The latest regeneration can be undone if the recommendation missed the mark.",
    milestones: params.existingMilestones,
    tasks: params.existingTasks,
    generatedMilestoneIds: createdMilestoneIds,
    generatedTaskIds: createdTaskIds,
  };

  return {
    milestonesToSave: [...nextMilestones, ...archivedMilestones],
    tasksToSave: [...nextTasks, ...cancelledTasks],
    rollbackSnapshot,
  };
}

export function restoreRollbackSnapshot(params: {
  rollbackSnapshot: GoalRollbackSnapshot;
  existingMilestones: GoalMilestone[];
  existingTasks: Task[];
}) {
  const timestamp = nowIso();
  const nextMilestones = params.existingMilestones
    .filter((milestone) => params.rollbackSnapshot.generatedMilestoneIds.includes(milestone.id))
    .map((milestone) => ({
      ...milestone,
      status: GoalMilestoneStatus.Archived,
      updatedAt: timestamp,
      version: milestone.version + 1,
    }));
  const nextTasks = params.existingTasks
    .filter((task) => params.rollbackSnapshot.generatedTaskIds.includes(task.id))
    .map((task) => ({
      ...task,
      status: TaskStatus.Cancelled,
      schedulingState: TaskSchedulingState.Unscheduled,
      scheduledDate: null,
      earliestStartAt: null,
      latestFinishAt: null,
      updatedAt: timestamp,
      version: task.version + 1,
    }));

  return {
    milestonesToSave: [...params.rollbackSnapshot.milestones, ...nextMilestones],
    tasksToSave: [...params.rollbackSnapshot.tasks, ...nextTasks],
  };
}

export function getReviewPendingGoalIds(goals: Goal[]) {
  return goals
    .filter((goal) => goal.metadata.phase11ReviewDraft)
    .map((goal) => goal.id);
}

export function hasUndoAvailable(goal: Goal) {
  const snapshot = goal.metadata.phase11RollbackSnapshot;
  if (!snapshot || typeof snapshot !== "object" || Array.isArray(snapshot)) {
    return false;
  }

  return typeof snapshot.expiresAt === "string" && Date.parse(snapshot.expiresAt) > Date.now();
}
