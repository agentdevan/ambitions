import { PropsWithChildren } from "react";
import { View, ViewProps } from "react-native";

import { useResolvedTheme } from "../../design/theme/useResolvedTheme";

interface SurfaceProps extends PropsWithChildren, ViewProps {
  tone?: "default" | "accent" | "sunken" | "hero";
}

export function Surface({ children, className = "", tone = "default", style, ...props }: SurfaceProps) {
  const theme = useResolvedTheme();
  const toneMap = {
    default: {
      backgroundColor: theme.colors.background.elevated,
      borderColor: theme.colors.border.subtle,
      accentColor: theme.colors.background.cardTint,
      shadowOpacity: theme.mode === "dark" ? 0.14 : 0.04,
      shadowRadius: theme.mode === "dark" ? 18 : 12,
      shadowOffset: { width: 0, height: theme.mode === "dark" ? 10 : 6 },
      elevation: 2,
      washOpacity: theme.mode === "dark" ? 0.06 : 0.42,
    },
    accent: {
      backgroundColor: theme.colors.background.accentWash,
      borderColor: theme.colors.border.accent,
      accentColor: theme.colors.accent.glow,
      shadowOpacity: theme.mode === "dark" ? 0.16 : 0.06,
      shadowRadius: 16,
      shadowOffset: { width: 0, height: 8 },
      elevation: 3,
      washOpacity: theme.mode === "dark" ? 0.04 : 0.26,
    },
    sunken: {
      backgroundColor: theme.colors.background.sunken,
      borderColor: theme.colors.border.subtle,
      accentColor: theme.colors.background.cardTint,
      shadowOpacity: 0.02,
      shadowRadius: 6,
      shadowOffset: { width: 0, height: 2 },
      elevation: 0,
      washOpacity: theme.mode === "dark" ? 0.03 : 0.16,
    },
    hero: {
      backgroundColor: theme.colors.background.hero,
      borderColor: theme.colors.border.subtle,
      accentColor: theme.colors.accent.glow,
      shadowOpacity: theme.mode === "dark" ? 0.2 : 0.07,
      shadowRadius: 22,
      shadowOffset: { width: 0, height: 12 },
      elevation: 4,
      washOpacity: theme.mode === "dark" ? 0.04 : 0.32,
    },
  };

  return (
    <View
      {...props}
      className={`overflow-hidden px-4 py-4 ${className}`.trim()}
      style={[
        {
          borderRadius: theme.radius.card,
          backgroundColor: toneMap[tone].backgroundColor,
          borderColor: toneMap[tone].borderColor,
          borderWidth: 1,
          shadowColor: theme.colors.shadow.color,
          shadowOpacity: toneMap[tone].shadowOpacity,
          shadowRadius: toneMap[tone].shadowRadius,
          shadowOffset: toneMap[tone].shadowOffset,
          elevation: toneMap[tone].elevation,
        },
        style,
      ]}
    >
      <View
        pointerEvents="none"
        style={{
          position: "absolute",
          top: 1,
          left: 1,
          right: 1,
          height: tone === "sunken" ? "34%" : "40%",
          borderTopLeftRadius: theme.radius.card,
          borderTopRightRadius: theme.radius.card,
          backgroundColor: toneMap[tone].accentColor,
          opacity: toneMap[tone].washOpacity,
        }}
      />
      <View
        pointerEvents="none"
        style={{
          position: "absolute",
          top: 0,
          left: 0,
          right: 0,
          height: tone === "hero" ? 4 : tone === "accent" ? 3 : tone === "default" ? 2 : 1,
          backgroundColor: toneMap[tone].accentColor,
          opacity: tone === "hero" ? 0.72 : tone === "accent" ? 0.5 : tone === "default" ? 0.22 : 0.16,
        }}
      />
      {children}
    </View>
  );
}
