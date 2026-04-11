import { Goal, GoalMilestone, JsonMap, JsonValue, Task } from "../../domain/models";

export type GoalReviewMode = "new_goal" | "targeted_regeneration" | "full_regeneration";
export type GoalDownstreamChoice = "keep" | "targeted_regeneration" | "full_regeneration";
export type GoalLifecycleAction = "pause" | "archive";
export type GoalLifecycleHandling =
  | "remove_from_active_plans"
  | "keep_scheduled"
  | "defer_downstream"
  | "archive_downstream";

export interface GoalReviewMilestoneDraft {
  id: string;
  sourceMilestoneId: string | null;
  continuityKey: string;
  title: string;
  summary: string | null;
  targetDate: string | null;
  estimatedMinutes: number | null;
  sortOrder: number;
  protected: boolean;
  rationale: string | null;
  changeLabel: "recommended" | "preserved" | "updated" | "new";
}

export interface GoalReviewTaskDraft {
  id: string;
  sourceTaskId: string | null;
  continuityKey: string;
  milestoneId: string;
  title: string;
  summary: string | null;
  targetDate: string | null;
  estimatedMinutes: number;
  protected: boolean;
  removed: boolean;
  userAdjusted: boolean;
  rationale: string | null;
  order: number;
  changeLabel: "recommended" | "preserved" | "updated" | "new";
}

export interface GoalReviewDraft {
  mode: GoalReviewMode;
  createdAt: string;
  headline: string;
  summary: string;
  rationale: string[];
  recommendedAction: GoalDownstreamChoice;
  milestones: GoalReviewMilestoneDraft[];
  tasks: GoalReviewTaskDraft[];
  impactSummary: {
    changedFields: string[];
    affectedMilestoneCount: number;
    affectedTaskCount: number;
    protectedTaskCount: number;
    recommendedRegeneration: boolean;
  };
}

export interface GoalRollbackSnapshot {
  id: string;
  createdAt: string;
  expiresAt: string;
  mode: GoalReviewMode;
  summary: string;
  milestones: GoalMilestone[];
  tasks: Task[];
  generatedMilestoneIds: string[];
  generatedTaskIds: string[];
}

export interface GoalEditImpactPreview {
  hasDownstream: boolean;
  changedFields: string[];
  affectedMilestoneCount: number;
  affectedTaskCount: number;
  protectedTaskCount: number;
  summary: string;
  recommendation: GoalDownstreamChoice;
  recommendedRegeneration: boolean;
}

type GoalMetadataValue = JsonValue | undefined;

function isJsonObject(value: GoalMetadataValue): value is Record<string, JsonValue> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function isReviewMilestoneDraft(value: JsonValue) {
  return isJsonObject(value) && typeof value.id === "string" && typeof value.title === "string";
}

function isReviewTaskDraft(value: JsonValue) {
  return isJsonObject(value) && typeof value.id === "string" && typeof value.title === "string";
}

export function cloneMetadata<T extends JsonValue>(value: T): T {
  return JSON.parse(JSON.stringify(value)) as T;
}

