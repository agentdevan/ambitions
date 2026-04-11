import { Goal, GoalMilestone, Task } from "../../domain/models";
import { GoalEditImpactPreview, GoalDownstreamChoice } from "./metadata";
import { selectProtectedItems } from "./protectedItemSelector";

const trackedGoalFields: Array<keyof Goal> = [
  "title",
  "summary",
  "domainKey",
  "horizon",
  "type",
  "startDate",
  "targetDate",
  "desiredWeeklyMinutes",
  "estimatedTotalMinutes",
  "successMetric",
  "notes",
];

function changedFields(goal: Goal, patch: Partial<Goal>) {
  return trackedGoalFields.filter((field) => {
    if (!(field in patch)) {
      return false;
    }

    return goal[field] !== patch[field];
  });
}

function recommendHandling(fields: string[], hasDownstream: boolean): GoalDownstreamChoice {
  if (!hasDownstream) {
    return "keep";
  }

  if (fields.some((field) => ["domainKey", "type"].includes(field))) {
    return "full_regeneration";
  }

  if (fields.length === 0) {
    return "keep";
  }

  return "targeted_regeneration";
}

function createSummary(params: {
  changedFields: string[];
  milestoneCount: number;
  taskCount: number;
  recommendation: GoalDownstreamChoice;
}) {
  const { changedFields: fields, milestoneCount, taskCount, recommendation } = params;

  if (fields.length === 0) {
    return "No structural goal changes were detected.";
  }

  if (milestoneCount === 0 && taskCount === 0) {
    return "This edit updates the goal itself and should not disturb downstream work.";
  }

  if (recommendation === "full_regeneration") {
    return `This edit could reshape the full downstream structure. ${milestoneCount} milestone areas and ${taskCount} tasks may need a refreshed recommendation.`;
  }

  return `This edit could refine ${milestoneCount} milestone areas and ${taskCount} tasks. A targeted refresh is the calmer default.`;
}

export function evaluateGoalEditImpact(params: {
  goal: Goal;
  patch: Partial<Goal>;
  milestones: GoalMilestone[];
  tasks: Task[];
}): GoalEditImpactPreview {
  const changed = changedFields(params.goal, params.patch).map(String);
  const hasDownstream = params.milestones.length > 0 || params.tasks.length > 0;
  const protectedItems = selectProtectedItems({
    milestones: params.milestones,
    tasks: params.tasks,
  });
  const recommendation = recommendHandling(changed, hasDownstream);

  return {
    hasDownstream,
    changedFields: changed,
    affectedMilestoneCount: hasDownstream ? params.milestones.length : 0,
    affectedTaskCount: hasDownstream ? params.tasks.length : 0,
    protectedTaskCount: protectedItems.taskIds.size,
    summary: createSummary({
      changedFields: changed,
      milestoneCount: hasDownstream ? params.milestones.length : 0,
      taskCount: hasDownstream ? params.tasks.length : 0,
      recommendation,
    }),
    recommendation,
    recommendedRegeneration: recommendation !== "keep",
  };
}
