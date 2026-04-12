import { ReactNode } from "react";
import { ActivityIndicator, Pressable, PressableProps, StyleProp, ViewStyle } from "react-native";

import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
import { AppText } from "./Text";

interface ButtonProps extends Omit<PressableProps, "children" | "style"> {
  children?: ReactNode;
  tone?: "primary" | "secondary" | "tertiary" | "ghost";
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
      shadowColor: theme.colors.text.primary,
    },
    secondary: {
      backgroundColor: theme.colors.background.elevated,
      borderColor: theme.colors.border.strong,
      textTone: "primary" as const,
      shadowColor: theme.colors.text.primary,
    },
    tertiary: {
      backgroundColor: "transparent",
      borderColor: "transparent",
      textTone: "secondary" as const,
      shadowColor: "transparent",
    },
    ghost: {
      backgroundColor: theme.colors.background.canvas,
      borderColor: theme.colors.border.subtle,
      textTone: "secondary" as const,
      shadowColor: theme.colors.text.primary,
    },
  }[tone];
  const sizing = {
    default: {
      minHeight: 48,
      paddingHorizontal: 18,
      textVariant: "caption" as const,
    },
    compact: {
      minHeight: 38,
      paddingHorizontal: 12,
      textVariant: "micro" as const,
    },
  }[size];

  return (
    <Pressable
      {...props}
      disabled={disabled || busy}
      className="items-center justify-center rounded-[16px] border"
      style={({ pressed }) => [
        {
          minHeight: sizing.minHeight,
          paddingHorizontal: sizing.paddingHorizontal,
          backgroundColor: palette.backgroundColor,
          borderColor: palette.borderColor,
          borderWidth: tone === "tertiary" ? 0 : 1,
          opacity: disabled || busy ? 0.45 : 1,
          transform: [{ scale: pressed ? 0.985 : 1 }],
          shadowColor: palette.shadowColor,
          shadowOpacity:
            tone === "primary" ? (pressed ? 0.12 : 0.16) : tone === "secondary" ? 0.04 : 0,
          shadowRadius: tone === "primary" ? 12 : 8,
          shadowOffset: { width: 0, height: tone === "primary" ? 7 : 4 },
          elevation: tone === "primary" ? 3 : tone === "secondary" ? 1 : 0,
        },
        style,
      ]}
    >
      {busy ? (
        <ActivityIndicator
          color={tone === "primary" ? theme.colors.text.inverse : theme.colors.text.primary}
        />
      ) : (
        <AppText tone={palette.textTone} variant={sizing.textVariant} numberOfLines={1}>
          {children}
        </AppText>
      )}
    </Pressable>
  );
}
