import { View } from "react-native";

import { AppText } from "../ui/Text";

interface TodayHeaderProps {
  dateLabel: string;
  liveContext: boolean;
}

export function TodayHeader({ dateLabel, liveContext }: TodayHeaderProps) {
  return (
    <View className="gap-3 px-1 pt-2">
      <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
        Today
      </AppText>
      <AppText variant="hero">Execution center</AppText>
      <AppText tone="secondary" variant="caption">
        {dateLabel}
      </AppText>
      <AppText tone="secondary" style={{ maxWidth: 320 }}>
        {liveContext
          ? "See the next useful move, with live calendar context shaping the day."
          : "See the next useful move, using your saved routine as the day’s baseline."}
      </AppText>
    </View>
  );
}
