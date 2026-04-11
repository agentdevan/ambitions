import { View } from "react-native";

import { Pill } from "../ui/Pill";
import { AppText } from "../ui/Text";

interface TodayHeaderProps {
  dateLabel: string;
}

export function TodayHeader({ dateLabel }: TodayHeaderProps) {
  return (
    <View className="gap-3 pt-4">
      <Pill label="Foundation Preview" />
      <View className="gap-1">
        <AppText variant="hero">Today</AppText>
        <AppText tone="secondary">{dateLabel}</AppText>
      </View>
    </View>
  );
}
