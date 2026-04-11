import {
  ExecutionRequest,
  ExecutionOutput,
  EngineResult,
} from "../types";
import {
  RecoveryTaskCandidate,
  TaskActionType,
  TaskStatus,
  TaskTransitionReason,
} from "../../domain/models";
import { resolveTransition } from "./transitionRules";
import {
  blockStateForTaskStatus,
  classifyPressureLevel,
  cloneBlock,
  cloneTask,
  lowerSchedulingState,
  statusForRecovery,
  updateDailyPlanPressure,
} from "./helpers";
import { evaluateRollover } from "./rolloverEvaluator";
import { buildSplitCandidates } from "./splitStrategies";
import { buildSubstituteCandidate } from "./substituteStrategies";
import { buildReplanSuggestion } from "./suggestionBuilders";

export interface ExecutionEngine {
  execute(request: ExecutionRequest): Promise<EngineResult<ExecutionOutput>>;
}

function recoveryCandidatesForStrategy(task: ExecutionRequest["tasks"][number], strategy: "split" | "substitute" | "defer" | "unscheduled", occurredAt: string) {
  if (strategy === "split") {
    return buildSplitCandidates(task, occurredAt);
  }

  if (strategy === "substitute") {
    const candidate = buildSubstituteCandidate(task, occurredAt);
    return candidate ? [candidate] : [];
  }

  return [] as RecoveryTaskCandidate[];
}

function applyBaseTaskMutation(request: ExecutionRequest) {
  const task = request.tasks.find((entry) => entry.id === request.event.taskId);

  if (!task) {
    throw new Error(`Could not find task ${request.event.taskId}.`);
  }

  const transition = resolveTransition(task, request.event);
  const block = request.timeBlocks.find((entry) => entry.taskId === task.id) ?? null;
  const updatedTask = cloneTask(task, {
    status: transition.toStatus,
    schedulingState: transition.toSchedulingState,
    completedAt: request.event.type === TaskActionType.Complete ? request.event.occurredAt : null,
    actualMinutes:
      request.event.type === TaskActionType.Complete
        ? (request.event.actualMinutes ?? task.actualMinutes ?? task.estimatedMinutes)
        : task.actualMinutes,
    scheduledDate:
      [TaskActionType.Skip, TaskActionType.Defer, TaskActionType.Miss, TaskActionType.Unschedule].includes(
        request.event.type,
      )
        ? null
        : task.scheduledDate,
    earliestStartAt:
      request.event.type === TaskActionType.Start ? task.earliestStartAt : [TaskActionType.Complete].includes(request.event.type)
        ? task.earliestStartAt
        : null,
    latestFinishAt:
      request.event.type === TaskActionType.Start ? task.latestFinishAt : [TaskActionType.Complete].includes(request.event.type)
        ? task.latestFinishAt
        : null,
    updatedAt: request.event.occurredAt,
    metadata: {
      lastActionType: request.event.type,
      lastActionAt: request.event.occurredAt,
      lastActionNote: request.event.note ?? null,
      lastTransitionReason: transition.reason,
    },
  });
  const updatedBlock = block
    ? cloneBlock(block, {
        state: blockStateForTaskStatus(transition.toStatus, request.event.type),
        updatedAt: request.event.occurredAt,
        metadata: {
          executionAction: request.event.type,
          executionStatus: transition.toStatus,
        },
      })
    : null;

  return { task, transition, updatedTask, updatedBlock };
}

function applyRecoveryMutation(request: ExecutionRequest, currentTask: ReturnType<typeof applyBaseTaskMutation>) {
  const actionableEvent = [TaskActionType.Miss, TaskActionType.Skip, TaskActionType.Defer].includes(
    request.event.type,
  );

  if (!actionableEvent) {
    return {
      task: currentTask.updatedTask,
      createdTasks: [],
      appliedStrategy: null,
      rationale: currentTask.transition.explanation,
    };
  }

  if (request.event.type === TaskActionType.Defer) {
    return {
      task: cloneTask(currentTask.updatedTask, {
        status: statusForRecovery("defer"),
        schedulingState: lowerSchedulingState(currentTask.updatedTask),
        updatedAt: request.event.occurredAt,
        metadata: {
          recoveryStrategy: "defer",
          recoveryRationale:
            "The task was preserved for later review instead of being silently pushed forward.",
          recoveryCandidateIds: "",
        },
      }),
      block: currentTask.updatedBlock
        ? cloneBlock(currentTask.updatedBlock, {
            state: blockStateForTaskStatus(statusForRecovery("defer"), request.event.type),
            metadata: {
              recoveryStrategy: "defer",
            },
          })
        : null,
      createdTasks: [],
      appliedStrategy: "defer" as const,
      rationale:
        "The task was preserved for later review instead of being silently pushed forward.",
      transitionReason: currentTask.transition.reason,
    };
  }

  const decision = evaluateRollover(currentTask.task, request.event.occurredAt);
  const candidates = recoveryCandidatesForStrategy(
    currentTask.task,
    decision.strategy,
    request.event.occurredAt,
  );
  const taskStatus =
    decision.strategy === "split" || decision.strategy === "substitute"
      ? statusForRecovery(decision.strategy)
      : statusForRecovery(decision.strategy);

  const recoveredTask = cloneTask(currentTask.updatedTask, {
    status: taskStatus,
    schedulingState: lowerSchedulingState(currentTask.updatedTask),
    updatedAt: request.event.occurredAt,
    metadata: {
      recoveryStrategy: decision.strategy,
      recoveryRationale: decision.rationale,
      recoveryCandidateIds: candidates.map((candidate) => candidate.task.id).join(","),
    },
  });
  const recoveredBlock = currentTask.updatedBlock
    ? cloneBlock(currentTask.updatedBlock, {
        state: blockStateForTaskStatus(recoveredTask.status, request.event.type),
        metadata: {
          recoveryStrategy: decision.strategy,
        },
      })
    : null;

  const transitionReason =
    decision.strategy === "split"
      ? TaskTransitionReason.RecoverySplit
      : decision.strategy === "substitute"
        ? TaskTransitionReason.RecoverySubstitute
        : currentTask.transition.reason;

  return {
    task: recoveredTask,
    block: recoveredBlock,
    createdTasks: candidates.map((candidate) => candidate.task),
    appliedStrategy: decision.strategy,
    rationale: decision.rationale,
    transitionReason,
  };
}

