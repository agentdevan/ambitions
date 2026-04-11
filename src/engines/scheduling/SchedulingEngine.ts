import { EngineResult, SchedulingOutput, SchedulingRequest } from "../types";
import { buildDailySchedule } from "./planner";

export interface SchedulingEngine {
  buildSchedule(request: SchedulingRequest): Promise<EngineResult<SchedulingOutput>>;
}

export const schedulingEngine: SchedulingEngine = {
  async buildSchedule(request) {
    return {
      generatedAt: new Date().toISOString(),
      payload: buildDailySchedule(request),
      warnings: [],
    };
  },
};
