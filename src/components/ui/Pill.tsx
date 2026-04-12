import { View } from "react-native";

import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
import { AppText } from "./Text";

interface PillProps {
  label: string;
  tone?: "neutral" | "accent" | "quiet";
}

export function Pill({ label, tone = "neutral" }: PillProps) {
  const theme = useResolvedTheme();
  const toneMap: Record<
    NonNullable<PillProps["tone"]>,
    { backgroundColor: string; borderColor: string; textTone: "secondary" | "tertiary" }
  > = {
    neutral: {
      backgroundColor: theme.colors.background.elevated,
      borderColor: theme.colors.border.subtle,
      textTone: "secondary",
    },
    accent: {
      backgroundColor: theme.colors.background.accentWash,
      borderColor: `${theme.colors.accent.primary}35`,
      textTone: "secondary",
    },
    quiet: {
      backgroundColor: theme.colors.background.sunken,
      borderColor: theme.colors.border.subtle,
      textTone: "secondary",
    },
  };

  return (
    <View
      className="self-start rounded-full px-2.5 py-1"
      style={{
        backgroundColor: toneMap[tone].backgroundColor,
        borderWidth: 1,
        borderColor: toneMap[tone].borderColor,
      }}
    >
      <AppText tone={toneMap[tone].textTone} variant="micro" numberOfLines={1}>
        {label}
      </AppText>
    </View>
  );
}
