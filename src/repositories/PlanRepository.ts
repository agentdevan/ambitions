import { DailyPlan, TimeBlock } from "../domain/models";

export interface PlanRepository {
  getDailyPlan(date: string): Promise<DailyPlan | null>;
  listDailyPlans(): Promise<DailyPlan[]>;
  listTimeBlocks(): Promise<TimeBlock[]>;
  listTimeBlocksForPlan(dailyPlanId: string): Promise<TimeBlock[]>;
  saveDailyPlans(plans: DailyPlan[]): Promise<void>;
  saveTimeBlocks(blocks: TimeBlock[]): Promise<void>;
}
