import { AccountStatusCard } from "../../components/account/AccountStatusCard";
import { useState } from "react";
import { View } from "react-native";
import { useNavigation } from "@react-navigation/native";

import { CapacityInsight } from "../../components/today/CapacityInsight";
import { GuidancePanel } from "../../components/today/GuidancePanel";
import { IntegrationStatusCard } from "../../components/today/IntegrationStatusCard";
import { ProgressPanel } from "../../components/today/ProgressPanel";
import { ReplanSuggestionsPanel } from "../../components/today/ReplanSuggestionsPanel";
import { ScheduleContext } from "../../components/today/ScheduleContext";
import { TimelinePlan } from "../../components/today/TimelinePlan";
import { TodayHeader } from "../../components/today/TodayHeader";
import { UnscheduledTasksPanel } from "../../components/today/UnscheduledTasksPanel";
import { Button } from "../../components/ui/Button";
import { EmptyStateCard } from "../../components/ui/EmptyStateCard";
import { MetricCard } from "../../components/ui/MetricCard";
import { Screen } from "../../components/ui/Screen";
import { Pill } from "../../components/ui/Pill";
import { Surface } from "../../components/ui/Surface";
import { AppText } from "../../components/ui/Text";
import { getGoalReviewDraft } from "../../services/goals/metadata";
import { useAppStore } from "../../state/useAppStore";
import { formatLongDate } from "../../utils/date";

