import { View } from "react-native";

import { Surface } from "../ui/Surface";
import { AppText } from "../ui/Text";

interface CapacityInsightProps {
  capacity: {
    mentalLoad: string;
    focusBudgetMinutes: number;
    meetingLoadMinutes: number;
    recoveryBudgetMinutes: number;
    usableMinutes: number;
    unusedCapacityMinutes: number;
    confidence: number;
    planPressure: "low" | "moderate" | "high";
    overloadWarning: boolean;
  };
  focus: string;
}

export function CapacityInsight({ capacity, focus }: CapacityInsightProps) {
  return (
    <Surface tone="sunken" className="gap-4">
      <View className="gap-3">
        <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
          Capacity
        </AppText>
        <AppText variant="section">Capacity guardrails</AppText>
        <AppText tone="secondary">{focus}</AppText>
      </View>

      <View
        className="gap-3 rounded-[18px] px-4 py-4"
        style={{ backgroundColor: "#F5F1EA", borderWidth: 1, borderColor: "#DDD5CB" }}
      >
        <View className="flex-row flex-wrap gap-x-6 gap-y-3">
          <View className="min-w-[96px] gap-1">
            <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
              Focus
            </AppText>
            <AppText variant="section">{capacity.focusBudgetMinutes} min</AppText>
          </View>
          <View className="min-w-[96px] gap-1">
            <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
              Usable
            </AppText>
            <AppText variant="section">{capacity.usableMinutes} min</AppText>
          </View>
          <View className="min-w-[96px] gap-1">
            <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
              Open
            </AppText>
            <AppText variant="section">{capacity.unusedCapacityMinutes} min</AppText>
          </View>
        </View>
        <AppText tone="secondary" variant="caption">
          Load is {capacity.mentalLoad}. Pressure is {capacity.planPressure}. Confidence is{" "}
          {Math.round(capacity.confidence * 100)}%
          {capacity.overloadWarning ? ", with some work left out on purpose." : "."}
        </AppText>
      </View>
    </Surface>
  );
}
