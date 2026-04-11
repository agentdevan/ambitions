import { GoalMilestone, GoalMilestoneStatus, Task, TaskStatus } from "../../domain/models";
import {
  getMilestoneContinuityKey,
  getTaskContinuityKey,
  hasUserAdjustedMetadata,
} from "./metadata";

export interface ProtectedItemsSnapshot {
  milestoneIds: Set<string>;
  milestoneContinuityKeys: Set<string>;
  taskIds: Set<string>;
  taskContinuityKeys: Set<string>;
}

function isProtectedMilestone(milestone: GoalMilestone) {
  return (
    hasUserAdjustedMetadata(milestone) ||
    milestone.status === GoalMilestoneStatus.Completed ||
    milestone.status === GoalMilestoneStatus.InProgress
  );
}

function isProtectedTask(task: Task) {
  return (
    hasUserAdjustedMetadata(task) ||
    task.status === TaskStatus.Completed ||
    task.status === TaskStatus.InProgress
  );
}

export function selectProtectedItems(params: {
  milestones: GoalMilestone[];
  tasks: Task[];
}): ProtectedItemsSnapshot {
  const milestoneIds = new Set<string>();
  const milestoneContinuityKeys = new Set<string>();
  const taskIds = new Set<string>();
  const taskContinuityKeys = new Set<string>();

  for (const milestone of params.milestones) {
    if (!isProtectedMilestone(milestone)) {
      continue;
    }

    milestoneIds.add(milestone.id);
    milestoneContinuityKeys.add(getMilestoneContinuityKey(milestone));
  }

  for (const task of params.tasks) {
    if (!isProtectedTask(task)) {
      continue;
    }

    taskIds.add(task.id);
    taskContinuityKeys.add(getTaskContinuityKey(task));
  }

  return {
    milestoneIds,
    milestoneContinuityKeys,
    taskIds,
    taskContinuityKeys,
  };
}
