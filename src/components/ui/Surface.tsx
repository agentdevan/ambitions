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
      shadowOpacity: theme.mode === "dark" ? 0.16 : 0.05,
      shadowRadius: theme.mode === "dark" ? 20 : 14,
      shadowOffset: { width: 0, height: theme.mode === "dark" ? 12 : 7 },
      elevation: 2,
      washOpacity: theme.mode === "dark" ? 0.08 : 0.48,
    },
    accent: {
      backgroundColor: theme.colors.background.accentWash,
      borderColor: theme.colors.border.accent,
      accentColor: theme.colors.accent.glow,
      shadowOpacity: theme.mode === "dark" ? 0.18 : 0.08,
      shadowRadius: 18,
      shadowOffset: { width: 0, height: 10 },
      elevation: 3,
      washOpacity: theme.mode === "dark" ? 0.08 : 0.3,
    },
    sunken: {
      backgroundColor: theme.colors.background.sunken,
      borderColor: theme.colors.border.subtle,
      accentColor: theme.colors.background.cardTint,
      shadowOpacity: theme.mode === "dark" ? 0.04 : 0.02,
      shadowRadius: 8,
      shadowOffset: { width: 0, height: 3 },
      elevation: 0,
      washOpacity: theme.mode === "dark" ? 0.04 : 0.18,
    },
    hero: {
      backgroundColor: theme.colors.background.hero,
      borderColor: theme.colors.border.subtle,
      accentColor: theme.colors.accent.glow,
      shadowOpacity: theme.mode === "dark" ? 0.22 : 0.08,
      shadowRadius: 24,
      shadowOffset: { width: 0, height: 14 },
      elevation: 4,
      washOpacity: theme.mode === "dark" ? 0.07 : 0.36,
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
          left: 0,
          right: 0,
          bottom: 0,
          height: 1,
          backgroundColor: theme.mode === "dark" ? "rgba(255,255,255,0.04)" : "rgba(255,255,255,0.56)",
          opacity: tone === "sunken" ? 0.35 : 0.7,
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
