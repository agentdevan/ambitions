import { ReactNode } from "react";
import { View } from "react-native";

import { Surface } from "./Surface";
import { AppText } from "./Text";

interface EmptyStateCardProps {
  eyebrow?: string;
  title: string;
  body: string;
  tone?: "default" | "accent" | "sunken";
  action?: ReactNode;
}

export function EmptyStateCard({
  eyebrow,
  title,
  body,
  tone = "default",
  action,
}: EmptyStateCardProps) {
  return (
    <Surface tone={tone}>
      <View className="gap-2.5">
        {eyebrow ? (
          <AppText variant="micro" tone="tertiary" style={{ textTransform: "uppercase" }}>
            {eyebrow}
          </AppText>
        ) : null}
        <AppText variant="title">{title}</AppText>
        <AppText tone="secondary">{body}</AppText>
        {action}
      </View>
    </Surface>
  );
}
