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
        shadowColor: theme.colors.shadow.color,
        shadowOpacity: theme.mode === "dark" ? 0.08 : 0.04,
        shadowRadius: 10,
        shadowOffset: { width: 0, height: 4 },
      }}
    >
      <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
        {label}
      </AppText>
      <AppText variant="title" numberOfLines={2} style={{ marginTop: 10 }}>
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
