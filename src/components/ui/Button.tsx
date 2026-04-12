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
      backgroundColor: "#60705D",
      borderColor: "#52614F",
      textTone: "inverse" as const,
      shadowColor: theme.colors.accent.primary,
    },
    secondary: {
      backgroundColor: "#FFF9F1",
      borderColor: "#CCBDAD",
      textTone: "primary" as const,
      shadowColor: theme.colors.text.primary,
    },
    ghost: {
      backgroundColor: "#EFE5D8",
      borderColor: "#D8C9B8",
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
            tone === "primary" ? (pressed ? 0.18 : 0.26) : tone === "secondary" ? 0.08 : 0.05,
          shadowRadius: tone === "primary" ? 18 : 10,
          shadowOffset: { width: 0, height: tone === "primary" ? 9 : 5 },
          elevation: tone === "primary" ? 5 : 2,
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
