import { Ionicons } from "@expo/vector-icons";
import { useEffect, useRef, useState } from "react";
import {
  Keyboard,
  KeyboardAvoidingView,
  LayoutChangeEvent,
  Platform,
  Pressable,
  ScrollView,
  TextInput,
  View,
} from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";

import { AccountStatusCard } from "../../components/account/AccountStatusCard";
import {
  DetailHero,
  DetailMetaGroup,
  DetailSection,
  DetailSummaryStrip,
  QuietMetaLine,
} from "../../components/detail/DetailPrimitives";
import { IntegrationStatusCard } from "../../components/today/IntegrationStatusCard";
import { GroupedActivityTimeline, MomentumBars } from "../../components/history/ActivityTimeline";
import { Button } from "../../components/ui/Button";
import { EmptyStateCard } from "../../components/ui/EmptyStateCard";
import { OptionChip } from "../../components/ui/OptionChip";
import { Pill } from "../../components/ui/Pill";
import { ProgressBar } from "../../components/ui/ProgressBar";
import { Screen } from "../../components/ui/Screen";
import { SegmentedControl } from "../../components/ui/SegmentedControl";
import { Surface } from "../../components/ui/Surface";
import { AppText } from "../../components/ui/Text";
import { TextField } from "../../components/ui/TextField";
import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
import { accentThemeOptions, appearanceModeOptions } from "../../product/theme";
import { useAppStore } from "../../state/useAppStore";
import { AuthFeedback } from "../../services/account/accountCopy";
import { buildActivityFeed, groupActivityByDate, summarizeInsights } from "../../services/history/selectors";
import { buildPlanningStyleSummary } from "../../services/personalization/selectors";
import {
  formatReminderBehavior,
  formatReminderTypeLabel,
  summarizeCalendarControl,
  summarizePlanningControls,
  summarizeQuietHours,
  summarizeSyncState,
} from "../../services/profile/controlSummaries";
import {
  formatTimeLabel,
  formatTimeRangeLabel,
  formatShortDateTime,
  normalizeTimeString,
} from "../../utils/date";
import { isSupabaseConfigured } from "../../services/account/supabaseConfig";
import {
  CalendarSyncState,
  ConstraintSource,
  ReminderType,
} from "../../domain/models";
import { DefaultUnfinishedWorkBehavior } from "../../product/types";

function MetaLine({ items }: { items: string[] }) {
  return (
    <View className="flex-row flex-wrap gap-x-4 gap-y-2">
      {items.map((item) => (
        <AppText key={item} tone="secondary" variant="caption">
          {item}
        </AppText>
      ))}
    </View>
  );
}

const quietHourPresets = [
  { id: "off", label: "Off", start: null, end: null },
  { id: "calm", label: "9:30p - 7a", start: "21:30", end: "07:00" },
  { id: "late", label: "10:30p - 7a", start: "22:30", end: "07:00" },
] as const;

const reminderLeadTimeOptions = [5, 10, 15] as const;
const ritualReminderLeadTimeOptions = [0, 10, 15] as const;
const unfinishedWorkBehaviorOptions: Array<{
  id: DefaultUnfinishedWorkBehavior;
  label: string;
  description: string;
}> = [
  {
    id: "carry_forward",
    label: "Carry forward",
    description: "Move unfinished work into tomorrow by default.",
  },
  {
    id: "send_to_review",
    label: "Send to review",
    description: "Route unfinished work back to review instead of assuming it stays live.",
  },
  {
    id: "ask_each_time",
    label: "Ask each time",
    description: "Choose the carry decision during closeout.",
  },
];

function describeConstraintSource(constraintCount: number, usingLiveCalendar: boolean) {
  if (usingLiveCalendar) {
    return constraintCount > 0
      ? `${constraintCount} live calendar block${constraintCount === 1 ? "" : "s"} shaping today`
      : "Live calendar checked with no blocking events";
  }

  return "Saved schedule defaults are shaping today";
}

function issueTone(status: CalendarSyncState | null | undefined) {
  return status === CalendarSyncState.Stale || status === CalendarSyncState.TemporaryFailure
    ? "sunken"
    : "default";
}

export function ProfileHistoryScreen() {
  const goals = useAppStore((state) => state.goals);
  const milestones = useAppStore((state) => state.milestones);
  const tasks = useAppStore((state) => state.allTasks);
  const activityEvents = useAppStore((state) => state.activityEvents);
  const adaptationProfile = useAppStore((state) => state.adaptationProfile);

  const feed = buildActivityFeed(activityEvents, tasks, milestones);
  const groups = groupActivityByDate(feed.slice(0, 18));
  const summary = summarizeInsights({
    goals,
    tasks,
    milestones,
    events: feed,
    profile: adaptationProfile,
  });

  return (
    <Screen>
      <View className="gap-4">
        <Surface tone="accent" className="gap-4">
          <AppText variant="title">Recent movement</AppText>
          <AppText tone="secondary">{summary.momentumCopy}</AppText>
          <ProgressBar
            progress={
              summary.completedThisWeek + summary.reshapedThisWeek > 0
                ? summary.completedThisWeek / (summary.completedThisWeek + summary.reshapedThisWeek)
                : 0
            }
          />
          <MomentumBars points={summary.momentum} />
          <MetaLine
            items={[
              `${summary.completedThisWeek} completed this week`,
              `${summary.reshapedThisWeek} reshaped`,
              `${summary.openedThisWeek} opened · ${summary.closedThisWeek} closed`,
            ]}
          />
        </Surface>

        <Surface className="gap-3">
          <AppText variant="section">Daily rituals</AppText>
          <AppText tone="secondary">{summary.planStabilityCopy}</AppText>
          <MetaLine
            items={[
              `${summary.recoveryUsedThisWeek} recoveries`,
              summary.carryoverQualityCopy,
            ]}
          />
        </Surface>

        <GroupedActivityTimeline
          groups={groups}
          emptyTitle="No history yet"
          emptyBody="Recent movement will appear here."
        />
      </View>
    </Screen>
  );
}

export function ProfileAppearanceScreen() {
  const productPreferences = useAppStore((state) => state.productPreferences);
  const saveProductPreferences = useAppStore((state) => state.saveProductPreferences);
  const theme = useResolvedTheme();
  const [busyState, setBusyState] = useState<string | null>(null);
  const [runtimeMessage, setRuntimeMessage] = useState<string | null>(null);

  if (!productPreferences) {
    return (
      <Screen>
        <EmptyStateCard title="Preferences unavailable" body="Appearance is still loading." />
      </Screen>
    );
  }

  const resolvedPreferences = productPreferences;

  async function saveAppearance(next: typeof resolvedPreferences, busyKey: string) {
    setBusyState(busyKey);
    setRuntimeMessage(null);

    try {
      await saveProductPreferences(next);
    } catch (error) {
      setRuntimeMessage(
        error instanceof Error ? error.message : "Appearance could not be updated.",
      );
    } finally {
      setBusyState(null);
    }
  }

  return (
    <Screen>
      <View className="gap-4">
        <Surface tone="hero" className="gap-3">
          <AppText variant="title">Appearance</AppText>
          <AppText tone="secondary">
            Pick mode and accent here.
          </AppText>
          <MetaLine items={[`${theme.mode} mode`, theme.accentLabel]} />
        </Surface>
        <Surface className="gap-3">
          <AppText variant="section">Mode</AppText>
          <View className="flex-row flex-wrap gap-2">
            {appearanceModeOptions.map((option) => (
              <OptionChip
                key={option.id}
                selected={resolvedPreferences.appearanceMode === option.id}
                onPress={() =>
                  void saveAppearance(
                    { ...resolvedPreferences, appearanceMode: option.id },
                    `mode:${option.id}`,
                  )
                }
              >
                {option.label}
              </OptionChip>
            ))}
          </View>
        </Surface>
        <View className="gap-3">
          <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
            Accent
          </AppText>
          {accentThemeOptions.map((accent) => (
            <Pressable
              key={accent.id}
              className="rounded-[28px]"
              onPress={() =>
                void saveAppearance(
                  { ...resolvedPreferences, accentTheme: accent.id },
                  `accent:${accent.id}`,
                )
              }
              style={({ pressed }) => ({ opacity: pressed ? 0.92 : 1 })}
            >
              <Surface
                className="gap-3"
                style={{
                  borderColor:
                    resolvedPreferences.accentTheme === accent.id
                      ? theme.colors.border.accent
                      : theme.colors.border.subtle,
                }}
              >
                <View className="flex-row items-center justify-between gap-3">
                  <View className="flex-1 gap-1">
                    <AppText variant="section">{accent.label}</AppText>
                    <AppText tone="secondary" variant="caption">
                      {accent.description}
                    </AppText>
                  </View>
                  <View className="flex-row gap-2">
                    {accent.preview.map((color) => (
                      <View
                        key={color}
                        style={{
                          width: 22,
                          height: 22,
                          borderRadius: 999,
                          backgroundColor: color,
                          borderWidth: 1,
                          borderColor: "rgba(0,0,0,0.06)",
                        }}
                      />
                    ))}
                  </View>
                </View>
                {resolvedPreferences.accentTheme === accent.id ? <MetaLine items={["Selected"]} /> : null}
              </Surface>
            </Pressable>
          ))}
        </View>
        {runtimeMessage ? <AppText tone="tertiary" variant="caption">{runtimeMessage}</AppText> : null}
      </View>
    </Screen>
  );
}

