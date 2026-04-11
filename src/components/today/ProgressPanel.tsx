import { View } from "react-native";

import { Surface } from "../ui/Surface";
import { AppText } from "../ui/Text";

interface ProgressPanelProps {
  completed: number;
  scheduled: number;
  rolled: number;
}

export function ProgressPanel({ completed, scheduled, rolled }: ProgressPanelProps) {
  return (
    <Surface className="gap-4">
      <View className="gap-1">
        <AppText tone="secondary" variant="caption">
          Progress and rollover awareness
        </AppText>
        <AppText variant="section">One completed, two still live, one held back on purpose</AppText>
      </View>

      <View className="flex-row gap-3">
        <Metric label="Done" value={String(completed)} />
        <Metric label="Active" value={String(scheduled)} />
        <Metric label="Rolled" value={String(rolled)} />
      </View>

      <AppText tone="secondary">
        The system should keep rollover visible without turning it into guilt. In later phases, this
        becomes a real adaptation signal rather than a static summary.
      </AppText>
    </Surface>
  );
}

function Metric({ label, value }: { label: string; value: string }) {
  return (
    <View className="flex-1 rounded-[20px] bg-[#FBFAF7] px-3 py-3">
      <AppText tone="tertiary" variant="micro">
        {label}
      </AppText>
      <AppText variant="title">{value}</AppText>
    </View>
  );
}
