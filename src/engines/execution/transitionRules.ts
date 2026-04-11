import {
  TaskActionEvent,
  TaskActionType,
  TaskSchedulingState,
  TaskStatus,
  TaskTransitionReason,
} from "../../domain/models";
import { Task } from "../../domain/models";

interface TransitionDefinition {
  toStatus: TaskStatus;
  toSchedulingState: TaskSchedulingState;
  reason: TaskTransitionReason;
  explanation: string;
}

function baseTransition(task: Task, event: TaskActionEvent): TransitionDefinition {
  switch (event.type) {
    case TaskActionType.Start:
      return {
        toStatus: TaskStatus.InProgress,
        toSchedulingState: TaskSchedulingState.InFlight,
        reason: TaskTransitionReason.Started,
        explanation: "The task is now active and owned by the current session.",
      };
    case TaskActionType.Complete:
      return {
        toStatus: TaskStatus.Completed,
        toSchedulingState: TaskSchedulingState.Done,
        reason: TaskTransitionReason.Completed,
        explanation: "The task was completed and removed from remaining day pressure.",
      };
    case TaskActionType.Skip:
      return {
        toStatus: TaskStatus.Skipped,
        toSchedulingState: TaskSchedulingState.Unscheduled,
        reason: TaskTransitionReason.Skipped,
        explanation: "The task was intentionally skipped instead of being silently pushed forward.",
      };
    case TaskActionType.Defer:
      return {
        toStatus: TaskStatus.Deferred,
        toSchedulingState: TaskSchedulingState.Unscheduled,
        reason: TaskTransitionReason.Deferred,
        explanation: "The task was preserved, but removed from the current day.",
      };
    case TaskActionType.Unschedule:
      return {
        toStatus: TaskStatus.Unscheduled,
        toSchedulingState: TaskSchedulingState.Unscheduled,
        reason: TaskTransitionReason.Unscheduled,
        explanation: "The task is no longer assigned to this day or window.",
      };
    case TaskActionType.Miss:
    default:
      return {
        toStatus: TaskStatus.Missed,
        toSchedulingState: TaskSchedulingState.Unscheduled,
        reason: TaskTransitionReason.Missed,
        explanation: "The task was not completed in its planned window and needs recovery handling.",
      };
  }
}

function isTerminalStatus(status: TaskStatus) {
  return [TaskStatus.Completed, TaskStatus.Cancelled].includes(status);
}

export function resolveTransition(task: Task, event: TaskActionEvent) {
  if (isTerminalStatus(task.status)) {
    throw new Error(`Task "${task.title}" is already terminal and cannot process ${event.type}.`);
  }

  if (event.type === TaskActionType.Start && task.status === TaskStatus.InProgress) {
    throw new Error(`Task "${task.title}" is already in progress.`);
  }

  return baseTransition(task, event);
}
