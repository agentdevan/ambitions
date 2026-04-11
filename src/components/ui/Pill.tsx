import { View } from "react-native";

import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
import { AppText } from "./Text";

interface PillProps {
  label: string;
  tone?: "neutral" | "accent";
}

export function Pill({ label, tone = "neutral" }: PillProps) {
  const theme = useResolvedTheme();
  const toneMap = {
    neutral: theme.colors.background.sunken,
    accent: theme.colors.background.accentWash,
  };

  return (
    <View
      className="self-start rounded-full px-3 py-1"
      style={{ backgroundColor: toneMap[tone] }}
    >
      <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
        {label}
      </AppText>
    </View>
  );
}
