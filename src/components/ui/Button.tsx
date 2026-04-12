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
  const tonePalette = {
    primary: {
      idleBackground: theme.colors.accent.primary,
      pressedBackground: theme.colors.accent.muted,
      disabledBackground: theme.colors.background.accentWashStrong,
      idleBorder: theme.colors.accent.primary,
      pressedBorder: theme.colors.accent.muted,
      disabledBorder: theme.colors.border.accent,
      textTone: "inverse" as const,
      disabledTextTone: "primary" as const,
      shadowColor: theme.colors.accent.primary,
      elevation: 4,
    },
    secondary: {
      idleBackground: theme.colors.background.elevated,
      pressedBackground: theme.colors.background.elevatedSecondary,
      disabledBackground: theme.colors.background.elevatedSecondary,
      idleBorder: theme.colors.border.strong,
      pressedBorder: theme.colors.border.accent,
      disabledBorder: theme.colors.border.subtle,
      textTone: "primary" as const,
      disabledTextTone: "secondary" as const,
      shadowColor: theme.colors.text.primary,
      elevation: 2,
    },
    tertiary: {
      idleBackground: theme.colors.background.canvas,
      pressedBackground: theme.colors.background.elevatedSecondary,
      disabledBackground: theme.colors.background.sunken,
      idleBorder: theme.colors.border.subtle,
      pressedBorder: theme.colors.border.strong,
      disabledBorder: theme.colors.border.subtle,
      textTone: "primary" as const,
      disabledTextTone: "secondary" as const,
      shadowColor: theme.colors.text.primary,
      elevation: 0,
    },
    inline: {
      idleBackground: "transparent",
      pressedBackground: "transparent",
      disabledBackground: "transparent",
      idleBorder: "transparent",
      pressedBorder: "transparent",
      disabledBorder: "transparent",
      textTone: "accent" as const,
      disabledTextTone: "secondary" as const,
      shadowColor: "transparent",
      elevation: 0,
    },
  }[resolvedTone];
  const sizing = {
    default: {
      minHeight: resolvedTone === "inline" ? 28 : 52,
      paddingHorizontal: resolvedTone === "inline" ? 0 : 18,
      paddingVertical: resolvedTone === "inline" ? 0 : 14,
      textVariant: "caption" as const,
    },
    compact: {
      minHeight: resolvedTone === "inline" ? 24 : 40,
      paddingHorizontal: resolvedTone === "inline" ? 0 : 14,
      paddingVertical: resolvedTone === "inline" ? 0 : 10,
      textVariant: "caption" as const,
    },
  }[size];
  const isDisabled = disabled || busy;

  return (
    <Pressable
      {...props}
      disabled={isDisabled}
      className="items-center justify-center rounded-[18px]"
      style={({ pressed }) => [
        {
          minHeight: sizing.minHeight,
          paddingHorizontal: sizing.paddingHorizontal,
          paddingVertical: sizing.paddingVertical,
          backgroundColor: isDisabled
            ? tonePalette.disabledBackground
            : pressed
              ? tonePalette.pressedBackground
              : tonePalette.idleBackground,
          borderColor: isDisabled
            ? tonePalette.disabledBorder
            : pressed
              ? tonePalette.pressedBorder
              : tonePalette.idleBorder,
          borderWidth: resolvedTone === "inline" ? 0 : 1,
          opacity: isDisabled && resolvedTone === "inline" ? 0.58 : 1,
          transform: [{ scale: pressed && !isDisabled ? 0.985 : 1 }],
          shadowColor: tonePalette.shadowColor,
          shadowOpacity:
            resolvedTone === "primary"
              ? isDisabled
                ? 0
                : pressed
                ? 0.2
                : theme.mode === "dark"
                  ? 0.34
                  : 0.18
              : resolvedTone === "secondary" || resolvedTone === "tertiary"
                ? isDisabled
                  ? 0
                  : pressed
                  ? 0.03
                  : theme.mode === "dark"
                    ? 0.08
                    : 0.05
                : 0,
          shadowRadius: resolvedTone === "primary" ? 18 : 8,
          shadowOffset: { width: 0, height: resolvedTone === "primary" ? 10 : 4 },
          elevation: isDisabled ? 0 : tonePalette.elevation,
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
          tone={
            isDisabled
              ? tonePalette.disabledTextTone
              : tonePalette.textTone
          }
          variant={sizing.textVariant}
          numberOfLines={1}
          style={{
            fontWeight: resolvedTone === "inline" ? "700" : "700",
            letterSpacing: resolvedTone === "inline" ? -0.1 : -0.15,
          }}
        >
          {children}
        </AppText>
      )}
    </Pressable>
  );
}
