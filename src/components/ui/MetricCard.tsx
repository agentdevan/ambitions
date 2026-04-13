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
      className="min-w-[92px] flex-1 px-4 py-4"
      style={{
        borderRadius: theme.radius.row,
        borderWidth: 1,
        borderColor: theme.colors.border.subtle,
        backgroundColor: theme.colors.background.elevatedSecondary,
      }}
    >
      <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
        {label}
      </AppText>
      <AppText variant="section" numberOfLines={2} style={{ marginTop: 8 }}>
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
