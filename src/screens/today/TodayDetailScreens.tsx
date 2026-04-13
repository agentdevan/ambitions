import { NativeStackScreenProps } from "@react-navigation/native-stack";
import { useMemo, useState } from "react";
import { View } from "react-native";

import {
  DetailHero,
  DetailMetaGroup,
  DetailSection,
  DetailSummaryStrip,
  QuietMetaLine,
} from "../../components/detail/DetailPrimitives";
import { CompactTimelineRow } from "../../components/navigation/CompactTimelineRow";
import { DrillInRow } from "../../components/navigation/DrillInRow";
import { CapacityInsight } from "../../components/today/CapacityInsight";
import { IntegrationStatusCard } from "../../components/today/IntegrationStatusCard";
import { ScheduleContext } from "../../components/today/ScheduleContext";
import { Button } from "../../components/ui/Button";
import { EmptyStateCard } from "../../components/ui/EmptyStateCard";
import { Pill } from "../../components/ui/Pill";
import { Screen } from "../../components/ui/Screen";
import { Surface } from "../../components/ui/Surface";
import { AppText } from "../../components/ui/Text";
import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
import { GoalMilestoneStatus, GoalStatus, TaskActionType, TaskStatus } from "../../domain/models";
import { TodayStackParamList } from "../../navigation/types";
import { useAppStore } from "../../state/useAppStore";
import { TodayTaskBlock } from "../../state/viewModels/today";
import { formatTimeLabel, formatTimeRangeLabel } from "../../utils/date";

const actionLabelMap: Record<TaskActionType, string> = {
  start: "Start now",
  complete: "Mark done",
  skip: "Skip",
  miss: "Mark missed",
  defer: "Move later",
  unschedule: "Unschedule",
};

const statusLabelMap: Record<TaskStatus, string> = {
  inbox: "Inbox",
  ready: "Ready",
  unscheduled: "Unscheduled",
  scheduled: "Scheduled",
  in_progress: "In progress",
  completed: "Completed",
  skipped: "Skipped",
  missed: "Missed",
  deferred: "Deferred",
  split: "Split",
  substituted: "Substituted",
  cancelled: "Cancelled",
};

const blockStateLabelMap: Record<TodayTaskBlock["state"], string> = {
  active: "In progress now",
  complete: "Completed",
  scheduled: "Scheduled next",
  rolled: "Rolled forward",
  deferred: "Deferred",
  cancelled: "Removed",
};

