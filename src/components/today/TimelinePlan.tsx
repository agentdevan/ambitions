import { View } from "react-native";

import { TaskActionType } from "../../domain/models";
import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
import { TodayTaskBlock } from "../../state/viewModels/today";
import { Button } from "../ui/Button";
import { Pill } from "../ui/Pill";
import { Surface } from "../ui/Surface";
import { AppText } from "../ui/Text";

interface TimelinePlanProps {
  blocks: TodayTaskBlock[];
  onTaskAction: (taskId: string, action: TaskActionType) => void;
  busyTaskId?: string | null;
}

const actionLabels: Record<TaskActionType, string> = {
  start: "Start",
  complete: "Done",
  skip: "Skip",
  miss: "Missed",
  defer: "Defer",
  unschedule: "Unscheduled",
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
          <View className="flex-row flex-wrap gap-2">
            <Pill label="Today plan" tone="accent" />
            <Pill label={`${blocks.length} scheduled sessions`} tone="quiet" />
          </View>
          <AppText variant="title">Task timeline</AppText>
          <AppText tone="secondary">
            The main work area keeps each session bounded, readable, and action-ready.
          </AppText>
        </View>
      </View>

      <View
        className="gap-4 rounded-[30px] px-3.5 py-3.5"
        style={{ backgroundColor: "#E7DDD1", borderWidth: 1, borderColor: "#D0BFAE" }}
      >
        {blocks.length === 0 ? (
          <AppText tone="secondary">
            No tasks were scheduled into believable windows for this day.
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
                  <View className="flex-row flex-wrap gap-2">
                    <Pill label={`${block.startsAt} - ${block.endsAt}`} tone="quiet" />
                    <Pill label={block.state} tone={block.state === "active" ? "accent" : "neutral"} />
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
                className="gap-3 rounded-[20px] px-3 py-3"
                style={{ backgroundColor: block.state === "active" ? "#F5FAF3" : "#F5EDE3", borderWidth: 1, borderColor: block.state === "active" ? "#C8D8C1" : "#DECFBF" }}
              >
                <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                  Session details
                </AppText>
                <View className="flex-row flex-wrap gap-2">
                {block.taskStatus ? (
                  <Pill label={block.taskStatus.replaceAll("_", " ")} />
                ) : null}
                {block.estimatedMinutes ? (
                  <Pill label={`${block.estimatedMinutes} min`} tone="quiet" />
                ) : null}
                </View>
              </View>

              {block.taskId && block.actions.length > 0 ? (
                <View
                  className="gap-3 rounded-[20px] px-3 py-3"
                  style={{ backgroundColor: "#F7F1E8", borderWidth: 1, borderColor: "#DDCDBD" }}
                >
                  <View className="flex-row items-center justify-between gap-3">
                    <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                      Actions
                    </AppText>
                    <AppText tone="tertiary" variant="caption">
                      Next move
                    </AppText>
                  </View>
                  <View className="flex-row flex-wrap gap-2">
                    {block.actions.slice(0, 2).map((action) => (
                      <Button
                        key={`${block.id}-${action}`}
                        onPress={() => onTaskAction(block.taskId as string, action)}
                        disabled={busyTaskId === block.taskId}
                        tone={action === "start" || action === "complete" ? "primary" : "secondary"}
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
