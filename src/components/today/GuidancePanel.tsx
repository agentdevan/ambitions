import { View } from "react-native";

import { Surface } from "../ui/Surface";
import { AppText } from "../ui/Text";

interface GuidancePanelProps {
  items: string[];
}

export function GuidancePanel({ items }: GuidancePanelProps) {
  return (
    <Surface tone="sunken" className="gap-3">
      <View className="gap-1">
        <AppText tone="secondary" variant="caption">
          Adaptive guidance
        </AppText>
        <AppText variant="section">Protect the day before it fragments</AppText>
      </View>

      <View className="gap-3">
        {items.map((item) => (
          <View key={item} className="flex-row gap-3">
            <View className="mt-2 h-1.5 w-1.5 rounded-full bg-[#6D7C6D]" />
            <AppText tone="secondary" style={{ flex: 1 }}>
              {item}
            </AppText>
          </View>
        ))}
      </View>
    </Surface>
  );
}
