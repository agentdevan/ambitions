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
      <View className="gap-2">
        <View className="flex-row flex-wrap gap-2">
          <Pill label="Today plan" tone="accent" />
          <Pill label={`${blocks.length} scheduled sessions`} tone="accent" />
        </View>
        <AppText variant="section">A believable shape for the day</AppText>
        <AppText tone="secondary">
          Each block is presented as an action surface instead of a flat schedule row.
        </AppText>
      </View>

      <View className="gap-3">
        {blocks.length === 0 ? (
          <AppText tone="secondary">
            No tasks were scheduled into believable windows for this day.
          </AppText>
        ) : null}
        {blocks.map((block) => (
          <Surface
            key={block.id}
            className="gap-4"
            tone={block.state === "active" ? "accent" : "sunken"}
          >
            <View className="flex-row items-start justify-between gap-3">
              <View className="flex-1 gap-2">
                <View className="flex-row flex-wrap gap-2">
                  <Pill label={`${block.startsAt} - ${block.endsAt}`} tone="quiet" />
                  <Pill label={block.state} tone={block.state === "active" ? "accent" : "neutral"} />
                </View>
                <AppText variant="section">{block.title}</AppText>
                {block.note ? (
                  <AppText tone="secondary" style={{ maxWidth: 280 }}>
                    {block.note}
                  </AppText>
                ) : null}
              </View>
              <View
                className="h-10 w-10 items-center justify-center rounded-full"
                style={{ backgroundColor: `${stateAccentMap[block.state]}18` }}
              >
                <View
                  className="h-3 w-3 rounded-full"
                  style={{ backgroundColor: stateAccentMap[block.state] }}
                />
              </View>
            </View>

            <View className="flex-row flex-wrap gap-2">
              {block.taskStatus ? (
                <Pill label={block.taskStatus.replaceAll("_", " ")} />
              ) : null}
              {block.estimatedMinutes ? (
                <Pill label={`${block.estimatedMinutes} min`} tone="quiet" />
              ) : null}
            </View>

            {block.taskId && block.actions.length > 0 ? (
              <View className="flex-row flex-wrap gap-2 pt-1">
                {block.actions.map((action) => (
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
            ) : null}
          </Surface>
        ))}
      </View>
    </Surface>
  );
}
