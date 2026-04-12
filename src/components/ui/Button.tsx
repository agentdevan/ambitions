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
      backgroundColor: theme.colors.background.elevated,
      borderColor: theme.colors.border.strong,
      textTone: "primary" as const,
      shadowColor: theme.colors.text.primary,
    },
    ghost: {
      backgroundColor: theme.colors.background.sunken,
      borderColor: theme.colors.border.subtle,
      textTone: "secondary" as const,
      shadowColor: "transparent",
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
      className="items-center justify-center rounded-[22px] border"
      style={({ pressed }) => [
        {
          minHeight: sizing.minHeight,
          paddingHorizontal: sizing.paddingHorizontal,
          backgroundColor: palette.backgroundColor,
          borderColor: palette.borderColor,
          borderWidth: tone === "ghost" ? 1 : 1.5,
          opacity: disabled || busy ? 0.5 : pressed ? 0.9 : 1,
          transform: [{ scale: pressed ? 0.985 : 1 }],
          shadowColor: palette.shadowColor,
          shadowOpacity: tone === "primary" ? 0.16 : tone === "secondary" ? 0.05 : 0,
          shadowRadius: tone === "primary" ? 18 : 12,
          shadowOffset: { width: 0, height: tone === "primary" ? 10 : 6 },
          elevation: tone === "primary" ? 4 : tone === "secondary" ? 1 : 0,
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
