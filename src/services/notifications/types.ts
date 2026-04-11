import { NotificationPreference, Task, TimeBlock } from "../../domain/models";
import { SchedulingOutput } from "../../engines";

export type CalmNotificationKind =
  | "task_reminder"
  | "start_small_nudge"
  | "free_window_nudge";

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
}

export interface NotificationSyncResult {
  scheduledIds: string[];
  drafts: NotificationDraft[];
}
