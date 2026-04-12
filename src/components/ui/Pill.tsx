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
      backgroundColor: "#ECE6DD",
      borderColor: "#E0D7CC",
      textTone: "secondary",
    },
    accent: {
      backgroundColor: "#DCE8D8",
      borderColor: "#BED0B9",
      textTone: "secondary",
    },
    quiet: {
      backgroundColor: "#F6F1EA",
      borderColor: "#E7DED3",
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
      }}
    >
      <AppText tone={toneMap[tone].textTone} variant="micro" numberOfLines={1}>
        {label}
      </AppText>
    </View>
  );
}
