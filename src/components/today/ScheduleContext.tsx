import { View } from "react-native";

import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
import { Pill } from "../ui/Pill";
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
        {items.map((item) => (
          <View
            key={item.label}
            className="rounded-[24px] px-4 py-4"
            style={{
              backgroundColor: theme.colors.background.canvas,
            }}
          >
            <View className="gap-2">
              <Pill label={item.label} tone="quiet" />
              <AppText>{item.value}</AppText>
            </View>
          </View>
        ))}
      </View>
    </Surface>
  );
}
