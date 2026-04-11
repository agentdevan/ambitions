import { View } from "react-native";

import { Pill } from "../ui/Pill";
import { AppText } from "../ui/Text";

interface TodayHeaderProps {
  dateLabel: string;
  liveContext: boolean;
}

export function TodayHeader({ dateLabel, liveContext }: TodayHeaderProps) {
  return (
    <View className="gap-4 pt-5">
      <View className="flex-row items-center justify-between">
        <View className="flex-row items-center gap-2">
          <Pill label="Today" />
          <Pill label={liveContext ? "Live context" : "Fallback"} tone={liveContext ? "accent" : "neutral"} />
        </View>
        <AppText tone="tertiary" variant="caption">
          Quiet structure
        </AppText>
      </View>

      <View className="gap-2">
        <AppText variant="hero">Today</AppText>
        <AppText tone="secondary">{dateLabel}</AppText>
      </View>

      <AppText tone="secondary" style={{ maxWidth: 310 }}>
        A measured plan for the day, shaped to fit real capacity.
      </AppText>
    </View>
  );
}
