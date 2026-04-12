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
          minHeight: compact ? 38 : 44,
          borderRadius: compact ? 16 : 18,
          borderWidth: 1,
          paddingHorizontal: compact ? 12 : 15,
          paddingVertical: compact ? 8 : 10,
          alignItems: "center",
          justifyContent: "center",
          backgroundColor: selected
            ? theme.colors.accent.primary
            : theme.colors.background.sunken,
          borderColor: selected
            ? theme.colors.accent.primary
            : theme.colors.border.strong,
          opacity: props.disabled ? 0.45 : pressed ? 0.94 : 1,
          transform: [{ scale: pressed ? 0.985 : 1 }],
          shadowColor: theme.colors.text.primary,
          shadowOpacity: selected ? 0.12 : 0.03,
          shadowRadius: selected ? 12 : 6,
          shadowOffset: { width: 0, height: selected ? 6 : 3 },
          elevation: selected ? 2 : 1,
        },
        style,
      ]}
    >
      <AppText
        tone={selected ? "inverse" : "primary"}
        variant={compact ? "micro" : "caption"}
        style={{ textAlign: "center", fontWeight: "600" }}
      >
        {children}
      </AppText>
    </Pressable>
  );
}