export function TodayScreen() {
  const navigation = useNavigation();
  const today = useAppStore((state) => state.today);
  const bootStatus = useAppStore((state) => state.bootStatus);
  const goals = useAppStore((state) => state.goals);
  const planDate = useAppStore((state) => state.planDate);
  const applyTaskAction = useAppStore((state) => state.applyTaskAction);
  const calendarConnectionState = useAppStore((state) => state.calendarConnectionState);
  const notificationPermissionStatus = useAppStore(
    (state) => state.notificationPermissionStatus,
  );
  const requestCalendarAccess = useAppStore((state) => state.requestCalendarAccess);
  const requestNotificationAccess = useAppStore((state) => state.requestNotificationAccess);
  const refreshIntegration = useAppStore((state) => state.refreshIntegration);
  const account = useAppStore((state) => state.account);
  const authState = useAppStore((state) => state.authState);
  const attachmentState = useAppStore((state) => state.attachmentState);
  const syncState = useAppStore((state) => state.syncState);
  const syncConflicts = useAppStore((state) => state.syncConflicts);
  const signInWithApple = useAppStore((state) => state.signInWithApple);
  const attachLocalDataToAccount = useAppStore((state) => state.attachLocalDataToAccount);
  const deferLocalDataAttachment = useAppStore((state) => state.deferLocalDataAttachment);
  const syncAccountData = useAppStore((state) => state.syncAccountData);
  const [busyTaskId, setBusyTaskId] = useState<string | null>(null);
  const [integrationBusy, setIntegrationBusy] = useState<string | null>(null);
  const [accountBusy, setAccountBusy] = useState<string | null>(null);
  const [runtimeMessage, setRuntimeMessage] = useState<string | null>(null);
  const pendingReviewGoals = goals.filter((goal) => getGoalReviewDraft(goal) !== null);

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

  async function handleTaskAction(taskId: string, action: Parameters<typeof applyTaskAction>[1]) {
    setBusyTaskId(taskId);
    setRuntimeMessage(null);

    try {
      await applyTaskAction(taskId, action);
    } catch (error) {
      setRuntimeMessage(
        error instanceof Error
          ? error.message
          : "The task action could not be applied to today's plan.",
      );
    } finally {
      setBusyTaskId(null);
    }
  }

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

  if (!today) {
    const emptyBody =
      bootStatus === "loading"
        ? "Loading the local planning foundation."
        : goals.length === 0
          ? "Start with a goal. Ambitions will turn it into a calm first day instead of a blank planner."
          : "Your goals exist, but there is no generated day yet. Open Plan to regenerate from the current foundation.";

    return (
      <Screen>
        <View className="gap-4">
          <TodayHeader
            liveContext={false}
            dateLabel={bootStatus === "error" ? "Unable to load plan" : formatLongDate(planDate)}
          />
          <EmptyStateCard
            title={bootStatus === "loading" ? "Loading the planning layer" : "No plan yet"}
            body={emptyBody}
            tone="sunken"
            action={
              bootStatus !== "loading" ? (
                <View className="flex-row gap-3 pt-1">
                  <Button
                    tone="secondary"
                    style={{ flex: 1 }}
                    onPress={() => navigation.navigate("Goals" as never)}
                  >
                    Open goals
                  </Button>
                  <Button
                    tone="secondary"
                    style={{ flex: 1 }}
                    onPress={() => navigation.navigate("Plan" as never)}
                  >
                    Open plan
                  </Button>
                </View>
              ) : null
            }
          />
        </View>
      </Screen>
    );
  }

  return (
    <Screen>
      <View className="gap-6">
        <TodayHeader
          dateLabel={formatLongDate(today.date)}
          liveContext={today.integration.usingLiveCalendar}
        />
        <Surface tone="sunken">
          <View className="gap-4">
            <View className="flex-row flex-wrap gap-2">
              <Pill label="Daily brief" tone="accent" />
              <Pill label={`${today.blocks.length} sessions`} tone="quiet" />
              <Pill label={`${today.unscheduled.length} held out`} tone="quiet" />
            </View>
            <AppText variant="section">{today.focus}</AppText>
            <View className="flex-row gap-3">
              <MetricCard label="On deck" value={String(today.blocks.length)} />
              <MetricCard label="Recovery" value={String(today.replanSuggestions.length)} />
              <MetricCard label="Done" value={String(today.progress.completed)} />
            </View>
          </View>
        </Surface>
        {pendingReviewGoals.length > 0 ? (
          <Surface>
            <View className="gap-3">
              <View className="flex-row flex-wrap gap-2">
                <Pill label="Recommended plan" tone="accent" />
                <Pill label={`${pendingReviewGoals.length} awaiting review`} />
              </View>
              <AppText variant="section">{pendingReviewGoals[0]?.title}</AppText>
              <AppText tone="secondary">
                A recommended plan or refresh is waiting for review. You can make a few light edits before accepting it.
              </AppText>
              <Button
                tone="secondary"
                onPress={() => navigation.navigate("Plan" as never)}
              >
                Open review
              </Button>
            </View>
          </Surface>
        ) : null}
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
            runAccountAction("sign_in", signInWithApple, "Sign in with Apple could not start.")
          }
          onAttach={() =>
            runAccountAction(
              "attach",
              attachLocalDataToAccount,
              "Local data could not be attached to the account.",
            )
          }
          onDefer={() =>
            runAccountAction(
              "defer",
              deferLocalDataAttachment,
              "The local-only path could not be preserved.",
            )
          }
          onSync={() =>
            runAccountAction("sync", () => syncAccountData(), "Account sync could not complete.")
          }
        />
        <IntegrationStatusCard
          calendarConnectionState={calendarConnectionState}
          notificationPermissionStatus={notificationPermissionStatus}
          onRequestCalendarAccess={() =>
            runIntegrationAction(
              "calendar",
              requestCalendarAccess,
              "Calendar access could not be refreshed.",
            )
          }
          onRequestNotificationAccess={() =>
            runIntegrationAction(
              "notifications",
              requestNotificationAccess,
              "Notification access could not be refreshed.",
            )
          }
          onRefreshIntegration={() =>
            runIntegrationAction(
              "refresh",
              () => refreshIntegration(today.date),
              "Calendar context could not be refreshed.",
            )
          }
          usingLiveCalendar={today.integration.usingLiveCalendar}
          calendarDetail={today.integration.calendarDetail}
          busyAction={
            integrationBusy === "calendar" ||
            integrationBusy === "notifications" ||
            integrationBusy === "refresh"
              ? integrationBusy
              : null
          }
        />
        <CapacityInsight capacity={today.capacity} focus={today.focus} />
        <TimelinePlan
          blocks={today.blocks}
          onTaskAction={handleTaskAction}
          busyTaskId={busyTaskId}
        />
        <UnscheduledTasksPanel tasks={today.unscheduled} />
        <ReplanSuggestionsPanel suggestions={today.replanSuggestions} />
        <GuidancePanel items={today.adaptiveGuidance} />
        <ScheduleContext items={today.scheduleContext} />
        <ProgressPanel
          completed={today.progress.completed}
          scheduled={today.progress.scheduled}
          recovery={today.progress.recovery}
        />

        {runtimeMessage || integrationBusy ? (
          <Surface tone="sunken">
            <View className="gap-2">
              {runtimeMessage ? (
                <AppText tone="secondary">{runtimeMessage}</AppText>
              ) : null}
              {integrationBusy ? (
                <AppText tone="tertiary" variant="caption">
                  Updating live context...
                </AppText>
              ) : null}
            </View>
          </Surface>
        ) : null}

        <Surface tone="sunken">
          <View className="gap-3">
            <View className="flex-row flex-wrap gap-2">
              <Pill label="Continuity scope" tone="quiet" />
            </View>
            <AppText tone="tertiary" variant="caption">
              Account sync covers goals, milestones, tasks, daily plans, preferences, and the
              adaptation profile. Notifications, permissions, and transient runtime state stay on the
              device.
            </AppText>
          </View>
        </Surface>
      </View>
    </Screen>
  );
}
