import { DailyPlan, DailyRitualState, TimeBlock, WeeklyReviewState } from "../domain/models";

export interface PlanRepository {
  getDailyPlan(date: string): Promise<DailyPlan | null>;
  getDailyRitualState(date: string): Promise<DailyRitualState | null>;
  getWeeklyReviewState(weekStartDate: string): Promise<WeeklyReviewState | null>;
  listDailyPlans(): Promise<DailyPlan[]>;
  listDailyRitualStates(): Promise<DailyRitualState[]>;
  listWeeklyReviewStates(): Promise<WeeklyReviewState[]>;
  listTimeBlocks(): Promise<TimeBlock[]>;
  listTimeBlocksForPlan(dailyPlanId: string): Promise<TimeBlock[]>;
  saveDailyPlans(plans: DailyPlan[]): Promise<void>;
  saveDailyRitualStates(states: DailyRitualState[]): Promise<void>;
  saveWeeklyReviewStates(states: WeeklyReviewState[]): Promise<void>;
  saveTimeBlocks(blocks: TimeBlock[]): Promise<void>;
}
