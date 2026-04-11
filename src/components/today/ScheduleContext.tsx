import { View } from "react-native";

import { Surface } from "../ui/Surface";
import { AppText } from "../ui/Text";

interface ScheduleContextProps {
  items: Array<{ label: string; value: string }>;
}

export function ScheduleContext({ items }: ScheduleContextProps) {
  return (
    <Surface className="gap-4">
      <View className="gap-1">
        <AppText tone="secondary" variant="caption">
          Schedule context
        </AppText>
        <AppText variant="section">Signals pulled from the day around you</AppText>
      </View>

      <View className="gap-3">
        {items.map((item) => (
          <View key={item.label} className="flex-row items-center justify-between gap-4">
            <AppText tone="tertiary">{item.label}</AppText>
            <AppText style={{ flexShrink: 1, textAlign: "right" }}>{item.value}</AppText>
          </View>
        ))}
      </View>
    </Surface>
  );
}
