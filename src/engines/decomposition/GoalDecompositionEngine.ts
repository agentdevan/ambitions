import { EngineResult, GoalDecompositionOutput, GoalDecompositionRequest } from "../types";
import { buildGoalPlan } from "./planning/planner";
import { PlanningMode } from "../../domain/models/planningBrain";
import { getGoalPaceMode } from "../../services/goals/goalIntelligence";

function resolvePlanningMode(request: GoalDecompositionRequest) {
  const paceMode = getGoalPaceMode(request.goal);
  if (paceMode === "aggressive") {
    return PlanningMode.Aggressive;
  }

  if (paceMode === "balanced") {
    return PlanningMode.Balanced;
  }

  return request.adaptationProfile?.strategy.strictness === "balanced"
    ? PlanningMode.Balanced
    : PlanningMode.Protective;
}

export interface GoalDecompositionEngine {
  decompose(request: GoalDecompositionRequest): Promise<EngineResult<GoalDecompositionOutput>>;
}

export const goalDecompositionEngine: GoalDecompositionEngine = {
  async decompose(request) {
    const mode = resolvePlanningMode(request);
    const plan = buildGoalPlan(request.goal, mode, request.adaptationProfile ?? null);

    return {
      generatedAt: new Date().toISOString(),
      payload: {
        analysis: plan.analysis,
        milestones: plan.milestones,
        tasks: plan.tasks,
      },
      warnings: [],
    };
  },
};
