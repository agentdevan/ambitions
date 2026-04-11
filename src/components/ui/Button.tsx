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
      backgroundColor: theme.colors.text.primary,
      borderColor: theme.colors.text.primary,
      textTone: "inverse" as const,
    },
    secondary: {
      backgroundColor: theme.colors.background.elevated,
      borderColor: theme.colors.border.strong,
      textTone: "primary" as const,
    },
    ghost: {
      backgroundColor: theme.colors.background.canvas,
      borderColor: theme.colors.border.subtle,
      textTone: "secondary" as const,
    },
  }[tone];
  const sizing = {
    default: {
      minHeight: 50,
      paddingHorizontal: 18,
      textVariant: "caption" as const,
    },
    compact: {
      minHeight: 40,
      paddingHorizontal: 14,
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
          opacity: disabled || busy ? 0.5 : pressed ? 0.88 : 1,
          transform: [{ scale: pressed ? 0.99 : 1 }],
          shadowColor: tone === "primary" ? theme.colors.text.primary : "transparent",
          shadowOpacity: tone === "primary" ? 0.08 : 0,
          shadowRadius: 14,
          shadowOffset: { width: 0, height: 8 },
          elevation: tone === "primary" ? 2 : 0,
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
