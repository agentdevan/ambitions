import { Goal } from "../../../domain/models";
import { GoalDraftInput } from "../../../domain/models/planningBrain";

export function toGoalDraftInput(goal: Goal): GoalDraftInput {
  return {
    title: goal.title,
    summary: goal.summary,
    successMetric: goal.successMetric,
    notes: goal.notes,
    horizon: goal.horizon,
    type: goal.type,
    targetDate: goal.targetDate,
    startDate: goal.startDate,
    desiredWeeklyMinutes: goal.desiredWeeklyMinutes,
    estimatedTotalMinutes: goal.estimatedTotalMinutes,
    domainKey: goal.domainKey,
    tags: goal.tags,
  };
}