function ActionButton({
  action,
  taskId,
  busyTaskId,
  onPress,
  tone = "primary",
}: {
  action: TaskActionType;
  taskId: string;
  busyTaskId: string | null;
  onPress: (taskId: string, action: TaskActionType) => Promise<void>;
  tone?: "primary" | "secondary" | "inline";
}) {
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

function getActionHierarchy(actions: TaskActionType[]) {
  const primary =
    actions.find((action) => action === "start") ??
    actions.find((action) => action === "complete") ??
    actions.find((action) => action === "defer") ??
    null;

  const secondary = actions.filter(
    (action) => action !== primary && (action === "complete" || action === "defer"),
  );

  return {
    primary,
    secondary: secondary.slice(0, 1),
  };
}

function TimelineGroup({
  title,
  description,
  blocks,
  onOpen,
}: {
  title: string;
  description: string;
  blocks: TodayTaskBlock[];
  onOpen: (blockId: string) => void;
}) {
  if (blocks.length === 0) {
    return null;
  }

  return (
    <DetailSection title={title} description={description}>
      <View className="gap-3">
        {blocks.map((block) => (
          <CompactTimelineRow key={block.id} block={block} onPress={() => onOpen(block.id)} />
        ))}
      </View>
    </DetailSection>
  );
}

function OpportunityOptionCard({
  title,
  detail,
  fitLabel,
  durationLabel,
  actionLabel,
  busy,
  onPress,
}: {
  title: string;
  detail: string;
  fitLabel: string;
  durationLabel: string;
  actionLabel: string;
  busy: boolean;
  onPress: () => Promise<void>;
}) {
  const theme = useResolvedTheme();

  return (
    <Surface tone="sunken" className="gap-4 mb-0">
      <View className="gap-2">
        <View className="flex-row flex-wrap items-center gap-2">
          <AppText variant="section">{title}</AppText>
          <Pill label={durationLabel} tone="quiet" />
          <Pill label={fitLabel} tone="accent" />
        </View>
        <AppText tone="secondary">{detail}</AppText>
      </View>
      <View
        className="rounded-[18px] px-3 py-3"
        style={{
          backgroundColor: theme.colors.background.canvas,
          borderWidth: 1,
          borderColor: theme.colors.border.subtle,
        }}
      >
        <Button busy={busy} onPress={() => void onPress()}>
          {actionLabel}
        </Button>
      </View>
    </Surface>
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
          body="Today's sessions aren't ready."
        />
      </Screen>
    );
  }

  const grouped = {
    now: today.blocks.filter((block) => block.state === "active"),
    next: today.blocks.filter((block) =>
      block.state === "scheduled" || block.state === "rolled",
    ),
    later: today.blocks.filter((block) => block.state === "deferred"),
    done: today.blocks.filter(
      (block) => block.state === "complete" || block.state === "cancelled",
    ),
  };

  return (
    <Screen>
      <View className="gap-6">
        <DetailHero
          eyebrow="Today"
          title="Full timeline"
          description="The protected shape of today."
          meta={
            <DetailSummaryStrip
              items={[
                {
                  label: "Sessions",
                  value: String(today.blocks.length),
                  detail: "Blocks in today's plan",
                },
                {
                  label: "Open time",
                  value:
                    today.capacity.unusedCapacityMinutes > 0
                      ? `${today.capacity.unusedCapacityMinutes} min`
                      : "None",
                  detail: "Still available today",
                },
              ]}
            />
          }
        />

        <TimelineGroup
          title="Now"
          description="What is live now, or the cleanest immediate re-entry."
          blocks={[...grouped.now, ...grouped.next.slice(0, Math.max(0, 1 - grouped.now.length))]}
          onOpen={(blockId) => navigation.navigate("TodaySessionDetail", { blockId })}
        />

        <TimelineGroup
          title="Next"
          description="Protected sessions that are already holding the day."
          blocks={grouped.now.length > 0 ? grouped.next : grouped.next.slice(1)}
          onOpen={(blockId) => navigation.navigate("TodaySessionDetail", { blockId })}
        />

        <TimelineGroup
          title="Later"
          description="Later sessions that have shifted or can still move."
          blocks={grouped.later}
          onOpen={(blockId) => navigation.navigate("TodaySessionDetail", { blockId })}
        />

        <TimelineGroup
          title="Done"
          description="Completed or cleared."
          blocks={grouped.done}
          onOpen={(blockId) => navigation.navigate("TodaySessionDetail", { blockId })}
        />
      </View>
    </Screen>
  );
}

