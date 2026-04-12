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
  return (
    <View className="gap-2.5 pt-2 pb-1">
      <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
        {eyebrow}
      </AppText>
      <View className="flex-row items-start justify-between gap-3">
        <View className="flex-1 gap-1.5">
          <AppText variant="hero">{title}</AppText>
          {description ? (
            <AppText tone="secondary" style={{ maxWidth: "92%" }}>
              {description}
            </AppText>
          ) : null}
        </View>
        {action}
      </View>
    </View>
  );
}
