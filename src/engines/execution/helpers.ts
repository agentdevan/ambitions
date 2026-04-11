import {
  DailyPlan,
  EntitySyncState,
  RecoveryStrategy,
  Task,
  TaskDifficulty,
  TaskSchedulingState,
  TaskStatus,
  TimeBlock,
  TimeBlockState,
} from "../../domain/models";

export function createTimestampedId(prefix: string, seed: string, occurredAt: string) {
  return `${prefix}-${seed}-${occurredAt.replace(/[:.]/g, "-")}`;
}

export function cloneTask(task: Task, patch: Partial<Task>): Task {
  return {
    ...task,
    ...patch,
    metadata: {
      ...task.metadata,
      ...(patch.metadata ?? {}),
    },
  };
}

export function cloneBlock(block: TimeBlock, patch: Partial<TimeBlock>): TimeBlock {
  return {
    ...block,
    ...patch,
    metadata: {
      ...block.metadata,
      ...(patch.metadata ?? {}),
    },
  };
}

export function classifyPressureLevel(unresolvedTaskCount: number, missedTaskCount: number) {
  if (missedTaskCount >= 2 || unresolvedTaskCount >= 5) {
    return "high" as const;
  }

  if (missedTaskCount >= 1 || unresolvedTaskCount >= 3) {
    return "moderate" as const;
  }

  return "low" as const;
}

export function parseBooleanMetadata(value: unknown) {
  return value === true || value === "true";
}

export function deriveWorkType(task: Task) {
  return String(task.metadata.planningWorkType ?? "");
}

export function deriveProtectiveMode(task: Task) {
  return parseBooleanMetadata(task.metadata.planningProtectiveMode);
}

export function fallbackTaskTitle(task: Task) {
  const fallback = String(task.metadata.planningFallbackTitle ?? "").trim();
  return fallback.length > 0 ? fallback : `Start ${task.title.toLowerCase()}`;
}

export function nextDifficulty(current: TaskDifficulty) {
  if (current === TaskDifficulty.Deep) {
    return TaskDifficulty.Moderate;
  }

  return TaskDifficulty.Light;
}

export function lowerSchedulingState(task: Task) {
  if (task.schedulingState === TaskSchedulingState.InFlight) {
    return TaskSchedulingState.Unscheduled;
  }

  if (task.schedulingState === TaskSchedulingState.Committed) {
    return TaskSchedulingState.Unscheduled;
  }

  return TaskSchedulingState.Unscheduled;
}

export function statusForRecovery(strategy: RecoveryStrategy) {
  switch (strategy) {
    case "split":
      return TaskStatus.Split;
    case "substitute":
      return TaskStatus.Substituted;
    case "defer":
      return TaskStatus.Deferred;
    default:
      return TaskStatus.Missed;
  }
}

export function blockStateForTaskStatus(status: TaskStatus, action: "start" | "complete" | "skip" | "miss" | "defer" | "unschedule") {
  if (action === "start") return TimeBlockState.Active;
  if (action === "complete") return TimeBlockState.Complete;
  if (action === "defer") return TimeBlockState.Deferred;
  if (action === "skip") return TimeBlockState.Cancelled;
  if (status === TaskStatus.Missed || status === TaskStatus.Split || status === TaskStatus.Substituted) {
    return TimeBlockState.Rolled;
  }
  return TimeBlockState.Deferred;
}

export function updateDailyPlanPressure(
  dailyPlan: DailyPlan,
  pressure: {
    level: "low" | "moderate" | "high";
    unresolvedTaskCount: number;
    missedTaskCount: number;
    recoveryCandidateCount: number;
    continuityTaskCount: number;
  },
  occurredAt: string,
) {
  return {
    ...dailyPlan,
    updatedAt: occurredAt,
    metadata: {
      ...dailyPlan.metadata,
      executionPlanPressure: pressure.level,
      executionUnresolvedTaskCount: pressure.unresolvedTaskCount,
      executionMissedTaskCount: pressure.missedTaskCount,
      executionRecoveryCandidateCount: pressure.recoveryCandidateCount,
      executionContinuityTaskCount: pressure.continuityTaskCount,
      executionReviewedAt: occurredAt,
    },
  } satisfies DailyPlan;
}

export function buildRecoveryTaskBase(params: {
  sourceTask: Task;
  id: string;
  title: string;
  summary: string | null;
  estimatedMinutes: number;
  difficulty: TaskDifficulty;
  status?: TaskStatus;
  scheduledDate?: string | null;
  strategy: RecoveryStrategy;
  occurredAt: string;
}): Task {
  const { sourceTask } = params;

  return {
    ...sourceTask,
    id: params.id,
    parentTaskId: sourceTask.id,
    title: params.title,
    summary: params.summary,
    estimatedMinutes: params.estimatedMinutes,
    difficulty: params.difficulty,
    status: params.status ?? TaskStatus.Unscheduled,
    schedulingState: TaskSchedulingState.Unscheduled,
    scheduledDate: params.scheduledDate ?? null,
    targetDate: params.scheduledDate ?? sourceTask.targetDate,
    earliestStartAt: null,
    latestFinishAt: null,
    completedAt: null,
    actualMinutes: null,
    syncState: EntitySyncState.LocalOnly,
    version: 1,
    lastSyncedAt: null,
    createdAt: params.occurredAt,
    updatedAt: params.occurredAt,
    metadata: {
      ...sourceTask.metadata,
      recoverySourceTaskId: sourceTask.id,
      recoveryStrategy: params.strategy,
      recoveryGeneratedAt: params.occurredAt,
    },
  };
}
