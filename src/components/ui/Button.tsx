import { ReactNode } from "react";
import { ActivityIndicator, Pressable, PressableProps, StyleProp, ViewStyle } from "react-native";

import { useAccessibilityPreferences } from "../../design/accessibility/useAccessibilityPreferences";
import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
import { AppText } from "./Text";

interface ButtonProps extends Omit<PressableProps, "children" | "style"> {
  children?: ReactNode;
  tone?: "primary" | "secondary" | "tertiary" | "destructive" | "inline" | "ghost";
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
  const { reduceMotionEnabled } = useAccessibilityPreferences();
  const resolvedTone = tone === "ghost" ? "secondary" : tone;
  const tonePalette = {
    primary: {
      idleBackground: theme.colors.accent.primary,
      pressedBackground: theme.colors.accent.secondary,
      disabledBackground: theme.mode === "dark" ? theme.colors.border.strong : theme.colors.border.accent,
      idleBorder: theme.colors.accent.primary,
      pressedBorder: theme.colors.accent.secondary,
      disabledBorder: theme.colors.border.accent,
      textTone: "inverse" as const,
      disabledTextTone: "inverse" as const,
      shadowColor: theme.colors.accent.primary,
      elevation: 5,
    },
    secondary: {
      idleBackground: theme.colors.background.elevatedSecondary,
      pressedBackground: theme.colors.background.accentWash,
      disabledBackground: theme.colors.background.sunken,
      idleBorder: theme.colors.border.subtle,
      pressedBorder: theme.colors.border.accent,
      disabledBorder: theme.colors.border.subtle,
      textTone: "primary" as const,
      disabledTextTone: "secondary" as const,
      shadowColor: theme.colors.text.primary,
      elevation: 2,
    },
    tertiary: {
      idleBackground: theme.colors.background.elevated,
      pressedBackground: theme.colors.background.accentWash,
      disabledBackground: theme.colors.background.sunken,
      idleBorder: theme.colors.border.subtle,
      pressedBorder: theme.colors.border.accent,
      disabledBorder: theme.colors.border.subtle,
      textTone: "primary" as const,
      disabledTextTone: "secondary" as const,
      shadowColor: theme.colors.text.primary,
      elevation: 1,
    },
    destructive: {
      idleBackground:
        theme.mode === "dark"
          ? `${theme.colors.semantic.warning}22`
          : `${theme.colors.semantic.warning}18`,
      pressedBackground:
        theme.mode === "dark"
          ? `${theme.colors.semantic.warning}36`
          : `${theme.colors.semantic.warning}28`,
      disabledBackground: theme.colors.background.sunken,
      idleBorder:
        theme.mode === "dark"
          ? `${theme.colors.semantic.warning}8A`
          : `${theme.colors.semantic.warning}66`,
      pressedBorder:
        theme.mode === "dark"
          ? `${theme.colors.semantic.warning}C0`
          : `${theme.colors.semantic.warning}96`,
      disabledBorder: theme.colors.border.subtle,
      textTone: "primary" as const,
      disabledTextTone: "secondary" as const,
      shadowColor: theme.colors.semantic.warning,
      elevation: 2,
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
      minHeight: resolvedTone === "inline" ? 28 : resolvedTone === "primary" ? 58 : 54,
      paddingHorizontal: resolvedTone === "inline" ? 0 : resolvedTone === "primary" ? 22 : 18,
      paddingVertical: resolvedTone === "inline" ? 0 : resolvedTone === "primary" ? 16 : 14,
      textVariant:
        resolvedTone === "inline"
          ? ("caption" as const)
          : resolvedTone === "primary"
            ? ("body" as const)
            : ("caption" as const),
    },
    compact: {
      minHeight: resolvedTone === "inline" ? 24 : 46,
      paddingHorizontal: resolvedTone === "inline" ? 0 : 16,
      paddingVertical: resolvedTone === "inline" ? 0 : 11,
      textVariant: "caption" as const,
    },
  }[size];
  const isDisabled = disabled || busy;

  return (
    <Pressable
      {...props}
      accessibilityRole="button"
      accessibilityState={{ disabled: isDisabled, busy }}
      disabled={isDisabled}
      hitSlop={resolvedTone === "inline" ? 4 : undefined}
      className="items-center justify-center"
      style={({ pressed }) => [
        {
          borderRadius: resolvedTone === "inline" ? 0 : theme.radius.control,
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
          borderWidth: resolvedTone === "inline" ? 0 : resolvedTone === "primary" ? 1.25 : 1,
          opacity: isDisabled ? (resolvedTone === "inline" ? 0.58 : 0.68) : 1,
          transform: [{ scale: pressed && !isDisabled && !reduceMotionEnabled ? 0.982 : 1 }],
          shadowColor: tonePalette.shadowColor,
          shadowOpacity:
            resolvedTone === "primary"
              ? isDisabled
                ? 0
                : pressed
                ? 0.18
                : theme.mode === "dark"
                  ? 0.28
                  : 0.14
              : resolvedTone === "secondary" || resolvedTone === "tertiary" || resolvedTone === "destructive"
                ? isDisabled
                  ? 0
                  : pressed
                  ? 0.05
                  : theme.mode === "dark"
                    ? 0.08
                    : 0.05
                : 0,
          shadowRadius: resolvedTone === "primary" ? 22 : 10,
          shadowOffset: { width: 0, height: resolvedTone === "primary" ? 12 : 5 },
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
            fontWeight: "700",
            letterSpacing:
              resolvedTone === "primary"
                ? -0.26
                : resolvedTone === "inline"
                  ? -0.04
                  : -0.08,
            textAlign: "center",
          }}
        >
          {children}
        </AppText>
      )}
    </Pressable>
  );
}
