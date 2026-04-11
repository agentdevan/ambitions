import { CapacityLoad, EntitySyncState, ReplanningStyle, StrategyStrictness } from "../../domain/models";
import { AdaptationOutput, AdaptationRequest, EngineResult } from "../types";

export interface AdaptationEngine {
  updateProfile(request: AdaptationRequest): Promise<EngineResult<AdaptationOutput>>;
}

export const adaptationEngine: AdaptationEngine = {
  async updateProfile(request) {
    return {
      generatedAt: new Date().toISOString(),
      payload: {
        profile: request.priorProfile ?? {
          id: "adaptation-placeholder",
          ownerUserId: null,
          remoteId: null,
          syncState: EntitySyncState.LocalOnly,
          version: 1,
          lastSyncedAt: null,
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString(),
          effectiveDate: request.date,
          source: "observed",
          capacity: {
            mentalLoad: CapacityLoad.Balanced,
            focusBudgetMinutes: 0,
            meetingLoadMinutes: 0,
            recoveryBudgetMinutes: 0,
          },
          completion: {
            consistencyScore: 0,
            rolloverRate: 0,
            averageTaskCompletionMinutes: null,
          },
          friction: {
            switchingPenaltyMinutes: 0,
            preferredStartWindow: "09:00",
            commonBlockers: [],
          },
          momentum: {
            currentStreakDays: 0,
            recentWinPattern: "",
            confidenceScore: 0,
          },
          strategy: {
            strictness: StrategyStrictness.Balanced,
            replanningStyle: ReplanningStyle.Guided,
          },
          metadata: {},
        },
      },
      warnings: ["Adaptation logic remains intentionally shallow in Phase 2."],
    };
  },
};
