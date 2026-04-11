import { EngineResult, GoalDecompositionOutput, GoalDecompositionRequest } from "../types";
import { buildGoalPlan } from "./planning/planner";

export interface GoalDecompositionEngine {
  decompose(request: GoalDecompositionRequest): Promise<EngineResult<GoalDecompositionOutput>>;
}

export const goalDecompositionEngine: GoalDecompositionEngine = {
  async decompose(request) {
    const plan = buildGoalPlan(request.goal);

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
