import { NativeStackScreenProps } from "@react-navigation/native-stack";
import { useState } from "react";
import { View } from "react-native";

import { CompactTimelineRow } from "../../components/navigation/CompactTimelineRow";
import { CapacityInsight } from "../../components/today/CapacityInsight";
import { IntegrationStatusCard } from "../../components/today/IntegrationStatusCard";
import { ScheduleContext } from "../../components/today/ScheduleContext";
import { Button } from "../../components/ui/Button";
import { EmptyStateCard } from "../../components/ui/EmptyStateCard";
import { Pill } from "../../components/ui/Pill";
import { Screen } from "../../components/ui/Screen";
import { Surface } from "../../components/ui/Surface";
import { AppText } from "../../components/ui/Text";
import { TaskActionType } from "../../domain/models";
import { useAppStore } from "../../state/useAppStore";
import { formatTimeLabel, formatTimeRangeLabel } from "../../utils/date";
import { TodayStackParamList } from "../../navigation/types";

const actionLabelMap: Record<TaskActionType, string> = {
  start: "Start now",
  complete: "Mark done",
  skip: "Skip",
  miss: "Mark missed",
  defer: "Move later",
  unschedule: "Unschedule",
};

function TaskActionButton({
  action,
  taskId,
  busyTaskId,
  onPress,
}: {
  action: TaskActionType;
  taskId: string;
  busyTaskId: string | null;
  onPress: (taskId: string, action: TaskActionType) => Promise<void>;
}) {
  const tone =
    action === "start" || action === "complete"
      ? "primary"
      : action === "defer"
        ? "secondary"
        : "tertiary";

  return (
    <Button
      busy={busyTaskId === taskId}
      tone={tone}
      onPress={() => void onPress(taskId, action)}
    >
      {actionLabelMap[action]}
    </Button>
  );
}

export function TodayTimelineScreen({
  navigation,
}: NativeStackScreenProps<TodayStackParamList, "TodayTimeline">) {
  const today = useAppStore((state) => state.today);

  if (!today) {
    return (
      <Screen>
        <EmptyStateCard
          title="No timeline yet"
          body="Today's sessions are not available right now."
        />
      </Screen>
    );
  }

  return (
    <Screen>
      <View className="gap-5">
        <Surface tone="accent" className="gap-3">
          <AppText variant="title">Full timeline</AppText>
          <AppText tone="secondary">
            Every session stays compact here. Open one when you need context or an action.
          </AppText>
        </Surface>
        <View className="gap-3">
          {today.blocks.map((block) => (
            <CompactTimelineRow
              key={block.id}
              block={block}
              onPress={() =>
                navigation.navigate("TodaySessionDetail", {
                  blockId: block.id,
                })
              }
            />
          ))}
        </View>
      </View>
    </Screen>
  );
}