export function ProfileScheduleDefaultsScreen() {
  const productPreferences = useAppStore((state) => state.productPreferences);
  const saveProductPreferences = useAppStore((state) => state.saveProductPreferences);
  const [sleepStart, setSleepStart] = useState("11:00 PM");
  const [sleepEnd, setSleepEnd] = useState("7:00 AM");
  const [workStart, setWorkStart] = useState("9:00 AM");
  const [workEnd, setWorkEnd] = useState("5:00 PM");
  const [commuteMinutes, setCommuteMinutes] = useState("20");
  const [busyState, setBusyState] = useState<string | null>(null);
  const [runtimeMessage, setRuntimeMessage] = useState<string | null>(null);

  useEffect(() => {
    if (!productPreferences) {
      return;
    }
    setSleepStart(formatTimeLabel(productPreferences.schedule.sleepStart));
    setSleepEnd(formatTimeLabel(productPreferences.schedule.sleepEnd));
    setWorkStart(formatTimeLabel(productPreferences.schedule.workdayStart));
    setWorkEnd(formatTimeLabel(productPreferences.schedule.workdayEnd));
    setCommuteMinutes(String(productPreferences.schedule.commuteMinutes));
  }, [productPreferences]);

  if (!productPreferences) {
    return (
      <Screen>
        <EmptyStateCard title="Preferences unavailable" body="Schedule defaults are still loading." />
      </Screen>
    );
  }

  const resolvedPreferences = productPreferences;

  const normalizedSleepStart =
    normalizeTimeString(sleepStart) ?? resolvedPreferences.schedule.sleepStart;
  const normalizedSleepEnd = normalizeTimeString(sleepEnd) ?? resolvedPreferences.schedule.sleepEnd;
  const normalizedWorkStart =
    normalizeTimeString(workStart) ?? resolvedPreferences.schedule.workdayStart;
  const normalizedWorkEnd = normalizeTimeString(workEnd) ?? resolvedPreferences.schedule.workdayEnd;

  async function saveSchedule() {
    setBusyState("schedule");
    setRuntimeMessage(null);

    try {
      await saveProductPreferences({
        ...resolvedPreferences,
        schedule: {
          ...resolvedPreferences.schedule,
          sleepStart: normalizedSleepStart,
          sleepEnd: normalizedSleepEnd,
          workdayStart: normalizedWorkStart,
          workdayEnd: normalizedWorkEnd,
          commuteMinutes: Number(commuteMinutes) || 0,
        },
      });
    } catch (error) {
      setRuntimeMessage(error instanceof Error ? error.message : "Schedule defaults could not be saved.");
    } finally {
      setBusyState(null);
    }
  }

  return (
    <Screen>
      <View className="gap-4">
        <Surface tone="accent" className="gap-3">
          <AppText variant="title">Schedule defaults</AppText>
          <AppText tone="secondary">
            Used when live context is missing.
          </AppText>
          <MetaLine
            items={[
              formatTimeRangeLabel(normalizedSleepStart, normalizedSleepEnd),
              formatTimeRangeLabel(normalizedWorkStart, normalizedWorkEnd),
              `${commuteMinutes} min commute`,
            ]}
          />
        </Surface>
        <View className="flex-row gap-3">
          <View style={{ flex: 1 }}>
            <TextField label="Sleep starts" onChangeText={setSleepStart} value={sleepStart} />
          </View>
          <View style={{ flex: 1 }}>
            <TextField label="Sleep ends" onChangeText={setSleepEnd} value={sleepEnd} />
          </View>
        </View>
        <View className="flex-row gap-3">
          <View style={{ flex: 1 }}>
            <TextField label="Work starts" onChangeText={setWorkStart} value={workStart} />
          </View>
          <View style={{ flex: 1 }}>
            <TextField label="Work ends" onChangeText={setWorkEnd} value={workEnd} />
          </View>
          <View style={{ flex: 0.7 }}>
            <TextField label="Commute" onChangeText={setCommuteMinutes} value={commuteMinutes} />
          </View>
        </View>
        <Button onPress={() => void saveSchedule()} busy={busyState === "schedule"}>
          Save defaults
        </Button>
        {runtimeMessage ? <AppText tone="tertiary" variant="caption">{runtimeMessage}</AppText> : null}
      </View>
    </Screen>
  );
}

export function ProfileIntegrationsScreen() {
  const today = useAppStore((state) => state.today);
  const calendarConnectionState = useAppStore((state) => state.calendarConnectionState);
  const scheduleConstraints = useAppStore((state) => state.scheduleConstraints);
  const notificationPermissionStatus = useAppStore((state) => state.notificationPermissionStatus);
  const requestCalendarAccess = useAppStore((state) => state.requestCalendarAccess);
  const requestNotificationAccess = useAppStore((state) => state.requestNotificationAccess);
  const refreshIntegration = useAppStore((state) => state.refreshIntegration);
  const [integrationBusy, setIntegrationBusy] = useState<string | null>(null);
  const [runtimeMessage, setRuntimeMessage] = useState<string | null>(null);
  const liveConstraintCount = scheduleConstraints.filter(
    (constraint) => constraint.source === ConstraintSource.Calendar,
  ).length;
  const calendarSummary = summarizeCalendarControl({
    connectionState: calendarConnectionState,
    scheduleConstraints,
    usingLiveCalendar: today?.integration.usingLiveCalendar ?? false,
  });
  const calendarTitles = String(calendarConnectionState?.metadata.selectedCalendarTitles ?? "")
    .split(" | ")
    .map((title) => title.trim())
    .filter(Boolean);
  const visibleConstraints = scheduleConstraints.slice(0, 4);

  async function runIntegrationAction(
    key: string,
    action: () => Promise<void>,
    fallbackError: string,
  ) {
    setIntegrationBusy(key);
    setRuntimeMessage(null);

    try {
      await action();
    } catch (error) {
      setRuntimeMessage(error instanceof Error ? error.message : fallbackError);
    } finally {
      setIntegrationBusy(null);
    }
  }

  return (
    <Screen>
      <View className="gap-4">
        <DetailHero
          eyebrow="Integrations"
          title={calendarSummary.headline}
          description={calendarSummary.detail}
          badges={
            <>
              <Pill label={calendarSummary.badge} tone="accent" />
              <Pill
                label={notificationPermissionStatus === "granted" ? "Reminders ready" : "Reminders need access"}
                tone="quiet"
              />
            </>
          }
          meta={
            <DetailSummaryStrip
              items={[
                {
                  label: "Calendar",
                  value: today?.integration.usingLiveCalendar ? "Live" : "Defaults",
                  detail: describeConstraintSource(liveConstraintCount, today?.integration.usingLiveCalendar ?? false),
                },
                {
                  label: "Last refresh",
                  value: calendarConnectionState?.lastSuccessfulSyncAt
                    ? formatShortDateTime(calendarConnectionState.lastSuccessfulSyncAt)
                    : "Not yet",
                  detail: calendarConnectionState?.metadata.lastReadDate
                    ? `Checked for ${String(calendarConnectionState.metadata.lastReadDate)}`
                    : "No completed calendar read",
                },
              ]}
            />
          }
        />
        <IntegrationStatusCard
          calendarConnectionState={calendarConnectionState}
          notificationPermissionStatus={notificationPermissionStatus}
          onRequestCalendarAccess={() =>
            runIntegrationAction("calendar", requestCalendarAccess, "Calendar access could not be refreshed.")
          }
          onRequestNotificationAccess={() =>
            runIntegrationAction("notifications", requestNotificationAccess, "Notification access could not be refreshed.")
          }
          onRefreshIntegration={() =>
            runIntegrationAction(
              "refresh",
              () => refreshIntegration(today?.date),
              "Calendar context could not be refreshed.",
            )
          }
          usingLiveCalendar={today?.integration.usingLiveCalendar ?? false}
          calendarDetail={
            today?.integration.calendarDetail ??
            "Calendar context is not available until today's plan loads."
          }
          busyAction={
            integrationBusy === "calendar" ||
            integrationBusy === "notifications" ||
            integrationBusy === "refresh"
              ? (integrationBusy as "calendar" | "notifications" | "refresh")
              : null
          }
        />
        <DetailSection
          title="Calendar scope"
          description="What Ambitions can currently inspect."
        >
          <Surface tone={issueTone(calendarConnectionState?.connectionStatus)} className="gap-3 mb-0">
            <DetailMetaGroup
              items={[
                {
                  label: "Selected",
                  value: String(calendarConnectionState?.selectedCalendarIds.length ?? 0),
                },
                {
                  label: "Visible",
                  value: String(calendarConnectionState?.metadata.availableCalendarCount ?? 0),
                },
                {
                  label: "Live blocks",
                  value: String(liveConstraintCount),
                },
                {
                  label: "Reminder access",
                  value: notificationPermissionStatus === "granted" ? "Ready" : "Needs access",
                },
              ]}
            />
            {calendarTitles.length > 0 ? (
              <QuietMetaLine items={calendarTitles} />
            ) : (
              <AppText tone="secondary" variant="caption">
                Calendar names appear here after a successful live read.
              </AppText>
            )}
          </Surface>
        </DetailSection>
        <DetailSection
          title="What shaped today's plan"
          description="A compact read of the context currently in play."
        >
          {visibleConstraints.length > 0 ? (
            <View className="gap-3">
              {visibleConstraints.map((constraint) => (
                <Surface key={constraint.id} className="gap-2 mb-0">
                  <View className="flex-row items-center justify-between gap-3">
                    <View className="flex-1 gap-1">
                      <AppText variant="section">{constraint.title}</AppText>
                      <AppText tone="secondary" variant="caption">
                        {formatShortDateTime(constraint.startsAt)} - {formatShortDateTime(constraint.endsAt)}
                      </AppText>
                    </View>
                    <Pill
                      label={constraint.source === ConstraintSource.Calendar ? "Live" : "Saved"}
                      tone={constraint.source === ConstraintSource.Calendar ? "accent" : "quiet"}
                    />
                  </View>
                  {constraint.notes ? (
                    <AppText tone="tertiary" variant="caption">
                      {constraint.notes}
                    </AppText>
                  ) : null}
                </Surface>
              ))}
            </View>
          ) : (
            <EmptyStateCard
              title="No blocking context"
              body="Nothing from calendar or defaults is actively narrowing today's plan right now."
            />
          )}
        </DetailSection>
        {calendarSummary.issue ? (
          <Surface tone="sunken" className="gap-2">
            <AppText variant="caption">Status</AppText>
            <AppText tone="secondary" variant="caption">
              {calendarSummary.issue}
            </AppText>
          </Surface>
        ) : null}
        {runtimeMessage ? <AppText tone="tertiary" variant="caption">{runtimeMessage}</AppText> : null}
      </View>
    </Screen>
  );
}

