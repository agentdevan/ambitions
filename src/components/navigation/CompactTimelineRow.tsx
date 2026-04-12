import { Pressable, View } from "react-native";

import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
import { TodayTaskBlock } from "../../state/viewModels/today";
import { formatTimeRangeLabel } from "../../utils/date";
import { Pill } from "../ui/Pill";
import { AppText } from "../ui/Text";

interface CompactTimelineRowProps {
  block: TodayTaskBlock;
  onPress: () => void;
}

const stateToneMap: Record<TodayTaskBlock["state"], "accent" | "quiet" | "neutral"> = {
  active: "accent",
  complete: "quiet",
  scheduled: "neutral",
  rolled: "quiet",
  deferred: "quiet",
  cancelled: "quiet",
};

const stateLabelMap: Record<TodayTaskBlock["state"], string> = {
  active: "Now",
  complete: "Done",
  scheduled: "Next",
  rolled: "Rolled",
  deferred: "Deferred",
  cancelled: "Removed",
};

export function CompactTimelineRow({ block, onPress }: CompactTimelineRowProps) {
  const theme = useResolvedTheme();

  return (
    <Pressable
      className="rounded-[22px]"
      onPress={onPress}
      style={({ pressed }) => [
        {
          opacity: pressed ? 0.96 : 1,
          transform: [{ scale: pressed ? 0.994 : 1 }],
        },
      ]}
    >
      {({ pressed }) => (
        <View
          className="flex-row items-center gap-4 rounded-[22px] px-4 py-4"
          style={{
            backgroundColor:
              block.state === "active"
                ? theme.colors.background.accentWash
                : pressed
                  ? theme.colors.background.sunken
                  : theme.colors.background.elevated,
            borderWidth: 1,
            borderColor:
              block.state === "active"
                ? `${theme.colors.accent.primary}40`
                : pressed
                  ? `${theme.colors.accent.primary}2A`
                  : theme.colors.border.subtle,
          }}
        >
          <View className="w-[82px] gap-1">
            <AppText variant="caption">
              {formatTimeRangeLabel(block.startsAt, block.endsAt, { compact: true })}
            </AppText>
            <AppText tone="tertiary" variant="caption">
              {block.estimatedMinutes ? `${block.estimatedMinutes} min` : "Session"}
            </AppText>
          </View>
          <View className="flex-1 gap-1.5">
            <View className="flex-row flex-wrap items-center gap-2">
              <AppText variant="section" numberOfLines={1}>
                {block.title}
              </AppText>
              <Pill label={stateLabelMap[block.state]} tone={stateToneMap[block.state]} />
            </View>
            <AppText tone="secondary" numberOfLines={1}>
              {block.note ?? "Open the session to see the next useful move."}
            </AppText>
          </View>
          <AppText tone={pressed ? "accent" : "tertiary"} variant="caption">
            Open
          </AppText>
        </View>
      )}
    </Pressable>
  );
}
