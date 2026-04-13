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
import { formatShortDateTime, formatTimeLabel, formatTimeRangeLabel } from "../../utils/date";
import { unsupportedNotificationPermissionStatus } from "../../bootstrap/runtime/runtimeSupport";

interface SyncStatusMetadata {
  lastAttemptedSyncAt: string | null;
  lastFailureAt: string | null;
  lastOperationKind: string | null;
}

const monthlyReviewCadenceOptions = [
  { day: 1, shortLabel: "Month opens", longLabel: "the first day of the month" },
  { day: 2, shortLabel: "After landing", longLabel: "the second day of the month" },
  { day: 3, shortLabel: "Early reset", longLabel: "the third day of the month" },
  { day: 5, shortLabel: "First work stretch", longLabel: "the fifth day of the month" },
  { day: 7, shortLabel: "After the first week", longLabel: "the seventh day of the month" },
] as const;

function monthlyCadenceOption(day: number) {
  return monthlyReviewCadenceOptions.find((option) => option.day === day) ?? null;
}

export function getMonthlyReviewCadenceOptions() {
  return monthlyReviewCadenceOptions.map((option) => ({ ...option }));
}

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
    case ReminderType.WeeklyReview:
      return "Weekly review";
    case ReminderType.MonthlyReview:
      return "Monthly review";
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
    case ReminderType.WeeklyReview:
      return `${preference.leadTimeMinutes} min before weekly review time`;
    case ReminderType.MonthlyReview:
      return `${preference.leadTimeMinutes} min before monthly review time`;
    default:
      return "Active";
  }
}

export function formatMonthlyReviewCadence(day: number) {
  const option = monthlyCadenceOption(day);
  return option?.longLabel ?? `day ${day} of the month`;
}

export function formatMonthlyReviewCadenceShort(day: number) {
  const option = monthlyCadenceOption(day);
  return option?.shortLabel ?? `Day ${day}`;
}

