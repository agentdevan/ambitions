import { EngineResult, ExecutionOutput, ExecutionRequest } from "../types";

export interface ExecutionEngine {
  analyzeExecution(request: ExecutionRequest): Promise<EngineResult<ExecutionOutput>>;
}

export const executionEngine: ExecutionEngine = {
  async analyzeExecution(request) {
    return {
      generatedAt: new Date().toISOString(),
      payload: {
        activeTaskIds: request.tasks.filter((task) => task.status === "in_progress").map((task) => task.id),
        rolloverCandidates: request.tasks
          .filter((task) => task.schedulingState === "rolled")
          .map((task) => task.id),
      },
      warnings: ["Execution analysis is a contract scaffold only."],
    };
  },
};
