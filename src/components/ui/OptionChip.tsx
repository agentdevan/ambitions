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
          minHeight: compact ? 34 : 42,
          borderRadius: 999,
          borderWidth: 1,
          paddingHorizontal: compact ? 12 : 16,
          paddingVertical: compact ? 8 : 11,
          backgroundColor: selected
            ? theme.colors.text.primary
            : theme.colors.background.elevated,
          borderColor: selected
            ? theme.colors.text.primary
            : theme.colors.border.subtle,
          opacity: props.disabled ? 0.45 : pressed ? 0.82 : 1,
        },
        style,
      ]}
    >
      <AppText
        tone={selected ? "inverse" : "secondary"}
        variant={compact ? "micro" : "caption"}
      >
        {children}
      </AppText>
    </Pressable>
  );
}
