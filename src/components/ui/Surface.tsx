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
      shadowOpacity: 0.1,
      elevation: 5,
    },
    accent: {
      backgroundColor: "#E9EFE6",
      borderColor: theme.colors.border.strong,
      accentColor: theme.colors.accent.primary,
      shadowOpacity: 0.14,
      elevation: 6,
    },
    sunken: {
      backgroundColor: "#EEE8E0",
      borderColor: "#E0D8CF",
      accentColor: "#F7F2EB",
      shadowOpacity: 0.06,
      elevation: 2,
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
          shadowRadius: tone === "accent" ? 22 : 16,
          shadowOffset: { width: 0, height: tone === "accent" ? 12 : 8 },
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
          height: 4,
          backgroundColor: toneMap[tone].accentColor,
          opacity: tone === "accent" ? 0.5 : 0.85,
        }}
      />
      {children}
    </View>
  );
}
