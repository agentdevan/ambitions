import { View } from "react-native";

import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
import { ActivityFeedItem, ActivityDateGroup } from "../../services/history/selectors";
import { formatShortDateTime, formatWeekdayDate } from "../../utils/date";
import { Pill } from "../ui/Pill";
import { Surface } from "../ui/Surface";
import { AppText } from "../ui/Text";

function toneForOutcome(outcomeLabel: string | null): "accent" | "quiet" | "neutral" {
  if (!outcomeLabel) {
    return "neutral";
  }

  if (["Completed", "Accepted", "Started", "Review ready"].includes(outcomeLabel)) {
    return "accent";
  }

  if (["Deferred", "Missed", "Skipped", "Moved", "Reverted", "Paused", "Archived"].includes(outcomeLabel)) {
    return "quiet";
  }

  return "neutral";
}

export function ActivityTimelineRow({
  item,
  compact = false,
}: {
  item: ActivityFeedItem;
  compact?: boolean;
}) {
  const theme = useResolvedTheme();

  return (
    <View className="flex-row gap-3">
      <View className="items-center pt-1">
        <View
          style={{
            width: 10,
            height: 10,
            borderRadius: 999,
            backgroundColor:
              item.outcomeLabel === "Completed" || item.outcomeLabel === "Accepted"
                ? theme.colors.accent.primary
                : theme.colors.border.strong,
          }}
        />
        {!compact ? (
          <View
            style={{
              width: 1,
              flex: 1,
              backgroundColor: theme.colors.border.subtle,
              marginTop: 8,
            }}
          />
        ) : null}
      </View>
      <View className="flex-1 gap-2 pb-4">
        <View className="flex-row flex-wrap items-center gap-2">
          <AppText variant="section">{item.title}</AppText>
          {item.outcomeLabel ? (
            <Pill label={item.outcomeLabel} tone={toneForOutcome(item.outcomeLabel)} />
          ) : null}
        </View>
        <AppText tone="tertiary" variant="caption">
          {formatShortDateTime(item.occurredAt)}
        </AppText>
        {item.detail ? (
          <AppText tone="secondary" variant="caption">
            {item.detail}
          </AppText>
        ) : null}
      </View>
    </View>
  );
}

export function GroupedActivityTimeline({
  groups,
  emptyTitle,
  emptyBody,
}: {
  groups: ActivityDateGroup[];
  emptyTitle: string;
  emptyBody: string;
}) {
  if (groups.length === 0) {
    return (
      <Surface className="gap-2 mb-0">
        <AppText variant="section">{emptyTitle}</AppText>
        <AppText tone="secondary" variant="caption">
          {emptyBody}
        </AppText>
      </Surface>
    );
  }

  return (
    <View className="gap-5">
      {groups.map((group) => (
        <View key={group.date} className="gap-3">
          <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
            {formatWeekdayDate(group.date)}
          </AppText>
          <Surface className="gap-0 mb-0">
            {group.items.map((item, index) => (
              <ActivityTimelineRow
                key={item.id}
                item={item}
                compact={index === group.items.length - 1}
              />
            ))}
          </Surface>
        </View>
      ))}
    </View>
  );
}

export function MomentumBars({
  points,
}: {
  points: Array<{ date: string; completed: number; reshaped: number }>;
}) {
  const theme = useResolvedTheme();
  const maxValue = Math.max(1, ...points.map((point) => point.completed + point.reshaped));

  return (
    <View className="flex-row items-end gap-2">
      {points.map((point) => {
        const completedHeight = Math.max(6, Math.round((point.completed / maxValue) * 48));
        const reshapedHeight =
          point.reshaped > 0 ? Math.max(6, Math.round((point.reshaped / maxValue) * 28)) : 0;

        return (
          <View key={point.date} className="flex-1 items-center gap-2">
            <View
              className="w-full items-center justify-end rounded-[20px] px-1.5 py-2"
              style={{
                height: 76,
                backgroundColor: theme.colors.background.elevatedSecondary,
                borderWidth: 1,
                borderColor: theme.colors.border.subtle,
              }}
            >
              {reshapedHeight > 0 ? (
                <View
                  style={{
                    width: "72%",
                    height: reshapedHeight,
                    borderRadius: 999,
                    backgroundColor: theme.colors.progress.mutedFill,
                    marginBottom: 4,
                  }}
                />
              ) : null}
              <View
                style={{
                  width: "72%",
                  height: completedHeight,
                  borderRadius: 999,
                  backgroundColor: theme.colors.progress.fill,
                  shadowColor: theme.colors.progress.fill,
                  shadowOpacity: theme.mode === "dark" ? 0.24 : 0.14,
                  shadowRadius: 10,
                  shadowOffset: { width: 0, height: 4 },
                }}
              />
            </View>
            <AppText tone="tertiary" variant="micro">
              {formatWeekdayDate(point.date).slice(0, 3)}
            </AppText>
          </View>
        );
      })}
    </View>
  );
}
