import { View } from "react-native";

import { Pill } from "../ui/Pill";
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
        <AppText variant="section">Capacity stays protected for the day.</AppText>
        <AppText tone="secondary">
          {focus}
        </AppText>
      </View>

      <View
        className="gap-3 rounded-[22px] px-4 py-4"
        style={{ backgroundColor: "#F6EFE6", borderWidth: 1, borderColor: "#DDCFBF" }}
      >
        <View className="flex-row flex-wrap gap-2">
          <Pill label={`${capacity.focusBudgetMinutes} min committed`} tone="accent" />
          <Pill label={`${capacity.usableMinutes} min usable`} />
          <Pill label={`${capacity.unusedCapacityMinutes} min open`} tone="quiet" />
          <Pill label={`Load ${capacity.mentalLoad}`} />
          <Pill label={`Pressure ${capacity.planPressure}`} tone="quiet" />
        </View>

        <AppText tone="secondary" variant="caption">
          Confidence {Math.round(capacity.confidence * 100)}%
          {capacity.overloadWarning ? ", with excess demand left unscheduled." : "."}
        </AppText>
      </View>
    </Surface>
  );
}
