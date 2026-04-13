import { Pressable, View } from "react-native";

import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
import { AppText } from "./Text";

interface SegmentedControlOption<T extends string> {
  value: T;
  label: string;
}

interface SegmentedControlProps<T extends string> {
  value: T;
  options: Array<SegmentedControlOption<T>>;
  onChange: (value: T) => void;
}

export function SegmentedControl<T extends string>({
  value,
  options,
  onChange,
}: SegmentedControlProps<T>) {
  const theme = useResolvedTheme();

  return (
    <View
      className="flex-row rounded-[20px] p-1"
      style={{
        backgroundColor: theme.colors.background.sunken,
        borderWidth: 1,
        borderColor: theme.colors.border.subtle,
        gap: 6,
      }}
    >
      {options.map((option) => {
        const selected = option.value === value;

        return (
          <Pressable
            key={option.value}
            onPress={() => onChange(option.value)}
            style={({ pressed }) => ({
              flex: 1,
              flexBasis: 0,
              minHeight: 42,
              alignItems: "center",
              justifyContent: "center",
              borderRadius: 14,
              paddingHorizontal: 12,
              backgroundColor: selected
                ? theme.colors.background.accentWashStrong
                : pressed
                  ? theme.colors.background.elevatedSecondary
                  : "transparent",
              borderWidth: selected ? 1 : 0,
              borderColor: selected ? theme.colors.border.accent : "transparent",
            })}
          >
            <AppText
              tone={selected ? "accent" : "secondary"}
              variant="caption"
              numberOfLines={1}
              style={{
                fontWeight: selected ? "700" : "600",
                textAlign: "center",
              }}
            >
              {option.label}
            </AppText>
          </Pressable>
        );
      })}
    </View>
  );
}
