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
      accentColor: theme.colors.background.canvas,
      shadowOpacity: 0.08,
      elevation: 4,
    },
    accent: {
      backgroundColor: theme.colors.background.accentWash,
      borderColor: theme.colors.border.strong,
      accentColor: theme.colors.accent.primary,
      shadowOpacity: 0.12,
      elevation: 5,
    },
    sunken: {
      backgroundColor: theme.colors.background.sunken,
      borderColor: theme.colors.background.sunken,
      accentColor: theme.colors.border.subtle,
      shadowOpacity: 0.04,
      elevation: 1,
    },
  };

  return (
    <View
      {...props}
      className={`overflow-hidden rounded-[32px] px-5 py-5 ${className}`.trim()}
      style={[
        {
          backgroundColor: toneMap[tone].backgroundColor,
          borderColor: toneMap[tone].borderColor,
          borderWidth: tone === "sunken" ? 0 : 1,
          shadowColor: theme.colors.text.primary,
          shadowOpacity: toneMap[tone].shadowOpacity,
          shadowRadius: tone === "accent" ? 26 : 20,
          shadowOffset: { width: 0, height: tone === "accent" ? 14 : 10 },
          elevation: toneMap[tone].elevation,
        },
        style,
      ]}
    >
      <View
        pointerEvents="none"
        style={{
          position: "absolute",
          top: 0,
          left: 0,
          right: 0,
          height: tone === "sunken" ? 0 : 5,
          backgroundColor: toneMap[tone].accentColor,
          opacity: tone === "accent" ? 0.24 : 0.55,
        }}
      />
      {children}
    </View>
  );
}
