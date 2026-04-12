import { PropsWithChildren } from "react";
import { View, ViewProps } from "react-native";

import { useResolvedTheme } from "../../design/theme/useResolvedTheme";

interface SurfaceProps extends PropsWithChildren, ViewProps {
  tone?: "default" | "accent" | "sunken";
}

export function Surface({ children, className = "", tone = "default", style, ...props }: SurfaceProps) {
  const theme = useResolvedTheme();
  const toneMap = {
    default: {
      backgroundColor: theme.colors.background.elevated,
      borderColor: theme.colors.border.subtle,
      accentColor: "#FFFFFF",
      shadowOpacity: 0.06,
      shadowRadius: 14,
      shadowOffset: { width: 0, height: 8 },
      elevation: 2,
      washOpacity: 0.22,
    },
    accent: {
      backgroundColor: theme.colors.background.accentWash,
      borderColor: `${theme.colors.accent.primary}33`,
      accentColor: theme.colors.accent.primary,
      shadowOpacity: 0.08,
      shadowRadius: 16,
      shadowOffset: { width: 0, height: 10 },
      elevation: 3,
      washOpacity: 0.16,
    },
    sunken: {
      backgroundColor: theme.colors.background.sunken,
      borderColor: theme.colors.border.subtle,
      accentColor: theme.colors.border.subtle,
      shadowOpacity: 0.02,
      shadowRadius: 6,
      shadowOffset: { width: 0, height: 2 },
      elevation: 0,
      washOpacity: 0.08,
    },
  };

  return (
    <View
      {...props}
      className={`overflow-hidden rounded-[24px] px-5 py-5 mb-3 ${className}`.trim()}
      style={[
        {
          backgroundColor: toneMap[tone].backgroundColor,
          borderColor: toneMap[tone].borderColor,
          borderWidth: 1,
          shadowColor: theme.colors.text.primary,
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
          borderTopLeftRadius: 23,
          borderTopRightRadius: 23,
          backgroundColor: "#FFFFFF",
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
          height: tone === "accent" ? 4 : tone === "default" ? 2 : 1,
          backgroundColor: toneMap[tone].accentColor,
          opacity: tone === "accent" ? 0.65 : tone === "default" ? 0.25 : 0.18,
        }}
      />
      {children}
    </View>
  );
}
