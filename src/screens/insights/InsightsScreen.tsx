import { useEffect, useState } from "react";
import { Pressable, View } from "react-native";

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
            This is the product settings area for V1, not a control panel.
          </AppText>
        </View>

        <Surface>
          <View className="gap-4">
            <AppText variant="section">Schedule defaults</AppText>
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
            <AppText tone="secondary">
              Calendar:{" "}
              {calendarConnectionState?.permissionState === "granted"
                ? "connected"
                : "not connected"}
            </AppText>
            <AppText tone="secondary">Notifications: {notificationPermissionStatus}</AppText>
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
                className="flex-row items-center justify-between rounded-[22px] px-4 py-4"
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
                  borderWidth: 1,
                  borderColor: theme.colors.border.subtle,
                  backgroundColor: theme.colors.background.elevated,
                  opacity: pressed ? 0.84 : 1,
                })}
              >
                <View className="flex-1 gap-1">
                  <AppText>{preference.reminderType.replace(/_/g, " ")}</AppText>
                  <AppText tone="tertiary" variant="caption">
                    {preference.enabled ? "On" : "Off"}
                  </AppText>
                </View>
                <Pill label={preference.enabled ? "Enabled" : "Muted"} tone="accent" />
              </Pressable>
            ))}
          </View>
        </Surface>

        <Surface>
          <View className="gap-4">
            <AppText variant="section">Theme</AppText>
            {themePresets.map((preset) => (
              <Pressable
                key={preset.id}
                className="rounded-[24px] px-4 py-4"
                onPress={() =>
                  void savePreferences(
                    "theme",
                    () => ({ ...resolvedProductPreferences, themePreset: preset.id }),
                    "Theme selection could not be updated.",
                  )
                }
                style={({ pressed }) => ({
                  backgroundColor: preset.colors.background.elevated,
                  borderColor:
                    resolvedProductPreferences.themePreset === preset.id
                      ? preset.colors.text.primary
                      : preset.colors.border.subtle,
                  borderWidth: 1,
                  opacity: pressed ? 0.85 : 1,
                })}
              >
                <AppText variant="section">{preset.label}</AppText>
                <AppText tone="secondary" style={{ marginTop: 6 }}>
                  {preset.description}
                </AppText>
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
