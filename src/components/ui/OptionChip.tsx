import { PropsWithChildren } from "react";
import { Pressable, PressableProps, StyleProp, ViewStyle } from "react-native";

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
          borderRadius: compact ? 15 : 17,
          borderWidth: 1,
          paddingHorizontal: compact ? 12 : 14,
          paddingVertical: compact ? 7 : 9,
          alignItems: "center",
          justifyContent: "center",
          backgroundColor: selected
            ? theme.colors.background.accentWashStrong
            : theme.colors.background.elevated,
          borderColor: selected
            ? theme.colors.border.accent
            : pressed
              ? theme.colors.border.strong
              : theme.colors.border.subtle,
          opacity: props.disabled ? 0.6 : 1,
          transform: [{ scale: pressed && !props.disabled ? 0.985 : 1 }],
          shadowColor: theme.colors.shadow.color,
          shadowOpacity: selected ? (theme.mode === "dark" ? 0.12 : 0.07) : 0.02,
          shadowRadius: selected ? 10 : 4,
          shadowOffset: { width: 0, height: selected ? 5 : 2 },
          elevation: selected ? 2 : 1,
        },
        style,
      ]}
    >
      <AppText
        tone={selected ? "accent" : "secondary"}
        variant={compact ? "micro" : "caption"}
        style={{ textAlign: "center", fontWeight: selected ? "700" : "600" }}
      >
        {children}
      </AppText>
    </Pressable>
  );
}
