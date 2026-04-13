import { DomainKey, PlanningCadence, UserPreferences } from "../domain/models";
import {
  AccentThemeKey,
  AppearanceMode,
  DefaultWeeklyCarryoverBehavior,
  DefaultUnfinishedWorkBehavior,
  DayIntensityPreference,
  ProductPreferences,
  ScheduleDefaults,
  TaskSizingPreference,
} from "./types";

const defaultSchedule: ScheduleDefaults = {
  sleepStart: "23:00",
  sleepEnd: "07:00",
  morningPrepMinutes: 30,
  workdayStart: "09:00",
  workdayEnd: "17:00",
  workdays: [1, 2, 3, 4, 5],
  commuteMinutes: 20,
};

function parseTime(value: unknown, fallback: string) {
  return typeof value === "string" && /^\d{2}:\d{2}$/.test(value) ? value : fallback;
}

function parseNumber(value: unknown, fallback: number) {
  if (typeof value === "number" && Number.isFinite(value)) {
    return value;
  }

  if (typeof value === "string" && value.trim().length > 0) {
    const parsed = Number(value);
    if (Number.isFinite(parsed)) {
      return parsed;
    }
  }

  return fallback;
}

function parseDomainList(value: unknown) {
  if (typeof value !== "string" || value.trim().length === 0) {
    return [DomainKey.Personal, DomainKey.Career];
  }

  const domains = value
    .split(",")
    .map((entry) => entry.trim())
    .filter((entry): entry is DomainKey =>
      Object.values(DomainKey).includes(entry as DomainKey),
    );

  return domains.length > 0 ? domains : [DomainKey.Personal, DomainKey.Career];
}

function parseWorkdays(value: unknown) {
  if (typeof value !== "string" || value.trim().length === 0) {
    return defaultSchedule.workdays;
  }

  const workdays = value
    .split(",")
    .map((entry) => Number(entry.trim()))
    .filter((entry) => Number.isInteger(entry) && entry >= 0 && entry <= 6);

  return workdays.length > 0 ? workdays : defaultSchedule.workdays;
}

function parseTaskSizing(value: unknown): TaskSizingPreference {
  return value === "smaller" || value === "mixed" || value === "bigger"
    ? value
    : "mixed";
}

function parseDayIntensity(value: unknown): DayIntensityPreference {
  return value === "light" || value === "balanced" || value === "ambitious"
    ? value
    : "balanced";
}

function parseAppearanceMode(value: unknown): AppearanceMode {
  return value === "light" || value === "dark" || value === "system" ? value : "system";
}

function parseBoolean(value: unknown, fallback: boolean) {
  if (typeof value === "boolean") {
    return value;
  }

  if (typeof value === "string") {
    if (value === "true") {
      return true;
    }

    if (value === "false") {
      return false;
    }
  }

  return fallback;
}

function parseAccentTheme(value: unknown): AccentThemeKey {
  switch (value) {
    case "gold":
    case "sage":
    case "slateBlue":
    case "bronze":
    case "olive":
    case "terracotta":
      return value;
    case "neutral":
      return "gold";
    case "slate":
      return "slateBlue";
    case "dusk":
      return "bronze";
    default:
      return "gold";
  }
}

function parseUnfinishedWorkBehavior(value: unknown): DefaultUnfinishedWorkBehavior {
  return value === "carry_forward" || value === "send_to_review" || value === "ask_each_time"
    ? value
    : "ask_each_time";
}

function parseWeeklyCarryoverBehavior(value: unknown): DefaultWeeklyCarryoverBehavior {
  return value === "essentials_only" || value === "review_first" || value === "aggressive"
    ? value
    : "review_first";
}

