import { View } from "react-native";

import { AppText } from "./Text";

interface PillProps {
  label: string;
  tone?: "neutral" | "accent";
}

const toneMap = {
  neutral: "bg-[#ECE7DE]",
  accent: "bg-[#DDE5DB]",
};

export function Pill({ label, tone = "neutral" }: PillProps) {
  return (
    <View className={`self-start rounded-full px-3 py-1 ${toneMap[tone]}`}>
      <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
        {label}
      </AppText>
    </View>
  );
}
