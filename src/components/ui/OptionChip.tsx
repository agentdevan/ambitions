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
          minHeight: compact ? 34 : 40,
          borderRadius: 16,
          borderWidth: 1,
          paddingHorizontal: compact ? 12 : 14,
          paddingVertical: compact ? 7 : 9,
          alignItems: "center",
          justifyContent: "center",
          backgroundColor: selected
            ? theme.colors.text.primary
            : theme.colors.background.elevated,
          borderColor: selected
            ? theme.colors.text.primary
            : theme.colors.border.subtle,
          opacity: props.disabled ? 0.45 : 1,
          transform: [{ scale: pressed ? 0.985 : 1 }],
          shadowColor: theme.colors.text.primary,
          shadowOpacity: selected ? 0.08 : 0.02,
          shadowRadius: selected ? 10 : 6,
          shadowOffset: { width: 0, height: selected ? 6 : 3 },
          elevation: selected ? 2 : 1,
        },
        style,
      ]}
    >
      <View className="flex-row items-center justify-center gap-2">
        <View
          className="h-2 w-2 rounded-full"
          style={{
            backgroundColor: selected
              ? theme.colors.text.inverse
              : theme.colors.text.tertiary,
            opacity: selected ? 0.92 : 0.55,
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
