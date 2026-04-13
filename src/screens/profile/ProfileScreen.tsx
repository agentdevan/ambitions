import { NativeStackScreenProps } from "@react-navigation/native-stack";
import { Ionicons } from "@expo/vector-icons";
import type { ReactNode } from "react";
import { View } from "react-native";

import { DrillInRow } from "../../components/navigation/DrillInRow";
import { PageHeader } from "../../components/navigation/PageHeader";
import { Button } from "../../components/ui/Button";
import { Pill } from "../../components/ui/Pill";
import { Screen } from "../../components/ui/Screen";
import { Surface } from "../../components/ui/Surface";
import { AppText } from "../../components/ui/Text";
import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
import { buildActivityFeed, summarizeInsights } from "../../services/history/selectors";
import {
  summarizeCalendarControl,
  summarizePlanningControls,
  summarizeQuietHours,
  summarizeSyncState,
} from "../../services/profile/controlSummaries";
import { useAppStore } from "../../state/useAppStore";
import { formatTimeRangeLabel } from "../../utils/date";
import { ProfileStackParamList } from "../../navigation/types";

type Props = NativeStackScreenProps<ProfileStackParamList, "ProfileHome">;

function SettingGroup({ title, children }: { title: string; children: ReactNode }) {
  return (
    <View className="gap-3">
      <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
        {title}
      </AppText>
      <View className="gap-3">{children}</View>
    </View>
  );
}

export function ProfileScreen({ navigation }: Props) {
  const productPreferences = useAppStore((state) => state.productPreferences);
  const notificationPreferences = useAppStore((state) => state.notificationPreferences);
  const calendarConnectionState = useAppStore((state) => state.calendarConnectionState);
  const account = useAppStore((state) => state.account);
  const attachmentState = useAppStore((state) => state.attachmentState);
  const syncState = useAppStore((state) => state.syncState);
  const syncConflicts = useAppStore((state) => state.syncConflicts);
  const scheduleConstraints = useAppStore((state) => state.scheduleConstraints);
  const today = useAppStore((state) => state.today);
  const goals = useAppStore((state) => state.goals);
  const milestones = useAppStore((state) => state.milestones);
  const tasks = useAppStore((state) => state.allTasks);
  const activityEvents = useAppStore((state) => state.activityEvents);
  const adaptationProfile = useAppStore((state) => state.adaptationProfile);
  const theme = useResolvedTheme();

  if (!productPreferences) {
    return (
      <Screen>
        <Surface>
          <AppText variant="title">Profile is loading</AppText>
          <AppText tone="secondary">Settings will appear in a moment.</AppText>
        </Surface>
      </Screen>
    );
  }

  const enabledNotifications = notificationPreferences.filter((item) => item.enabled).length;
  const quietHoursSummary = summarizeQuietHours(notificationPreferences);
  const reflectionSummary = summarizeInsights({
    goals,
    tasks,
    milestones,
    events: buildActivityFeed(activityEvents, tasks, milestones),
    profile: adaptationProfile,
    adaptiveEnabled: productPreferences.adaptivePlanningEnabled,
  });
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

  return (
    <Screen>
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
                {account ? accountSummary.headline : "Local only."}
              </AppText>
            </View>
          </View>

          <View className="flex-row flex-wrap gap-2">
            <Pill
              label={
                account
                  ? syncState?.mode.replaceAll("_", " ") ?? "signed in"
                  : "local only"
              }
              tone="quiet"
            />
            <Pill label={`${reflectionSummary.completedThisWeek} done this week`} tone="accent" />
          </View>
        </Surface>

        <SettingGroup title="Planning">
          <DrillInRow
            title="Planning"
            subtitle={planningSummary.unfinishedWorkLabel}
            detail={`${planningSummary.intensityLabel} · ${planningSummary.weeklyCarryoverLabel}`}
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
        </SettingGroup>

        <SettingGroup title="Connected">
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
            subtitle={accountSummary.headline}
            detail={account ? "Connected account" : "Local only"}
            actionLabel="Open"
            leading={<Ionicons color={theme.colors.text.secondary} name="person-circle-outline" size={18} />}
            onPress={() => navigation.navigate("ProfileAccount")}
          />
        </SettingGroup>

        <SettingGroup title="Profile">
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
        </SettingGroup>

        <Surface className="gap-3">
          <AppText variant="section">What&apos;s controllable now</AppText>
          <AppText tone="secondary" variant="caption">
            Plan weight, daily closeout defaults, weekly shaping posture, monthly steering defaults, reminders, calendar context, account syncing, and appearance are yours to tune.
          </AppText>
          <View className="flex-row flex-wrap gap-2">
            <Pill label={planningSummary.intensityLabel} tone="quiet" />
            <Pill label={planningSummary.unfinishedWorkLabel} tone="quiet" />
            <Pill label={planningSummary.weeklyCarryoverLabel} tone="quiet" />
            <Pill label={calendarSummary.badge} tone="quiet" />
          </View>
        </Surface>

        {productPreferences.adaptivePlanningEnabled ? (
          <Surface className="gap-3">
            <AppText variant="section">Planning automation</AppText>
            <AppText tone="secondary" variant="caption">
              {planningSummary.learnedSummary}
            </AppText>
          </Surface>
        ) : null}

        <Surface className="gap-3">
          <AppText variant="section">You&apos;re on track</AppText>
          <AppText tone="secondary" variant="caption">
            {reflectionSummary.personalizedHighlights[0] ?? "Recent movement is starting to take shape."}
          </AppText>
        </Surface>
      </View>
    </Screen>
  );
}
