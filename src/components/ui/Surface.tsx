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
      backgroundColor: "#FBF8F3",
      borderColor: "#D9D0C4",
      accentColor: "#FFFFFF",
      shadowOpacity: 0.13,
      shadowRadius: 20,
      shadowOffset: { width: 0, height: 10 },
      elevation: 6,
      washOpacity: 0.28,
    },
    accent: {
      backgroundColor: "#E2EAE0",
      borderColor: "#C5D1C0",
      accentColor: theme.colors.accent.primary,
      shadowOpacity: 0.18,
      shadowRadius: 24,
      shadowOffset: { width: 0, height: 14 },
      elevation: 8,
      washOpacity: 0.18,
    },
    sunken: {
      backgroundColor: "#ECE5DC",
      borderColor: "#D8CDBF",
      accentColor: "#F7F2EB",
      shadowOpacity: 0.08,
      shadowRadius: 12,
      shadowOffset: { width: 0, height: 5 },
      elevation: 2,
      washOpacity: 0.1,
    },
  };

  return (
    <View
      {...props}
      className={`overflow-hidden rounded-[20px] px-4 py-4 mb-3 ${className}`.trim()}
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
          height: "48%",
          borderTopLeftRadius: 19,
          borderTopRightRadius: 19,
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
          height: tone === "accent" ? 5 : 4,
          backgroundColor: toneMap[tone].accentColor,
          opacity: tone === "accent" ? 0.72 : tone === "default" ? 0.55 : 0.42,
        }}
      />
      {children}
    </View>
  );
}
