import { View } from "react-native";

import { MetricCard } from "../ui/MetricCard";
import { Pill } from "../ui/Pill";
import { Surface } from "../ui/Surface";
import { AppText } from "../ui/Text";

interface ProgressPanelProps {
  completed: number;
  scheduled: number;
  recovery: number;
}

export function ProgressPanel({ completed, scheduled, recovery }: ProgressPanelProps) {
  return (
    <Surface className="gap-5">
      <View className="gap-2">
        <View className="flex-row flex-wrap gap-2">
          <Pill label="Progress" tone="accent" />
        </View>
        <AppText variant="section">Enough movement to keep the day intact</AppText>
      </View>

      <View className="flex-row gap-3">
        <MetricCard label="Done" value={String(completed)} />
        <MetricCard label="Active" value={String(scheduled)} />
        <MetricCard label="Recovery" value={String(recovery)} />
      </View>

      <AppText tone="secondary" style={{ maxWidth: 300 }}>
        Recovery stays visible, but quiet. Missed work should return as a smaller or cleaner next
        step, not as guilt.
      </AppText>
    </Surface>
  );
}
