import { DailyPlanStatus, EntitySyncState } from "../../domain/models";
import { EngineResult, SchedulingOutput, SchedulingRequest } from "../types";

export interface SchedulingEngine {
  buildSchedule(request: SchedulingRequest): Promise<EngineResult<SchedulingOutput>>;
}

export const schedulingEngine: SchedulingEngine = {
  async buildSchedule(request) {
    return {
      generatedAt: new Date().toISOString(),
      payload: {
        dailyPlan:
          request.existingPlan ??
          ({
            id: "daily-plan-placeholder",
            ownerUserId: null,
            remoteId: null,
            syncState: EntitySyncState.LocalOnly,
            version: 1,
            lastSyncedAt: null,
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString(),
            date: request.date,
            status: DailyPlanStatus.Draft,
            focus: "",
            planningNotes: null,
            totalPlannedMinutes: 0,
            totalCommittedMinutes: 0,
            adaptationProfileId: request.adaptationProfile?.id ?? null,
            metadata: {},
          } as SchedulingOutput["dailyPlan"]),
        timeBlocks: [],
      },
      warnings: ["Scheduling logic is deferred; only the interface is stabilized here."],
    };
  },
};