export function summarizeMonthlyReviewControl(params: {
  day: number;
  time: string;
  autoPrompt: boolean;
}) {
  const cadence = formatMonthlyReviewCadenceShort(params.day);
  const time = formatTimeLabel(params.time, { compact: true });

  return {
    cadenceLabel: cadence,
    scheduleLabel: `${cadence} at ${time}`,
    promptLabel: params.autoPrompt
      ? "Next-month strategy prompts stay on"
      : "Next-month strategy stays manual",
  };
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

  if (connectionState.permissionState === CalendarPermissionState.Unavailable) {
    return {
      badge: "Native only",
      headline: "Using saved defaults",
      detail: "Calendar context is only available in native iPhone and Android builds, so Ambitions is staying on saved schedule defaults here.",
      meta: ["Native calendar access unavailable", "Saved defaults still active"],
      issue: "Calendar is native-only in this build. Use a device build when you need live calendar validation.",
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

export function summarizeNotificationAccess(status: string) {
  if (status === "granted") {
    return {
      badge: "Access ready",
      shortLabel: "Ready",
      detail: "Ready to notify",
      headline: "Reminders ready",
      description: "Choose what Ambitions can interrupt you for, and how early it should speak up.",
      actionLabel: "Allow notifications",
      needsPermission: false,
      unsupported: false,
    };
  }

  if (status === unsupportedNotificationPermissionStatus) {
    return {
      badge: "Native only",
      shortLabel: "Native only",
      detail: "Reminders need a native device build",
      headline: "Reminders are native-only",
      description: "Push reminders are only available in native iPhone and Android builds, so this runtime stays quiet.",
      actionLabel: "Allow notifications",
      needsPermission: false,
      unsupported: true,
    };
  }

  return {
    badge: "Access needed",
    shortLabel: "Needs access",
    detail: "Grant access to enable pushes",
    headline: "Reminders need access",
    description: "Notification access is still off, so Ambitions will keep reminders quiet.",
    actionLabel: "Allow notifications",
    needsPermission: true,
    unsupported: false,
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
  const weeklyCarryoverLabel =
    productPreferences.defaultWeeklyCarryoverBehavior === "essentials_only"
      ? "Carry only essentials"
      : productPreferences.defaultWeeklyCarryoverBehavior === "aggressive"
        ? "Carry more forward"
        : "Review unfinished work first";
  const monthlyCadenceLabel = formatMonthlyReviewCadenceShort(productPreferences.monthlyReviewDay);
  const monthlyPostureLabel =
    productPreferences.defaultMonthlyPosture === "build_momentum"
      ? "Build momentum"
      : productPreferences.defaultMonthlyPosture === "push_output"
        ? "Push output"
        : "Stabilize";
  const monthlyCarryoverLabel =
    productPreferences.defaultMonthlyCarryoverStance === "prune_aggressively"
      ? "Prune aggressively"
      : productPreferences.defaultMonthlyCarryoverStance === "tolerate_more_carryover"
        ? "Tolerate more carryover"
        : "Review before carrying";

  return {
    adaptiveLabel,
    intensityLabel,
    taskLabel,
    unfinishedWorkLabel,
    weeklyCarryoverLabel,
    monthlyCadenceLabel,
    monthlyPostureLabel,
    monthlyCarryoverLabel,
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
  const unsyncedLocalCount = pendingPushCount;
  const attached = attachmentState?.status === LocalAttachmentStatus.Attached;
  const accountConnected = !!syncState?.accountId;
  const metadata = readSyncStatusMetadata(syncState);
  const hasAttentionState =
    syncState?.mode === SyncMode.Offline ||
    syncState?.mode === SyncMode.Issue ||
    syncState?.mode === SyncMode.ReviewRequired ||
    conflicts.length > 0;
  const canRetry = attached && accountConnected;
  const lastSuccessLabel = syncState?.lastSyncAt
    ? formatShortDateTime(syncState.lastSyncAt)
    : null;
  const lastAttemptLabel = metadata.lastAttemptedSyncAt
    ? formatShortDateTime(metadata.lastAttemptedSyncAt)
    : null;
  const lastFailureLabel = metadata.lastFailureAt
    ? formatShortDateTime(metadata.lastFailureAt)
    : null;

  let headline = "Local only";
  let detail = "Everything is staying on this device.";
  let badge = "Local only";
  let modeLabel = "On this device only";
  let nextStep = "Connect an account when you want goals, plans, and review history to follow you to another device.";
  let localStateDetail = "This device is the only place holding current Ambitions data.";
  let cloudStateDetail = "Nothing is in your account yet.";
  let signOutDetail = "There is no connected account to sign out from.";

  if (accountConnected && !attached) {
    headline =
      attachmentState?.status === LocalAttachmentStatus.ConfirmationRequired
        ? "Signed in, still local on this device"
        : "Signed in without device attachment";
    detail =
      attachmentState?.status === LocalAttachmentStatus.ConfirmationRequired
        ? "Your account is ready, but this device is still holding newer local data until you choose to bring it over."
        : "Your account is connected, but this device is not sending its local work yet.";
    badge = "Account connected";
    modeLabel = "Account connected, device still local";
    nextStep =
      attachmentState?.status === LocalAttachmentStatus.ConfirmationRequired
        ? "Attach this device when you want its current goals, plans, and history to follow you."
        : "Attach this device when you want new work here to start following the account.";
    localStateDetail =
      attachmentState?.pendingRecordCount ?? 0
        ? `This device is holding ${attachmentState?.pendingRecordCount ?? 0} local item${
            attachmentState?.pendingRecordCount === 1 ? "" : "s"
          } that have not moved into the account.`
        : "This device is still the source of truth for any work created here until attachment happens.";
    cloudStateDetail = "Your account exists, but this device has not started cross-device syncing yet.";
    signOutDetail =
      attachmentState?.status === LocalAttachmentStatus.ConfirmationRequired
        ? "Signing out leaves this device's current work here. Reconnect before signing out if you want this local state to follow you."
        : "Signing out removes the account connection only. Local work on this device stays here.";
  } else {
    switch (syncState?.mode) {
      case SyncMode.Synced:
        headline = "Up to date across devices";
        detail = "This device and your account are aligned.";
        badge = "Healthy sync";
        modeLabel = "Cloud-backed and current";
        nextStep = "Nothing needs attention right now.";
        localStateDetail = "This device is not holding newer unsynced changes.";
        cloudStateDetail = lastSuccessLabel
          ? `Your account last received a completed sync ${lastSuccessLabel}.`
          : "Your account has the same known state as this device.";
        signOutDetail =
          "Signing out pauses syncing on this device, but your current content stays here and remains in the connected account.";
        break;
      case SyncMode.Syncing:
        headline = "Syncing recent changes";
        detail = "Ambitions is moving this device's newer state into your account now.";
        badge = "Syncing";
        modeLabel = "Connected and moving changes";
        nextStep = "Let the current sync finish before relying on another device for the latest state.";
        localStateDetail = "This device is currently writing newer local changes into the connected account.";
        cloudStateDetail = "The account is updating now.";
        signOutDetail =
          "Signing out now would leave any still-pending local changes on this device until you reconnect and sync again.";
        break;
      case SyncMode.PendingChanges:
        headline = "This device has newer unsynced changes";
        detail = "Recent edits are still on this device and have not reached your account yet.";
        badge = "Needs sync";
        modeLabel = "Connected, waiting to send changes";
        nextStep = canRetry
          ? "Sync again when you're ready if you want another device to pick these changes up."
          : "Reconnect this device before expecting another device to match it.";
        localStateDetail = `This device is currently holding ${unsyncedLocalCount} unsynced local change${
          unsyncedLocalCount === 1 ? "" : "s"
        }.`;
        cloudStateDetail = lastSuccessLabel
          ? `Your account is still at the state from ${lastSuccessLabel}.`
          : "Your account has not received a completed sync from this device yet.";
        signOutDetail =
          "Signing out keeps these newer local changes on this device. Reconnect before signing out if you want them to follow you.";
        break;
      case SyncMode.Offline:
        headline = "Offline, with local changes preserved";
        detail = pendingPushCount > 0
          ? "You can keep working here. This device is holding newer changes until the connection returns."
          : "You can keep working here while the account connection is paused.";
        badge = "Offline";
        modeLabel = "Connected, waiting on network";
        nextStep = pendingPushCount > 0
          ? "Reconnect and sync when you want these local changes to reach your account."
          : "Reconnect whenever you want the account to confirm this device is current again.";
        localStateDetail = pendingPushCount > 0
          ? `This device is holding ${pendingPushCount} unsynced local change${pendingPushCount === 1 ? "" : "s"}.`
          : "No new local changes are waiting right now.";
        cloudStateDetail = lastSuccessLabel
          ? `Your account is still at the last completed sync from ${lastSuccessLabel}.`
          : "No completed account sync has happened from this device yet.";
        signOutDetail =
          pendingPushCount > 0
            ? "Signing out now leaves the newer local state on this device. Reconnect before signing out if you want it to follow you."
            : "Signing out leaves local data on this device and pauses account syncing.";
        break;
      case SyncMode.Issue:
        headline = "Sync needs another try";
        detail = "The last sync did not finish, but your local changes are still here on this device.";
        badge = "Needs attention";
        modeLabel = "Connected, retry available";
        nextStep = "Retry when you're ready. Another device may still be behind until a sync completes.";
        localStateDetail = pendingPushCount > 0
          ? `This device is holding ${pendingPushCount} newer local change${pendingPushCount === 1 ? "" : "s"}.`
          : "This device kept the latest local state after the failed sync.";
        cloudStateDetail = lastSuccessLabel
          ? `Your account is still at the last completed sync from ${lastSuccessLabel}.`
          : "Your account may not have any completed sync from this device yet.";
        signOutDetail =
          "Signing out keeps local data on this device. Retry first if you want the connected account to receive your latest changes.";
        break;
      case SyncMode.ReviewRequired:
        headline = "Sync stopped to protect conflicting edits";
        detail = "Ambitions kept local state in place instead of silently replacing it.";
        badge = "Review required";
        modeLabel = "Connected, waiting on review";
        nextStep = "Use this device as the current source of truth until the conflicting items are reviewed.";
        localStateDetail = "This device kept its local state instead of manufacturing duplicate records.";
        cloudStateDetail =
          conflicts.length > 0
            ? `${conflicts.length} item${conflicts.length === 1 ? "" : "s"} differ between this device and the connected account.`
            : "A prior sync conflict still needs review.";
        signOutDetail =
          "Signing out now leaves current local data on this device, but another device should not be treated as current until review is complete.";
        break;
      default:
        break;
    }
  }

  return {
    headline,
    detail,
    badge,
    modeLabel,
    nextStep,
    localStateDetail,
    cloudStateDetail,
    signOutDetail,
    needsAttention: hasAttentionState,
    canRetry,
    pendingChangeCount: pendingTotal,
    unsyncedLocalCount,
    reviewCount: conflicts.length,
    lastSuccessLabel,
    lastAttemptLabel,
    lastFailureLabel,
    meta: [
      accountConnected
        ? attached
          ? "This device is attached to the connected account"
          : "Account is connected, but this device is still local-first"
        : "This device is staying local only",
      lastSuccessLabel ? `Last completed sync ${lastSuccessLabel}` : "No completed sync yet",
      pendingTotal > 0
        ? `${pendingTotal} pending sync change${pendingTotal === 1 ? "" : "s"}`
        : "No pending sync changes",
      conflicts.length > 0
        ? `${conflicts.length} item${conflicts.length === 1 ? "" : "s"} need review`
        : "No open sync conflicts",
    ],
  };
}

function readSyncStatusMetadata(syncState: SyncStateSnapshot | null): SyncStatusMetadata {
  const metadata = syncState?.metadata ?? {};
  return {
    lastAttemptedSyncAt:
      typeof metadata.lastAttemptedSyncAt === "string" ? metadata.lastAttemptedSyncAt : null,
    lastFailureAt: typeof metadata.lastFailureAt === "string" ? metadata.lastFailureAt : null,
    lastOperationKind: typeof metadata.lastOperationKind === "string" ? metadata.lastOperationKind : null,
  };
}
