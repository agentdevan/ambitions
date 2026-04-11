import { useState } from "react";
import { Pressable, TextInput, View } from "react-native";

import { Button } from "../../components/ui/Button";
import { Pill } from "../../components/ui/Pill";
import { Screen } from "../../components/ui/Screen";
import { Surface } from "../../components/ui/Surface";
import { AppText } from "../../components/ui/Text";
import { themePresets } from "../../product/theme";
import { useAppStore } from "../../state/useAppStore";

export function InsightsScreen() {
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
  const [sleepStart, setSleepStart] = useState(productPreferences?.schedule.sleepStart ?? "23:00");
  const [sleepEnd, setSleepEnd] = useState(productPreferences?.schedule.sleepEnd ?? "07:00");
  const [workStart, setWorkStart] = useState(productPreferences?.schedule.workdayStart ?? "09:00");
  const [workEnd, setWorkEnd] = useState(productPreferences?.schedule.workdayEnd ?? "17:00");
  const [commuteMinutes, setCommuteMinutes] = useState(
    String(productPreferences?.schedule.commuteMinutes ?? 20),
  );

  if (!productPreferences) {
    return null;
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
              <TextInput onChangeText={setSleepStart} style={fieldStyle} value={sleepStart} />
              <TextInput onChangeText={setSleepEnd} style={fieldStyle} value={sleepEnd} />
            </View>
            <View className="flex-row gap-3">
              <TextInput onChangeText={setWorkStart} style={fieldStyle} value={workStart} />
              <TextInput onChangeText={setWorkEnd} style={fieldStyle} value={workEnd} />
              <TextInput
                onChangeText={setCommuteMinutes}
                style={[fieldStyle, { flex: 0.7 }]}
                value={commuteMinutes}
              />
            </View>
            <Button
              tone="secondary"
              onPress={() =>
                saveProductPreferences({
                  ...productPreferences,
                  schedule: {
                    ...productPreferences.schedule,
                    sleepStart,
                    sleepEnd,
                    workdayStart: workStart,
                    workdayEnd: workEnd,
                    commuteMinutes: Number(commuteMinutes) || 0,
                  },
                })
              }
            >
              Save schedule defaults
            </Button>
          </View>
        </Surface>

        <Surface tone="sunken">
          <View className="gap-4">
            <AppText variant="section">Planning style</AppText>
            <View className="flex-row flex-wrap gap-2">
              {[
                ["smaller", "Smaller tasks"],
                ["mixed", "Mixed"],
                ["bigger", "Fewer bigger tasks"],
              ].map(([key, label]) => (
                <Pressable
                  key={key}
                  className="rounded-full border px-4 py-3"
                  onPress={() =>
                    saveProductPreferences({
                      ...productPreferences,
                      taskSizing: key as typeof productPreferences.taskSizing,
                    })
                  }
                  style={{
                    backgroundColor:
                      productPreferences.taskSizing === key ? "#18181A" : "#F8F6F1",
                    borderColor:
                      productPreferences.taskSizing === key ? "#18181A" : "#DDD8D0",
                  }}
                >
                  <AppText
                    tone={productPreferences.taskSizing === key ? "inverse" : "secondary"}
                    variant="caption"
                  >
                    {label}
                  </AppText>
                </Pressable>
              ))}
            </View>
            <View className="flex-row flex-wrap gap-2">
              {[
                ["light", "Light"],
                ["balanced", "Balanced"],
                ["ambitious", "Ambitious"],
              ].map(([key, label]) => (
                <Pressable
                  key={key}
                  className="rounded-full border px-4 py-3"
                  onPress={() =>
                    saveProductPreferences({
                      ...productPreferences,
                      dayIntensity: key as typeof productPreferences.dayIntensity,
                    })
                  }
                  style={{
                    backgroundColor:
                      productPreferences.dayIntensity === key ? "#18181A" : "#F8F6F1",
                    borderColor:
                      productPreferences.dayIntensity === key ? "#18181A" : "#DDD8D0",
                  }}
                >
                  <AppText
                    tone={productPreferences.dayIntensity === key ? "inverse" : "secondary"}
                    variant="caption"
                  >
                    {label}
                  </AppText>
                </Pressable>
              ))}
            </View>
          </View>
        </Surface>

        <Surface>
          <View className="gap-4">
            <AppText variant="section">Integrations</AppText>
            <AppText tone="secondary">
              Calendar: {calendarConnectionState?.permissionState === "granted" ? "connected" : "not connected"}
            </AppText>
            <AppText tone="secondary">
              Notifications: {notificationPermissionStatus}
            </AppText>
            <View className="flex-row gap-3">
              <Button tone="secondary" style={{ flex: 1 }} onPress={requestCalendarAccess}>
                Refresh calendar access
              </Button>
              <Button tone="secondary" style={{ flex: 1 }} onPress={requestNotificationAccess}>
                Refresh notifications
              </Button>
            </View>
            {notificationPreferences.map((preference) => (
              <Pressable
                key={preference.id}
                className="flex-row items-center justify-between rounded-[22px] border border-[#DED7CB] bg-[#F8F6F1] px-4 py-4"
                onPress={() =>
                  updateNotificationPreference(preference.reminderType, !preference.enabled)
                }
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
                className="rounded-[24px] border px-4 py-4"
                onPress={() =>
                  saveProductPreferences({ ...productPreferences, themePreset: preset.id })
                }
                style={{
                  backgroundColor: preset.colors.background.elevated,
                  borderColor:
                    productPreferences.themePreset === preset.id
                      ? preset.colors.text.primary
                      : preset.colors.border.subtle,
                }}
              >
                <AppText variant="section">{preset.label}</AppText>
                <AppText tone="secondary" style={{ marginTop: 6 }}>
                  {preset.description}
                </AppText>
              </Pressable>
            ))}
          </View>
        </Surface>
      </View>
    </Screen>
  );
}

const fieldStyle = {
  flex: 1,
  minHeight: 52,
  borderRadius: 22,
  borderWidth: 1,
  borderColor: "#DDD8D0",
  backgroundColor: "#F8F6F1",
  paddingHorizontal: 16,
  paddingVertical: 14,
  color: "#18181A",
  fontSize: 15,
} as const;
