import {
  AdaptationProfile,
  ActivityEvent,
  DailyPlan,
  DailyRitualState,
  EntityRecord,
  EntitySyncState,
  Goal,
  GoalMilestone,
  MonthlyReviewState,
  NotificationPreference,
  SyncEntityKind,
  Task,
  TimeBlock,
  UserPreferences,
  WeeklyReviewState,
} from "../../../domain/models";

export type SyncEntityRecord =
  | Goal
  | GoalMilestone
  | Task
  | DailyPlan
  | DailyRitualState
  | WeeklyReviewState
  | MonthlyReviewState
  | TimeBlock
  | UserPreferences
  | NotificationPreference
  | AdaptationProfile
  | ActivityEvent;

export const syncEntityOrder: SyncEntityKind[] = [
  "goal",
  "milestone",
  "task",
  "daily_plan",
  "daily_ritual_state",
  "weekly_review_state",
  "monthly_review_state",
  "time_block",
  "activity_event",
  "preferences",
  "notification_preference",
  "adaptation_profile",
];

export function toRemoteId(kind: SyncEntityKind, record: EntityRecord) {
  return record.remoteId ?? `${kind}:${record.id}`;
}

export function prepareOwnedRecord<T extends SyncEntityRecord>(
  kind: SyncEntityKind,
  record: T,
  accountId: string,
  now: string,
): T {
  return {
    ...record,
    ownerUserId: accountId,
    remoteId: toRemoteId(kind, record),
    syncState: EntitySyncState.PendingSync,
    updatedAt: now,
  };
}

export function normalizeRemoteRecord<T extends SyncEntityRecord>(
  kind: SyncEntityKind,
  record: T,
  accountId: string,
  now: string,
): T {
  return {
    ...record,
    ownerUserId: accountId,
    remoteId: toRemoteId(kind, record),
    syncState: EntitySyncState.Synced,
    lastSyncedAt: now,
  };
}

export function duplicateConflictRecord(
  kind: SyncEntityKind,
  record: SyncEntityRecord,
  now: string,
): SyncEntityRecord | null {
  if (kind === "goal") {
    const goal = record as Goal;
    return {
      ...goal,
      id: `${goal.id}:preserved:${now}`,
      title: `${goal.title} (Preserved copy)`,
      remoteId: null,
      syncState: EntitySyncState.Conflict,
      version: 1,
      lastSyncedAt: null,
      createdAt: now,
      updatedAt: now,
      metadata: { ...goal.metadata, preservedConflict: "true" },
    };
  }

  if (kind === "milestone") {
    const milestone = record as GoalMilestone;
    return {
      ...milestone,
      id: `${milestone.id}:preserved:${now}`,
      title: `${milestone.title} (Preserved copy)`,
      remoteId: null,
      syncState: EntitySyncState.Conflict,
      version: 1,
      lastSyncedAt: null,
      createdAt: now,
      updatedAt: now,
      metadata: { ...milestone.metadata, preservedConflict: "true" },
    };
  }

  if (kind === "task") {
    const task = record as Task;
    return {
      ...task,
      id: `${task.id}:preserved:${now}`,
      title: `${task.title} (Preserved copy)`,
      remoteId: null,
      syncState: EntitySyncState.Conflict,
      version: 1,
      lastSyncedAt: null,
      createdAt: now,
      updatedAt: now,
      metadata: { ...task.metadata, preservedConflict: "true" },
    };
  }

  if (kind === "activity_event") {
    const event = record as ActivityEvent;
    return {
      ...event,
      id: `${event.id}:preserved:${now}`,
      title: `${event.title} (Preserved copy)`,
      remoteId: null,
      syncState: EntitySyncState.Conflict,
      version: 1,
      lastSyncedAt: null,
      createdAt: now,
      updatedAt: now,
      metadata: { ...event.metadata, preservedConflict: "true" },
    };
  }

  return null;
}
