import { ReactNode } from "react";
import { ActivityIndicator, Pressable, PressableProps, StyleProp, View, ViewStyle } from "react-native";

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
  const isWarmGoldLight = theme.mode === "light" && theme.accentTheme === "gold";
  const tonePalette = {
    primary: {
      idleBackground: isWarmGoldLight ? theme.colors.accent.muted : theme.colors.accent.primary,
      pressedBackground: isWarmGoldLight ? theme.colors.accent.primary : theme.colors.accent.muted,
      disabledBackground: theme.colors.background.sunken,
      idleBorder: isWarmGoldLight ? theme.colors.accent.muted : theme.colors.accent.primary,
      pressedBorder: theme.colors.accent.primary,
      disabledBorder: theme.colors.border.subtle,
      textTone: "inverse" as const,
      disabledTextTone: "secondary" as const,
      textColor: theme.colors.accent.contrast,
      disabledTextColor: theme.colors.text.tertiary,
      shadowColor: isWarmGoldLight ? theme.colors.accent.muted : theme.colors.accent.primary,
      innerGlow: isWarmGoldLight ? `${theme.colors.accent.primary}18` : theme.colors.accent.glow,
      elevation: 7,
    },
    secondary: {
      idleBackground: isWarmGoldLight ? theme.colors.background.accentWashStrong : theme.colors.background.elevatedSecondary,
      pressedBackground: isWarmGoldLight ? theme.colors.background.accentWash : theme.colors.background.accentWashStrong,
      disabledBackground: theme.colors.background.sunken,
      idleBorder: isWarmGoldLight ? theme.colors.border.accent : theme.colors.border.strong,
      pressedBorder: theme.colors.border.accent,
      disabledBorder: theme.colors.border.subtle,
      textTone: "primary" as const,
      disabledTextTone: "secondary" as const,
      textColor: theme.colors.text.primary,
      disabledTextColor: theme.colors.text.tertiary,
      shadowColor: theme.colors.text.primary,
      innerGlow: theme.colors.background.cardTint,
      elevation: 3,
    },
    tertiary: {
      idleBackground:
        theme.mode === "dark"
          ? theme.colors.background.elevated
          : isWarmGoldLight
            ? theme.colors.background.accentWash
            : theme.colors.background.sunken,
      pressedBackground: isWarmGoldLight ? theme.colors.background.accentWashStrong : theme.colors.background.accentWash,
      disabledBackground: theme.colors.background.sunken,
      idleBorder: isWarmGoldLight ? theme.colors.border.accent : theme.colors.border.strong,
      pressedBorder: theme.colors.border.accent,
      disabledBorder: theme.colors.border.subtle,
      textTone: "primary" as const,
      disabledTextTone: "secondary" as const,
      textColor: theme.colors.text.primary,
      disabledTextColor: theme.colors.text.tertiary,
      shadowColor: theme.colors.text.primary,
      innerGlow: theme.colors.background.cardTint,
      elevation: 2,
    },
    destructive: {
      idleBackground: theme.colors.semantic.warning,
      pressedBackground:
        theme.mode === "dark"
          ? theme.colors.accent.muted
          : theme.colors.accent.muted,
      disabledBackground: theme.colors.background.sunken,
      idleBorder: theme.colors.semantic.warning,
      pressedBorder: theme.colors.accent.muted,
      disabledBorder: theme.colors.border.subtle,
      textTone: "inverse" as const,
      disabledTextTone: "secondary" as const,
      textColor: theme.colors.accent.contrast,
      disabledTextColor: theme.colors.text.tertiary,
      shadowColor: theme.colors.semantic.warning,
      innerGlow:
        theme.mode === "dark"
          ? `${theme.colors.semantic.warning}22`
          : `${theme.colors.semantic.warning}18`,
      elevation: 4,
    },
    inline: {
      idleBackground: theme.colors.background.elevatedSecondary,
      pressedBackground: theme.colors.background.accentWashStrong,
      disabledBackground: theme.colors.background.sunken,
      idleBorder: theme.colors.border.strong,
      pressedBorder: theme.colors.border.accent,
      disabledBorder: theme.colors.border.subtle,
      textTone: "accent" as const,
      disabledTextTone: "secondary" as const,
      textColor: theme.colors.accent.primary,
      disabledTextColor: theme.colors.text.tertiary,
      shadowColor: theme.colors.accent.primary,
      innerGlow: theme.colors.accent.wash,
      elevation: 1,
    },
  }[resolvedTone];
  const sizing = {
    default: {
      minHeight: resolvedTone === "inline" ? 42 : resolvedTone === "primary" || resolvedTone === "destructive" ? 60 : 54,
      paddingHorizontal: resolvedTone === "inline" ? 14 : resolvedTone === "primary" || resolvedTone === "destructive" ? 22 : 18,
      paddingVertical: resolvedTone === "inline" ? 10 : resolvedTone === "primary" || resolvedTone === "destructive" ? 16 : 13,
      textVariant:
        resolvedTone === "inline"
          ? ("micro" as const)
          : resolvedTone === "primary" || resolvedTone === "destructive"
            ? ("body" as const)
            : ("caption" as const),
    },
    compact: {
      minHeight: resolvedTone === "inline" ? 36 : resolvedTone === "destructive" ? 46 : 46,
      paddingHorizontal: resolvedTone === "inline" ? 12 : 15,
      paddingVertical: resolvedTone === "inline" ? 8 : 10,
      textVariant: resolvedTone === "inline" ? ("micro" as const) : ("caption" as const),
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
          borderRadius: resolvedTone === "inline" ? theme.radius.compactControl : theme.radius.control,
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
          borderWidth: resolvedTone === "primary" || resolvedTone === "destructive" ? 1.35 : 1,
          opacity: isDisabled ? (resolvedTone === "inline" ? 0.58 : 0.68) : 1,
          transform: [
            { scale: pressed && !isDisabled && !reduceMotionEnabled ? 0.982 : 1 },
            { translateY: pressed && !isDisabled && !reduceMotionEnabled ? 1 : 0 },
          ],
          shadowColor: tonePalette.shadowColor,
          shadowOpacity:
            resolvedTone === "primary" || resolvedTone === "destructive"
              ? isDisabled
                ? 0
                : pressed
                ? 0.2
                : theme.mode === "dark"
                  ? 0.32
                  : 0.16
              : resolvedTone === "secondary" || resolvedTone === "tertiary"
                ? isDisabled
                  ? 0
                  : pressed
                  ? 0.05
                  : theme.mode === "dark"
                    ? 0.08
                    : 0.05
                : isDisabled
                  ? 0
                  : pressed
                    ? 0.08
                    : theme.mode === "dark"
                      ? 0.14
                      : 0.08,
          shadowRadius: resolvedTone === "primary" || resolvedTone === "destructive" ? 24 : 10,
          shadowOffset: { width: 0, height: resolvedTone === "primary" || resolvedTone === "destructive" ? 12 : 5 },
          elevation: isDisabled ? 0 : tonePalette.elevation,
        },
        style,
      ]}
    >
      {({ pressed }) => (
        <>
          <View
            pointerEvents="none"
            style={{
              position: "absolute",
              top: 1,
              left: 1,
              right: 1,
              height:
                resolvedTone === "primary" || resolvedTone === "destructive"
                  ? "46%"
                  : resolvedTone === "inline"
                    ? "52%"
                    : "42%",
              borderTopLeftRadius: resolvedTone === "inline" ? theme.radius.compactControl : theme.radius.control,
              borderTopRightRadius: resolvedTone === "inline" ? theme.radius.compactControl : theme.radius.control,
              backgroundColor: tonePalette.innerGlow,
              opacity:
                isDisabled ? 0 : pressed ? 0.08 : resolvedTone === "primary" || resolvedTone === "destructive" ? 0.22 : 0.14,
            }}
          />
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
                color: isDisabled ? tonePalette.disabledTextColor : tonePalette.textColor,
                fontWeight: "700",
                letterSpacing:
                  resolvedTone === "primary" || resolvedTone === "destructive"
                    ? -0.26
                    : resolvedTone === "inline"
                      ? 0.28
                      : -0.08,
                textAlign: "center",
              }}
            >
              {children}
            </AppText>
          )}
        </>
      )}
    </Pressable>
  );
}
