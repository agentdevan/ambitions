import { DomainKey } from "../domain/models";

export type TaskSizingPreference = "smaller" | "mixed" | "bigger";
export type DayIntensityPreference = "light" | "balanced" | "ambitious";
export type AppearanceMode = "light" | "dark" | "system";
export type AccentThemeKey =
  | "gold"
  | "sage"
  | "slateBlue"
  | "bronze"
  | "olive"
  | "terracotta";
export type DefaultUnfinishedWorkBehavior =
  | "carry_forward"
  | "send_to_review"
  | "ask_each_time";
export type WeeklyIntensityPreference = "lighter" | "balanced" | "fuller";
export type WeeklyEmphasisPreference =
  | "protect_essentials"
  | "steady_progress"
  | "push_meaningful_area";
export type DefaultWeeklyCarryoverBehavior =
  | "essentials_only"
  | "review_first"
  | "aggressive";

export interface ScheduleDefaults {
  sleepStart: string;
  sleepEnd: string;
  morningPrepMinutes: number;
  workdayStart: string;
  workdayEnd: string;
  workdays: number[];
  commuteMinutes: number;
}

export interface ProductPreferences {
  onboardingCompleted: boolean;
  focusDomains: DomainKey[];
  taskSizing: TaskSizingPreference;
  dayIntensity: DayIntensityPreference;
  adaptivePlanningEnabled: boolean;
  appearanceMode: AppearanceMode;
  accentTheme: AccentThemeKey;
  defaultUnfinishedWorkBehavior: DefaultUnfinishedWorkBehavior;
  weeklyReviewDay: number;
  weeklyReviewTime: string;
  autoPromptNextWeekShaping: boolean;
  defaultWeeklyCarryoverBehavior: DefaultWeeklyCarryoverBehavior;
  schedule: ScheduleDefaults;
}

export interface GoalDraftInference {
  title: string;
  naturalLanguage: string;
  summary: string | null;
  domainKey: DomainKey;
  targetDate: string | null;
  horizon: "daily" | "weekly" | "monthly" | "yearly";
  type: "outcome" | "system" | "project" | "habit";
  desiredWeeklyMinutes: number | null;
  estimatedTotalMinutes: number | null;
  successMetric: string | null;
  notes: string | null;
  focusDomains: DomainKey[];
}
