import { Pressable, View } from "react-native";

import { TaskActionType } from "../../domain/models";
import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
import { TodayTaskBlock } from "../../state/viewModels/today";
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
        <AppText tone="secondary" variant="caption">
          Time-blocked plan
        </AppText>
        <AppText variant="section">A believable shape for the day</AppText>
      </View>

      <View className="gap-1">
        {blocks.length === 0 ? (
          <AppText tone="secondary">
            No tasks were scheduled into believable windows for this day.
          </AppText>
        ) : null}
        {blocks.map((block, index) => (
          <View
            key={block.id}
            className="flex-row gap-4 py-4"
            style={{
              borderBottomWidth: index < blocks.length - 1 ? 1 : 0,
              borderBottomColor: theme.colors.border.subtle,
            }}
          >
            <View className="items-center pt-0.5">
              <AppText variant="micro" tone="tertiary">
                {block.startsAt}
              </AppText>
              <View
                className="mt-2 w-[2px] flex-1 rounded-full"
                style={{ backgroundColor: `${stateAccentMap[block.state]}24`, minHeight: 46 }}
              />
            </View>

            <View className="flex-1 gap-2">
              <View className="flex-row items-start justify-between gap-3">
                <View className="flex-1 gap-1.5">
                  <AppText variant="section">{block.title}</AppText>
                  <AppText tone="tertiary" variant="caption">
                    Until {block.endsAt}
                  </AppText>
                </View>
                <View
                  className="rounded-full px-2.5 py-1"
                  style={{ backgroundColor: `${stateAccentMap[block.state]}14` }}
                >
                  <AppText
                    variant="micro"
                    style={{
                      color: stateAccentMap[block.state],
                      textTransform: "capitalize",
                    }}
                  >
                    {block.state}
                  </AppText>
                </View>
              </View>

              {block.note ? (
                <AppText tone="secondary" style={{ maxWidth: 280 }}>
                  {block.note}
                </AppText>
              ) : null}

              {block.taskStatus ? (
                <AppText tone="tertiary" variant="caption">
                  Status: {block.taskStatus.replaceAll("_", " ")}
                  {block.estimatedMinutes ? ` | ${block.estimatedMinutes} min` : ""}
                </AppText>
              ) : null}

              {block.taskId && block.actions.length > 0 ? (
                <View className="flex-row flex-wrap gap-2 pt-1">
                  {block.actions.map((action) => (
                    <Pressable
                      key={`${block.id}-${action}`}
                      onPress={() => onTaskAction(block.taskId as string, action)}
                      className="rounded-full px-3 py-2"
                      disabled={busyTaskId === block.taskId}
                      style={({ pressed }) => ({
                        borderWidth: 1,
                        borderColor: theme.colors.border.subtle,
                        backgroundColor: theme.colors.background.elevated,
                        opacity: busyTaskId === block.taskId ? 0.45 : pressed ? 0.8 : 1,
                      })}
                    >
                      <AppText variant="micro" tone="secondary">
                        {busyTaskId === block.taskId ? "Working..." : actionLabels[action]}
                      </AppText>
                    </Pressable>
                  ))}
                </View>
              ) : null}
            </View>
          </View>
        ))}
      </View>
    </Surface>
  );
}
