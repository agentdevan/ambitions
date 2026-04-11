import { View } from "react-native";

import { Pill } from "../ui/Pill";
import { AppText } from "../ui/Text";

interface TodayHeaderProps {
  dateLabel: string;
}

export function TodayHeader({ dateLabel }: TodayHeaderProps) {
  return (
    <View className="gap-4 pt-5">
      <View className="flex-row items-center justify-between">
        <Pill label="Today" />
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