export function ProfileNotificationsScreen() {
  const notificationPreferences = useAppStore((state) => state.notificationPreferences);
  const notificationPermissionStatus = useAppStore((state) => state.notificationPermissionStatus);
  const updateNotificationPreference = useAppStore((state) => state.updateNotificationPreference);
  const requestNotificationAccess = useAppStore((state) => state.requestNotificationAccess);
  const productPreferences = useAppStore((state) => state.productPreferences);
  const [busyState, setBusyState] = useState<string | null>(null);
  const [runtimeMessage, setRuntimeMessage] = useState<string | null>(null);
  const enabledCount = notificationPreferences.filter((preference) => preference.enabled).length;
  const timeBlockPreference = notificationPreferences.find(
    (preference) => preference.reminderType === ReminderType.TimeBlockStart,
  );
  const morningPreference = notificationPreferences.find(
    (preference) => preference.reminderType === ReminderType.MorningStart,
  );
  const eveningPreference = notificationPreferences.find(
    (preference) => preference.reminderType === ReminderType.EveningClose,
  );
  const recoveryPreference = notificationPreferences.find(
    (preference) => preference.reminderType === ReminderType.RecoveryPrompt,
  );
  const weeklyReviewPreference = notificationPreferences.find(
    (preference) => preference.reminderType === ReminderType.WeeklyReview,
  );
  const monthlyReviewPreference = notificationPreferences.find(
    (preference) => preference.reminderType === ReminderType.MonthlyReview,
  );
  const quietHoursSummary = summarizeQuietHours(notificationPreferences);

  async function runAction(key: string, action: () => Promise<void>, fallbackError: string) {
    setBusyState(key);
    setRuntimeMessage(null);

    try {
      await action();
    } catch (error) {
      setRuntimeMessage(error instanceof Error ? error.message : fallbackError);
    } finally {
      setBusyState(null);
    }
  }

  async function applyQuietHours(start: string | null, end: string | null) {
    const pushPreferences = notificationPreferences.filter(
      (preference) => preference.channel === "push",
    );

    await Promise.all(
      pushPreferences.map((preference) =>
        updateNotificationPreference(preference.reminderType, {
          quietHoursStart: start,
          quietHoursEnd: end,
        }),
      ),
    );
  }

  return (
    <Screen>
      <View className="gap-4">
        <DetailHero
          eyebrow="Notifications"
          title={enabledCount > 0 ? "Calm reminder control" : "Reminders are quiet"}
          description={
            notificationPermissionStatus === "granted"
              ? "Choose what Ambitions can interrupt you for, and how early it should speak up."
              : "Notification access is still off, so Ambitions will keep reminders quiet."
          }
          badges={
            <>
              <Pill
                label={notificationPermissionStatus === "granted" ? "Access ready" : "Access needed"}
                tone={notificationPermissionStatus === "granted" ? "accent" : "quiet"}
              />
              <Pill
                label={
                  enabledCount > 0
                    ? `${enabledCount} reminder${enabledCount === 1 ? "" : "s"} on`
                    : "No reminders active"
                }
                tone="quiet"
              />
            </>
          }
          meta={
            <DetailSummaryStrip
              items={[
                {
                  label: "Permission",
                  value: notificationPermissionStatus,
                  detail: notificationPermissionStatus === "granted" ? "Ready to notify" : "Grant access to enable pushes",
                },
                {
                  label: "Quiet hours",
                  value: quietHoursSummary,
                  detail: "Shared across push reminders",
                },
              ]}
            />
          }
        />
        {notificationPermissionStatus !== "granted" ? (
          <Button
            tone="secondary"
            onPress={() =>
              void runAction(
                "permission",
                requestNotificationAccess,
                "Notification access could not be refreshed.",
              )
            }
            busy={busyState === "permission"}
          >
            Allow notifications
          </Button>
        ) : null}
        <DetailSection
          title="Push timing"
          description="For reminders that can reach you outside the app."
        >
          <Surface className="gap-3 mb-0">
            <View className="gap-2">
              <AppText variant="section">Quiet hours</AppText>
              <AppText tone="secondary" variant="caption">
                Keep push reminders quiet overnight.
              </AppText>
            </View>
            <View className="flex-row flex-wrap gap-2">
              {quietHourPresets.map((preset) => (
                <OptionChip
                  key={preset.id}
                  selected={
                    summarizeQuietHours([
                      ...(notificationPreferences.filter((preference) => preference.channel === "push")),
                    ]) ===
                    (preset.start && preset.end
                      ? formatTimeRangeLabel(preset.start, preset.end, { compact: true })
                      : "No shared quiet hours")
                  }
                  onPress={() =>
                    void runAction(
                      `quiet-hours:${preset.id}`,
                      () => applyQuietHours(preset.start, preset.end),
                      "Quiet hours could not be updated.",
                    )
                  }
                >
                  {preset.label}
                </OptionChip>
              ))}
            </View>
          </Surface>
        </DetailSection>
        {timeBlockPreference ? (
          <DetailSection
            title="Before sessions"
            description="How early a session reminder should appear."
          >
            <Surface className="gap-3 mb-0">
              <View className="flex-row items-center justify-between gap-3">
                <View className="flex-1 gap-1">
                  <AppText variant="section">{formatReminderBehavior(timeBlockPreference)}</AppText>
                  <AppText tone="secondary" variant="caption">
                    {timeBlockPreference.enabled
                      ? "A heads-up before scheduled work begins."
                      : "No push reminder before scheduled sessions."}
                  </AppText>
                </View>
                <Button
                  size="compact"
                  tone={timeBlockPreference.enabled ? "tertiary" : "secondary"}
                  busy={busyState === `notification:${timeBlockPreference.id}`}
                  onPress={() =>
                    void runAction(
                      `notification:${timeBlockPreference.id}`,
                      () =>
                        updateNotificationPreference(timeBlockPreference.reminderType, {
                          enabled: !timeBlockPreference.enabled,
                        }),
                      "Notification preference could not be updated.",
                    )
                  }
                >
                  {timeBlockPreference.enabled ? "Mute" : "Enable"}
                </Button>
              </View>
              <View className="flex-row flex-wrap gap-2">
                {reminderLeadTimeOptions.map((minutes) => (
                  <OptionChip
                    key={minutes}
                    selected={timeBlockPreference.leadTimeMinutes === minutes}
                    onPress={() =>
                      void runAction(
                        `lead-time:${minutes}`,
                        () =>
                          updateNotificationPreference(timeBlockPreference.reminderType, {
                            enabled: true,
                            leadTimeMinutes: minutes,
                          }),
                        "Lead time could not be updated.",
                      )
                    }
                  >
                    {minutes} min
                  </OptionChip>
                ))}
              </View>
            </Surface>
          </DetailSection>
        ) : null}
        {weeklyReviewPreference && productPreferences ? (
          <DetailSection
            title="Weekly review"
            description="Control the reminder that opens weekly review and next-week shaping."
          >
            <Surface className="gap-3 mb-0">
              <View className="flex-row items-center justify-between gap-3">
                <View className="flex-1 gap-1">
                  <AppText variant="section">
                    {formatReminderBehavior(weeklyReviewPreference)}
                  </AppText>
                  <AppText tone="secondary" variant="caption">
                    {weeklyReviewPreference.enabled
                      ? `Scheduled for ${["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"][productPreferences.weeklyReviewDay]} at ${formatTimeLabel(productPreferences.weeklyReviewTime, { compact: true })}.`
                      : "Weekly review stays quiet until you enable this reminder again."}
                  </AppText>
                </View>
                <Button
                  size="compact"
                  tone={weeklyReviewPreference.enabled ? "tertiary" : "secondary"}
                  busy={busyState === `notification:${weeklyReviewPreference.id}`}
                  onPress={() =>
                    void runAction(
                      `notification:${weeklyReviewPreference.id}`,
                      () =>
                        updateNotificationPreference(weeklyReviewPreference.reminderType, {
                          enabled: !weeklyReviewPreference.enabled,
                        }),
                      "Weekly review reminder could not be updated.",
                    )
                  }
                >
                  {weeklyReviewPreference.enabled ? "Mute" : "Enable"}
                </Button>
              </View>
              <View className="flex-row flex-wrap gap-2">
                {reminderLeadTimeOptions.map((minutes) => (
                  <OptionChip
                    key={`weekly-review:${minutes}`}
                    selected={weeklyReviewPreference.leadTimeMinutes === minutes}
                    onPress={() =>
                      void runAction(
                        `lead-time:${weeklyReviewPreference.id}:${minutes}`,
                        () =>
                          updateNotificationPreference(weeklyReviewPreference.reminderType, {
                            enabled: true,
                            leadTimeMinutes: minutes,
                          }),
                        "Weekly review reminder timing could not be updated.",
                      )
                    }
                  >
                    {minutes} min
                  </OptionChip>
                ))}
              </View>
              <QuietMetaLine
                items={[
                  weeklyReviewPreference.channel === "push" ? "Push" : "In app",
                  weeklyReviewPreference.enabled ? "Active" : "Muted",
                  quietHoursSummary,
                ]}
              />
              <AppText tone="secondary" variant="caption">
                Review day and time are set in Planning. Delivery here stays on the real weekly review preference.
              </AppText>
            </Surface>
          </DetailSection>
        ) : null}
        {monthlyReviewPreference && productPreferences ? (
          <DetailSection
            title="Monthly review"
            description="Control the reminder that opens monthly review and next-month shaping."
          >
            <Surface className="gap-3 mb-0">
              <View className="flex-row items-center justify-between gap-3">
                <View className="flex-1 gap-1">
                  <AppText variant="section">
                    {formatReminderBehavior(monthlyReviewPreference)}
                  </AppText>
                  <AppText tone="secondary" variant="caption">
                    {monthlyReviewPreference.enabled
                      ? `Scheduled for day ${productPreferences.monthlyReviewDay} at ${formatTimeLabel(productPreferences.monthlyReviewTime, { compact: true })}.`
                      : "Monthly review stays quiet until you enable this reminder again."}
                  </AppText>
                </View>
                <Button
                  size="compact"
                  tone={monthlyReviewPreference.enabled ? "tertiary" : "secondary"}
                  busy={busyState === `notification:${monthlyReviewPreference.id}`}
                  onPress={() =>
                    void runAction(
                      `notification:${monthlyReviewPreference.id}`,
                      () =>
                        updateNotificationPreference(monthlyReviewPreference.reminderType, {
                          enabled: !monthlyReviewPreference.enabled,
                        }),
                      "Monthly review reminder could not be updated.",
                    )
                  }
                >
                  {monthlyReviewPreference.enabled ? "Mute" : "Enable"}
                </Button>
              </View>
              <View className="flex-row flex-wrap gap-2">
                {reminderLeadTimeOptions.map((minutes) => (
                  <OptionChip
                    key={`monthly-review:${minutes}`}
                    selected={monthlyReviewPreference.leadTimeMinutes === minutes}
                    onPress={() =>
                      void runAction(
                        `lead-time:${monthlyReviewPreference.id}:${minutes}`,
                        () =>
                          updateNotificationPreference(monthlyReviewPreference.reminderType, {
                            enabled: true,
                            leadTimeMinutes: minutes,
                          }),
                        "Monthly review reminder timing could not be updated.",
                      )
                    }
                  >
                    {minutes} min
                  </OptionChip>
                ))}
              </View>
              <QuietMetaLine
                items={[
                  monthlyReviewPreference.channel === "push" ? "Push" : "In app",
                  monthlyReviewPreference.enabled ? "Active" : "Muted",
                  quietHoursSummary,
                ]}
              />
              <AppText tone="secondary" variant="caption">
                Review day and time are set in Planning. Delivery here stays on the real monthly review preference.
              </AppText>
            </Surface>
          </DetailSection>
        ) : null}
        <DetailSection
          title="Daily rituals"
          description="Keep opening and closeout reminders quiet and deliberate."
        >
          <View className="gap-3">
            {[morningPreference, eveningPreference, recoveryPreference]
              .filter((preference): preference is NonNullable<typeof morningPreference> => Boolean(preference))
              .map((preference) => (
                <Surface key={preference.id} className="gap-3 mb-0">
                  <View className="flex-row items-center justify-between gap-3">
                    <View className="flex-1 gap-1">
                      <AppText variant="section">
                        {formatReminderTypeLabel(preference.reminderType)}
                      </AppText>
                      <AppText tone="secondary" variant="caption">
                        {formatReminderBehavior(preference)}
                      </AppText>
                    </View>
                    <Button
                      size="compact"
                      tone={preference.enabled ? "tertiary" : "secondary"}
                      busy={busyState === `notification:${preference.id}`}
                      onPress={() =>
                        void runAction(
                          `notification:${preference.id}`,
                          () =>
                            updateNotificationPreference(preference.reminderType, {
                              enabled: !preference.enabled,
                            }),
                          "Notification preference could not be updated.",
                        )
                      }
                    >
                      {preference.enabled ? "Mute" : "Enable"}
                    </Button>
                  </View>
                  {preference.reminderType !== ReminderType.RecoveryPrompt ? (
                    <View className="flex-row flex-wrap gap-2">
                      {ritualReminderLeadTimeOptions.map((minutes) => (
                        <OptionChip
                          key={`${preference.id}:${minutes}`}
                          selected={preference.leadTimeMinutes === minutes}
                          onPress={() =>
                            void runAction(
                              `lead-time:${preference.id}:${minutes}`,
                              () =>
                                updateNotificationPreference(preference.reminderType, {
                                  enabled: true,
                                  leadTimeMinutes: minutes,
                                }),
                              "Lead time could not be updated.",
                            )
                          }
                        >
                          {minutes === 0 ? "At time" : `${minutes} min`}
                        </OptionChip>
                      ))}
                    </View>
                  ) : null}
                  <QuietMetaLine
                    items={[
                      preference.channel === "push" ? "Push" : "In app",
                      preference.enabled ? "Active" : "Muted",
                      preference.reminderType === ReminderType.RecoveryPrompt
                        ? "Shown only when drift is detected"
                        : quietHoursSummary,
                    ]}
                  />
                </Surface>
              ))}
          </View>
        </DetailSection>
        <DetailSection
          title="Reminder types"
          description="What Ambitions is allowed to notify you about."
        >
          <View className="gap-3">
            {notificationPreferences.map((preference) => (
              <Surface key={preference.id} className="gap-3 mb-0">
                <View className="flex-row items-center justify-between gap-3">
                  <View className="flex-1 gap-1">
                    <AppText variant="section">{formatReminderTypeLabel(preference.reminderType)}</AppText>
                    <AppText tone="secondary" variant="caption">
                      {formatReminderBehavior(preference)}
                    </AppText>
                  </View>
                  <Button
                    size="compact"
                    tone={preference.enabled ? "tertiary" : "secondary"}
                    busy={busyState === `notification:${preference.id}`}
                    onPress={() =>
                      void runAction(
                        `notification:${preference.id}`,
                        () =>
                          updateNotificationPreference(preference.reminderType, {
                            enabled: !preference.enabled,
                          }),
                        "Notification preference could not be updated.",
                      )
                    }
                  >
                    {preference.enabled ? "Mute" : "Enable"}
                  </Button>
                </View>
                <QuietMetaLine
                  items={[
                    preference.channel === "push" ? "Push" : "In app",
                    preference.enabled ? "Active" : "Muted",
                    preference.channel === "push"
                      ? quietHoursSummary
                      : "Does not use quiet hours",
                  ]}
                />
              </Surface>
            ))}
          </View>
        </DetailSection>
        {runtimeMessage ? <AppText tone="tertiary" variant="caption">{runtimeMessage}</AppText> : null}
      </View>
    </Screen>
  );
}

