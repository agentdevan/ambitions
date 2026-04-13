import { useScrollToTop } from "@react-navigation/native";
import { NativeStackScreenProps } from "@react-navigation/native-stack";
import { Ionicons } from "@expo/vector-icons";
import { useMemo, useRef } from "react";
import { View } from "react-native";
import { useShallow } from "zustand/react/shallow";

import {
  DetailSection,
  DetailSummaryStrip,
  QuietMetaLine,
} from "../../components/detail/DetailPrimitives";
import { DrillInRow } from "../../components/navigation/DrillInRow";
import { PageHeader } from "../../components/navigation/PageHeader";
import { Button } from "../../components/ui/Button";
import { EmptyStateCard } from "../../components/ui/EmptyStateCard";
import { Pill } from "../../components/ui/Pill";
import { Screen } from "../../components/ui/Screen";
import { Surface } from "../../components/ui/Surface";
import { AppText } from "../../components/ui/Text";
import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
import { buildActivityFeed, summarizeInsights } from "../../services/history/selectors";
import {
  formatMonthlyReviewCadenceShort,
  summarizeCalendarControl,
  summarizePlanningControls,
  summarizeQuietHours,
  summarizeSyncState,
} from "../../services/profile/controlSummaries";
import { useAppStore } from "../../state/useAppStore";
import { formatTimeRangeLabel } from "../../utils/date";
import { ProfileStackParamList } from "../../navigation/types";

type Props = NativeStackScreenProps<ProfileStackParamList, "ProfileHome">;

