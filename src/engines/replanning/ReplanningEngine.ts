import {
  EntitySyncState,
  ReplanSuggestion,
  ReplanSuggestionType,
  TaskStatus,
} from "../../domain/models";
import { EngineResult, ReplanningOutput, ReplanningRequest } from "../types";

export interface ReplanningEngine {
  suggestAdjustments(request: ReplanningRequest): Promise<EngineResult<ReplanningOutput>>;
}

function suggestionForTask(request: ReplanningRequest, task: ReplanningRequest["tasks"][number]): ReplanSuggestion | null {
  const occurredAt = new Date().toISOString();
  const recoveryStrategy = String(task.metadata.recoveryStrategy ?? "");
  const candidateTaskIds = String(task.metadata.recoveryCandidateIds ?? "");

  if (task.status === TaskStatus.Split) {
    return {
      id: `replan-${task.id}-retry-smaller`,
      ownerUserId: null,
      remoteId: null,
      syncState: EntitySyncState.LocalOnly,
      version: 1,
      lastSyncedAt: null,
      createdAt: occurredAt,
      updatedAt: occurredAt,
      planDate: request.date,
      type: ReplanSuggestionType.RetrySmaller,
      title: "Retry smaller",
      rationale: "The last version carried too much startup friction. Use the smaller recovery steps instead of retrying the full task unchanged.",
      taskId: task.id,
      timeBlockId: null,
      confidence: 0.82,
      suggestedStartAt: null,
      suggestedEndAt: null,
      metadata: {
        recoveryStrategy,
        candidateTaskIds,
      },
    };
  }

  if (task.status === TaskStatus.Substituted) {
    return {
      id: `replan-${task.id}-substitute`,
      ownerUserId: null,
      remoteId: null,
      syncState: EntitySyncState.LocalOnly,
      version: 1,
      lastSyncedAt: null,
      createdAt: occurredAt,
      updatedAt: occurredAt,
      planDate: request.date,
      type: ReplanSuggestionType.SubstituteLowerFriction,
      title: "Use a lower-friction substitute",
      rationale: "The original task should not be repeated as-is. A smaller substitute preserves continuity with less drag.",
      taskId: task.id,
      timeBlockId: null,
      confidence: 0.79,
      suggestedStartAt: null,
      suggestedEndAt: null,
      metadata: {
        recoveryStrategy,
        candidateTaskIds,
      },
    };
  }

  if (task.status === TaskStatus.Deferred) {
    return {
      id: `replan-${task.id}-defer`,
      ownerUserId: null,
      remoteId: null,
      syncState: EntitySyncState.LocalOnly,
      version: 1,
      lastSyncedAt: null,
      createdAt: occurredAt,
      updatedAt: occurredAt,
      planDate: request.date,
      type: ReplanSuggestionType.PreserveAndDefer,
      title: "Preserve and defer",
      rationale: "The task still matters, but it should return only after a deliberate reschedule or lower-pressure day.",
      taskId: task.id,
      timeBlockId: null,
      confidence: 0.74,
      suggestedStartAt: null,
      suggestedEndAt: null,
      metadata: {
        recoveryStrategy: "defer",
      },
    };
  }

  if (task.status === TaskStatus.Missed || task.status === TaskStatus.Skipped) {
    return {
      id: `replan-${task.id}-drop`,
      ownerUserId: null,
      remoteId: null,
      syncState: EntitySyncState.LocalOnly,
      version: 1,
      lastSyncedAt: null,
      createdAt: occurredAt,
      updatedAt: occurredAt,
      planDate: request.date,
      type: ReplanSuggestionType.DropFromCurrentDay,
      title: "Drop from the current day",
      rationale: "Do not carry this forward unchanged. Leave it unscheduled until the next step is clarified.",
      taskId: task.id,
      timeBlockId: null,
      confidence: 0.68,
      suggestedStartAt: null,
      suggestedEndAt: null,
      metadata: {
        recoveryStrategy: recoveryStrategy || "unscheduled",
      },
    };
  }

  return null;
}

export const replanningEngine: ReplanningEngine = {
  async suggestAdjustments(request) {
    const suggestions = request.tasks
      .map((task) => suggestionForTask(request, task))
      .filter((suggestion): suggestion is ReplanSuggestion => suggestion !== null);

    return {
      generatedAt: new Date().toISOString(),
      payload: {
        suggestions,
      },
      warnings: [],
    };
  },
};