export function ProfilePlanningPreferencesScreen() {
  const productPreferences = useAppStore((state) => state.productPreferences);
  const saveProductPreferences = useAppStore((state) => state.saveProductPreferences);
  const adaptationProfile = useAppStore((state) => state.adaptationProfile);
  const [busyState, setBusyState] = useState<string | null>(null);
  const [runtimeMessage, setRuntimeMessage] = useState<string | null>(null);
  const [weeklyReviewTime, setWeeklyReviewTime] = useState("4:30 PM");
  const [monthlyReviewTime, setMonthlyReviewTime] = useState("9:30 AM");

  useEffect(() => {
    if (!productPreferences) {
      return;
    }

    setWeeklyReviewTime(formatTimeLabel(productPreferences.weeklyReviewTime));
    setMonthlyReviewTime(formatTimeLabel(productPreferences.monthlyReviewTime));
  }, [productPreferences]);

  if (!productPreferences) {
    return (
      <Screen>
        <EmptyStateCard title="Preferences unavailable" body="Planning is still loading." />
      </Screen>
    );
  }

  const planningStyle = buildPlanningStyleSummary(
    adaptationProfile,
    productPreferences.adaptivePlanningEnabled,
  );
  const planningSummary = summarizePlanningControls(productPreferences, adaptationProfile);

  async function savePreference(
    key: string,
    next: NonNullable<typeof productPreferences>,
    fallbackError: string,
  ) {
    setBusyState(key);
    setRuntimeMessage(null);

    try {
      await saveProductPreferences(next);
    } catch (error) {
      setRuntimeMessage(error instanceof Error ? error.message : fallbackError);
    } finally {
      setBusyState(null);
    }
  }

  return (
    <Screen>
      <View className="gap-4">
        <DetailHero
          eyebrow="Planning"
          title={planningSummary.intensityLabel}
          description="Shape how assertive the planner should feel without dropping into low-level tuning."
          badges={
            <>
              <Pill label={planningSummary.taskLabel} tone="quiet" />
              <Pill label={planningSummary.adaptiveLabel} tone="accent" />
            </>
          }
          meta={
            <DetailSummaryStrip
              items={[
                {
                  label: "Plan weight",
                  value: planningSummary.intensityLabel,
                  detail: "How full the planner should build the day",
                },
                {
                  label: "Task shape",
                  value: planningSummary.taskLabel,
                  detail: "How granular planned work should feel",
                },
                {
                  label: "Unfinished work",
                  value: planningSummary.unfinishedWorkLabel,
                  detail: "Default closeout handling",
                },
                {
                  label: "Weekly carryover",
                  value: planningSummary.weeklyCarryoverLabel,
                  detail: "Default weekly carryover posture",
                },
              ]}
            />
          }
        />
        <DetailSection
          title="Adaptive planning"
          description="Choose whether recent behavior should tune the planner."
        >
          <Surface className="gap-3 mb-0">
            <AppText tone="secondary" variant="caption">
              {productPreferences.adaptivePlanningEnabled
                ? "Ambitions can quietly learn from recent completion, carryover, and pace."
                : "Planning stays on your explicit defaults, without behavior-based tuning."}
            </AppText>
          <View className="flex-row flex-wrap gap-2">
            {[
              [true, "Learn from history"],
              [false, "Keep defaults"],
            ].map(([enabled, label]) => (
              <OptionChip
                key={String(enabled)}
                selected={productPreferences.adaptivePlanningEnabled === enabled}
                onPress={() =>
                  void savePreference(
                    `adaptive:${enabled}`,
                    {
                      ...productPreferences,
                      adaptivePlanningEnabled: enabled as boolean,
                    },
                    "Adaptive planning could not be updated.",
                  )
                }
              >
                {label}
              </OptionChip>
            ))}
          </View>
          {planningStyle ? (
            <View className="gap-1 rounded-[20px] bg-black/5 px-4 py-4">
              <AppText tone="secondary" variant="caption">
                Current learned signal
              </AppText>
              <AppText variant="caption">{planningStyle.summary}</AppText>
            </View>
          ) : null}
          </Surface>
        </DetailSection>
        <DetailSection
          title="Weekly shaping"
          description="Set the weekly prompt and the default posture the planner should respect."
        >
          <Surface className="gap-3 mb-0">
            <AppText tone="secondary" variant="caption">
              Set when weekly review should happen here. Reminder delivery is controlled in Notifications, and next-week shaping can still be prompted automatically.
            </AppText>
            <View className="gap-2">
              <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                Review day
              </AppText>
              <View className="flex-row flex-wrap gap-2">
                {[
                  [0, "Sun"],
                  [1, "Mon"],
                  [2, "Tue"],
                  [3, "Wed"],
                  [4, "Thu"],
                  [5, "Fri"],
                  [6, "Sat"],
                ].map(([day, label]) => (
                  <OptionChip
                    key={String(day)}
                    selected={productPreferences.weeklyReviewDay === day}
                    onPress={() =>
                      void savePreference(
                        `weekly-day:${day}`,
                        { ...productPreferences, weeklyReviewDay: day as number },
                        "Weekly review day could not be updated.",
                      )
                    }
                  >
                    {label}
                  </OptionChip>
                ))}
              </View>
            </View>
            <TextField
              label="Review time"
              onChangeText={setWeeklyReviewTime}
              supportingText={`Currently ${formatTimeLabel(productPreferences.weeklyReviewTime, { compact: true })}`}
              value={weeklyReviewTime}
            />
            <Button
              busy={busyState === "weekly-time"}
              onPress={() => {
                const normalized = normalizeTimeString(weeklyReviewTime);
                void savePreference(
                  "weekly-time",
                  {
                    ...productPreferences,
                    weeklyReviewTime: normalized ?? productPreferences.weeklyReviewTime,
                  },
                  "Weekly review time could not be updated.",
                );
              }}
            >
              Save weekly review time
            </Button>
            <View className="gap-2">
              <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                Next-week prompt
              </AppText>
              <View className="flex-row flex-wrap gap-2">
                {[
                  [true, "Prompt automatically"],
                  [false, "Manual only"],
                ].map(([enabled, label]) => (
                  <OptionChip
                    key={`weekly-prompt:${String(enabled)}`}
                    selected={productPreferences.autoPromptNextWeekShaping === enabled}
                    onPress={() =>
                      void savePreference(
                        `weekly-prompt:${enabled}`,
                        {
                          ...productPreferences,
                          autoPromptNextWeekShaping: enabled as boolean,
                        },
                        "Next-week shaping prompt could not be updated.",
                      )
                    }
                  >
                    {label}
                  </OptionChip>
                ))}
              </View>
            </View>
            <View className="gap-2">
              <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                Default weekly carryover
              </AppText>
              <View className="flex-row flex-wrap gap-2">
                {[
                  ["essentials_only", "Carry only essentials"],
                  ["review_first", "Review first"],
                  ["aggressive", "Carry more forward"],
                ].map(([key, label]) => (
                  <OptionChip
                    key={key}
                    selected={productPreferences.defaultWeeklyCarryoverBehavior === key}
                    onPress={() =>
                      void savePreference(
                        `weekly-carry:${key}`,
                        {
                          ...productPreferences,
                          defaultWeeklyCarryoverBehavior:
                            key as typeof productPreferences.defaultWeeklyCarryoverBehavior,
                        },
                        "Weekly carryover posture could not be updated.",
                      )
                    }
                  >
                    {label}
                  </OptionChip>
                ))}
              </View>
            </View>
          </Surface>
        </DetailSection>
        <DetailSection
          title="Monthly steering"
          description="Set the month-level review cadence and default strategic posture."
        >
          <Surface className="gap-3 mb-0">
            <AppText tone="secondary" variant="caption">
              Monthly review steers the week without replacing weekly shaping. Reminder delivery stays in Notifications.
            </AppText>
            <View className="gap-2">
              <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                Review day
              </AppText>
              <View className="flex-row flex-wrap gap-2">
                {[1, 2, 3, 4, 5, 7, 10].map((day) => (
                  <OptionChip
                    key={`monthly-day:${day}`}
                    selected={productPreferences.monthlyReviewDay === day}
                    onPress={() =>
                      void savePreference(
                        `monthly-day:${day}`,
                        { ...productPreferences, monthlyReviewDay: day },
                        "Monthly review day could not be updated.",
                      )
                    }
                  >
                    Day {day}
                  </OptionChip>
                ))}
              </View>
            </View>
            <TextField
              label="Monthly review time"
              onChangeText={setMonthlyReviewTime}
              supportingText={`Currently ${formatTimeLabel(productPreferences.monthlyReviewTime, { compact: true })}`}
              value={monthlyReviewTime}
            />
            <Button
              busy={busyState === "monthly-time"}
              onPress={() => {
                const normalized = normalizeTimeString(monthlyReviewTime);
                void savePreference(
                  "monthly-time",
                  {
                    ...productPreferences,
                    monthlyReviewTime: normalized ?? productPreferences.monthlyReviewTime,
                  },
                  "Monthly review time could not be updated.",
                );
              }}
            >
              Save monthly review time
            </Button>
            <View className="gap-2">
              <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                Next-month prompt
              </AppText>
              <View className="flex-row flex-wrap gap-2">
                {[
                  [true, "Prompt automatically"],
                  [false, "Manual only"],
                ].map(([enabled, label]) => (
                  <OptionChip
                    key={`monthly-prompt:${String(enabled)}`}
                    selected={productPreferences.autoPromptNextMonthShaping === enabled}
                    onPress={() =>
                      void savePreference(
                        `monthly-prompt:${enabled}`,
                        {
                          ...productPreferences,
                          autoPromptNextMonthShaping: enabled as boolean,
                        },
                        "Next-month shaping prompt could not be updated.",
                      )
                    }
                  >
                    {label}
                  </OptionChip>
                ))}
              </View>
            </View>
            <View className="gap-2">
              <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                Default posture
              </AppText>
              <View className="flex-row flex-wrap gap-2">
                {[
                  ["stabilize", "Stabilize"],
                  ["build_momentum", "Build momentum"],
                  ["push_output", "Push output"],
                ].map(([key, label]) => (
                  <OptionChip
                    key={`monthly-posture:${key}`}
                    selected={productPreferences.defaultMonthlyPosture === key}
                    onPress={() =>
                      void savePreference(
                        `monthly-posture:${key}`,
                        {
                          ...productPreferences,
                          defaultMonthlyPosture: key as typeof productPreferences.defaultMonthlyPosture,
                        },
                        "Monthly posture could not be updated.",
                      )
                    }
                  >
                    {label}
                  </OptionChip>
                ))}
              </View>
            </View>
            <View className="gap-2">
              <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                Default emphasis
              </AppText>
              <View className="flex-row flex-wrap gap-2">
                {[
                  ["protect_essentials", "Protect essentials"],
                  ["deepen_one_priority_area", "Deepen one area"],
                  ["rebalance_neglected_areas", "Rebalance neglected areas"],
                ].map(([key, label]) => (
                  <OptionChip
                    key={`monthly-emphasis:${key}`}
                    selected={productPreferences.defaultMonthlyEmphasis === key}
                    onPress={() =>
                      void savePreference(
                        `monthly-emphasis:${key}`,
                        {
                          ...productPreferences,
                          defaultMonthlyEmphasis: key as typeof productPreferences.defaultMonthlyEmphasis,
                        },
                        "Monthly emphasis could not be updated.",
                      )
                    }
                  >
                    {label}
                  </OptionChip>
                ))}
              </View>
            </View>
            <View className="gap-2">
              <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                Default pressure
              </AppText>
              <View className="flex-row flex-wrap gap-2">
                {[
                  ["lighter", "Lighter"],
                  ["balanced", "Balanced"],
                  ["fuller", "Fuller"],
                ].map(([key, label]) => (
                  <OptionChip
                    key={`monthly-pressure:${key}`}
                    selected={productPreferences.defaultMonthlyPressure === key}
                    onPress={() =>
                      void savePreference(
                        `monthly-pressure:${key}`,
                        {
                          ...productPreferences,
                          defaultMonthlyPressure: key as typeof productPreferences.defaultMonthlyPressure,
                        },
                        "Monthly pressure could not be updated.",
                      )
                    }
                  >
                    {label}
                  </OptionChip>
                ))}
              </View>
            </View>
            <View className="gap-2">
              <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                Carryover stance
              </AppText>
              <View className="flex-row flex-wrap gap-2">
                {[
                  ["prune_aggressively", "Prune aggressively"],
                  ["review_before_carrying", "Review before carrying"],
                  ["tolerate_more_carryover", "Tolerate more carryover"],
                ].map(([key, label]) => (
                  <OptionChip
                    key={`monthly-carry:${key}`}
                    selected={productPreferences.defaultMonthlyCarryoverStance === key}
                    onPress={() =>
                      void savePreference(
                        `monthly-carry:${key}`,
                        {
                          ...productPreferences,
                          defaultMonthlyCarryoverStance:
                            key as typeof productPreferences.defaultMonthlyCarryoverStance,
                        },
                        "Monthly carryover stance could not be updated.",
                      )
                    }
                  >
                    {label}
                  </OptionChip>
                ))}
              </View>
            </View>
          </Surface>
        </DetailSection>

        <DetailSection
          title="Closeout default"
          description="Choose what unfinished work should do when you close the day."
        >
          <Surface className="gap-3 mb-0">
            <AppText tone="secondary" variant="caption">
              {planningSummary.unfinishedWorkLabel}
            </AppText>
            <View className="gap-2">
              {unfinishedWorkBehaviorOptions.map((option) => (
                <OptionChip
                  key={option.id}
                  selected={productPreferences.defaultUnfinishedWorkBehavior === option.id}
                  onPress={() =>
                    void savePreference(
                      `unfinished:${option.id}`,
                      {
                        ...productPreferences,
                        defaultUnfinishedWorkBehavior: option.id,
                      },
                      "The closeout default could not be updated.",
                    )
                  }
                >
                  {option.label}
                </OptionChip>
              ))}
            </View>
            <AppText tone="secondary" variant="caption">
              {
                unfinishedWorkBehaviorOptions.find(
                  (option) => option.id === productPreferences.defaultUnfinishedWorkBehavior,
                )?.description
              }
            </AppText>
          </Surface>
        </DetailSection>
        <DetailSection
          title="Task size"
          description="Decide whether plans should break down into shorter steps or deeper blocks."
        >
          <Surface className="gap-3 mb-0">
          <View className="flex-row flex-wrap gap-2">
            {[
              ["smaller", "Shorter steps"],
              ["mixed", "Mixed"],
              ["bigger", "Deeper blocks"],
            ].map(([key, label]) => (
              <OptionChip
                key={key}
                selected={productPreferences.taskSizing === key}
                onPress={() =>
                  void savePreference(
                    `task-sizing:${key}`,
                    { ...productPreferences, taskSizing: key as typeof productPreferences.taskSizing },
                    "Task sizing could not be updated.",
                  )
                }
              >
                {label}
              </OptionChip>
            ))}
          </View>
          </Surface>
        </DetailSection>
        <DetailSection
          title="Day intensity"
          description="Control how much pressure the planner should put into a normal day."
        >
          <Surface className="gap-3 mb-0">
          <View className="flex-row flex-wrap gap-2">
            {[
              ["light", "Lighter plans"],
              ["balanced", "Balanced"],
              ["ambitious", "Fuller plans"],
            ].map(([key, label]) => (
              <OptionChip
                key={key}
                selected={productPreferences.dayIntensity === key}
                onPress={() =>
                  void savePreference(
                    `day-intensity:${key}`,
                    { ...productPreferences, dayIntensity: key as typeof productPreferences.dayIntensity },
                    "Day intensity could not be updated.",
                  )
                }
              >
                {label}
              </OptionChip>
            ))}
          </View>
          </Surface>
        </DetailSection>
        <Surface className="gap-3">
          <AppText variant="section">Still automatic</AppText>
          <AppText tone="secondary" variant="caption">
            Ambitions still decides exact task ordering, recovery reshaping details, most open-time recommendations, and the final daily fill level automatically.
          </AppText>
        </Surface>
        {busyState ? <AppText tone="tertiary" variant="caption">Saving...</AppText> : null}
        {runtimeMessage ? <AppText tone="tertiary" variant="caption">{runtimeMessage}</AppText> : null}
      </View>
    </Screen>
  );
}

