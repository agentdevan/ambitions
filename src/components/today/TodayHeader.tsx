import { View } from "react-native";

import { AppText } from "../ui/Text";

interface TodayHeaderProps {
  dateLabel: string;
  liveContext: boolean;
}

export function TodayHeader({ dateLabel, liveContext }: TodayHeaderProps) {
  return (
    <View className="gap-2 px-1">
      <AppText variant="hero">Today</AppText>
      <AppText tone="secondary" variant="section">
        {dateLabel}
      </AppText>
      <AppText tone="secondary" style={{ maxWidth: 320 }}>
        {liveContext
          ? "Calendar-grounded focus, then action cards, then supporting context."
          : "A steady fallback day: brief first, then task cards, then supporting context."}
      </AppText>
    </View>
  );
}
