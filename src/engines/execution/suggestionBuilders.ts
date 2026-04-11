import {
  EntitySyncState,
  ReplanSuggestion,
  ReplanSuggestionType,
  RecoveryStrategy,
  Task,
  TaskActionType,
} from "../../domain/models";
import { createTimestampedId } from "./helpers";

function suggestionTypeForStrategy(strategy: RecoveryStrategy, action: TaskActionType) {
  if (strategy === "split") return ReplanSuggestionType.RetrySmaller;
  if (strategy === "substitute") return ReplanSuggestionType.SubstituteLowerFriction;
  if (strategy === "defer") return ReplanSuggestionType.PreserveAndDefer;
  if (action === TaskActionType.Defer) return ReplanSuggestionType.PreserveAndDefer;
  return ReplanSuggestionType.DropFromCurrentDay;
}

function suggestionTitleForStrategy(strategy: RecoveryStrategy) {
  switch (strategy) {
    case "split":
      return "Retry smaller";
    case "substitute":
      return "Use a lower-friction substitute";
    case "defer":
      return "Preserve and defer";
    default:
      return "Drop from the current day";
  }
}

export function buildReplanSuggestion(params: {
  date: string;
  task: Task;
  action: TaskActionType;
  strategy: RecoveryStrategy;
  rationale: string;
  occurredAt: string;
  candidateTaskIds: string[];
}): ReplanSuggestion {
  return {
    id: createTimestampedId("suggestion", params.task.id, params.occurredAt),
    ownerUserId: null,
    remoteId: null,
    syncState: EntitySyncState.LocalOnly,
    version: 1,
    lastSyncedAt: null,
    createdAt: params.occurredAt,
    updatedAt: params.occurredAt,
    planDate: params.date,
    type: suggestionTypeForStrategy(params.strategy, params.action),
    title: suggestionTitleForStrategy(params.strategy),
    rationale: params.rationale,
    taskId: params.task.id,
    timeBlockId: null,
    confidence: params.strategy === "unscheduled" ? 0.66 : params.strategy === "defer" ? 0.72 : 0.81,
    suggestedStartAt: null,
    suggestedEndAt: null,
    metadata: {
      recoveryStrategy: params.strategy,
      candidateTaskIds: params.candidateTaskIds.join(","),
      sourceTaskTitle: params.task.title,
    },
  };
}