type AuthMode = "create" | "sign_in";
type AccountFieldKey = "displayName" | "email" | "password";
const AUTH_RATE_LIMIT_COOLDOWN_MS = 30_000;

function validateEmail(value: string) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value.trim());
}

function getFieldValidationState({
  valid,
  touched,
  value,
}: {
  valid: boolean;
  touched: boolean;
  value: string;
}) {
  if (valid && value.trim().length > 0) {
    return "success" as const;
  }

  if (touched && value.trim().length > 0) {
    return "error" as const;
  }

  return "default" as const;
}

function RequirementRow({
  label,
  met,
}: {
  label: string;
  met: boolean;
}) {
  const theme = useResolvedTheme();

  return (
    <View className="flex-row items-center gap-2">
      <Ionicons
        color={met ? theme.colors.semantic.success : theme.colors.text.tertiary}
        name={met ? "checkmark-circle" : "ellipse-outline"}
        size={15}
      />
      <AppText
        tone={met ? "primary" : "secondary"}
        variant="caption"
        style={met ? { color: theme.colors.semantic.success } : undefined}
      >
        {label}
      </AppText>
    </View>
  );
}

function AuthReadyBadge({
  mode,
}: {
  mode: AuthMode;
}) {
  const theme = useResolvedTheme();

  return (
    <View
      className="flex-row items-center gap-2 rounded-[18px] px-3 py-3"
      style={{
        backgroundColor:
          theme.mode === "dark" ? "rgba(142,168,131,0.14)" : "rgba(111,133,102,0.1)",
        borderWidth: 1,
        borderColor: theme.colors.semantic.success,
      }}
    >
      <Ionicons color={theme.colors.semantic.success} name="checkmark-circle" size={18} />
      <AppText tone="primary" variant="caption">
        {mode === "create" ? "Ready to create your account" : "Ready to sign in"}
      </AppText>
    </View>
  );
}

