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
    { backgroundColor: string; borderColor: string; textTone: "secondary" | "tertiary" | "inverse" }
  > = {
    neutral: {
      backgroundColor: theme.colors.background.elevatedSecondary,
      borderColor: theme.colors.border.subtle,
      textTone: "secondary",
    },
    accent: {
      backgroundColor: theme.colors.background.accentWashStrong,
      borderColor: theme.colors.border.accent,
      textTone: "secondary",
    },
    quiet: {
      backgroundColor: theme.colors.background.sunken,
      borderColor: theme.colors.border.subtle,
      textTone: "tertiary",
    },
  };

  return (
    <View
      className="self-start px-3 py-1.5"
      style={{
        borderRadius: theme.radius.pill,
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
