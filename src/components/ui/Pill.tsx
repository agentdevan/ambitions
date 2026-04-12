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
      backgroundColor: "#F1E8DC",
      borderColor: "#D1C1AF",
      textTone: "secondary",
    },
    accent: {
      backgroundColor: "#D4E1CF",
      borderColor: "#AEC3A7",
      textTone: "secondary",
    },
    quiet: {
      backgroundColor: "#EFE6DA",
      borderColor: "#DACBBB",
      textTone: "tertiary",
    },
  };

  return (
    <View
      className="self-start rounded-full px-3.5 py-1.5"
      style={{
        backgroundColor: toneMap[tone].backgroundColor,
        borderWidth: 1,
        borderColor: toneMap[tone].borderColor,
        shadowColor: theme.colors.text.primary,
        shadowOpacity: 0.05,
        shadowRadius: 5,
        shadowOffset: { width: 0, height: 2 },
      }}
    >
      <AppText tone={toneMap[tone].textTone} variant="micro" numberOfLines={1}>
        {label}
      </AppText>
    </View>
  );
}
