import { EngineResult, GoalDecompositionOutput, GoalDecompositionRequest } from "../types";
import { buildGoalPlan } from "./planning/planner";
import { PlanningMode } from "../../domain/models/planningBrain";

export interface GoalDecompositionEngine {
  decompose(request: GoalDecompositionRequest): Promise<EngineResult<GoalDecompositionOutput>>;
}

export const goalDecompositionEngine: GoalDecompositionEngine = {
  async decompose(request) {
    const mode =
      request.adaptationProfile?.strategy.strictness === "balanced"
        ? PlanningMode.Balanced
        : PlanningMode.Protective;
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
