import { Pressable, View } from "react-native";
import { Ionicons } from "@expo/vector-icons";

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
  const accentColor =
    block.state === "active"
      ? theme.colors.accent.primary
      : block.state === "scheduled"
        ? theme.colors.semantic.warning
        : theme.colors.border.strong;

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
          className="flex-row items-center gap-3 rounded-[22px] px-4 py-4"
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
          <View
            className="self-stretch rounded-full"
            style={{
              width: 4,
              backgroundColor: accentColor,
              opacity: block.state === "active" ? 1 : 0.7,
            }}
          />
          <View className="w-[76px] gap-1">
            <AppText variant="caption">
              {formatTimeRangeLabel(block.startsAt, block.endsAt, { compact: true })}
            </AppText>
            <AppText tone="tertiary" variant="caption">
              {block.estimatedMinutes ? `${block.estimatedMinutes} min` : "Session"}
            </AppText>
          </View>
          <View className="flex-1 gap-1">
            <View className="flex-row flex-wrap items-center gap-2">
              <AppText variant="section" numberOfLines={1}>
                {block.title}
              </AppText>
              <Pill label={stateLabelMap[block.state]} tone={stateToneMap[block.state]} />
            </View>
            <AppText tone="secondary" numberOfLines={2}>
              {block.note ?? "Open for details."}
            </AppText>
          </View>
          <Ionicons
            color={pressed ? theme.colors.accent.primary : theme.colors.text.tertiary}
            name="chevron-forward"
            size={16}
          />
        </View>
      )}
    </Pressable>
  );
}
