import { EngineResult, TimeCapacityOutput, TimeCapacityRequest } from "../types";
import { buildCapacityOutput, deriveUsableWindows } from "../scheduling/capacityCalculator";
import { interpretConstraints } from "../scheduling/constraintInterpreter";
import { StrategyStrictness } from "../../domain/models";

export interface TimeCapacityEngine {
  calculate(request: TimeCapacityRequest): Promise<EngineResult<TimeCapacityOutput>>;
}

export const timeCapacityEngine: TimeCapacityEngine = {
  async calculate(request) {
    const strictness = request.adaptationProfile?.strategy.strictness ?? StrategyStrictness.Protective;
    const interpretedConstraints = interpretConstraints(request);
    const usableWindows = deriveUsableWindows(interpretedConstraints, strictness);

    return {
      generatedAt: new Date().toISOString(),
      payload: buildCapacityOutput({
        interpretedConstraints,
        usableWindows,
        preferences: request.preferences,
        strictness,
      }),
      warnings: [],
    };
  },
};
