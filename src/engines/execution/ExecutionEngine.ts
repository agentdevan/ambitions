export interface ExecutionEngine {
  generateDailyPlan(date: string): Promise<void>;
}

export const executionEngine: ExecutionEngine = {
  async generateDailyPlan() {
    return;
  },
};
