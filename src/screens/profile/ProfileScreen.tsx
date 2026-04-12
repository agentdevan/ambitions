import { NativeStackScreenProps } from "@react-navigation/native-stack";
import { Ionicons } from "@expo/vector-icons";
import { View } from "react-native";

import { DrillInRow } from "../../components/navigation/DrillInRow";
import { PageHeader } from "../../components/navigation/PageHeader";
import { Pill } from "../../components/ui/Pill";
import { Screen } from "../../components/ui/Screen";
import { Surface } from "../../components/ui/Surface";
import { AppText } from "../../components/ui/Text";
import { buildActivityFeed, summarizeInsights } from "../../services/history/selectors";
import { useAppStore } from "../../state/useAppStore";
import { formatTimeRangeLabel } from "../../utils/date";
import { ProfileStackParamList } from "../../navigation/types";

type Props = NativeStackScreenProps<ProfileStackParamList, "ProfileHome">;

export function ProfileScreen({ navigation }: Props) {
  const productPreferences = useAppStore((state) => state.productPreferences);
  const notificationPreferences = useAppStore((state) => state.notificationPreferences);
  const calendarConnectionState = useAppStore((state) => state.calendarConnectionState);
  const account = useAppStore((state) => state.account);
  const syncState = useAppStore((state) => state.syncState);
  const goals = useAppStore((state) => state.goals);
  const milestones = useAppStore((state) => state.milestones);
  const tasks = useAppStore((state) => state.allTasks);
  const activityEvents = useAppStore((state) => state.activityEvents);

  if (!productPreferences) {
    return (
      <Screen>
        <Surface>
          <AppText variant="title">Profile is loading</AppText>
          <AppText tone="secondary">
            Account and preference detail are not ready yet.
          </AppText>
        </Surface>
      </Screen>
    );
  }

  const enabledNotifications = notificationPreferences.filter((item) => item.enabled).length;
  const reflectionSummary = summarizeInsights({
    goals,
    tasks,
    milestones,
    events: buildActivityFeed(activityEvents, tasks, milestones),
  });

  return (
    <Screen>
      <View className="gap-6">
        <PageHeader
          eyebrow="Profile"
          title="Profile"
          description="Controls and defaults."
        />

        <Surface tone="accent" className="gap-4">
          <View className="gap-1.5">
            <View className="flex-row flex-wrap items-center gap-2">
              <Pill label={account ? "Account connected" : "Local only"} tone="accent" />
              <Pill label={syncState?.mode.replaceAll("_", " ") ?? "Not synced"} tone="quiet" />
            </View>
            <AppText variant="title">{account?.displayName ?? account?.email ?? "Local profile"}</AppText>
            <AppText tone="secondary">{account ? "Sync ready." : "Local setup."}</AppText>
          </View>
        </Surface>

        <View className="gap-3">
          <DrillInRow
            title="Recent movement"
            subtitle="History and momentum"
            detail={`${reflectionSummary.completedThisWeek} completed`}
            leading={<Ionicons color="#6F6558" name="analytics-outline" size={18} />}
            onPress={() => navigation.navigate("ProfileHistory")}
          />
          <DrillInRow
            title="Appearance"
            subtitle="Theme"
            detail={productPreferences.themePreset}
            leading={<Ionicons color="#6F6558" name="color-palette-outline" size={18} />}
            onPress={() => navigation.navigate("ProfileAppearance")}
          />
          <DrillInRow
            title="Schedule defaults"
            subtitle={formatTimeRangeLabel(
              productPreferences.schedule.sleepStart,
              productPreferences.schedule.sleepEnd,
            )}
            detail={`${productPreferences.schedule.commuteMinutes} min commute`}
            leading={<Ionicons color="#6F6558" name="time-outline" size={18} />}
            onPress={() => navigation.navigate("ProfileScheduleDefaults")}
          />
          <DrillInRow
            title="Integrations"
            subtitle={
              calendarConnectionState?.permissionState === "granted"
                ? "Calendar ready"
                : "Calendar off"
            }
            detail={calendarConnectionState?.permissionState ?? "not ready"}
            leading={<Ionicons color="#6F6558" name="link-outline" size={18} />}
            onPress={() => navigation.navigate("ProfileIntegrations")}
          />
          <DrillInRow
            title="Notifications"
            subtitle="Reminders"
            detail={`${enabledNotifications} enabled`}
            leading={<Ionicons color="#6F6558" name="notifications-outline" size={18} />}
            onPress={() => navigation.navigate("ProfileNotifications")}
          />
          <DrillInRow
            title="Planning preferences"
            subtitle="Task size and intensity"
            detail={`${productPreferences.taskSizing} / ${productPreferences.dayIntensity}`}
            leading={<Ionicons color="#6F6558" name="options-outline" size={18} />}
            onPress={() => navigation.navigate("ProfilePlanningPreferences")}
          />
          <DrillInRow
            title="Account"
            subtitle="Sign-in and sync"
            detail={account ? "Connected" : "Local only"}
            leading={<Ionicons color="#6F6558" name="person-circle-outline" size={18} />}
            onPress={() => navigation.navigate("ProfileAccount")}
          />
        </View>
      </View>
    </Screen>
  );
}
