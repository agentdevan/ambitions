export interface GoalDecompositionEngine {
  decomposeGoal(goalId: string): Promise<void>;
}

export const goalDecompositionEngine: GoalDecompositionEngine = {
  async decomposeGoal() {
    return;
  },
};
