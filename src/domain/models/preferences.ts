import { EntityRecord, JsonMap } from "./shared";

export enum PlanningCadence {
  Minimal = "minimal",
  Standard = "standard",
  Intentional = "intentional",
}

export enum ReminderType {
  TimeBlockStart = "time_block_start",
  PlanReview = "plan_review",
  ReplanPrompt = "replan_prompt",
  MomentumNudge = "momentum_nudge",
  MorningStart = "morning_start",
  EveningClose = "evening_close",
  RecoveryPrompt = "recovery_prompt",
}

export enum NotificationChannel {
  Push = "push",
  InApp = "in_app",
}

export interface UserPreferences extends EntityRecord {
  timezone: string;
  weekStartsOn: number;
  defaultFocusSessionMinutes: number;
  defaultBreakMinutes: number;
  planningCadence: PlanningCadence;
  dailyPlanningTime: string | null;
  weeklyPlanningDay: number;
  monthlyPlanningDay: number;
  allowWeekendPlanning: boolean;
  preferredDeepWorkWindows: string[];
  metadata: JsonMap;
}

export interface NotificationPreference extends EntityRecord {
  channel: NotificationChannel;
  reminderType: ReminderType;
  enabled: boolean;
  leadTimeMinutes: number;
  quietHoursStart: string | null;
  quietHoursEnd: string | null;
  metadata: JsonMap;
}
