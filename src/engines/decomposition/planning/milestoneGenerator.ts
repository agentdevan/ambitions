import { EntitySyncState, Goal, GoalMilestone, GoalMilestoneStatus } from "../../../domain/models";
import { GoalPlanningAnalysis } from "../../../domain/models/planningBrain";
import { addDays } from "./date";
import { getStrategyTemplate } from "./strategyTemplates";

function createMilestoneRecord(goal: Goal, id: string, targetDate: string | null): GoalMilestone {
  const timestamp = new Date().toISOString();

  return {
    id,
    ownerUserId: null,
    remoteId: null,
    syncState: EntitySyncState.LocalOnly,
    version: 1,
    lastSyncedAt: null,
    createdAt: timestamp,
    updatedAt: timestamp,
    goalId: goal.id,
    title: "",
    summary: null,
    status: GoalMilestoneStatus.Pending,
    targetDate,
    completedAt: null,
    sortOrder: 0,
    estimatedMinutes: null,
    metadata: {},
  };
}

export function generateMilestones(goal: Goal, analysis: GoalPlanningAnalysis) {
  const milestones: GoalMilestone[] = [];
  let sortOrder = 1;
  const anchorDate = goal.startDate ?? new Date().toISOString().slice(0, 10);

  for (const strategy of analysis.strategies) {
    const template = getStrategyTemplate(strategy.key);
    if (!template) {
      continue;
    }

    const blueprints = template.buildMilestones({
      goal,
      input: {
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
      },
      analysis,
      strategy,
    });

    for (const blueprint of blueprints) {
      const milestone = createMilestoneRecord(
        goal,
        `${goal.id}-milestone-${sortOrder}`,
        addDays(anchorDate, blueprint.targetOffsetDays),
      );

      milestone.title = blueprint.title;
      milestone.summary = blueprint.summary;
      milestone.sortOrder = sortOrder;
      milestone.estimatedMinutes = blueprint.workTypes.length * 30;
      milestone.metadata = {
        planningStrategyKey: strategy.key,
        planningPhaseKey: blueprint.phaseKey,
        planningConfidence: Number(blueprint.confidence.toFixed(2)),
      };

      milestones.push(milestone);
      sortOrder += 1;
    }
  }

  return milestones;
}