export function ProfileScreen({ navigation }: Props) {
  const scrollRef = useRef<any>(null);
  useScrollToTop(scrollRef);
  const {
    productPreferences,
    notificationPreferences,
    calendarConnectionState,
    account,
    attachmentState,
    syncState,
    syncConflicts,
    scheduleConstraints,
    today,
    goals,
    milestones,
    tasks,
    activityEvents,
    adaptationProfile,
  } = useAppStore(
    useShallow((state) => ({
      productPreferences: state.productPreferences,
      notificationPreferences: state.notificationPreferences,
      calendarConnectionState: state.calendarConnectionState,
      account: state.account,
      attachmentState: state.attachmentState,
      syncState: state.syncState,
      syncConflicts: state.syncConflicts,
      scheduleConstraints: state.scheduleConstraints,
      today: state.today,
      goals: state.goals,
      milestones: state.milestones,
      tasks: state.allTasks,
      activityEvents: state.activityEvents,
      adaptationProfile: state.adaptationProfile,
    })),
  );
  const theme = useResolvedTheme();

  if (!productPreferences) {
    return (
      <Screen ref={scrollRef}>
        <EmptyStateCard
          eyebrow="Preparing"
          title="Profile is loading"
          body="Settings, trust state, and defaults will appear in a moment."
        />
      </Screen>
    );
  }

  const enabledNotifications = notificationPreferences.filter((item) => item.enabled).length;
  const quietHoursSummary = summarizeQuietHours(notificationPreferences);
  const activityFeed = useMemo(
    () => buildActivityFeed(activityEvents, tasks, milestones),
    [activityEvents, milestones, tasks],
  );
  const reflectionSummary = useMemo(
    () =>
      summarizeInsights({
        goals,
        tasks,
        milestones,
        events: activityFeed,
        profile: adaptationProfile,
        adaptiveEnabled: productPreferences.adaptivePlanningEnabled,
      }),
    [activityFeed, adaptationProfile, goals, milestones, productPreferences.adaptivePlanningEnabled, tasks],
  );
  const planningSummary = summarizePlanningControls(
    productPreferences,
    adaptationProfile,
  );
  const calendarSummary = summarizeCalendarControl({
    connectionState: calendarConnectionState,
    scheduleConstraints,
    usingLiveCalendar: today?.integration.usingLiveCalendar ?? false,
  });
  const accountSummary = summarizeSyncState({
    syncState,
    attachmentState,
    conflicts: syncConflicts,
  });
  const appearanceDetail =
    productPreferences.appearanceMode === "system"
      ? `System · ${theme.accentLabel}`
      : `${productPreferences.appearanceMode} · ${theme.accentLabel}`;
  const homeSummaryItems = [
    {
      label: "Sync",
      value: account ? accountSummary.badge : "Local only",
      detail: account ? accountSummary.modeLabel : accountSummary.detail,
    },
    {
      label: "Calendar",
      value: calendarSummary.badge,
      detail: calendarSummary.headline,
    },
    {
      label: "Reminders",
      value: enabledNotifications > 0 ? `${enabledNotifications} active` : "Muted",
      detail: quietHoursSummary,
    },
    {
      label: "Movement",
      value: String(reflectionSummary.completedThisWeek),
      detail: "Completed this week",
    },
  ];
  const statusReads = [
    planningSummary.learnedSummary,
    reflectionSummary.personalizedHighlights[0] ?? reflectionSummary.momentumCopy,
    calendarSummary.issue ?? calendarSummary.detail,
    account ? accountSummary.nextStep : "Everything is still staying on this device.",
  ];

  return (
    <Screen ref={scrollRef}>
      <View className="gap-5">
        <PageHeader
          eyebrow="Profile"
          title="Profile"
          description="Controls and defaults."
          action={
            <Button
              size="compact"
              tone="tertiary"
              onPress={() => navigation.navigate(account ? "ProfileAccount" : "ProfileAppearance")}
            >
              {account ? "Open account" : "Appearance"}
            </Button>
          }
        />

        <Surface tone="hero" className="gap-4">
          <View className="flex-row items-center gap-4">
            <View
              className="items-center justify-center rounded-full"
              style={{
                width: 54,
                height: 54,
                backgroundColor: theme.colors.background.elevated,
                borderWidth: 1,
                borderColor: theme.colors.border.subtle,
              }}
            >
              <Ionicons color={theme.colors.text.primary} name="person-outline" size={24} />
            </View>
            <View className="flex-1 gap-1">
              <AppText variant="section">
                {account?.displayName ?? account?.email ?? "Local profile"}
              </AppText>
              <AppText tone="secondary" variant="caption">
                {account ? accountSummary.modeLabel : "Local only on this device."}
              </AppText>
            </View>
          </View>

          <View className="flex-row flex-wrap gap-2">
            <Pill
              label={
                account
                  ? accountSummary.badge
                  : "local only"
              }
              tone="quiet"
            />
            <Pill label={`${reflectionSummary.completedThisWeek} done this week`} tone="accent" />
          </View>
          <DetailSummaryStrip items={homeSummaryItems} />
        </Surface>

        <Surface className="gap-5">
          <DetailSection
            title="Status line"
            description="Profile stays secondary, but it should still tell you quickly what is healthy, connected, or needs trust attention."
          >
            <View className="gap-4">
              <QuietMetaLine items={statusReads} />
              <View className="flex-row flex-wrap gap-2">
                <Pill label={planningSummary.intensityLabel} tone="quiet" />
                <Pill label={planningSummary.unfinishedWorkLabel} tone="quiet" />
                <Pill label={planningSummary.weeklyCarryoverLabel} tone="quiet" />
                <Pill label={`${formatMonthlyReviewCadenceShort(productPreferences.monthlyReviewDay)} review`} tone="quiet" />
                <Pill label={calendarSummary.badge} tone="quiet" />
              </View>
            </View>
          </DetailSection>
        </Surface>

        <Surface className="gap-5">
          <DetailSection
            title="Trust and connected systems"
            description="Account, sync, calendar, and reminders belong together so operational trust reads as one layer."
          >
            <View className="gap-3">
              {!account ? (
                <Surface tone="sunken" className="gap-2.5 mb-0">
                  <AppText variant="section">Everything is still local only.</AppText>
                  <AppText tone="secondary" variant="caption">
                    That keeps this device self-contained, but sync, recovery, and cross-device trust are still off until you attach an account.
                  </AppText>
                </Surface>
              ) : null}
              <DrillInRow
                title="Integrations"
                subtitle={calendarSummary.headline}
                detail={calendarSummary.badge}
                actionLabel="Open"
                leading={<Ionicons color={theme.colors.text.secondary} name="link-outline" size={18} />}
                onPress={() => navigation.navigate("ProfileIntegrations")}
              />
              <DrillInRow
                title="Notifications"
                subtitle={enabledNotifications > 0 ? `${enabledNotifications} reminder${enabledNotifications === 1 ? "" : "s"} active` : "All reminders muted"}
                detail={quietHoursSummary}
                actionLabel="Open"
                leading={<Ionicons color={theme.colors.text.secondary} name="notifications-outline" size={18} />}
                onPress={() => navigation.navigate("ProfileNotifications")}
              />
              <DrillInRow
                title="Account"
                subtitle={account ? accountSummary.modeLabel : accountSummary.detail}
                detail={account ? accountSummary.badge : "Local only"}
                actionLabel="Open"
                leading={<Ionicons color={theme.colors.text.secondary} name="person-circle-outline" size={18} />}
                onPress={() => navigation.navigate("ProfileAccount")}
              />
            </View>
          </DetailSection>
        </Surface>

        <Surface className="gap-5">
          <DetailSection
            title="Planning defaults"
            description="These controls shape how the planner behaves before Today, Plan, and Insights interpret anything."
          >
            <View className="gap-3">
              <DrillInRow
                title="Planning"
                subtitle={planningSummary.unfinishedWorkLabel}
                detail={`${planningSummary.intensityLabel} · ${planningSummary.monthlyPostureLabel}`}
                actionLabel="Open"
                leading={<Ionicons color={theme.colors.text.secondary} name="options-outline" size={18} />}
                onPress={() => navigation.navigate("ProfilePlanningPreferences")}
              />
              <DrillInRow
                title="Schedule"
                subtitle={formatTimeRangeLabel(
                  productPreferences.schedule.sleepStart,
                  productPreferences.schedule.sleepEnd,
                )}
                detail={`${productPreferences.schedule.commuteMinutes} min commute`}
                actionLabel="Open"
                leading={<Ionicons color={theme.colors.text.secondary} name="time-outline" size={18} />}
                onPress={() => navigation.navigate("ProfileScheduleDefaults")}
              />
            </View>
          </DetailSection>
        </Surface>

        <Surface className="gap-5">
          <DetailSection
            title="Personalization and reflection"
            description="Appearance and history stay available, but they remain support surfaces instead of becoming the workflow."
          >
            <View className="gap-3">
              <DrillInRow
                title="Appearance"
                subtitle="Mode and accent"
                detail={appearanceDetail}
                actionLabel="Open"
                leading={<Ionicons color={theme.colors.text.secondary} name="color-palette-outline" size={18} />}
                onPress={() => navigation.navigate("ProfileAppearance")}
              />
              <DrillInRow
                title="History & reflection"
                subtitle={reflectionSummary.personalizedHighlights[0] ?? "Recent movement and reflection"}
                detail={`${reflectionSummary.completedThisWeek} completed this week`}
                actionLabel="Open"
                leading={<Ionicons color={theme.colors.text.secondary} name="pulse-outline" size={18} />}
                onPress={() => navigation.navigate("ProfileHistory")}
              />
            </View>
          </DetailSection>
        </Surface>
      </View>
    </Screen>
  );
}
