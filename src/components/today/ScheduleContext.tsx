import { View } from "react-native";

import { Surface } from "../ui/Surface";
import { AppText } from "../ui/Text";

interface ScheduleContextProps {
  items: Array<{ label: string; value: string }>;
}

export function ScheduleContext({ items }: ScheduleContextProps) {
  return (
    <Surface className="gap-5">
      <View className="gap-2">
        <AppText tone="secondary" variant="caption">
          Schedule context
        </AppText>
        <AppText variant="section">What the surrounding day allows</AppText>
      </View>

      <View className="gap-1">
        {items.map((item, index) => (
          <View
            key={item.label}
            className={`flex-row items-center justify-between gap-4 py-3 ${index < items.length - 1 ? "border-b border-[#E7E1D8]" : ""}`}
          >
            <AppText tone="tertiary">{item.label}</AppText>
            <AppText style={{ flexShrink: 1, textAlign: "right" }}>{item.value}</AppText>
          </View>
        ))}
      </View>
    </Surface>
  );
}
