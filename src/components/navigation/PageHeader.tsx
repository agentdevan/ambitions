import { ReactNode } from "react";
import { View } from "react-native";

import { AppText } from "../ui/Text";

interface PageHeaderProps {
  eyebrow: string;
  title: string;
  description: string;
  action?: ReactNode;
}

export function PageHeader({
  eyebrow,
  title,
  description,
  action = null,
}: PageHeaderProps) {
  return (
    <View className="gap-3 pt-2">
      <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
        {eyebrow}
      </AppText>
      <View className="flex-row items-end justify-between gap-4">
        <View className="flex-1 gap-2">
          <AppText variant="hero">{title}</AppText>
          <AppText tone="secondary">{description}</AppText>
        </View>
        {action}
      </View>
    </View>
  );
}
