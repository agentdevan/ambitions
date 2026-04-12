import { ReactNode } from "react";
import { View } from "react-native";

import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
import { AppText } from "../ui/Text";

interface PageHeaderProps {
  eyebrow: string;
  title: string;
  description?: string | null;
  action?: ReactNode;
}

export function PageHeader({
  eyebrow,
  title,
  description = null,
  action = null,
}: PageHeaderProps) {
  const theme = useResolvedTheme();

  return (
    <View className="gap-3 pt-2 pb-1">
      <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
        {eyebrow}
      </AppText>
      <View className="flex-row items-end justify-between gap-3">
        <View className="flex-1 gap-1.5">
          <AppText variant="hero">{title}</AppText>
          {description ? (
            <AppText tone="secondary" style={{ maxWidth: "90%", color: theme.colors.text.secondary }}>
              {description}
            </AppText>
          ) : null}
        </View>
        {action}
      </View>
    </View>
  );
}
