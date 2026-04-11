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
          minHeight: compact ? 36 : 44,
          borderRadius: 999,
          borderWidth: 1,
          paddingHorizontal: compact ? 12 : 15,
          paddingVertical: compact ? 8 : 11,
          alignItems: "center",
          justifyContent: "center",
          backgroundColor: selected
            ? theme.colors.text.primary
            : theme.colors.background.canvas,
          borderColor: selected
            ? theme.colors.text.primary
            : theme.colors.border.strong,
          opacity: props.disabled ? 0.45 : pressed ? 0.88 : 1,
          shadowColor: selected ? theme.colors.text.primary : "transparent",
          shadowOpacity: selected ? 0.08 : 0,
          shadowRadius: 12,
          shadowOffset: { width: 0, height: 6 },
          elevation: selected ? 2 : 0,
        },
        style,
      ]}
    >
      <AppText
        tone={selected ? "inverse" : "primary"}
        variant={compact ? "micro" : "caption"}
        style={{ textAlign: "center" }}
      >
        {children}
      </AppText>
    </Pressable>
  );
}
