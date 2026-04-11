import { EngineResult, TimeCapacityOutput, TimeCapacityRequest } from "../types";

export interface TimeCapacityEngine {
  calculate(request: TimeCapacityRequest): Promise<EngineResult<TimeCapacityOutput>>;
}

export const timeCapacityEngine: TimeCapacityEngine = {
  async calculate(request) {
    return {
      generatedAt: new Date().toISOString(),
      payload: {
        focusMinutes: request.adaptationProfile?.capacity.focusBudgetMinutes ?? 0,
        adminMinutes: Math.max(
          0,
          (request.preferences.defaultFocusSessionMinutes * 2) -
            (request.adaptationProfile?.capacity.meetingLoadMinutes ?? 0),
        ),
        recoveryMinutes: request.adaptationProfile?.capacity.recoveryBudgetMinutes ?? 0,
        usableWindows: [],
      },
      warnings: ["Time capacity heuristics are placeholders until Phase 3 engine work."],
    };
  },
};
