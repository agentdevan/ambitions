import { View } from "react-native";

import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
import { AppText } from "./Text";

interface MetricCardProps {
  label: string;
  value: string;
  detail?: string;
}

export function MetricCard({ label, value, detail }: MetricCardProps) {
  const theme = useResolvedTheme();

  return (
    <View
      className="min-w-[92px] flex-1 rounded-[20px] px-4 py-3.5"
      style={{
        borderWidth: 1,
        borderColor: theme.colors.border.subtle,
        backgroundColor: theme.colors.background.elevated,
      }}
    >
      <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
        {label}
      </AppText>
      <AppText variant="section" numberOfLines={1} style={{ marginTop: 8 }}>
        {value}
      </AppText>
      {detail ? (
        <AppText tone="secondary" variant="caption" style={{ marginTop: 6 }}>
          {detail}
        </AppText>
      ) : null}
    </View>
  );
}
