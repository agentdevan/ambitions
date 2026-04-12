import { useEffect, useState } from "react";
import { Pressable, View } from "react-native";

import { AccountStatusCard } from "../../components/account/AccountStatusCard";
import { IntegrationStatusCard } from "../../components/today/IntegrationStatusCard";
import { Button } from "../../components/ui/Button";
import { EmptyStateCard } from "../../components/ui/EmptyStateCard";
import { OptionChip } from "../../components/ui/OptionChip";
import { Screen } from "../../components/ui/Screen";
import { Surface } from "../../components/ui/Surface";
import { AppText } from "../../components/ui/Text";
import { TextField } from "../../components/ui/TextField";
import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
import { themePresets } from "../../product/theme";
import { useAppStore } from "../../state/useAppStore";
import {
  formatTimeLabel,
  formatTimeRangeLabel,
  normalizeTimeString,
} from "../../utils/date";

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

export function ProfileAppearanceScreen() {
  const productPreferences = useAppStore((state) => state.productPreferences);
  const saveProductPreferences = useAppStore((state) => state.saveProductPreferences);
  const [busyState, setBusyState] = useState<string | null>(null);
  const [runtimeMessage, setRuntimeMessage] = useState<string | null>(null);

  if (!productPreferences) {
    return (
      <Screen>
        <EmptyStateCard title="Preferences unavailable" body="Appearance settings are still loading." />
      </Screen>
    );
  }

  const resolvedPreferences = productPreferences;

  async function saveTheme(themePreset: (typeof themePresets)[number]["id"]) {
    setBusyState(themePreset);
    setRuntimeMessage(null);

    try {
      await saveProductPreferences({ ...resolvedPreferences, themePreset });
    } catch (error) {
      setRuntimeMessage(error instanceof Error ? error.message : "Theme selection could not be updated.");
    } finally {
      setBusyState(null);
    }
  }

  return (
    <Screen>
      <View className="gap-4">
        <Surface tone="accent" className="gap-3">
          <AppText variant="title">Appearance</AppText>
          <AppText tone="secondary">
            Pick the visual tone here instead of burying it in Insights.
          </AppText>
        </Surface>
        {themePresets.map((preset) => (
          <Pressable
            key={preset.id}
            className="rounded-[24px]"
            onPress={() => void saveTheme(preset.id)}
            style={({ pressed }) => ({ opacity: pressed ? 0.9 : 1 })}
          >
            <Surface
              className="gap-2"
              style={{
                backgroundColor: preset.colors.background.elevated,
                borderColor:
                  resolvedPreferences.themePreset === preset.id
                    ? preset.colors.text.primary
                    : preset.colors.border.subtle,
              }}
            >
              <AppText variant="section">{preset.label}</AppText>
              <AppText tone="secondary">{preset.description}</AppText>
              {resolvedPreferences.themePreset === preset.id ? <MetaLine items={["Selected"]} /> : null}
              {busyState === preset.id ? (
                <AppText tone="tertiary" variant="caption">
                  Saving...
                </AppText>
              ) : null}
            </Surface>
          </Pressable>
        ))}
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
            These defaults shape the plan when live context is missing or incomplete.
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
  const notificationPermissionStatus = useAppStore((state) => state.notificationPermissionStatus);
  const requestCalendarAccess = useAppStore((state) => state.requestCalendarAccess);
  const requestNotificationAccess = useAppStore((state) => state.requestNotificationAccess);
  const refreshIntegration = useAppStore((state) => state.refreshIntegration);
  const [integrationBusy, setIntegrationBusy] = useState<string | null>(null);
  const [runtimeMessage, setRuntimeMessage] = useState<string | null>(null);

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
        <Surface tone="accent" className="gap-3">
          <AppText variant="title">Integrations</AppText>
          <AppText tone="secondary">
            Calendar and reminder connections live here, not on Insights.
          </AppText>
        </Surface>
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
        {runtimeMessage ? <AppText tone="tertiary" variant="caption">{runtimeMessage}</AppText> : null}
      </View>
    </Screen>
  );
}

export function ProfileNotificationsScreen() {
  const theme = useResolvedTheme();
  const notificationPreferences = useAppStore((state) => state.notificationPreferences);
  const notificationPermissionStatus = useAppStore((state) => state.notificationPermissionStatus);
  const updateNotificationPreference = useAppStore((state) => state.updateNotificationPreference);
  const requestNotificationAccess = useAppStore((state) => state.requestNotificationAccess);
  const [busyState, setBusyState] = useState<string | null>(null);
  const [runtimeMessage, setRuntimeMessage] = useState<string | null>(null);

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

  return (
    <Screen>
      <View className="gap-4">
        <Surface tone="accent" className="gap-3">
          <AppText variant="title">Notifications</AppText>
          <AppText tone="secondary">
            Manage reminder behavior here.
          </AppText>
          <MetaLine items={[`Permission: ${notificationPermissionStatus}`]} />
        </Surface>
        {notificationPermissionStatus !== "granted" ? (
          <Button tone="secondary" onPress={() => void runAction("permission", requestNotificationAccess, "Notification access could not be refreshed.")} busy={busyState === "permission"}>
            Allow notifications
          </Button>
        ) : null}
        {notificationPreferences.map((preference) => (
          <Pressable
            key={preference.id}
            className="rounded-[24px]"
            onPress={() =>
              void runAction(
                `notification:${preference.id}`,
                () => updateNotificationPreference(preference.reminderType, !preference.enabled),
                "Notification preference could not be updated.",
              )
            }
            style={({ pressed }) => ({ opacity: pressed ? 0.92 : 1 })}
          >
            <Surface
              tone={preference.enabled ? "accent" : "default"}
              className="gap-2"
              style={{
                borderColor: preference.enabled
                  ? theme.colors.border.strong
                  : theme.colors.border.subtle,
              }}
            >
              <AppText variant="section">{preference.reminderType.replace(/_/g, " ")}</AppText>
              <MetaLine items={[preference.enabled ? "Reminder active" : "Reminder muted"]} />
            </Surface>
          </Pressable>
        ))}
        {runtimeMessage ? <AppText tone="tertiary" variant="caption">{runtimeMessage}</AppText> : null}
      </View>
    </Screen>
  );
}

