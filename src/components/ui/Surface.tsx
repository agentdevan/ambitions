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
      shadowOpacity: 0.06,
      elevation: 3,
    },
    accent: {
      backgroundColor: theme.colors.background.accentWash,
      borderColor: theme.colors.border.subtle,
      shadowOpacity: 0.08,
      elevation: 4,
    },
    sunken: {
      backgroundColor: theme.colors.background.sunken,
      borderColor: theme.colors.border.subtle,
      shadowOpacity: 0.03,
      elevation: 1,
    },
  };

  return (
    <View
      {...props}
      className={`rounded-[30px] border px-5 py-5 ${className}`.trim()}
      style={[
        {
          backgroundColor: toneMap[tone].backgroundColor,
          borderColor: toneMap[tone].borderColor,
          borderWidth: 1,
          shadowColor: theme.colors.text.primary,
          shadowOpacity: toneMap[tone].shadowOpacity,
          shadowRadius: tone === "accent" ? 22 : 18,
          shadowOffset: { width: 0, height: tone === "accent" ? 12 : 10 },
          elevation: toneMap[tone].elevation,
        },
        style,
      ]}
    >
      {children}
    </View>
  );
}