export function TodaySessionDetailScreen({
  route,
  navigation,
}: NativeStackScreenProps<TodayStackParamList, "TodaySessionDetail">) {
  const today = useAppStore((state) => state.today);
  const applyTaskAction = useAppStore((state) => state.applyTaskAction);
  const allTasks = useAppStore((state) => state.allTasks);
  const goals = useAppStore((state) => state.goals);
  const milestones = useAppStore((state) => state.milestones);
  const [busyTaskId, setBusyTaskId] = useState<string | null>(null);
  const [runtimeMessage, setRuntimeMessage] = useState<string | null>(null);

  const block = today?.blocks.find((entry) => entry.id === route.params.blockId) ?? null;
  const linkedTask = allTasks.find((task) => task.id === block?.taskId) ?? null;
  const linkedGoal = goals.find((goal) => goal.id === linkedTask?.goalId) ?? null;
  const linkedMilestone = milestones.find(
    (milestone) => milestone.id === linkedTask?.milestoneId,
  ) ?? null;

  const { primary, secondary } = useMemo(
    () => getActionHierarchy(block?.actions ?? []),
    [block?.actions],
  );

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
          body="That session isn't available."
        />
      </Screen>
    );
  }

  const goalStateLabel = linkedGoal
    ? linkedGoal.status === GoalStatus.Active
      ? "Active goal"
      : linkedGoal.status === GoalStatus.Paused
        ? "Paused goal"
        : linkedGoal.status === GoalStatus.Completed
          ? "Completed goal"
          : "Archived goal"
    : "No linked goal";

  const milestoneStateLabel = linkedMilestone
    ? linkedMilestone.status === GoalMilestoneStatus.InProgress
      ? "Milestone in progress"
      : linkedMilestone.status === GoalMilestoneStatus.Completed
        ? "Milestone completed"
        : linkedMilestone.status === GoalMilestoneStatus.Missed
          ? "Milestone missed"
          : linkedMilestone.status === GoalMilestoneStatus.Archived
            ? "Milestone archived"
            : "Milestone pending"
    : "No milestone";

  return (
    <Screen>
      <View className="gap-6">
        <DetailHero
          eyebrow="Session"
          title={block.title}
          description={block.note ?? "Keep it moving."}
          badges={
            <>
              <Pill
                label={blockStateLabelMap[block.state]}
                tone={block.state === "active" ? "accent" : "quiet"}
              />
              {block.taskStatus ? (
                <Pill label={statusLabelMap[block.taskStatus]} tone="quiet" />
              ) : null}
            </>
          }
          meta={
            <DetailMetaGroup
              items={[
                {
                  label: "Time",
                  value: formatTimeRangeLabel(block.startsAt, block.endsAt),
                },
                {
                  label: "Expected",
                  value: block.estimatedMinutes ? `${block.estimatedMinutes} min` : "No estimate",
                },
                {
                  label: "Goal",
                  value: linkedGoal?.title ?? "Unlinked session",
                },
                {
                  label: "Milestone",
                  value: linkedMilestone?.title ?? "Not tied to a milestone",
                },
              ]}
            />
          }
        />

        {block.taskId && primary ? (
          <Surface className="gap-4 mb-0">
            <View className="gap-1">
              <AppText variant="section">Next action</AppText>
              <AppText tone="secondary" variant="caption">
                Take the clearest next step from here.
              </AppText>
            </View>
            <ActionButton
              action={primary}
              taskId={block.taskId}
              busyTaskId={busyTaskId}
              onPress={handleTaskAction}
            />
            {secondary.length > 0 || linkedGoal ? (
              <View className="flex-row flex-wrap gap-3">
                {secondary.map((action) => (
                  <ActionButton
                    key={action}
                    action={action}
                    taskId={block.taskId as string}
                    busyTaskId={busyTaskId}
                    onPress={handleTaskAction}
                    tone="secondary"
                  />
                ))}
                {linkedGoal ? (
                  <Button
                    tone="inline"
                    onPress={() =>
                      (navigation.getParent() as any)?.navigate("Goals", {
                        screen: "GoalDetail",
                        params: { goalId: linkedGoal.id },
                      })
                    }
                  >
                    Open goal
                  </Button>
                ) : null}
              </View>
            ) : null}
          </Surface>
        ) : null}

        <DetailSection
          title="Session read"
          description="Key context."
        >
          <Surface className="gap-4 mb-0">
            <QuietMetaLine
              items={[
                block.state === "active"
                  ? `Live until ${formatTimeLabel(block.endsAt)}`
                  : `Starts at ${formatTimeLabel(block.startsAt)}`,
                goalStateLabel,
                milestoneStateLabel,
                linkedTask?.difficulty ? `${linkedTask.difficulty} effort` : "No effort label",
              ]}
            />
            <DetailSummaryStrip
              items={[
                {
                  label: "Why this exists",
                  value: linkedMilestone?.title ?? linkedGoal?.title ?? "Hold the next useful step",
                  detail:
                    linkedMilestone?.summary ??
                    linkedGoal?.summary ??
                    "This block protects the next meaningful move.",
                },
                {
                  label: "State",
                  value: blockStateLabelMap[block.state],
                  detail:
                    block.taskStatus && linkedTask
                      ? `${statusLabelMap[block.taskStatus]} task`
                      : "Session-level planning block",
                },
              ]}
            />
          </Surface>
        </DetailSection>

        <DetailSection
          title="Linked work"
          description="Open the connected goal or day."
        >
          <View className="gap-3">
            {linkedGoal ? (
              <DrillInRow
                title={linkedGoal.title}
                subtitle={
                  linkedMilestone?.title
                    ? `Inside ${linkedMilestone.title}`
                    : linkedGoal.summary ?? "Open the goal for milestones, progress, and edits."
                }
                detail={goalStateLabel}
                onPress={() =>
                  (navigation.getParent() as any)?.navigate("Goals", {
                    screen: "GoalDetail",
                    params: { goalId: linkedGoal.id },
                  })
                }
              />
            ) : null}
            <DrillInRow
              title="View in full timeline"
              subtitle="See the whole day"
              onPress={() => navigation.navigate("TodayTimeline")}
            />
          </View>
        </DetailSection>

        {runtimeMessage ? (
          <AppText tone="tertiary" variant="caption">
            {runtimeMessage}
          </AppText>
        ) : null}
      </View>
    </Screen>
  );
}

