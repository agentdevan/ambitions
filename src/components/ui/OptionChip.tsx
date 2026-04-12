import { PropsWithChildren } from "react";
import { Pressable, PressableProps, StyleProp, View, ViewStyle } from "react-native";

import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
import { AppText } from "./Text";

interface OptionChipProps
  extends PropsWithChildren,
    Omit<PressableProps, "children" | "style"> {
  selected?: boolean;
  compact?: boolean;
  style?: StyleProp<ViewStyle>;
}

export function OptionChip({
  children,
  selected = false,
  compact = false,
  style,
  ...props
}: OptionChipProps) {
  const theme = useResolvedTheme();

  return (
    <Pressable
      {...props}
      style={({ pressed }) => [
        {
          minHeight: compact ? 36 : 42,
          borderRadius: 999,
          borderWidth: 1,
          paddingHorizontal: compact ? 12 : 14,
          paddingVertical: compact ? 8 : 10,
          alignItems: "center",
          justifyContent: "center",
          backgroundColor: selected
            ? theme.colors.accent.primary
            : "#F4EEE7",
          borderColor: selected
            ? theme.colors.accent.primary
            : "#D8CEC2",
          opacity: props.disabled ? 0.45 : 1,
          transform: [{ scale: pressed ? 0.97 : 1 }],
          shadowColor: selected ? theme.colors.accent.primary : theme.colors.text.primary,
          shadowOpacity: pressed ? 0.08 : selected ? 0.16 : 0.03,
          shadowRadius: selected ? 12 : 8,
          shadowOffset: { width: 0, height: selected ? 8 : 4 },
          elevation: selected ? 2 : 1,
        },
        style,
      ]}
    >
      <View className="flex-row items-center justify-center gap-2">
        <View
          className="h-2.5 w-2.5 rounded-full"
          style={{
            backgroundColor: selected
              ? theme.colors.text.inverse
              : theme.colors.accent.primary,
            opacity: selected ? 0.92 : 0.4,
          }}
        />
        <AppText
          tone={selected ? "inverse" : "primary"}
          variant={compact ? "micro" : "caption"}
          style={{ textAlign: "center" }}
        >
          {children}
        </AppText>
      </View>
    </Pressable>
  );
}
