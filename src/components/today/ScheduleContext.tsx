import { View } from "react-native";

import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
import { Surface } from "../ui/Surface";
import { AppText } from "../ui/Text";

interface ScheduleContextProps {
  items: Array<{ label: string; value: string }>;
}

export function ScheduleContext({ items }: ScheduleContextProps) {
  const theme = useResolvedTheme();

  return (
    <Surface className="gap-5">
      <View className="gap-2">
        <AppText tone="secondary" variant="micro" style={{ textTransform: "uppercase" }}>
          Schedule context
        </AppText>
        <AppText variant="section">What the surrounding day allows</AppText>
      </View>

      <View className="gap-3">
        {items.map((item, index) => (
          <View
            key={item.label}
            className="rounded-[20px] px-4 py-4"
            style={{
              borderWidth: 1,
              borderColor: theme.colors.border.subtle,
              backgroundColor:
                index % 2 === 0 ? theme.colors.background.elevated : theme.colors.background.sunken,
            }}
          >
            <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
              {item.label}
            </AppText>
            <AppText style={{ marginTop: 6 }}>{item.value}</AppText>
          </View>
        ))}
      </View>
    </Surface>
  );
}
