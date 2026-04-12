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
import { IntegrationStatusCard } from "../../components/today/IntegrationStatusCard";
import { GroupedActivityTimeline, MomentumBars } from "../../components/history/ActivityTimeline";
import { Button } from "../../components/ui/Button";
import { EmptyStateCard } from "../../components/ui/EmptyStateCard";
import { OptionChip } from "../../components/ui/OptionChip";
import { ProgressBar } from "../../components/ui/ProgressBar";
import { Screen } from "../../components/ui/Screen";
import { SegmentedControl } from "../../components/ui/SegmentedControl";
import { Surface } from "../../components/ui/Surface";
import { AppText } from "../../components/ui/Text";
import { TextField } from "../../components/ui/TextField";
import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
import { accentThemeOptions, appearanceModeOptions } from "../../product/theme";
import { useAppStore } from "../../state/useAppStore";
import { buildActivityFeed, groupActivityByDate, summarizeInsights } from "../../services/history/selectors";
import {
  formatTimeLabel,
  formatTimeRangeLabel,
  normalizeTimeString,
} from "../../utils/date";
import { isSupabaseConfigured } from "../../services/account/supabaseConfig";

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

export function ProfileHistoryScreen() {
  const goals = useAppStore((state) => state.goals);
  const milestones = useAppStore((state) => state.milestones);
  const tasks = useAppStore((state) => state.allTasks);
  const activityEvents = useAppStore((state) => state.activityEvents);

  const feed = buildActivityFeed(activityEvents, tasks, milestones);
  const groups = groupActivityByDate(feed.slice(0, 18));
  const summary = summarizeInsights({ goals, tasks, milestones, events: feed });

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
              summary.planCopy,
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
            Calendar and reminders.
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
          <AppText tone="secondary">Manage reminder behavior.</AppText>
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
        <EmptyStateCard title="Preferences unavailable" body="Planning is still loading." />
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
          <AppText tone="secondary">Tune the planner.</AppText>
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

type AuthMode = "create" | "sign_in";
type AccountFieldKey = "displayName" | "email" | "password";

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

export function ProfileAccountScreen() {
  const account = useAppStore((state) => state.account);
  const authState = useAppStore((state) => state.authState);
  const attachmentState = useAppStore((state) => state.attachmentState);
  const syncState = useAppStore((state) => state.syncState);
  const syncConflicts = useAppStore((state) => state.syncConflicts);
  const createAccount = useAppStore((state) => state.createAccount);
  const signIn = useAppStore((state) => state.signIn);
  const signOut = useAppStore((state) => state.signOut);
  const attachLocalDataToAccount = useAppStore((state) => state.attachLocalDataToAccount);
  const deferLocalDataAttachment = useAppStore((state) => state.deferLocalDataAttachment);
  const syncAccountData = useAppStore((state) => state.syncAccountData);
  const theme = useResolvedTheme();
  const insets = useSafeAreaInsets();
  const [accountBusy, setAccountBusy] = useState<string | null>(null);
  const [runtimeMessage, setRuntimeMessage] = useState<string | null>(null);
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
      setRuntimeMessage(null);
      return;
    }

    if (authState?.lastError) {
      setRuntimeMessage(authState.lastError);
    }
  }, [account, authState?.lastError]);

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

    if (field === "password" && canSubmitAuth && authConfigured) {
      void submitAuth();
    }
  }

  async function submitAuth() {
    setTouchedFields({
      displayName: true,
      email: true,
      password: true,
    });

    if (!canSubmitAuth || !authConfigured) {
      return;
    }

    await runAccountAction(
      "auth",
      () =>
        authMode === "create"
          ? createAccount({
              email: email.trim(),
              password,
              displayName: displayName.trim(),
            })
          : signIn({
              email: email.trim(),
              password,
            }),
      authMode === "create"
        ? "Couldn’t create your account. Try again."
        : "Couldn’t sign in. Try again.",
    );
  }

  const nameValid = displayName.trim().length > 0;
  const emailValid = validateEmail(email);
  const passwordValid = password.trim().length >= 8;
  const canSubmitAuth =
    emailValid && passwordValid && (authMode === "sign_in" || nameValid);
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
      ? "Create an account to keep your plans and history available across devices."
      : "Sign in to continue syncing on this device.";
  const unavailableMessage =
    authState?.lastError ?? "Connection unavailable right now.";

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
          <Surface tone="accent" className="gap-3">
            <AppText variant="title">Account</AppText>
            <AppText tone="secondary">
              Understand your account status, connect when you&apos;re ready, and keep your data safe.
            </AppText>
          </Surface>
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
                      setRuntimeMessage(null);
                    }}
                  />
                </View>
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
                      onChangeText={setDisplayName}
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
                    onChangeText={setEmail}
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
                    onChangeText={setPassword}
                    onFocus={() => focusField("password")}
                    onSubmitEditing={() => handleSubmitEditing("password")}
                    placeholder="At least 8 characters"
                    returnKeyType={canSubmitAuth ? "go" : "done"}
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
                    {authMode === "create" ? "What you need" : "Before you sign in"}
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
                    disabled={!canSubmitAuth}
                    onPress={() => void submitAuth()}
                  >
                    {authMode === "create" ? "Create account" : "Sign in"}
                  </Button>
                  <AppText tone="tertiary" variant="caption">
                    Your data stays on this device until you connect an account.
                  </AppText>
                </View>
              </Surface>
            )
          ) : null}
          {runtimeMessage && (account || authConfigured) ? (
            <Surface
              tone="sunken"
              className="gap-2"
              style={{
                borderColor: theme.colors.semantic.warning,
              }}
            >
              <AppText variant="caption">Couldn&apos;t complete that action</AppText>
              <AppText tone="secondary" variant="caption">
                {runtimeMessage}
              </AppText>
            </Surface>
          ) : null}
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}
