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
import { Screen } from "../../components/ui/Screen";
import { AppText } from "../../components/ui/Text";
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
  const [busyTaskId, setBusyTaskId] = useState<string | null>(null);
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

        {runtimeMessage ? (
          <AppText tone="tertiary" variant="caption">
            {runtimeMessage}
          </AppText>
        ) : null}
        {integrationBusy ? (
          <AppText tone="tertiary" variant="caption">
            Updating live context...
          </AppText>
        ) : null}

        <View className="pb-2 pt-1">
          <AppText tone="tertiary" variant="caption">
            Calendar writes, account sync, and broader automation remain deferred. This release
            reads live context and keeps reminders intentionally sparse.
          </AppText>
        </View>
      </View>
    </Screen>
  );
}
