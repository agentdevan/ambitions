import { useScrollToTop } from "@react-navigation/native";
import { NativeStackScreenProps } from "@react-navigation/native-stack";
import { Ionicons } from "@expo/vector-icons";
import { useMemo, useRef } from "react";
import { View } from "react-native";
import { useShallow } from "zustand/react/shallow";

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
  summarizeCalendarControl,
  summarizeQuietHours,
  summarizeSyncState,
} from "../../services/profile/controlSummaries";
import { useAppStore } from "../../state/useAppStore";
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
        <EmptyStateCard eyebrow="Preparing" title="Profile is loading" body="Settings, trust state, and defaults will appear in a moment." />
      </Screen>
    );
  }

  const enabledNotifications = notificationPreferences.filter((item) => item.enabled).length;
  const quietHoursSummary = summarizeQuietHours(notificationPreferences);
  const activityFeed = useMemo(() => buildActivityFeed(activityEvents, tasks, milestones), [activityEvents, milestones, tasks]);
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

  return (
    <Screen ref={scrollRef}>
      <View className="gap-5">
        <PageHeader
          eyebrow="Profile"
          title="Profile"
          description="Settings, connected services, and account."
          action={
            <View className="flex-row gap-3">
              <Button
                size="compact"
                style={{ flex: 1 }}
                onPress={() => navigation.navigate(account ? "ProfileAccount" : "ProfileAppearance")}
              >
                {account ? "Account" : "Appearance"}
              </Button>
              <Button
                size="compact"
                tone="secondary"
                style={{ flex: 1 }}
                onPress={() => navigation.navigate("ProfileNotifications")}
              >
                Notifications
              </Button>
            </View>
          }
        />

        <Surface tone="hero" className="gap-4">
          <View className="flex-row items-center gap-4">
            <View
              className="items-center justify-center rounded-full"
              style={{
                width: 58,
                height: 58,
                backgroundColor: theme.colors.background.elevated,
                borderWidth: 1,
                borderColor: theme.colors.border.subtle,
              }}
            >
              <Ionicons color={theme.colors.text.primary} name="person-outline" size={24} />
            </View>
            <View className="flex-1 gap-1">
              <AppText variant="section">{account?.displayName ?? account?.email ?? "Local profile"}</AppText>
              <AppText tone="secondary">{account ? accountSummary.modeLabel : "Local only on this device."}</AppText>
            </View>
          </View>

          <View className="flex-row flex-wrap gap-2">
            <Pill label={account ? accountSummary.badge : "Local only"} tone="quiet" />
            <Pill label={calendarSummary.badge} tone="quiet" />
            <Pill label={enabledNotifications > 0 ? `${enabledNotifications} reminders` : "Reminders muted"} tone="accent" />
          </View>
          <View className="flex-row gap-3">
            <Button style={{ flex: 1 }} onPress={() => navigation.navigate("ProfileAppearance")}>
              Appearance
            </Button>
            <Button tone="secondary" style={{ flex: 1 }} onPress={() => navigation.navigate("ProfileAccount")}>
              Account
            </Button>
          </View>
        </Surface>

        <Surface className="gap-3">
          <AppText variant="section">Open more</AppText>
          <DrillInRow
            title="Appearance"
            subtitle="Mode and accent"
            detail={appearanceDetail}
            actionLabel="Open"
            leading={<Ionicons color={theme.colors.accent.primary} name="color-palette-outline" size={18} />}
            onPress={() => navigation.navigate("ProfileAppearance")}
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
            title="Integrations"
            subtitle={calendarSummary.headline}
            detail={calendarSummary.badge}
            actionLabel="Open"
            leading={<Ionicons color={theme.colors.text.secondary} name="link-outline" size={18} />}
            onPress={() => navigation.navigate("ProfileIntegrations")}
          />
          <DrillInRow
            title="Account"
            subtitle={account ? accountSummary.modeLabel : accountSummary.detail}
            detail={account ? accountSummary.badge : "Local only"}
            actionLabel="Open"
            leading={<Ionicons color={theme.colors.text.secondary} name="person-circle-outline" size={18} />}
            onPress={() => navigation.navigate("ProfileAccount")}
          />
        </Surface>

        <Surface className="gap-3">
          <AppText variant="section">More settings</AppText>
          <DrillInRow
            title="Planning defaults"
            subtitle="Schedule and planner behavior"
            detail="Open"
            actionLabel="Open"
            leading={<Ionicons color={theme.colors.text.secondary} name="options-outline" size={18} />}
            onPress={() => navigation.navigate("ProfilePlanningPreferences")}
          />
          <DrillInRow
            title="Schedule defaults"
            subtitle="Sleep, commute, and time boundaries"
            detail="Open"
            actionLabel="Open"
            leading={<Ionicons color={theme.colors.text.secondary} name="time-outline" size={18} />}
            onPress={() => navigation.navigate("ProfileScheduleDefaults")}
          />
          <DrillInRow
            title="History"
            subtitle={reflectionSummary.personalizedHighlights[0] ?? "Recent movement and reflection"}
            detail={`${reflectionSummary.completedThisWeek} completed`}
            actionLabel="Open"
            leading={<Ionicons color={theme.colors.text.secondary} name="pulse-outline" size={18} />}
            onPress={() => navigation.navigate("ProfileHistory")}
          />
        </Surface>

        <Surface tone="sunken" className="gap-2">
          <AppText variant="caption">System status</AppText>
          <AppText tone="secondary" variant="caption">
            {account ? accountSummary.nextStep : calendarSummary.issue ?? "Everything is staying on this device right now."}
          </AppText>
        </Surface>
      </View>
    </Screen>
  );
}