function computePressure(tasks: ExecutionRequest["tasks"], persistedTaskIds: Set<string>, createdTaskCount: number) {
  const relevantTasks = tasks.filter((task) => persistedTaskIds.has(task.id));
  const unresolvedTaskCount = relevantTasks.filter(
    (task) => ![TaskStatus.Completed, TaskStatus.Cancelled].includes(task.status),
  ).length;
  const missedTaskCount = relevantTasks.filter((task) =>
    [TaskStatus.Missed, TaskStatus.Split, TaskStatus.Substituted, TaskStatus.Deferred].includes(
      task.status,
    ),
  ).length;
  const continuityTaskCount = relevantTasks.filter((task) => Boolean(task.goalId || task.milestoneId)).length;

  return {
    level: classifyPressureLevel(unresolvedTaskCount, missedTaskCount),
    unresolvedTaskCount,
    missedTaskCount,
    recoveryCandidateCount: createdTaskCount,
    continuityTaskCount,
  };
}

export const executionEngine: ExecutionEngine = {
  async execute(request) {
    const base = applyBaseTaskMutation(request);
    const recovery = applyRecoveryMutation(request, base);
    const tasksToSave = request.tasks.map((task) => {
      if (task.id !== base.task.id) {
        return task;
      }

      return recovery.task;
    });
    const allTasksToPersist = [...tasksToSave, ...recovery.createdTasks];
    const blockToPersist =
      recovery.block ?? base.updatedBlock ?? null;
    const blocksToSave = blockToPersist
      ? request.timeBlocks.map((block) => (block.id === blockToPersist.id ? blockToPersist : block))
      : request.timeBlocks;
    const persistedTaskIds = new Set(allTasksToPersist.map((task) => task.id));
    const pressure = computePressure(allTasksToPersist, persistedTaskIds, recovery.createdTasks.length);
    const dailyPlan = updateDailyPlanPressure(request.dailyPlan, pressure, request.event.occurredAt);
    const suggestion =
      [TaskActionType.Miss, TaskActionType.Skip, TaskActionType.Defer].includes(request.event.type)
        ? buildReplanSuggestion({
            date: request.date,
            task: recovery.task,
            action: request.event.type,
            strategy: recovery.appliedStrategy ?? "unscheduled",
            rationale: recovery.rationale,
            occurredAt: request.event.occurredAt,
            candidateTaskIds: recovery.createdTasks.map((task) => task.id),
          })
        : null;

    return {
      generatedAt: request.event.occurredAt,
      payload: {
        mutation: {
          tasksToSave: allTasksToPersist,
          blocksToSave,
          dailyPlan,
        },
        audit: {
          event: request.event,
          transition: {
            taskId: base.task.id,
            fromStatus: base.task.status,
            toStatus: recovery.task.status,
            fromSchedulingState: base.task.schedulingState,
            toSchedulingState: recovery.task.schedulingState,
            reason: recovery.transitionReason ?? base.transition.reason,
            explanation: recovery.rationale,
            occurredAt: request.event.occurredAt,
          },
          appliedStrategy: recovery.appliedStrategy,
          explanation: recovery.rationale,
          metadata: {
            candidateTaskCount: recovery.createdTasks.length,
          },
        },
        createdTaskIds: recovery.createdTasks.map((task) => task.id),
        preservedTaskIds: recovery.createdTasks
          .filter((task) => Boolean(task.goalId || task.milestoneId))
          .map((task) => task.id),
        replanSuggestions: suggestion ? [suggestion] : [],
        pressure,
      },
      warnings:
        recovery.appliedStrategy === "unscheduled"
          ? ["Task dropped out of the current day pending review instead of silent rollover."]
          : [],
    };
  },
};
