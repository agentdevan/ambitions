import { View } from "react-native";

import { TaskActionType } from "../../domain/models";
import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
import { TodayTaskBlock } from "../../state/viewModels/today";
import { Button } from "../ui/Button";
import { Surface } from "../ui/Surface";
import { AppText } from "../ui/Text";
import { formatTimeRangeLabel } from "../../utils/date";

interface TimelinePlanProps {
  blocks: TodayTaskBlock[];
  onTaskAction: (taskId: string, action: TaskActionType) => void;
  busyTaskId?: string | null;
}

const actionLabels: Record<TaskActionType, string> = {
  start: "Start now",
  complete: "Mark done",
  skip: "Skip",
  miss: "Missed",
  defer: "Move later",
  unschedule: "Unschedule",
};

const stateLabels: Record<TodayTaskBlock["state"], string> = {
  complete: "Complete",
  scheduled: "Scheduled",
  active: "In progress",
  rolled: "Rolled forward",
  deferred: "Deferred",
  cancelled: "Removed",
};

export function TimelinePlan({
  blocks,
  onTaskAction,
  busyTaskId = null,
}: TimelinePlanProps) {
  const theme = useResolvedTheme();
  const stateAccentMap = {
    complete: theme.colors.semantic.success,
    scheduled: theme.colors.accent.muted,
    active: theme.colors.accent.primary,
    rolled: theme.colors.semantic.warning,
    deferred: theme.colors.semantic.muted,
    cancelled: theme.colors.border.strong,
  };

  return (
    <Surface className="gap-6">
      <View className="flex-row items-end justify-between gap-3">
        <View className="gap-2">
          <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
            Timeline
          </AppText>
          <AppText variant="title">Today&apos;s timeline</AppText>
          <AppText tone="secondary">
            See each work block in order, then take the next useful action without extra clutter.
          </AppText>
        </View>
        <AppText tone="secondary" variant="caption">
          {blocks.length} session{blocks.length === 1 ? "" : "s"}
        </AppText>
      </View>

      <View
        className="gap-4 rounded-[20px] px-1 py-1"
        style={{
          backgroundColor: theme.colors.background.sunken,
          borderWidth: 1,
          borderColor: theme.colors.border.strong,
        }}
      >
        {blocks.length === 0 ? (
          <AppText tone="secondary">
            Nothing was scheduled into believable windows for today.
          </AppText>
        ) : null}
        {blocks.map((block) => (
          <Surface
            key={block.id}
            className="gap-6"
            tone={block.state === "active" ? "accent" : "default"}
            style={{
              marginBottom: 0,
              borderColor:
                block.state === "active" ? "#AFC3A7" : `${stateAccentMap[block.state]}33`,
            }}
          >
            <View className="gap-6">
              <View className="flex-row items-start justify-between gap-3">
                <View className="flex-1 gap-3">
                  <View className="flex-row flex-wrap items-center gap-x-4 gap-y-2">
                    <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                      {formatTimeRangeLabel(block.startsAt, block.endsAt)}
                    </AppText>
                    <AppText tone="secondary" variant="caption">
                      {stateLabels[block.state]}
                    </AppText>
                  </View>
                  <AppText variant="title">{block.title}</AppText>
                  {block.note ? (
                    <AppText tone="secondary" variant="caption">
                      {block.note}
                    </AppText>
                  ) : null}
                </View>
                <View
                  className="h-12 w-12 items-center justify-center rounded-[18px]"
                  style={{ backgroundColor: `${stateAccentMap[block.state]}20`, borderWidth: 1, borderColor: `${stateAccentMap[block.state]}38` }}
                >
                  <View
                    className="h-3 w-3 rounded-full"
                    style={{ backgroundColor: stateAccentMap[block.state] }}
                  />
                </View>
              </View>

              <View
                className="gap-2 rounded-[18px] px-3 py-3"
                style={{
                  backgroundColor:
                    block.state === "active"
                      ? theme.colors.background.elevated
                      : theme.colors.background.canvas,
                  borderWidth: 1,
                  borderColor:
                    block.state === "active"
                      ? `${theme.colors.accent.primary}44`
                      : theme.colors.border.subtle,
                }}
              >
                <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                  Session details
                </AppText>
                <View className="flex-row flex-wrap gap-x-4 gap-y-2">
                  {block.taskStatus ? (
                    <AppText tone="secondary" variant="caption">
                      {block.taskStatus.replaceAll("_", " ")}
                    </AppText>
                  ) : null}
                  {block.estimatedMinutes ? (
                    <AppText tone="secondary" variant="caption">
                      {block.estimatedMinutes} min
                    </AppText>
                  ) : null}
                </View>
              </View>

              {block.taskId && block.actions.length > 0 ? (
                <View
                  className="gap-3 rounded-[18px] px-3 py-3"
                  style={{
                    backgroundColor: theme.colors.background.canvas,
                    borderWidth: 1,
                    borderColor: theme.colors.border.subtle,
                  }}
                >
                  <View className="flex-row items-center justify-between gap-3">
                    <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                      Actions
                    </AppText>
                    <AppText tone="tertiary" variant="caption">
                      Next step
                    </AppText>
                  </View>
                  <View className="flex-row flex-wrap gap-2">
                    {block.actions.slice(0, 2).map((action) => (
                      <Button
                        key={`${block.id}-${action}`}
                        onPress={() => onTaskAction(block.taskId as string, action)}
                        disabled={busyTaskId === block.taskId}
                        tone={
                          action === "start" || action === "complete"
                            ? "primary"
                            : action === "defer"
                              ? "secondary"
                              : "tertiary"
                        }
                        size="compact"
                      >
                        {busyTaskId === block.taskId ? "Working..." : actionLabels[action]}
                      </Button>
                    ))}
                  </View>
                </View>
              ) : null}
            </View>
          </Surface>
        ))}
      </View>
    </Surface>
  );
}
