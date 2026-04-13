import { View } from "react-native";

import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
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
  const theme = useResolvedTheme();

  return (
    <Surface tone="sunken" className="gap-4">
      <View className="gap-2">
        <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
          Capacity
        </AppText>
        <AppText variant="section">Day limits</AppText>
        <AppText tone="secondary">{focus}</AppText>
      </View>

      <View
        className="gap-3 rounded-[18px] px-4 py-4"
        style={{
          backgroundColor: theme.colors.background.elevated,
          borderWidth: 1,
          borderColor: theme.colors.border.strong,
          shadowColor: theme.colors.shadow.color,
          shadowOpacity: theme.mode === "dark" ? 0.08 : 0.04,
          shadowRadius: 10,
          shadowOffset: { width: 0, height: 4 },
        }}
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
          {capacity.mentalLoad} load. {capacity.planPressure} pressure.{" "}
          {Math.round(capacity.confidence * 100)}% confidence
          {capacity.overloadWarning ? ". Some work stayed out." : "."}
        </AppText>
      </View>
    </Surface>
  );
}