export function getGoalReviewDraft(goal: Goal): GoalReviewDraft | null {
  const raw = goal.metadata.phase11ReviewDraft;
  if (!isJsonObject(raw)) {
    return null;
  }

  const milestones = Array.isArray(raw.milestones)
    ? (raw.milestones.filter(isReviewMilestoneDraft) as unknown as GoalReviewMilestoneDraft[])
    : [];
  const tasks = Array.isArray(raw.tasks)
    ? (raw.tasks.filter(isReviewTaskDraft) as unknown as GoalReviewTaskDraft[])
    : [];
  const rationale = Array.isArray(raw.rationale)
    ? raw.rationale.filter((entry): entry is string => typeof entry === "string")
    : [];
  const impactSummary = isJsonObject(raw.impactSummary) ? raw.impactSummary : null;

  if (
    typeof raw.mode !== "string" ||
    typeof raw.createdAt !== "string" ||
    typeof raw.headline !== "string" ||
    typeof raw.summary !== "string" ||
    typeof raw.recommendedAction !== "string" ||
    !impactSummary
  ) {
    return null;
  }

  return {
    mode: raw.mode as GoalReviewMode,
    createdAt: raw.createdAt,
    headline: raw.headline,
    summary: raw.summary,
    rationale,
    recommendedAction: raw.recommendedAction as GoalDownstreamChoice,
    milestones,
    tasks,
    impactSummary: {
      changedFields: Array.isArray(impactSummary.changedFields)
        ? impactSummary.changedFields.filter(
            (entry): entry is string => typeof entry === "string",
          )
        : [],
      affectedMilestoneCount:
        typeof impactSummary.affectedMilestoneCount === "number"
          ? impactSummary.affectedMilestoneCount
          : 0,
      affectedTaskCount:
        typeof impactSummary.affectedTaskCount === "number" ? impactSummary.affectedTaskCount : 0,
      protectedTaskCount:
        typeof impactSummary.protectedTaskCount === "number"
          ? impactSummary.protectedTaskCount
          : 0,
      recommendedRegeneration: impactSummary.recommendedRegeneration === true,
    },
  };
}

export function setGoalReviewDraft(goal: Goal, reviewDraft: GoalReviewDraft | null): Goal {
  const metadata: JsonMap = cloneMetadata(goal.metadata);

  if (reviewDraft) {
    metadata.phase11ReviewDraft = cloneMetadata(reviewDraft as unknown as JsonValue);
  } else {
    delete metadata.phase11ReviewDraft;
  }

  return {
    ...goal,
    metadata,
  };
}

export function getGoalRollbackSnapshot(goal: Goal): GoalRollbackSnapshot | null {
  const raw = goal.metadata.phase11RollbackSnapshot;
  if (!isJsonObject(raw)) {
    return null;
  }

  if (
    typeof raw.id !== "string" ||
    typeof raw.createdAt !== "string" ||
    typeof raw.expiresAt !== "string" ||
    typeof raw.mode !== "string" ||
    typeof raw.summary !== "string" ||
    !Array.isArray(raw.milestones) ||
    !Array.isArray(raw.tasks)
  ) {
    return null;
  }

  return cloneMetadata(raw as unknown as JsonValue) as unknown as GoalRollbackSnapshot;
}

export function setGoalRollbackSnapshot(
  goal: Goal,
  rollbackSnapshot: GoalRollbackSnapshot | null,
): Goal {
  const metadata: JsonMap = cloneMetadata(goal.metadata);

  if (rollbackSnapshot) {
    metadata.phase11RollbackSnapshot = cloneMetadata(rollbackSnapshot as unknown as JsonValue);
  } else {
    delete metadata.phase11RollbackSnapshot;
  }

  return {
    ...goal,
    metadata,
  };
}

export function markTaskAsUserAdjusted(task: Task) {
  return {
    ...task,
    metadata: {
      ...task.metadata,
      phase11UserAdjusted: true,
    },
  };
}

export function markMilestoneAsUserAdjusted(milestone: GoalMilestone) {
  return {
    ...milestone,
    metadata: {
      ...milestone.metadata,
      phase11UserAdjusted: true,
    },
  };
}

export function hasUserAdjustedMetadata(record: { metadata: JsonMap }) {
  return record.metadata.phase11UserAdjusted === true;
}

export function getMilestoneContinuityKey(milestone: GoalMilestone) {
  const raw = milestone.metadata.planningContinuityKey;
  if (typeof raw === "string" && raw.length > 0) {
    return raw;
  }

  const strategyKey = String(milestone.metadata.planningStrategyKey ?? "");
  const phaseKey = String(milestone.metadata.planningPhaseKey ?? "");
  if (strategyKey.length > 0 && phaseKey.length > 0) {
    return `${strategyKey}:${phaseKey}`;
  }

  return milestone.id;
}

export function getTaskContinuityKey(task: Task) {
  const raw = task.metadata.planningContinuityKey;
  if (typeof raw === "string" && raw.length > 0) {
    return raw;
  }

  const fallback = task.metadata.planningContinuityToken;
  return typeof fallback === "string" && fallback.length > 0 ? fallback : task.id;
}
