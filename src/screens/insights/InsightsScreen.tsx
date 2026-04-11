import { useEffect, useState } from "react";
import { Pressable, View } from "react-native";

import { AccountStatusCard } from "../../components/account/AccountStatusCard";
import { Button } from "../../components/ui/Button";
import { EmptyStateCard } from "../../components/ui/EmptyStateCard";
import { OptionChip } from "../../components/ui/OptionChip";
import { Pill } from "../../components/ui/Pill";
import { Screen } from "../../components/ui/Screen";
import { Surface } from "../../components/ui/Surface";
import { TextField } from "../../components/ui/TextField";
import { AppText } from "../../components/ui/Text";
import { themePresets } from "../../product/theme";
import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
import { useAppStore } from "../../state/useAppStore";

export function InsightsScreen() {
  const theme = useResolvedTheme();
  const productPreferences = useAppStore((state) => state.productPreferences);
  const notificationPreferences = useAppStore((state) => state.notificationPreferences);
  const notificationPermissionStatus = useAppStore(
    (state) => state.notificationPermissionStatus,
  );
  const calendarConnectionState = useAppStore((state) => state.calendarConnectionState);
  const saveProductPreferences = useAppStore((state) => state.saveProductPreferences);
  const updateNotificationPreference = useAppStore(
    (state) => state.updateNotificationPreference,
  );
  const requestCalendarAccess = useAppStore((state) => state.requestCalendarAccess);
  const requestNotificationAccess = useAppStore((state) => state.requestNotificationAccess);
  const account = useAppStore((state) => state.account);
  const authState = useAppStore((state) => state.authState);
  const attachmentState = useAppStore((state) => state.attachmentState);
  const syncState = useAppStore((state) => state.syncState);
  const syncConflicts = useAppStore((state) => state.syncConflicts);
  const signInWithApple = useAppStore((state) => state.signInWithApple);
  const attachLocalDataToAccount = useAppStore((state) => state.attachLocalDataToAccount);
  const deferLocalDataAttachment = useAppStore((state) => state.deferLocalDataAttachment);
  const syncAccountData = useAppStore((state) => state.syncAccountData);
  const [sleepStart, setSleepStart] = useState("23:00");
  const [sleepEnd, setSleepEnd] = useState("07:00");
  const [workStart, setWorkStart] = useState("09:00");
  const [workEnd, setWorkEnd] = useState("17:00");
  const [commuteMinutes, setCommuteMinutes] = useState("20");
  const [busyState, setBusyState] = useState<string | null>(null);
  const [runtimeMessage, setRuntimeMessage] = useState<string | null>(null);

  useEffect(() => {
    if (!productPreferences) {
      return;
    }

    setSleepStart(productPreferences.schedule.sleepStart);
    setSleepEnd(productPreferences.schedule.sleepEnd);
    setWorkStart(productPreferences.schedule.workdayStart);
    setWorkEnd(productPreferences.schedule.workdayEnd);
    setCommuteMinutes(String(productPreferences.schedule.commuteMinutes));
  }, [productPreferences]);

  if (!productPreferences) {
    return (
      <Screen>
        <EmptyStateCard
          eyebrow="Settings"
          title="Settings are not available yet"
          body="The local preference layer is still settling. Reopen the app once startup finishes."
        />
      </Screen>
    );
  }

  const resolvedProductPreferences = productPreferences;

  async function savePreferences(
    key: string,
    buildNext: () => typeof resolvedProductPreferences,
    fallbackError: string,
  ) {
    setBusyState(key);
    setRuntimeMessage(null);

    try {
      await saveProductPreferences(buildNext());
    } catch (error) {
      setRuntimeMessage(error instanceof Error ? error.message : fallbackError);
    } finally {
      setBusyState(null);
    }
  }

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
      <View className="gap-6">
        <View className="gap-2 pt-2">
          <Pill label="Settings" />
          <AppText variant="hero">Quiet controls. Personal ownership.</AppText>
          <AppText tone="secondary">
            The essentials only: schedule defaults, planning preferences, account continuity, and
            a few personal controls.
          </AppText>
        </View>

        <AccountStatusCard
          account={account}
          authState={authState}
          attachmentState={attachmentState}
          syncState={syncState}
          conflicts={syncConflicts}
          busyAction={
            busyState === "sign_in" ||
            busyState === "attach" ||
            busyState === "sync" ||
            busyState === "defer"
              ? (busyState as "sign_in" | "attach" | "sync" | "defer")
              : null
          }
          onSignIn={() =>
            void runAction("sign_in", signInWithApple, "Sign in with Apple could not start.")
          }
          onAttach={() =>
            void runAction(
              "attach",
              attachLocalDataToAccount,
              "Local data could not be attached to the account.",
            )
          }
          onDefer={() =>
            void runAction(
              "defer",
              deferLocalDataAttachment,
              "The local-only path could not be preserved.",
            )
          }
          onSync={() =>
            void runAction("sync", () => syncAccountData(), "Account sync could not complete.")
          }
        />

        <Surface>
          <View className="gap-4">
            <AppText variant="section">Schedule defaults</AppText>
            <AppText tone="secondary">
              These defaults shape the planner when live context is unavailable or incomplete.
            </AppText>
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
                <TextField
                  label="Commute"
                  onChangeText={setCommuteMinutes}
                  value={commuteMinutes}
                />
              </View>
            </View>
            <Button
              tone="secondary"
              busy={busyState === "schedule"}
              onPress={() =>
                void savePreferences(
                  "schedule",
                    () => ({
                    ...resolvedProductPreferences,
                    schedule: {
                      ...resolvedProductPreferences.schedule,
                      sleepStart,
                      sleepEnd,
                      workdayStart: workStart,
                      workdayEnd: workEnd,
                      commuteMinutes: Number(commuteMinutes) || 0,
                    },
                  }),
                  "Schedule defaults could not be saved.",
                )
              }
            >
              Save schedule defaults
            </Button>
          </View>
        </Surface>

        <Surface tone="sunken">
          <View className="gap-4">
            <AppText variant="section">Planning style</AppText>
            <AppText tone="secondary">
              Keep the planner aligned to your preferred pacing without over-customizing it.
            </AppText>
            <View className="gap-2">
              <AppText variant="caption" tone="secondary">
                Task size
              </AppText>
              <View className="flex-row flex-wrap gap-2">
                {[
                  ["smaller", "Smaller tasks"],
                  ["mixed", "Mixed"],
                  ["bigger", "Fewer bigger tasks"],
                ].map(([key, label]) => (
                  <OptionChip
                    key={key}
                    selected={resolvedProductPreferences.taskSizing === key}
                    onPress={() =>
                      void savePreferences(
                        "task-sizing",
                        () => ({
                          ...resolvedProductPreferences,
                          taskSizing: key as typeof resolvedProductPreferences.taskSizing,
                        }),
                        "Task sizing could not be updated.",
                      )
                    }
                  >
                    {label}
                  </OptionChip>
                ))}
              </View>
            </View>

            <View className="gap-2">
              <AppText variant="caption" tone="secondary">
                Day intensity
              </AppText>
              <View className="flex-row flex-wrap gap-2">
                {[
                  ["light", "Light"],
                  ["balanced", "Balanced"],
                  ["ambitious", "Ambitious"],
                ].map(([key, label]) => (
                  <OptionChip
                    key={key}
                    selected={resolvedProductPreferences.dayIntensity === key}
                    onPress={() =>
                      void savePreferences(
                        "day-intensity",
                        () => ({
                          ...resolvedProductPreferences,
                          dayIntensity: key as typeof resolvedProductPreferences.dayIntensity,
                        }),
                        "Day intensity could not be updated.",
                      )
                    }
                  >
                    {label}
                  </OptionChip>
                ))}
              </View>
            </View>
          </View>
        </Surface>

        <Surface>
          <View className="gap-4">
            <AppText variant="section">Integrations</AppText>
            <View className="flex-row flex-wrap gap-2">
              <Pill
                label={
                  calendarConnectionState?.permissionState === "granted"
                    ? "Calendar connected"
                    : "Calendar not connected"
                }
                tone={
                  calendarConnectionState?.permissionState === "granted" ? "accent" : "neutral"
                }
              />
              <Pill
                label={`Notifications ${notificationPermissionStatus}`}
                tone={notificationPermissionStatus === "granted" ? "accent" : "neutral"}
              />
            </View>
            <View className="flex-row gap-3">
              <Button
                tone="secondary"
                style={{ flex: 1 }}
                busy={busyState === "calendar"}
                onPress={() =>
                  void runAction(
                    "calendar",
                    requestCalendarAccess,
                    "Calendar access could not be refreshed.",
                  )
                }
              >
                Refresh calendar access
              </Button>
              <Button
                tone="secondary"
                style={{ flex: 1 }}
                busy={busyState === "notifications"}
                onPress={() =>
                  void runAction(
                    "notifications",
                    requestNotificationAccess,
                    "Notification access could not be refreshed.",
                  )
                }
              >
                Refresh notifications
              </Button>
            </View>
            {notificationPreferences.map((preference) => (
              <Pressable
                key={preference.id}
                className="rounded-[24px]"
                onPress={() =>
                  void runAction(
                    `notification:${preference.id}`,
                    () =>
                      updateNotificationPreference(
                        preference.reminderType,
                        !preference.enabled,
                      ),
                    "Notification preference could not be updated.",
                  )
                }
                style={({ pressed }) => ({
                  opacity: pressed ? 0.84 : 1,
                })}
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
                  <View className="flex-row items-center justify-between gap-3">
                    <View className="flex-1 gap-1">
                      <AppText>{preference.reminderType.replace(/_/g, " ")}</AppText>
                      <AppText tone="tertiary" variant="caption">
                        {preference.enabled ? "Reminder is active" : "Reminder is muted"}
                      </AppText>
                    </View>
                    <Pill label={preference.enabled ? "Enabled" : "Muted"} tone="accent" />
                  </View>
                </Surface>
              </Pressable>
            ))}
          </View>
        </Surface>

        <Surface>
          <View className="gap-4">
            <AppText variant="section">Theme</AppText>
            <AppText tone="secondary">
              Pick the visual tone you want across the app without changing the overall product
              language.
            </AppText>
            {themePresets.map((preset) => (
              <Pressable
                key={preset.id}
                className="rounded-[24px]"
                onPress={() =>
                  void savePreferences(
                    "theme",
                    () => ({ ...resolvedProductPreferences, themePreset: preset.id }),
                    "Theme selection could not be updated.",
                  )
                }
                style={({ pressed }) => ({
                  opacity: pressed ? 0.85 : 1,
                })}
              >
                <Surface
                  tone="default"
                  className="gap-3"
                  style={{
                    backgroundColor: preset.colors.background.elevated,
                    borderColor:
                      resolvedProductPreferences.themePreset === preset.id
                        ? preset.colors.text.primary
                        : preset.colors.border.subtle,
                  }}
                >
                  <View className="flex-row flex-wrap gap-2">
                    {resolvedProductPreferences.themePreset === preset.id ? (
                      <Pill label="Selected" tone="accent" />
                    ) : null}
                    <Pill label={preset.label} />
                  </View>
                  <AppText tone="secondary">{preset.description}</AppText>
                </Surface>
              </Pressable>
            ))}
          </View>
        </Surface>

        {runtimeMessage ? (
          <AppText tone="tertiary" variant="caption">
            {runtimeMessage}
          </AppText>
        ) : null}
      </View>
    </Screen>
  );
}
