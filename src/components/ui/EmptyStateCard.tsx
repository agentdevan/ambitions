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
    <Surface tone={tone} className="gap-4">
      <View className="gap-3.5">
        {eyebrow ? (
          <AppText variant="micro" tone="tertiary" style={{ textTransform: "uppercase" }}>
            {eyebrow}
          </AppText>
        ) : null}
        <AppText variant="title" style={{ maxWidth: "96%" }}>
          {title}
        </AppText>
        <AppText tone="secondary" style={{ maxWidth: "96%" }}>
          {body}
        </AppText>
        {action}
      </View>
    </Surface>
  );
}
