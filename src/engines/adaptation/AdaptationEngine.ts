import { AdaptationOutput, AdaptationRequest, EngineResult } from "../types";
import { buildDurationRefinementRules } from "./durationRefinement";
import { interpretExecutionHistory } from "./historyInterpreter";
import {
  buildPersonalizationProfile,
  personalizeStrictnessDecision,
} from "./personalizationProfile";
import { updateAdaptationProfile } from "./profileUpdaters";
import { detectRegression } from "./regressionDetector";
import { determineStrictness } from "./strictnessPolicy";

export interface AdaptationEngine {
  updateProfile(request: AdaptationRequest): Promise<EngineResult<AdaptationOutput>>;
}

export const adaptationEngine: AdaptationEngine = {
  async updateProfile(request) {
    const history = interpretExecutionHistory(request.tasks);
    const regression = detectRegression(history.summary);
    const personalization = buildPersonalizationProfile(history);
    const strictness = personalizeStrictnessDecision({
      decision: determineStrictness(history.summary, regression),
      personalization,
    });
    const durationRefinements = buildDurationRefinementRules(request.tasks);
    const profile = updateAdaptationProfile({
      date: request.date,
      preferences: request.preferences,
      priorProfile: request.priorProfile,
      history: history.summary,
      personalization,
      streakDays: history.streakDays,
      regression,
      strictness,
      durationRefinements,
    });

    return {
      generatedAt: new Date().toISOString(),
      payload: {
        profile,
      },
      warnings:
        history.summary.sampleSize < 4
          ? [
              "Adaptation is active, but the current profile is still operating on a very small execution sample.",
            ]
          : [],
    };
  },
};
