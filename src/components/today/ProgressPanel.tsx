import { View } from "react-native";

import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
import { Pill } from "../ui/Pill";
import { Surface } from "../ui/Surface";
import { AppText } from "../ui/Text";

interface ProgressPanelProps {
  completed: number;
  scheduled: number;
  recovery: number;
}

export function ProgressPanel({ completed, scheduled, recovery }: ProgressPanelProps) {
  const theme = useResolvedTheme();

  function Metric({ label, value }: { label: string; value: string }) {
    return (
      <View
        className="flex-1 rounded-[22px] px-4 py-3"
        style={{
          borderWidth: 1,
          borderColor: theme.colors.border.subtle,
          backgroundColor: theme.colors.background.elevated,
        }}
      >
        <AppText tone="tertiary" variant="micro">
          {label}
        </AppText>
        <AppText variant="title" style={{ marginTop: 6 }}>
          {value}
        </AppText>
      </View>
    );
  }

  return (
    <Surface className="gap-5">
      <View className="gap-2">
        <View className="flex-row flex-wrap gap-2">
          <Pill label="Progress" />
        </View>
        <AppText variant="section">Enough movement to keep the day intact</AppText>
      </View>

      <View className="flex-row gap-3">
        <Metric label="Done" value={String(completed)} />
        <Metric label="Active" value={String(scheduled)} />
        <Metric label="Recovery" value={String(recovery)} />
      </View>

      <AppText tone="secondary" style={{ maxWidth: 300 }}>
        Recovery stays visible, but quiet. Missed work should return as a smaller or cleaner next
        step, not as guilt.
      </AppText>
    </Surface>
  );
}