export function TodaySessionDetailScreen({
  route,
}: NativeStackScreenProps<TodayStackParamList, "TodaySessionDetail">) {
  const today = useAppStore((state) => state.today);
  const applyTaskAction = useAppStore((state) => state.applyTaskAction);
  const [busyTaskId, setBusyTaskId] = useState<string | null>(null);
  const [runtimeMessage, setRuntimeMessage] = useState<string | null>(null);

  const block = today?.blocks.find((entry) => entry.id === route.params.blockId) ?? null;

  async function handleTaskAction(taskId: string, action: TaskActionType) {
    setBusyTaskId(taskId);
    setRuntimeMessage(null);

    try {
      await applyTaskAction(taskId, action);
    } catch (error) {
      setRuntimeMessage(
        error instanceof Error
          ? error.message
          : "That change could not be applied to today's plan.",
      );
    } finally {
      setBusyTaskId(null);
    }
  }

  if (!today || !block) {
    return (
      <Screen>
        <EmptyStateCard
          title="Session not found"
          body="That session is no longer available."
        />
      </Screen>
    );
  }

  return (
    <Screen>
      <View className="gap-5">
        <Surface tone={block.state === "active" ? "accent" : "default"} className="gap-4">
          <View className="gap-2">
            <View className="flex-row flex-wrap items-center gap-2">
              <Pill label={block.state.replace("_", " ")} tone={block.state === "active" ? "accent" : "quiet"} />
              {block.taskStatus ? <Pill label={block.taskStatus.replace("_", " ")} tone="quiet" /> : null}
            </View>
            <AppText variant="title">{block.title}</AppText>
            <AppText tone="secondary">
              {formatTimeRangeLabel(block.startsAt, block.endsAt)}.
            </AppText>
          </View>
          <AppText tone="secondary">
            {block.note ?? "Open the next useful move and keep the session simple."}
          </AppText>
        </Surface>

        <Surface className="gap-4">
          <AppText variant="section">Session details</AppText>
          <View className="gap-3">
            <AppText tone="secondary">
              {block.estimatedMinutes
                ? `${block.estimatedMinutes} planned minutes.`
                : "No estimated duration was saved for this block."}
            </AppText>
            <AppText tone="secondary">
              {block.state === "active"
                ? `This session is live until ${formatTimeLabel(block.endsAt)}.`
                : `The session begins at ${formatTimeLabel(block.startsAt)}.`}
            </AppText>
          </View>
        </Surface>

        {block.taskId && block.actions.length > 0 ? (
          <Surface className="gap-4">
            <AppText variant="section">What to do next</AppText>
            <View className="gap-3">
              {block.actions.map((action) => (
                <TaskActionButton
                  key={action}
                  action={action}
                  taskId={block.taskId as string}
                  busyTaskId={busyTaskId}
                  onPress={handleTaskAction}
                />
              ))}
            </View>
          </Surface>
        ) : null}

        {runtimeMessage ? (
          <AppText tone="tertiary" variant="caption">
            {runtimeMessage}
          </AppText>
        ) : null}
      </View>
    </Screen>
  );
}

export function TodayCapacityScreen() {
  const today = useAppStore((state) => state.today);

  if (!today) {
    return (
      <Screen>
        <EmptyStateCard
          title="No capacity detail yet"
          body="Today's capacity snapshot is not available."
        />
      </Screen>
    );
  }

  return (
    <Screen>
      <View className="gap-5">
        <CapacityInsight capacity={today.capacity} focus={today.focus} />
        <Surface className="gap-4">
          <AppText variant="section">Read on the day</AppText>
          <View className="gap-3">
            <AppText tone="secondary">
              {today.capacity.unusedCapacityMinutes > 0
                ? `${today.capacity.unusedCapacityMinutes} minutes are still open. Protect them for the best next move, not filler.`
                : "The day is already committed. If something slips, replan instead of forcing more in."}
            </AppText>
            <AppText tone="secondary">
              {today.capacity.overloadWarning
                ? "The planner already held work back to avoid overload."
                : "The current shape still fits inside the planned guardrails."}
            </AppText>
          </View>
        </Surface>
      </View>
    </Screen>
  );
}

export function TodayContextScreen() {
  const today = useAppStore((state) => state.today);
  const calendarConnectionState = useAppStore((state) => state.calendarConnectionState);
  const notificationPermissionStatus = useAppStore(
    (state) => state.notificationPermissionStatus,
  );
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

  if (!today) {
    return (
      <Screen>
        <EmptyStateCard
          title="No context yet"
          body="Today's surrounding conditions are not available."
        />
      </Screen>
    );
  }

  return (
    <Screen>
      <View className="gap-5">
        <Surface tone="accent" className="gap-3">
          <AppText variant="title">Context around the day</AppText>
          <AppText tone="secondary">{today.integration.calendarDetail}</AppText>
        </Surface>

        <Surface className="gap-4">
          <AppText variant="section">Scheduling context</AppText>
          <ScheduleContext items={today.scheduleContext} />
        </Surface>

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
              ? (integrationBusy as "calendar" | "notifications" | "refresh")
              : null
          }
        />

        {runtimeMessage ? (
          <AppText tone="tertiary" variant="caption">
            {runtimeMessage}
          </AppText>
        ) : null}
      </View>
    </Screen>
  );
}
