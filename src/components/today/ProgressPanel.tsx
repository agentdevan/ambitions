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
    <Surface className="gap-5">
      <View className="gap-2">
        <AppText tone="secondary" variant="caption">
          Progress
        </AppText>
        <AppText variant="section">Enough movement to keep the day intact</AppText>
      </View>

      <View className="flex-row gap-3">
        <Metric label="Done" value={String(completed)} />
        <Metric label="Active" value={String(scheduled)} />
        <Metric label="Rolled" value={String(rolled)} />
      </View>

      <AppText tone="secondary" style={{ maxWidth: 300 }}>
        Rollover stays visible, but quiet. It is part of the plan, not a reprimand.
      </AppText>
    </Surface>
  );
}

function Metric({ label, value }: { label: string; value: string }) {
  return (
    <View className="flex-1 rounded-[22px] border border-[#E6DFD5] bg-[#FBF8F3] px-4 py-3">
      <AppText tone="tertiary" variant="micro">
        {label}
      </AppText>
      <AppText variant="title" style={{ marginTop: 6 }}>
        {value}
      </AppText>
    </View>
  );
}
