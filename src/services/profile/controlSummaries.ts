import {
  AdaptationProfile,
  CalendarConnectionState,
  CalendarPermissionState,
  CalendarSyncState,
  LocalAttachmentState,
  LocalAttachmentStatus,
  NotificationPreference,
  ReminderType,
  ScheduleConstraint,
  SyncConflictRecord,
  SyncMode,
  SyncStateSnapshot,
} from "../../domain/models";
import { ProductPreferences } from "../../product/types";
import { formatShortDateTime, formatTimeRangeLabel } from "../../utils/date";

export function formatReminderTypeLabel(reminderType: ReminderType) {
  switch (reminderType) {
    case ReminderType.TimeBlockStart:
      return "Before sessions";
    case ReminderType.PlanReview:
      return "Plan review";
    case ReminderType.ReplanPrompt:
      return "Replan prompts";
    case ReminderType.MomentumNudge:
      return "Momentum nudges";
    case ReminderType.MorningStart:
      return "Morning start";
    case ReminderType.EveningClose:
      return "Evening close";
    case ReminderType.RecoveryPrompt:
      return "Recovery prompt";
    default:
      return "Reminder";
  }
}

export function formatReminderBehavior(preference: NotificationPreference) {
  if (!preference.enabled) {
    return "Muted";
  }

  switch (preference.reminderType) {
    case ReminderType.TimeBlockStart:
      return `${preference.leadTimeMinutes} min before a scheduled session`;
    case ReminderType.PlanReview:
      return "When a daily plan needs review";
    case ReminderType.ReplanPrompt:
      return "When the day needs reshaping";
    case ReminderType.MomentumNudge:
      return "When a small nudge can keep momentum going";
    case ReminderType.MorningStart:
      return `${preference.leadTimeMinutes} min before the day opens`;
    case ReminderType.EveningClose:
      return `${preference.leadTimeMinutes} min before closeout time`;
    case ReminderType.RecoveryPrompt:
      return "When drift is detected and a clean recovery path is available";
    default:
      return "Active";
  }
}

export function summarizeQuietHours(preferences: NotificationPreference[]) {
  const pushPreferences = preferences.filter((preference) => preference.channel === "push");
  const sharedStart = pushPreferences[0]?.quietHoursStart ?? null;
  const sharedEnd = pushPreferences[0]?.quietHoursEnd ?? null;
  const allMatch = pushPreferences.every(
    (preference) =>
      preference.quietHoursStart === sharedStart && preference.quietHoursEnd === sharedEnd,
  );

  if (!pushPreferences.length || !allMatch || !sharedStart || !sharedEnd) {
    return "No shared quiet hours";
  }

  return formatTimeRangeLabel(sharedStart, sharedEnd, { compact: true });
}

export function summarizeCalendarControl(params: {
  connectionState: CalendarConnectionState | null;
  scheduleConstraints: ScheduleConstraint[];
  usingLiveCalendar: boolean;
}) {
  const { connectionState, scheduleConstraints, usingLiveCalendar } = params;
  const liveConstraintCount = scheduleConstraints.filter(
    (constraint) => constraint.source === "calendar",
  ).length;
  const selectedCount = connectionState?.selectedCalendarIds.length ?? 0;
  const availableCount = Number(connectionState?.metadata.availableCalendarCount ?? 0);

  if (!connectionState || connectionState.permissionState === CalendarPermissionState.NotAsked) {
    return {
      badge: "Calendar off",
      headline: "Using saved defaults",
      detail: "Live calendar is off, so Ambitions is shaping today from your saved schedule defaults.",
      meta: ["Calendar access not granted", "Refresh available after connection"],
      issue: null as string | null,
    };
  }

  if (connectionState.permissionState === CalendarPermissionState.Denied) {
    return {
      badge: "Access off",
      headline: "Using saved defaults",
      detail: "Calendar access is off right now, so planning stays on your saved baseline.",
      meta: ["Calendar permission denied", "No live events read"],
      issue: "Calendar access is off. Reconnect when you want live context back.",
    };
  }

  if (connectionState.connectionStatus === CalendarSyncState.NoUsableCalendars) {
    return {
      badge: "No calendars",
      headline: "Nothing readable yet",
      detail: "Ambitions has permission, but there are no visible calendars it can use for live context.",
      meta: [`${availableCount} visible calendars`, "Saved defaults still active"],
      issue: "No usable calendars were found. Using saved defaults until one becomes available.",
    };
  }

  if (connectionState.connectionStatus === CalendarSyncState.Ready && usingLiveCalendar) {
    return {
      badge: "Live calendar",
      headline: liveConstraintCount > 0 ? "Using live calendar context" : "Calendar is clear",
      detail:
        liveConstraintCount > 0
          ? `Today's plan is reacting to ${liveConstraintCount} live calendar block${liveConstraintCount === 1 ? "" : "s"}.`
          : "Today's plan checked your live calendar and found no blocking events.",
      meta: [
        `${selectedCount || availableCount} calendar${selectedCount === 1 ? "" : "s"} in scope`,
        connectionState.lastSuccessfulSyncAt
          ? `Updated ${formatShortDateTime(connectionState.lastSuccessfulSyncAt)}`
          : "Updated just now",
      ],
      issue: null as string | null,
    };
  }

  const stale = connectionState.connectionStatus === CalendarSyncState.Stale;

  return {
    badge: stale ? "Stale" : "Connection issue",
    headline: stale ? "Using saved defaults for now" : "Live context unavailable",
    detail: stale
      ? "The last calendar refresh failed, so Ambitions fell back to your saved schedule defaults."
      : "Live calendar could not be read right now, so planning stayed on the safer default baseline.",
    meta: [
      connectionState.lastSuccessfulSyncAt
        ? `Last good refresh ${formatShortDateTime(connectionState.lastSuccessfulSyncAt)}`
        : "No successful live refresh yet",
      `${selectedCount || availableCount} calendar${selectedCount === 1 ? "" : "s"} in scope`,
    ],
    issue:
      stale
        ? "Calendar context is stale. Refresh when you want a fresh read."
        : "Connection issue. Try again when you're ready.",
  };
}

