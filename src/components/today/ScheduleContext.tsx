import { View } from "react-native";

import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
import { Pill } from "../ui/Pill";
import { AppText } from "../ui/Text";

interface ScheduleContextProps {
  items: Array<{ label: string; value: string }>;
}

export function ScheduleContext({ items }: ScheduleContextProps) {
  const theme = useResolvedTheme();

  return (
    <View className="flex-row flex-wrap gap-2">
      {items.map((item) => (
        <View
          key={item.label}
          className="rounded-[16px] px-4 py-3"
          style={{
            backgroundColor: "#F8F1E8",
            borderWidth: 1,
            borderColor: "#DCCDBC",
            minWidth: "47%",
          }}
        >
          <View className="gap-2">
            <Pill label={item.label} tone="quiet" />
            <AppText tone="secondary" variant="caption">
              {item.value}
            </AppText>
          </View>
        </View>
      ))}
    </View>
  );
}
