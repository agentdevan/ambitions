import { View } from "react-native";

import { AppText } from "../ui/Text";

interface TodayHeaderProps {
  dateLabel: string;
  liveContext: boolean;
}

export function TodayHeader({ dateLabel, liveContext }: TodayHeaderProps) {
  return (
    <View className="gap-2 px-1 pt-2">
      <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
        Today
      </AppText>
      <AppText variant="hero">Today</AppText>
      <AppText tone="secondary" variant="caption">
        {dateLabel}
      </AppText>
      <AppText tone="secondary" style={{ maxWidth: 320 }}>
        {liveContext
          ? "Live context is shaping the day."
          : "Using your saved baseline for a steady day."}
      </AppText>
    </View>
  );
}
