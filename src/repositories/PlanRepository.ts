import {
  DailyPlan,
  DailyRitualState,
  MonthlyReviewState,
  TimeBlock,
  WeeklyReviewState,
} from "../domain/models";

export interface PlanRepository {
  getDailyPlan(date: string): Promise<DailyPlan | null>;
  getDailyRitualState(date: string): Promise<DailyRitualState | null>;
  getWeeklyReviewState(weekStartDate: string): Promise<WeeklyReviewState | null>;
  getMonthlyReviewState(monthStartDate: string): Promise<MonthlyReviewState | null>;
  listDailyPlans(): Promise<DailyPlan[]>;
  listDailyRitualStates(): Promise<DailyRitualState[]>;
  listWeeklyReviewStates(): Promise<WeeklyReviewState[]>;
  listMonthlyReviewStates(): Promise<MonthlyReviewState[]>;
  listTimeBlocks(): Promise<TimeBlock[]>;
  listTimeBlocksForPlan(dailyPlanId: string): Promise<TimeBlock[]>;
  saveDailyPlans(plans: DailyPlan[]): Promise<void>;
  saveDailyRitualStates(states: DailyRitualState[]): Promise<void>;
  saveWeeklyReviewStates(states: WeeklyReviewState[]): Promise<void>;
  saveMonthlyReviewStates(states: MonthlyReviewState[]): Promise<void>;
  saveTimeBlocks(blocks: TimeBlock[]): Promise<void>;
}
