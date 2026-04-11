import { EngineResult, ReplanningOutput, ReplanningRequest } from "../types";

export interface ReplanningEngine {
  suggestAdjustments(request: ReplanningRequest): Promise<EngineResult<ReplanningOutput>>;
}

export const replanningEngine: ReplanningEngine = {
  async suggestAdjustments() {
    return {
      generatedAt: new Date().toISOString(),
      payload: {
        suggestions: [],
      },
      warnings: ["Replanning logic is a Phase 3 concern; the contract is stable now."],
    };
  },
};