export function ProfilePlanningPreferencesScreen() {
  const productPreferences = useAppStore((state) => state.productPreferences);
  const saveProductPreferences = useAppStore((state) => state.saveProductPreferences);
  const [busyState, setBusyState] = useState<string | null>(null);
  const [runtimeMessage, setRuntimeMessage] = useState<string | null>(null);

  if (!productPreferences) {
    return (
      <Screen>
        <EmptyStateCard title="Preferences unavailable" body="Planning preferences are still loading." />
      </Screen>
    );
  }

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
        <Surface tone="accent" className="gap-3">
          <AppText variant="title">Planning preferences</AppText>
          <AppText tone="secondary">
            Tune the planner's bias without turning the main product into a form.
          </AppText>
        </Surface>
        <Surface className="gap-3">
          <AppText variant="section">Task size</AppText>
          <View className="flex-row flex-wrap gap-2">
            {[
              ["smaller", "Smaller tasks"],
              ["mixed", "Mixed"],
              ["bigger", "Fewer bigger tasks"],
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
        <Surface className="gap-3">
          <AppText variant="section">Day intensity</AppText>
          <View className="flex-row flex-wrap gap-2">
            {[
              ["light", "Light"],
              ["balanced", "Balanced"],
              ["ambitious", "Ambitious"],
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
        {busyState ? <AppText tone="tertiary" variant="caption">Saving...</AppText> : null}
        {runtimeMessage ? <AppText tone="tertiary" variant="caption">{runtimeMessage}</AppText> : null}
      </View>
    </Screen>
  );
}

export function ProfileAccountScreen() {
  const account = useAppStore((state) => state.account);
  const authState = useAppStore((state) => state.authState);
  const attachmentState = useAppStore((state) => state.attachmentState);
  const syncState = useAppStore((state) => state.syncState);
  const syncConflicts = useAppStore((state) => state.syncConflicts);
  const signInWithApple = useAppStore((state) => state.signInWithApple);
  const attachLocalDataToAccount = useAppStore((state) => state.attachLocalDataToAccount);
  const deferLocalDataAttachment = useAppStore((state) => state.deferLocalDataAttachment);
  const syncAccountData = useAppStore((state) => state.syncAccountData);
  const [accountBusy, setAccountBusy] = useState<string | null>(null);
  const [runtimeMessage, setRuntimeMessage] = useState<string | null>(null);

  async function runAccountAction(
    key: string,
    action: () => Promise<void>,
    fallbackError: string,
  ) {
    setAccountBusy(key);
    setRuntimeMessage(null);

    try {
      await action();
    } catch (error) {
      setRuntimeMessage(error instanceof Error ? error.message : fallbackError);
    } finally {
      setAccountBusy(null);
    }
  }

  return (
    <Screen>
      <View className="gap-4">
        <Surface tone="accent" className="gap-3">
          <AppText variant="title">Account</AppText>
          <AppText tone="secondary">
            Sign-in, attachment, and sync all live here now.
          </AppText>
        </Surface>
        <AccountStatusCard
          account={account}
          authState={authState}
          attachmentState={attachmentState}
          syncState={syncState}
          conflicts={syncConflicts}
          busyAction={
            accountBusy === "sign_in" ||
            accountBusy === "attach" ||
            accountBusy === "sync" ||
            accountBusy === "defer"
              ? (accountBusy as "sign_in" | "attach" | "sync" | "defer")
              : null
          }
          onSignIn={() =>
            void runAccountAction("sign_in", signInWithApple, "Sign in with Apple could not start.")
          }
          onAttach={() =>
            void runAccountAction(
              "attach",
              attachLocalDataToAccount,
              "Local data could not be attached to the account.",
            )
          }
          onDefer={() =>
            void runAccountAction(
              "defer",
              deferLocalDataAttachment,
              "The local-only path could not be preserved.",
            )
          }
          onSync={() =>
            void runAccountAction("sync", () => syncAccountData(), "Account sync could not complete.")
          }
        />
        {runtimeMessage ? <AppText tone="tertiary" variant="caption">{runtimeMessage}</AppText> : null}
      </View>
    </Screen>
  );
}
