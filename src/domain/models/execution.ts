import { ISODateTimeString, JsonMap } from "./shared";
import { Task, TaskSchedulingState, TaskStatus, TimeBlock, DailyPlan } from "./planning";

export enum TaskActionType {
  Start = "start",
  Complete = "complete",
  Skip = "skip",
  Miss = "miss",
  Defer = "defer",
  Unschedule = "unschedule",
}

export enum TaskTransitionReason {
  Started = "started",
  Completed = "completed",
  Skipped = "skipped",
  Missed = "missed",
  Deferred = "deferred",
  Unscheduled = "unscheduled",
  RecoverySplit = "recovery_split",
  RecoverySubstitute = "recovery_substitute",
}

export type PlanPressureLevel = "low" | "moderate" | "high";
export type RecoveryStrategy = "split" | "substitute" | "defer" | "unscheduled";

export interface TaskActionEvent {
  taskId: string;
  type: TaskActionType;
  occurredAt: ISODateTimeString;
  actualMinutes?: number | null;
  note?: string | null;
}

export interface TaskTransition {
  taskId: string;
  fromStatus: TaskStatus;
  toStatus: TaskStatus;
  fromSchedulingState: TaskSchedulingState;
  toSchedulingState: TaskSchedulingState;
  reason: TaskTransitionReason;
  explanation: string;
  occurredAt: ISODateTimeString;
}

export interface PlanPressureSnapshot {
  level: PlanPressureLevel;
  unresolvedTaskCount: number;
  missedTaskCount: number;
  recoveryCandidateCount: number;
  continuityTaskCount: number;
}

export interface RecoveryTaskCandidate {
  task: Task;
  strategy: RecoveryStrategy;
  explanation: string;
}

export interface ExecutionMutationSet {
  tasksToSave: Task[];
  blocksToSave: TimeBlock[];
  dailyPlan: DailyPlan;
}

export interface ExecutionAuditTrail {
  event: TaskActionEvent;
  transition: TaskTransition;
  appliedStrategy: RecoveryStrategy | null;
  explanation: string;
  metadata: JsonMap;
}
