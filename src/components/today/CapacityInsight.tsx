import { View } from "react-native";

import { MetricCard } from "../ui/MetricCard";
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
    <Surface tone="accent" className="gap-5">
      <View className="gap-2">
        <AppText tone="secondary" variant="micro" style={{ textTransform: "uppercase" }}>
          Capacity
        </AppText>
        <AppText variant="section">
          {capacity.focusBudgetMinutes} minutes scheduled inside {capacity.usableMinutes} usable
          minutes.
        </AppText>
      </View>

      <AppText tone="secondary" style={{ maxWidth: 300 }}>
        {focus}
      </AppText>

      <View className="flex-row gap-3">
        <MetricCard label="Mental load" value={capacity.mentalLoad} />
        <MetricCard label="Pressure" value={capacity.planPressure} />
      </View>

      <AppText tone="secondary" variant="caption">
        {capacity.unusedCapacityMinutes} minutes remain intentionally open. Confidence{" "}
        {Math.round(capacity.confidence * 100)}%
        {capacity.overloadWarning ? ", with excess demand left unscheduled." : "."}
      </AppText>
    </Surface>
  );
}