export function summarizePlanningControls(
  productPreferences: ProductPreferences,
  adaptationProfile: AdaptationProfile | null,
) {
  const adaptiveLabel = productPreferences.adaptivePlanningEnabled ? "Learning" : "Defaults only";
  const intensityLabel =
    productPreferences.dayIntensity === "light"
      ? "Lighter plans"
      : productPreferences.dayIntensity === "ambitious"
        ? "Fuller plans"
        : "Balanced plans";
  const taskLabel =
    productPreferences.taskSizing === "smaller"
      ? "Shorter steps"
      : productPreferences.taskSizing === "bigger"
        ? "Deeper blocks"
        : "Mixed task size";
  const unfinishedWorkLabel =
    productPreferences.defaultUnfinishedWorkBehavior === "carry_forward"
      ? "Carry unfinished work forward"
      : productPreferences.defaultUnfinishedWorkBehavior === "send_to_review"
        ? "Send unfinished work back to review"
        : "Ask each evening";

  return {
    adaptiveLabel,
    intensityLabel,
    taskLabel,
    unfinishedWorkLabel,
    learnedSummary:
      productPreferences.adaptivePlanningEnabled && adaptationProfile?.personalization.active
        ? adaptationProfile.personalization.summary.todayApproach
        : "Planner behavior is staying on your explicit defaults.",
  };
}

export function summarizeSyncState(params: {
  syncState: SyncStateSnapshot | null;
  attachmentState: LocalAttachmentState | null;
  conflicts: SyncConflictRecord[];
}) {
  const { syncState, attachmentState, conflicts } = params;
  const pendingPushCount = syncState?.pendingPushCount ?? 0;
  const pendingPullCount = syncState?.pendingPullCount ?? 0;
  const pendingTotal = pendingPushCount + pendingPullCount;
  const attached = attachmentState?.status === LocalAttachmentStatus.Attached;

  let headline = "Local only";
  let detail = "Everything is staying on this device.";

  switch (syncState?.mode) {
    case SyncMode.Synced:
      headline = "Up to date";
      detail = "Your account and this device are aligned.";
      break;
    case SyncMode.Syncing:
      headline = "Syncing now";
      detail = "Ambitions is moving recent changes to your account.";
      break;
    case SyncMode.PendingChanges:
      headline = "Pending changes";
      detail = "Recent changes are waiting to sync.";
      break;
    case SyncMode.Offline:
      headline = "Offline for now";
      detail = "You can keep working. Changes will sync later.";
      break;
    case SyncMode.Issue:
      headline = "Connection issue";
      detail = "Your changes are still safe on this device.";
      break;
    case SyncMode.ReviewRequired:
      headline = "Needs review";
      detail = "Some synced items need a quick review.";
      break;
    default:
      break;
  }

  return {
    headline,
    detail,
    meta: [
      attached ? "Device attached to account" : "Device not attached",
      syncState?.lastSyncAt ? `Last sync ${formatShortDateTime(syncState.lastSyncAt)}` : "No completed sync yet",
      pendingTotal > 0 ? `${pendingTotal} change${pendingTotal === 1 ? "" : "s"} waiting` : "No pending changes",
      conflicts.length > 0 ? `${conflicts.length} review item${conflicts.length === 1 ? "" : "s"}` : "No sync conflicts",
    ],
  };
}
