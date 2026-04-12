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
          minHeight: compact ? 42 : 54,
          borderRadius: 999,
          borderWidth: selected ? 0 : 1.5,
          paddingHorizontal: compact ? 14 : 18,
          paddingVertical: compact ? 10 : 14,
          alignItems: "center",
          justifyContent: "center",
          backgroundColor: selected
            ? theme.colors.accent.primary
            : theme.colors.background.canvas,
          borderColor: selected
            ? theme.colors.accent.primary
            : theme.colors.border.strong,
          opacity: props.disabled ? 0.45 : pressed ? 0.9 : 1,
          shadowColor: selected ? theme.colors.accent.primary : theme.colors.text.primary,
          shadowOpacity: selected ? 0.18 : 0.05,
          shadowRadius: selected ? 16 : 10,
          shadowOffset: { width: 0, height: selected ? 10 : 5 },
          elevation: selected ? 3 : 1,
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
