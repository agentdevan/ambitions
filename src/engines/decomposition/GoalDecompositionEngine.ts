import { EngineResult, GoalDecompositionOutput, GoalDecompositionRequest } from "../types";

export interface GoalDecompositionEngine {
  decompose(request: GoalDecompositionRequest): Promise<EngineResult<GoalDecompositionOutput>>;
}

export const goalDecompositionEngine: GoalDecompositionEngine = {
  async decompose(request) {
    return {
      generatedAt: new Date().toISOString(),
      payload: {
        milestones: request.milestones,
        tasks: request.existingTasks,
      },
      warnings: ["Goal decomposition logic is intentionally deferred to Phase 3."],
    };
  },
};
