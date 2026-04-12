import { View } from "react-native";

import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
import { Surface } from "../ui/Surface";
import { AppText } from "../ui/Text";

interface GuidancePanelProps {
  items: string[];
}

export function GuidancePanel({ items }: GuidancePanelProps) {
  const theme = useResolvedTheme();

  return (
    <Surface tone="sunken" className="gap-4">
      <View className="gap-2">
        <AppText tone="secondary" variant="micro" style={{ textTransform: "uppercase" }}>
          Guidance
        </AppText>
        <AppText variant="section">Small adjustments for the way today is shaped</AppText>
      </View>

      <View className="gap-3">
        {items.map((item) => (
          <View
            key={item}
            className="flex-row gap-3 rounded-[20px] px-4 py-3"
            style={{
              backgroundColor: theme.colors.background.elevated,
              borderWidth: 1,
              borderColor: theme.colors.border.subtle,
            }}
          >
            <View
              className="mt-2 h-2 w-2 rounded-full"
              style={{ backgroundColor: theme.colors.accent.primary }}
            />
            <AppText tone="secondary" style={{ flex: 1 }}>
              {item}
            </AppText>
          </View>
        ))}
      </View>
    </Surface>
  );
}
