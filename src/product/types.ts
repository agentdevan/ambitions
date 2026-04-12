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
  appearanceMode: AppearanceMode;
  accentTheme: AccentThemeKey;
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
