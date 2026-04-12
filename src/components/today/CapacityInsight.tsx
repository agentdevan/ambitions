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
      <View className="gap-3">
        <AppText tone="secondary" variant="micro" style={{ textTransform: "uppercase" }}>
          Capacity
        </AppText>
        <AppText variant="section">
          {capacity.focusBudgetMinutes} minutes committed inside {capacity.usableMinutes} usable
          minutes.
        </AppText>
        <AppText tone="secondary" style={{ maxWidth: 300 }}>
          {focus}
        </AppText>
      </View>

      <View className="flex-row gap-3">
        <MetricCard label="Mental load" value={capacity.mentalLoad} />
        <MetricCard label="Pressure" value={capacity.planPressure} />
        <MetricCard label="Open" value={`${capacity.unusedCapacityMinutes} min`} />
      </View>

      <AppText tone="secondary" variant="caption">
        Confidence {Math.round(capacity.confidence * 100)}%
        {capacity.overloadWarning ? ", with excess demand left unscheduled." : "."}
      </AppText>
    </Surface>
  );
}
