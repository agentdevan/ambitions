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
      backgroundColor: "#6B7A69",
      borderColor: "#61705F",
      textTone: "inverse" as const,
      shadowColor: theme.colors.accent.primary,
    },
    secondary: {
      backgroundColor: "#FAF5EE",
      borderColor: "#D3C6B8",
      textTone: "primary" as const,
      shadowColor: theme.colors.text.primary,
    },
    ghost: {
      backgroundColor: "#F1EAE1",
      borderColor: "#DDCFC0",
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
          borderWidth: 1,
          opacity: disabled || busy ? 0.5 : 1,
          transform: [{ scale: pressed ? 0.985 : 1 }],
          shadowColor: palette.shadowColor,
          shadowOpacity:
            tone === "primary" ? (pressed ? 0.14 : 0.22) : tone === "secondary" ? 0.06 : 0.03,
          shadowRadius: tone === "primary" ? 16 : 8,
          shadowOffset: { width: 0, height: tone === "primary" ? 8 : 4 },
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
