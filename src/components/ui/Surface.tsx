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
      backgroundColor: "#FFFCF8",
      borderColor: "#D3C6B7",
      accentColor: "#FFFFFF",
      shadowOpacity: 0.16,
      shadowRadius: 22,
      shadowOffset: { width: 0, height: 12 },
      elevation: 7,
      washOpacity: 0.42,
    },
    accent: {
      backgroundColor: "#DCE7D7",
      borderColor: "#B7C5B1",
      accentColor: theme.colors.accent.primary,
      shadowOpacity: 0.22,
      shadowRadius: 26,
      shadowOffset: { width: 0, height: 16 },
      elevation: 9,
      washOpacity: 0.24,
    },
    sunken: {
      backgroundColor: "#E7DDD1",
      borderColor: "#CFC0AE",
      accentColor: "#F3ECE3",
      shadowOpacity: 0.05,
      shadowRadius: 10,
      shadowOffset: { width: 0, height: 4 },
      elevation: 2,
      washOpacity: 0.12,
    },
  };

  return (
    <View
      {...props}
      className={`overflow-hidden rounded-[22px] px-4 py-4 mb-3 ${className}`.trim()}
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
          height: tone === "sunken" ? "38%" : "46%",
          borderTopLeftRadius: 21,
          borderTopRightRadius: 21,
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
          height: tone === "accent" ? 6 : tone === "default" ? 4 : 3,
          backgroundColor: toneMap[tone].accentColor,
          opacity: tone === "accent" ? 0.82 : tone === "default" ? 0.62 : 0.36,
        }}
      />
      {children}
    </View>
  );
}
