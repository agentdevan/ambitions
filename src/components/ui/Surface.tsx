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
    },
    accent: {
      backgroundColor: theme.colors.background.accentWash,
      borderColor: theme.colors.border.subtle,
    },
    sunken: {
      backgroundColor: theme.colors.background.sunken,
      borderColor: theme.colors.border.subtle,
    },
  };

  return (
    <View
      {...props}
      className={`rounded-[28px] border px-5 py-5 ${className}`.trim()}
      style={[
        {
          ...toneMap[tone],
          shadowColor: theme.colors.text.primary,
          shadowOpacity: tone === "sunken" ? 0.02 : 0.05,
          shadowRadius: 18,
          shadowOffset: { width: 0, height: 10 },
          elevation: tone === "sunken" ? 1 : 3,
        },
        style,
      ]}
    >
      {children}
    </View>
  );
}
