import { Pressable, View } from "react-native";

import { useAccessibilityPreferences } from "../../design/accessibility/useAccessibilityPreferences";
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
  const { reduceMotionEnabled } = useAccessibilityPreferences();

  return (
    <View
      className="flex-row p-1"
      style={{
        borderRadius: theme.radius.control + 2,
        backgroundColor: theme.colors.background.sunken,
        borderWidth: 1,
        borderColor: theme.colors.border.strong,
        gap: 6,
      }}
    >
      {options.map((option) => {
        const selected = option.value === value;

        return (
          <Pressable
            key={option.value}
            accessibilityRole="tab"
            accessibilityState={{ selected }}
            hitSlop={4}
            onPress={() => onChange(option.value)}
            style={({ pressed }) => ({
              flex: 1,
              flexBasis: 0,
              minHeight: 44,
              alignItems: "center",
              justifyContent: "center",
              borderRadius: theme.radius.compactControl,
              paddingHorizontal: 14,
              backgroundColor: selected
                ? theme.colors.background.accentWashStrong
                : pressed
                  ? theme.colors.background.elevatedSecondary
                  : "transparent",
              borderWidth: selected ? 1 : 0,
              borderColor: selected ? theme.colors.border.accent : "transparent",
              transform: [
                { scale: pressed && !reduceMotionEnabled ? 0.99 : 1 },
                { translateY: pressed && !reduceMotionEnabled ? 1 : 0 },
              ],
              shadowColor: selected ? theme.colors.accent.primary : theme.colors.shadow.color,
              shadowOpacity: selected ? (theme.mode === "dark" ? 0.12 : 0.06) : 0,
              shadowRadius: 10,
              shadowOffset: { width: 0, height: 4 },
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
