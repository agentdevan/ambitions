import { NativeStackScreenProps } from "@react-navigation/native-stack";
import { View } from "react-native";

import { DrillInRow } from "../../components/navigation/DrillInRow";
import { PageHeader } from "../../components/navigation/PageHeader";
import { Pill } from "../../components/ui/Pill";
import { Screen } from "../../components/ui/Screen";
import { Surface } from "../../components/ui/Surface";
import { AppText } from "../../components/ui/Text";
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

  return (
    <Screen>
      <View className="gap-6">
        <PageHeader
          eyebrow="Profile"
          title="Your controls live here."
          description="Settings, account, defaults, and integrations are grouped here so the rest of the app can stay focused."
        />

        <Surface tone="accent" className="gap-4">
          <View className="gap-2">
            <View className="flex-row flex-wrap items-center gap-2">
              <Pill label={account ? "Account connected" : "Local only"} tone="accent" />
              <Pill label={syncState?.mode.replaceAll("_", " ") ?? "Not synced"} tone="quiet" />
            </View>
            <AppText variant="title">{account?.displayName ?? account?.email ?? "Local profile"}</AppText>
            <AppText tone="secondary">
              {account
                ? "Account, sync state, and personal defaults are grouped here."
                : "The app is running locally right now. Add an account later if you want sync."}
            </AppText>
          </View>
        </Surface>

        <View className="gap-3">
          <DrillInRow
            title="Appearance"
            subtitle="Theme preset and visual tone."
            detail={productPreferences.themePreset}
            onPress={() => navigation.navigate("ProfileAppearance")}
          />
          <DrillInRow
            title="Schedule defaults"
            subtitle={formatTimeRangeLabel(
              productPreferences.schedule.sleepStart,
              productPreferences.schedule.sleepEnd,
            )}
            detail={`${productPreferences.schedule.commuteMinutes} min commute`}
            onPress={() => navigation.navigate("ProfileScheduleDefaults")}
          />
          <DrillInRow
            title="Integrations"
            subtitle={
              calendarConnectionState?.permissionState === "granted"
                ? "Calendar context is available."
                : "Calendar access is not configured."
            }
            detail={calendarConnectionState?.permissionState ?? "not ready"}
            onPress={() => navigation.navigate("ProfileIntegrations")}
          />
          <DrillInRow
            title="Notifications"
            subtitle="Reminder behavior and permission state."
            detail={`${enabledNotifications} enabled`}
            onPress={() => navigation.navigate("ProfileNotifications")}
          />
          <DrillInRow
            title="Planning preferences"
            subtitle="Task sizing and day intensity."
            detail={`${productPreferences.taskSizing} / ${productPreferences.dayIntensity}`}
            onPress={() => navigation.navigate("ProfilePlanningPreferences")}
          />
          <DrillInRow
            title="Account"
            subtitle="Sign-in, local attachment, and sync."
            detail={account ? "Connected" : "Local only"}
            onPress={() => navigation.navigate("ProfileAccount")}
          />
        </View>
      </View>
    </Screen>
  );
}