function AuthFeedbackCard({
  feedback,
  detail,
}: {
  feedback: AuthFeedback;
  detail?: string;
}) {
  const theme = useResolvedTheme();
  const isInfo = feedback.kind === "info";

  return (
    <View
      className="gap-2 rounded-[20px] px-4 py-4"
      style={{
        backgroundColor: isInfo
          ? theme.mode === "dark"
            ? "rgba(142,168,131,0.14)"
            : "rgba(111,133,102,0.08)"
          : theme.mode === "dark"
            ? "rgba(193,154,116,0.14)"
            : "rgba(165,128,89,0.08)",
        borderWidth: 1,
        borderColor: isInfo ? theme.colors.semantic.success : theme.colors.semantic.warning,
      }}
    >
      <AppText variant="caption">
        {feedback.code === "confirmation_required"
          ? "Check your email"
          : feedback.code === "email_exists"
            ? "Account already exists"
            : "Couldn’t continue"}
      </AppText>
      <AppText tone="secondary" variant="caption">
        {feedback.message}
      </AppText>
      {detail ? (
        <AppText tone="tertiary" variant="caption">
          {detail}
        </AppText>
      ) : null}
    </View>
  );
}

export function ProfileAccountScreen() {
  const account = useAppStore((state) => state.account);
  const authState = useAppStore((state) => state.authState);
  const attachmentState = useAppStore((state) => state.attachmentState);
  const syncState = useAppStore((state) => state.syncState);
  const syncConflicts = useAppStore((state) => state.syncConflicts);
  const createAccount = useAppStore((state) => state.createAccount);
  const signIn = useAppStore((state) => state.signIn);
  const clearAuthFeedback = useAppStore((state) => state.clearAuthFeedback);
  const signOut = useAppStore((state) => state.signOut);
  const attachLocalDataToAccount = useAppStore((state) => state.attachLocalDataToAccount);
  const deferLocalDataAttachment = useAppStore((state) => state.deferLocalDataAttachment);
  const syncAccountData = useAppStore((state) => state.syncAccountData);
  const theme = useResolvedTheme();
  const insets = useSafeAreaInsets();
  const [accountBusy, setAccountBusy] = useState<string | null>(null);
  const [accountActionMessage, setAccountActionMessage] = useState<string | null>(null);
  const [authFeedback, setAuthFeedback] = useState<AuthFeedback | null>(null);
  const [authCooldownUntil, setAuthCooldownUntil] = useState<number | null>(null);
  const [authCooldownRemainingMs, setAuthCooldownRemainingMs] = useState(0);
  const [authMode, setAuthMode] = useState<AuthMode>("create");
  const [displayName, setDisplayName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [touchedFields, setTouchedFields] = useState<Record<AccountFieldKey, boolean>>({
    displayName: false,
    email: false,
    password: false,
  });
  const [keyboardInset, setKeyboardInset] = useState(0);
  const [focusedField, setFocusedField] = useState<AccountFieldKey | null>(null);
  const scrollRef = useRef<ScrollView>(null);
  const nameInputRef = useRef<TextInput>(null);
  const emailInputRef = useRef<TextInput>(null);
  const passwordInputRef = useRef<TextInput>(null);
  const fieldOffsets = useRef<Partial<Record<AccountFieldKey, number>>>({});
  const authConfigured = isSupabaseConfigured();

  useEffect(() => {
    const showEvent = Platform.OS === "ios" ? "keyboardWillShow" : "keyboardDidShow";
    const hideEvent = Platform.OS === "ios" ? "keyboardWillHide" : "keyboardDidHide";
    const showSubscription = Keyboard.addListener(showEvent, (event) => {
      setKeyboardInset(event.endCoordinates.height);
      if (focusedField) {
        requestAnimationFrame(() => {
          const top = fieldOffsets.current[focusedField] ?? 0;
          scrollRef.current?.scrollTo({
            y: Math.max(0, top - 28),
            animated: true,
          });
        });
      }
    });
    const hideSubscription = Keyboard.addListener(hideEvent, () => {
      setKeyboardInset(0);
    });

    return () => {
      showSubscription.remove();
      hideSubscription.remove();
    };
  }, [focusedField]);

  useEffect(() => {
    if (account) {
      setAccountActionMessage(null);
      setAuthFeedback(null);
      setAuthCooldownUntil(null);
      setAuthCooldownRemainingMs(0);
    }
  }, [account]);

  useEffect(() => {
    if (!authCooldownUntil) {
      setAuthCooldownRemainingMs(0);
      return;
    }

    const updateRemaining = () => {
      const nextRemaining = Math.max(0, authCooldownUntil - Date.now());
      setAuthCooldownRemainingMs(nextRemaining);

      if (nextRemaining === 0) {
        setAuthCooldownUntil(null);
      }
    };

    updateRemaining();
    const interval = setInterval(updateRemaining, 250);

    return () => {
      clearInterval(interval);
    };
  }, [authCooldownUntil]);

  async function runAccountAction(
    key: string,
    action: () => Promise<void>,
    fallbackError: string,
  ) {
    setAccountBusy(key);
    setAccountActionMessage(null);

    try {
      await action();
    } catch (error) {
      setAccountActionMessage(error instanceof Error ? error.message : fallbackError);
    } finally {
      setAccountBusy(null);
    }
  }

  function clearAuthSurfaceFeedback() {
    if (!(authFeedback?.code === "rate_limited" && authCooldownRemainingMs > 0)) {
      setAuthFeedback(null);
    }
    if (authState?.lastError || authState?.status === "error") {
      void clearAuthFeedback();
    }
  }

  function markTouched(field: AccountFieldKey) {
    setTouchedFields((current) => ({
      ...current,
      [field]: true,
    }));
  }

  function registerFieldOffset(field: AccountFieldKey, event: LayoutChangeEvent) {
    fieldOffsets.current[field] = event.nativeEvent.layout.y;
  }

  function focusField(field: AccountFieldKey) {
    setFocusedField(field);
    requestAnimationFrame(() => {
      const top = fieldOffsets.current[field] ?? 0;
      scrollRef.current?.scrollTo({
        y: Math.max(0, top - 28),
        animated: true,
      });
    });
  }

  function handleSubmitEditing(field: AccountFieldKey) {
    if (field === "displayName") {
      emailInputRef.current?.focus();
      return;
    }

    if (field === "email") {
      passwordInputRef.current?.focus();
      return;
    }

    if (field === "password" && canAttemptAuth && authConfigured) {
      void submitAuth();
    }
  }

  async function submitAuth() {
    if (accountBusy === "auth" || authCooldownRemainingMs > 0) {
      return;
    }

    setTouchedFields({
      displayName: true,
      email: true,
      password: true,
    });

    if (!canSubmitAuth || !authConfigured) {
      return;
    }

    setAccountBusy("auth");
    setAuthFeedback(null);
    setAccountActionMessage(null);

    try {
      const result =
        authMode === "create"
          ? await createAccount({
              email: email.trim(),
              password,
              displayName: displayName.trim(),
            })
          : await signIn({
              email: email.trim(),
              password,
            });

      if (result.feedback) {
        setAuthFeedback(result.feedback);

        if (result.feedback.code === "rate_limited") {
          setAuthCooldownUntil(Date.now() + AUTH_RATE_LIMIT_COOLDOWN_MS);
        }

        if (result.feedback.suggestedMode === "sign_in") {
          setAuthMode("sign_in");
          setTouchedFields({
            displayName: false,
            email: true,
            password: false,
          });
          setDisplayName("");
          setPassword("");
        }
      }
    } catch (error) {
      setAuthFeedback({
        kind: "error",
        code: "unknown",
        message:
          error instanceof Error
            ? error.message
            : authMode === "create"
              ? "Couldn’t create your account. Try again."
              : "Couldn’t sign in. Try again.",
      });
    } finally {
      setAccountBusy(null);
    }
  }

  const nameValid = displayName.trim().length > 0;
  const emailValid = validateEmail(email);
  const passwordValid = password.trim().length >= 8;
  const canSubmitAuth =
    emailValid && passwordValid && (authMode === "sign_in" || nameValid);
  const isAuthCoolingDown = authCooldownRemainingMs > 0;
  const cooldownSeconds = Math.max(1, Math.ceil(authCooldownRemainingMs / 1000));
  const canAttemptAuth = canSubmitAuth && accountBusy !== "auth" && !isAuthCoolingDown;
  const nameFieldState =
    authMode === "create"
      ? getFieldValidationState({
          valid: nameValid,
          touched: touchedFields.displayName,
          value: displayName,
        })
      : "default";
  const emailFieldState = getFieldValidationState({
    valid: emailValid,
    touched: touchedFields.email,
    value: email,
  });
  const passwordFieldState = getFieldValidationState({
    valid: passwordValid,
    touched: touchedFields.password,
    value: password,
  });
  const modeDescription =
    authMode === "create"
      ? "Keep plans, history, and settings available across devices."
      : "Pick up your account on this device.";
  const unavailableMessage =
    authState?.lastError ?? "Connection unavailable right now.";
  const authFeedbackDetail =
    authFeedback?.code === "rate_limited" && isAuthCoolingDown
      ? `You can try again in ${cooldownSeconds}s.`
      : undefined;
  const authButtonLabel =
    isAuthCoolingDown
      ? `Try again in ${cooldownSeconds}s`
      : authMode === "create"
        ? "Create account"
        : "Sign in";
  const syncSummary = summarizeSyncState({
    syncState,
    attachmentState,
    conflicts: syncConflicts,
  });
  const pendingChangeCount =
    (syncState?.pendingPushCount ?? 0) + (syncState?.pendingPullCount ?? 0);

  return (
    <KeyboardAvoidingView
      behavior={Platform.OS === "ios" ? "padding" : undefined}
      keyboardVerticalOffset={Platform.OS === "ios" ? 8 : 0}
      style={{ flex: 1, backgroundColor: theme.colors.background.canvas }}
    >
      <ScrollView
        ref={scrollRef}
        keyboardDismissMode={Platform.OS === "ios" ? "interactive" : "on-drag"}
        keyboardShouldPersistTaps="handled"
        showsVerticalScrollIndicator={false}
        contentContainerStyle={{
          paddingTop: insets.top + 10,
          paddingBottom: Math.max(insets.bottom + 24, keyboardInset + 24),
          paddingHorizontal: 16,
        }}
      >
        <View className="gap-4">
          <DetailHero
            eyebrow="Account"
            title={account ? syncSummary.headline : "Local profile"}
            description={
              account
                ? syncSummary.detail
                : "Keep everything on this device, or connect an account when you want cross-device syncing."
            }
            badges={
              <>
                <Pill label={account ? "Connected account" : "Local only"} tone="accent" />
                <Pill
                  label={attachmentState?.status === "attached" ? "Device attached" : "Device not attached"}
                  tone="quiet"
                />
              </>
            }
            meta={
              <DetailSummaryStrip
                items={[
                  {
                    label: "Sync",
                    value: account ? syncSummary.headline : "Local only",
                    detail: account
                      ? syncState?.lastSyncAt
                        ? `Last sync ${formatShortDateTime(syncState.lastSyncAt)}`
                        : "No completed sync yet"
                      : "Nothing is being sent to an account",
                  },
                  {
                    label: "Pending",
                    value: String(pendingChangeCount),
                    detail:
                      pendingChangeCount > 0
                        ? "Changes waiting to move"
                        : "No pending sync work",
                  },
                ]}
              />
            }
          />
          <AccountStatusCard
            account={account}
            authState={authState}
            attachmentState={attachmentState}
            syncState={syncState}
            conflicts={syncConflicts}
            busyAction={
              accountBusy === "attach" ||
              accountBusy === "sync" ||
              accountBusy === "defer" ||
              accountBusy === "sign_out"
                ? (accountBusy as "attach" | "sync" | "defer" | "sign_out")
                : null
            }
            onAttach={() =>
              void runAccountAction(
                "attach",
                attachLocalDataToAccount,
                "Couldn’t bring this device’s data into your account.",
              )
            }
            onDefer={() =>
              void runAccountAction(
                "defer",
                deferLocalDataAttachment,
                "Couldn’t keep this device in local-only mode.",
              )
            }
            onSync={() =>
              void runAccountAction("sync", () => syncAccountData(), "Couldn’t sync right now.")
            }
            onSignOut={() =>
              void runAccountAction("sign_out", signOut, "Couldn’t sign out right now.")
            }
          />
          <DetailSection
            title="What syncs"
            description="Only real surfaces Ambitions can currently carry between devices."
          >
            <Surface className="gap-3 mb-0">
              <QuietMetaLine
                items={
                  attachmentState?.status === "attached"
                    ? ["Goals", "Plans", "History", "Preferences", "Notification settings"]
                    : ["Everything stays local until this device is attached to an account"]
                }
              />
              <AppText tone="secondary" variant="caption">
                {attachmentState?.status === "attached"
                  ? "Local device state and connected account state are linked for these surfaces."
                  : "You can sign in without immediately uploading local data. Attachment stays explicit."}
              </AppText>
            </Surface>
          </DetailSection>
          {account ? (
            <DetailSection
              title="Current state"
              description="A compact read of connection health."
            >
              <Surface className="gap-3 mb-0">
                <DetailMetaGroup
                  items={[
                    {
                      label: "Mode",
                      value: syncSummary.headline,
                    },
                    {
                      label: "Conflicts",
                      value: String(syncConflicts.length),
                    },
                    {
                      label: "Uploads",
                      value: String(syncState?.pendingPushCount ?? 0),
                    },
                    {
                      label: "Downloads",
                      value: String(syncState?.pendingPullCount ?? 0),
                    },
                  ]}
                />
                {syncState?.lastError ? (
                  <AppText tone="secondary" variant="caption">
                    {syncState.lastError}
                  </AppText>
                ) : null}
              </Surface>
            </DetailSection>
          ) : null}
          {!account ? (
            !authConfigured ? (
              <Surface className="gap-4">
                <View className="gap-2">
                  <AppText variant="section">Account connection unavailable</AppText>
                  <AppText tone="secondary">
                    This build can keep your data local, but account connection has not been configured yet.
                  </AppText>
                </View>
                <View
                  className="rounded-[20px] px-4 py-4"
                  style={{
                    backgroundColor: theme.colors.background.elevatedSecondary,
                    borderWidth: 1,
                    borderColor: theme.colors.border.subtle,
                  }}
                >
                  <AppText tone="secondary" variant="caption">
                    {unavailableMessage}
                  </AppText>
                </View>
              </Surface>
            ) : (
              <Surface className="gap-4">
                <View className="gap-3">
                  <AppText variant="section">Connect an account</AppText>
                  <AppText tone="secondary" variant="caption">
                    {modeDescription}
                  </AppText>
                  <SegmentedControl
                    value={authMode}
                    options={[
                      { value: "create", label: "Create account" },
                      { value: "sign_in", label: "Sign in" },
                    ]}
                    onChange={(value) => {
                      setAuthMode(value);
                      setTouchedFields({
                        displayName: false,
                        email: false,
                        password: false,
                      });
                      clearAuthSurfaceFeedback();
                    }}
                  />
                </View>
                {authFeedback ? (
                  <AuthFeedbackCard feedback={authFeedback} detail={authFeedbackDetail} />
                ) : null}
                {authMode === "create" ? (
                  <View
                    onLayout={(event) => registerFieldOffset("displayName", event)}
                  >
                    <TextField
                      ref={nameInputRef}
                      autoCapitalize="words"
                      autoCorrect={false}
                      label="Name"
                      onBlur={() => markTouched("displayName")}
                      onChangeText={(value) => {
                        setDisplayName(value);
                        clearAuthSurfaceFeedback();
                      }}
                      onFocus={() => focusField("displayName")}
                      onSubmitEditing={() => handleSubmitEditing("displayName")}
                      placeholder="Your name"
                      returnKeyType="next"
                      supportingText={
                        touchedFields.displayName && !nameValid ? "Enter your name." : undefined
                      }
                      validationState={nameFieldState}
                      value={displayName}
                    />
                  </View>
                ) : null}
                <View onLayout={(event) => registerFieldOffset("email", event)}>
                  <TextField
                    ref={emailInputRef}
                    autoCapitalize="none"
                    autoCorrect={false}
                    keyboardType="email-address"
                    label="Email"
                    onBlur={() => markTouched("email")}
                    onChangeText={(value) => {
                      setEmail(value);
                      clearAuthSurfaceFeedback();
                    }}
                    onFocus={() => focusField("email")}
                    onSubmitEditing={() => handleSubmitEditing("email")}
                    placeholder="you@example.com"
                    returnKeyType="next"
                    supportingText={
                      touchedFields.email && !emailValid ? "Enter a valid email address." : undefined
                    }
                    validationState={emailFieldState}
                    value={email}
                  />
                </View>
                <View onLayout={(event) => registerFieldOffset("password", event)}>
                  <TextField
                    ref={passwordInputRef}
                    autoCapitalize="none"
                    autoCorrect={false}
                    label="Password"
                    onBlur={() => markTouched("password")}
                    onChangeText={(value) => {
                      setPassword(value);
                      clearAuthSurfaceFeedback();
                    }}
                    onFocus={() => focusField("password")}
                    onSubmitEditing={() => handleSubmitEditing("password")}
                    placeholder="At least 8 characters"
                    returnKeyType={canAttemptAuth ? "go" : "done"}
                    secureTextEntry
                    supportingText={
                      touchedFields.password && !passwordValid
                        ? "Use at least 8 characters."
                        : undefined
                    }
                    validationState={passwordFieldState}
                    value={password}
                  />
                </View>
                <View
                  className="gap-2 rounded-[22px] px-4 py-4"
                  style={{
                    backgroundColor: theme.colors.background.elevatedSecondary,
                    borderWidth: 1,
                    borderColor: canSubmitAuth
                      ? theme.colors.semantic.success
                      : theme.colors.border.subtle,
                  }}
                >
                  <AppText variant="caption">
                    {authMode === "create" ? "Requirements" : "Ready to sign in"}
                  </AppText>
                  {authMode === "create" ? (
                    <RequirementRow label="Name required" met={nameValid} />
                  ) : null}
                  <RequirementRow label="Valid email" met={emailValid} />
                  <RequirementRow label="At least 8 characters" met={passwordValid} />
                </View>
                {canSubmitAuth ? <AuthReadyBadge mode={authMode} /> : null}
                <View className="gap-3">
                  <Button
                    busy={accountBusy === "auth"}
                    disabled={!canAttemptAuth}
                    onPress={() => void submitAuth()}
                    style={{ width: "100%" }}
                  >
                    {authButtonLabel}
                  </Button>
                  <Button
                    tone="inline"
                    onPress={() => {
                      setAuthMode(authMode === "create" ? "sign_in" : "create");
                      setTouchedFields({
                        displayName: false,
                        email: false,
                        password: false,
                      });
                      clearAuthSurfaceFeedback();
                    }}
                  >
                    {authMode === "create" ? "Already have an account? Sign in" : "Need an account? Create one"}
                  </Button>
                </View>
              </Surface>
            )
          ) : null}
          {accountActionMessage && (account || authConfigured) ? (
            <Surface
              tone="sunken"
              className="gap-2"
              style={{
                borderColor: theme.colors.semantic.warning,
              }}
            >
              <AppText variant="caption">Couldn&apos;t complete that action</AppText>
              <AppText tone="secondary" variant="caption">
                {accountActionMessage}
              </AppText>
            </Surface>
          ) : null}
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}