export function getProductPreferences(preferences: UserPreferences | null): ProductPreferences {
  const metadata = preferences?.metadata ?? {};

  return {
    onboardingCompleted: metadata.onboardingCompleted === true || metadata.onboardingCompleted === "true",
    focusDomains: parseDomainList(metadata.focusDomains),
    taskSizing: parseTaskSizing(metadata.taskSizing),
    dayIntensity: parseDayIntensity(metadata.dayIntensity),
    adaptivePlanningEnabled: parseBoolean(metadata.adaptivePlanningEnabled, true),
    appearanceMode: parseAppearanceMode(metadata.appearanceMode),
    accentTheme: parseAccentTheme(metadata.accentTheme ?? metadata.themePreset),
    defaultUnfinishedWorkBehavior: parseUnfinishedWorkBehavior(
      metadata.defaultUnfinishedWorkBehavior,
    ),
    weeklyReviewDay: parseNumber(metadata.weeklyReviewDay, preferences?.weeklyPlanningDay ?? 0),
    weeklyReviewTime: parseTime(metadata.weeklyReviewTime, "16:30"),
    autoPromptNextWeekShaping: parseBoolean(metadata.autoPromptNextWeekShaping, true),
    defaultWeeklyCarryoverBehavior: parseWeeklyCarryoverBehavior(
      metadata.defaultWeeklyCarryoverBehavior,
    ),
    schedule: {
      sleepStart: parseTime(metadata.sleepWindowStart, defaultSchedule.sleepStart),
      sleepEnd: parseTime(metadata.sleepWindowEnd, defaultSchedule.sleepEnd),
      morningPrepMinutes: parseNumber(
        metadata.morningPrepMinutes,
        defaultSchedule.morningPrepMinutes,
      ),
      workdayStart: parseTime(metadata.workdayStart, defaultSchedule.workdayStart),
      workdayEnd: parseTime(metadata.workdayEnd, defaultSchedule.workdayEnd),
      workdays: parseWorkdays(metadata.workdays),
      commuteMinutes: parseNumber(metadata.commuteMinutes, defaultSchedule.commuteMinutes),
    },
  };
}

function cadenceForIntensity(intensity: DayIntensityPreference) {
  if (intensity === "light") {
    return PlanningCadence.Minimal;
  }

  if (intensity === "ambitious") {
    return PlanningCadence.Intentional;
  }

  return PlanningCadence.Standard;
}

function focusSessionMinutes(taskSizing: TaskSizingPreference) {
  if (taskSizing === "smaller") {
    return 20;
  }

  if (taskSizing === "bigger") {
    return 45;
  }

  return 30;
}

function breakMinutes(taskSizing: TaskSizingPreference) {
  if (taskSizing === "smaller") {
    return 5;
  }

  if (taskSizing === "bigger") {
    return 10;
  }

  return 8;
}

export function mergeProductPreferences(
  current: UserPreferences,
  product: ProductPreferences,
): UserPreferences {
  const metadata = {
    ...current.metadata,
    onboardingCompleted: product.onboardingCompleted,
    focusDomains: product.focusDomains.join(","),
    taskSizing: product.taskSizing,
    dayIntensity: product.dayIntensity,
    adaptivePlanningEnabled: product.adaptivePlanningEnabled,
    appearanceMode: product.appearanceMode,
    accentTheme: product.accentTheme,
    defaultUnfinishedWorkBehavior: product.defaultUnfinishedWorkBehavior,
    weeklyReviewDay: product.weeklyReviewDay,
    weeklyReviewTime: product.weeklyReviewTime,
    autoPromptNextWeekShaping: product.autoPromptNextWeekShaping,
    defaultWeeklyCarryoverBehavior: product.defaultWeeklyCarryoverBehavior,
    sleepWindowStart: product.schedule.sleepStart,
    sleepWindowEnd: product.schedule.sleepEnd,
    morningPrepMinutes: product.schedule.morningPrepMinutes,
    workdayStart: product.schedule.workdayStart,
    workdayEnd: product.schedule.workdayEnd,
    workdays: product.schedule.workdays.join(","),
    commuteMinutes: product.schedule.commuteMinutes,
    lunchWindowStart: current.metadata.lunchWindowStart ?? "12:15",
    lunchWindowEnd: current.metadata.lunchWindowEnd ?? "13:00",
  };

  const workStartHour = Number(product.schedule.workdayStart.slice(0, 2));
  const preferredDeepWorkWindows =
    workStartHour >= 9
      ? ["07:30-08:30", "18:15-19:00"]
      : ["08:00-09:30", "14:00-15:00"];

  return {
    ...current,
    planningCadence: cadenceForIntensity(product.dayIntensity),
    weeklyPlanningDay: product.weeklyReviewDay,
    defaultFocusSessionMinutes: focusSessionMinutes(product.taskSizing),
    defaultBreakMinutes: breakMinutes(product.taskSizing),
    preferredDeepWorkWindows,
    metadata,
    updatedAt: new Date().toISOString(),
    version: current.version + 1,
  };
}
