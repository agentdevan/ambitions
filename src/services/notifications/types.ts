import {
  DailyRitualState,
  NotificationPreference,
  Task,
  TimeBlock,
  WeeklyReviewState,
} from "../../domain/models";
import { SchedulingOutput } from "../../engines";
import { ProductPreferences } from "../../product/types";

export type CalmNotificationKind =
  | "task_reminder"
  | "start_small_nudge"
  | "free_window_nudge"
  | "morning_ritual"
  | "evening_close"
  | "recovery_prompt"
  | "weekly_review";

export interface NotificationDraft {
  id: string;
  kind: CalmNotificationKind;
  title: string;
  body: string;
  scheduledAt: string;
  metadata: Record<string, string>;
}

export interface NotificationPlanContext {
  date: string;
  schedule: SchedulingOutput | null;
  timeBlocks: TimeBlock[];
  tasks: Task[];
  preferences: NotificationPreference[];
  productPreferences: ProductPreferences;
  dailyRitual: DailyRitualState | null;
  weeklyReviewState: WeeklyReviewState | null;
  nextWeekReviewState: WeeklyReviewState | null;
}

export interface NotificationSyncResult {
  scheduledIds: string[];
  drafts: NotificationDraft[];
}
