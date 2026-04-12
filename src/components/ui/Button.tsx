import { ReactNode } from "react";
import { ActivityIndicator, Pressable, PressableProps, StyleProp, ViewStyle } from "react-native";

import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
import { AppText } from "./Text";

interface ButtonProps extends Omit<PressableProps, "children" | "style"> {
  children?: ReactNode;
  tone?: "primary" | "secondary" | "ghost";
  busy?: boolean;
  size?: "default" | "compact";
  style?: StyleProp<ViewStyle>;
}

export function Button({
  children,
  tone = "primary",
  busy = false,
  size = "default",
  disabled,
  style,
  ...props
}: ButtonProps) {
  const theme = useResolvedTheme();
  const palette = {
    primary: {
      backgroundColor: theme.colors.accent.primary,
      borderColor: theme.colors.accent.primary,
      textTone: "inverse" as const,
      shadowColor: theme.colors.accent.primary,
    },
    secondary: {
      backgroundColor: theme.colors.background.canvas,
      borderColor: theme.colors.border.strong,
      textTone: "primary" as const,
      shadowColor: theme.colors.text.primary,
    },
    ghost: {
      backgroundColor: theme.colors.background.elevated,
      borderColor: theme.colors.background.elevated,
      textTone: "secondary" as const,
      shadowColor: theme.colors.text.primary,
    },
  }[tone];
  const sizing = {
    default: {
      minHeight: 52,
      paddingHorizontal: 20,
      textVariant: "caption" as const,
    },
    compact: {
      minHeight: 42,
      paddingHorizontal: 16,
      textVariant: "micro" as const,
    },
  }[size];

  return (
    <Pressable
      {...props}
      disabled={disabled || busy}
      className="items-center justify-center rounded-full border"
      style={({ pressed }) => [
        {
          minHeight: sizing.minHeight,
          paddingHorizontal: sizing.paddingHorizontal,
          backgroundColor: palette.backgroundColor,
          borderColor: palette.borderColor,
          borderWidth: tone === "ghost" ? 0 : 1.5,
          opacity: disabled || busy ? 0.5 : pressed ? 0.9 : 1,
          transform: [{ scale: pressed ? 0.98 : 1 }],
          shadowColor: palette.shadowColor,
          shadowOpacity: tone === "primary" ? 0.18 : tone === "secondary" ? 0.06 : 0.03,
          shadowRadius: tone === "primary" ? 18 : 12,
          shadowOffset: { width: 0, height: tone === "primary" ? 10 : 6 },
          elevation: tone === "primary" ? 4 : 1,
        },
        style,
      ]}
    >
      {busy ? (
        <ActivityIndicator color={tone === "primary" ? theme.colors.text.inverse : theme.colors.text.primary} />
      ) : (
        <AppText tone={palette.textTone} variant={sizing.textVariant}>
          {children}
        </AppText>
      )}
    </Pressable>
  );
}
