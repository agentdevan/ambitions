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
      shadowOpacity: theme.mode === "dark" ? 0.2 : 0.06,
      shadowRadius: theme.mode === "dark" ? 24 : 18,
      shadowOffset: { width: 0, height: theme.mode === "dark" ? 14 : 10 },
      elevation: 2,
      washOpacity: theme.mode === "dark" ? 0.08 : 0.5,
    },
    accent: {
      backgroundColor: theme.colors.background.accentWash,
      borderColor: theme.colors.border.accent,
      accentColor: theme.colors.accent.glow,
      shadowOpacity: theme.mode === "dark" ? 0.26 : 0.1,
      shadowRadius: 22,
      shadowOffset: { width: 0, height: 12 },
      elevation: 3,
      washOpacity: theme.mode === "dark" ? 0.05 : 0.35,
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
      shadowOpacity: theme.mode === "dark" ? 0.3 : 0.08,
      shadowRadius: 28,
      shadowOffset: { width: 0, height: 16 },
      elevation: 4,
      washOpacity: theme.mode === "dark" ? 0.05 : 0.42,
    },
  };

  return (
    <View
      {...props}
      className={`overflow-hidden rounded-[26px] px-4 py-4 ${className}`.trim()}
      style={[
        {
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
          borderTopLeftRadius: 27,
          borderTopRightRadius: 27,
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
          height: tone === "hero" ? 5 : tone === "accent" ? 4 : tone === "default" ? 2 : 1,
          backgroundColor: toneMap[tone].accentColor,
          opacity: tone === "hero" ? 0.85 : tone === "accent" ? 0.58 : tone === "default" ? 0.24 : 0.18,
        }}
      />
      {children}
    </View>
  );
}
