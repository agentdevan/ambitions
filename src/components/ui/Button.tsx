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
      backgroundColor: "#F7F1E8",
      borderColor: "#D8CEC2",
      textTone: "primary" as const,
      shadowColor: theme.colors.text.primary,
    },
    ghost: {
      backgroundColor: "#EEE7DE",
      borderColor: "#EEE7DE",
      textTone: "secondary" as const,
      shadowColor: theme.colors.text.primary,
    },
  }[tone];
  const sizing = {
    default: {
      minHeight: 46,
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
      className="items-center justify-center rounded-[14px] border"
      style={({ pressed }) => [
        {
          minHeight: sizing.minHeight,
          paddingHorizontal: sizing.paddingHorizontal,
          backgroundColor: palette.backgroundColor,
          borderColor: palette.borderColor,
          borderWidth: tone === "ghost" ? 0 : 1,
          opacity: disabled || busy ? 0.5 : 1,
          transform: [{ scale: pressed ? 0.98 : 1 }],
          shadowColor: palette.shadowColor,
          shadowOpacity: tone === "primary" ? (pressed ? 0.12 : 0.18) : tone === "secondary" ? 0.04 : 0.02,
          shadowRadius: tone === "primary" ? 14 : 8,
          shadowOffset: { width: 0, height: tone === "primary" ? 8 : 4 },
          elevation: tone === "primary" ? 3 : 1,
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
