import { View } from "react-native";

import { AppText } from "./Text";

interface PillProps {
  label: string;
  tone?: "neutral" | "accent";
}

const toneMap = {
  neutral: "bg-[#ECE8E1]",
  accent: "bg-[#DDE5DB]",
};

export function Pill({ label, tone = "neutral" }: PillProps) {
  return (
    <View className={`self-start rounded-full px-3 py-1.5 ${toneMap[tone]}`}>
      <AppText tone="secondary" variant="micro">
        {label}
      </AppText>
    </View>
  );
}
