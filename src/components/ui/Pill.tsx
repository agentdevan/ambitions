import { View } from "react-native";

import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
import { AppText } from "./Text";

interface PillProps {
  label: string;
  tone?: "neutral" | "accent" | "quiet";
}

export function Pill({ label, tone = "neutral" }: PillProps) {
  const theme = useResolvedTheme();
  const toneMap: Record<NonNullable<PillProps["tone"]>, { backgroundColor: string; borderColor: string; textTone: "secondary" | "tertiary" }> = {
    neutral: {
      backgroundColor: "#EFE7DC",
      borderColor: "#D8CCBE",
      textTone: "secondary",
    },
    accent: {
      backgroundColor: "#D5E3D2",
      borderColor: "#B5C8B0",
      textTone: "secondary",
    },
    quiet: {
      backgroundColor: "#F5EEE5",
      borderColor: "#E2D6C8",
      textTone: "tertiary",
    },
  };

  return (
    <View
      className="self-start rounded-full px-3 py-1.5"
      style={{
        backgroundColor: toneMap[tone].backgroundColor,
        borderWidth: 1,
        borderColor: toneMap[tone].borderColor,
        shadowColor: theme.colors.text.primary,
        shadowOpacity: 0.04,
        shadowRadius: 4,
        shadowOffset: { width: 0, height: 2 },
      }}
    >
      <AppText tone={toneMap[tone].textTone} variant="micro" numberOfLines={1}>
        {label}
      </AppText>
    </View>
  );
}