export function TodayOpenTimeScreen({
  navigation,
}: NativeStackScreenProps<TodayStackParamList, "TodayOpenTime">) {
  const today = useAppStore((state) => state.today);
  const applyTaskAction = useAppStore((state) => state.applyTaskAction);
  const [busyTaskId, setBusyTaskId] = useState<string | null>(null);
  const [runtimeMessage, setRuntimeMessage] = useState<string | null>(null);

  async function handleOptionAction(taskId: string, action: TaskActionType) {
    setBusyTaskId(taskId);
    setRuntimeMessage(null);

    try {
      await applyTaskAction(taskId, action);
    } catch (error) {
      setRuntimeMessage(
        error instanceof Error
          ? error.message
          : "That task could not be updated right now.",
      );
    } finally {
      setBusyTaskId(null);
    }
  }

  if (!today || !today.openWindow) {
    return (
      <Screen>
        <EmptyStateCard
          title="No open window right now"
          body="No free window right now."
        />
      </Screen>
    );
  }

  const primary = today.recommendation.options[0] ?? null;
  const nextBlock = today.next;

  return (
    <Screen>
      <View className="gap-6">
        <DetailHero
          eyebrow="Open time"
          title={
            today.openWindow.bucket === "tiny"
              ? "A short opening is available."
              : "This is the cleanest use of the open window."
          }
          description={
            today.openWindow.opensUntilLabel
              ? `${today.openWindow.availableMinutes} minutes are open until ${today.openWindow.opensUntilLabel}.`
              : `${today.openWindow.availableMinutes} minutes are still open today.`
          }
          badges={
            <>
              <Pill label={today.openWindow.label} tone="accent" />
              <Pill label={`Pressure: ${today.capacity.planPressure}`} tone="quiet" />
            </>
          }
          meta={
            <DetailSummaryStrip
              items={[
                {
                  label: "Window",
                  value: today.openWindow.label,
                  detail: today.openWindow.detail,
                },
                {
                  label: "Next",
                  value: nextBlock ? nextBlock.title : "No fixed next block",
                  detail: nextBlock
                    ? `${formatTimeLabel(nextBlock.startsAt)}`
                    : "This part of the day is flexible.",
                },
              ]}
            />
          }
        />

        {primary ? (
          <DetailSection
            title="Best fit"
            description="The most believable move for the room that is left."
          >
            <OpportunityOptionCard
              actionLabel={primary.actionLabel}
              busy={busyTaskId === primary.taskId}
              detail={primary.reason}
              durationLabel={`${primary.estimatedMinutes} min`}
              fitLabel={primary.fitLabel}
              title={primary.title}
              onPress={() => handleOptionAction(primary.taskId, primary.suggestedAction)}
            />
          </DetailSection>
        ) : (
          <Surface className="gap-3">
            <AppText variant="section">No strong fit right now</AppText>
            <AppText tone="secondary">
              Nothing honest fits this opening cleanly. Protect the space, reset, or let the next block arrive without forcing filler.
            </AppText>
          </Surface>
        )}

        {today.recommendation.options.length > 1 ? (
          <DetailSection
            title="Still fits"
            description="Other clean options, if you want a different move."
          >
            <View className="gap-3">
              {today.recommendation.options.slice(1).map((option) => (
                <OpportunityOptionCard
                  key={option.taskId}
                  actionLabel={option.actionLabel}
                  busy={busyTaskId === option.taskId}
                  detail={option.reason}
                  durationLabel={`${option.estimatedMinutes} min`}
                  fitLabel={option.fitLabel}
                  title={option.title}
                  onPress={() => handleOptionAction(option.taskId, option.suggestedAction)}
                />
              ))}
            </View>
          </DetailSection>
        ) : null}

        <DetailSection
          title="More context"
          description="Before you commit the window."
        >
          <View className="gap-3">
            {nextBlock ? (
              <DrillInRow
                title={nextBlock.title}
                subtitle="Next scheduled block"
                detail={formatTimeLabel(nextBlock.startsAt)}
                onPress={() =>
                  navigation.navigate("TodaySessionDetail", {
                    blockId: nextBlock.id,
                  })
                }
              />
            ) : null}
            <DrillInRow
              title="View full timeline"
              subtitle="See the whole day"
              onPress={() => navigation.navigate("TodayTimeline")}
            />
          </View>
        </DetailSection>

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
          body="Capacity isn't ready."
        />
      </Screen>
    );
  }

  return (
    <Screen>
      <View className="gap-6">
        <DetailHero
          eyebrow="Today"
          title="Capacity"
          description="How much room the day still honestly has."
          meta={
            <DetailSummaryStrip
              items={[
                {
                  label: "Usable",
                  value: `${today.capacity.usableMinutes} min`,
                  detail: "Estimated workable time",
                },
                {
                  label: "Open",
                  value:
                    today.capacity.unusedCapacityMinutes > 0
                      ? `${today.capacity.unusedCapacityMinutes} min`
                      : "None",
                  detail: "Still free today",
                },
              ]}
            />
          }
        />
        <CapacityInsight capacity={today.capacity} focus={today.focus} />
        <Surface className="gap-3 mb-0">
          <AppText variant="section">Read on the day</AppText>
          <AppText tone="secondary">
            {today.capacity.unusedCapacityMinutes > 0
              ? `${today.capacity.unusedCapacityMinutes} minutes are still open. Protect them for the cleanest next move, not filler.`
              : "The day is already committed. If something slips, recover it instead of forcing more in."}
          </AppText>
          <AppText tone="secondary">
            {today.capacity.overloadWarning
              ? "The planner already held work back to avoid overload."
              : "The current shape still fits inside the planned guardrails."}
          </AppText>
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
          body="Context isn't ready."
        />
      </Screen>
    );
  }

  return (
    <Screen>
      <View className="gap-6">
        <DetailHero
          eyebrow="Today"
          title="Context"
          description={today.integration.calendarDetail}
          badges={
            <Pill
              label={today.integration.calendarStatusLabel}
              tone={today.integration.usingLiveCalendar ? "accent" : "quiet"}
            />
          }
        />

        <Surface className="gap-4 mb-0">
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
