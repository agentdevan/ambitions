import { ReactNode } from "react";
import { ActivityIndicator, Pressable, PressableProps, StyleProp, ViewStyle } from "react-native";

import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
import { AppText } from "./Text";

interface ButtonProps extends Omit<PressableProps, "children" | "style"> {
  children?: ReactNode;
  tone?: "primary" | "secondary" | "tertiary" | "inline" | "ghost";
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
  const resolvedTone = tone === "ghost" ? "secondary" : tone;
  const palette = {
    primary: {
      backgroundColor: theme.colors.accent.primary,
      borderColor: theme.colors.accent.primary,
      textTone: "inverse" as const,
      shadowColor: theme.colors.accent.primary,
    },
    secondary: {
      backgroundColor: theme.colors.background.elevatedSecondary,
      borderColor: theme.colors.border.subtle,
      textTone: "primary" as const,
      shadowColor: theme.colors.text.primary,
    },
    tertiary: {
      backgroundColor: theme.colors.background.sunken,
      borderColor: theme.colors.border.subtle,
      textTone: "secondary" as const,
      shadowColor: theme.colors.text.primary,
    },
    inline: {
      backgroundColor: "transparent",
      borderColor: "transparent",
      textTone: "accent" as const,
      shadowColor: "transparent",
    },
  }[resolvedTone];
  const sizing = {
    default: {
      minHeight: 52,
      paddingHorizontal: 18,
      paddingVertical: 14,
      textVariant: "caption" as const,
    },
    compact: {
      minHeight: 42,
      paddingHorizontal: 14,
      paddingVertical: 10,
      textVariant: "caption" as const,
    },
  }[size];

  return (
    <Pressable
      {...props}
      disabled={disabled || busy}
      className="items-center justify-center rounded-[18px] border"
      style={({ pressed }) => [
        {
          minHeight: sizing.minHeight,
          paddingHorizontal: sizing.paddingHorizontal,
          paddingVertical: resolvedTone === "inline" ? 0 : sizing.paddingVertical,
          backgroundColor: palette.backgroundColor,
          borderColor: palette.borderColor,
          borderWidth: resolvedTone === "inline" ? 0 : 1,
          opacity: disabled || busy ? 0.46 : pressed ? 0.94 : 1,
          transform: [{ scale: pressed ? 0.985 : 1 }],
          shadowColor: palette.shadowColor,
          shadowOpacity:
            resolvedTone === "primary"
              ? pressed
                ? 0.2
                : theme.mode === "dark"
                  ? 0.34
                  : 0.18
              : resolvedTone === "secondary" || resolvedTone === "tertiary"
                ? pressed
                  ? 0.03
                  : theme.mode === "dark"
                    ? 0.08
                    : 0.05
                : 0,
          shadowRadius: resolvedTone === "primary" ? 18 : 8,
          shadowOffset: { width: 0, height: resolvedTone === "primary" ? 10 : 4 },
          elevation: resolvedTone === "primary" ? 3 : resolvedTone === "inline" ? 0 : 1,
        },
        style,
      ]}
    >
      {busy ? (
        <ActivityIndicator
          color={
            resolvedTone === "primary"
              ? theme.colors.text.inverse
              : resolvedTone === "inline"
                ? theme.colors.accent.primary
                : theme.colors.text.primary
          }
        />
      ) : (
        <AppText
          tone={palette.textTone}
          variant={sizing.textVariant}
          numberOfLines={1}
          style={{ fontWeight: resolvedTone === "inline" ? "600" : "700", letterSpacing: -0.15 }}
        >
          {children}
        </AppText>
      )}
    </Pressable>
  );
}
