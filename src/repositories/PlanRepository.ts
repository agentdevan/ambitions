import { DailyPlan, DailyRitualState, TimeBlock } from "../domain/models";

export interface PlanRepository {
  getDailyPlan(date: string): Promise<DailyPlan | null>;
  getDailyRitualState(date: string): Promise<DailyRitualState | null>;
  listDailyPlans(): Promise<DailyPlan[]>;
  listDailyRitualStates(): Promise<DailyRitualState[]>;
  listTimeBlocks(): Promise<TimeBlock[]>;
  listTimeBlocksForPlan(dailyPlanId: string): Promise<TimeBlock[]>;
  saveDailyPlans(plans: DailyPlan[]): Promise<void>;
  saveDailyRitualStates(states: DailyRitualState[]): Promise<void>;
  saveTimeBlocks(blocks: TimeBlock[]): Promise<void>;
}
